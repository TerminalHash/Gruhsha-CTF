#include "ImGUI.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle = false;
int tuner = 3;

void onRender(CRules@ this) {
    float screen_width = getScreenWidth();
    ImGUI::Begin("Settings", Vec2f(screen_width / 2 - 200, 200), Vec2f(screen_width / 2 + 200, 400));
    ImGUI::Text("Text example");
    ImGUI::Separator(10);
    ImGUI::Button("Button example");
    toggle = ImGUI::Toggle("Toggle example", toggle);
    ImGUI::Line();
    tuner = ImGUI::Tuner("Tuner example", tuner, 1, 10);
    ImGUI::End();
}
