//Rules timer!

// Requires game_end_time set originally

#include "TranslationsSystem.as"
#include "ActorHUDStartPos.as"

void onInit(CRules@ this) {
	//this.addCommandID("sudden death sound");

	if (!this.exists("no timer"))
		this.set_bool("no timer", false);
	if (!this.exists("game_end_time"))
		this.set_u32("game_end_time", 0);
	if (!this.exists("end_in"))
		this.set_s32("end_in", 0);

	//this.set_bool("kurwa", false);
}

void onTick(CRules@ this) {
	if (!getNet().isServer() || !this.isMatchRunning() || this.get_bool("no timer")) { return; }

	u32 gameEndTime = this.get_u32("game_end_time");

	if (gameEndTime == 0) return; //-------------------- early out if no time.

	this.set_s32("end_in", (s32(gameEndTime) - s32(getGameTime())) / 30);
	this.Sync("end_in", true);

	s32 end_in = this.get_s32("end_in");
	//bool kurwa = this.get_bool("kurwa");

	// Special tag for buffs on 10 min
	//if (end_in == 1200) {  // 20 min
	// (end_in == 300) {     // 5 min
	if (end_in == 600 || (end_in == 300 && this.get_string("internal_game_mode") == "smolctf")) {
		if(!isServer()) return;

		this.Tag("sudden death");
		this.Sync("sudden death", true);

		// Change prices in shops
		// knight shop
		CBlob@[] knightshoplist;
		if(getBlobsByName("knightshop", knightshoplist)) {
			for (int i = 0; i < knightshoplist.size(); ++i) {
				CBlob@ currentshop = knightshoplist[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		// archer shop
		CBlob@[] archershoplist;
		if(getBlobsByName("archershop", archershoplist)) {
			for (int i = 0; i < archershoplist.size(); ++i) {
				CBlob@ currentshop = archershoplist[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		//printf("[INFO] Sudded Death Mode activated!");
	}

	if (getGameTime() > gameEndTime) {
		bool hasWinner = false;
		s8 teamWonNumber = -1;

		if (this.exists("team_wins_on_end")) {
			teamWonNumber = this.get_s8("team_wins_on_end");
		}

		if (teamWonNumber >= 0) {
			//ends the game and sets the winning team
			this.SetTeamWon(teamWonNumber);
			CTeam@ teamWon = this.getTeam(teamWonNumber);

			if (teamWon !is null) {
				hasWinner = true;
				this.SetGlobalMessage("Time is up!\n{WINNING_TEAM} wins the game!");
				this.AddGlobalMessageReplacement("WINNING_TEAM", teamWon.getName());
				
			}
		}

		if (!hasWinner) {
			this.SetGlobalMessage("Time is up!\nIt's a tie!");
		}

		//GAME OVER
		this.SetCurrentState(3);
	}
}

void onRender(CRules@ this) {
	if (g_videorecording)
		return;

	if (!this.isMatchRunning() || this.get_bool("no timer") || !this.exists("end_in")) return;

	s32 end_in = this.get_s32("end_in");

	Vec2f timer_pos1 = Vec2f(10, 49);			// y coordinate
	Vec2f timer_pos2 = Vec2f(227, 5);			// x coordinate

	// change timer position for tavern tdm
	if (this.get_string("internal_game_mode") == "tavern") {
		timer_pos1 = Vec2f(10, 159);
		timer_pos2 = Vec2f(120, 5);
	}

	if (end_in > 0) {
		s32 timeToEnd = end_in;

		s32 secondsToEnd = timeToEnd % 60;
		s32 MinutesToEnd = timeToEnd / 60;
		drawRulesFont(getTranslatedString("{MIN}:{SEC}")
						.replace("{MIN}", "" + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd))
						.replace("{SEC}", "" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd)),
		              SColor(255, 255, 255, 255), timer_pos1, timer_pos2, true, false);
	}

	// Notification
	if ((end_in > 600 && end_in < 610 && this.get_string("internal_game_mode") != "tavern") ||
		(end_in > 300 && end_in < 310 && this.get_string("internal_game_mode") == "smolctf")) {
		Vec2f dim = Vec2f(342, 155);
		Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
		Vec2f tl = ul + Vec2f(-10, -10);

		if (g_locale == "ru") {
			GUI::DrawSunkenPane(tl, tl + Vec2f(400, 30));
		} else {
			GUI::DrawSunkenPane(tl, tl + Vec2f(210, 30));
		}

		GUI::DrawText(Descriptions::thirtyminutesleft, Vec2f(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 7), color_white);
	}

	Vec2f skull = Vec2f(5, 4);

	float x = skull.x - 8;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	if (this.hasTag("sudden death") && this.get_string("internal_game_mode") != "tavern") {
		GUI::DrawIcon("CTF_States.png", 2, Vec2f(32, 32), skull, 1.0f);

		Vec2f dim = Vec2f(342, 295);
		Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
		Vec2f tl = ul + Vec2f(-190, -100);

		if (mousePos.x > x && mousePos.x < x + 74 && mousePos.y < skull.y + 64 && mousePos.y > skull.y) {
			GUI::DrawSunkenPane(tl, tl + Vec2f(490, 150));
			GUI::DrawText(Descriptions::suddenactive, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 80), color_white);
			GUI::DrawText(Descriptions::kegbuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 65), color_white);
			GUI::DrawText(Descriptions::drillbuff1, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 50), color_white);
			GUI::DrawText(Descriptions::drillbuff2, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 35), color_white);
			GUI::DrawText(Descriptions::blockreqdebuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 20), color_white);
			GUI::DrawText(Descriptions::respawndebuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y - 5), color_white);
			GUI::DrawText(Descriptions::pricedebuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y + 10), color_white);

			// victims of democracy
			//GUI::DrawText(Descriptions::shielddebuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y + 10), color_white);
			//GUI::DrawText(Descriptions::swordbuff, Vec2f(getHUDX() - dim.x / 2.0f - 180, getHUDY() - dim.y + 25), color_white);
		}
	}
}