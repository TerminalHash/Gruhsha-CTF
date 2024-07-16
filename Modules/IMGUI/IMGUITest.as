#include "IMGUI.as"
#include "ScoreboardCommon.as"

string[] column_names = {
    "TEAM",
    "PLAYER",
    "USERNAME",
    "K",
    "D",
    "KDR"
};

u32[] column_widths = {
    70,
    200,
    100,
    34,
    34,
    50
};

u32 priority = 4;

void onInit(CRules@ this) {}

void inTick(CRules@ this) {}

void onRender(CRules@ this) {
    GUI::SetFont("menu");
    u32 screen_width = getScreenWidth();
    u32 scoreboard_width = 0;
    for (u32 column_id = 0; column_id < column_widths.length; column_id++) {
        scoreboard_width += column_widths[column_id];
    }

    Vec2f scoreboard_start_pos = Vec2f((screen_width - scoreboard_width) / 2.0, 200);
    Vec2f scoreboard_pos = scoreboard_start_pos;

    IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, 32), IMGUI::BLACK);
    // НАЗВАНИЯ СТРОК
    for (u32 column_id = 0; column_id < column_names.length; column_id++) {
        if(IMGUI::Button(column_names[column_id], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[column_id], 32))) priority = column_id;
	scoreboard_pos.x += column_widths[column_id];
    }

    CPlayer@[] players;

    for (u32 player_id = 0; player_id < getPlayerCount(); player_id++) {
        CPlayer@ player = getPlayer(player_id);
        if(player is null) continue;

        bool inserted = false;

        for (u32 j = 0; j < players.length; j++) {
            if (column_names[priority] == "TEAM" && players[j].getTeamNum() > player.getTeamNum()) {
                players.insert(j, player);
                inserted = true;
		break;
            } else if (column_names[priority] == "K" && players[j].getKills() < player.getKills()) {
                players.insert(j, player);
                inserted = true;
		break;
            } else if (column_names[priority] == "D" && players[j].getDeaths() < player.getDeaths()) {
                players.insert(j, player);
                inserted = true;
		break;
            } else if (column_names[priority] == "KDR" && getKDR(players[j]) < getKDR(player)) {
                players.insert(j, player);
                inserted = true;
		break;
            }
        }

        if (!inserted)
            players.push_back(player);
    }

    for (u32 player_id = 0; player_id < players.length; player_id++) {
        scoreboard_pos.x = scoreboard_start_pos.x;
        scoreboard_pos.y += 32;

        CPlayer@ player = players[player_id];

        string team_name = "SPEC";
        SColor team_color = IMGUI::GRAY;
        if (player.getTeamNum() == 0) {
            team_name = "BLUE";
            team_color = IMGUI::BLUE;
        }
        if (player.getTeamNum() == 1) {
            team_name = "RED";
            team_color = IMGUI::RED;
        }

        IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, 32), IMGUI::BLACK);

        for (u32 column_id = 0; column_id < column_names.length; column_id++) {
            string name = column_names[column_id];
            u32 width = column_widths[column_id];
            Vec2f cell_size = Vec2f(width, 32);

            if (name == "TEAM") {
                IMGUI::Panel(""+team_name, scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "PLAYER") {
                IMGUI::Panel(""+player.getClantag() + " " + player.getCharacterName(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "USERNAME") {
                IMGUI::Panel(""+player.getUsername(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "K") {
                IMGUI::Panel(""+player.getKills(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "D") {
                IMGUI::Panel(""+player.getDeaths(), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            } else if (name == "KDR") {
                IMGUI::Panel(""+formatFloat(getKDR(player), "", 0, 2), scoreboard_pos, scoreboard_pos + cell_size, team_color);
            }

            scoreboard_pos.x += width;
        }
    }
}
