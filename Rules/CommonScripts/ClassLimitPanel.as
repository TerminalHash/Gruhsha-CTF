// ClassLimitPanel.as
#define CLIENT_ONLY

#include "Gruhsha_Gamemodes.as";

// amount variables
int P_Archers;
int P_Builders;
int P_Knights;
// initialization limits
int archers_limit;
int builders_limit;

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

    // remove class counter text
    if (InternalGamemode(this) == "tavern") return;

    GUI::SetFont("menu");

	//P_Archers = 0;
	//P_Builders = 0;
	//P_Knights = 0;
    //
	//// calculating amount of players in classes
	//for (u32 i = 0; i < getPlayersCount(); i++) {
	//	if (getPlayer(i).getScoreboardFrame() == 2 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Archers++;}
	//	if (getPlayer(i).getScoreboardFrame() == 1 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Builders++;}
	//	if (getPlayer(i).getScoreboardFrame() == 3 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Knights++;}
	//}
    
    if (getLocalPlayer() !is null) {
        P_Archers = this.get_s32("archer" + getLocalPlayer().getTeamNum() + "Count");
        P_Builders = this.get_s32("builder" + getLocalPlayer().getTeamNum() + "Count");
        P_Knights = this.get_s32("knight" + getLocalPlayer().getTeamNum() + "Count");
    }

	archers_limit = this.get_u8("archers_limit");
	builders_limit = this.get_u8("builders_limit");

    Vec2f archer_pan = Vec2f(12, 270);
    Vec2f archer_pan_text = Vec2f(264, 14);
    if (archers_limit < 10) {
        archer_pan_text = Vec2f(268, 14);
    }
    
    Vec2f knight_pan = Vec2f(12, 320);
    Vec2f knight_pan_text = Vec2f(196, 14);
    
    if (P_Knights >= 10) {
        knight_pan_text = Vec2f(193, 14);
    }
    
    Vec2f builder_pan = Vec2f(12, 370);
    Vec2f builder_pan_text = Vec2f(110, 14);
    if (builders_limit < 10) {
        builder_pan_text = Vec2f(114, 14);
    }
    

	//GUI::DrawIcon("class_panel.png", Vec2f(12, 190));
    // ARCHERS
    //GUI::DrawIcon("class_panel.png", 2, Vec2f(41, 24), archer_pan, 1.0);
    GUI::DrawShadowedText(P_Archers + "/" + archers_limit, archer_pan_text, color_white);
    
    // KNIGHTS
    //GUI::DrawIcon("class_panel.png", 1, Vec2f(41, 24), knight_pan, 1.0);
    GUI::DrawShadowedText("" + P_Knights, knight_pan_text, color_white);

    // BUILDERS
    //GUI::DrawIcon("class_panel.png", 9, Vec2f(41, 24), builder_pan, 1.0);
    GUI::DrawShadowedText(P_Builders + "/" + builders_limit, builder_pan_text, color_white);
}
