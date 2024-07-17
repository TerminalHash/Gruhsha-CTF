#include "IMGUI.as"
#include "ScoreboardCommon.as"

array<string> column_names = {
    "TEAM",
    "PLAYER",
    "USERNAME",
    "K",
    "D",
    "KDR"
};

array<u32> column_widths = {
    70,
    200,
    100,
    34,
    34,
    50
};

const u32 row_height = 26;
const u32 pick_button_width = 50;
const u32 blue_team_num = 0;
const u32 red_team_num = 1;
const u32 spec_team_num = 200;

u32 priority = 0;

void onInit(CRules@ this) {}

void inTick(CRules@ this) {}

void onRender(CRules@ this) {
    CPlayer@ local_player = getLocalPlayer();
    if (local_player is null) return;
    u32 local_team_num = local_player.getTeamNum();
    string local_username = local_player.getUsername();

    GUI::SetFont("menu");
    u32 screen_width = getScreenWidth();
    u32 scoreboard_width = 0;
    for (u32 column_id = 0; column_id < column_widths.length(); column_id++) {
        scoreboard_width += column_widths[column_id];
    }

    Vec2f scoreboard_start_pos = Vec2f((screen_width - scoreboard_width) / 2.0, 200);
    Vec2f scoreboard_pos = scoreboard_start_pos;

    IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, row_height), IMGUI::BLACK);

    for (u32 column_id = 0; column_id < column_names.length(); column_id++) {
        if (column_names[column_id] == "PLAYER" || column_names[column_id] == "USERNAME")
            IMGUI::Panel(column_names[column_id], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[column_id], row_height));
        else if (IMGUI::Button(column_names[column_id], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[column_id], row_height))) priority = column_id;
	scoreboard_pos.x += column_widths[column_id];
    }

    array<CPlayer@> players;

    // СОРТИРОВКА ИГРОКОВ
    for (u32 player_id = 0; player_id < getPlayerCount(); player_id++) {
        CPlayer@ player = getPlayer(player_id);
        if(player is null) continue;

        bool inserted = false;

        for (u32 j = 0; j < players.length(); j++) {
            if (column_names[priority] == "TEAM" && players[j].getTeamNum() > player.getTeamNum() ||
                column_names[priority] == "K" && players[j].getKills() < player.getKills() ||
                column_names[priority] == "D" && players[j].getDeaths() < player.getDeaths() ||
                column_names[priority] == "KDR" && getKDR(players[j]) < getKDR(player)) {
                players.insert(j, player);
                inserted = true;
                break;
            }
        }
        if (!inserted) players.push_back(player);
    }

    // ОТРИСОВКА ОСНОВНОЙ ТАБЛИЦЫ
    for (u32 player_id = 0; player_id < players.length(); player_id++) {
        scoreboard_pos.x = scoreboard_start_pos.x;
        scoreboard_pos.y += row_height;

        CPlayer@ player = players[player_id];
        string clantag = player.getClantag();
        string username = player.getUsername();

        string team_name = "SPEC";
        SColor team_color = IMGUI::DARK_GRAY;
        u32 team_num = player.getTeamNum();
        if (team_num == blue_team_num) {
            team_name = "BLUE";
            team_color = IMGUI::BLUE;
        }
        if (team_num == red_team_num) {
            team_name = "RED";
            team_color = IMGUI::RED;
        }

        IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, row_height), IMGUI::BLACK);

        // КАПИТАНСКИЕ ПЛАШКИ
        if (getRules().get_string("team_"+team_num+"_leader")==username) {
            IMGUI::Panel("CAPTAIN", scoreboard_pos-Vec2f(100,0), scoreboard_pos + Vec2f(0, row_height), IMGUI::DARK_GRAY, IMGUI::YELLOW);
        }

        // ОСНОВНАЯ ТАБЛИЦА
        for (u32 column_id = 0; column_id < column_names.length(); column_id++) {
            string column_name = column_names[column_id];
            u32 column_width = column_widths[column_id];
            Vec2f cell_size = Vec2f(column_width, row_height);

            string info = "";

            if (column_name == "TEAM") info = ""+team_name;
            else if (column_name == "PLAYER") info = ""+clantag + " " + player.getCharacterName();
            else if (column_name == "USERNAME") info = ""+username;
            else if (column_name == "K") info = ""+player.getKills();
            else if (column_name == "D") info = ""+player.getDeaths();
            else if (column_name == "KDR") info = ""+formatFloat(getKDR(player));

            IMGUI::Panel(info, scoreboard_pos, scoreboard_pos + cell_size, team_color);
            scoreboard_pos.x += column_width;
        }

        // КНОПКИ ДЛЯ ПИКОВ
        CBitStream pick_params;
	pick_params.write_string(username);
        if (isAdmin(local_player)) {
            if (team_num != blue_team_num) {
                if (IMGUI::Button("BLUE", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height))) {
                    this.SendCommand(this.getCommandID("put to blue"), pick_params);
                }
                scoreboard_pos.x += pick_button_width;
            }
            if (team_num != red_team_num) {
                if (IMGUI::Button("RED", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height))) {
                    this.SendCommand(this.getCommandID("put to red"), pick_params);
                    scoreboard_pos.x += pick_button_width;
                }
                scoreboard_pos.x += pick_button_width;
            }
            if (team_num != spec_team_num) {
                if (IMGUI::Button("SPEC", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height))) {
                    this.SendCommand(this.getCommandID("put to spec"), pick_params);
                    scoreboard_pos.x += pick_button_width;
                }
            }
        } else if (local_player.getUsername() == this.get_string("team_"+local_team_num+"_leader") && username != local_username) {
            if (team_num == local_team_num) {
                if (IMGUI::Button("SPEC", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height))) {
                    this.SendCommand(this.getCommandID("put to spec"), pick_params);
                }
            }
            if (team_num == spec_team_num) {
                if (IMGUI::Button("PICK", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height))) {
                    if (local_team_num == blue_team_num)
                        this.SendCommand(this.getCommandID("put to blue"), pick_params);
                    if (local_team_num == red_team_num)
                        this.SendCommand(this.getCommandID("put to red"), pick_params);
                }
            }
        }
    }
}
