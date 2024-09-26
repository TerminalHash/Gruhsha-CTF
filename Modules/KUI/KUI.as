namespace KUI {

////////////// CONTSANTS //////////////
const string    icons = "KUI_Icons.png";
const int       window_title_h = 24;
const Vec2f     window_inner_margin = Vec2f(8, 2);
const int       window_close_icon = 16;
const Vec2f     window_close_icon_size = Vec2f(8,8);
const int       tab_h = 24;
const int       text_h = 16;
const int       button_h = 24;
const int       toggle_h = 16;
const int       toggle_icon_f = 0;
const int       toggle_icon_t = 4;
const Vec2f     toggle_icon_sz = Vec2f(8,8);
const int       stepper_h = 16;
const int       stepper_icon_l = 8;
const int       stepper_icon_r = 12;
const Vec2f     stepper_icon_sz = Vec2f(8,8);
const int       slider_h = 24;
const int       dragger_h = 24;
const int       keybind_h = 24;
const int       keybind_w = 160;
const int       spacing = 2;

////////////// COLORS //////////////
namespace Colors {
    const SColor    FG = SColor(0xFFFFFFFF);
}

////////////// INPUT //////////////
namespace Input {
    CControls@      controls = getControls();

    bool            _now_press = false;
    bool            _was_press = false;

    void Update() {
        if(controls is null) return;

        _was_press = _now_press;
        _now_press = controls.mousePressed1;
    }

    bool IsPress() {
        return _now_press;
    }

    bool IsJustPressed() {
        return (_now_press and !_was_press) ? true : false;
    }

    bool IsJustReleased() {
        return (!_now_press and _was_press) ? true : false;
    }

    Vec2f GetCursorPos() {
        return controls.getMouseScreenPos();
    }

    void  SetCursorPos(Vec2f pos) {
        controls.setMousePosition(pos);
    }
}

////////////// VARIABLES //////////////

// Indexing //
int         button_current   = 0;
int         button_hovered   = 0;
int         slider_current   = 0;
int         slider_selected  = 0;
int         dragger_current  = 0;
int         dragger_selected = 0;
int         keybind_current  = 0;
int         keybind_selected = 0;

// Screen space //
Vec2f       screen_tl = Vec2f_zero;
Vec2f       screen_br = Vec2f_zero;

// Window space //
Vec2f       window_tl = Vec2f_zero;
Vec2f       window_br = Vec2f_zero;

// Canvas space //
Vec2f       canvas_tl = Vec2f_zero;
Vec2f       canvas_br = Vec2f_zero;

////////////// ENUMS //////////////

enum Alignment {
    TL, // TOP LEFT
    TC, // TOP CENTER
    TR, // TOP RIGHT
    CL, // CENTER LEFT
    CC, // CENTER CENTER
    CR, // CENTER RIGHT
    BL, // BOTTOM LEFT,
    BC, // BOTTOM CENTER,
    BR, // BOTTOM RIGHT
}

////////////// CLASSES //////////////

/*
class Rectangle() {
    Vec2f tl;
    Vec2f br;
}
*/

class WindowConfig {
    Alignment alignment = CC;
    Vec2f pos = Vec2f_zero;
    bool closable = false;
}

////////////// FUNCTIONS //////////////

void Begin(Vec2f tl = Vec2f_zero, Vec2f br = Vec2f(getScreenWidth(), getScreenHeight())) {
    GUI::SetFont("KUI");
    Input::Update();

    button_current  = 0;
    slider_current  = 0;
    dragger_current = 0;
    keybind_current = 0;

    screen_tl = tl;
    screen_br = br;
    window_tl = screen_tl;
    window_br = screen_br;
    canvas_tl = screen_tl;
    canvas_br = screen_br;
}

void End() {
    GUI::SetFont("menu");

    button_current  = 0;
    slider_current  = 0;
    dragger_current = 0;
    keybind_current = 0;

    screen_tl = Vec2f_zero;
    screen_br = Vec2f_zero;
    window_tl = Vec2f_zero;
    window_br = Vec2f_zero;
    canvas_tl = Vec2f_zero;
    canvas_br = Vec2f_zero;
}

bool Window(string title, Vec2f size, const WindowConfig config = WindowConfig()) {
    // WINDOW ALIGNMENT

    Vec2f screen_sz = screen_br - screen_tl;
    switch (config.alignment) {
        case TL:
            window_tl = Vec2f_zero;
            window_br = size;
            break;
        case TC:
            window_tl = Vec2f(screen_sz.x / 2 - size.x / 2, 0);
            window_br = Vec2f(screen_sz.x / 2 + size.x / 2, size.y);
            break;
        case TR:
            window_tl = Vec2f(screen_sz.x - size.x, 0);
            window_br = Vec2f(screen_sz.x, size.y);
            break;
        case CL:
            window_tl = Vec2f(0, screen_sz.y / 2 - size.y / 2);
            window_br = Vec2f(size.x, screen_sz.y / 2 + size.y / 2);
            break;
        case CC:
            window_tl = screen_sz / 2 - size / 2;
            window_br = screen_sz / 2 + size / 2;
            break;
        case CR:
            window_tl = Vec2f(screen_sz.x - size.x, screen_sz.y / 2 - size.y / 2);
            window_br = Vec2f(screen_sz.x, screen_sz.y / 2 + size.y / 2);
            break;
        case BL:
            window_tl = Vec2f(0, screen_sz.y - size.y);
            window_br = Vec2f(size.x, screen_sz.y);
            break;
        case BC:
            window_tl = Vec2f(screen_sz.x / 2 - size.x / 2, screen_sz.y - size.y);
            window_br = Vec2f(screen_sz.x / 2 + size.x / 2, screen_sz.y);
            break;
        case BR:
            window_tl = screen_sz - size;
            window_br = screen_sz;
            break;
    }

    window_tl += config.pos;
    window_br += config.pos;

    Vec2f cpos = Input::GetCursorPos();
    bool hover = cpos.x > window_tl.x && cpos.x < window_br.x && cpos.y > window_tl.y && cpos.y < window_br.y;

    Input::controls.setButtonsLock(hover ? true : false);

    // WINDOW TITLE AND PANEL
    GUI::DrawFramedPane(window_tl, window_br);
    GUI::DrawPane(window_tl, Vec2f(window_br.x, window_tl.y + window_title_h));
    GUI::DrawText(title,
                  Vec2f(window_tl.x + window_inner_margin.x, window_tl.y + window_title_h / 2 - text_h / 2 - 1),
                  Colors::FG);

    // WINDOW CLOSE BUTTON
    if (config.closable) {
        Vec2f tl = Vec2f(window_br.x - window_title_h,
                         window_tl.y);
        Vec2f br = Vec2f(window_br.x,
                         window_tl.y + window_title_h);

        if(ButtonIconGeneral(tl, br, icons, window_close_icon, window_close_icon_size)) {
            Input::controls.setButtonsLock(false);
            return false;
        }
    }

    window_tl += Vec2f(0, window_title_h);
    canvas_tl = window_tl + window_inner_margin;
    canvas_br = window_br - window_inner_margin;

    return true;
}

int TabBar(int tab, array<string> tabs) {
    if(tabs.length() != 0) {
        int w = (window_br.x - window_tl.x) / tabs.length();

        for (int i = 0; i < tabs.length(); i++) {
            Vec2f tl = Vec2f(window_tl.x + i*w, window_tl.y);
            Vec2f br = Vec2f(window_tl.x + (i+1)*w, window_tl.y + tab_h);

            string title = tabs[i];

            if (i != tab) {
                if (ButtonGeneral(tl, br, title)) tab = i;
            } else {
                DrawButtonSelected(tl, br, title);
            }
        }

        window_tl.y += tab_h;
        canvas_tl.y += tab_h;
    }

    return tab;
}

void Spacing(int spacing) {
    canvas_tl.y += spacing;
}

void Text(string text) {
    GUI::DrawText(text, canvas_tl, Colors::FG);
    canvas_tl.y += text_h + spacing;
}

void Image(string file) {
    Vec2f tl = canvas_tl;
    Vec2f dim;
    GUI::GetImageDimensions(file, dim);
    float scale = (canvas_br.x - canvas_tl.x) / dim.x / 2;

    GUI::DrawIcon(file, tl, scale);

    canvas_tl.y += dim.y * scale * 2 + spacing;
}

bool Button(string title = "") {
    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x, canvas_tl.y + button_h);

    bool result = ButtonGeneral(tl, br, title);

    canvas_tl.y += button_h + spacing;
    return result;
}

bool ButtonGeneral(Vec2f tl, Vec2f br, string title = "") {
    button_current += 1;

    Vec2f cpos = Input::GetCursorPos();
    if (cpos.x > tl.x && cpos.x < br.x && cpos.y > tl.y && cpos.y < br.y) {
        if (button_hovered != button_current) {
            button_hovered = button_current;
            Sound::Play("KUI_Hovered");
        }

        if (Input::IsPress()) {
            DrawButtonPressed(tl, br, title);
            if (Input::IsJustPressed()) {
                Sound::Play("KUI_Pressed");
                return true;
            }
        } else {
            DrawButtonHovered(tl, br, title);
        }
    } else {
        DrawButtonDefault(tl, br, title);
        if (button_hovered == button_current) button_hovered = 0;
    }
    return false;
}

void DrawButtonDefault(Vec2f tl, Vec2f br, string title = "") {
    GUI::DrawButton(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

void DrawButtonHovered(Vec2f tl, Vec2f br, string title = "") {
    GUI::DrawButtonHover(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

void DrawButtonPressed(Vec2f tl, Vec2f br, string title = "") {
    GUI::DrawButtonPressed(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

void DrawButtonSelected(Vec2f tl, Vec2f br, string title = "") {
    GUI::DrawSunkenPane(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

bool ButtonIconGeneral(Vec2f tl, Vec2f br, string icon_name, int icon_index, Vec2f icon_size = Vec2f(8,8)) {
    button_current += 1;

    Vec2f cpos = Input::GetCursorPos();
    if (cpos.x > tl.x && cpos.x < br.x && cpos.y > tl.y && cpos.y < br.y) {
        if (button_hovered != button_current) {
            button_hovered = button_current;
            Sound::Play("KUI_Hovered");
        }

        if (Input::IsPress()) {
            DrawButtonIconPressed(tl, br, icon_name, icon_size, icon_index);
            if (Input::IsJustPressed()) {
                Sound::Play("KUI_Pressed");
                return true;
            }
        } else {
            DrawButtonIconHovered(tl, br, icon_name, icon_size, icon_index);
        }
    } else {
        DrawButtonIconDefault(tl, br, icon_name, icon_size, icon_index);
        if (button_hovered == button_current) button_hovered = 0;
    }
    return false;
}

void DrawButtonIconDefault(Vec2f tl, Vec2f br, string icon_name, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 0, icon_size, tl + (br - tl - icon_size * 2) / 2, 1);
}

void DrawButtonIconHovered(Vec2f tl, Vec2f br, string icon_name, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 1, icon_size, tl + (br - tl - icon_size * 2) / 2, 1);
}

void DrawButtonIconPressed(Vec2f tl, Vec2f br, string icon_name, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 2, icon_size, tl + (br - tl - icon_size * 2) / 2, 1);
}

bool Toggle(bool value, string title = "") {
    Vec2f tl = canvas_tl;
    Vec2f br = canvas_tl + Vec2f(16, toggle_h);

    if (value) {
        if(ButtonIconGeneral(tl, br, icons, toggle_icon_t, toggle_icon_sz)) value = !value;
    } else {
        if(ButtonIconGeneral(tl, br, icons, toggle_icon_f, toggle_icon_sz)) value = !value;
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y), Colors::FG);

    canvas_tl.y += toggle_h + spacing;
    return value;
}

int Stepper(int value, string title = "", int min = 0, int max = 5, int step = 1) {
    Vec2f l_tl = canvas_tl;
    Vec2f l_br = canvas_tl + Vec2f(16, stepper_h);

    Vec2f value_dim;
    GUI::GetTextDimensions(""+max, value_dim);

    Vec2f r_tl = Vec2f(l_br.x + value_dim.x + 4, canvas_tl.y);
    Vec2f r_br = Vec2f(l_br.x + value_dim.x + 4, canvas_tl.y) + Vec2f(16, stepper_h);

    if (ButtonIconGeneral(l_tl, l_br, icons, stepper_icon_l, stepper_icon_sz)) value = Maths::Max(value - step, min);
    if (ButtonIconGeneral(r_tl, r_br, icons, stepper_icon_r, stepper_icon_sz)) value = Maths::Min(value + step, max);

    GUI::DrawTextCentered(""+value, Vec2f(l_br.x + (r_tl.x - l_br.x) / 2 - 2, l_tl.y + (r_br.y - l_tl.y) / 2 - 1), Colors::FG);
    GUI::DrawText(title, Vec2f(r_br.x + 4, canvas_tl.y), Colors::FG);
    canvas_tl.y += stepper_h + spacing;
    return value;
}

int Switcher(int index, array<string> titles) {
    Vec2f l_tl = canvas_tl;
    Vec2f l_br = canvas_tl + Vec2f(16, stepper_h);

    Vec2f r_tl = Vec2f(canvas_br.x - 16, canvas_tl.y);
    Vec2f r_br = Vec2f(canvas_br.x, canvas_tl.y + stepper_h);

    if (ButtonIconGeneral(l_tl, l_br, icons, stepper_icon_l, stepper_icon_sz)) index = Maths::Max(index - 1, 0);
    if (ButtonIconGeneral(r_tl, r_br, icons, stepper_icon_r, stepper_icon_sz)) index = Maths::Min(index + 1, titles.length() - 1);

    GUI::DrawTextCentered(""+titles[index], Vec2f(l_tl + (r_br - l_tl) / 2), Colors::FG);

    canvas_tl.y += stepper_h + spacing;
    return index;
}

int SliderInt(int value, string title, int min, int max) {
    slider_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x - (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + slider_h);

    Vec2f value_dim;
    GUI::GetTextDimensions(""+max, value_dim);
    int value_w = value_dim.x + 16;

    if (slider_selected == slider_current) {
        DrawButtonSelected(tl, br);

        value = (Maths::Clamp(Input::GetCursorPos().x, tl.x + value_w / 2, br.x - value_w / 2) - tl.x - value_w / 2) / (br.x - tl.x - value_w) * (max - min) + min;

        if (Input::IsJustReleased()) {
            slider_selected = 0;
        }
    } else if (ButtonGeneral(tl, br)) {
        slider_selected = slider_current;
    }

    Vec2f value_tl = Vec2f(tl.x + (br.x - tl.x - value_w) * (0.0 + value - min) / (max - min), tl.y);
    Vec2f value_br = Vec2f(tl.x + (br.x - tl.x - value_w) * (0.0 + value - min) / (max - min) + value_w, br.y);

    DrawButtonDefault(value_tl, value_br, ""+value);
    GUI::DrawText(title, Vec2f(br.x + 4, canvas_tl.y + dragger_h / 2 - text_h / 2 - 1), Colors::FG);

    canvas_tl.y += slider_h + spacing;
    return value;
}

float SliderFloat(float value, string title, float min, float max) {
    slider_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x - (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + slider_h);

    Vec2f value_dim;
    GUI::GetTextDimensions(formatFloat(max, "", 0, 2), value_dim);
    int value_w = value_dim.x + 16;

    if (slider_selected == slider_current) {
        DrawButtonSelected(tl, br);

        value = (Maths::Clamp(Input::GetCursorPos().x, tl.x + value_w / 2, br.x - value_w / 2) - tl.x - value_w / 2) / (br.x - tl.x - value_w) * (max - min) + min;

        if (Input::IsJustReleased()) {
            slider_selected = 0;
        }
    } else if (ButtonGeneral(tl, br)) {
        slider_selected = slider_current;
    }

    Vec2f value_tl = Vec2f(tl.x + (br.x - tl.x - value_w) * (value - min) / (max - min), tl.y);
    Vec2f value_br = Vec2f(tl.x + (br.x - tl.x - value_w) * (value - min) / (max - min) + value_w, br.y);

    DrawButtonDefault(value_tl, value_br, formatFloat(value, "", 0, 2));
    GUI::DrawText(title, Vec2f(br.x + 4, canvas_tl.y + dragger_h / 2 - text_h / 2 - 1), Colors::FG);

    canvas_tl.y += slider_h + spacing;
    return value;
}

int DraggerInt(int value, string title, int step = 1) {
    dragger_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x - (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + dragger_h);
    Vec2f center = tl + (br - tl) / 2;

    if(dragger_selected == dragger_current) {
        DrawButtonSelected(tl, br, ""+value);
        value -= (center.x - Input::GetCursorPos().x) * step;
        Input::SetCursorPos(center);
        if (Input::IsJustReleased()) {
            getHUD().ShowCursor();
            dragger_selected = 0;
        }
    } else if(ButtonGeneral(tl, br, ""+value)) {
        getHUD().HideCursor();
        dragger_selected = dragger_current;
        Input::SetCursorPos(center);
    }

    GUI::DrawText(title, Vec2f(br.x + 4, canvas_tl.y + dragger_h / 2 - text_h / 2 - 1), Colors::FG);

    canvas_tl.y += dragger_h + spacing;
    return value;
}

float DraggerFloat(float value, string title, float step = 0.01) {
    dragger_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x - (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + dragger_h);
    Vec2f center = tl + (br - tl) / 2;

    if(dragger_selected == dragger_current) {
        DrawButtonSelected(tl, br, formatFloat(value, "", 0, 2));
        value -= (center.x - Input::GetCursorPos().x) * step;
        Input::SetCursorPos(center);
        if (Input::IsJustReleased()) {
            getHUD().ShowCursor();
            dragger_selected = 0;
        }
    } else if(ButtonGeneral(tl, br, formatFloat(value, "", 0, 2))) {
        getHUD().HideCursor();
        dragger_selected = dragger_current;
        Input::SetCursorPos(center);
    }

    GUI::DrawText(title, Vec2f(br.x + 4, canvas_tl.y + dragger_h / 2 - text_h / 2 - 1), Colors::FG);

    canvas_tl.y += dragger_h + spacing;
    return value;
}

int List(int index, array<string> titles, int lines = 10) {

    int page_first = index / lines * lines;
    for(int i = 0; i < lines; i++) {
        Vec2f tl = Vec2f(canvas_tl.x, canvas_tl.y + i*button_h);
        Vec2f br = Vec2f(canvas_br.x, canvas_tl.y + i*button_h+button_h);

        if (page_first+i == index) {
            KUI::DrawButtonSelected(tl, br, titles[page_first+i]);
        } else if (KUI::ButtonGeneral(tl, br, titles[page_first+i])) {
            index = page_first+i;
        }
    }

    Vec2f prev_tl = Vec2f(canvas_tl.x, canvas_tl.y + lines*button_h);
    Vec2f prev_br = Vec2f(canvas_br.x - (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + lines*button_h+button_h);
    if (ButtonGeneral(prev_tl, prev_br, "<--")) {
        index = Maths::Clamp(index - lines, 0, titles.length() - 1);
    }

    Vec2f next_tl = Vec2f(canvas_tl.x + (canvas_br.x - canvas_tl.x) / 2, canvas_tl.y + lines*button_h);
    Vec2f next_br = Vec2f(canvas_br.x, canvas_tl.y + lines*button_h+button_h);
    if (ButtonGeneral(next_tl, next_br, "-->")) {
        index = Maths::Clamp(index + lines, 0, titles.length() - 1);
    }

    return index;
}

int Keybind(int key, string title) {
    keybind_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = canvas_tl + Vec2f(keybind_w, keybind_h);
    string key_title = Input::controls.getKeyName(key);

    if (keybind_selected == keybind_current) {
        DrawButtonSelected(tl, br, key_title);
        int last_key = Input::controls.lastKeyPressed;

        if (last_key != 0 and !Input::IsPress()) {
            key = last_key;
            keybind_selected = 0;
        }
    } else if (ButtonGeneral(tl, br, key_title)) {
        keybind_selected = keybind_current;
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y + keybind_h / 2 - text_h / 2 - 1), Colors::FG);
    canvas_tl.y += keybind_h + spacing;
    return key;
}

}