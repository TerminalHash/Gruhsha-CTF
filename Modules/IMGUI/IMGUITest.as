#include "IMGUI.as"

string[] column_names = {
    "CLANTAG",
    "NICKNAME",
    "USERNAME",
    "K",
    "D",
    "KDR"
};

u32[] column_widths = {
    100,
    100,
    100,
    32,
    32,
    50
};

void onInit(CRules@ this) {}

void inTick(CRules@ this) {}

void onRender(CRules@ this) {
    GUI::SetFont("AveriaSerif-tag");
    u32 screen_width = getScreenWidth();
    u32 scoreboard_width = 0;
    for (u32 i = 0; i < column_widths.length; i++) {
        scoreboard_width += column_widths[i];
    }

    Vec2f scoreboard_start_pos = Vec2f((screen_width - scoreboard_width) / 2.0, 200);
    Vec2f scoreboard_pos = scoreboard_start_pos;

    IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, 32), IMGUI::BLACK);
    // НАЗВАНИЯ СТРОК
    for (u32 i = 0; i < column_names.length; i++) {
        IMGUI::Panel(column_names[i], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[i], 32), IMGUI::GRAY);
	scoreboard_pos.x += column_widths[i];
    }

    for (u32 player_id = 0; player_id < getPlayerCount(); player_id++) {
        scoreboard_pos.x = scoreboard_start_pos.x;
        scoreboard_pos.y += 32;

        CPlayer@ player = getPlayer(player_id);
        if(player is null) continue;

        SColor team_color = IMGUI::GRAY;
        if (player.getTeamNum() == 0) team_color = IMGUI::BLUE;
        if (player.getTeamNum() == 1) team_color = IMGUI::RED;

        IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, 32), IMGUI::BLACK);

        for (u32 i = 0; i < column_names.length; i++) {
            string name = column_names[i];
            u32 width = column_widths[i];
            Vec2f cell_size = Vec2f(width, 32);

            if (name == "CLANTAG") {
              IMGUI::Panel(""+player.getClantag(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "NICKNAME") {
              IMGUI::Panel(""+player.getCharacterName(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "USERNAME") {
              IMGUI::Panel(""+player.getUsername(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "K") {
              IMGUI::Panel(""+player.getKills(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "D") {
              IMGUI::Panel(""+player.getDeaths(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "KDR") {
              IMGUI::Panel(""+player.getDeaths(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            }

            scoreboard_pos.x += width;
        }
    }
}
