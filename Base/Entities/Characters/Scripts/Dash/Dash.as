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
    SyncDashTime(this, 0);
    //SyncDashKeyTime(this, 0);
}

void onTick(CBlob@ this) {
    // set special boolean for forcing normal state
    if (this !is null && getGameTime() > (this.get_u32("last_dash") + DASH_MAGIC_NUMBER)) {
        if (this.getConfig() == "knight") {
            this.set_bool("used dash", false);
            this.Sync("used dash", true);
        }
    }

    // drop carried blob after some time, if it's our restricted blob
    if (this !is null && getGameTime() == (this.get_u32("last_dash") + DASH_KNOCK_TICKS)) {
        CBlob@ carriedBlob = this.getCarriedBlob();
        if (carriedBlob !is null && !disallowedItemsWhileDashing (this, carriedBlob)) {
            this.DropCarried();
        }

        // FIXME: erzats block for attacks via knock
        //setKnocked(this, 10);
    }

    if (b_KeyJustPressed("dash_keybind")) {
        printf("Dash key is pressed");
        if (this !is null && getGameTime() > (this.get_u32("last_dash") + (DASH_COOLDOWN * 30))) {
            printf("Player " + this.getPlayer().getUsername() + " is dashing!");

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

                SyncDashTime(this, getGameTime());
            }
        }
    }
}