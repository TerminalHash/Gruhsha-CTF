#include "IMGUI.as"
#include "ScoreboardCommon.as"

const u32 row_height = 24;
const u32 pick_button_width = 50;
const u32 blue_team_num = 0;
const u32 red_team_num = 1;
const u32 spec_team_num = 200;

u32 priority = 0;

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

void onRender(CRules@ this) {

    array<string> column_names = {
        "TEAM",
        "NICKNAME",
        "USERNAME",
        "K",
        "D",
        "KDR"
    };
    
    array<u32> column_widths = {
        60,
        90,
        90,
        34,
        34,
        50
    };
    
    GUI::SetFont("menu");
  
    CPlayer@ local_player = getLocalPlayer();
    if (local_player is null) return;
    u32 local_team_num = local_player.getTeamNum();
    SColor local_team_color = IMGUI::DARK_GRAY;
    if (local_team_num == blue_team_num) local_team_color = IMGUI::BLUE;
    if (local_team_num == red_team_num) local_team_color = IMGUI::RED;

    string local_username = local_player.getUsername();

    // ЗАПОЛНЕНИЕ ОТСОРТИРОВАННОГО МАССИВА ИГРОКОВ
    array<CPlayer@> players;
    for (u32 player_id = 0; player_id < getPlayerCount(); player_id++) {
        CPlayer@ player = getPlayer(player_id);
        if(player is null) continue;

        string nickname = player.getClantag() + " " + player.getCharacterName();
        Vec2f nickname_size(0,0);
        GUI::GetTextDimensions(nickname, nickname_size);
        column_widths[1] = Maths::Max(nickname_size.x + 12, column_widths[1]);

        string username = player.getUsername();
        Vec2f username_size(0,0);
        GUI::GetTextDimensions(username, username_size);
        column_widths[2] = Maths::Max(username_size.x + 12, column_widths[2]);
        
        // СОРТИРОВКА
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
    

    u32 screen_width = getScreenWidth();
    u32 scoreboard_width = 0;
    for (u32 column_id = 0; column_id < column_widths.length(); column_id++) {
        scoreboard_width += column_widths[column_id];
    }

    Vec2f scoreboard_start_pos((screen_width - scoreboard_width) / 2.0, 200);
    Vec2f scoreboard_pos(scoreboard_start_pos);

    IMGUI::Panel("", scoreboard_pos, scoreboard_pos + Vec2f(scoreboard_width, row_height), IMGUI::BLACK);

    for (u32 column_id = 0; column_id < column_names.length(); column_id++) {
        if (column_names[column_id] == "NICKNAME" || column_names[column_id] == "USERNAME")
            IMGUI::Panel(column_names[column_id], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[column_id], row_height));
        else if (IMGUI::Button(column_names[column_id], scoreboard_pos, scoreboard_pos + Vec2f(column_widths[column_id], row_height))) priority = column_id;
	scoreboard_pos.x += column_widths[column_id];
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
            else if (column_name == "NICKNAME") info = ""+clantag + " " + player.getCharacterName();
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
              if (IMGUI::Button("BLUE", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::BLUE, IMGUI::HBLUE)) {
                    this.SendCommand(this.getCommandID("put to blue"), pick_params);
                }
                scoreboard_pos.x += pick_button_width;
            }
            if (team_num != red_team_num) {
                if (IMGUI::Button("RED", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::RED, IMGUI::HRED)) {
                    this.SendCommand(this.getCommandID("put to red"), pick_params);
                }
                scoreboard_pos.x += pick_button_width;
            }
            if (team_num != spec_team_num) {
              if (IMGUI::Button("SPEC", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::DARK_GRAY, IMGUI::GRAY)) {
                    this.SendCommand(this.getCommandID("put to spec"), pick_params);
                    scoreboard_pos.x += pick_button_width;
                }
            }
        } else if (local_player.getUsername() == this.get_string("team_"+local_team_num+"_leader") && username != local_username) {
            if (team_num == local_team_num) {
                if (IMGUI::Button("SPEC", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::DARK_GRAY, IMGUI::GRAY)) {
                    this.SendCommand(this.getCommandID("put to spec"), pick_params);
                }
            }
            if (team_num == spec_team_num) {
                if (local_team_num == blue_team_num && IMGUI::Button("PICK", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::BLUE, IMGUI::HBLUE)) {
                    this.SendCommand(this.getCommandID("put to blue"), pick_params);
                }
                if (local_team_num == red_team_num && IMGUI::Button("PICK", scoreboard_pos, scoreboard_pos + Vec2f(pick_button_width, row_height), IMGUI::RED, IMGUI::HRED)) {
                    this.SendCommand(this.getCommandID("put to red"), pick_params);
                }
            }
        }
    }
}
