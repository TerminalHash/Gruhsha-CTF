void onInit(CRules@ this) {
    onRestart(this);
}

void onRestart(CRules@ this) {
    if (!GUI::isFontLoaded("KUI")) {
         string ImGUI = CFileMatcher("KUI.ttf").getFirst();
         GUI::LoadFont("KUI", ImGUI, 14, true);
    }
}

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
const int       toggle_icon_t = 0;
const int       toggle_icon_f = 4;
const Vec2f     toggle_icon_sz = Vec2f(8,8);
const int       stepper_h = 16;
const int       stepper_icon_l = 8;
const int       stepper_icon_r = 12;
const Vec2f     stepper_icon_sz = Vec2f(8,8);
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
}

////////////// VARIABLES //////////////

// Indexing //
int         button_current   = 0;
int         button_hovered   = 0;
int         keybind_current  = 0;
int         keybind_selected = 0;

// Columns //
int         column_current = 0;
int         columns        = 1;

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

    columns = 1;

    button_current  = 0;
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

    columns = 1;

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

        if(ButtonIconGeneral(tl, br, icons, window_close_icon, window_close_icon_size)) return false;
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
                DrawButtonPressed(tl, br, title);
            }
        }

        window_tl.y += tab_h;
        canvas_tl.y += tab_h;
    }

    return tab;
}

void TableBegin(int columns) {
    table_columns = columns;
}

void TableEnd() {
    table_columns = 1;
}

void Spacing(int spacing) {
    canvas_tl.y += spacing;
}

void Text(string text) {
    GUI::DrawText(text, canvas_tl, Colors::FG);
    canvas_tl.y += text_h + spacing;
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

bool Toggle(bool toggle, string title = "") {
    Vec2f tl = canvas_tl;
    Vec2f br = canvas_tl + Vec2f(16, toggle_h);

    if (toggle) {
        if(ButtonIconGeneral(tl, br, icons, toggle_icon_t, toggle_icon_sz)) toggle = !toggle;
    } else {
        if(ButtonIconGeneral(tl, br, icons, toggle_icon_f, toggle_icon_sz)) toggle = !toggle;
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y), Colors::FG);

    canvas_tl.y += toggle_h + spacing;
    return toggle;
}

int Stepper(int stepper, string title = "", int min = 1, int max = 5) {
    Vec2f stepper_l_tl = canvas_tl;
    Vec2f stepper_l_br = canvas_tl + Vec2f(16, stepper_h);

    Vec2f stepper_val_dim;
    GUI::GetTextDimensions(""+max, stepper_val_dim);

    Vec2f stepper_r_tl = Vec2f(stepper_l_br.x + stepper_val_dim.x + 4, canvas_tl.y);
    Vec2f stepper_r_br = Vec2f(stepper_l_br.x + stepper_val_dim.x + 4, canvas_tl.y) + Vec2f(16, stepper_h);

    if (ButtonIconGeneral(stepper_l_tl, stepper_l_br, icons, stepper_icon_l, stepper_icon_sz)) stepper = Maths::Max(stepper - 1, min);
    if (ButtonIconGeneral(stepper_r_tl, stepper_r_br, icons, stepper_icon_r, stepper_icon_sz)) stepper = Maths::Min(stepper + 1, max);

    GUI::DrawTextCentered(""+stepper, Vec2f(stepper_l_br.x + (stepper_r_tl.x - stepper_l_br.x) / 2 - 2, stepper_l_tl.y + (stepper_r_br.y - stepper_l_tl.y) / 2 - 1), Colors::FG);
    GUI::DrawText(title, Vec2f(stepper_r_br.x + 4, canvas_tl.y), Colors::FG);
    canvas_tl.y += stepper_h + spacing;
    return stepper;
}

int Keybind(int key, string title = "") {
    keybind_current += 1;

    Vec2f tl = canvas_tl;
    Vec2f br = canvas_tl + Vec2f(keybind_w, keybind_h);
    string key_title = Input::controls.getKeyName(key);

    Input::controls.setButtonsLock(keybind_selected == 0 ? false : true);

    if (keybind_selected == keybind_current) {
        DrawButtonPressed(tl, br, key_title);
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