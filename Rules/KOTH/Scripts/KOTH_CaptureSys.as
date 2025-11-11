// KOTH_CaptureSys.as
/*
    Capture system for KOTH gamemode.
    Based on Team Fortress 2 rules of this mode.

    Default timer for cap is five minutes.
*/
#include "KOTH_Common.as"

void onInit (CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    // timers
    this.set_s32("control_timer_blue", cp_control_time);
    this.set_s32("control_timer_red", cp_control_time);

    // capture related
    this.set_bool("blue_on_cp",           false);
    this.set_bool("red_on_cp",            false);
    this.set_bool("cp_controlled_blue",   false);
    this.set_bool("cp_controlled_red",    false);
    this.set_bool("koth_stalemate",       false);
}

void onTick(CRules@ this) {
    bool BlueCP = getRules().get_bool("blue_on_cp");
    bool RedCP = getRules().get_bool("red_on_cp");
    bool isControlPointCappedByBlue = getRules().get_bool("cp_controlled_blue");
    bool isControlPointCappedByRed = getRules().get_bool("cp_controlled_red");
    bool isStalemate = getRules().get_bool("koth_stalemate");

    // King of the Hill (KOTH) Mechanic
    // If our current gamemode is KOTH, it will enable timer
    // if (GetGamemode(this) == "KOTH")
    if (isControlPointCappedByBlue) {
        if (this.get_s32("control_timer_blue") > 0) {
            this.sub_s32("control_timer_blue", 1);
            this.Sync("control_timer_blue", true);
        }
    } else if (isControlPointCappedByRed) {
        if (this.get_s32("control_timer_red") > 0) {
            this.sub_s32("control_timer_red", 1);
            this.Sync("control_timer_red", true);
        }
    }
    //}

    // DEBUG
    if (getLocalPlayer() is null) return;
    if (getLocalPlayer().getUsername() == "TerminalHash") {
        if (getControls().isKeyJustReleased(KEY_NUMPAD5)) {
            printf("--===============================--");
            printf("STATUS OF BOOLEANS");
            printf(" ");
            printf("Blue on CP: " + this.get_bool("blue_on_cp"));
            printf("Red on CP: " + this.get_bool("red_on_cp"));
            printf("CP is controlled by Blue: " + this.get_bool("cp_controlled_blue"));
            printf("CP is controlled by Red: " + this.get_bool("cp_controlled_red"));
            printf("Stalemate status: " + this.get_bool("koth_stalemate"));
            printf("-- -- -- -- -- -- -- --");
            printf("TIMERS");
            printf(" ");
            printf("Control timer BLUE: " + this.get_s32("control_timer_blue"));
            printf("Control timer RED: " + this.get_s32("control_timer_red"));
        }
    }
}
