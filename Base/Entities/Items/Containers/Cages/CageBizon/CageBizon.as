#include "AnimalConsts.as";
#include "GenericButtonCommon.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 600;

// only one animal allowed to spawn
const int animals_to_spawn = 1;

const s32 releaseSecs = 3;

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
	this.addCommandID("set release timer");

	this.set_s32("release secs", releaseSecs);
	this.set_s32("release timer", 0);

	this.set_Vec2f("required space", Vec2f(5, 4));

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$unlock_icon$", "UnlockIcon.png", Vec2f(16, 16), 0);
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

	CMap@ map = getMap();
	if (map is null) return;

	const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
	if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

	// dont allow releasing, when cage in no build sector or solid tiles or in blobs
	Vec2f space = this.get_Vec2f("required space");
	Vec2f offsetPos = crate_getOffsetPos(this, map);
	Vec2f aligned = getDriver().getScreenPosFromWorldPos(offsetPos);

	for (f32 step_x = 0.0f; step_x < space.x ; ++step_x) {
		for (f32 step_y = 0.0f; step_y < space.y ; ++step_y) {
			Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
			Vec2f v = offsetPos + temp;
			
			if (map.isTileSolid(v) ||(map.getSectorAtPosition(v, "no build") !is null || hasNoBuildBlobs(v))) return;
		}
	}

	// first button is actually releasing button
	if (this.get_s32("release timer") != 0 && getGameTime() >= this.get_s32("release timer")) {
		CButton@ button = caller.CreateGenericButton(
			"$chest_open$",										// icon token
			Vec2f_zero,											// button offset
			this,												// button attachment
			this.getCommandID("activate"),						// command id
			"Open the cage");// description

		button.radius = 12.0f;
		button.enableRadius = 24.0f;
	}

	// second button is lock removing button
	if (this.get_s32("release timer") == 0) {
		CButton@ button = caller.CreateGenericButton(
			"$unlock_icon$",										// icon token
			Vec2f_zero,											// button offset
			this,												// button attachment
			this.getCommandID("set release timer"),				// command id
			"Remove lock");// description

		button.radius = 12.0f;
		button.enableRadius = 24.0f;
	}
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

		this.AddForce(Vec2f(0, -800));

		// spawn our animal after opening cage with traditional method
		// animal should be friendly for team, which opened cage
		for (uint i = 0; i < animals_to_spawn; i++) {
			CBlob@ animal = server_CreateBlob("bison", 255, Vec2f(this.getPosition().x + 35, this.getPosition().y));
			if (animal !is null) {
				animal.set_netid(friend_property, caller.getNetworkID());
				animal.set_u8(state_property, MODE_FRIENDLY);

				// need for hearts particles
				animal.set_bool("released from cage", true);
				animal.Sync("released from cage", true);
			}
		}

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

		for (uint i = 0; i < animals_to_spawn; i++) {
			CBlob@ animal = server_CreateBlob("bison", 255, Vec2f(this.getPosition().x + 35, this.getPosition().y));
			if (animal !is null) {
				if (animal.get_s16("mad timer") <= MAD_TIME / 8) {
					animal.getSprite().PlaySound("/BisonMad");
				}

				animal.set_s16("mad timer", MAD_TIME);
				animal.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
				animal.set_u8(state_property, MODE_TARGET);
				animal.set_netid(target_property, caller.getNetworkID());

				// need for angry particles
				animal.set_bool("released from cage with attack", true);
				animal.Sync("released from cage with attack", true);
			}
		}

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

	if (cmd == this.getCommandID("set release timer") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;
					
		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		// range check
		const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
		if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

		this.set_s32("release timer", getGameTime() + this.get_s32("release secs") * getTicksASecond());
		this.Sync("release timer", true);
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

const string[] noBuildBlobs = {"wooden_door", "stone_door", "wooden_platform", "bridge"};

bool hasNoBuildBlobs(Vec2f pos)
{
	CBlob@[] blobs;
	if (getMap().getBlobsAtPosition(pos + Vec2f(1, 1), blobs))
	{
		for (int i = 0; i < blobs.size(); i++)
		{
			CBlob@ blob = blobs[i];
			if (blob is null) continue;

			if (noBuildBlobs.find(blob.getName()) != -1)
			{
				return true;
			}
		}
	}

	return false;
}

Vec2f crate_getOffsetPos(CBlob@ blob, CMap@ map)
{
	Vec2f space = blob.get_Vec2f("required space");
	space.x *= 0.5f;
	space.y -= 1;
	Vec2f offsetPos = map.getAlignedWorldPos(blob.getPosition() + Vec2f(4, 6) - space * map.tilesize);
	return offsetPos;
}

// SPRITE
void onInit(CSprite@ this) {
	this.RemoveSpriteLayer("cage_lock");
	CSpriteLayer@ cage_lock = this.addSpriteLayer("cage_lock", 'CageLock.png' , 16, 16, 255, -1);

	if (cage_lock !is null)
	{
		Animation@ anim = cage_lock.addAnimation("default", 0, false);
		anim.AddFrame(0);
		cage_lock.SetOffset(Vec2f(-17.0f, 2.0f));
		cage_lock.SetRelativeZ(1);
	}
}

// render unpacking time
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	Vec2f pos2d = blob.getScreenPos();
	const u32 gameTime = getGameTime();
	const s32 unpackTime = blob.get_s32("release timer");

	if (unpackTime > gameTime)
	{
		// draw drop time progress bar
		const int top = pos2d.y - 1.0f * blob.getHeight();
		Vec2f dim(32.0f, 12.0f);
		const int secs = 1 + (unpackTime - gameTime) / getTicksASecond();
		Vec2f upperleft(pos2d.x - dim.x / 2, top - dim.y - dim.y);
		Vec2f lowerright(pos2d.x + dim.x / 2, top - dim.y);
		const f32 progress = 1.0f - (f32(secs) / f32(blob.get_s32("release secs")));
		GUI::DrawProgressBar(upperleft, lowerright, progress);
	}

	if (blob.isAttached())
	{
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");

		CBlob@ holder = point.getOccupied();
		if (holder is null || !holder.isMyPlayer()) return;

		CMap@ map = getMap();
		if (map is null) return;

		Vec2f space = blob.get_Vec2f("required space");
		Vec2f offsetPos = crate_getOffsetPos(blob, map);
		Vec2f aligned = getDriver().getScreenPosFromWorldPos(offsetPos);

		const f32 scalex = getDriver().getResolutionScaleFactor();
		const f32 zoom = getCamera().targetDistance * scalex;

		DrawSlots(space, aligned, zoom);

		for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
		{
			for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
			{
				Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
				Vec2f v = offsetPos + temp;
			
				if (map.isTileSolid(v) ||(map.getSectorAtPosition(v, "no build") !is null || hasNoBuildBlobs(v)))
				{
					GUI::DrawIcon("CrateSlots.png", 5, Vec2f(8, 8), aligned + (temp - Vec2f(0.5f, 0.5f)* map.tilesize) * 2 * zoom, zoom);
				}
			}
		}
	}
}

void DrawSlots(Vec2f size, Vec2f pos, const f32 zoom)
{
	const int x = Maths::Floor(size.x);
	const int y = Maths::Floor(size.y);
	CMap@ map = getMap();

	GUI::DrawRectangle(pos, pos + Vec2f(x, y) * map.tilesize * zoom * 2, SColor(125, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(0, 0) * map.tilesize * zoom * 2, pos + Vec2f(x, 0) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(x, 0) * map.tilesize * zoom * 2, pos + Vec2f(x, y) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(x, y) * map.tilesize * zoom * 2, pos + Vec2f(0, y) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(0, y) * map.tilesize * zoom * 2, pos + Vec2f(0, 0) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
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

void onTick(CSprite@ this) {
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (this !is null) {
		if (blob.getHealth() == 5.0f) {
			this.SetAnimation("default");
		} else if (blob.getHealth() >= 4.0f && blob.getHealth() < 5.0f) {
			this.SetAnimation("hp_75");
		} else if (blob.getHealth() >= 3.0f && blob.getHealth() < 4.0f) {
			this.SetAnimation("hp_50");
		} else if (blob.getHealth() >= 2.0f && blob.getHealth() < 3.0f) {
			this.SetAnimation("hp_25");
		} else if (blob.getHealth() >= 1.0f && blob.getHealth() < 23.0f) {
			this.SetAnimation("hp_5");
		}
	}

	// remove the lock
	if (blob.get_s32("release timer") != 0 && getGameTime() >= blob.get_s32("release timer")) {
		this.RemoveSpriteLayer("cage_lock");
	}
}