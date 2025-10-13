// DashCommom.as
const s32 DASH_FORCE = 250.0;

// time in seconds!!!
const s32 DASH_COOLDOWN = 5;
const s32 DASH_MAGIC_NUMBER = 30;
const s32 DASH_KNOCK_TICKS = 20;

string[] disallowed_items = {
	"keg",
	"hazelnut",
	"fumokeg",
	"crate",
	"airdropcrate",
	"ctf_flag",
	"chicken"
};

void SyncDashTime(CBlob@ this, u32 last_dash_time) {
    if (this is null) return;

    printf("Syncing last dash time, wait...");
    if (isServer()) {
        this.set_u32("last_dash", last_dash_time);
        this.Sync("last_dash", true);

        if (this.getConfig() == "knight") {
            this.set_bool("used dash", true);
            this.Sync("used dash", true);
        }
    }
}

/*
void SyncDashKeyTime(CBlob@ this, u32 last_key_press_time) {
    printf("Syncing last key press time, wait...");
    if (isServer()) {
        this.set_u32("dash_key_pressed_time", last_key_press_time);
        this.Sync("dash_key_pressed_time", true);
    }
}
*/

// some items will be dropped or block dashing before player dashes into nothing
// other items allowed to be in hands while player dashing by default
bool disallowedItemsWhileDashing (CBlob@ this, CBlob@ item) {
    CBlob@ carried = this.getCarriedBlob();

    if (this !is null && carried !is null) {
        for (int i = 0; i < disallowed_items.length; i++) {
            string item_blob = disallowed_items[i];
            
            if (item.getConfig() == item_blob) return false;
        }
    }

    return true;
}