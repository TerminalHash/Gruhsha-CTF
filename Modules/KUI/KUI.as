#include "KUI_Keybind.as"

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

const string ICONS_FILE_NAME = "KUI_Icons.png";

const int WINDOW_TITLE_HEIGHT = 26;
const int WINDOW_INDENT_R = 10;
const int WINDOW_INDENT_L = 10;
const int WINDOW_INDENT_T = 4;
const int WINDOW_CLOSE_ICON = 8;
const Vec2f WINDOW_CLOSE_ICON_SIZE = Vec2f(8,8);

const int TAB_HEIGHT = 26;

const int TEXT_HEIGHT = 16;
const int TEXT_INDENT = 4;

const int BUTTON_HEIGHT = 26;
const int BUTTON_INDENT = 4;

const int TOGGLE_HEIGHT = 16;
const Vec2f TOGGLE_ICON_SIZE = Vec2f(8,8);
const int TOGGLE_ICON = 0;
const int TOGGLE_ICON_ON = 1;
const int TOGGLE_ICON_HOVER = 2;
const int TOGGLE_INDENT = 4;

const int TUNER_HEIGHT = 16;
const Vec2f TUNER_ICON_SIZE = Vec2f(8,8);
const int TUNER_L_ICON = 4;
const int TUNER_R_ICON = 6;
const int TUNER_ICON_HOVER = 1;
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
        if(ButtonIconGeneral("KUI_Icons.png", tl, br, WINDOW_CLOSE_ICON_SIZE, WINDOW_CLOSE_ICON)) {
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

void Separator(float separator = 20) {
    window_draw_point += separator;
}

void Line() {
    Vec2f p1 = Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point);
    Vec2f p2 = Vec2f(window_br.x - WINDOW_INDENT_L, window_draw_point);
    GUI::DrawLine2D(p1, p2, Colors::FG);
    window_draw_point += 4;
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

bool ButtonIconGeneral(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
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

void DrawButtonIconDefault(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawButton(tl, br);
    GUI::DrawIcon(icon_name, icon_index, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

void DrawButtonIconHovered(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawButtonHover(tl, br);
    GUI::DrawIcon(icon_name, icon_index, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

void DrawButtonIconPressed(string icon_name, Vec2f tl, Vec2f br, Vec2f icon_size = Vec2f(8,8), int icon_index = 0) {
    GUI::DrawButtonPressed(tl, br);
    GUI::DrawIcon(icon_name, icon_index, icon_size, tl + (br - tl - icon_size * 2) / 2, 1, 0);
}

bool Toggle(string title, bool toggle) {
    if (controls is null) return toggle;

    Vec2f tl = Vec2f(window_tl.x + WINDOW_INDENT_R, window_draw_point);
    Vec2f br = Vec2f(window_br.x - WINDOW_INDENT_L, window_draw_point + TOGGLE_HEIGHT);

    int toggle_icon_index = TOGGLE_ICON;

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        toggle_icon_index = TOGGLE_ICON + TOGGLE_ICON_HOVER;
        if (press) {
            if (!pressed) {
                Sound::Play("buttonclick");
                pressed = true;
                toggle = !toggle;
            }
        } else {
            pressed = false;
        }
    }

    if (toggle) toggle_icon_index += TOGGLE_ICON_ON;

    GUI::DrawIcon(ICONS_FILE_NAME, toggle_icon_index, TOGGLE_ICON_SIZE, tl, 1, 0);
    GUI::DrawText(title, tl + Vec2f(TOGGLE_ICON_SIZE.x * 2 + 4, 0), Colors::FG);

    window_draw_point = br.y + TOGGLE_INDENT;
    return toggle;
}

int Tuner(string title, int tuner, int min = 1, int max = 5) {
    if (controls is null) return tuner;

    Vec2f tuner_l_tl = Vec2f(window_tl.x + WINDOW_INDENT_L, window_draw_point);
    Vec2f tuner_l_br = Vec2f(window_tl.x + WINDOW_INDENT_L + TUNER_ICON_SIZE.x * 2, window_draw_point + TUNER_HEIGHT);

    Vec2f tuner_value_dim;
    GUI::GetTextDimensions(max + "", tuner_value_dim);

    Vec2f tuner_r_tl = Vec2f(tuner_l_br.x + tuner_value_dim.x, window_draw_point);
    Vec2f tuner_r_br = Vec2f(tuner_l_br.x + tuner_value_dim.x + TUNER_ICON_SIZE.x * 2, window_draw_point + TUNER_HEIGHT);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover_l = mouse_pos.x > tuner_l_tl.x && mouse_pos.x < tuner_l_br.x && mouse_pos.y > tuner_l_tl.y && mouse_pos.y < tuner_l_br.y;
    bool hover_r = mouse_pos.x > tuner_r_tl.x && mouse_pos.x < tuner_r_br.x && mouse_pos.y > tuner_r_tl.y && mouse_pos.y < tuner_r_br.y;
    bool press = controls.mousePressed1;

    int tuner_l_icon_index = TUNER_L_ICON;
    int tuner_r_icon_index = TUNER_R_ICON;

    if (hover_l) {
        tuner_l_icon_index += TUNER_ICON_HOVER;
        if (press) {
            if (!pressed) {
                Sound::Play("buttonclick");
                tuner = Maths::Max(min, tuner - 1);
                pressed = true;
            }
        } else {
            pressed = false;
        }
    }

    if (hover_r) {
        tuner_r_icon_index += TUNER_ICON_HOVER;
        if (press) {
            if (!pressed) {
                Sound::Play("buttonclick");
                tuner = Maths::Min(max, tuner + 1);
                pressed = true;
            }
        } else {
            pressed = false;
        }
    }

    GUI::DrawIcon(ICONS_FILE_NAME, tuner_l_icon_index, TUNER_ICON_SIZE, tuner_l_tl, 1, 0);
    GUI::DrawIcon(ICONS_FILE_NAME, tuner_r_icon_index, TUNER_ICON_SIZE, tuner_r_tl, 1, 0);
    GUI::DrawTextCentered("" + tuner, Vec2f(tuner_l_br.x + (tuner_r_tl.x - tuner_l_br.x) / 2 - 2, tuner_l_tl.y + (tuner_r_br.y - tuner_l_tl.y) / 2 - 1), Colors::FG);
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
            DrawButtonPressed(keyname(key), tl, br);
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
            DrawButtonHovered(keyname(key), tl, br);
            pressed = false;
        }
    } else {
        DrawButtonDefault(keyname(key), tl, br);
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y + KEYBIND_HEIGHT / 2 - TEXT_HEIGHT / 2 - 1), Colors::FG);
    window_draw_point += KEYBIND_HEIGHT + KEYBIND_INDENT;
    return key;
}

}