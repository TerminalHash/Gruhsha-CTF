#include "ImGUI.as"
#include "ScoreboardCommon.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle1 = false;
bool toggle2 = false;
int slider = 0;

void onRender(CRules@ this) {
    ImGUI::Begin("Settings", Vec2f(200, 200), Vec2f(600, 600));
    ImGUI::Button("Button Example 1");
    ImGUI::Text("Text example AMOGUS");
    ImGUI::Button("Button Example 2");
    ImGUI::Text("Text example ABOBA");
    toggle1 = ImGUI::Toggle("Toggle example 1", toggle1);
    toggle2 = ImGUI::Toggle("Toggle example 2", toggle2);
    ImGUI::Text("Text example PINEKST");
    ImGUI::Button("Button Example 3");

    slider = ImGUI::SliderInt("Slider example", slider, 1, 5);

    ImGUI::End();
}
