#include "KUI.as"

array<string> window_names = {
    "Settings",
    "Maplist",
    "None"
};

array<string> settings_tab_names = {
    "VISUAL",
    "SOUND",
    "CONTROL"
};

array<string> settings_control_tab_names = {
   "EMOTES",
   "TAGS",
   "BLOCKS",
   "MISC"
};

array<string> maplist = {
    "4zK_Rorschach",
    "4zK_Stubs",
    "8x_Gloryhill2",
    "8x_Grounds",
    "Asu_DeadPlateau",
    "Biurza_Rule_Lawyering",
    "Ej_Chambers",
    "Ferrezinhre_Fagra",
    "Ferrezinhre_Hanged_Man_Hideout",
    "Ferrezinhre_Highlands",
    "Fuzzle_Stale",
    "HearthPlains",
    "JTG_FirstBadLands",
    "Joiken_CTF2",
    "Magmus_Holegmus",
    "Magmus_hangingmus_forum",
    "Mazey_Epic",
    "NewTortuga",
    "PUNK123_ChasmSpasm",
    "PUNK123_Nubtytown",
    "Punk123_SkinnedCastle",
    "Redshadow6_twinlakes",
    "Skinney_Crypt",
    "Skinney_Glitch",
    "Snatchmark",
    "bunnie_Elantris",
    "bunnie_Lech_Walesa",
    "bunnie_Luthadel",
    "mcrifel_Steppes",
    "mcrifel_fish"
};

int window = 0;

int settings_tab = 0;

bool settings_visual_smoke = true;
bool settings_visual_blood = true;
int  settings_visual_camera_sway = 5;

bool settings_sound_voicelines = false;
bool settings_sound_tags = true;
bool settings_sound_bushes_and_tree_leafs = false;

int  settings_control_tab = 0;
int  settings_control_emote1 = 0;
int  settings_control_tag1 = 0;
int  settings_control_wood_block = 0;
int  settings_control_pickup_drill = 0;

int maplist_current = 0;

void onRender(CRules@ this) {
    KUI::Begin();

    KUI::WindowConfig maplist_config();
    maplist_config.pos = Vec2f(400, 0);

    window = KUI::Switcher(window, window_names);
    switch (window) {
        case 0:
            KUI::Window("SETTINGS", Vec2f(400, 400));
            settings_tab = KUI::TabBar(settings_tab, settings_tab_names);
            switch (settings_tab) {
                case 0:
                    settings_visual_camera_sway = KUI::SliderInt(settings_visual_camera_sway, "Camera sway", 1, 10);
                    settings_visual_smoke = KUI::Toggle(settings_visual_smoke, "smoke");
                    settings_visual_blood = KUI::Toggle(settings_visual_blood, "blood");
                    break;
                case 1:
                    settings_sound_voicelines = KUI::Toggle(settings_sound_voicelines, "voicelines");
                    settings_sound_tags = KUI::Toggle(settings_sound_tags, "tags");
                    settings_sound_bushes_and_tree_leafs = KUI::Toggle(settings_sound_bushes_and_tree_leafs, "bushes and tree leafs");
                    break;
                case 2:
                    settings_control_tab = KUI::TabBar(settings_control_tab, settings_control_tab_names);
                    switch (settings_control_tab) {
                        case 0:
                            settings_control_emote1 = KUI::Keybind(settings_control_emote1, "emote 1");
                            KUI::Text("...");
                            break;
                        case 1:
                            settings_control_tag1 = KUI::Keybind(settings_control_tag1, "tag 1");
                            KUI::Text("...");
                            break;
                        case 2:
                            settings_control_wood_block = KUI::Keybind(settings_control_wood_block, "wood block");
                            KUI::Text("...");
                            break;
                        case 3:
                            settings_control_pickup_drill = KUI::Keybind(settings_control_pickup_drill, "pickup drill");
                            KUI::Text("...");
                            break;
                    }
                    break;
            }
            break;
        case 1:
            KUI::Window("MAPLIST", Vec2f(400, 400));
            maplist_current = KUI::List(maplist_current, maplist);
            KUI::Window(maplist[maplist_current], Vec2f(400, 400), maplist_config);
            if(KUI::Button("Load")) {
                LoadMap(maplist[maplist_current]);
            };
            KUI::Image(maplist[maplist_current]);
            break;

        case 2:
            break;
    }

    KUI::End();
}
