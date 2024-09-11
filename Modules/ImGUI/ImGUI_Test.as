#include "ImGUI.as"
#include "ScoreboardCommon.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle1 = false;
bool toggle2 = false;
float slider = 0.5;

void onRender(CRules@ this) {
    ImGUI::Begin("Settings", Vec2f(200, 200), Vec2f(600, 600));
    ImGUI::Button("PRESS if you are Gay");
    ImGUI::Text("Pnext ЛОХ");
    ImGUI::Button("PRESS if you are not Gay");
    ImGUI::Text("Terminal ЛОХ");
    toggle1 = ImGUI::Toggle("Ставь галочку если ты реальный пидор", toggle1);
    ImGUI::Text("Kusaka ЛОХ");
    toggle2 = ImGUI::Toggle("Ставь галочку если ты реальный гей", toggle2);
    ImGUI::Button("JUST PRESS IDIOT");

    //    IMGUI::SliderConfig slider_config();
    //    slider_config.min = 0.0;
    //    slider_config.max = 1.0;
    //    slider = IMGUI::Slider("slider exaple", slider, slider_config);
    
    ImGUI::End();
}
