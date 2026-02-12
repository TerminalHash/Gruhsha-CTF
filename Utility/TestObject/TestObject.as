// TestObject.as
#include "GenericButtonCommon.as";

void onInit(CBlob@ this) {
    this.Tag("TEST OBJECT");

	this.addCommandID("change to default");
	this.addCommandID("change to default client");
	this.addCommandID("change to teamobject");
	this.addCommandID("change to teamobject client");

	AddIconToken("$team_object$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$test_object$", "UnlockIcon.png", Vec2f(16, 16), 0);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CMap@ map = getMap();
	if (map is null) return;

	const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
	if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

	if (this.hasTag("TEAM OBJECT")) {
		CButton@ button = caller.CreateGenericButton(
			"$team_object$",										// icon token
			Vec2f_zero,											// button offset
			this,												// button attachment
			this.getCommandID("change to default"),						// command id
			"Use default look");// description

		button.radius = 12.0f;
		button.enableRadius = 24.0f;
	}

	// second button is lock removing button
	if (!this.hasTag("TEAM OBJECT")) {
		CButton@ button = caller.CreateGenericButton(
			"$test_object$",										// icon token
			Vec2f_zero,											// button offset
			this,												// button attachment
			this.getCommandID("change to teamobject"),				// command id
			"Use team look");// description

		button.radius = 12.0f;
		button.enableRadius = 24.0f;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("change to teamobject") && isServer())
	{
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		this.Tag("TEAM OBJECT");

		this.SendCommand(this.getCommandID("change to teamobject client"));
	} else if (cmd == this.getCommandID("change to teamobject client") && isClient()) {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("teamobject");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}

	if (cmd == this.getCommandID("change to default") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		// dont allow to spawn double animal
		this.Untag("TEAM OBJECT");

		this.SendCommand(this.getCommandID("change to default client"));
	} else if (cmd == this.getCommandID("change to default client") && isClient()) {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("default");
			sprite.PlaySound("destroy_wood.ogg", 3.0f);
			sprite.PlaySound("rock_hit1.ogg", 3.0f);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (this.getName() == blob.getName())
		|| ((blob.getShape().isStatic() || blob.hasTag("player") || blob.hasTag("projectile")) && !blob.hasTag("parachute"));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}