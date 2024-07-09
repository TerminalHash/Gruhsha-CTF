#include "EasyUI.as"

#define CLIENT_ONLY

EasyUI@ ui;
Pane@ blue_team;
Pane@ red_team;

void onInit(CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    @ui = EasyUI();

    Pane@ pane = StandardPane(ui, StandardPaneType::Framed);
    pane.SetMinSize(500, 500);
    pane.SetAlignment(0.5,0.5);
    
    ui.AddComponent(pane);
}

void onTick(CRules@ this) {
    ui.Update(); 
}

void onRender(CRules@ this) {
    if (ui is null) return;
    ui.Render();
   
}

// Пример обработки событий
class HideComponentHandler : EventHandler {
    private Component@ component;

    HideComponentHandler(Component@ component) {
        @this.component = component;
    }

    void Handle() {}
}
