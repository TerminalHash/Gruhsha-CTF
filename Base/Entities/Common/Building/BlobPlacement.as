// Blob can place blocks on grid

#include "ActivationThrowCommon.as"
#include "PlacementCommon.as";
#include "BuildBlock.as";
#include "CheckSpam.as";
#include "GameplayEventsCommon.as";
#include "Requirements.as"
#include "RunnerTextures.as"
#include "BindingsCommon.as";

bool PlaceBlob(CBlob@ this, CBlob@ blob, Vec2f cursorPos, bool repairing = false, CBlob@ repairBlob = null)
{
	if (blob !is null)
	{
		// convert aimpos to tileaimpos (on server this time);
		Vec2f pos = this.getPosition();
		Vec2f mouseNorm = cursorPos - pos;
		f32 mouseLen = mouseNorm.Length();
		const f32 maxLen = MAX_BUILD_LENGTH;
		mouseNorm /= mouseLen;

		Vec2f tileaimpos;

		if (mouseLen > maxLen * getMap().tilesize)
		{
			f32 d = maxLen * getMap().tilesize;
			Vec2f p = pos + Vec2f(d * mouseNorm.x, d * mouseNorm.y);
			tileaimpos = getMap().getTileWorldPosition(getMap().getTileSpacePosition(p));
		}
		else
		{
			tileaimpos = getMap().getTileWorldPosition(getMap().getTileSpacePosition(cursorPos));
		}

		// out of range
		if (mouseLen >= getMaxBuildDistance(this) + 16.0f)
		{
			return false;
		} 

		cursorPos = getBottomOfCursor(tileaimpos, blob);

		if (!serverBlobCheck(this, blob, cursorPos, repairing, repairBlob))
			return false;

		// one day we will reach an ideal world without latency, dumb edge cases and bad netcode
		// that day is not today
		u32 delay = 2 * getCurrentBuildDelay(this) - 1;
		SetBuildDelay(this, delay);

		CShape@ shape = blob.getShape();
		shape.server_SetActive(true);

		blob.Tag("temp blob placed");
		if (blob.hasTag("has damage owner"))
		{
			blob.SetDamageOwnerPlayer(this.getPlayer());
		}

		// EPIC DIRTY HACK: change the condition for setting the blob depending on whether we are holding a seed or not.
		CBlob@ carryBlob = this.getCarriedBlob();

		if (carryBlob !is null)
		{
			if (carryBlob.getConfig() != "seed")
			{
				if (true) // for bunnie blob/block code
				{
					if (repairing && repairBlob !is null)
					{
						repairBlob.server_SetHealth(repairBlob.getInitialHealth());
						getMap().server_SetTile(repairBlob.getPosition(), blob.get_TileType("background tile"));
						blob.server_Die();
					}
					else
					{
						blob.setPosition(cursorPos);
						shape.SetStatic(true);
						DestroyScenary(cursorPos, cursorPos);
					}
					return true;
				}
			}

			//////////////////////////////////////////////////////
			//////////////////////////////////////////////////////
			else // for seed
			{
				if (this.server_DetachFrom(blob))
				{
					if (repairing && repairBlob !is null)
					{
						repairBlob.server_SetHealth(repairBlob.getInitialHealth());
						getMap().server_SetTile(repairBlob.getPosition(), blob.get_TileType("background tile"));
						blob.server_Die();
					}
					else
					{
						blob.setPosition(cursorPos);
						if (blob.isSnapToGrid())
						{
							shape.SetStatic(true);
						}
					}
				}

				DestroyScenary(cursorPos, cursorPos);

				return true;
			}
			//////////////////////////////////////////////////////
			//////////////////////////////////////////////////////

		}
	}

	return false;
}

bool numberChecker(s32 number)
{
    if (getMap().isTileGrass(number))
    return false;

    if (number == 0)
    return false;

    return true;
}

// Returns true if pos is valid
bool serverBlobCheck(CBlob@ blob, CBlob@ blobToPlace, Vec2f cursorPos, bool repairing = false, CBlob@ repairBlob = null)
{
	// Pos check of about 8 tiles, accounts for people with lag
	Vec2f pos = (blob.getPosition() - cursorPos) / 2;

	//if (pos.Length() > 30)
	if (pos.Length() > getMaxBuildDistance(blob) + 16.0f)
		return false;
	
	// Are we still on cooldown?
	if (isBuildDelayed(blob)) 
		return true;

	// Are we trying to place in a bad pos?
	CMap@ map = getMap();
	Tile backtile = map.getTile(cursorPos);

	s32 support = blobToPlace.getShape().getConsts().support;

    //cross check
    if (blobToPlace.getName() == "spikes")
    {
        Vec2f cpos = cursorPos;

        Vec2f cpos_1 = cpos + Vec2f(-8, 0);
        Vec2f cpos_2 = cpos + Vec2f(8, 0);
        Vec2f cpos_3 = cpos + Vec2f(0, 8);
        Vec2f cpos_4 = cpos + Vec2f(0, -8);

        Vec2f[] checks;
        checks.push_back(cpos_1);
        checks.push_back(cpos_2);
        checks.push_back(cpos_3);
        checks.push_back(cpos_4);

        bool got_ladder_support = false;

        for (int i=0; i<checks.length; ++i)
        {
            CBlob@[] blobs_at_pos;

            if (getMap().getBlobsAtPosition(checks[i], blobs_at_pos))
            {
                for (int g=0; g < blobs_at_pos.length; ++g)
                {
                    if (blobs_at_pos[g].getName() == "ladder")
                    {
                        got_ladder_support = true;
                    }
                }
            }
        }

        bool has_no_support = !numberChecker(getMap().getTile(cpos_1).type) && !numberChecker(getMap().getTile(cpos_2).type) && !numberChecker(getMap().getTile(cpos_3).type) && !numberChecker(getMap().getTile(cpos_4).type) && !got_ladder_support;

        if (has_no_support)
        {
            return false;
        }
    }

	if (map.isTileBedrock(backtile.type) || map.isTileSolid(backtile.type))
		return false;

	// Make sure we actually have support at our cursor pos
	if (!(blobToPlace.getShape().getConsts().support > 0 ? map.hasSupportAtPos(cursorPos) : true)) 
		return false;

	// Is the pos currently collapsing?
	if (map.isTileCollapsing(cursorPos))
		return false;

	// Is our blob not a ladder and are we trying to place it into a no build area
	if (blobToPlace.getName() != "ladder")
	{
		pos = cursorPos + Vec2f(map.tilesize * 0.2f, map.tilesize * 0.2f);

		if (map.getSectorAtPosition(pos, "no build") !is null)
			return false;
	}

	// Are we trying to place a blob on a door/ladder/platform/bridge (usually due to lag)?
	if (fakeHasTileSolidBlobs(cursorPos) && !repairing)
	{
		return false;
	}

	// Are we trying to repair something we aren't supposed to?
	if (repairing && repairBlob !is null)
	{
		// Are we trying to repair a different blob?
		if (repairBlob.getName() != blobToPlace.getName())
		{
			return false;
		}

		// Are we trying to repair something at full health?
		if (repairBlob.getHealth() == blobToPlace.getInitialHealth())
		{
			return false;
		}
	}

	return true;
} 

Vec2f getBottomOfCursor(Vec2f cursorPos, CBlob@ carryBlob=null)
{
	// check at bottom of cursor
	CMap@ map = getMap();
	f32 w = map.tilesize / 2.0f;
	f32 h = map.tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}

void PositionCarried(CBlob@ this, CBlob@ carryBlob)
{
	// rotate towards mouse if object allows
	if (carryBlob.hasTag("place45"))
	{
		f32 distance = 8.0f;
		if (carryBlob.exists("place45 distance"))
			distance = f32(carryBlob.get_s8("place45 distance"));

		f32 angleOffset = 0.0f;
		if (!carryBlob.hasTag("place45 perp"))
			angleOffset = 90.0f;

		Vec2f aimpos = this.getAimPos();
		Vec2f pos = this.getPosition();
		Vec2f aim_vec = (pos - aimpos);
		aim_vec.Normalize();
		f32 angle_step = 45.0f;
		f32 mouseAngle = (int(aim_vec.getAngleDegrees() + (angle_step * 0.5)) / int(angle_step)) * angle_step ;
		if (!this.isFacingLeft()) mouseAngle += 180;

		carryBlob.setAngleDegrees(-mouseAngle + angleOffset);
		AttachmentPoint@ hands = this.getAttachments().getAttachmentPointByName("PICKUP");

		aim_vec *= distance;

		if (hands !is null)
		{
			hands.offset.x = 0 + (aim_vec.x * 2 * (this.isFacingLeft() ? 1.0f : -1.0f)); // if blob config has offset other than 0,0 there is a desync on client, dont know why
			hands.offset.y = -(aim_vec.y * (distance < 0 ? 1.0f : 1.0f));
		}
	}
	else
	{
		if (!carryBlob.hasTag("place norotate"))
		{
			carryBlob.setAngleDegrees(0.0f);
		}
		AttachmentPoint@ hands = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (hands !is null)
		{
			// set the pickup offset according to the pink pixel
			CSprite@ sprite = this.getSprite();

			int layer = 0;
			Vec2f head_offset = getHeadOffset(this, -1, layer);
			if (layer != 0)
			{
				// set the proper offset
				Vec2f off(sprite.getFrameWidth() / 2, -sprite.getFrameHeight() / 2);
				off += Vec2f(-head_offset.x, head_offset.y);
				off.x *= -1.0f;
				hands.offset = off;
			}
			else
			{
				hands.offset.Set(0, 0);
			}

			if (this.isKeyPressed(key_down))      // hack for crouch
			{
				if (this.getName() == "archer" && sprite.isAnimation("crouch")) //hack for archer prone
				{
					hands.offset.y -= 4;
					hands.offset.x += 2;
				}
				else
				{
					hands.offset.y += 2;
				}
			}
		}
	}
}

void onInit(CBlob@ this)
{
	AddCursor(this);
	SetupBuildDelay(this);

	this.addCommandID("placeBlob");
	this.addCommandID("placeSeed");
	this.addCommandID("repairBlob");
	this.addCommandID("settleLadder");
	this.addCommandID("rotateBlob");

	this.set_u16("build_angle", 0);

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	CControls@ controls = this.getControls();

	if (controls is null || this.isInInventory())
	{
		return;
	}

	//don't build with menus open
	if (getHUD().hasMenus())
	{
		return;
	}

	CBlob @carryBlob = this.getCarriedBlob();
	if (carryBlob !is null)
	{
		if (carryBlob.hasTag("place ignore facing"))
		{
			carryBlob.getSprite().SetFacingLeft(false);
		}

		// hide block in hands when placing close
		if (!carryBlob.isSnapToGrid())
		{
			PositionCarried(this, carryBlob);
		}
		else
		{
			if (carryBlob.hasTag("place norotate"))
			{
				this.getCarriedBlob().setAngleDegrees(0.0f);
			}
			else
			{
				this.getCarriedBlob().setAngleDegrees(this.get_u16("build_angle"));
			}
		}
	}

	if (!this.isMyPlayer())
	{
		return;
	}

////                     ONLY MYPLAYER STUFF BEYOND THIS LINE                   ////
	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if (bc is null)
	{
		return;
	}

	bc.blobActive = false;

	// CODE ATHEONFISH: clientside block selection
	/*if (carryBlob is null)
	{
		return;
	}*/

	// don't draw blob locally
	if (carryBlob !is null && carryBlob.hasTag("temp blob"))
	{
		carryBlob.SetVisible(false);
	}

	if (isBuildDelayed(this))
	{
		return;
	}


	SetTileAimpos(this, bc);
	// check buildable

	bc.buildable = false;
	bc.supported = false;
	bc.hasReqs = true;

	////////////////////////////////////////////////////
	// 		Bunnie code block for blob placing		 //
	//////////////////////////////////////////////////
	// CODE ATHEONFISH: clientside block selection

	if (carryBlob !is null && carryBlob.getConfig() != "seed")
	{
		u8 blockIndex = this.get_u8("bunnie_tile");

		string blobtile = "null";
		switch (blockIndex)
		{
			case 2: blobtile = "stone_door"; break;
			case 5: blobtile = "wooden_door"; break;
			case 6: blobtile = "bridge"; break;
			case 7: blobtile = "ladder"; break;
			case 8: blobtile = "wooden_platform"; break;
			case 10: blobtile = "spikes"; break;

			case 0: blobtile = "null";
		}

		/*if (carryBlob !is null)
		{
			this.set_u8("bunnie_tile", 255);
		}*/

		BuildBlock @block = getBlockByIndex(this, blockIndex);
		if (block !is null && block.name == blobtile)
		{
			bc.hasReqs = hasRequirements(this.getInventory(), block.reqs, bc.missing, not block.buildOnGround);
		}

		if (blobtile != "null")
		{
			CMap@ map = this.getMap();
			bool snap = true;
		
			bool onetile = false;
			if (blobtile == "ladder")
			{
				onetile = true;
			}
		
			if (snap) // activate help line
			{
				bc.blobActive = true;
				bc.blockActive = false;
			}
		
			if (bc.cursorClose)
			{
				if (snap) // if snaps to grid make cursor
				{
					Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
				
					CMap@ map = this.getMap();
					TileType buildtile = 256;   // something else than a tile
					Vec2f bottomPos = getBottomOfCursor(bc.tileAimPos);

					bool overlapped;

					if (true)
					{
						Vec2f ontilepos = halftileoffset + bc.tileAimPos;

						overlapped = false;
						CBlob@[] b;

						f32 tsqr = halftileoffset.LengthSquared() - 1.0f;
					
						if (map.getBlobsInRadius(ontilepos, 0.5f, @b))
						{
							for (uint nearblob_step = 0; nearblob_step < b.length && !overlapped; ++nearblob_step)
							{
								CBlob@ blob = b[nearblob_step];

								string bname = blob.getName();
								if (blob.hasTag("player") || bname == "bush" || bname == "flowers" || bname == "log"
									|| !isBlocking(blob) || !blob.getShape().isStatic() || (blobtile == bname && (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == 255) && blob.getHealth() != blob.getInitialHealth())) continue;

								overlapped = (blob.getPosition() - ontilepos).LengthSquared() < tsqr;
							}
						}
					}
					else
					{
						overlapped = false;
					}

					u8 support = 0;

					switch (blockIndex)
					{
						case 2: support = 3; break;
						case 5: support = 3; break;
						case 6: support = 1; break;
						case 7: support = 5; break;
						case 8: support = 1; break;
						case 10: support = 0; break;

						case 0: support = 0;
					}

				
					bc.buildableAtPos = isBuildableAtPos(this, bottomPos, buildtile, null, bc.sameTileOnBack, blobtile) && !overlapped;
					//printf("hello " + isBuildableAtPos(this, bottomPos, buildtile, null, bc.sameTileOnBack, blobtile));
					bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
					bc.buildable = bc.buildableAtPos && !bc.rayBlocked;
					bc.buildable_alt = isBuildableAtPosAlt(this, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack, blobtile) && !bc.rayBlocked && !overlapped;
					bc.supported = support > 0 ? map.hasSupportAtPos(bc.tileAimPos) : true;

					//printf("buildable: " + bc.buildable);
				}
			}
		
			// place blob with action1 key
			if (!getHUD().hasButtons())
			{
				if (this.isKeyPressed(key_action1))
				{
					bool check = (bc.cursorClose && bc.buildable && bc.supported && bc.hasReqs);

					string build_mode = "vanilla";

					if (getRules().exists("build_mode"))
					{
						build_mode = getRules().get_string("build_mode");
					}

					if (build_mode == "lagfriendly") check = (bc.cursorClose && bc.hasReqs && bc.buildable_alt);

					if (snap && check)
					{
						CMap@ map = getMap();
						CBlob@ blobAtPos = map.getBlobAtPosition(getBottomOfCursor(bc.tileAimPos));
						if (blobAtPos !is null && blobtile == blobAtPos.getConfig() && blobAtPos.getHealth() < blobAtPos.getInitialHealth() && blobAtPos.getName() != "ladder")
						{
							CBitStream params;
							params.write_string(blobtile);
							params.write_Vec2f(getBottomOfCursor(bc.tileAimPos, null));
							params.write_u8(blockIndex);
							params.write_u16(blobAtPos.getNetworkID());
							this.SendCommand(this.getCommandID("repairBlob"), params);
						}
						else
						{
							CBitStream params;
							params.write_string(blobtile);
							params.write_Vec2f(getBottomOfCursor(bc.tileAimPos, null));
							params.write_u8(blockIndex);
							this.SendCommand(this.getCommandID("placeBlob"), params);
						}

						u32 delay = 2 * getCurrentBuildDelay(this);
						SetBuildDelay(this, delay);
						bc.blobActive = false;
					}
					else if (snap && this.isKeyJustPressed(key_action1))
					{
						this.getSprite().PlaySound("NoAmmo.ogg", 0.5);
					}
				}
			
				if (this.isKeyJustPressed(key_action3))
				{
					CBitStream params;
					params.write_u16((this.get_u16("build_angle") + 90) % 360);
					this.set_u16("build_angle", ((this.get_u16("build_angle") + 90) % 360));
					this.SendCommand(this.getCommandID("rotateBlob"), params);
				}
			}
		}
	}

	////////////////////////////////////////////////////
	////////////////////////////////////////////////////
	////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////
	// EPIC DIRTY HACK: we set separate, correct conditions for placing seed
	else if (carryBlob !is null && carryBlob.getConfig() == "seed")
	{
		u8 blockIndex = this.get_u8("buildblob");
		BuildBlock @block = getBlockByIndex(this, blockIndex);
		if (block !is null && block.name == carryBlob.getName()) {
			bc.hasReqs = hasRequirements(this.getInventory(), block.reqs, bc.missing, not block.buildOnGround);
		}

		if (carryBlob !is null)
		{
			CMap@ map = this.getMap();
			bool snap = carryBlob.isSnapToGrid();

			carryBlob.SetVisible(!carryBlob.hasTag("temp blob"));

			bool isLadder = false;
			if (carryBlob.getName() == "ladder")
			{
				isLadder = true;
			}

			if (snap) // activate help line
			{
				bc.blobActive = true;
				bc.blockActive = false;
			}

			if (bc.cursorClose)
			{
				if (snap) // if snaps to grid make cursor
				{
					Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);

					CMap@ map = this.getMap();
					TileType buildtile = 256;   // something else than a tile
					Vec2f bottomPos = getBottomOfCursor(bc.tileAimPos, carryBlob);

					bool overlapped;

					if (isLadder)
					{
						Vec2f ontilepos = halftileoffset + bc.tileAimPos;

						overlapped = false;
						CBlob@[] b;

						f32 tsqr = halftileoffset.LengthSquared() - 1.0f;

						if (map.getBlobsInRadius(ontilepos, 0.5f, @b))
						{
							for (uint nearblob_step = 0; nearblob_step < b.length && !overlapped; ++nearblob_step)
							{
								CBlob@ blob = b[nearblob_step];

								string bname = blob.getName();
								if (blob is carryBlob || blob.hasTag("player") || !isBlocking(blob) || !blob.getShape().isStatic())
								{
									continue;
								}

								overlapped = (blob.getPosition() - ontilepos).LengthSquared() < tsqr;
							}
						}
					}
					else
					{
						overlapped = carryBlob.isOverlappedAtPosition(bottomPos, carryBlob.getAngleDegrees());
					}

					bc.buildableAtPos = isBuildableAtPos(this, bottomPos, buildtile, carryBlob, bc.sameTileOnBack) && !overlapped;
					bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
					bc.buildable = bc.buildableAtPos && !bc.rayBlocked;
					bc.supported = carryBlob.getShape().getConsts().support > 0 ? map.hasSupportAtPos(bc.tileAimPos) : true;
					//printf("bc.buildableAtPos " + bc.buildableAtPos + " bc.supported " + bc.supported );
				}
			}

			// place blob with action1 key
			if (!getHUD().hasButtons() && !carryBlob.hasTag("custom drop"))
			{
				if (this.isKeyPressed(key_action1))
				{
					if (snap && bc.cursorClose && bc.hasReqs && bc.buildable && bc.supported)
					{
						CMap@ map = getMap();

						CBlob@ currentBlobAtPos = null;

						CBlob@[] blobsAtPos;
						map.getBlobsAtPosition(getBottomOfCursor(bc.tileAimPos, carryBlob), blobsAtPos);

						for (int i = 0; i < blobsAtPos.size(); i++)
						{
							CBlob@ blobAtPos = blobsAtPos[i];

							if (isRepairable(blobAtPos))
							{
								@currentBlobAtPos = getBlobByNetworkID(blobAtPos.getNetworkID());
							}
						}

						CBitStream params;
						params.write_u16(carryBlob.getNetworkID());
						params.write_Vec2f(getBottomOfCursor(bc.tileAimPos, carryBlob));

						if (currentBlobAtPos !is null && carryBlob.getName() == currentBlobAtPos.getName() && currentBlobAtPos.getHealth() < currentBlobAtPos.getInitialHealth() && 	currentBlobAtPos.getName() != "ladder")
						{
							params.write_u16(currentBlobAtPos.getNetworkID());
							this.SendCommand(this.getCommandID("repairBlob"), params);
						}
						else
						{
								this.SendCommand(this.getCommandID("placeSeed"), params);
						}

						u32 delay = 2 * getCurrentBuildDelay(this);
						SetBuildDelay(this, delay);
						bc.blobActive = false;
					}
					else if (snap && this.isKeyJustPressed(key_action1))
					{
						this.getSprite().PlaySound("NoAmmo.ogg", 0.5);
					}
				}
			}
		}
	}
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
}

void onInit(CSprite@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags |= Script::tick_hasattached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

string NewBlockIcons = "NewBlockIcons.png";

const string cursorTexture = "TileCursor_caps.png";

void DrawCursorAt(Vec2f position, string& in filename, bool draw_red=false)
{
	SColor dc = color_white;
	if (draw_red) dc = SColor(255, 255, 0, 0);
	
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, 0, Vec2f(16, 16), position, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), dc);
}

// render block placement
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	/*if (getHUD().hasButtons())
	{
		return;
	}*/
	if ((blob.isKeyPressed(key_action2) || blob.isKeyPressed(key_pickup)) && blob.getName() == "builder")   //hack: dont show when builder is attacking
	{
		return;
	}
	if (isBuildDelayed(blob))
	{
		return;
	}
	
	// draw a map block or other blob that snaps to grid
	CBlob@ carryBlob = blob.getCarriedBlob();

	u8 bunnie_tile = blob.get_u8("bunnie_tile");

	bool custom_draw = false;

	bool enable_this = true;

	if (enable_this && (bunnie_tile == 2 || bunnie_tile == 5 || bunnie_tile == 6 || bunnie_tile == 7 || bunnie_tile == 8 || bunnie_tile == 10))
	{
		custom_draw = true;
		CCamera@ camera = getCamera();
		f32 zoom = camera.targetDistance;

		BlockCursor @bc;
		blob.get("blockCursor", @bc);

		CMap@ map = getMap();
			
		if (bc !is null)
		{
			if (!bc.hasReqs)
			{
				getHUD().SetCursorFrame(1);
			}
			else
			{
				getHUD().SetCursorFrame(0);
			}

			/*if (bc.cursorClose && bc.hasReqs && bc.buildable_alt)
			{
				SColor color;
				Vec2f aimpos = bc.tileAimPos;
					
				color.set(255, 255, 255, 255);
				map.DrawTile(aimpos, buildtile, color, getCamera().targetDistance, false);
				DrawCursorAt(aimpos, cursorTexture, (!bc.buildable || !bc.supported));
			}
			else
			{
				f32 halfTile = map.tilesize / 2.0f;
				Vec2f aimpos = blob.getAimPos() + getCamera().getInterpolationOffset();
				Vec2f offset(-0.2f + 0.4f * (Maths::Sin(getGameTime() * 0.5f)), 0.0f);
				map.DrawTile(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) + offset, buildtile,
							 SColor(255, 255, 46, 50),
							 getCamera().targetDistance, false);
			}*/

			SColor color;

			u8 frame = 0;
			Vec2f dimensions = Vec2f(8, 8);

			Vec2f ladder_offset = Vec2f(0, 0);

			if (bunnie_tile == 2)
			{
				dimensions = Vec2f(10, 8);
				frame = 5;
				ladder_offset = Vec2f(-0.5 * getDriver().getResolutionScaleFactor(), 0);
			}
			else if (bunnie_tile == 5)
			{
				frame = 0;
			}
			else if (bunnie_tile == 6)
			{
				frame = 1;
			}
			else if (bunnie_tile == 7)
			{
				if (blob.get_u16("build_angle") == 0 || blob.get_u16("build_angle") == 180)
				{
					dimensions = Vec2f(10, 24);
					frame = 4;
					ladder_offset = Vec2f(-0.5 * getDriver().getResolutionScaleFactor(), -4 * getDriver().getResolutionScaleFactor());
				}
				else 
				{
					dimensions = Vec2f(24, 10);
					frame = 10;
					ladder_offset = Vec2f(-4 * getDriver().getResolutionScaleFactor(), -0.5 * getDriver().getResolutionScaleFactor()); 
				}
			}
			else if (bunnie_tile == 8)
			{
				frame = 2 + (blob.get_u16("build_angle") / 90) * 9;
			}
			else if (bunnie_tile == 10)
			{
				frame = 3;
			}

			if (bc.cursorClose && bc.hasReqs)
			{
				if (getRules().get_string("build_mode") == "lagfriendly")
				{
					if (bc.buildable_alt)
					{
						color.set(255, 255, 255, 255);
						Vec2f drawpos = getDriver().getScreenPosFromWorldPos(bc.tileAimPos + ladder_offset);
						//carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						GUI::DrawIcon(NewBlockIcons, frame, dimensions, drawpos, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), blob.getTeamNum());
						DrawCursorAt(bc.tileAimPos, cursorTexture, (!bc.buildable || !bc.supported));
					}
					else
					{
						color.set(255, 255, 46, 50);
						Vec2f offset(0.0f, -1.0f + 1.0f * ((getGameTime() * 0.8f) % 8));
						Vec2f drawpos = getDriver().getScreenPosFromWorldPos(bc.tileAimPos + ladder_offset + offset);
						//carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) + offset - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						GUI::DrawIcon(NewBlockIcons, frame, dimensions, drawpos, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), color);
					}
				}
				else
				{

					if (bc.buildable && bc.supported)
					{
						color.set(255, 255, 255, 255);
						Vec2f drawpos = getDriver().getScreenPosFromWorldPos(bc.tileAimPos + ladder_offset);
						//carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						GUI::DrawIcon(NewBlockIcons, frame, dimensions, drawpos, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), blob.getTeamNum());
					}
					else
					{
						color.set(255, 255, 46, 50);
						Vec2f offset(0.0f, -1.0f + 1.0f * ((getGameTime() * 0.8f) % 8));
						Vec2f drawpos = getDriver().getScreenPosFromWorldPos(bc.tileAimPos + ladder_offset + offset);
						//carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) + offset - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						GUI::DrawIcon(NewBlockIcons, frame, dimensions, drawpos, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), color);
					}
				}
			}
			else if (bc.hasReqs)
			{
				Vec2f aimpos = blob.getMovement().getVars().aimpos;
				{
					f32 halfTile = getMap().tilesize / 2.0f;
					Vec2f aimpos = blob.getMovement().getVars().aimpos;
					Vec2f drawpos = getDriver().getScreenPosFromWorldPos(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) + ladder_offset);

					/*carryBlob.RenderForHUD(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) - carryBlob.getPosition(), 0.0f,
										   SColor(255, 255, 46, 50) ,
										   RenderStyle::normal);*/

					GUI::DrawIcon(NewBlockIcons, frame, dimensions, drawpos, getCamera().targetDistance * getDriver().getResolutionScaleFactor(), SColor(255, 255, 46, 50));
				}
			}
		}
	}
	else if (carryBlob !is null && !custom_draw) // && carryBlob.isSnapToGrid()
	{
		CCamera@ camera = getCamera();
		f32 zoom = camera.targetDistance;

		if (!carryBlob.isSnapToGrid())
		{
			return;
		}
		
		BlockCursor @bc;
		blob.get("blockCursor", @bc);
		
		if (bc !is null)
		{
			if (bc.cursorClose)// && bc.hasReqs && bc.buildable)
			{
				SColor color;

				if (true)
				{
					if (getRules().get_string("build_mode") == "lagfriendly")
					{
						if (bc.buildable_alt)
						{
							color.set(255, 255, 255, 255);
							carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
							DrawCursorAt(bc.tileAimPos, cursorTexture, (!bc.buildable || !bc.supported));
						}
						else
						{
							color.set(255, 255, 46, 50);
							Vec2f offset(0.0f, -1.0f + 1.0f * ((getGameTime() * 0.8f) % 8));
							carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) + offset - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						}
					}
					else
					{
						if (bc.buildable && bc.supported)
						{
							color.set(255, 255, 255, 255);
							carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						}
						else
						{
							color.set(255, 255, 46, 50);
							Vec2f offset(0.0f, -1.0f + 1.0f * ((getGameTime() * 0.8f) % 8));
							carryBlob.RenderForHUD(getBottomOfCursor(bc.tileAimPos, carryBlob) + offset - carryBlob.getPosition(), 0.0f, color, RenderStyle::normal);
						}
					}
				}
			}
			else //if (blob.isKeyPressed(key_use))
			{
				Vec2f aimpos = blob.getMovement().getVars().aimpos;
				if (true)
				{
					f32 halfTile = getMap().tilesize / 2.0f;
					Vec2f aimpos = blob.getMovement().getVars().aimpos;
					carryBlob.RenderForHUD(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) - carryBlob.getPosition(), 0.0f,
										   SColor(255, 255, 46, 50) ,
										   RenderStyle::normal);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!isServer()) return;

	if (cmd == this.getCommandID("rotateBlob") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;

		u16 angle;
		if (!params.saferead_u16(angle)) return;

		this.set_u16("build_angle", angle);
		return;
	}
	else if (cmd == this.getCommandID("placeBlob"))
	{
		string name;
		if (!params.saferead_string(name)) return;

		Vec2f pos;
		if (!params.saferead_Vec2f(pos)) return;

		u8 index;
		if (!params.saferead_u8(index)) return;

		CBlob @carryBlob = server_CreateBlob(name, this.getTeamNum(), pos);

		BuildBlock @block = getBlockByIndex(this, index);
			
		if (carryBlob !is null)
		{
			if (carryBlob.getName() == "wooden_platform" || carryBlob.getName() == "ladder")
				carryBlob.setAngleDegrees(this.get_u16("build_angle"));

			if (!serverBlobCheck(this, carryBlob, pos))
			{
				carryBlob.server_Die();
				return;
			}

			if (PlaceBlob(this, carryBlob, pos, true))
			{
				server_TakeRequirements(this.getInventory(), block.reqs);
				CPlayer@ p = this.getPlayer();
				if (p !is null)
				{
					GE_BuildBlob(p.getNetworkID(), carryBlob.getName()); // gameplay event for coins
				}
			}
		}
	}

	/////////////////////////////////////////////////////////////////
	// EPIC DIRTY HACK: use semi-vanilla code to place seed correctly
	else if (cmd == this.getCommandID("placeSeed"))
	{
		CBlob @carryBlob = getBlobByNetworkID(params.read_u16());
		if (carryBlob !is null)
		{
			Vec2f pos = params.read_Vec2f();

			if (PlaceBlob(this, carryBlob, pos))
			{
				CPlayer@ p = this.getPlayer();
				if (p !is null)
				{
					GE_BuildBlob(p.getNetworkID(), carryBlob.getName()); // gameplay event for coins
				}
			}
		}
	}
	/////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////

	else if (cmd == this.getCommandID("repairBlob"))
	{
		string name;
		if (!params.saferead_string(name)) return;

		Vec2f pos;
		if (!params.saferead_Vec2f(pos)) return;

		u8 index;
		if (!params.saferead_u8(index)) return;

		u16 repair_id;
		if (!params.saferead_u16(repair_id)) return;

		CBlob @repairBlob = getBlobByNetworkID(repair_id);
		if (repairBlob is null) return;

		// the getHealth() is here because apparently a blob isn't null for a tick (?) after being destroyed
		bool repairing = (repairBlob !is null && repairBlob.getHealth() > 0);

		CBlob @carryBlob = server_CreateBlob(name, this.getTeamNum(), pos);

		BuildBlock @block = getBlockByIndex(this, index);

		if (repairing) // is there a blobtile here?
		{
			if (PlaceBlob(this, carryBlob, pos, true, repairBlob))
			{
				server_TakeRequirements(this.getInventory(), block.reqs);
				CPlayer@ p = this.getPlayer();
				if (p !is null)
				{
					GE_BuildBlob(p.getNetworkID(), carryBlob.getName()); // gameplay event for coins
				}
			}
		}
		else // there's nothing here so we can place a new one
		{
			if (PlaceBlob(this, carryBlob, pos))
			{
				server_TakeRequirements(this.getInventory(), block.reqs);
				CPlayer@ p = this.getPlayer();
				if (p !is null)
				{
					GE_BuildBlob(p.getNetworkID(), carryBlob.getName()); // gameplay event for coins
				}
			}
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	// set visible in case of detachment and was invisible for HUD
	detached.SetVisible(true);

	if (detached.hasTag("temp blob placed"))  // wont happen on client
	{
		// override ignore collision so we can step on our ladder
		this.IgnoreCollisionWhileOverlapped(null);
		detached.IgnoreCollisionWhileOverlapped(null);
		detached.Untag("temp blob placed");
	}
}
