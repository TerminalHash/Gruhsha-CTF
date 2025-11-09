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
}

void onTick(CBlob@ this) {
    if (!this.hasTag("no shielding") && this.get_f32("shield health") <= 0.0f) {
     	this.Tag("no shielding");
		this.set_f32("shield health", 0.0f);
     	this.Sync("no shielding", true);
		this.Sync("shield health", true);
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
				this.Sync("shield health", true);
		} else if (customData == Hitters::sword && !this.hasTag("no shielding")) {
		    this.sub_f32("shield health", 0.5f);
			this.Sync("shield health", true);
        }
	}

    // every explosion hitter disables shielding mechanic for drill
    if (isExplosionHitter(customData) && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 1.0f);
		this.Sync("shield health", true);
    }

    if (isCustomExplosionHitter(customData) && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 1.0f);
		this.Sync("shield health", true);
    }

    if (customData == Hitters::builder && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 0.37f);
		this.Sync("shield health", true);
    }

    if (customData == Hitters::arrow && !this.hasTag("no shielding")) {
        this.sub_f32("shield health", 0.2f);
		this.Sync("shield health", true);
    }

	return damage;
}