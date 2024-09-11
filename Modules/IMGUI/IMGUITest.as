#include "IMGUI.as"
#include "ScoreboardCommon.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle1 = false;
bool toggle2 = false;
float slider = 0.5;

void onRender(CRules@ this) {
    IMGUI::Begin("Settings", Vec2f(200, 200), Vec2f(600, 600));
    IMGUI::ButtonConfig button_config();
    button_config.color_hover = IMGUI::RED;
    IMGUI::Button("PRESS if you are Gay", button_config);
    IMGUI::Text("Pnext ЛОХ");
    IMGUI::Button("PRESS if you are not Gay");
    IMGUI::Text("Terminal ЛОХ");
    toggle1 = IMGUI::Toggle("Ставь галочку если ты реальный пидор", toggle1);
    IMGUI::Text("Kusaka ЛОХ");
    toggle2 = IMGUI::Toggle("Ставь галочку если ты реальный гей", toggle2);
    IMGUI::Button("JUST PRESS IDIOT");

    //    IMGUI::SliderConfig slider_config();
    //    slider_config.min = 0.0;
    //    slider_config.max = 1.0;
    //    slider = IMGUI::Slider("slider exaple", slider, slider_config);
    
    IMGUI::End();
}
