#include "KUI.as"

int tab = 0;
bool toggle1 = false;
bool toggle2 = true;
int tuner1 = 3;
int tuner2 = 15;
int key1 = EKEY_CODE::KEY_KEY_A;
int key2 = EKEY_CODE::KEY_RETURN;

void onRender(CRules@ this) {
    // WINDOW
    KUI::BeginConfig config1();
    config1.alignment = KUI::Alignment::CL;

    KUI::Begin("WINDOW", Vec2f(400, 400), config1);
    tab = KUI::Tabs(tab, {"TAB 0", "TAB 1", "TAB 2"});
    switch (tab) {
    case 0:
        KUI::Text("Text 1");
        KUI::Text("Text 2");
        if(KUI::Button("Button 1")) {/* press 1*/};
        if(KUI::Button("Button 2")) {/* press 2*/};
        break;
    case 1:
        toggle1 = KUI::Toggle("Toggle 1", toggle1);
        toggle2 = KUI::Toggle("Toggle 2", toggle2);
        break;
    case 2:
        tuner1 = KUI::Tuner("Tuner 1", tuner1, 1, 5);
        tuner2 = KUI::Tuner("Tuner 2", tuner2, 0, 20);
        key1 = KUI::Keybind("Keybind 1", key1);
        key2 = KUI::Keybind("Keybind 2", key2);
        break;
    }
    KUI::End();

    KUI::BeginConfig config2();
    config2.alignment = KUI::Alignment::CR;

    KUI::Begin("WINDOW", Vec2f(400, 400), config2);
    KUI::Text("Text 1");
    KUI::Text("Text 2");
    if(KUI::Button("Button 1")) {/* press 1*/};
    if(KUI::Button("Button 2")) {/* press 2*/};
    toggle1 = KUI::Toggle("Toggle 1", toggle1);
    toggle2 = KUI::Toggle("Toggle 2", toggle2);
    tuner1 = KUI::Tuner("Tuner 1", tuner1, 1, 5);
    tuner2 = KUI::Tuner("Tuner 2", tuner2, 0, 20);
    key1 = KUI::Keybind("Keybind 1", key1);
    key2 = KUI::Keybind("Keybind 2", key2);
    KUI::End();
}
