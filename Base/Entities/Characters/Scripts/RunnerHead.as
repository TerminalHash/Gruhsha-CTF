// generic character head script

// TODO: fix double includes properly, added the following line temporarily to fix include issues
#include "PaletteSwap.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"
#include "HolidayCommon.as"
#include "RunnerHeadAngle.as"
#include "HeadCommon.as"

void onPlayerInfoChanged(CSprite@ this)
{
	LoadHead(this, this.getBlob().getHeadNum());
}

CSpriteLayer@ LoadHead(CSprite@ this, int headIndex)
{
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	CRules@ rules = getRules();

	// strip old head
	this.RemoveSpriteLayer("head");
	if (blob !is null)
		blob.set_s32("headIndex", headIndex);

	string texture_file;
	s32 headFrame = getHeadSpecs(player, texture_file);

	u8 team = blob.getTeamNum();
	u8 skin = blob.getSkinNum();

	//add new head
	CSpriteLayer@ head = this.addSpriteLayer("head", texture_file, 16, 16, team, skin);

	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(headFrame);
		anim.AddFrame(headFrame + 1);
		anim.AddFrame(headFrame + 2);
		head.SetAnimation(anim);

		head.SetFacingLeft(blob.isFacingLeft());
	}

	//setup gib properties
	blob.set_s32("head index", headFrame);
	blob.set_string("head texture", texture_file);
	blob.set_s32("head team", team);
	blob.set_s32("head skin", skin);

	return head;
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	if (getRules().get_string("clusterfuck") == "off") return;

	CBlob@ blob = this.getBlob();
	if (blob !is null && blob.getName() != "bed")
	{
		int frame = blob.get_s32("head index");
		int framex = frame % FRAMES_WIDTH;
		int framey = frame / FRAMES_WIDTH;

		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.5;
		makeGibParticle(
			blob.get_string("head texture"),
			pos, vel + getRandomVelocity(90, hp , 30),
			framex, framey, Vec2f(16, 16),
			2.0f, 20, "/BodyGibFall", blob.getTeamNum()
		);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;

	ScriptData@ script = this.getCurrentScript();
	if (script is null)
		return;

	if (blob.getShape().isStatic())
	{
		script.tickFrequency = 60;
	}
	else
	{
		script.tickFrequency = 1;
	}


	// head animations
	CSpriteLayer@ head = this.getSpriteLayer("head");

	// load head when player is set or it is AI
	if (head is null && (player !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3) || (blob.get_s32("headIndex") != blob.getHeadNum()))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}

	if (head !is null)
	{
		Vec2f offset;

		// pixeloffset from script
		// set the head offset and Z value according to the pink/yellow pixels
		int layer = 0;
		Vec2f head_offset = getHeadOffset(blob, -1, layer);
		f32 head_z = this.getRelativeZ() + layer * 0.55f; //changed from 0.25 to 0.55 so it's above legs, torso and arms
		if (blob.isAttached()&&!blob.hasTag("isInVehicle")&&!blob.isAttachedToPoint("PICKUP"))
			head_z += 300;

		// behind, in front or not drawn
		if (layer == 0)
		{
			head.SetVisible(false);
		}
		else
		{
			head.SetVisible(this.isVisible());
			head.SetRelativeZ(head_z);
		}

		offset = head_offset;

		// set the proper offset
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		headoffset += this.getOffset();
		headoffset += Vec2f(-offset.x, offset.y);
		headoffset += Vec2f(0, -2);
		if (blob.hasTag("attack head"))
			headoffset += Vec2f(1, 0);
		if (blob.hasTag("dead head"))
			headoffset += Vec2f(0, 2);
		head.SetOffset(headoffset);
		head.ResetTransform();

		f32 lower_clamp = Maths::Abs(blob.getVelocity().x)<1?-35:0;
		f32	upper_clamp = 45;
		f32 headangle = Maths::Clamp(getHeadAngle(blob, headoffset), FLIP?lower_clamp:-upper_clamp, FLIP?upper_clamp:-lower_clamp);
		//printf("angle "+headangle);

		if (blob.hasTag("dead") || blob.hasTag("dead head"))
		{
			headangle = -lower_clamp*FLIP_FACTOR+blob.getAngleDegrees();
			head.animation.frame = 2;

			// sparkle blood if cut throat
			if (getNet().isClient() && getGameTime() % 2 == 0 && blob.hasTag("cutthroat"))
			{
				Vec2f vel = getRandomVelocity(90.0f, 1.3f * 0.1f * XORRandom(40), 2.0f);
				ParticleBlood(blob.getPosition() + Vec2f(this.isFacingLeft() ? headoffset.x : -headoffset.x, headoffset.y), vel, SColor(255, 126, 0, 0));
				if (XORRandom(100) == 0)
					blob.Untag("cutthroat");
			}
		}
		else if (blob.hasTag("attack head"))
		{
			head.animation.frame = 1;
		}
		else
		{
			head.animation.frame = 0;
		}

		blob.set_f32("head_angle", headangle);

		if (getRules().get_string("head_rotating") == "off") return;
		head.RotateBy(headangle+blob.getAngleDegrees()*0, Vec2f(0, 4));
	}
}

f32 getHeadAngle(CBlob@ this, Vec2f headoffset)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f pos = this.getPosition() + headoffset.RotateBy(-this.getAngleDegrees());
 	Vec2f aimvector = this.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor));
}
