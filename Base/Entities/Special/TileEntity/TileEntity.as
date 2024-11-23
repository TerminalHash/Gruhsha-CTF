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

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (this.hasTag("collapsing_tile") && this.getTickSinceCreated()<15) return;

	if (solid)
	{
		if (this.getVelocity().Length()<3)
		{
			Vec2f vel_pos = this.getPosition()-this.getOldVelocity();

			for (int idx = 0; idx < 4; ++idx)
			{
				Vec2f dir = Vec2f(8, 0).RotateBy(90*idx);
				
				if (getMap().hasSupportAtPos(this.getPosition()+dir))
				{
					this.getShape().PutOnGround();
				}
				
				this.server_SetTimeToDie(0.5f);
			}
			f32 max_hits = 2+this.getVelocity().Length()*1.5;
			for (int idx = 0; idx < max_hits; ++idx)
			{
				Vec2f tile_pos = this.getPosition()+this.getOldVelocity().Normalize()*8;
				if (getMap().isTileSolid(tile_pos)&&!getMap().isTileGroundStuff(getMap().getTile(tile_pos).type))
					getMap().server_DestroyTile(tile_pos, 1.0f, this);
			}
		}
		else if (this.getVelocity().Length()>=0.2f)
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

	CBlob@[] blobs_nearby;
	if (this.getVelocity().Length()<3)
	if (getMap().getBlobsInRadius(this.getPosition(), 6, @blobs_nearby)) {
		for (int idx = 0; idx < blobs_nearby.size(); ++idx) {
			CBlob@ c_blob = blobs_nearby[idx];
			if (c_blob is null) continue;

			if (!c_blob.getShape().isStatic()) continue;

			if (c_blob.getShape().getConsts().collidable) continue;

			this.set_bool("collided with structure", true);
			//printf("Colliding with structure");
		}
	}

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

			if(dot < -0.71) {
				Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", this.getPosition());
				this.set_bool("collided with shield", true);
			}
		}
	}

	if (blob is null) return;
		
	if (this.getOldVelocity().Length()<2) return;

	if (blob.hasTag("player") && blob.getPosition().y < this.getPosition().y && this.getVelocity().y>=0) return;

	if (!this.get_bool("collided with shield")) {
		
		f32 tile_damage = (5 + this.getOldVelocity().Length()) / 4.5f;
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
		
		this.server_Hit(blob, point1, this.getOldVelocity(), tile_damage, GruhshaHitters::tile_entity, true);
		if (hitting_important_thing)
			this.server_Die();
	} else {
		//printf("Collided with shield!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
}

void onDie(CBlob@ this)
{
	if (this.get_bool("collided with structure")) {
		//printf("Tile Entity despawned");
		return;
	}
	else
	{
		bool should_be_placed = false;

		//if (getMap().isTileSolid(this.getPosition()+Vec2f(0, 8)))
		//	should_be_placed = true;
		//
		//for (int idx = 0; idx < 16; idx += 4)
		//if (getMap().isTileBackgroundNonEmpty(getMap().getTile(this.getPosition()+Vec2f(-8+idx, 0))))
		//	should_be_placed = true;
		for (int idx = 0; idx < 4; ++idx)
		{
			Vec2f dir = Vec2f(8, 0).RotateBy(90*idx);
			if (getMap().hasSupportAtPos(this.getPosition()+dir))
				should_be_placed = true;
		}

		if (should_be_placed)
		{
			getMap().server_SetTile(this.getPosition(), this.get_s32("tile_frame"));
		}
	}
	
	return;
	
	if (!this.exists("tile_flags")) return;
	getMap().AddTileFlag(getMap().getTileOffset(this.getPosition()), this.get_u32("tile_flags"));
}
