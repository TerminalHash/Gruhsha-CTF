/* 
    DrillShield.as
   	shielding with drill is available **only** for builders
	it sounds like imbalanced shit i guess, but whatever

	max hit count for that "shield":
	-- -- -- -- -- -- -- -- -- -- -- -- -- --
	HITTER				HITS
	-- -- -- -- -- -- -- -- -- -- -- -- -- --
	Slash				2
	Jab					5
	Pickaxe				3
	Arrow				5
	Explosion			1
*/

#include "ShieldCommon.as";
#include "KnightCommon.as";
#include "Hitters.as";
#include "GruhshaHitters.as";

// shield things
const f32 drill_shield_health = 1.0f;

void onInit(CBlob@ this) {
	this.set_f32("shield health", drill_shield_health);

	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
}

void onTick(CBlob@ this) {
    ShieldVars@ shieldVars = getShieldVars(this);
    if (shieldVars is null) return;

	if (this.isAttachedToPoint("PICKUP")) {
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null || holder.isAttached()) return;

	    Vec2f pos = holder.getPosition();
	    Vec2f vel = holder.getVelocity();
	    Vec2f aimpos = holder.getAimPos();

        Vec2f vec;
	    const int direction = holder.getAimDirection(aimpos);
	    const f32 side = (holder.isFacingLeft() ? 1.0f : -1.0f);
	    bool walking = (holder.isKeyPressed(key_left) || holder.isKeyPressed(key_right));

		if (holder.getConfig() == "builder" && !this.hasTag("no shielding")) {
            setShieldEnabled(this, true);
            setShieldAngle(this, SHIELD_BLOCK_ANGLE);

            int horiz = this.isFacingLeft() ? -1 : 1;

		    if (walking) {
			    if (direction == 0) { //forward
			    	setShieldDirection(this, Vec2f(horiz, 0));
			    } else if (direction == 1) {   //down
			    	setShieldDirection(this, Vec2f(horiz, 3));
			    } else {
			    	setShieldDirection(this, Vec2f(horiz, -3));
			    }
		    } else {
			    if (direction == 0) {   //forward
			    	setShieldDirection(this, Vec2f(horiz, 0));
			    } else if (direction == 1) {   //down
			    	setShieldDirection(this, Vec2f(horiz, 3));
			    } else { //up
				    if (vec.y < -0.97) {
				    	setShieldDirection(this, Vec2f(0, -1));
				    } else {
				    	setShieldDirection(this, Vec2f(horiz, -3));
				    }
			    }
		    }
        }
    }

    if (!this.hasTag("no shielding") && this.get_f32("shield health") <= 0.0f) {
        this.Tag("no shielding");
        this.Sync("no shielding", true);

        setShieldEnabled(this, false);
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	// just formality - put that condition under special check
	if (hitterBlob !is null && hitterBlob.getConfig() == "knight") {
		KnightInfo@ knight;
		if (!hitterBlob.get("knightInfo", @knight)) {
			return damage;
		}

		if (customData == Hitters::sword &&
	    	    (
	    	        knight.state == KnightStates::sword_cut_mid ||
	    	        knight.state == KnightStates::sword_cut_mid_down ||
	    	        knight.state == KnightStates::sword_cut_up ||
	    	        knight.state == KnightStates::sword_cut_down
	    	    ) &&
            !this.hasTag("no shielding")
			) {
				this.sub_f32("shield health", 0.2f);
		} else if (customData == Hitters::sword && !this.hasTag("no shielding")) {
		    this.sub_f32("shield health", 0.5f);
        }
	}

    // every explosion hitter disables shielding mechanic for drill
    if (isExplosionHitter(customData) && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 1.0f);
    }

    if (isCustomExplosionHitter(customData) && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 1.0f);
    }

    if (customData == Hitters::builder && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 0.37f);
    }

    if (customData == Hitters::arrow && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 0.2f);
    }

	return damage;
}

void onDetach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ) {
    ShieldVars@ shieldVars = getShieldVars(this);
    if (shieldVars is null) return;

	setShieldEnabled(attached, false);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob ) {
	ShieldVars@ shieldVars = getShieldVars(this);
    if (shieldVars is null) return;

	setShieldEnabled(this, false);
}