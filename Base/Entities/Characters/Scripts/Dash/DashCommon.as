// DashCommom.as
const s32 DASH_FORCE = 225.0;

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

void SyncDashTime(CBlob@ this, u32 last_dash_time, u32 dash_cooldown_time, bool used_dash) {
    if (this is null) return;

    //printf("Syncing last dash time, wait...");
    if (isServer()) {
        this.set_u32("last_dash", last_dash_time);
        this.Sync("last_dash", true);

        this.set_u32("dash cooldown time", dash_cooldown_time);
        this.Sync("dash cooldown time", true);

        this.set_bool("used dash", used_dash);
        this.Sync("used dash", true);
        
        this.set_bool("unblock attacks", false);
        this.Sync("unblock attacks", true);
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