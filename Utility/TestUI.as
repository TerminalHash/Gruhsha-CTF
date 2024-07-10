#include "EasyUI.as"

#define CLIENT_ONLY

EasyUI@ ui;

const SColor BLUE = SColor(0xFF1A6F9E);
const SColor RED = SColor(0xFFBA2721);

List@ scoreboard;
[]Components@ components;

void onInit(CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    @ui = EasyUI();
    @scoreboard = StandardList();
    scoreboard.SetCellWrap(7);
    scoreboard.SetAlignment(0.5, 0.5);

    // NICKNAME COLUMN
    Label@ nickname_label = StandardLabel();
    nickname_label.SetText("NICKNAME");
    nickname_label.SetAlignment(0.5, 0.5);
    Pane@ nickname_pane = StandardPane(ui);
    nickname_pane.SetMinSize(100, 32);
    nickname_pane.AddComponent(nickname_label);

    // USERNAME COLUMN
    Label@ username_label = StandardLabel();
    username_label.SetText("USERNAME");
    username_label.SetAlignment(0.5, 0.5);
    Pane@ username_pane = StandardPane(ui);
    username_pane.SetMinSize(100, 32);
    username_pane.AddComponent(username_label);

    // INFO COLUMN
    Label@ info_label = StandardLabel();
    info_label.SetText("INFO");
    info_label.SetAlignment(0.5, 0.5);
    Pane@ info_pane = StandardPane(ui);
    info_pane.SetMinSize(100, 32);
    info_pane.AddComponent(info_label);

    // PING COLUMN
    Label@ ping_label = StandardLabel();
    ping_label.SetText("PING");
    ping_label.SetAlignment(0.5, 0.5);
    Pane@ ping_pane = StandardPane(ui);
    ping_pane.SetMinSize(100, 32);
    ping_pane.AddComponent(ping_label);

    // DEATHS COLUMN
    Label@ deaths_label = StandardLabel();
    deaths_label.SetText("DEATHS");
    deaths_label.SetAlignment(0.5, 0.5);
    Pane@ deaths_pane = StandardPane(ui);
    deaths_pane.SetMinSize(100, 32);
    deaths_pane.AddComponent(deaths_label);

    // KILLS COLUMN
    Label@ kills_label = StandardLabel();
    kills_label.SetText("KILLS");
    kills_label.SetAlignment(0.5, 0.5);
    Pane@ kills_pane = StandardPane(ui);
    kills_pane.SetMinSize(100, 32);
    kills_pane.AddComponent(kills_label);

    // KDR COLUMN
    Label@ kdr_label = StandardLabel();
    kdr_label.SetText("KDR");
    kdr_label.SetAlignment(0.5, 0.5);
    Pane@ kdr_pane = StandardPane(ui);
    kdr_pane.SetMinSize(100, 32);
    kdr_pane.AddComponent(kdr_label);
  
    // LOCALPLAYER NICKNAME
    CPlayer@ lp = getLocalPlayer();

    //Label@ lp_nickname_label = StandardLabel();
    //lp_nickname_label.SetText(lp.getCharacterName());
    //lp_nickname_label.SetAlignment(0.5, 0.5);
    //Pane@ lp_nickname_pane = StandardPane(ui);
    //lp_nickname_pane.SetMinSize(100, 32);
    //lp_nickname_pane.AddComponent(lp_nickname_label);

    scoreboard.SetComponents({
	nickname_pane,
	username_pane,
	info_pane,
	ping_pane,
	deaths_pane,
	kills_pane,
	kdr_pane});
    
    ui.AddComponent(scoreboard);
}

void onTick(CRules@ this) {
    ui.Update();
}

void onRender(CRules@ this) {
    if (ui is null) return;

    ui.Render();
    ui.Debug(getControls().isKeyPressed(KEY_LSHIFT));
}
