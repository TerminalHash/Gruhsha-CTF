// Killsounds.as
/*
    Play special sound after kill victim with some player.
*/

#include "pathway.as";

string soundsdir = getPath();
string kill_sound = soundsdir + "Sounds/Killsounds/";

void onBlobDie(CRules@ this, CBlob@ blob) {
    if (this.get_string("killsounds_toggle") != "on") return;

    if (blob !is null) {
        CPlayer@ killer = blob.getPlayerOfRecentDamage();
        CPlayer@ victim = blob.getPlayer();

        if (victim !is null) {
            if (killer !is null) { //requires victim so that killing trees matters
                if (killer.getUsername() == "H1996R") {
                   killer.getBlob().getSprite().PlaySound(kill_sound + "hahalios_kill_sound" + ".ogg", 1.0f);
                }
            }
        }
    }
}
