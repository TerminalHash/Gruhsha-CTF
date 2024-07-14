#include "IMGUI.as"

void onInit(CRules@ this) {}

void inTick(CRules@ this) {}

void onRender(CRules@ this) {

    CPlayer@ local = getLocalPlayer();

	const Vec2f start_pos = Vec2f(200, 200);
	const Vec2f tile_size = Vec2f(100, 32);
	Vec2f pos = start_pos;

	string[] columns = {
	    "NICKNAME",
	    "USERNAME"
	};

	// НАЗВАНИЯ СТРОК
	for (u32 i = 0; i < columns.length; i++) {
	    IMGUI::Panel(columns[i], pos, pos + tile_size, IMGUI::GRAY);
		pos.x += tile_size.x;
	}

	pos.x = start_pos.x;
	pos.y += tile_size.y;
	
    for (u32 i = 0; i < columns.length; i++) {
        if (columns[i] == "USERNAME") {
		    IMGUI::Panel(local.getCharacterName(), pos, pos + tile_size, IMGUI::GRAY);
        } else if (columns[i] == "NICKNAME"){
		    IMGUI::Panel(local.getUsername(), pos, pos + tile_size, IMGUI::GRAY);
        }
		pos.x += tile_size.x;
	}
}
