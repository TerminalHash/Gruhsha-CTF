#define CLIENT_ONLY
#include "KUI.as"

const string SETTINGS_DIR  = "../Cache/";
const string SETTINGS_FILE = "GRUHSHA_settings.cfg";

bool    open = false;
int     tab = 0;

int     visual_camera_sway = 5;
bool    visual_smoke = true;
bool    visual_blood = true;

bool    sound_voicelines = false;
bool    sound_tags = true;
bool    sound_bushes_and_leafs = false;

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

    visual_camera_sway      = cfile.exists("visual_camera_sway"    ) ? cfile.read_s32 ("visual_camera_sway"    ) : visual_camera_sway;
    visual_smoke            = cfile.exists("visual_smoke"          ) ? cfile.read_bool("visual_smoke"          ) : visual_smoke;
    visual_blood            = cfile.exists("visual_blood"          ) ? cfile.read_bool("visual_blood"          ) : visual_blood;
    sound_voicelines        = cfile.exists("sound_voicelines"      ) ? cfile.read_bool("sound_voicelines"      ) : sound_voicelines;
    sound_tags              = cfile.exists("sound_tags"            ) ? cfile.read_bool("sound_tags"            ) : sound_tags;
    sound_bushes_and_leafs  = cfile.exists("sound_bushes_and_leafs") ? cfile.read_bool("sound_bushes_and_leafs") : sound_bushes_and_leafs;
}

void SettingsSave() {
    ConfigFile cfile;
    cfile.add_s32 ("visual_camera_sway",        visual_camera_sway      );
    cfile.add_bool("visual_smoke",              visual_smoke            );
    cfile.add_bool("visual_blood",              visual_blood            );
    cfile.add_bool("sound_voicelines",          sound_voicelines        );
    cfile.add_bool("sound_tags",                sound_tags              );
    cfile.add_bool("sound_bushes_and_leafs",    sound_bushes_and_leafs  );

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
    open = KUI::Window("SETTINGS", Vec2f(400, 600), window_config);
    if (!open) {
        SettingsSave();
        return;
    }

    tab = KUI::TabBar(tab, {"VISUAL", "SOUND"});
    switch (tab) {
    case 0:
        visual_camera_sway      = KUI::SliderInt(visual_camera_sway, "camera sway", 1, 5);
        visual_smoke            = KUI::Toggle(visual_smoke, "enable smoke");
        visual_blood            = KUI::Toggle(visual_blood, "enable blood");
        break;
    case 1:
        sound_voicelines        = KUI::Toggle(sound_voicelines, "voicelines");
        sound_tags              = KUI::Toggle(sound_tags, "tags");
        sound_bushes_and_leafs  = KUI::Toggle(sound_bushes_and_leafs, "bushes and leafs");
        break;
    }

    KUI::End();
}