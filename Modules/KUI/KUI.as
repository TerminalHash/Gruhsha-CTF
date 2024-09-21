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
const int       keybind_w = 100;

const int       spacing = 2;

namespace Colors {

const SColor    FG = SColor(0xFFFFFFFF);

}

////////////// VARIABLES //////////////

// Input
CControls@      controls = getControls();
int             current_id = 0;
int             pressed_id = 0;
int             hovered_id = 0;
int             selected_id = 0;
bool            hovered = false;
bool            pressed = false;
bool            selected = false;

// Screen space //
Vec2f           screen_tl = Vec2f_zero;
Vec2f           screen_br = Vec2f_zero;

// Window space //
Vec2f           window_tl = Vec2f_zero;
Vec2f           window_br = Vec2f_zero;

// Canvas space //
Vec2f           canvas_tl = Vec2f_zero;
Vec2f           canvas_br = Vec2f_zero;

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
    current_id = 0;
    screen_tl = tl;
    screen_br = br;
    window_tl = screen_tl;
    window_br = screen_br;
    canvas_tl = screen_tl;
    canvas_br = screen_br;
}

void End() {
    GUI::SetFont("menu");
    current_id = 0;
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
    if (controls is null) return 0;
    if(tabs.length() != 0) {
        int tab_w = (window_br.x - window_tl.x) / tabs.length();

        for (int i = 0; i < tabs.length(); i++) {
            Vec2f tl = Vec2f(window_tl.x + i*tab_w, window_tl.y);
            Vec2f br = Vec2f(window_tl.x + (i+1)*tab_w, window_tl.y + tab_h);

            Vec2f mouse_pos = controls.getMouseScreenPos();
            bool press = controls.mousePressed1;
            bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;

            string tab_title = tabs[i];

            if (i != tab) {
                if (hover) {
                    if (press) {
                        DrawButtonPressed(tl, br, tab_title);
                        if (!pressed) {
                            Sound::Play("buttonclick");
                            pressed = true;
                            tab = i;
                        }
                    } else {
                        DrawButtonHovered(tl, br, tab_title);
                        pressed = false;
                    }
                } else {
                    DrawButtonDefault(tl, br, tab_title);
                }
            } else {
                DrawButtonPressed(tl, br, tab_title);
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

bool Button(string title = "") {
    Vec2f tl = canvas_tl;
    Vec2f br = Vec2f(canvas_br.x, canvas_tl.y + button_h);

    bool result = ButtonGeneral(tl, br, title);

    canvas_tl.y += button_h + spacing;
    return result;
}

bool ButtonGeneral(Vec2f tl, Vec2f br, string title = "") {
    if (controls is null) return false;

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
    bool result = false;

    if (hover) {
        if (press) {
            DrawButtonPressed(tl, br, title);
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                result = true;
            }
        } else {
            DrawButtonHovered(tl, br, title);
            pressed = false;
        }
    } else {
        DrawButtonDefault(tl, br, title);
    }

    return result;
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
    if (controls is null) return false;
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
    bool result = false;

    if (hover) {
        if (press) {
            DrawButtonIconPressed(tl, br, icon_name, icon_size, icon_index);
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                result = true;
            }
        } else {
            DrawButtonIconHovered(tl, br, icon_name, icon_size, icon_index);
            pressed = false;
        }
    } else {
        DrawButtonIconDefault(tl, br, icon_name, icon_size, icon_index);
    }

    return result;
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
    if (controls is null) return toggle;

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
    if (controls is null) return stepper;

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
    if (controls is null) return key;

    Vec2f tl = canvas_tl;
    Vec2f br = canvas_tl + Vec2f(keybind_w, keybind_h);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press and !selected) {
            DrawButtonPressed(tl, br, _Keyname(key));
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                selected = true;
            }
        } else {
            if (selected) {
                DrawButtonPressed(tl, br, _Keyname(key));
                for (int i = 1; i <= 512; i++) {
                    if (i == EKEY_CODE::KEY_LBUTTON) continue;
                     bool key_pressed = controls.isKeyPressed(i);
                    if (!key_pressed) continue;
                    key = i;
                    selected = false;
                    break;
                }
            } else {
                DrawButtonHovered(tl, br, _Keyname(key));
                pressed = false;
            }
        }
    } else {
        DrawButtonDefault(tl, br, _Keyname(key));
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y + keybind_h / 2 - text_h / 2 - 1), Colors::FG);
    canvas_tl.y += keybind_h + spacing;
    return key;
}

string _Keyname(int key)
{
    switch (key)
    {
        case EKEY_CODE::KEY_LBUTTON:           return "LMB";
        case EKEY_CODE::KEY_RBUTTON:           return "RMB";
        case EKEY_CODE::KEY_MBUTTON:           return "MIDDLE CLICK";
        case EKEY_CODE::KEY_CANCEL:            return "CANCEL";
        case EKEY_CODE::KEY_XBUTTON1:          return "X1MB";
        case EKEY_CODE::KEY_XBUTTON2:          return "X2MB";
        case EKEY_CODE::KEY_BACK:              return "BACK";
        case EKEY_CODE::KEY_TAB:               return "TAB";
        case EKEY_CODE::KEY_CLEAR:             return "CLEAR";
        case EKEY_CODE::KEY_RETURN:            return "RETURN";
        case EKEY_CODE::KEY_SHIFT:             return "SHIFT";
        case EKEY_CODE::KEY_CONTROL:           return "CONTROL";
        case EKEY_CODE::KEY_MENU:              return "MENU";
        case EKEY_CODE::KEY_PAUSE:             return "PAUSE";
        case EKEY_CODE::KEY_CAPITAL:           return "CAPS LOCK";
        case EKEY_CODE::KEY_ESCAPE:            return "ESC";
        case EKEY_CODE::KEY_SPACE:             return "SPACE";
        case EKEY_CODE::KEY_PRIOR:             return "PRIOR";
        case EKEY_CODE::KEY_NEXT:              return "NEXT";
        case EKEY_CODE::KEY_END:               return "END";
        case EKEY_CODE::KEY_HOME:              return "HOME";
        case EKEY_CODE::KEY_LEFT:              return "LEFT";
        case EKEY_CODE::KEY_UP:                return "UP";
        case EKEY_CODE::KEY_RIGHT:             return "RIGHT";
        case EKEY_CODE::KEY_DOWN:              return "DOWN";
        case EKEY_CODE::KEY_SELECT:            return "SELECT";
        case EKEY_CODE::KEY_PRINT:             return "PRNTSCR";
        case EKEY_CODE::KEY_EXECUT:            return "EXECUTE";
        case EKEY_CODE::KEY_INSERT:            return "INSERT";
        case EKEY_CODE::KEY_DELETE:            return "DEL";
        case EKEY_CODE::KEY_HELP:              return "HELP";
        case EKEY_CODE::KEY_KEY_0:             return "0";
        case EKEY_CODE::KEY_KEY_1:             return "1";
        case EKEY_CODE::KEY_KEY_2:             return "2";
        case EKEY_CODE::KEY_KEY_3:             return "3";
        case EKEY_CODE::KEY_KEY_4:             return "4";
        case EKEY_CODE::KEY_KEY_5:             return "5";
        case EKEY_CODE::KEY_KEY_6:             return "6";
        case EKEY_CODE::KEY_KEY_7:             return "7";
        case EKEY_CODE::KEY_KEY_8:             return "8";
        case EKEY_CODE::KEY_KEY_9:             return "9";
        case EKEY_CODE::KEY_KEY_A:             return "A";
        case EKEY_CODE::KEY_KEY_B:             return "B";
        case EKEY_CODE::KEY_KEY_C:             return "C";
        case EKEY_CODE::KEY_KEY_D:             return "D";
        case EKEY_CODE::KEY_KEY_E:             return "E";
        case EKEY_CODE::KEY_KEY_F:             return "F";
        case EKEY_CODE::KEY_KEY_G:             return "G";
        case EKEY_CODE::KEY_KEY_H:             return "H";
        case EKEY_CODE::KEY_KEY_I:             return "I";
        case EKEY_CODE::KEY_KEY_J:             return "J";
        case EKEY_CODE::KEY_KEY_K:             return "K";
        case EKEY_CODE::KEY_KEY_L:             return "L";
        case EKEY_CODE::KEY_KEY_M:             return "M";
        case EKEY_CODE::KEY_KEY_N:             return "N";
        case EKEY_CODE::KEY_KEY_O:             return "O";
        case EKEY_CODE::KEY_KEY_P:             return "P";
        case EKEY_CODE::KEY_KEY_Q:             return "Q";
        case EKEY_CODE::KEY_KEY_R:             return "R";
        case EKEY_CODE::KEY_KEY_S:             return "S";
        case EKEY_CODE::KEY_KEY_T:             return "T";
        case EKEY_CODE::KEY_KEY_U:             return "U";
        case EKEY_CODE::KEY_KEY_V:             return "V";
        case EKEY_CODE::KEY_KEY_W:             return "W";
        case EKEY_CODE::KEY_KEY_X:             return "X";
        case EKEY_CODE::KEY_KEY_Y:             return "Y";
        case EKEY_CODE::KEY_KEY_Z:             return "Z";
        case EKEY_CODE::KEY_LWIN:              return "LWIN";
        case EKEY_CODE::KEY_RWIN:              return "RWIN";
        case EKEY_CODE::KEY_APPS:              return "APPS";
        case EKEY_CODE::KEY_SLEEP:             return "SLEEP";
        case EKEY_CODE::KEY_NUMPAD0:           return "NP0";
        case EKEY_CODE::KEY_NUMPAD1:           return "NP1";
        case EKEY_CODE::KEY_NUMPAD2:           return "NP2";
        case EKEY_CODE::KEY_NUMPAD3:           return "NP3";
        case EKEY_CODE::KEY_NUMPAD4:           return "NP4";
        case EKEY_CODE::KEY_NUMPAD5:           return "NP5";
        case EKEY_CODE::KEY_NUMPAD6:           return "NP6";
        case EKEY_CODE::KEY_NUMPAD7:           return "NP7";
        case EKEY_CODE::KEY_NUMPAD8:           return "NP8";
        case EKEY_CODE::KEY_NUMPAD9:           return "NP9";
        case EKEY_CODE::KEY_MULTIPLY:          return "MULTIPLY";
        case EKEY_CODE::KEY_ADD:               return "ADD";
        case EKEY_CODE::KEY_SEPARATOR:         return "SEPARATOR";
        case EKEY_CODE::KEY_SUBTRACT:          return "SUBTRACT";
        case EKEY_CODE::KEY_DECIMAL:           return "DECIMAL";
        case EKEY_CODE::KEY_DIVIDE:            return "DIVIDE";
        case EKEY_CODE::KEY_F1:                return "F1";
        case EKEY_CODE::KEY_F2:                return "F2";
        case EKEY_CODE::KEY_F3:                return "F3";
        case EKEY_CODE::KEY_F4:                return "F4";
        case EKEY_CODE::KEY_F5:                return "F5";
        case EKEY_CODE::KEY_F6:                return "F6";
        case EKEY_CODE::KEY_F7:                return "F7";
        case EKEY_CODE::KEY_F8:                return "F8";
        case EKEY_CODE::KEY_F9:                return "F9";
        case EKEY_CODE::KEY_F10:               return "F10";
        case EKEY_CODE::KEY_F11:               return "F11";
        case EKEY_CODE::KEY_F12:               return "F12";
        case EKEY_CODE::KEY_NUMLOCK:           return "NUMLOCK";
        case EKEY_CODE::KEY_SCROLL:            return "SCROLL";
        case EKEY_CODE::KEY_LSHIFT:            return "LSHIFT";
        case EKEY_CODE::KEY_RSHIFT:            return "RSHIFT";
        case EKEY_CODE::KEY_LCONTROL:          return "LCONTROL";
        case EKEY_CODE::KEY_RCONTROL:          return "RCONTROL";
        case EKEY_CODE::KEY_LMENU:             return "LALT";
        case EKEY_CODE::KEY_RMENU:             return "RALT";
        case EKEY_CODE::KEY_PLUS:              return "+";
        case EKEY_CODE::KEY_COMMA:             return ",";
        case EKEY_CODE::KEY_MINUS:             return "-";
        case EKEY_CODE::KEY_PERIOD:            return ".";
        case EKEY_CODE::KEY_PLAY:              return "PLAY";
        case EKEY_CODE::MOUSE_SCROLL_UP:       return "SCROLL UP";
        case EKEY_CODE::MOUSE_SCROLL_DOWN:     return "SCROLL DOWN";
        default:                               return "UNKNOWN";
    }

    return "";
}

}