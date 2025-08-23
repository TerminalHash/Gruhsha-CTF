// Saw logic

#include "Hitters.as"
#include "GenericButtonCommon.as"
#include "ParticleSparks.as"
#include "KnockedCommon.as"
#include "KnightCommon.as"
#include "ShieldCommon.as";
#include "TreeCommon.as"  // Waffle: Need tree vars

const string toggle_id = "toggle_power";
const string toggle_id_client = "toggle_power_client";
const string sawteammate_id_client = "sawteammate_client";

void onInit(CBlob@ this)
{
	this.Tag("saw");
	
	//this.getShape().SetRotationsAllowed(false);

	this.addCommandID(toggle_id);
	this.addCommandID(toggle_id_client);
	this.addCommandID(sawteammate_id_client);
	this.addCommandID("broke saw client");

	////////////////////////////////////////
	// code chunk picked from TrampolineLogic.as
	this.Tag("no falldamage");
	this.Tag("medium weight");
	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1 | key_action2);
	////////////////////////////////////////

	this.getCurrentScript().runFlags |= Script::tick_onscreen;

	SetSawOn(this, true);
}

bool onReceiveCreateData(CBlob@ this, CBitStream@ stream)
{
	//joining clients use correct sprite frames
	UpdateSprite(this);
	return true;
}

//toggling on/off

void SetSawOn(CBlob@ this, const bool on)
{
	this.set_bool("saw_on", on);
}

bool getSawOn(CBlob@ this)
{
	return this.get_bool("saw_on");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (caller.getTeamNum() != this.getTeamNum() || this.getDistanceTo(caller) > 16) return;

	if (this.hasTag("broken saw")) return;

	const string desc = getTranslatedString("Turn Saw " + (getSawOn(this) ? "Off" : "On"));
	caller.CreateGenericButton(8, Vec2f(0, 0), this, this.getCommandID(toggle_id), desc);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(sawteammate_id_client) && isClient())
	{
		CBlob@ tobeblended = getBlobByNetworkID(params.read_netid());
		if (tobeblended !is null)
		{
			CSprite@ s = tobeblended.getSprite();
			if (s !is null)
			{
				if (getRules().get_string("clusterfuck") != "off") {
					s.Gib();
				}
			}
		}

		this.getSprite().PlaySound("SawOther.ogg");
	}
	else if (cmd == this.getCommandID(toggle_id) && isServer())
	{
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ b = p.getBlob();
		if (b is null) return;

		// range check
		if (this.getDistanceTo(b) > 32) return;

		// team check
		if (this.getTeamNum() != b.getTeamNum()) return;

		SetSawOn(this, !getSawOn(this));

		CBitStream params;
		this.SendCommand(this.getCommandID(toggle_id_client), params);
	}
	else if (cmd == this.getCommandID(toggle_id_client) && isClient())
	{
		SetSawOn(this, !getSawOn(this));
		UpdateSprite(this);
	}
	
	if (cmd == this.getCommandID("broke saw client") && isClient()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ b = p.getBlob();
		if (b is null) return;
	
		if (this !is null && b !is null) {
			sparks(b.getPosition(), 180.0f - b.getOldVelocity().Angle(), 0.5f, 60.0f, 0.5f);
			this.getSprite().PlaySound("ShieldHit", 1.0f, 1.0f);
		}
	}
}

//function for blending things
void Blend(CBlob@ this, CBlob@ tobeblended)
{
	if (this is tobeblended || tobeblended.hasTag("sawed") ||
	        tobeblended.hasTag("invincible") || !getSawOn(this))
	{
		return;
	}

	tobeblended.Tag("sawed");

	if ((tobeblended.getName() == "waterbomb" || tobeblended.getName() == "bomb") && tobeblended.hasTag("activated"))
		return;

	//make plank from wooden stuff
	const string blobname = tobeblended.getName();
	if (blobname == "log")
	{
		if (isServer())
		{
			if (this is null) return;

			u8 team = this.getTeamNum();

			if (this !is null)
			{
				getRules().add_s32("teamwood" + team, 50);
				getRules().Sync("teamwood" + team, true);
			}
		}

		this.getSprite().PlaySound("SawLog.ogg");
	}
	else
	{
		this.getSprite().PlaySound("SawOther.ogg");
	}

	// on saw player or dead body - disable the saw
	if (
		(tobeblended.getPlayer() !is null || //player
		(tobeblended.hasTag("flesh"))) && //dead body
		tobeblended.getTeamNum() == this.getTeamNum()) //same team as saw
	{
		if (isServer())
		{
			// gib and play sound on client
			tobeblended.Tag("sawed");
			tobeblended.Sync("sawed", true);
			CBitStream params;
			params.write_netid(tobeblended.getNetworkID());
			this.SendCommand(this.getCommandID(sawteammate_id_client), params);

			// turn off the saw and update for client
			SetSawOn(this, !getSawOn(this));
			CBitStream params2;
			this.SendCommand(this.getCommandID(toggle_id_client), params2);
		}
	}
	
	CSprite@ s = tobeblended.getSprite();
	if (s !is null)
	{
		if (getRules().get_string("clusterfuck") != "off") {
			s.Gib();
		}
	}

	if (tobeblended !is null && tobeblended.getConfig() == "knight" && !tobeblended.hasTag("broken shield")) {
		KnightInfo@ knight;
		if (!tobeblended.get("knightInfo", @knight)) {
			return;
		}

		ShieldVars@ shieldVars = getShieldVars(tobeblended);
		if (shieldVars is null) return;

		bool shieldState = isShieldState(knight.state);

		if (shieldState) return;
	}

	//printf("Blend kill");
	//give no fucks about teamkilling
	tobeblended.server_SetHealth(-1.0f);
	tobeblended.server_Die();
}


bool canSaw(CBlob@ this, CBlob@ blob)
{
	if (blob.getRadius() >= this.getRadius() * 0.99f || blob.getShape().isStatic() ||
	        blob.hasTag("sawed") || blob.hasTag("invincible"))
	{
		return false;
	}

	const string name = blob.getName();
	if (
	    name == "migrant" ||
	    name == "wooden_door" ||
	    name == "mat_wood" ||
	    name == "tree_bushy" ||
	    name == "tree_pine" ||
	    (name == "mine" && blob.getTeamNum() == this.getTeamNum()))
	{
		return false;
	}

	//flesh blobs & mines have to be fed into the saw part
	if (blob.hasTag("flesh") || (name == "mine"))
	{
		Vec2f pos = this.getPosition();
		Vec2f bpos = blob.getPosition();

		Vec2f off = (bpos - pos);
		const f32 len = off.Normalize();

		const f32 dot = off * (Vec2f(0, -1).RotateBy(this.getAngleDegrees(), Vec2f()));

		// prevent teamkilling, we dont want them to leave so fast
		if (blob.getTeamNum() == this.getTeamNum()) return false;

		if (dot > 0.8f)
		{
			if (blob.hasTag("flesh") && isServer())
			{
				this.Tag("bloody");
				this.Sync("bloody", true);
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	return true;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null)
	{
		Blend(this, hitBlob);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("ignore_saw"))
	{
		return false;
	}
	
	return true;
}

// allow to block saws with drills
// FIX ME: epic sync problems, idk how fix that actually lol
/*f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	if (isServer()) {
		if (this !is null && hitterBlob !is null) {
			if (customData == Hitters::drill && 
				!this.hasTag("broken saw") && 
				this.getTeamNum() != hitterBlob.getTeamNum()
			) {
				// disable our saw immediately and block toggle for a some time
				SetSawOn(this, !getSawOn(this));
				UpdateSprite(this);

				setBrokenState(this);

				this.SendCommand(this.getCommandID("broke saw client"));
			}
		}
	}

	return damage;
}*/

void setBrokenState(CBlob@ this) {
	if (isServer()) {
		this.set_s32("broken saw timer", 60 * 30); // one minute
		this.Tag("broken saw");
		this.Sync("broken saw timer", true);
		this.Sync("broken saw", true);
	}
}

void setBrokenShieldState(CBlob@ blob) {
	if (isServer()) {
		blob.Tag("broken shield");
		blob.set_s32("broken shield timer", 5 * 30); // 5 seconds
		blob.Sync("broken shield", true);
		blob.Sync("broken shield timer", true);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    if (blob is null ||
            this.isAttached() || blob.isAttached() ||
            !getSawOn(this))
    {
        return;
    }

    if (canSaw(this, blob))
    {
        Vec2f pos = this.getPosition();
        Vec2f bpos = blob.getPosition();

		// knights with broken shield automatically have
		if (blob !is null && blob.getConfig() == "knight" && !blob.hasTag("broken shield")) {
			KnightInfo@ knight;
			if (!blob.get("knightInfo", @knight)) {
				return;
			}

			ShieldVars@ shieldVars = getShieldVars(blob);
			if (shieldVars is null) return;

			bool shieldState = isShieldState(knight.state);

			if (shieldState) {
				setBrokenShieldState(blob);

				Sound::Play("/Stun", bpos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);

				setKnocked(blob, 20);

				// i guess it will be rewrote to commands, need tests
				sparks(blob.getPosition(), 180.0f - blob.getOldVelocity().Angle(), 0.5f, 60.0f, 0.5f);
				this.getSprite().PlaySound("ShieldHit", 1.0f, 1.0f);

				// disable our saw immediately and block toggle for a some time
				SetSawOn(this, !getSawOn(this));
				UpdateSprite(this);

				setBrokenState(this);

				return;
			}
		}

        blob.server_SetHealth(-1);
        this.server_Hit(blob, bpos, bpos - pos, 0.0f, Hitters::saw);

		//printf("onCollision kill");
    }

	const string name = blob.getName();
    if ((name == "waterbomb" || name == "bomb") && blob.hasTag("activated"))
    {
        Vec2f oldVelocity = blob.getVelocity();
        // bombs very close to the top of the saw have a ratio of 0 and most of the rest has a ratio of 1 
        // using the old bomb position is slightly more reliable when bombs fall from above
        f32 ydiff = Maths::Max(this.getPosition().y - blob.getOldPosition().y + blob.getHeight(), 0.0f);
        f32 ratio = Maths::Clamp01(3.0f * (1.0f - ydiff/this.getHeight()));

        if (isServer())
        {
        	if (name == "waterbomb")
        	{
        		// hack; waterbombs have a mass of 200 (which gives them a special interaction with kegs)
        		// but it's annoying here so we're giving it same mass as normal bombs
        		blob.SetMass(20.0); 
        	}

			// momentally kill saw, if it's enemy's bomb
			if (name == "bomb" && blob.getTeamNum() != this.getTeamNum()) {
				this.server_Die();
				blob.server_Die();
			}

            // give a horizontal boost to the bombs coming from the top based on their original velocity
            f32 xboost = 60.0f * Maths::Clamp(oldVelocity.x / 8.0f, -1.0f, 1.0f) * (1.0f - ratio);

            // bear in mind bombs have custom physics that cap velocity *eventually*
            // this is hacky but gives enough of a nice short boost
            Vec2f newVelocity(
                // mostly random x position, but keep some horizontal momentum when coming from the top
                70.0f * ((float(XORRandom(100)) / 100.0f) - 0.5f) + xboost,
                // small vertical boost to bombs coming from the top, big boost with some randomness for the others
                -(Maths::Max(80.0f + XORRandom(30), 500.0f * ratio - XORRandom(300)))
            );
            
            // make some sparks that go towards the direction the bomb was headed towards
            sparks(blob.getPosition(), 180.0f - oldVelocity.Angle(), 0.5f, 60.0f, 0.5f);
            // make some sparks that go the opposite direction the bomb is going to go *horizontally*
            // this gives the nice feel that sparks were emitted from the collision point
            sparks(blob.getPosition(), newVelocity.Angle(), 2.0f, 20.0f, 3.0f);

            blob.setVelocity(Vec2f_zero);
            blob.AddForce(newVelocity);
            blob.set_Vec2f("bombnado velocity", newVelocity);
            blob.Sync("bombnado velocity", true);

            // shorten the fuse quite significantly by a semi-random amount
            const int fuseTicksLeft = blob.get_s32("bomb_timer") - getGameTime();
            blob.set_s32("bomb_timer", getGameTime() + Maths::Min(fuseTicksLeft / 3 + XORRandom(6), fuseTicksLeft));
            blob.Sync("bomb_timer", true);
        }

        if (isClient())
        {
            Vec2f newVelocity = blob.get_Vec2f("bombnado velocity");

            // play a hit sound with a pitch depending on some parameters for some audio clues
            const f32 typePitchBoost = ((name == "waterbomb") ? 0.25f : 0.0f);
            const f32 bottomHitPitchBoost = ratio * 0.06f;
            this.getSprite().PlaySound("ShieldHit", 1.0f, 1.07f + bottomHitPitchBoost + typePitchBoost);

            // make some sparks that go towards the direction the bomb was headed towards
            sparks(blob.getPosition(), 180.0f - oldVelocity.Angle(), 0.5f, 60.0f, 0.5f);
            // make some sparks that go the opposite direction the bomb is going to go *horizontally*
            // this gives the nice feel that sparks were emitted from the collision point
            sparks(blob.getPosition(), newVelocity.Angle(), 2.0f, 20.0f, 3.0f);
        }
    }
}

void UpdateSprite(CBlob@ this)
{
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();

		const u8 frame = getSawOn(this) ? 0 : 1;

		sprite.animation.frame = frame;

		CSpriteLayer@ back = sprite.getSpriteLayer("back");
		if (back !is null)
		{
			back.animation.frame = frame;
		}
		
		CSpriteLayer@ chop = sprite.getSpriteLayer("chop");
		if (chop !is null && this.hasTag("bloody") && !g_kidssafe)
		{
			chop.animation.frame = 1;
		}
	}
}

//only pickable by enemies if they are _under_ this
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (byBlob.getTeamNum() == this.getTeamNum() ||
	        byBlob.getPosition().y > this.getPosition().y + 4);
}

//sprite update
void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);

	CSpriteLayer@ chop = this.addSpriteLayer("chop", "/Saw.png", 16, 16);
	if (chop !is null)
	{
		Animation@ anim = chop.addAnimation("default", 0, false);
		anim.AddFrame(3);
		anim.AddFrame(7);
		chop.SetAnimation(anim);
		chop.SetRelativeZ(-1.0f);
	}

	CSpriteLayer@ back = this.addSpriteLayer("back", "/Saw.png", 24, 16);
	if (back !is null)
	{
		Animation@ anim = back.addAnimation("default", 0, false);
		anim.AddFrame(1);
		anim.AddFrame(3);
		back.SetAnimation(anim);
		back.SetRelativeZ(-5.0f);
	}
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetZ(this.isAttached() ? 10.0f : -10.0f);

	//spin saw blade
	CSpriteLayer@ chop = sprite.getSpriteLayer("chop");
	if (chop !is null && getSawOn(this))
	{
		chop.SetFacingLeft(false);

		Vec2f around(0.5f, -0.5f);
		chop.RotateBy(30.0f, around);
	}

	UpdateSprite(this);

	if (this.hasTag("broken saw")) {
		this.sub_s32("broken saw timer", 1);
		this.Sync("broken saw timer", true);

		if (this.get_s32("broken saw timer") <= 0) {
			this.Untag("broken saw");
			this.Sync("broken saw", true);
		}
	}

	// Waffle: Automatically chop trees behind the saw if they're fully grown
	if (this.getTickSinceCreated() % 15 == 0 && !this.isAttached() && getSawOn(this))
	{
		CMap@ map = getMap();
		if (map is null)
		{
			return;
		}

		CBlob@[] overlapping;
		Vec2f offset = Vec2f(this.getWidth(), this.getHeight()) / 3;
		map.getBlobsInBox(this.getPosition() - offset, this.getPosition() + offset, overlapping);
		for (u16 i = 0; i < overlapping.length(); i++)
		{
			CBlob@ blob = overlapping[i];
			if (blob !is null && blob.hasTag("tree"))
			{
				TreeVars vars;
				blob.get("TreeVars", vars);
				if (vars.max_height == vars.height && !blob.exists("cut_down_time"))
				{
					this.server_Hit(blob, blob.getPosition(), blob.getPosition() - this.getPosition(), 0.5f, Hitters::saw);
				}
			}
		}
	}

	//////////////////////////////////////////////
	// allow rotating for saws like trampolines
	// code chunk picked from TrampolineLogic.as
	CRules@ rules = getRules();
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();

	if (point.isKeyPressed(key_action2)) {
		// set angle to what was on previous tick
		angle = this.get_f32("old angle");
		this.setAngleDegrees(angle);
	} else if (point.isKeyPressed(key_action1)) {
		// rotate in 45 degree steps
		angle = Maths::Floor((angle - 67.5f) / 45) * 45;
		this.setAngleDegrees(-angle);
	} else {
		// follow cursor normally
		this.setAngleDegrees(-angle + 90);
	}

	this.set_f32("old angle", this.getAngleDegrees());
	////////////////////////////////////////
}
