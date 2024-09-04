// Builder logic

#include "BuilderCommon.as";
#include "PlacementCommon.as";
#include "Help.as";
#include "CommonBuilderBlocks.as";
#include "KnockedCommon.as";
#include "BindingsCommon.as"

namespace Builder
{
	enum Page
	{
		PAGE_ZERO = 0,
		PAGE_ONE,
		PAGE_TWO,
		PAGE_THREE,
		PAGE_COUNT
	};
}

const string[] PAGE_NAME =
{
	"Building",
	"Component",
	"Source",
	"Device"
};

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

const Vec2f MENU_SIZE(3, 4);
const u32 SHOW_NO_BUILD_TIME = 90;

void onInit(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (!blob.exists(blocks_property))
	{
		BuildBlock[][] blocks;
		addCommonBuilderBlocks(blocks, blob.getTeamNum());
		blob.set(blocks_property, blocks);
	}

	if (!blob.exists(inventory_offset))
	{
		blob.set_Vec2f(inventory_offset, Vec2f(0, 174));
	}

	AddIconToken("$BUILDER_CLEAR$", "BuilderIcons.png", Vec2f(32, 32), 2);

	for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
	{
		AddIconToken("$"+PAGE_NAME[i]+"$", "BuilderPageIcons.png", Vec2f(48, 24), i);
	}

	blob.addCommandID("make block");
	blob.addCommandID("make block client");
	blob.addCommandID("tool clear");
	blob.addCommandID("tool clear client");
	blob.addCommandID("page select");
	blob.addCommandID("page select client");

	blob.set_Vec2f("backpack position", Vec2f_zero);

	blob.set_u8("build page", 0);

	blob.set_u8("buildblob", 255);
	blob.set_TileType("buildtile", 0);

	blob.set_u32("cant build time", 0);
	blob.set_u32("show build time", 0);

	this.getCurrentScript().removeIfTag = "dead";
}

void MakeBlocksMenu(CInventory@ this, const Vec2f &in INVENTORY_CE)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	BuildBlock[][]@ blocks;
	blob.get(blocks_property, @blocks);
	if (blocks is null) return;

	const Vec2f MENU_CE = Vec2f(0, MENU_SIZE.y * -GRID_SIZE - GRID_PADDING) + INVENTORY_CE;

	CGridMenu@ menu = CreateGridMenu(MENU_CE, blob, MENU_SIZE, getTranslatedString("Build"));
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		const u8 PAGE = blob.get_u8("build page");

		for(u8 i = 0; i < blocks[PAGE].length; i++)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if (b is null) continue;
			string block_desc = getTranslatedString(b.description);
			CBitStream params;
			params.write_u8(i);
			CGridButton@ button = menu.AddButton(b.icon, "\n" + block_desc, blob.getCommandID("make block"), params);
			if (button is null) continue;

			button.selectOneOnClick = true;

			CBitStream missing;
			if (hasRequirements(this, b.reqs, missing, not b.buildOnGround))
			{
				button.hoverText = block_desc + "\n" + getButtonRequirementsText(b.reqs, false);
			}
			else
			{
				button.hoverText = block_desc + "\n" + getButtonRequirementsText(missing, true);
				button.SetEnabled(false);
			}

			u8 bunnie_tile = blob.get_u8("bunnie_tile");

			CBlob@ carryBlob = blob.getCarriedBlob();
			if (carryBlob !is null && carryBlob.getName() == b.name)
			{
				button.SetSelected(1);
			}
			else if (b.tile == blob.get_TileType("buildtile") && b.tile != 0)
			{
				button.SetSelected(1);
			}
			else if (bunnie_tile == i)
			{
				button.SetSelected(1);
			}
		}

		const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;

		CGridMenu@ tool = CreateGridMenu(TOOL_POS, blob, Vec2f(1, 1), "");
		if (tool !is null)
		{
			tool.SetCaptionEnabled(false);

			CGridButton@ clear = tool.AddButton("$BUILDER_CLEAR$", "", blob.getCommandID("tool clear"), Vec2f(1, 1));
			if (clear !is null)
			{
				clear.SetHoverText(getTranslatedString("Stop building\n"));
			}
		}

		// index menu only available in sandbox
		if (getRules().gamemode_name != "Sandbox") return;

		const Vec2f INDEX_POS = Vec2f(menu.getLowerRightPosition().x + GRID_PADDING + GRID_SIZE, menu.getUpperLeftPosition().y + GRID_SIZE * Builder::PAGE_COUNT / 2);

		CGridMenu@ index = CreateGridMenu(INDEX_POS, blob, Vec2f(2, Builder::PAGE_COUNT), "Type");
		if (index !is null)
		{
			index.deleteAfterClick = false;


			for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
			{
				CBitStream params;
				params.write_u8(i);
				CGridButton@ button = index.AddButton("$"+PAGE_NAME[i]+"$", PAGE_NAME[i], blob.getCommandID("page select"), Vec2f(2, 1), params);
				if (button is null) continue;

				button.selectOneOnClick = true;

				if (i == PAGE)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const Vec2f INVENTORY_CE = this.getInventorySlots() * GRID_SIZE / 2 + menu.getUpperLeftPosition();
	blob.set_Vec2f("backpack position", INVENTORY_CE);

	blob.ClearGridMenusExceptInventory();

	MakeBlocksMenu(this, INVENTORY_CE);
}

void onCommand(CInventory@ this, u8 cmd, CBitStream@ params)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (cmd == blob.getCommandID("make block") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null || callerb !is blob) return;

		BuildBlock[][]@ blocks;
		if (!blob.get(blocks_property, @blocks)) return;

		u8 i;
		if (!params.saferead_u8(i)) return; 

		const u8 PAGE = blob.get_u8("build page");
		if (blocks !is null && i < blocks[PAGE].length)
		{
			BuildBlock@ block = @blocks[PAGE][i];
			bool canBuildBlock = canBuild(blob, @blocks[PAGE], i) && !isKnocked(blob);
			if (!canBuildBlock) return;

			CBlob@ carryBlob = blob.getCarriedBlob();
			if (carryBlob !is null)
			{
				if (carryBlob.getName() == block.name) return;

				if (carryBlob.hasTag("temp blob"))
				{
					carryBlob.Untag("temp blob");
					carryBlob.server_Die();
				}
				else
				{
					// try put into inventory whatever was in hands
					// creates infinite mats duplicating if used on build block, not great :/
					if (!block.buildOnGround && !blob.server_PutInInventory(carryBlob))
					{
						carryBlob.server_DetachFromAll();
					}
				}
			}

			blob.set_Vec2f("building space", Vec2f_zero);
			blob.set_u8("buildblob", 0);

			if (block.tile == 0)
			{
				server_BuildBlob(blob, @blocks[PAGE], i);
			}

			blob.set_TileType("buildtile", block.tile);

			CBitStream stream;
			stream.write_TileType(block.tile);
			stream.write_bool(block.buildOnGround);
			stream.write_u32(blob.get_u32("cant build time"));
			stream.write_u8(blob.get_u8("buildblob"));
			stream.write_Vec2f(blob.get_Vec2f("building space"));
			blob.SendCommand(blob.getCommandID("make block client"), stream);
		}
	}
	else if (cmd == blob.getCommandID("make block client") && isClient())
	{
		const TileType buildtile = params.read_TileType();
		const bool buildonground = params.read_bool();
		const u32 buildtime = params.read_u32();
		const u8 buildblob = params.read_u8();
		const Vec2f buildspace = params.read_Vec2f();

		blob.set_TileType("buildtile", buildtile);
		blob.set_u32("cant build time", buildtime);
		blob.set_u8("buildblob", buildblob);
		blob.set_Vec2f("building space", buildspace);

		if (buildonground)
		{
			if (buildblob > 0)
			{
				blob.getSprite().PlaySound("/Construct");
			}
			else if (blob.isMyPlayer())
			{
				blob.getSprite().PlaySound("/NoAmmo", 0.5f);
			}
		}

		if (blob.isMyPlayer())
		{
			SetHelp(blob, "help self action", "builder", getTranslatedString("$Build$Build/Place  $LMB$"), "", 3);
		}
	}
	else if (cmd == blob.getCommandID("tool clear") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null) return;
		if (callerb !is blob) return;

		ClearCarriedBlock(blob);

		blob.set_u8("bunnie_tile", 255);

		blob.server_SendCommandToPlayer(blob.getCommandID("tool clear client"), callerp);
	}
	else if (cmd == blob.getCommandID("tool clear client") && isClient())
	{
		blob.ClearGridMenus();

		blob.set_u8("bunnie_tile", 255);

		ClearCarriedBlock(blob);
	}
	else if (cmd == blob.getCommandID("page select") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null) return;
		if (callerb !is blob) return;

		u8 page;
		if (!params.saferead_u8(page)) return;

		blob.set_u8("build page", page);

		ClearCarriedBlock(blob);

		CBitStream sparams;
		sparams.write_u8(page);
		blob.server_SendCommandToPlayer(blob.getCommandID("page select client"), sparams, callerp);
	}
	else if (cmd == blob.getCommandID("page select client") && isClient())
	{
		u8 page;
		if (!params.saferead_u8(page)) return;

		blob.ClearGridMenus();
		blob.set_u8("build page", page);

		ClearCarriedBlock(blob);

		if (blob is getLocalPlayerBlob())
		{
			blob.CreateInventoryMenu(blob.get_Vec2f("backpack position"));
		}
	}
}

u8[] blockBinds = {
	0, 1, 2, 3, 4, 5, 6, 7, 8
};

void onInit(CBlob@ this)
{
	ConfigFile@ cfg = openBlockBindingsConfig();

	for (uint i = 0; i < 9; i++)
	{
		blockBinds[i] = read_block(cfg, "block_" + (i + 1), blockBinds[i]);
	}

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (isServer())
	{
		if (attached.getName() == "wooden_platform" ||
			attached.getName() == "wooden_door" ||
			attached.getName() == "stone_door" ||
			attached.getName() == "ladder" ||
			attached.getName() == "spikes" ||
			attached.getName() == "bridge")
		{
			return;
		}

		this.set_u8("bunnie_tile", 250);
		this.Sync("bunnie_tile", true);
		this.set_u8("bunnie_tile", 255);
		this.Sync("bunnie_tile", true);
	}
}


void onTick(CBlob@ this)
{
	if (this !is getLocalPlayerBlob())
	{
		return;
	}

	if (this.hasTag("reload blocks"))
	{
		this.Untag("reload blocks");
		onInit(this);
	}
	
	CControls@ controls = getControls();

	CGridMenu@ bmenu = getGridMenuByName(getTranslatedString("Build"));

	//printf("hello1 " + controls.isKeyJustPressed(KEY_LBUTTON) + ", gt " + getGameTime());

	// FOR SOME REASON, THIS HAS TO BE HERE IN ORDER FOR THE FOLLOWING CODE TO WORK. NEVER REMOVE THIS!!!
	// FOR SOME REASON, THIS HAS TO BE HERE IN ORDER FOR THE FOLLOWING CODE TO WORK. NEVER REMOVE THIS!!!
	// FOR SOME REASON, THIS HAS TO BE HERE IN ORDER FOR THE FOLLOWING CODE TO WORK. NEVER REMOVE THIS!!!
	bool weird = controls.isKeyJustPressed(KEY_LBUTTON);

	if (bmenu !is null)
	{
		Vec2f cursorPos = controls.getMouseScreenPos();

		getRules().set_Vec2f("blockmenu_cursor_pos", cursorPos);
		getRules().add_u16("blockmenu_open_ticks", 1);

		if (controls.isKeyJustPressed(KEY_LBUTTON))
		{
			getRules().set_Vec2f("blockmenu_cursor_pos", cursorPos);
			Vec2f menu_tl = getRules().get_Vec2f("opened_block_menu");
			Vec2f cursorPos = getRules().get_Vec2f("blockmenu_cursor_pos");
			Vec2f offset = cursorPos - menu_tl;

			u8 meme_index = 0;

			if (offset.x > 0 && offset.y > 0 && offset.x <= 142 && offset.y <= 192)
			{
				meme_index += u8(offset.x / 48);

				meme_index += u8(offset.y / 48) * 3;

				CBitStream params;
				params.write_u8(meme_index);

				if (meme_index != 9)
				{
					this.SendCommand(this.getCommandID("make block"), params);
				}


				this.set_u8("bunnie_tile", meme_index);

				BuildBlock[][]@ blocks;
				if (!this.get(blocks_property, @blocks)) return;
					
				const u8 PAGE = this.get_u8("build page");
				if (blocks !is null && meme_index >= 0 && meme_index < blocks[PAGE].length)
				{
					BuildBlock@ block = @blocks[PAGE][meme_index];
					bool canBuildBlock = canBuild(this, @blocks[PAGE], meme_index) && !isKnocked(this);
					if (!canBuildBlock)
					{
						this.getSprite().PlaySound("/NoAmmo", 1.2);
					}

					this.set_TileType("buildtile", block.tile);
				}
			}

			getRules().set_bool("blockmenu_clicked", true);
		}
	}
	//printf("ticks " + getRules().get_u16("blockmenu_open_ticks"));

	if (bmenu is null && !getRules().get_bool("menu_just_closed") && getRules().get_Vec2f("opened_block_menu") != Vec2f_zero && controls !is null && getRules().get_u16("blockmenu_open_ticks") > 1 && !getRules().get_bool("blockmenu_clicked"))
	{
		getRules().set_bool("menu_just_closed", true);
		Vec2f menu_tl = getRules().get_Vec2f("opened_block_menu");
		Vec2f cursorPos = getRules().get_Vec2f("blockmenu_cursor_pos");

		Vec2f offset = cursorPos - menu_tl;

		u8 meme_index = 0;

		//printf("test: " + getRules().get_u16("blockmenu_open_ticks"));

		if (offset.x >= 70 && offset.x <= 74 && offset.y >= 138 && offset.y <= 142 && getRules().get_u16("blockmenu_open_ticks") < 4)
		{
			getRules().set_u16("blockmenu_open_ticks", 0);
			CBitStream params;
			this.SendCommand(this.getCommandID("tool clear"), params);
		}
		else if (offset.x > 0 && offset.y > 0 && offset.x <= 142 && offset.y <= 192)
		{
			getRules().set_u16("blockmenu_open_ticks", 0);
			meme_index += u8(offset.x / 48);

			meme_index += u8(offset.y / 48) * 3;

			CBitStream params;
			params.write_u8(meme_index);

			//printf("Here? " + offset);
			if (meme_index != 9)
			{
				this.SendCommand(this.getCommandID("make block"), params);
			}

			this.set_u8("bunnie_tile", meme_index);

			BuildBlock[][]@ blocks;
			if (!this.get(blocks_property, @blocks)) return;
				
			const u8 PAGE = this.get_u8("build page");
			if (blocks !is null && meme_index >= 0 && meme_index < blocks[PAGE].length)
			{
				BuildBlock@ block = @blocks[PAGE][meme_index];
				bool canBuildBlock = canBuild(this, @blocks[PAGE], meme_index) && !isKnocked(this);
				if (!canBuildBlock)
				{
					this.getSprite().PlaySound("/NoAmmo", 1.2);
				}

				this.set_TileType("buildtile", block.tile);
			}
		}
	}

	if (bmenu is null)
	{
		getRules().set_u16("blockmenu_open_ticks", 0);
	}

	CRules@ rules = getRules();

	uint[] actual_i =
	{
		2, 5, 6, 7, 8, 9, 10, 0, 1, 3, 4
	};

	if (getHUD().hasButtons() == false || getLocalPlayer().getUsername() == "Fobri")
	{
		for (uint i = 0; i < 11; i++)
		{
			if (b_KeyJustPressed(button_file_names[1][actual_i[i]]))
			{
				CBitStream params;
				params.write_u8(actual_i[i]);

				this.SendCommand(this.getCommandID("make block"), params);

				this.set_u8("bunnie_tile", actual_i[i]);

				BuildBlock[][]@ blocks;
				if (!this.get(blocks_property, @blocks)) return;
				
				const u8 PAGE = this.get_u8("build page");
				if (blocks !is null && i >= 0 && i < blocks[PAGE].length)
				{
					BuildBlock@ block = @blocks[PAGE][actual_i[i]];
					bool canBuildBlock = canBuild(this, @blocks[PAGE], actual_i[i]) && !isKnocked(this);
					if (!canBuildBlock)
					{
						this.getSprite().PlaySound("/NoAmmo", 1.2);
					}

					this.set_TileType("buildtile", block.tile);
				}
			}
		}
	}
}

void onRender(CSprite@ this)
{
	CMap@ map = getMap();

	CBlob@ blob = this.getBlob();
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob is blob)
	{
		// no build zone show
		const bool onground = blob.isOnGround();
		const u32 time = blob.get_u32( "cant build time" );
		if (time + SHOW_NO_BUILD_TIME > getGameTime())
		{
			Vec2f space = blob.get_Vec2f( "building space" );
			Vec2f offsetPos = getBuildingOffsetPos(blob, map, space);

			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			Vec2f aligned = getDriver().getScreenPosFromWorldPos( offsetPos );

			for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
			{
				for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
				{
					Vec2f temp = ( Vec2f( step_x + 0.5, step_y + 0.5 ) * map.tilesize );
					Vec2f v = offsetPos + temp;
					Vec2f pos = aligned + (temp - Vec2f(0.5f,0.5f)* map.tilesize) * 2 * zoom;
					if (!onground || map.getSectorAtPosition(v , "no build") !is null || map.isTileSolid(v) || blobBlockingBuilding(map, v))
					{
						// draw red
						GUI::DrawIcon( "CrateSlots.png", 5, Vec2f(8,8), pos, zoom );
					}
					else
					{
						// draw white
						GUI::DrawIcon( "CrateSlots.png", 9, Vec2f(8,8), pos, zoom );
					}
				}
			}
		}

		// show cant build
		if (blob.isKeyPressed(key_action1) || blob.get_u32("show build time") + 15 > getGameTime())
		{
			if (blob.isKeyPressed(key_action1))
			{
				blob.set_u32( "show build time", getGameTime());
			}

			Vec2f cam_offset = getCamera().getInterpolationOffset();

			BlockCursor @bc;
			blob.get("blockCursor", @bc);
			if (bc !is null)
			{
				if (bc.blockActive || bc.blobActive)
				{
					Vec2f pos = blob.getPosition();
					Vec2f myPos =  blob.getInterpolatedScreenPos() + Vec2f(0.0f,(pos.y > blob.getAimPos().y) ? -blob.getRadius() : blob.getRadius());
					Vec2f aimPos2D = getDriver().getScreenPosFromWorldPos( blob.getAimPos() + cam_offset );

					if (!bc.hasReqs)
					{
						const string missingText = getButtonRequirementsText( bc.missing, true );
						Vec2f boxpos( myPos.x, myPos.y - 120.0f );
						GUI::DrawText( getTranslatedString("Requires\n") + missingText, Vec2f(boxpos.x - 50, boxpos.y - 15.0f), Vec2f(boxpos.x + 50, boxpos.y + 15.0f), color_black, false, false, true );
					}
					else if (bc.cursorClose)
					{
						if (bc.rayBlocked)
						{
							Vec2f blockedPos2D = getDriver().getScreenPosFromWorldPos(bc.rayBlockedPos + cam_offset);
							GUI::DrawArrow2D( aimPos2D, blockedPos2D, SColor(0xffdd2212) );
						}

						if (!bc.buildableAtPos && !bc.sameTileOnBack) //no build indicator drawing
						{
							CMap@ map = getMap();
							Vec2f middle = blob.getAimPos() + Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);
							CMap::Sector@ sector = map.getSectorAtPosition( middle, "no build");
							if (sector !is null)
							{
								GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(sector.upperleft), getDriver().getScreenPosFromWorldPos(sector.lowerright), SColor(0x65ed1202) );
							}
							else
							{
								CBlob@[] blobsInRadius;
								if (map.getBlobsInRadius( middle, map.tilesize, @blobsInRadius ))
								{
									for (uint i = 0; i < blobsInRadius.length; i++)
									{
										CBlob @b = blobsInRadius[i];
										if (!b.isAttached())
										{
											Vec2f bpos = b.getInterpolatedPosition();
											float w = b.getWidth();
											float h = b.getHeight();

											if (b.getAngleDegrees() % 180 != 0) //swap dimentions
											{
												float t = w;
												w = h;
												h = t;
											}

											GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(bpos + Vec2f(w/-2.0f, h/-2.0f)),
																getDriver().getScreenPosFromWorldPos(bpos + Vec2f(w/2.0f, h/2.0f)),
																SColor(0x65ed1202) );
										}
									}
								}
							}
						}
					}
					else if (blob.getCarriedBlob() is null || blob.getCarriedBlob().hasTag("temp blob")) // only display the red arrow while we are building
					{
						const f32 maxDist = getMaxBuildDistance(blob) + 8.0f;
						Vec2f norm = aimPos2D - myPos;
						const f32 dist = norm.Normalize();
						norm *= (maxDist - dist);
						GUI::DrawArrow2D( aimPos2D, aimPos2D + norm, SColor(0xffdd2212) );
					}
				}
			}
		}
	}
}

bool blobBlockingBuilding(CMap@ map, Vec2f v)
{
	CBlob@[] overlapping;
	map.getBlobsAtPosition(v, @overlapping);
	for(uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ o_blob = overlapping[i];
		CShape@ o_shape = o_blob.getShape();
		if (o_blob !is null &&
			o_shape !is null &&
			!o_blob.isAttached() &&
			o_shape.isStatic() &&
			!o_shape.getVars().isladder)
		{
			return true;
		}
	}
	return false;
}
