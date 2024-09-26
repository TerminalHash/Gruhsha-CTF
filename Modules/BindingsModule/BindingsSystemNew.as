#include "KUI.as"

bool settings_open = false;
int  settings_tab = 0;
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

void onMainMenuCreated(CRules@ this, CContextMenu@ menu) {
    Menu::addContextItem(menu, "Gruhsha settings", getCurrentScriptName(), "void OpenSettings()");
}

void OpenSettings() {
    Menu::CloseAllMenus();
    settings_open = true;
}

void onRender(CRules@ this) {
    if (!settings_open) return;

    KUI::Begin();

    KUI::WindowConfig settings_window_config;
    settings_window_config.closable = true;
    settings_open = KUI::Window("SETTINGS", Vec2f(500, 700), settings_window_config);
    if (!settings_open) return;
    settings_tab = KUI::TabBar(settings_tab, {"VISUAL", "SOUND", "CONTROL"});
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
        settings_control_tab = KUI::TabBar(settings_control_tab, {"EMOTES", "TAGS", "BLOCKS", "MISC"});
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

    KUI::End();
}