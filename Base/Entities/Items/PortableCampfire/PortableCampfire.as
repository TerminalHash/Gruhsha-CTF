// PortableCampfire.as

#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("activatable");

	this.addCommandID("activate");
	this.addCommandID("activate client");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
	if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

	CButton@ button = caller.CreateGenericButton(
		"$chest_open$",										// icon token
		Vec2f_zero,											// button offset
		this,												// button attachment
		this.getCommandID("activate"),						// command id
		"Place campfire");// description

	button.radius = 12.0f;
	button.enableRadius = 24.0f;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate") && isServer())
	{
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		// range check
		const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
		if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

		CBlob@ campfire = server_CreateBlob("fireplace", caller.getTeamNum(), Vec2f(this.getPosition().x, this.getPosition().y - 2));

		this.SendCommand(this.getCommandID("activate client"));

		this.server_Die();
	}
	else if (cmd == this.getCommandID("activate client") && isClient())
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("campfireactivate.ogg", 4.0f);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (this.getName() == blob.getName())
		|| ((blob.getShape().isStatic() || blob.hasTag("player") || blob.hasTag("projectile")));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}
