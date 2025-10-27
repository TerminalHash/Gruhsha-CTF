/*
    Dash.as
    Mechanics of dashes for classes.

    TODO:
    - maybe make dynamic DASH_FORCE system (with values only below 250) for items?
    - enable tag "disabled attacks" after jumping on trampoline from hights
    - add indication of cooldown for enemies with setting for toggle it
*/

#include "DashCommon.as"
#include "KnightCommon.as";
#include "KnockedCommon.as"
#include "BindingsCommon.as"

void onInit(CBlob@ this) {
    this.addCommandID("sync dash values");
    SyncDashTime(this, -1, -1, false);
}

void onTick(CBlob@ this) {
    bool inair = (!this.isOnGround() && !this.isOnLadder());
    bool disable_debuff = this.get_bool("unblock attacks");

    // more powerful solution for attack blocking
    // checks for InAir state and disables any attacks via tag
    // also disable that debuff, if player already grounded and trying to defend yourself
    if (this !is null && this.getConfig() != "archer") {
        if (inair && this.get_bool("used dash") && !disable_debuff) {
            this.Tag("disabled attacks");
            this.Sync("disabled attacks", true);
        }

        // HACK: return special tag after jumping on trampoline
        // if we dont do this, player would be available to glide and attack
        if (!this.hasTag("disabled attacks")) {
            if (getGameTime() >= this.get_s32("trampodash") + 20 && this.get_s32("trampodash") != -1) {
                this.Tag("disabled attacks");
                this.Sync("disabled attacks", true);
            
                this.set_s32("trampodash", -1);
            }
        }

        if (!inair && disable_debuff) {
            this.Untag("disabled attacks");
            this.Sync("disabled attacks", true);
        }

        if (!inair && !disable_debuff && this.get_bool("used dash")) {
            this.set_bool("unblock attacks", true);
            this.Sync("unblock attacks", true);
        }
    }

    // reset dash state for the player, he can use dashes now
    if (this !is null && getGameTime() == (this.get_u32("last_dash") + (DASH_COOLDOWN * 30))) {
        this.set_bool("used dash", false);
        this.Sync("used dash", true);

        this.Untag("disabled attacks");
        this.Sync("disabled attacks", true);

        this.set_bool("unblock attacks", false);
        this.Sync("unblock attacks", true);
    }

    // drop carried blob after some time, if it's our restricted blob
    if (this !is null && getGameTime() == (this.get_u32("last_dash") + DASH_KNOCK_TICKS)) {
        CBlob@ carriedBlob = this.getCarriedBlob();
        if (carriedBlob !is null && !disallowedItemsWhileDashing (this, carriedBlob)) {
            this.DropCarried();
        }
    }

    if (this.get_bool("used dash")) {
        this.sub_u32("dash cooldown time", 1);
        this.Sync("dash cooldown time", true);
    }

    if (b_KeyJustPressed("dash_keybind")) {
        //printf("Dash key is pressed");
        if (this !is null && getGameTime() > (this.get_u32("last_dash") + (DASH_COOLDOWN * 30))) {
            //printf("Player " + this.getPlayer().getUsername() + " is dashing!");

            // disable dashing, when knight or archer charging his attack
            // also block dashing while knight is trying to dash with gliding state
            // also clear selected block/tool for builder
            if (this.getConfig() == "archer") {
                if (this.isKeyPressed(key_action1)) return;
            } else if (this.getConfig() == "knight") {
                KnightInfo@ knight;
                if (!this.get("knightInfo", @knight)) {
                    return;
                }

                if (this.isKeyPressed(key_action1)) return;
                if (knight.state == KnightStates::shieldgliding) return;
            } else if (this.getConfig() == "builder") {
                this.set_u8("bunnie_tile", 255);

                CBitStream kekrams;
                kekrams.write_u8(255);
                this.SendCommand(this.getCommandID("tool clear"));
            }

            // disallow dashing with items in hands
            CBlob@ carriedBlob = this.getCarriedBlob();
            if (carriedBlob !is null && !disallowedItemsWhileDashing (this, carriedBlob)) return;

            // DASH!
            if (this !is null && this.isMyPlayer()) {
                Vec2f dashforce = this.getAimPos() - this.getPosition();
                dashforce.Normalize();
                this.AddForce(dashforce * DASH_FORCE);

                CBitStream params;
			    params.write_u32(getGameTime());
                params.write_u32(DASH_COOLDOWN);
                params.write_bool(true);
			    this.SendCommand(this.getCommandID("sync dash values"), params);
            }
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) {
	if (cmd == this.getCommandID("sync dash values") && isServer()) {
        //printf("SERVER COMMAND");
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;

		u32 dash_time;
		if (!params.saferead_u32(dash_time)) return;

        u32 dash_cooldown_time;
		if (!params.saferead_u32(dash_cooldown_time)) return;

        bool isDashUsed;
        if (!params.saferead_bool(isDashUsed)) return;

		SyncDashTime(caller, dash_time, dash_cooldown_time * getTicksASecond(), isDashUsed);
	}
}