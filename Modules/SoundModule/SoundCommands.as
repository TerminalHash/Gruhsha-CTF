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
			if (textIn.toUpper() == "TUTURU" || textIn.toUpper() == "TUTURU!"  || textIn.toUpper() == "TU TU RU" || textIn.toUpper() == "TUTTURU") {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(9) + 1;
					Sound::Play(soundrandom + "Tuturu" + random + ".ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "POG" || textIn.toUpper() == "POGGERS") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "poggers.ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper().find("SUS", 0) != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "sus.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "BRUH" || textIn.toUpper() == ("БРУХ") || textIn.toUpper() == ("БРАХ")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "bruh.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
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
					int random = XORRandom(9) + 1;
					Sound::Play(soundrandom + "kurwa" + random + ".ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);


			} else if (textIn.toUpper() == "YEP" || textIn.toUpper() == "YOP"  || textIn == "дап" || textIn == "Дап") {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(5) + 1;
					Sound::Play(soundrandom + "yep" + random + ".ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			} else if (textIn.toUpper() == "NOPE" || textIn == ("ноуп") || textIn == ("Ноуп")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "nope.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "BANZAI" || textIn == ("банзай") || textIn == ("Банзай")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "banzai.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "BOMBASTIC" || textIn == ("бомбастик") || textIn == ("Бомбастик")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "bombastic.ogg", pos, 1.2f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "NOTHING WE CAN DO") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "nothwcd.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "KURWA PIERDOLE" || textIn.toUpper() == "KURWA JAPIERDOLE" || textIn.toUpper() == "JAPIERDOLE KURWA") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "kurwa9.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "KURWA BOBR" || textIn.toUpper() == "BOBR KURWA" || textIn == "курва бобр" || textIn == "бобр курва" || textIn == "Курва бобр" || textIn == "Бобр курва") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "kurwa6.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "RAKIETA") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "rakita.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "JOEVER" || textIn.toUpper() == "GAMEOVER" || textIn.toUpper() == "GAME OVER") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "joever.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "LONG TIME AGO") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "longtime.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "BYE-BYE" || textIn.toUpper() == "BYE BYE") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "byebye.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);

			// russian sounds
			} else if (textIn == "пенек" || textIn == "пенёк" || textIn == "косарь" || textIn == "penek" || textIn.find("на", 0) != -1 && textIn.find("пенек", 0) != -1 || textIn.find("на", 0) != -1 && textIn.find("пенёк", 0) != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "penek.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("БЛЯЯ") != -1 || textIn.toUpper().findFirst("BLYAA") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "blyat.ogg", pos, 1.2f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("курлык") != -1 || textIn.toUpper().findFirst("KURLIK") != -1 || textIn.toUpper().findFirst("KURLYK") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "kurlik.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("заснайп") != -1 || textIn == ("sniped")) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "snipe.ogg", pos, 0.7f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == ("трипл") || textIn == ("triple")) {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "triple" + random + ".ogg", pos);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("хуительн") != -1 && textIn.findFirst("истори") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "history.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("гиляторн") != -1 && textIn.findFirst("пушк") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "pushka.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("на") != -1 && (textIn.findFirst("ушко") != -1 || textIn.findFirst("ущко") != -1 )) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "ushko-pushka.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("легенд") != -1 && textIn.findFirst("битв") != -1 || textIn.toUpper().findFirst("legend") != -1 && textIn.toUpper().findFirst("battl") != -1 ) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "legend.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("немогу") != -1 || (textIn.findFirst("да") != -1) && textIn.findFirst("блять") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "dablyat.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("новой") != -1 || textIn.findFirst("всё хуйня") != -1 || textIn.findFirst("кусака блять") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "misha.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("похлопаю") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "pohlopau.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("ладно") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "nyladno.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("бред") != -1 || textIn.findFirst("врёшь") != -1 || textIn.findFirst("врешь") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "bredish.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.findFirst("ёбаный") != -1 || textIn.findFirst("ебаный") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "ebanrot" + random + ".ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			}  else if (textIn == ("ай") || textIn == ("ai") || textIn == ("ah")) {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "ai" + random + ".ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == ("ой") || textIn == ("oi") || textIn == ("oh")) {
				if (annoying_voicelines_sounds == "on")
				{
					int random = XORRandom(2) + 1;
					Sound::Play(soundrandom + "oi" + random + ".ogg", pos, 1.0f);
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
			} else if (textIn.findFirst("хехе") != -1 || textIn.findFirst("hehe") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "hehe.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.find("айяй") != -1 || textIn.find("ahoh") != -1 || textIn.find("aiyai") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "aiyai.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn.toUpper().find("auf") != -1 || textIn.find("ауф") != -1 || textIn.find("АУФ") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "auf.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == "ЛОШАДИНЫЙ ХУЙ ЖАРА ИЮЛЬ") {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "loshadinyuhui.ogg", pos, 1.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == "жаль" || textIn == "Жаль" || textIn == "жаль этого добряка" || textIn == "Жаль этого добряка" || textIn == "жаль конечно этого добряка" || textIn == "Жаль конечно этого добряка" || textIn.find("рип") != -1 || textIn.find("Рип") != -1 || textIn.toUpper().find("RIP") != -1) {
				if (annoying_voicelines_sounds == "on")
				{
					Sound::Play(soundrandom + "dobryak.ogg", pos, 2.0f);
				}

				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 80);
			} else if (textIn == "сработал" || textIn.toUpper() == "Сработал") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "srabotal.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.findFirst("огузки") != -1 || textIn.findFirst("Огузки") != -1 || textIn.findFirst("ОГУЗКИ") != -1) {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "rage.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);

			// MineCult sounds (he-he)
			} else if (textIn.toUpper() == "SKILL ISSUE" || textIn == "скилл ишью") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "skillissue.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn == "осуждаю" || textIn == "Осуждаю") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "osujdenie.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn == "надо тащить" || textIn.toUpper() == "Надо тащить" || textIn.toUpper() == "нужно что-то делать" || textIn.toUpper() == "Нужно что-то делать" || textIn.toUpper() == "WEN PUSH" || textIn.toUpper() == "WHEN PUSH") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "nadochotodelat.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn.toUpper() == "Снайпер" || textIn.toUpper() == "снайпер") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "ebanisniper.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn == "получил пизды" || textIn == "Получил пизды") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "enjoyingpizda.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			} else if (textIn == "Стратегия" || textIn == "стратегия" || textIn == "это стратегия" || textIn == "Это стратегия") {
					if (annoying_voicelines_sounds == "on")
					{
						Sound::Play(soundrandom + "etostrategia.ogg", pos, 2.0f);
					}

					this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
					this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
		}
	return true;
}
