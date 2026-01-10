// Killsounds.as
/*
    Play special sound after kill victim with some player.
*/

#include "pathway.as";

string soundsdir = getPath();
string kill_sound = soundsdir + "Sounds/Killsounds/";

void onBlobDie(CRules@ this, CBlob@ blob) {
    if (this.get_string("killsounds_toggle") != "on") return;

    if (blob is null) return;

    if (blob !is null) {
        CPlayer@ killer = blob.getPlayerOfRecentDamage();
        if (killer is null) return;

        CPlayer@ victim = blob.getPlayer();
        if (victim is null) return;

        CBlob@ killerBlob = killer.getBlob();
        if (killerBlob is null) return;

        CSprite@ killerSprite = killerBlob.getSprite();
        if (killerSprite is null) return;

        if (victim !is null) {
            // requires victim so that killing trees matters
            // also it shouldnt be played, when killer commits suicide
            if (killer !is null && killerBlob !is null && victim.getUsername() != killer.getUsername()) {
                if (killer.getUsername() == "H1996R") {
                   killerSprite.PlaySound(kill_sound + "hahalios_kill_sound" + ".ogg", 1.0f);
                } else if (killer.getUsername() == "TerminalHash") {
                   killerSprite.PlaySound(kill_sound + "th_kill_sound" + ".ogg", 1.0f);
                }
            }
        }
    }
}
