#include "KUI.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle1 = false;
bool toggle2 = true;
int tuner1 = 3;
int tuner2 = 15;
int key1 = EKEY_CODE::KEY_KEY_A;
int key2 = EKEY_CODE::KEY_XBUTTON1;

void onRender(CRules@ this) {
    // WINDOW
    float screen_width = getScreenWidth();
    KUI::Begin("Window example", Vec2f(screen_width / 2 - 200, 200), Vec2f(screen_width / 2 + 200, 600));

    // TEXT
    KUI::Text("Text example 1");
    KUI::Text("Text example 2");

    // BUTTONS
    if(KUI::Button("Button example 1")) {/* press 1*/};
    if(KUI::Button("Button example 2")) {/* press 2*/};

    // TOGGLES
    toggle1 = KUI::Toggle("Toggle example 1", toggle1);
    toggle2 = KUI::Toggle("Toggle example 2", toggle2);

    // TUNERS
    tuner1 = KUI::Tuner("Tuner example 1", tuner1, 1, 5);
    tuner2 = KUI::Tuner("Tuner example 2", tuner2, 0, 20);

    // KEYBINDS
    key1 = KUI::Keybind("Keybind example 1", key1);
    key2 = KUI::Keybind("Keybind example 2", key2);

    KUI::End();
}
