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
	bool localplayer_is_deaf = this.get_bool(localplayer.getUsername() + "is_deaf");
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
			if (textIn.toUpper() == "TUTURU" || textIn.toUpper() == "TUTURU!"  || textIn.toUpper() == "TU TU RU" || textIn.toUpper() == "TUTTURU") {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(9) + 1;
					Sound::Play(soundrandom + "Tuturu" + random + ".ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "POG" || textIn.toUpper() == "POGGERS") {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "poggers.ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper().find("SUS", 0) != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "sus.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "BRUH" || textIn.toUpper() == ("БРУХ") || textIn.toUpper() == ("БРАХ")) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "bruh.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn == ("оуе") || textIn == ("oue") || textIn == ("ohyea") || textIn == ("ohyeah") || textIn.find("оу", 0) != -1 && textIn.find("е", 0) != -1 || textIn.find("оу", 0) != -1 && textIn.find("еe", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yea", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yeah", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEAH", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEA", 0) != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "oue.ogg", pos, 0.8f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper() == "KURWA" || textIn == "курва") {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(8) + 1;
					Sound::Play(soundrandom + "kurwa" + random + ".ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);


			} else if (textIn.toUpper() == "YEP" || textIn.toUpper() == "YOP"  || textIn == "дап" || textIn == "Дап") {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(5) + 1;
					Sound::Play(soundrandom + "yep" + random + ".ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "NOPE" || textIn == ("ноуп") || textIn == ("Ноуп")) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "nope.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);

			// russian sounds
			} else if (textIn == "пенек" || textIn == "пенёк" || textIn == "косарь" || textIn == "penek" || textIn.find("на", 0) != -1 && textIn.find("пенек", 0) != -1 || textIn.find("на", 0) != -1 && textIn.find("пенёк", 0) != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "penek.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("БЛЯЯ") != -1 || textIn.toUpper().findFirst("BLYAA") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "blyat.ogg", pos, 1.2f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("курлык") != -1 || textIn.toUpper().findFirst("KURLIK") != -1 || textIn.toUpper().findFirst("KURLYK") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "kurlik.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("снайп") != -1 || textIn == ("sniped")) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "snipe.ogg", pos, 0.7f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == ("трипл") || textIn == ("triple")) {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "triple" + random + ".ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("хуительн") != -1 && textIn.findFirst("истори") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "history.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("гиляторн") != -1 && textIn.findFirst("пушк") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "pushka.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("на") != -1 && (textIn.findFirst("ушко") != -1 || textIn.findFirst("ущко") != -1 )) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "ushko-pushka.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("легенд") != -1 && textIn.findFirst("битв") != -1 || textIn.toUpper().findFirst("legend") != -1 && textIn.toUpper().findFirst("battl") != -1 ) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "legend.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("немогу") != -1 || (textIn.findFirst("да") != -1) && textIn.findFirst("блять") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "dablyat.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("новой") != -1 || textIn.findFirst("всё хуйня") != -1 || textIn.findFirst("кусака блять") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "misha.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("похлопаю") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "pohlopau.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("ладно") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "nyladno.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("бред") != -1 || textIn.findFirst("врёшь") != -1 || textIn.findFirst("врешь") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "bredish.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("ёбаный") != -1 || textIn.findFirst("ебаный") != -1) {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "ebanrot" + random + ".ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}  else if (textIn == ("ай") || textIn == ("ai") || textIn == ("ah")) {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "ai" + random + ".ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn == ("ой") || textIn == ("oi") || textIn == ("oh")) {
				if (localplayer_is_deaf == false)
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "oi" + random + ".ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn.findFirst("афк") != -1 || textIn.findFirst("afk") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "afk.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn.findFirst("хехе") != -1 || textIn.findFirst("hehe") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "hehe.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn.find("айяй") != -1 || textIn.find("ahoh") != -1 || textIn.find("aiyai") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "aiyai.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn.toUpper().find("auf") != -1 || textIn.find("ауф") != -1 || textIn.find("АУФ") != -1) {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "auf.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				} else if (textIn == "ЛОШАДИНЫЙ ХУЙ ЖАРА ИЮЛЬ") {
				if (localplayer_is_deaf == false)
				{
					Sound::Play(soundrandom + "loshadinyuhui.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
				}
		}
	return true;
}
