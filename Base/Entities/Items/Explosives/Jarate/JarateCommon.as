// JarateCommon.as
/*
    This script manages blobs, what has tag "peed".
    It increases damage gain to blob.
*/
#include "JarateHitCommon.as";
#include "MakeBangEffect.as";

const int peed_state_time = getTicksASecond() * 5; // 10 seconds

void onInit(CBlob@ this) {
	this.set_s32("peed time", peed_state_time);
}

void onTick(CBlob@ this) {
    // Player doesnt frozen - script not allowed to work
    if (!this.hasTag("peed")) return;

    if (this.hasTag("peed") && this.get_s32("peed time") > 0) {
        this.sub_s32("peed time", 1);
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