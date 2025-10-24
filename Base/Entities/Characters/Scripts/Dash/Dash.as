/*
    Dash.as
    Mechanics of dashes for classes.
    
    TODO:
    - improve attack blocking for knights, it's sucks currently
    - check how it works on dedicated server
    - check for desyncs and fix them (or delete nahui this mechanic, if it's impossible)
    - tweak time variables for more good values
    - maybe make dynamic DASH_FORCE system (with values only below 250) for items?

    - disable damage from stomps after dashes and enable it after some time (use DASH_KNOCK_TICKS???)
    OR
    - decrease horizontal velocity for prevent powerful stomps
*/

#include "DashCommon.as"
#include "KnightCommon.as";
#include "KnockedCommon.as"
#include "BindingsCommon.as"

void onInit(CBlob@ this) {
    SyncDashTime(this, 0, 0, false);
    //SyncDashKeyTime(this, 0);
}

void onTick(CBlob@ this) {
    bool inair = (!this.isOnGround() && !this.isOnLadder());
    bool disable_debuff = this.get_bool("unblock attacks");

    // more powerful solution for attack blocking
    // checks for InAir state and disables any attacks via tag
    // also disable that debuff, if player already grounded and trying to defend yourself
    if (this !is null && this.getConfig() == "knight") {
        if (inair && this.get_bool("used dash") && !disable_debuff) {
            this.Tag("disabled attacks");
            this.Sync("disabled attacks", true);
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
        printf("Dash key is pressed");
        if (this !is null && getGameTime() > (this.get_u32("last_dash") + (DASH_COOLDOWN * 30))) {
            //printf("Player " + this.getPlayer().getUsername() + " is dashing!");

            // disable dashing, when knight or archer charging his attack
            // also block dashing while knight is trying to dash with gliding state
            if (this.getConfig() == "archer") {
                if (this.isKeyPressed(key_action1)) return;
            } else if (this.getConfig() == "knight") {
                KnightInfo@ knight;
                if (!this.get("knightInfo", @knight)) {
                    return;
                }

                if (this.isKeyPressed(key_action1)) return;
                if (knight.state == KnightStates::shieldgliding) return;
            }

            // disallow dashing with items in hands
            CBlob@ carriedBlob = this.getCarriedBlob();
            if (carriedBlob !is null && !disallowedItemsWhileDashing (this, carriedBlob)) return;

            // DASH!
            if (this !is null && this.isMyPlayer()) {
                Vec2f dashforce = this.getAimPos() - this.getPosition();
                dashforce.Normalize();
                this.AddForce(dashforce * DASH_FORCE);

                SyncDashTime(this, getGameTime(), DASH_COOLDOWN * getTicksASecond(), true);
            }
        }
    }
}