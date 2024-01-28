// SoundCommands.as
/*
	Система звуковых команд.
	Воспроизводит различные звуки, если написан тот или иной текст.
*/

#include "RulesCore.as";
#include "pathway.as";

// Utility
#include "IdentifyPlayer.as";

string soundsdir = getPath();
string soundrandom = soundsdir + "Sounds/Random/";

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	bool soundplayed = false;
	CPlayer@ localplayer = getLocalPlayer();
	bool player_is_sounds_muted = this.get_bool(player.getUsername() + "is_sounds_muted");
	u32 time_since_last_sound_use = getGameTime() - this.get_u32(player.getUsername() + "lastsoundplayedtime");
	u32 soundcooldown = this.get_u32(player.getUsername() + "soundcooldown");

	// player needs to be alive, can be heard by anyone
	CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }

	Vec2f pos = blob.getPosition();
	
	if (player_is_sounds_muted == false && time_since_last_sound_use >= soundcooldown)
		{
			// Sound list with matching text
			if (textIn == "TUTURU" || textIn == "Tuturu!" || textIn == "tuturu" || textIn == "Tuturu" || textIn == "TU TU RU" || textIn == "tu tu ru" || textIn == "tutturu")
			{
				int random = XORRandom(9) + 1;
				Sound::Play(soundrandom + "Tuturu" + random + ".ogg", pos);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (textIn == "poggers" || textIn == "POGGERS" || textIn == "pog")
			{
				Sound::Play(soundrandom + "poggers.ogg", pos);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (textIn.find("sus", 0) != -1)
			{
				Sound::Play(soundrandom + "sus.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
		}
	return true;
}
