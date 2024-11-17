// TileEntity.as
#include "Hitters.as"
#include "KnightCommon.as";
#include "ShieldCommon.as";
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(10);
	
	this.Tag("no mortar rotations");
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

void onTick(CBlob@ this)
{
	if (!this.hasTag("no_rotations"))
		RotateOnFly(this);
	
	SetTileFrame(this);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (solid)
	{
		if (this.getVelocity().Length()<3)
		{
			Vec2f vel_pos = this.getPosition()-this.getOldVelocity();
			
			if (getMap().isTileSolid(vel_pos+Vec2f(0, 8)))
			{
				this.getShape().PutOnGround();
				this.server_Die();
			}
			else
				this.server_SetTimeToDie(3);
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
			shieldState &&
			(	shieldVars.direction == Vec2f(-1, 0)  || // LEFT
				shieldVars.direction == Vec2f(1, 0)   || // RIGHT
				shieldVars.direction == Vec2f(1, -3)  || // UP RIGHT
				shieldVars.direction == Vec2f(-1, -3) || // UP LEFT
				shieldVars.direction == Vec2f(0, -1)     // UP
			)){
			Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", this.getPosition());

			this.set_bool("collided with shield", true);
		}
	}

	if (blob is null) return;
		
	if (this.getOldVelocity().Length()<2) return;

	if (!this.get_bool("collided with shield")) {
		this.server_Hit(blob, point1, this.getOldVelocity(), (5 + this.getOldVelocity().Length()) / 4.5f, Hitters::fall, true);
	} else {
		//printf("Collided with shield!");
		//this.server_Die();
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
	} else {

	//if (!this.isOnGround()) return;
	//if (getMap().getSector("no build") !is null) return;
		getMap().server_SetTile(this.getPosition(), this.get_s32("tile_frame"));
	}
	
	return;
	
	if (!this.exists("tile_flags")) return;
	getMap().AddTileFlag(getMap().getTileOffset(this.getPosition()), this.get_u32("tile_flags"));
}
