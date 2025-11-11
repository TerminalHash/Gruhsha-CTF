#include "KOTH_Structs.as";
#include "ActorHUDStartPos.as";
//#include "CommandsHelpHUD.as";

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/


void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart( CRules@ this )
{
	//set for all clients to ensure safe sync
	this.set_s16("stalemate_breaker", 0);

}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	s32 blue_timer = this.get_s32("control_timer_blue");
	s32 red_timer = this.get_s32("control_timer_red");

	bool isControlPointCappedByBlue = this.get_bool("cp_controlled_blue");
    bool isControlPointCappedByRed = this.get_bool("cp_controlled_red");
	bool isStalemate = getRules().get_bool("koth_stalemate");

	// ControlPoints (CP) Interface
	// points panel

	// King of the Hill (KOTH) Interface
	// if (GetGamemode(this) == "KOTH")
	// main panel
	GUI::DrawIcon("KOTH_Panel.png", 0, Vec2f(146,38), Vec2f(getScreenWidth() /2 - 145, getScreenHeight() / -2));

	// blue controlling
	if (isControlPointCappedByBlue) {
		GUI::DrawIcon("Blue_Token.png", 0, Vec2f(146,38), Vec2f(getScreenWidth() /2 - 145, getScreenHeight() / -2));
	}

	// red controlling
	if (isControlPointCappedByRed) {
		GUI::DrawIcon("Red_Token.png", 0, Vec2f(146,38), Vec2f(getScreenWidth() /2 - 145, getScreenHeight() / -2));
	}

	// blue and red in hold sector?
	if (isStalemate) {
		GUI::DrawIcon("KOTH_Stale_Icon.png", 0, Vec2f(146,38), Vec2f(getScreenWidth() /2 - 145, getScreenHeight() / -2));
	}

	///////////////////////////////////////////////////////////
	// Players counters
	CBlob@[] overlapping;
	u32 BLUE_PLAYERS = 0;
	u32 RED_PLAYERS = 0;
	u32 BLUE_ON_HOLD = 0;
	u32 RED_ON_HOLD = 0;

    if (getMap().getBlobsInSector(getMap().getSector("hold zone"), overlapping)) {
        for (int i = 0; i < overlapping.length; ++i) {
            if (overlapping[i].hasTag("player") && overlapping[i].getTeamNum() == 0) {
				BLUE_ON_HOLD++;
            }

            if (overlapping[i].hasTag("player") && overlapping[i].getTeamNum() == 1) {
				RED_ON_HOLD++;
            }
        }
    }

	for (int i=0; i<getPlayersCount(); ++i) {
		CPlayer@ p = getPlayer(i);

		if (p !is null) {
			if (p.getTeamNum() == 0) {
				BLUE_PLAYERS++;
			}

			if (p.getTeamNum() == 1) {
				RED_PLAYERS++;
			}
		}
	}

    GUI::SetFont("hud");
	GUI::DrawText(BLUE_ON_HOLD + "/" + BLUE_PLAYERS, Vec2f(getScreenWidth() / 2 - 50, getScreenHeight() /-2 + 48), SColor(255, 255, 255, 255));
	GUI::DrawText(RED_ON_HOLD + "/" + RED_PLAYERS, Vec2f(getScreenWidth() / 2 + 26, getScreenHeight() /-2 + 48), SColor(255, 255, 255, 255));
	///////////////////////////////////////////////////////////

	///////////////////////////////////////////////////////////
	// timers
	GUI::SetFont("AveriaSerif-big");
	if (blue_timer > 0) {
		s32 secondsToEndBlue = blue_timer / 30 % 60;
		s32 MinutesToEndBlue = blue_timer / 60 / 30;

		string blue_time_counter = getTranslatedString("{MIN}:{SEC}").replace("{MIN}", "" + ((MinutesToEndBlue < 10) ? "0" + MinutesToEndBlue : "" + MinutesToEndBlue)).replace("{SEC}", "" + ((secondsToEndBlue < 10) ? "0" + secondsToEndBlue : "" + secondsToEndBlue));

		GUI::DrawText(blue_time_counter , Vec2f(getScreenWidth() / 2 - 75, getScreenHeight() /-2 + 5), SColor(255, 255, 255, 255));
	}

	if (red_timer > 0) {
		s32 secondsToEndRed = red_timer / 30 % 60;
		s32 MinutesToEndRed = red_timer / 60 / 30;

		string red_time_counter = getTranslatedString("{MIN}:{SEC}").replace("{MIN}", "" + ((MinutesToEndRed < 10) ? "0" + MinutesToEndRed : "" + MinutesToEndRed)).replace("{SEC}", "" + ((secondsToEndRed < 10) ? "0" + secondsToEndRed : "" + secondsToEndRed));

		GUI::DrawText(red_time_counter , Vec2f(getScreenWidth() / 2 + 10, getScreenHeight() /-2 + 5), SColor(255, 255, 255, 255));
	}
	//}
	///////////////////////////////////////////////////////////

	string propname = "koth spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (this.isMatchRunning() && spawn != 255)
		{
			string spawn_message = getTranslatedString("Respawning in: {SEC}").replace("{SEC}", ((spawn > 250) ? getTranslatedString("approximatively never") : ("" + spawn)));

			GUI::SetFont("hud");
			GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	this.SyncToPlayer("koth_serialised_team_hud", player);
}
