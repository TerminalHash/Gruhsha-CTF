#include "ImGUI.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle1 = false;
bool toggle2 = false;
int tuner1 = 3;
int tuner2 = 8;

void onRender(CRules@ this) {
    float screen_width = getScreenWidth();
    ImGUI::Begin("Settings", Vec2f(screen_width / 2 - 200, 200), Vec2f(screen_width / 2 + 200, 600));
    ImGUI::Button("Button example 1");
    ImGUI::Text("Text example AMOGUS");
    ImGUI::Button("Button example 2");
    ImGUI::Text("Text example ABOBA");
    toggle1 = ImGUI::Toggle("Toggle example 1", toggle1);
    toggle2 = ImGUI::Toggle("Toggle example 2", toggle2);
    ImGUI::Text("Text example GRUHSHA");
    ImGUI::Button("Button Example 3");
    tuner1 = ImGUI::Tuner("Tuner example 1", tuner1, 0, 5);
    ImGUI::Text("Text example ImGUI");
    tuner2 = ImGUI::Tuner("Tuner example 2", tuner2, 4, 10);
    ImGUI::End();
}
