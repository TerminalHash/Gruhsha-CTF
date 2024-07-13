//Rules timer!

// Requires game_end_time set originally

#include "TranslationsSystem.as"
#include "ActorHUDStartPos.as"

void onInit(CRules@ this)
{
	if (!this.exists("no timer"))
		this.set_bool("no timer", false);
	if (!this.exists("game_end_time"))
		this.set_u32("game_end_time", 0);
	if (!this.exists("end_in"))
		this.set_s32("end_in", 0);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer() || !this.isMatchRunning() || this.get_bool("no timer"))
	{
		return;
	}

	u32 gameEndTime = this.get_u32("game_end_time");

	if (gameEndTime == 0) return; //-------------------- early out if no time.

	this.set_s32("end_in", (s32(gameEndTime) - s32(getGameTime())) / 30);
	this.Sync("end_in", true);

	s32 end_in = this.get_s32("end_in");

	// Special tag for buffs
	if (end_in == 1200) {
		this.Tag("sudden death");
		this.Sync("sudden death", true);

		//printf("[INFO] Sudded Death Mode activated!");
	}

	if (getGameTime() > gameEndTime)
	{
		bool hasWinner = false;
		s8 teamWonNumber = -1;

		if (this.exists("team_wins_on_end")) {
			teamWonNumber = this.get_s8("team_wins_on_end");
		}

		if (teamWonNumber >= 0)
		{
			//ends the game and sets the winning team
			this.SetTeamWon(teamWonNumber);
			CTeam@ teamWon = this.getTeam(teamWonNumber);

			if (teamWon !is null)
			{
				hasWinner = true;
				this.SetGlobalMessage("Time is up!\n{WINNING_TEAM} wins the game!");
				this.AddGlobalMessageReplacement("WINNING_TEAM", teamWon.getName());
				
			}
		}

		if (!hasWinner)
		{
			this.SetGlobalMessage("Time is up!\nIt's a tie!");
		}

		//GAME OVER
		this.SetCurrentState(3);
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	if (!this.isMatchRunning() || this.get_bool("no timer") || !this.exists("end_in")) return;

	s32 end_in = this.get_s32("end_in");

	if (end_in > 0)
	{
		GUI::DrawIcon("timer_panel.png", Vec2f(12, 140));
		s32 timeToEnd = end_in;

		s32 secondsToEnd = timeToEnd % 60;
		s32 MinutesToEnd = timeToEnd / 60;
		drawRulesFont(getTranslatedString("{MIN}:{SEC}")
						.replace("{MIN}", "" + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd))
						.replace("{SEC}", "" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd)),
		              SColor(255, 255, 255, 255), Vec2f(10, 157), Vec2f(150, 180), true, false);
	}

	// Notification
	if (end_in > 1190 && end_in < 1210) {
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
}
