// Keg logic
#include "Hitters.as";
#include "GruhshaHitters.as";
#include "ActivationThrowCommon.as"

void onInit(CBlob@ this)
{
	//this.Tag("bomberman_style");
	//this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 256.0f);
	this.set_f32("explosive_damage", 20.0f);
	this.set_u8("custom_hitter", GruhshaHitters::fumo_keg);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 256.0f);
	this.set_f32("map_damage_ratio", 2.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 450.0f);  // 15 seconds timer
	//this.Tag("medium weight");
	this.Tag("slash_while_in_hand"); // allows knights to knock kegs off enemies' backs

	this.set_u16("_keg_carrier_id", 0xffff);

	this.Tag("special");

	this.set_f32("important-pickup", 30.0f);
}

void onInit(CSprite@ this)
{
	this.SetEmitSoundPaused(true);
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	s32 timer = blob.get_s32("explosion_timer") - getGameTime();

	if (timer < 0) {
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
