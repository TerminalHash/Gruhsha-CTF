#include "EasyUI.as"

#define CLIENT_ONLY

EasyUI@ ui;

// BLUE
const SColor blue_color = SColor(0xFF1A6F9E);

Label@ blue_name_label;
List@ blue_scoreboard;
Pane@ blue_pane;

// RED
const SColor red_color = SColor(0xFFBA2721);

Label@ red_name_label;
List@ red_scoreboard;
Pane@ red_pane;

// SPEC
Label@ spec_name_label;
List@ spec_scoreboard;
Pane@ spec_pane;

List@ scoreboards;

void onInit(CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    @ui = EasyUI();

    @blue_name_label = StandardLabel();
    blue_name_label.SetFont("Balkara_Condensed");
    blue_name_label.SetText("ЯЩЕРЫ");

    @blue_scoreboard = StandardList(ui);
    blue_scoreboard.SetScrollIndex(1);
    blue_scoreboard.SetCellWrap(1);
    blue_scoreboard.AddComponent(blue_name_label);

    @blue_pane = StandardPane(ui, blue_color);
    blue_pane.SetMinSize(1200, 100);
    blue_pane.SetAlignment(0.5,0.0);
    blue_pane.AddComponent(blue_scoreboard);
    
    @red_name_label = StandardLabel();
    red_name_label.SetFont("Balkara_Condensed");
    red_name_label.SetText("РУСЫ");

    @red_scoreboard = StandardList(ui);
    red_scoreboard.SetScrollIndex(1);
    red_scoreboard.SetCellWrap(1);
    red_scoreboard.AddComponent(red_name_label);

    @red_pane = StandardPane(ui, red_color);
    red_pane.SetMinSize(1200, 100);
    red_pane.SetAlignment(0.5,0.0);
    red_pane.AddComponent(red_scoreboard);
        
    @spec_name_label = StandardLabel();
    spec_name_label.SetFont("Balkara_Condensed");
    spec_name_label.SetText("ЛОХИ");

    @spec_scoreboard = StandardList(ui);
    spec_scoreboard.SetScrollIndex(1);
    spec_scoreboard.SetCellWrap(1);
    spec_scoreboard.AddComponent(spec_name_label);

    @spec_pane = StandardPane(ui);
    spec_pane.SetMinSize(1200, 100);
    spec_pane.SetAlignment(0.5,0.0);
    spec_pane.AddComponent(spec_scoreboard);

    @scoreboards = StandardList();
    scoreboards.SetScrollIndex(1);
    scoreboards.SetMaxLines(3);
    scoreboards.SetCellWrap(1);
    scoreboards.SetAlignment(0.5,0.5);
    scoreboards.SetSpacing(0, 20);
    scoreboards.SetComponents({blue_pane, red_pane, spec_pane});
    
    ui.AddComponent(scoreboards);

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
