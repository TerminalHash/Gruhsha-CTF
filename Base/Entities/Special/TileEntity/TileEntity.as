// TileEntity.as
#include "Hitters.as"
#include "GruhshaHitters.as"
#include "KnightCommon.as";
#include "ShieldCommon.as";
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(10);
	
	this.Tag("no mortar rotations");
	this.Tag("collides_over_crouching");
}

void SetTileFrame(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	if (!this.exists("tile_frame")) return;
	int frame = this.get_s32("tile_frame");
	
	if (sprite.getFrame()==frame) return;
	
	//print("have set tile frame");
	this.set_string("custom_mortar_effect", "SmallDust");
	this.AddScript("MortarLaunched.as");
	sprite.SetFrame(this.get_s32("tile_frame"));
	sprite.SetZ(300);
}

void RotateOnFly(CBlob@ this)
{
	if (this.getVelocity().Length()<3) return;
	
	const bool FLIP = this.getVelocity().x<0;
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	f32 rotation_scale = 20;
	this.setAngleDegrees(getGameTime()%(360/rotation_scale)*rotation_scale*FLIP_FACTOR);
	
}

void CollapsingTileLogic(CBlob@ this)
{
	if (!this.hasTag("collapsing_tile")) return;
	if (this.getTickSinceCreated()>15)
	{
		StartCollapsing(this);
		return;
	}

	this.getShape().SetGravityScale(0);
}

void StartCollapsing(CBlob@ this)
{
	if (this.hasTag("started_collapsing")) return;
	this.getShape().SetGravityScale(1);
	this.setPosition(this.getPosition()+Vec2f(XORRandom(80)-40, 0)*0.03f);
	this.Tag("started_collapsing");
}

void onTick(CBlob@ this)
{
	CollapsingTileLogic(this);

	if (!this.hasTag("no_rotations"))
		RotateOnFly(this);
	
	SetTileFrame(this);
}

bool canExplosionDestroy(TileType t)
{
	return !(getMap().isTileGroundStuff(t));
}

bool canTileBePlaced(Vec2f pos)
{
	//align it
	pos = getMap().getAlignedWorldPos(pos)+Vec2f(1, 1)*4;
	//printf("tile pos "+pos);

	for (int idx = 0; idx < 4; ++idx)
	{
		Vec2f dir = Vec2f(6, 0).RotateBy(90*idx);
		
		if (getMap().isTileSolid(pos+dir) && getMap().getSectorAtPosition(pos, "no build") is null)
			return true;
	}

	return false;
}

void TryToPlaceTile(CBlob@ this)
{
	Vec2f vel_pos = this.getPosition();

	if (canTileBePlaced(vel_pos))
	{
		setDeadStatus(this);
		this.server_Die();
	}
	else
		this.server_SetTimeToDie(3);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (this.hasTag("collapsing_tile") && this.getTickSinceCreated()<15) return;

	if (solid)
	{
		f32 max_hits = this.getOldVelocity().Length();
		//
		{
			HitInfo@[] hitInfos;
			if(getMap().getHitInfosFromRay(this.getPosition(), (point2-this.getPosition()).AngleDegrees(), 12, this, hitInfos))
			{
				for (int idx = 0; idx < hitInfos.size(); ++idx)
				{
					HitInfo@ hi = hitInfos[idx];
					if (hi.blob !is null) continue;
					
					for (int hit_i = 0; hit_i < max_hits; ++hit_i)
					{
						if (canExplosionDestroy(getMap().getTile(hi.hitpos).type))
							getMap().server_DestroyTile(hi.hitpos, 1.0f, this);
					}
					break;
				}
			}
		}

		if (this.getOldVelocity().Length()<3)
		{
			if (blob is null)
				TryToPlaceTile(this);
		}
		else if (this.getOldVelocity().Length()>=0.2f)
		{
			string[] hit_sounds =
			{
				"Rubble1.ogg",
				"Rubble2.ogg"
				//"hitwall.ogg"
			};
			this.getSprite().PlaySound(hit_sounds[Maths::Round(XORRandom(hit_sounds.size()*10)/10)]);
		}
		else
		{
			this.setPosition(this.getPosition()+Vec2f(XORRandom(8)-4, 0));
		}
	}

	bool shield_hit = false;

	if (blob !is null && blob.getConfig() == "knight") {
		KnightInfo@ knight;
		if (!blob.get("knightInfo", @knight)) {
			return;
		}

		ShieldVars@ shieldVars = getShieldVars(blob);
		if (shieldVars is null) return;

		bool shieldState = isShieldState(knight.state);

		// if player is knight and his shield is upwards - spikes should ignore him
		if (blob !is null &&
			this !is null &&
			blob.getConfig() == "knight" &&
			shieldState) {

			Vec2f tileVec = this.getVelocity();
			tileVec.Normalize();
			Vec2f shieldVec = shieldVars.direction;
			shieldVec.Normalize();
			f32 dot = tileVec.x * shieldVec.x + tileVec.y * shieldVec.y;

			if (dot < -0.71) {
				Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", this.getPosition());
				sparks(this.getPosition(), shieldVec.Angle() - 45.0f + XORRandom(90), 1 + XORRandom(6));
				shield_hit = true;
			}
		}
	}

	if (blob is null) return;
		
	if (this.getOldVelocity().Length()<2) return;

	if (blob.hasTag("player") && blob.getPosition().y < this.getPosition().y && this.getVelocity().y>=0) return;

	if (!shield_hit) {
		
		//if tile entity goes faster than 2 pxls a tick, then we add 25% of it to the damage
		f32 velocity_damage = this.getOldVelocity().Length()>2?(this.getOldVelocity().Length()/4):0;
		f32 tile_damage = 2+velocity_damage;

		bool hitting_important_thing = false;

		if (!blob.hasTag("flesh"))
		{
			if (blob.hasTag("building"))
			{
				hitting_important_thing = true;
				tile_damage /= 2;
			}
			else
				tile_damage *= 3;
		}

		bool wooden = getMap().isTileWood(this.get_s32("tile_frame"));

		if (wooden) tile_damage /= 2;
		
		this.server_Hit(blob, point1, this.getOldVelocity(), tile_damage, GruhshaHitters::tile_entity, true);

		if (hitting_important_thing)
		{
			setDeadStatus(this);
			this.server_Die();
		}
	} else {
		shield_hit = false;
		//printf("Collided with shield!");
	}
}

void setDeadStatus(CBlob@ this)
{
	this.setVelocity(Vec2f());
	this.setPosition(getMap().getAlignedWorldPos(this.getPosition())+Vec2f(1, 1)*4);
}

bool shouldBePlacedOnDeath(CBlob@ this)
{
	CBlob@[] blobs_nearby;
	Vec2f pos = getMap().getAlignedWorldPos(this.getPosition())+Vec2f(1, 1)*4;

	if (getMap().getBlobsInRadius(pos, 7, @blobs_nearby)) {
		for (int idx = 0; idx < blobs_nearby.size(); ++idx) {
			CBlob@ c_blob = blobs_nearby[idx];
			if (c_blob is null) continue;

			if (!c_blob.getShape().isStatic()) continue;

			if (c_blob.getShape().getConsts().collidable) continue;

			//printf("Colliding with structure");
			return false;
		}
	}

	return true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData==Hitters::builder||customData==Hitters::drill) return damage;

	return 0;
}

void onDie(CBlob@ this)
{
	if (!shouldBePlacedOnDeath(this)) return;

	if (canTileBePlaced(this.getPosition()))
	{
		getMap().server_SetTile(this.getPosition(), this.get_s32("tile_frame"));
	}
	
	return;
	
	if (!this.exists("tile_flags")) return;
	getMap().AddTileFlag(getMap().getTileOffset(this.getPosition()), this.get_u32("tile_flags"));
}
