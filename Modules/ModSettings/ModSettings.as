#define CLIENT_ONLY
#include "KUI.as"

const string SETTINGS_DIR  = "../Cache/";
const string SETTINGS_FILE = "GRUHSHA_settings.cfg";

bool    open = false;
int     tab = 0;

float   visual_camera_sway = 5;
bool    visual_enable_smoke = true;
bool    visual_enable_blood = true;

bool    sound_voicelines = false;
bool    sound_tags = true;
bool    sound_bushes_and_tree_leafs = false;

int     control_tab = 0;
int     control_emote1 = 0;
int     control_tag1 = 0;
int     control_wood_block = 0;
int     control_pickup_drill = 0;

void onMainMenuCreated(CRules@ rules, CContextMenu@ menu) {
    if (getLocalPlayer().getUsername() == "kusaka79")
        Menu::addContextItem(menu, "Mod Settings", getCurrentScriptName(), "void SettingsOpen()");
}

void SettingsOpen() {
    CPlayer@ player = getLocalPlayer();
    if (player is null || !player.isMyPlayer()) return;
    Menu::CloseAllMenus();
    SettingsLoad();
    open = true;
}

void SettingsLoad() {
    ConfigFile cfile;
    if (cfile.loadFile(SETTINGS_DIR+SETTINGS_FILE)) {
        printf(SETTINGS_FILE+" found");
    } else {
        printf(SETTINGS_FILE+" not found");
    }

    visual_camera_sway = cfile.exists("visual_enable_smoke") ? cfile.read_f32("visual_camera_sway") : 5.0;
    visual_enable_smoke = cfile.exists("visual_enable_smoke") ? cfile.read_bool("visual_enable_smoke") : true;
    visual_enable_blood = cfile.exists("visual_enable_blood") ? cfile.read_bool("visual_enable_blood") : true;
}

void SettingsSave() {
    CRules@ rules = getRules();

    ConfigFile cfile;

    cfile.add_f32("visual_camera_sway", visual_camera_sway);
    cfile.add_bool("visual_enable_smoke", visual_enable_smoke);
    cfile.add_bool("visual_enable_blood", visual_enable_blood);

    if (cfile.saveFile(SETTINGS_FILE)) {
        printf(SETTINGS_FILE+" saved");
    } else {
        printf(SETTINGS_FILE+" not saved!");
    }
}

void onRender(CRules@ rules) {
    if (!open) return;

    KUI::Begin();

    KUI::WindowConfig window_config;
    window_config.closable = true;
    open = KUI::Window("SETTINGS", Vec2f(500, 700), window_config);
    if (!open) {
        SettingsSave();
        return;
    }

    tab = KUI::TabBar(tab, {"VISUAL", "SOUND", "CONTROL"});
    switch (tab) {
    case 0:
        visual_camera_sway =  KUI::SliderFloat(visual_camera_sway, "camera sway", 1, 10);
        visual_enable_smoke = KUI::Toggle(visual_enable_smoke, "enable smoke");
        visual_enable_blood = KUI::Toggle(visual_enable_blood, "enable blood");
        break;
    case 1:
        sound_voicelines = KUI::Toggle(sound_voicelines, "voicelines");
        sound_tags = KUI::Toggle(sound_tags, "tags");
        sound_bushes_and_tree_leafs = KUI::Toggle(sound_bushes_and_tree_leafs, "bushes and tree leafs");
        break;
    case 2:
        control_tab = KUI::TabBar(control_tab, {"EMOTES", "TAGS", "BLOCKS", "MISC"});
        switch (control_tab) {
        case 0:
            control_emote1 = KUI::Keybind(control_emote1, "emote 1");
            KUI::Text("...");
            break;
        case 1:
            control_tag1 = KUI::Keybind(control_tag1, "tag 1");
            KUI::Text("...");
            break;
        case 2:
            control_wood_block = KUI::Keybind(control_wood_block, "wood block");
            KUI::Text("...");
            break;
        case 3:
            control_pickup_drill = KUI::Keybind(control_pickup_drill, "pickup drill");
            KUI::Text("...");
            break;
        }
        break;
    }

    KUI::End();
}