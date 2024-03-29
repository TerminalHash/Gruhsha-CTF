#include "Help.as";
#include "TrampolineCommon.as";
#include "GenericButtonCommon.as";
#include "StandardControlsCommon.as";
#include "HandleButtonClickForTramp.as";
#include "Hitters.as";

class TrampolineCooldown{
	u16 netid;
	u32 timer;
	TrampolineCooldown(u16 netid, u16 timer){this.netid = netid; this.timer = timer;}
};

void onInit(CBlob@ this)
{
	TrampolineCooldown @[] cooldowns;
	this.set(Trampoline::TIMER, cooldowns);
	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("setup_feet_tick");
	// this.getCurrentScript().runFlags |= Script::tick_attached;

	this.Tag("no falldamage");
	this.Tag("medium weight");
	this.Tag("ignore_attach_facing");
	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	this.addCommandID("freeze_angle_at");
	this.addCommandID("unfreeze_tramp");
	this.addCommandID("unfold");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1 | key_action3);

	if (this.hasTag("tramp_freeze"))
	{
		ShowMeYourFeet(this, this.get_f32("old_angle"), true);
	}
}

void onTick(CBlob@ this)
{
	// Map trampoline setup tick
	if (this.hasTag("setup_feet_tick"))
	{
		this.Untag("setup_feet_tick");
		if (this.exists("map_alpha"))
		{
			// from BasePNGLoader.as - getAngleFromChannel()
			switch (this.get_u8("map_alpha") & 0x30)
			{
				// case  0: {this.set_f32("old_angle",   0.0f); ShowMeYourFeet(this,   0.0f); break;}
				case 16: {this.set_f32("old_angle",  90.0f); ShowMeYourFeet(this,  90.0f); break;}
				// case 32: {this.set_f32("old_angle", 180.0f); ShowMeYourFeet(this, 180.0f); break;}
				case 48: {this.set_f32("old_angle", 270.0f); ShowMeYourFeet(this, 270.0f); break;}
			}
		}
		else if (this.getTeamNum() == 255)
		{
			ShowMeYourFeet(this, 0.0f);
		}

		this.getCurrentScript().runFlags |= Script::tick_attached;
	}

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	HandleButtonClickKey(holder, point);

	if (holder.isMyPlayer() && point.isKeyJustPressed(key_action3))
	{
		if (this.hasTag("feet_active"))
		{
			if (!this.hasTag("tramp_freeze"))
			{
				return; // already sent command
			}

			this.Untag("tramp_freeze");
			Sound::Play("bone_fall.ogg", this.getPosition());

			this.SendCommand(this.getCommandID("unfreeze_tramp"));
		}
		else
		{
			if (this.hasTag("tramp_freeze"))
			{
				return; // already sent command
			}

			this.Tag("tramp_freeze");
			// this.getShape().SetRotationsAllowed(false);
			Sound::Play("hit_wood.ogg", this.getPosition());

			CBitStream params;
			params.write_f32(getHoldAngle(this, holder, point));
			this.SendCommand(this.getCommandID("freeze_angle_at"), params);
		}
	}

	f32 angle;
	if (this.hasTag("tramp_freeze") || this.hasTag("feet_active"))
	{
		angle = this.get_f32("old_angle");
	}
	// else if (point.isKeyPressed(key_action2))
	// {
	// 	angle = this.get_f32("old_angle");
	// }
	else
	{
		angle = getHoldAngle(this, holder, point);
	}

	this.setAngleDegrees(angle);
	// this.set_f32("old_angle", angle);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.getShape().isStatic())
	{
		if (solid && this.hasTag("folded") && !this.isAttached())
			Unfold(this);

		return;
	}

	if (blob.isAttached() || this.hasTag("folded")) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//choose whether to pass through team trampolines
	if (blob.hasTag("player") 
		&& (blob.isKeyPressed(key_down)
			|| (this.getAngleDegrees() > 120		// Hold W to pass downward-facing trampolines
				&& this.getAngleDegrees() < 240
				&& blob.isKeyPressed(key_up)))
		&& this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	//cant bounce holder
	if (holder is blob) return;

	//cant bounce while held by something attached to something else
	if (holder !is null && holder.isAttached()) return;

	//prevent knights from flying using trampolines

	// Blob needs to be coming towards bouncy side (4 pixels above center pos)
	Vec2f offset = blob.getOldPosition() - this.getPosition();
	offset.RotateBy(-this.getAngleDegrees());
	if (offset.y > -4) return;

	TrampolineCooldown@[]@ cooldowns;
	if (!this.get(Trampoline::TIMER, @cooldowns)) return;

	//shred old cooldown if we have too many
	if (Trampoline::SAFETY && cooldowns.length > Trampoline::COOLDOWN_LIMIT) cooldowns.removeAt(0);

	u16 netid = blob.getNetworkID();
	bool block = false;
	for(int i = 0; i < cooldowns.length; i++)
	{
		if (cooldowns[i].timer < getGameTime())
		{
			cooldowns.removeAt(i);
			i--;
		}
		else if (netid == cooldowns[i].netid)
		{
			block = true;
			break;
		}
	}
	if (!block)
	{
		Vec2f velocity_old = blob.getOldVelocity();
		if (velocity_old.Length() < 1.0f) return;

		float angle = this.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);

		float velocity_angle = direction.AngleWith(velocity_old);

		if (Maths::Abs(velocity_angle) > 90)
		{
			TrampolineCooldown cooldown(netid, getGameTime() + Trampoline::COOLDOWN);
			cooldowns.push_back(cooldown);

			Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);
			velocity.RotateBy(angle);

			f32 force_modifier = 1.07f;
			f32 force_value = Maths::Max(6, velocity_old.Length()*force_modifier);
			blob.setVelocity(Vec2f(force_value,0).RotateBy(angle-90));

			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetAnimation("default");
				sprite.SetAnimation("bounce");
				sprite.PlaySound("TrampolineJump.ogg");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("freeze_angle_at"))
	{
		f32 angle;
		if (!params.saferead_f32(angle)) return;

		this.set_f32("old_angle", angle);
		this.setAngleDegrees(angle);
		ShowMeYourFeet(this, angle);
	}
	else if (cmd == this.getCommandID("unfreeze_tramp"))
	{
		Fold(this);
		RemoveFeet(this);
	}
	else if (cmd == this.getCommandID("unfold"))
	{
		Unfold(this);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller) || !this.hasTag("folded")
		|| (this.isAttached() && !this.isAttachedTo(caller)))
	{
		return;
	}

	CButton@ button = caller.CreateGenericButton(6, Vec2f(0, 0), this, this.getCommandID("unfold"), "Unpack Trampoline");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.getTeamNum() == 255)
	{
		RemoveFeet(this);
		this.Untag("invincible");
	}

	this.getShape().SetRotationsAllowed(false);
	if (!this.hasTag("tramp_freeze"))
		Fold(this);

	if (!attached.isMyPlayer()) return;

	SetHelp(attached, "trampoline help lmb", "", getTranslatedString("$trampoline$ Lock to 45° steps  $KEY_HOLD$$LMB$"), "", 3, true);
	// SetHelp(attached, "trampoline help rmb", "", getTranslatedString("$trampoline$ Lock current angle  $KEY_HOLD$$RMB$"), "", 3, true);
	SetHelp(attached, "trampoline help space", "", getTranslatedString("$trampoline$ Add/remove feet  $KEY_TAP$$KEY_SPACE$"), "", 3, true);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.getShape().SetRotationsAllowed(true);

	if (!detached.isMyPlayer()) return;
	RemoveHelps(detached, "trampoline help lmb");
	// RemoveHelps(detached, "trampoline help rmb");
	RemoveHelps(detached, "trampoline help space");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isExplosionHitter(customData) && !this.isAttached() && this.getTeamNum() != 255)
	{
		RemoveFeet(this);

		if (isClient())
		{
			makeGibParticle("TrampFeet.png", this.getPosition(),
							this.getVelocity() + getRandomVelocity(90, 3, 80) + Vec2f(0.0f, -2.0f),
							0, 0, Vec2f(8, 8), 2.0f, 20, "material_drop.ogg");
			makeGibParticle("TrampFeet.png", this.getPosition(),
							this.getVelocity() + getRandomVelocity(90, 3, 80) + Vec2f(0.0f, -2.0f),
							0, 1, Vec2f(8, 8), 2.0f, 20, "material_drop.ogg");
		}
	}
	return damage;
}

void onHealthChange(CBlob@ this, f32 health_old)
{
	if (!isClient()) return;

	if (this.getHealth() <= this.getInitialHealth() / 2)
	{
		CSprite@ sprite = this.getSprite();

		Animation@ anim = sprite.getAnimation("default");
		anim.AddFrame(2);
		anim.RemoveFrame(0);

		@anim = sprite.getAnimation("bounce");
		anim.RemoveFrame(6);
		anim.AddFrame(2);

		@anim = sprite.getAnimation("pack");
		const int[] frames = {2, 3, 0, 1};
		anim.AddFrames(frames);
		for (int i = 0; i < 4; ++i)
		{
			anim.RemoveFrame(0);
		}

		@anim = sprite.getAnimation("unpack");
		anim.RemoveFrame(3);
		anim.AddFrame(2);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if (this.hasTag("no pickup"))
	{
		return false;
	}
	else if (this.hasTag("folded") || byBlob.getTeamNum() == this.getTeamNum())
	{
		return true;
	}
	else
	{
		// Can only be picked up from non-bouncy side
		Vec2f offset = byBlob.getPosition() - this.getPosition();
		offset.RotateBy(-this.getAngleDegrees());
		return (offset.y > 4);
	}
}

f32 getHoldAngle(CBlob@ this, CBlob@ holder, AttachmentPoint@ point)
{
	if (!this.hasTag("folded")) // follow cursor slowly
	{
		f32 angle = (holder.getAimPos() - this.getPosition()).Angle();
		angle = (-1.0f * angle + 90 + 360) % 360;

		if (angle < 90) angle=angle;
		else if (angle < 180) angle = 90;
		else if (angle < 270) angle = 270;

		f32 diff = angle - this.getAngleDegrees();
		if (diff < -180) diff += 360;
		if (diff > 180) diff -= 360;

		return this.getAngleDegrees() + diff / 10.0f;
	}
	else if (point.isKeyPressed(key_action1))
	{
		// Follow cursor in 45 degree steps
		f32 angle;
		angle = (holder.getAimPos() - this.getPosition()).Angle();
		angle = -Maths::Floor((angle - 67.5f) / 45) * 45;
		return angle;
	}
	// else if (point.isKeyPressed(key_action2))
	// {
	// 	return this.get_f32("old_angle");
	// }
	else
	{
		// follow cursor normally
		return (-1.0f * (holder.getAimPos() - this.getPosition()).Angle() + 90 + 360) % 360;
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ left = this.addSpriteLayer("left_foot", "TrampFeet.png", 8, 8);
	if (left !is null)
	{
		left.addAnimation("default", 0, false);
		left.animation.AddFrame(0);

		left.SetRelativeZ(-1);
		left.SetVisible(false);
		left.SetIgnoreParentFacing(true);
	}

	CSpriteLayer@ right = this.addSpriteLayer("right_foot", "TrampFeet.png", 8, 8);
	if (right !is null)
	{
		right.addAnimation("default", 0, false);
		right.animation.AddFrame(1);

		right.SetRelativeZ(-1);
		right.SetVisible(false);
		right.SetIgnoreParentFacing(true);
	}

	CBlob@ blob = this.getBlob();
	if (blob.hasTag("tramp_freeze"))
	{
		ShowMeYourFeet(blob, blob.get_f32("old_angle"), false, true);
	}
}

void ShowMeYourFeet(CBlob@ this, f32 tramp_angle, bool skip_sprite=false, bool skip_shape=false)
{
	if (this.hasTag("folded"))
		Unfold(this);

	tramp_angle = (tramp_angle + 360) % 360;
	f32 tilt = tramp_angle;
	if (tilt > 180)
		tilt = 360 - tilt;

	tilt *= 0.0174533f; // radians

	f32 height = tilt < 0.9506f ? 7.38241f * Maths::Sin(tilt + 0.49394f) - 3.5f // match bottom vertex
								: 12.0208f * Maths::Sin(tilt - 0.29544f) - 3.5f; // match side vertex

	Vec2f left_offset = Vec2f(0, height);
	Vec2f right_offset = Vec2f(0, height);

	f32 halfwidth = 8 * Maths::Abs(Maths::Cos(tilt));

	bool lame_legs = false;
	if (tramp_angle < 100) // normal
	{
		left_offset.x = -halfwidth;
		right_offset.x = halfwidth;
	}
	else if (tramp_angle < 155) // right spotlight
	{
		left_offset.x = -halfwidth - 1;
		right_offset.x = -halfwidth + 3;
	}
	else if (tramp_angle < 205) // upside down
	{
		left_offset = Vec2f(-8, 0);
		right_offset = Vec2f(8, 0);
		lame_legs = true;
	}
	else if (tramp_angle < 260) // left spotlight
	{
		right_offset.x = halfwidth + 1;
		left_offset.x = halfwidth - 3;
	}
	else // normal
	{
		left_offset.x = -halfwidth;
		right_offset.x = halfwidth;
	}

	if (!skip_shape)
	{
		this.Tag("feet_active");
		this.Tag("tramp_freeze");
		Vec2f centerofmass = (left_offset + right_offset) / 2;
		centerofmass.RotateBy(-tramp_angle);
		this.getShape().SetCenterOfMassOffset(centerofmass);
		// this.getShape().SetRotationsAllowed(false);
	}

	if (!lame_legs && !skip_shape)
	{
		Vec2f[] legShape;
		Vec2f offset;
		Vec2f center;

		// Left foot
		legShape.clear();
		offset = left_offset;
		offset.RotateBy(-tramp_angle);
		center = Vec2f(11.5f, 3.5f) + offset;
		// legShape.push_back(center + Vec2f(-3.5f, -3.5f));
		legShape.push_back(center + Vec2f(3.5f, -3.5f));
		legShape.push_back(center + Vec2f(3.5f, 3.5f));
		legShape.push_back(center + Vec2f(-3.5f, 3.5f));
		for (int i = 0; i < legShape.size(); ++i)
		{
			legShape[i].RotateBy(-tramp_angle, center);
		}
		this.getShape().AddShape(legShape);

		// Right foot
		legShape.clear();
		offset = right_offset;
		offset.RotateBy(-tramp_angle);
		center = Vec2f(11.5f, 3.5f) + offset;
		legShape.push_back(center + Vec2f(-3.5f, -3.5f));
		// legShape.push_back(center + Vec2f(3.5f, -3.5f));
		legShape.push_back(center + Vec2f(3.5f, 3.5f));
		legShape.push_back(center + Vec2f(-3.5f, 3.5f));
		for (int i = 0; i < legShape.size(); ++i)
		{
			legShape[i].RotateBy(-tramp_angle, center);
		}
		this.getShape().AddShape(legShape);
	}

	if (!isClient() || skip_sprite) return;

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ left = sprite.getSpriteLayer("left_foot");
	left.ResetTransform();
	left.TranslateBy(left_offset);
	left.SetVisible(true);

	CSpriteLayer@ right = sprite.getSpriteLayer("right_foot");
	right.ResetTransform();
	right.TranslateBy(right_offset);
	right.SetVisible(true);

	if (lame_legs) return; // don't rotate

	// cancel angle so the offset is normal
	if (tilt > 180)
	{
		left.RotateBy(-tramp_angle, Vec2f_zero);
		right.RotateBy(-tramp_angle, Vec2f_zero);
	}
	else
	{
		left.RotateBy(-tramp_angle, Vec2f_zero);
		right.RotateBy(-tramp_angle, Vec2f_zero);
	}
}

void RemoveFeet(CBlob@ this)
{
	this.Untag("tramp_freeze");
	this.Untag("feet_active");
	// this.getShape().SetRotationsAllowed(true);
	this.getShape().SetCenterOfMassOffset(Vec2f_zero);
	this.getShape().RemoveShape(1);
	this.getShape().RemoveShape(1);

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.getSpriteLayer("left_foot").SetVisible(false);
		sprite.getSpriteLayer("right_foot").SetVisible(false);
	}
}

void Fold(CBlob@ this)
{
	this.Tag("folded");
	this.Untag("medium weight");
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetAnimation("pack");
}

void Unfold(CBlob@ this)
{
	this.Untag("folded");
	this.Tag("medium weight");
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetAnimation("unpack");
}
