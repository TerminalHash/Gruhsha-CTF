#include "KUI.as"

void onInit(CRules@ this) {}

void onTick(CRules@ this) {}

bool toggle = false;
int tuner = 3;

void onRender(CRules@ this) {
    float screen_width = getScreenWidth();
    KUI::Begin("Window example", Vec2f(screen_width / 2 - 200, 200), Vec2f(screen_width / 2 + 200, 400));
    KUI::Text("Text example");
    KUI::Separator(10);
    KUI::Line();
    KUI::Button("Button example");
    toggle = KUI::Toggle("Toggle example", toggle);
    tuner = KUI::Tuner("Tuner example", tuner, 1, 10);
    KUI::End();
}
