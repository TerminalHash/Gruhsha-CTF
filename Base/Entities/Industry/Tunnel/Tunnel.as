// Tunnel.as

#include "TunnelCommon.as"

s32 seconds_temporary_perhit = 36;			// 180 seconds (3 min) alive
s32 seconds_temporary_perhit_less = 12;		// 60 seconds (1 min) alive
f32 damage_temporary_perhit = 0.2f;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	const u16 left = getRules().get_u16("barrier_x1");
	const u16 right = getRules().get_u16("barrier_x2");

	if ((this.getPosition().x > left && this.getPosition().x < right && this.getTeamNum() == 0 || this.getPosition().x > left && this.getPosition().x < right && this.getTeamNum() == 1)) {
		//printf("Tunnel is temporary!");

		this.Tag("temporary");
		this.Sync("temporary", true);

		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);
	} else if ((this.getPosition().x > left && this.getPosition().x > right && this.getTeamNum() == 0)) {
		//printf("Tunnel is temporary in enemy zone!");

		this.Tag("temporary");
		this.Sync("temporary", true);

		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);
	} else if ((this.getPosition().x < left && this.getPosition().x < right && this.getTeamNum() == 1)) {
		//printf("Tunnel is temporary in enemy zone!");

		this.Tag("temporary");
		this.Sync("temporary", true);

		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);
	}
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (!this.hasTag("temporary")) return;

	const u16 left = getRules().get_u16("barrier_x1");
	const u16 right = getRules().get_u16("barrier_x2");

	if (getGameTime() > seconds_temporary_perhit * getTicksASecond() + this.get_s32("breaktime")) {
		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);

		this.server_Hit(this, this.getPosition(), Vec2f(0, -1), this.getInitialHealth() * damage_temporary_perhit * 2.01, 0);
	} else if (getGameTime() > seconds_temporary_perhit_less * getTicksASecond() + this.get_s32("breaktime") && (this.getPosition().x > right && this.getTeamNum() == 0)) {
		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);

		this.server_Hit(this, this.getPosition(), Vec2f(0, -1), this.getInitialHealth() * damage_temporary_perhit * 2.01, 0);
	} else if (getGameTime() > seconds_temporary_perhit_less * getTicksASecond() + this.get_s32("breaktime") && (this.getPosition().x < left && this.getTeamNum() == 1)) {
		this.set_s32("breaktime", getGameTime());
		this.Sync("breaktime", true);

		this.server_Hit(this, this.getPosition(), Vec2f(0, -1), this.getInitialHealth() * damage_temporary_perhit * 2.01, 0);
	}
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 24, 24, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null) {
		Animation@ anim = planks.addAnimation("default", 3, true);
		anim.AddFrame(5);
		planks.SetOffset(Vec2f(0, 0));
		planks.SetRelativeZ(10);
	}

	this.getCurrentScript().tickFrequency = 45; // opt
}

void onTick(CSprite@ this)
{
	if (this is null) return;

	CSpriteLayer@ planks = this.getSpriteLayer("planks");
	if (planks is null) return;

	CBlob@[] list;
	if (getTunnels(this.getBlob(), list)) {
		planks.SetVisible(false);
	} else {
		planks.SetVisible(true);
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();

	if (sprite !is null) {
		Animation@ destruction = sprite.getAnimation("destruction");

		if (destruction !is null) {
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}
