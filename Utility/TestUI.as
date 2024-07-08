#include "EasyUI.as"

#define CLIENT_ONLY

EasyUI@ ui;

void onInit(CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    @ui = EasyUI();

    // текст для кнопки
    Label@ label = StandardLabel();
    label.SetText("Пень лох");
    label.SetAlignment(0.5, 0.5);

    // кнопка
    Button@ button = StandardButton(ui);
    button.SetMinSize(200, 30);
    button.AddComponent(label);

    // ползунок в списке
    Slider@ slider = StandardHorizontalSlider(ui);
    slider.SetMinSize(200, 30);

    // список
    List@ list = StandardList(ui);
    list.SetCellWrap(1); // количество столбцов
    list.SetMaxLines(10); // количество колонок
    list.SetSpacing(2, 2); // отступы между элементами
    list.SetAlignment(0.5,0.5); // выравнивание всего списка по центру экрана
    list.SetComponents({button, slider}); // добавление кнопки и ползунка в список

    ui.AddComponent(list);
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

    void Handle() {
        component.SetVisible(!component.isVisible());
    }
}
