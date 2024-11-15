// TileEntity.as
#include "Hitters.as"

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
	}

	if (blob !is null && blob.getShape().isStatic()) {
		if (blob.getConfig() == "flag_base") {
			this.set_bool("collided with structure", true);
			printf("Colliding with structure");
		}
	}


	if (blob is null) return;
		
	if (this.getOldVelocity().Length()<4) return;

	this.server_Hit(blob, point1, this.getOldVelocity(), 5+this.getOldVelocity().Length(), Hitters::fall, true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
}

void onDie(CBlob@ this)
{
	if (this.get_bool("collided with structure")) {
		printf("Tile Entity despawned");
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