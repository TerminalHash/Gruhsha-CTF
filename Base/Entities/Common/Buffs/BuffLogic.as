// BuffLogic.as

#include "FireCommon.as";
#include "JarateHitCommon.as";
#include "MakeBangEffect.as";

const int icy_state_time = getTicksASecond() * 10; // 10 seconds
const int peed_state_time = getTicksASecond() * 5; // 5 seconds

void onInit(CBlob@ this) {
	this.set_s32("icy time", icy_state_time);
	this.set_s32("peed time", peed_state_time);
}

void onTick(CBlob@ this) {
    if (this.hasTag("icy") && this.get_s32("icy time") > 0) {
        if (this.hasTag(burning_tag) || this.hasTag("immune from icy")) {
            this.sub_s32("icy time", 2);
        } else {
            this.sub_s32("icy time", 1);
        }

        //printf("current time " + this.get_s32("icy time"));

        // Imitation of slow down via player's mass increasing
        this.SetMass(140.0);
    } else if (this.hasTag("icy") && this.get_s32("icy time") <= 0) {
        // Reset timer
		this.set_s32("icy time", icy_state_time);

        // Restore player's normal mass
        this.SetMass(68.0);

        // Untag player, he's warmed up
        this.Untag("icy");
        //this.Sync("icy", true);
    }

    // ######################################### \\

    if (this.hasTag("peed") && this.get_s32("peed time") > 0) {
        this.sub_s32("peed time", 1);
        
        //printf("current time " + this.get_s32("peed time"));
    } else if (this.hasTag("peed") && this.get_s32("peed time") <= 0) {
        // Reset timer
		this.set_s32("peed time", peed_state_time);

        // Untag player, he's warmed up
        this.Untag("peed");
    }
}

// CLIENT
// play sound and make MINICRIT text effect as in Team Fortess 2
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	if (DoublingDamageHitters(customData)) {
		if (this !is null && hitterBlob !is null && this.hasTag("player") && this.hasTag("peed") && isClient()) {
            MakeBangEffect(this, "minicrit" + (XORRandom(2) + 1), Maths::Max(16, this.getRadius())/20, true);
            this.getSprite().PlaySound("minicrit" + (XORRandom(5) + 1) + ".ogg", 2.0);
		}
	}

	return damage; 
}

// Logic for some items
void onAddToInventory(CBlob@ this, CBlob@ blob) {
    if (!isServer()) return;

	if (blob !is null && this !is null && this.hasTag("player")) {
        if (blob.getConfig() == "lantern") {
            this.Tag("immune from icy");
        }
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob) {
    if (!isServer()) return;

	if (blob !is null && this !is null && this.hasTag("player")) {
        if (blob.getConfig() == "lantern") {
            this.Untag("immune from icy");
        }
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) {
    if (!isServer()) return;

    if (this !is null && attached !is null) {
        if (attached.getConfig() == "lantern") {
            this.Tag("immune from icy");
        }
    }
}

void onDetach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) {
    if (!isServer()) return;

    if (this !is null && attached !is null) {
        if (attached.getConfig() == "lantern") {
            this.Untag("immune from icy");
        }
    }
}
