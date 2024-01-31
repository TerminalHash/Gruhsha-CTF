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

			// english sounds
			if (textIn == "TUTURU" || textIn == "Tuturu!" || textIn == "tuturu" || textIn == "Tuturu" || textIn == "TU TU RU" || textIn == "tu tu ru" || textIn == "tutturu")
			{
				int random = XORRandom(9) + 1;
				Sound::Play(soundrandom + "Tuturu" + random + ".ogg", pos);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
			else if (textIn == "poggers" || textIn == "POGGERS" || textIn == "pog")
			{
				Sound::Play(soundrandom + "poggers.ogg", pos);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("sus", 0) != -1)
			{
				Sound::Play(soundrandom + "sus.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (textIn == ("bruh") || textIn == ("брух") || textIn == ("брах"))
			{
				Sound::Play(soundrandom + "bruh.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (textIn == ("оуе") || textIn == ("oue") || textIn == ("ohyea") || textIn == ("ohyeah") || textIn.find("оу", 0) != -1 && textIn.find("е", 0) != -1 || textIn.find("оу", 0) != -1 && textIn.find("еe", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yea", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yeah", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEAH", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEA", 0) != -1)
			{
				Sound::Play(soundrandom + "oue.ogg", pos, 0.8f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}

			// russian sounds
			else if (textIn == "пенек" || textIn == "пенёк" || textIn == "косарь" || textIn == "penek" || textIn.find("на", 0) != -1 && textIn.find("пенек", 0) != -1 || textIn.find("на", 0) != -1 && textIn.find("пенёк", 0) != -1)
			{
				Sound::Play(soundrandom + "penek.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn == "БЛЯЯЯЯЯЯЯЯЯ" || textIn == "БЛЯЯЯЯЯЯЯЯ" || textIn == "БЛЯЯЯЯЯЯЯ" || textIn == "БЛЯЯЯЯЯЯ" || textIn == "БЛЯЯЯЯЯ" || textIn == "БЛЯЯЯЯ")
			{
				Sound::Play(soundrandom + "blyat.ogg", pos, 1.2f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn == ("курлык") || textIn == ("kurlik") || textIn == ("kurluk") || textIn == ("kurlyk") || textIn == ("курлык-курлык") || textIn.find("курлык", 0) != -1 && textIn.find("курлык", 0) != -1)
			{
				Sound::Play(soundrandom + "kurlik.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn == ("ЗАСНАЙПИЛИ"))
			{
				Sound::Play(soundrandom + "snipe.ogg", pos, 0.7f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn == ("трипл") || textIn == ("triple"))
			{
				Sound::Play(soundrandom + "triple.ogg", pos, 0.7f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("охуительная", 0) != -1 && textIn.find("история", 0) != -1 || textIn.find("охуительные", 0) != -1 && textIn.find("истории", 0) != -1)
			{
				Sound::Play(soundrandom + "history.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("аннигиляторная", 0) != -1 && textIn.find("пушка", 0) != -1 || textIn.find("анигиляторная", 0) != -1 && textIn.find("пушка", 0) != -1 || textIn == ("пушка"))
			{
				Sound::Play(soundrandom + "pushka.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("на", 0) != -1 && textIn.find("ушко", 0) != -1 || textIn.find("на", 0) != -1 && textIn.find("ущко", 0) != -1 )
			{
				Sound::Play(soundrandom + "ushko-pushka.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("легендарная", 0) != -1 && textIn.find("битва", 0) != -1 || textIn.find("legend", 0) != -1 && textIn.find("battle", 0) != -1 )
			{
				Sound::Play(soundrandom + "legend.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn == "немогу" || textIn == "даблять" || textIn == "даблядь" || textIn.find("да", 0) != -1 && textIn.find("блядь", 0) != -1 || textIn.find("я", 0) != -1 && textIn.find("не", 0) != -1 && textIn.find("могу", 0) != -1 || textIn.find("да", 0) != -1 && textIn.find("блять", 0) != -1)
			{
				Sound::Play(soundrandom + "dablyat.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
			else if (textIn.find("давай", 0) != -1 && textIn.find("по", 0) != -1 || textIn.find("новой", 0) != -1 || textIn.find("по", 0) != -1 && textIn.find("новой", 0) != -1 || textIn.find("новую", 0) != -1)
			{
				Sound::Play(soundrandom + "misha.ogg", pos, 1.0f);

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}
		}
	return true;
}
