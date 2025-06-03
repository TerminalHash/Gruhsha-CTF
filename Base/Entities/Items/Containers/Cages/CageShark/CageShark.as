#include "AnimalConsts.as";
#include "GenericButtonCommon.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 600;

void onInit(CBlob@ this)
{
	this.Tag("activatable");
	this.Tag("special");
	this.Tag("heavy weight");
	this.Tag("cage is fine");

	this.addCommandID("activate");
	this.addCommandID("activate client");
	this.addCommandID("release animal");
	this.addCommandID("release animal client");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$chest_close$", "InteractionIcons.png", Vec2f(32, 32), 13);
}

void onTick(CBlob@ this)
{
	// parachute

	if (this.hasTag("parachute"))
	{
		if (this.getSprite().getSpriteLayer("parachute") is null)
		{
			ShowParachute(this);
		}

		// para force + swing in wind
		this.AddForce(Vec2f(Maths::Sin(getGameTime() * 0.03f) * 1.0f, -120.0f * this.getVelocity().y));

		if (this.isOnGround() || this.isInWater() || this.isAttached())
		{
			this.Untag("parachute");
			HideParachute(this);
		}
	}
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
		"Open the cage");// description

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

		// set initial tag back, because we dont want spawn two animals %)
		if (!this.hasTag("cage is fine")) {
			this.Tag("cage is fine");
			this.Untag("cage is being damaged");
		}

		// range check
		const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
		if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

		this.AddForce(Vec2f(0, -800));

		// spawn our animal after opening cage with traditional method
		// animal should be friendly for team, which opened cage
		CBlob@ shark = server_CreateBlob("shark", 255, Vec2f(this.getPosition().x + 35, this.getPosition().y));

		this.SendCommand(this.getCommandID("activate client"));

		this.server_Die();
	} else if (cmd == this.getCommandID("activate client") && isClient()) {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}

	if (cmd == this.getCommandID("release animal") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		// dont allow to spawn double animal
		if (!this.hasTag("cage is being damaged")) return;
		if (this.hasTag("cage is fine")) return;

		CBlob@ shark = server_CreateBlob("shark", 255, Vec2f(this.getPosition().x + 35, this.getPosition().y));

		this.SendCommand(this.getCommandID("release animal client"));
	} else if (cmd == this.getCommandID("release animal client") && isClient()) {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("destroy_wood.ogg", 3.0f);
			sprite.PlaySound("rock_hit1.ogg", 3.0f);
		}
	}
}

void onDie(CBlob@ this) {
	if (this is null) return;

	if (this !is null && this.hasTag("cage is being damaged")) {
		this.SendCommand(this.getCommandID("release animal"));
	}
}

// set special tag for damaged cage for activate special command after destroying
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	if (hitterBlob !is null && damage > 0 && this.hasTag("cage is fine")) {
		this.Untag("cage is fine");
		this.Tag("cage is being damaged");

		return damage;
	}

	return damage;
}

//bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
//{
//	return blob.getShape().isStatic() && blob.isCollidable();
//}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (this.getName() == blob.getName())
		|| ((blob.getShape().isStatic() || blob.hasTag("player") || blob.hasTag("projectile")) && !blob.hasTag("parachute"));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void ShowParachute(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.addSpriteLayer("parachute",   32, 32);

	if (parachute !is null)
	{
		Animation@ anim = parachute.addAnimation("default", 0, true);
		anim.AddFrame(1);
		parachute.SetOffset(Vec2f(0.0f, - 17.0f));
	}
}

void HideParachute(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.getSpriteLayer("parachute");

	if (parachute !is null && parachute.isVisible())
	{
		parachute.SetVisible(false);
		ParticlesFromSprite(parachute);
	}
}
