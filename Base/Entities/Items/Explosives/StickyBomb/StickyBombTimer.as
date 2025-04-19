#include "StickyBombCommon.as";
#include "Hitters.as";
#include "GruhshaHitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	if (!this.exists("bomb_timer"))
	{
		this.set_s32("bomb_timer", getGameTime());
	}
	f32 explRadius = 64.0f;
	if (!this.exists("explosive_radius"))
	{
		this.set_f32("explosive_radius", explRadius);
	}
	if (!this.exists("explosive_damage"))
	{
		this.set_f32("explosive_damage", 3.0f);
	}

	BombFuseOn(this, explRadius * 0.5f);

	//use the bomb hitter
	if (!this.exists("custom_hitter"))
	{
		this.set_u8("custom_hitter", GruhshaHitters::sticky_bomb);
	}
	if (!this.exists("map_damage_radius"))
	{
		this.set_f32("map_damage_radius", 0);
	}
	if (!this.exists("map_damage_ratio"))
	{
		this.set_f32("map_damage_ratio", 0);
	}
	if (!this.exists("map_damage_raycast"))
	{
		this.set_bool("map_damage_raycast", true);
	}
}

void Explode(CBlob@ this)
{
	if (this.hasTag("exploding"))
	{
		MetroBoominMakeItBoom(this);

		//if (!isServer())
			this.set_f32("map_damage_radius", 16);
		
		if (this.exists("explosive_radius") && this.exists("explosive_damage"))
		{
			Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
		}
		else //default "bomb" explosion
		{
			Explode(this, 64.0f, 3.0f);
		}
		this.Untag("exploding");
		
		//kiwiExplosionEffects(this);
	}

	BombFuseOff(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	if (this.getHealth() < 2.5f || this.hasTag("player"))
	{
		this.getSprite().Gib();
		this.server_Die();
	}
	else
	{
		this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_f32("explosive_damage") * 1.5f, 0);
	}
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}

void MetroBoominMakeItBoom(CBlob@ this)
{
	f32 velang = this.get_f32("velang");
	f32 max_hits = 8;
	int hits_made = 0;
	int blobs_hit = 0;

	bool has_destroyed_tile = false;

	//cycle for raycasts
	for (f32 idx = 0; idx < max_hits; /* we don't increment here because it's handled manually */)
	{
		//by default we do increment by 2, so the dynamite destroys 2x2 area of castle tiles
		//if it's a wooden tile which was destroyed, we increment only by 1 because wood is much less durable than stone
		//in case we hit a full wood wall it's 4x2 area that will be destroyed
		f32 raycast_increment = 2;

		has_destroyed_tile = false;
		HitInfo@[] infos;
		//sqrt of 128 is 11.31371 (diagonal of a tile in case tilesize is 8), so we need less than half of that for case when the dynamite is angled by 45 degrees
		//because two raycasts should be able to pierce through a tile
		
		//print("general, made it here, idx = " + idx + ", hits made: " + hits_made);
		
		f32 less_than_a_tile_diagonal = 3;
		Vec2f cool_offset = Vec2f(less_than_a_tile_diagonal, 0).RotateBy(velang+((hits_made%2==0)?-1:1)*90);
		Vec2f not_cool_offset = Vec2f(0, -0.5);
		
		f32 prev_idx = idx;

		if (getMap().getHitInfosFromRay(this.getPosition()+cool_offset+not_cool_offset, velang, getMap().tilesize*8, this, @infos))
		{
			//cycle for all the hits from hitinfos
			for (int jdx = 0; jdx < infos.size(); ++jdx)
			{
				if (idx >= max_hits) break;
				HitInfo@ c_info = infos[jdx];
				CBlob@ c_blob = c_info.blob;

				//we only need to hit tiles
				if (c_blob !is null)
				{
					if (c_blob.getShape().isStatic())
					{
						if (c_blob.getShape().getConsts().collidable)
						{
							if (c_blob.getConfig() != this.getConfig())
							{
								//because kag is fucking shit when you kill a blob it still gets hit by getHitInfosFromRay func if run in the same tick...
								//so we track how many blobs we hit so we can skip those later..
								if (jdx < blobs_hit/2) continue;
								if (!c_blob.hasTag("stone")) raycast_increment = 1;
								raycast_increment *= 1.5f;
								c_blob.getSprite().Gib();
								c_blob.server_Die();
								//raycast cycle incrementation here
								idx += raycast_increment;
								hits_made += 1;
								blobs_hit += 1;
								
								//print("blob, made it here, idx = " + idx);
								break;
							}
						} else continue;
					} else continue;
				}

				Vec2f tile_pos = getMap().getAlignedWorldPos(c_info.hitpos)+Vec2f(1, 1)*4;

				TileType c_type = getMap().getTile(tile_pos).type;
				
				//don't hit last dirt frame and backtile with doors
				//if (!canExplosionDamage(getMap(), tile_pos, c_type)) continue;

				//don't hit ground
				if (getMap().isTileGroundStuff(c_type)) continue;

				//don't hit gold
				if (getMap().isTileGold(c_type)) continue;
				
				//checking before doing any damage
				bool was_solid = getMap().isTileSolid(tile_pos);
				
				//if we will hit a wooden tile we lower the cycle cost for it
				if (getMap().isTileWood(c_type))
					raycast_increment = 1;

				int tile_gib_id = getMap().isTileWood(c_type)?1:(getMap().isTileCastle(c_type)?2:0);

				//cycle for destroying a tile
				//30 hits is more than enough to kill any tile in the game
				for (int ldx = 0; ldx < 30; ++ldx)
				{
					getMap().server_DestroyTile(tile_pos, 1);
					has_destroyed_tile = was_solid && !getMap().isTileSolid(tile_pos);
					
					//breaking the cycle after we completely destroyed the tile
					if (has_destroyed_tile)
					{
						Vec2f pos_sosal = tile_pos - Vec2f(1, 1)*4 + Vec2f(XORRandom(8), XORRandom(8));
						Vec2f velocity_sosal = getRandomVelocity((tile_pos - this.getPosition()).getAngle(), 1.0f + 2, 90.0f) + Vec2f(0.0f, -2.0f);
	
						makeSmallExplosionParticle(tile_pos);
						
						//cycle for gib particles
						for (int ydx = 0; ydx < 3; ++ydx)
						{
							CParticle@ p = makeGibParticle("GenericGibs", pos_sosal, velocity_sosal, tile_gib_id, XORRandom(8), Vec2f(8, 8), 2.0f, 0, "", 0);
						}
						
						break;
					}
				}
				//raycast cycle incrementation here
				idx += raycast_increment;
				hits_made += 1;
			}
		}

		//in case we hit nothing we still take the price as if we just hit wood
		if (idx == prev_idx) {
			idx += 1;
			//adding one to total hits so it changes hitpos
			hits_made += 1;
		}
	}
}

void onTick(CBlob@ this)
{
	if (!UpdateBomb(this))
	{
		Explode(this);
	}
}

void onDie(CBlob@ this)
{
	Explode(this);
}

// run the tick so we explode in inventory
void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true;
	//this.getSprite().SetEmitSoundPaused( false );
}
