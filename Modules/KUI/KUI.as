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

const string ICONS = "KUI_Icons.png";

const int WINDOW_TITLE_HEIGHT = 26;
const int WINDOW_INDENT_R = 10;
const int WINDOW_INDENT_L = 10;
const int WINDOW_INDENT_T = 4;
const int WINDOW_CLOSE_ICON = 16;
const Vec2f WINDOW_CLOSE_ICON_SIZE = Vec2f(8,8);

const int TAB_HEIGHT = 26;

const int TEXT_HEIGHT = 16;
const int TEXT_INDENT = 4;

const int BUTTON_HEIGHT = 26;
const int BUTTON_INDENT = 4;

const int TOGGLE_HEIGHT = 16;
const int TOGGLE_ICON_T = 0;
const int TOGGLE_ICON_F = 4;
const Vec2f TOGGLE_ICON_SIZE = Vec2f(8,8);
const int TOGGLE_INDENT = 4;

const int TUNER_HEIGHT = 16;
const int TUNER_ICON_L = 8;
const int TUNER_ICON_R = 12;
const Vec2f TUNER_ICON_SIZE = Vec2f(8,8);
const int TUNER_INDENT = 4;

const int KEYBIND_HEIGHT = 26;
const int KEYBIND_WIDTH = 100;
const int KEYBIND_INDENT = 4;

namespace Colors {
    const SColor FG = SColor(0xFFFFFFFF);
}

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

Vec2f window_tl = Vec2f(0,0);
Vec2f window_br = Vec2f(0,0);
int window_draw_point = 0;

CControls@ controls = getControls();

bool pressed = false;
bool selected = false;

class BeginConfig {
    Alignment alignment = CC;
    Vec2f pos = Vec2f_zero;
    bool closable = false;
};

bool Begin(string title, Vec2f size, const BeginConfig config = BeginConfig()) {
    GUI::SetFont("KUI");

    // WINDOW ALIGNMENT
    Vec2f screen_size = Vec2f(getScreenWidth(), getScreenHeight());
    switch (config.alignment) {
        case TL:
            window_tl = Vec2f_zero;
            window_br = size;
            break;
        case TC:
            window_tl = Vec2f(screen_size.x / 2 - size.x / 2, 0);
            window_br = Vec2f(screen_size.x / 2 + size.x / 2, size.y);
            break;
        case TR:
            window_tl = Vec2f(screen_size.x - size.x, 0);
            window_br = Vec2f(screen_size.x, size.y);
            break;
        case CL:
            window_tl = Vec2f(0, screen_size.y / 2 - size.y / 2);
            window_br = Vec2f(size.x, screen_size.y / 2 + size.y / 2);
            break;
        case CC:
            window_tl = screen_size / 2 - size / 2;
            window_br = screen_size / 2 + size / 2;
            break;
        case CR:
            window_tl = Vec2f(screen_size.x - size.x, screen_size.y / 2 - size.y / 2);
            window_br = Vec2f(screen_size.x, screen_size.y / 2 + size.y / 2);
            break;
        case BL:
            window_tl = Vec2f(0, screen_size.y - size.y);
            window_br = Vec2f(size.x, screen_size.y);
            break;
        case BC:
            window_tl = Vec2f(screen_size.x / 2 - size.x / 2, screen_size.y - size.y);
            window_br = Vec2f(screen_size.x / 2 + size.x / 2, screen_size.y);
            break;
        case BR:
            window_tl = screen_size - size;
            window_br = screen_size;
            break;
    }

    window_tl += config.pos;
    window_br += config.pos;

    // WINDOW TITLE AND PANEL
    GUI::DrawFramedPane(window_tl, window_br);
    GUI::DrawPane(window_tl, Vec2f(window_br.x, window_tl.y + WINDOW_TITLE_HEIGHT));
    GUI::DrawText(title,
                  Vec2f(window_tl.x + WINDOW_INDENT_R, window_tl.y + WINDOW_TITLE_HEIGHT / 2 - TEXT_HEIGHT / 2 - 1),
                  Colors::FG);

    // WINDOW CLOSE BUTTON
    if (config.closable) {
        Vec2f tl = Vec2f(window_br.x - WINDOW_TITLE_HEIGHT, window_tl.y);
        Vec2f br = Vec2f(window_br.x, window_tl.y + WINDOW_TITLE_HEIGHT);
        if(ButtonIconGeneral(ICONS, tl, br, WINDOW_CLOSE_ICON, WINDOW_CLOSE_ICON_SIZE)) {
            return false;
        }
    }

    window_draw_point = window_tl.y + WINDOW_TITLE_HEIGHT;

    window_draw_point += WINDOW_INDENT_T;
    return true;
}

void End() {
    GUI::SetFont("menu");
    window_draw_point = 0;
    window_tl = Vec2f(0,0);
    window_br = Vec2f(0,0);
}

int Tabs(int tab, array<string> tabs) {
    if (controls is null) return 0;
    if(tabs.length() != 0) {
        int tab_width = (window_br.x - window_tl.x) / tabs.length();

        for (int i = 0; i < tabs.length(); i++) {
            Vec2f tl = Vec2f(window_tl.x + i*tab_width, window_tl.y + WINDOW_TITLE_HEIGHT);
            Vec2f br = Vec2f(window_tl.x + (i+1)*tab_width, window_tl.y + WINDOW_TITLE_HEIGHT + TAB_HEIGHT);

            Vec2f mouse_pos = controls.getMouseScreenPos();
            bool press = controls.mousePressed1;
            bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;

            string tab_title = tabs[i];

            if (i != tab) {
                if (hover) {
                    if (press) {
                        DrawButtonPressed(tab_title, tl, br);
                        if (!pressed) {
                            Sound::Play("buttonclick");
                            pressed = true;
                            tab = i;
                        }
                    } else {
                        DrawButtonHovered(tab_title, tl, br);
                        pressed = false;
                    }
                } else {
                    DrawButtonDefault(tab_title, tl, br);
                }
            } else {
                DrawButtonPressed(tab_title, tl, br);
            }
        }

        window_draw_point += TAB_HEIGHT;
    }

    return tab;
}

void Text(string text) {
    GUI::DrawText(text, Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point), Colors::FG);
    window_draw_point += TEXT_HEIGHT + TEXT_INDENT;
}

bool Button(string title) {
    Vec2f tl = Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point);
    Vec2f br = Vec2f(window_br.x - WINDOW_INDENT_L, window_draw_point + BUTTON_HEIGHT);

    bool result = ButtonGeneral(title, tl, br);

    window_draw_point += BUTTON_HEIGHT + BUTTON_INDENT;
    return result;
}

bool ButtonGeneral(string title, Vec2f tl, Vec2f br) {
    if (controls is null) return false;

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
    bool result = false;

    if (hover) {
        if (press) {
            DrawButtonPressed(title, tl, br);
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                result = true;
            }
        } else {
            DrawButtonHovered(title, tl, br);
            pressed = false;
        }
    } else {
        DrawButtonDefault(title, tl, br);
    }

    return result;
}

void DrawButtonDefault(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButton(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

void DrawButtonHovered(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButtonHover(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

void DrawButtonPressed(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButtonPressed(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
}

bool ButtonIconGeneral(string icon_name, Vec2f tl, Vec2f br, int icon_index, Vec2f icon_size = Vec2f(8,8)) {
    if (controls is null) return false;
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool press = controls.mousePressed1;
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool result = false;

    if (hover) {
        if (press) {
            DrawButtonIconPressed(icon_name, tl, br, icon_size, icon_index);
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                result = true;
            }
        } else {
            DrawButtonIconHovered(icon_name, tl, br, icon_size, icon_index);
            pressed = false;
        }
    } else {
        DrawButtonIconDefault(icon_name, tl, br, icon_size, icon_index);
    }

    return result;
}

void DrawButtonIconDefault(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 0, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

void DrawButtonIconHovered(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 1, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

void DrawButtonIconPressed(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawIcon(icon_name, icon_index + 2, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

bool Toggle(string title, bool toggle) {
    if (controls is null) return toggle;

    Vec2f tl = Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point);
    Vec2f br = Vec2f(window_tl.x + WINDOW_INDENT_R + 16, window_draw_point + TOGGLE_HEIGHT);

    if (toggle) {
        if(ButtonIconGeneral(ICONS, tl, br, TOGGLE_ICON_T, TOGGLE_ICON_SIZE)) toggle = !toggle;
    } else {
        if(ButtonIconGeneral(ICONS, tl, br, TOGGLE_ICON_F, TOGGLE_ICON_SIZE)) toggle = !toggle;
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y), Colors::FG);

    window_draw_point = br.y + TOGGLE_INDENT;
    return toggle;
}

int Tuner(string title, int tuner, int min = 1, int max = 5) {
    if (controls is null) return tuner;

    Vec2f tuner_l_tl = Vec2f(window_tl.x + WINDOW_INDENT_L - 2, window_draw_point);
    Vec2f tuner_l_br = Vec2f(window_tl.x + WINDOW_INDENT_L - 2 + 16, window_draw_point + TUNER_HEIGHT);

    Vec2f tuner_value_dim;
    GUI::GetTextDimensions(""+max, tuner_value_dim);

    Vec2f tuner_r_tl = Vec2f(tuner_l_br.x + tuner_value_dim.x + 4, window_draw_point);
    Vec2f tuner_r_br = Vec2f(tuner_l_br.x + tuner_value_dim.x + 4 + 16, window_draw_point + TUNER_HEIGHT);

    if (ButtonIconGeneral(ICONS, tuner_l_tl, tuner_l_br, TUNER_ICON_L, TUNER_ICON_SIZE)) tuner = Maths::Max(tuner - 1, min);
    if (ButtonIconGeneral(ICONS, tuner_r_tl, tuner_r_br, TUNER_ICON_R, TUNER_ICON_SIZE)) tuner = Maths::Min(tuner + 1, max);

    GUI::DrawTextCentered(""+tuner, Vec2f(tuner_l_br.x + (tuner_r_tl.x - tuner_l_br.x) / 2 - 2, tuner_l_tl.y + (tuner_r_br.y - tuner_l_tl.y) / 2 - 1), Colors::FG);
    GUI::DrawText(title, Vec2f(tuner_r_br.x + 4, window_draw_point), Colors::FG);
    window_draw_point += TUNER_HEIGHT + TUNER_INDENT;
    return tuner;
}

int Keybind(string title, int key) {
    if (controls is null) return key;

    Vec2f tl = Vec2f(window_tl.x + WINDOW_INDENT_L, window_draw_point);
    Vec2f br = Vec2f(window_tl.x + WINDOW_INDENT_L + KEYBIND_WIDTH, window_draw_point + KEYBIND_HEIGHT);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            DrawButtonPressed(Keyname(key), tl, br);
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
            }

            for (int i = 1; i <= 512; i++) {
                if (i == EKEY_CODE::KEY_LBUTTON) continue;
                bool key_pressed = controls.isKeyPressed(i);
                if (!key_pressed) continue;
                key = i;
                break;
            }
        } else {
            DrawButtonHovered(Keyname(key), tl, br);
            pressed = false;
        }
    } else {
        DrawButtonDefault(Keyname(key), tl, br);
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y + KEYBIND_HEIGHT / 2 - TEXT_HEIGHT / 2 - 1), Colors::FG);
    window_draw_point += KEYBIND_HEIGHT + KEYBIND_INDENT;
    return key;
}

string Keyname(int key)
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

void Indentation(int indentation) {
    window_draw_point += indentation;
}

void Line() {
    Vec2f p1 = Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point);
    Vec2f p2 = Vec2f(window_br.x - WINDOW_INDENT_L, window_draw_point);
    GUI::DrawLine2D(p1, p2, Colors::FG);
    window_draw_point += 4;
}

}