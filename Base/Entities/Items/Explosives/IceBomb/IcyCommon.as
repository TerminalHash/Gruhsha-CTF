// IcyCommon.as
/*
    This script manages blobs, what has tag "icy".
    What freezing is doing for now:

    CLASS             CHANGE
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    All               Decreasing walk speed, decreasing jump height
    Archer            Grapple throw speed decreased by half
    Builder           Increasing build delay
    Knight            Literally cant slide on shield

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    For some changes (like build delay), you need a check other scripts:
    <class>Logic.as
    <class>Common.as
    PlacementCommon.as
*/

#include "FireCommon.as";

const int icy_state_time = getTicksASecond() * 10; // 10 seconds

void onInit(CBlob@ this) {
	this.set_s32("icy time", icy_state_time);
}

void onTick(CBlob@ this) {
    // Player doesnt frozen - script not allowed to work
    if (!this.hasTag("icy")) return;

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