#include "IMGUI.as"

void onInit(CRules@ this) {}

void inTick(CRules@ this) {}

void onRender(CRules@ this) {
    if(IMGUI::Button("НАЖАТЬ ХУЕТУ", Vec2f(200, 200), Vec2f(350, 250))) {
        IMGUI::Panel("ХУЕТА НАЖАТА", Vec2f(200, 250), Vec2f(350, 300), RED);
    }
}
