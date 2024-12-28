// Keg logic
#include "Hitters.as";
#include "ActivationThrowCommon.as"

void onInit(CBlob@ this)
{
	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_u8("custom_hitter", Hitters::keg);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 32.0f);
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", false);
	this.set_f32("keg_time", 180.0f);  // 180.0f

	this.set_u16("_keg_carrier_id", 0xffff);

	this.set_f32("important-pickup", 30.0f);
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	s32 timer = blob.get_s32("explosion_timer") - getGameTime();

	if (timer < 0)
	{
		return;
	}
}

void onTick(CBlob@ this)
{
	if (this.isInFlames() && !this.hasTag("exploding") && isServer())
	{
		server_Activate(this);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	s32 timer = this.get_s32("explosion_timer") - getGameTime();
	if (timer > 60 || timer < 0 || this.getDamageOwnerPlayer() is null) // don't change keg ownership for final 2 seconds of fuse
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}
	
	if (isServer())
	{
		this.set_u16("_keg_carrier_id", attached.getNetworkID());
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return this.getConfig()!=blob.getConfig();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (!solid) return;
	
	this.server_Die();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isServer() &&
	        !isExplosionHitter(customData) &&
	        (hitterBlob is null || hitterBlob.getTeamNum() != this.getTeamNum()))
	{
		u16 id = this.get_u16("_keg_carrier_id");
		if (id != 0xffff)
		{
			CBlob@ carrier = getBlobByNetworkID(id);
			if (carrier !is null)
			{
				this.server_DetachFrom(carrier);
			}
		}
	}

	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
			damage *= 0.25f; //quarter damage from these
			break;
		case Hitters::keg:
			if (isServer())
			{
				if (!this.hasTag("exploding"))
				{
					server_Activate(this);
				}

				//set fuse to shortest fuse time - either current time or new random time
				//so it doesn't explode at the exact same time as hitter keg
				this.set_s32("explosion_timer", Maths::Min(this.get_s32("explosion_timer"), getGameTime() + XORRandom(this.get_f32("keg_time")) / 3));
				this.Sync("explosion_timer", true);
			}
			damage *= 0.0f; //invincible to allow keg chain reaction
			break;
		default:
			damage *= 0.5f; //half damage from everything else
	}

	return damage;
}
