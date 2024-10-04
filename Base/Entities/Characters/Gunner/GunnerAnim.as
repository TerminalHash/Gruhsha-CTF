// Archer animations

#include "GunnerCommon.as"
#include "FireCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "KnockedCommon.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"

const f32 config_offset = -6.0f;

void onInit(CSprite@ this) {
	LoadSprites(this);
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onPlayerInfoChanged(CSprite@ this) {
	LoadSprites(this);
}

void LoadSprites(CSprite@ this) {
	int armour = PLAYER_ARMOUR_STANDARD;

	string username = "null";

	CPlayer@ p = this.getBlob().getPlayer();
	if (p !is null)
	{
		armour = p.getArmourSet();
		username = p.getUsername();
		if (armour == PLAYER_ARMOUR_STANDARD)
		{
			/*Accolades@ acc = getPlayerAccolades(p.getUsername());
			if (acc.hasCape())
			{
				armour = PLAYER_ARMOUR_CAPE;
			}*/
		}
	}

	switch (armour) {
	case PLAYER_ARMOUR_STANDARD:
		ensureCorrectRunnerTexture(this, "gunner", "Gunner");
		break;
	case PLAYER_ARMOUR_CAPE:
		ensureCorrectRunnerTexture(this, "gunner_cape", "GunnerCape");
		break;
	case PLAYER_ARMOUR_GOLD:
		ensureCorrectRunnerTexture(this, "gunner_gold",  "GunnerGold");
		break;
	}


	string texname = getRunnerTextureName(this);

	/*this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addTexturedSpriteLayer("frontarm", texname , 32, 16);

	if (frontarm !is null) {
		Animation@ animcharge = frontarm.addAnimation("charge", 0, false);
		animcharge.AddFrame(16);
		animcharge.AddFrame(24);
		animcharge.AddFrame(32);
		Animation@ animshoot = frontarm.addAnimation("fired", 0, false);
		animshoot.AddFrame(40);
		Animation@ animnoarrow = frontarm.addAnimation("no_arrow", 0, false);
		animnoarrow.AddFrame(25);
		frontarm.SetOffset(Vec2f(-1.0f, 5.0f + config_offset));
		frontarm.SetAnimation("fired");
		frontarm.SetVisible(false);
	}

	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addTexturedSpriteLayer("backarm", texname , 32, 16);

	if (backarm !is null) {
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(17);
		backarm.SetOffset(Vec2f(-1.0f, 5.0f + config_offset));
		backarm.SetAnimation("default");
		backarm.SetVisible(false);
	}*/
}

/*void setArmValues(CSpriteLayer@ arm, bool visible, f32 angle, f32 relativeZ, string anim, Vec2f around, Vec2f offset) {
	if (arm !is null)
	{
		arm.SetVisible(visible);

		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}

			arm.SetOffset(offset);
			arm.ResetTransform();
			arm.SetRelativeZ(relativeZ);
			arm.RotateBy(angle, around);
		}
	}
}*/


void onTick(CSprite@ this) {
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead")) {
		if (this.animation.name != "dead") {
			this.SetAnimation("dead");
			/*this.RemoveSpriteLayer("frontarm");
			this.RemoveSpriteLayer("backarm");*/
		}

		Vec2f vel = blob.getVelocity();

		if (vel.y < -1.0f) {
			this.SetFrameIndex(0);
		} else if (vel.y > 1.0f) {
			this.SetFrameIndex(1);
		} else {
			this.SetFrameIndex(2);
		}

		return;
	}

	// animations
	bool knocked = isKnocked(blob);
	const bool action1 = blob.isKeyPressed(key_action1);

	//if (!blob.hasTag(burning_tag)) //give way to burning anim
	{
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		Vec2f pos = blob.getPosition();

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}

		if (knocked)
		{
			if (inair)
			{
				if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
					this.SetAnimation("knocked_air_noarm");
				} else {
					this.SetAnimation("knocked_air");
				}
			}
			else
			{
				if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
					this.SetAnimation("knocked_noarm");
				} else {
					this.SetAnimation("knocked");
				}
			}
		}
		else if (blob.hasTag("seated"))
		{
			this.SetAnimation("crouch");
		}
		else if (blob.hasTag("blob lying"))
		{
			if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
				this.SetAnimation("lying_h");
			} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
				this.SetAnimation("lying_noarm");
			} else {
				this.SetAnimation("lying");
			}
		}
		else if (action1  || (this.isAnimation("build") && !this.isAnimationEnded()))
		{
			this.SetAnimation("build");
		}
		else if (inair)
		{
			RunnerMoveVars@ moveVars;
			if (!blob.get("moveVars", @moveVars))
			{
				return;
			}
			Vec2f vel = blob.getVelocity();
			f32 vy = vel.y;
			if (vy < -0.0f && moveVars.walljumped)
			{
				if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
					this.SetAnimation("run_h");
				} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
					this.SetAnimation("run_noarm");
				} else {
					this.SetAnimation("run");
				}
			}
			else
			{
				if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
					this.SetAnimation("fall_h");
				} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
					this.SetAnimation("fall_noarm");
				} else {
					this.SetAnimation("fall");
				}

				this.animation.timer = 0;
				bool inwater = blob.isInWater();

				if (vy < -1.5 * (inwater ? 0.7 : 1))
				{
					this.animation.frame = 0;
				}
				else if (vy > 1.5 * (inwater ? 0.7 : 1))
				{
					this.animation.frame = 2;
				}
				else
				{
					this.animation.frame = 1;
				}
			}
		}
		else if ((left || right) ||
		         (blob.isOnLadder() && (up || down)))
		{
			if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
				this.SetAnimation("run_h");
			} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
				this.SetAnimation("run_noarm");
			} else {
				this.SetAnimation("run");
			}
		}
		else
		{
			// get the angle of aiming with mouse
			Vec2f aimpos = blob.getAimPos();
			Vec2f vec = aimpos - pos;
			f32 angle = vec.Angle();
			int direction;

			if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
			        (angle > 150 && angle < 210))
			{
				direction = 0;
			}
			else if (aimpos.y < pos.y)
			{
				direction = -1;
			}
			else
			{
				direction = 1;
			}

			defaultIdleAnim(this, blob, direction);
		}
	}

	//set the head anim
	if (knocked)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action1))
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

bool IsFiring(CBlob@ blob)
{
	return blob.isKeyPressed(key_action1);
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	if (getRules().get_string("clusterfuck") == "off") return;

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
