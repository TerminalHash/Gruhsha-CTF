// SoundCommands.as
/*
	Система звуковых команд.
	Воспроизводит различные звуки, если написан тот или иной текст.
*/

#include "RulesCore.as";
#include "pathway.as";

string soundsdir = getPath();
string soundrandom = soundsdir + "Sounds/Voicelines/";

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	bool soundplayed = false;
	CPlayer@ localplayer = getLocalPlayer();
	bool localplayer_is_deaf = this.get_bool(localplayer.getUsername() + "is_deaf");
	bool player_is_sounds_muted = this.get_bool(player.getUsername() + "is_sounds_muted");
	u32 time_since_last_sound_use = getGameTime() - this.get_u32(player.getUsername() + "lastsoundplayedtime");
	u32 soundcooldown = this.get_u32(player.getUsername() + "soundcooldown");

	string annoying_voicelines_sounds = getRules().get_string("annoying_voicelines");

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
			if (textIn.toUpper().find("SUS", 0) != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "sus.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "BRUH" || textIn.toUpper() == ("БРУХ") || textIn.toUpper() == ("БРАХ")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "bruh.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == ("оуе") || textIn == ("oue") || textIn == ("ohyea") || textIn == ("ohyeah") || textIn.find("оу", 0) != -1 && textIn.find("е", 0) != -1 || textIn.find("оу", 0) != -1 && textIn.find("еe", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yea", 0) != -1 || textIn.find("oh", 0) != -1 && textIn.find("yeah", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEAH", 0) != -1 || textIn.find("OH", 0) != -1 && textIn.find("YEA", 0) != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "oue.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper() == "KURWA" || textIn == "курва") {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(11) + 1;
					Sound::Play(soundrandom + "kurwa" + random + ".ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);


			} else if (textIn.findFirst("афк") != -1 || textIn.findFirst("afk") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "afk.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);

			} else if (textIn.toUpper() == "KURWA PIERDOLE" || textIn.toUpper() == "KURWA JAPIERDOLE" || textIn.toUpper() == "JAPIERDOLE KURWA") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "kurwa9.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "KURWA BOBR" || textIn.toUpper() == "BOBR KURWA" || textIn == "курва бобр" || textIn == "бобр курва" || textIn == "Курва бобр" || textIn == "Бобр курва") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "kurwa6.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "GROOVY") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "groovy.ogg", pos, 3.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "AH SHIT HERE WE GO AGAIN" || textIn.toUpper() == "AH SHIT, HERE WE GO AGAIN" || textIn.toUpper() == "HERE WE GO AGAIN") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "cj.ogg", pos, 7.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);

			// anime sounds
			} else if (textIn.toUpper() == "TUTURU" || textIn.toUpper() == "TUTURU!"  || textIn.toUpper() == "TU TU RU" || textIn.toUpper() == "TUTTURU") {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(9) + 1;
					Sound::Play(soundrandom + "Tuturu" + random + ".ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 40);
			} else if (textIn.toUpper() == "POG" || textIn.toUpper() == "POGGERS") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "poggers.ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 40);
			} else if (textIn.toUpper() == "NICE" || textIn.toUpper() == "NOICE" || textIn == "найс" || textIn == "Найс" || textIn == "отлично" || textIn == "Отлично") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "nice.ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 40);
			} else if (textIn.toUpper() == "BAKA" || textIn.toUpper() == "DURAK" || textIn.toUpper() == "дурак" || textIn.toUpper() == "Дурак" || textIn.toUpper() == "ДУРАК") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "baka.ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 40);

			// russian sounds
			} else if (textIn.findFirst("ладно") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "nyladno.ogg", pos, 3.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper().find("auf") != -1 || textIn.find("ауф") != -1 || textIn.find("АУФ") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "auf.ogg", pos, 4.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("огузки") != -1 || textIn.findFirst("Огузки") != -1 || textIn.findFirst("ОГУЗКИ") != -1 || textIn.toUpper().findFirst("OGUZKI") != -1) {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "rage.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 1800);
			} else if (textIn == "хорошо но мало" || textIn.toUpper() == "хорошо, но мало" || textIn.toUpper() == "GOOD, BUT NOT ENOUGH") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "goodbutnotenough.ogg", pos, 3.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "NOT COOL" || textIn.toUpper() == "не прикольно" || textIn.toUpper() == "Не прикольно") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "neprikolno.ogg", pos, 3.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);

			// MineCult/Gruhsha sounds (he-he)
			} else if (textIn.toUpper() == "SKILL ISSUE" || textIn == "скилл ишью") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "skillissue.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "осуждаю" || textIn == "Осуждаю" || textIn.toUpper() == "BLAMING") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "osujdenie.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "получил пизды" || textIn == "Получил пизды" || textIn.toUpper() == "GET FUCKED") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "enjoyingpizda.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "Стратегия" || textIn == "стратегия" || textIn == "это стратегия" || textIn == "Это стратегия" || textIn.toUpper() == "ITS STRATEGY") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "etostrategia.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "Груши" || textIn == "Груши мои груши" || textIn == "груши" || textIn == "груши мои груши" || textIn.toUpper() == "GRUSHI MOI GRUSHI") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "grushi.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "чего втыкаешь" || textIn == "чего не пушишь" || textIn == "почему не пушишь" || textIn == "Чего втыкаешь" || textIn == "Чего не пушишь" || textIn == "Почему не пушишь" || textIn.toUpper() == "WHY YOU STAYING" || textIn.toUpper() == "WHY YOU DONT PUSHING") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "vtykaesh.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "сосал" || textIn == "Сосал" || textIn.toUpper() == "SOSAL" || textIn.toUpper() == "SUCKED") {
					if (annoying_voicelines_sounds == "on")
					{
						int random = XORRandom(2) + 1;
						Sound::Play(soundrandom + "sosal" + random + ".ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "мегасосал" || textIn == "Мегасосал" || textIn.toUpper() == "MEGASOSAL") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "sosal1.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "похуй гойда" || textIn == "похер гойда" || textIn == "Похуй гойда" || textIn == "Похер гойда" || textIn.toUpper() == "POHUI GOIDA" || textIn.toUpper() == "POHER GOIDA") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "pohuigoida.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "сердце" || textIn == "Сердце" || textIn.toUpper() == "HEART") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "heartvoice.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "пизда роялю" || textIn == "Пизда роялю" || textIn.toUpper() == "PIZDA ROYALU") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "royal.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "ГОЙДА" || textIn == "Гойда" || textIn == "гойда" || textIn.toUpper() == "GOIDA") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "hallios_goida.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "Перекати гойда" || textIn == "перекати гойда" || textIn == "ПЕРЕКАТИ ГОЙДА" || textIn == "перекати ГОЙДА" || textIn == "Перекати ГОЙДА" || textIn.toUpper() == "PEREKATI GOIDA") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "perekatigoida.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "гол" || textIn == "Гол" || textIn == "ГОOOOЛ" || textIn.toUpper() == "GOL" || textIn.toUpper() == "GOOOOL") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "nebula_gool.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn == "Бля" || textIn == "бля" || textIn == "БЛЯ" || textIn.toUpper() == "BLYA") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "nebula_blyat.ogg", pos, 4.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
		}

	return true;
}
