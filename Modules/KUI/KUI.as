#include "BindingsCommon.as"

namespace KUI {

const int TOGGLE_ICONS = 0;
const int TUNER_ICONS = 4;
const SColor FG = SColor(0xFFFFFFFF);

CControls@ controls = getControls();

Vec2f window_tl = Vec2f(0,0);
Vec2f window_br = Vec2f(0,0);
float drawstart = 0.0;
bool pressed = false;

void Begin(string title, Vec2f tl, Vec2f br) {
    GUI::SetFont("KUI");

    GUI::DrawFramedPane(tl, br);
    GUI::DrawPane(tl, Vec2f(br.x, tl.y + 26));
    GUI::DrawText(title, Vec2f(tl.x + 6, tl.y + 4), FG);

    window_tl = tl;
    window_br = br;
    drawstart = tl.y + 30;
}

void End() {
    GUI::SetFont("menu");
    drawstart = 0;
}

void Separator(float separator = 20) {
    drawstart += separator;
}

void Line() {
    Vec2f p1 = Vec2f(window_tl.x + 8, drawstart);
    Vec2f p2 = Vec2f(window_br.x - 8, drawstart);
    GUI::DrawLine2D(p1, p2, FG);
    drawstart += 4;
}

void Text(string text) {
    GUI::DrawText(text, Vec2f(window_tl.x + 8, drawstart), FG);
    drawstart += 20;
}

bool Button(string title) {
    if (controls is null) return false;

    bool button = false;

    Vec2f tl = Vec2f(window_tl.x + 8, drawstart);
    Vec2f br = Vec2f(window_br.x - 8, drawstart + 28);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            DrawButtonPress(title, tl, br);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                button = true;
            }
        } else {
            DrawButtonHover(title, tl, br);
            pressed = false;
        }
    } else {
        DrawButtonNormal(title, tl, br);
    }

    return button;
}

void DrawButtonNormal(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButton(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), FG);
    drawstart = br.y + 4;
}

void DrawButtonHover(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButtonHover(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), FG);
    drawstart = br.y + 4;
}

void DrawButtonPress(string title, Vec2f tl, Vec2f br) {
    GUI::DrawButtonPressed(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), FG);
    drawstart = br.y + 4;
}

bool Toggle(string title, bool toggle) {
    if (controls is null) return toggle;

    Vec2f tl = Vec2f(window_tl.x + 8, drawstart);
    Vec2f br = Vec2f(window_br.x - 8, drawstart + 16);

    int toggle_index = 0;

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        toggle_index = 2;
        if (press) {
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                toggle = !toggle;
            }
        } else {
            pressed = false;
        }
    }

    if (toggle) toggle_index += 1;

    GUI::DrawIcon("KUI_Icons.png", TOGGLE_ICONS + toggle_index, Vec2f(8,8), tl, 1, 0);
    GUI::DrawText(title, tl + Vec2f(20, 0), FG);

    drawstart = br.y + 4;
    return toggle;
}

int Tuner(string title, int tuner, int min = 1, int max = 5) {
    if (controls is null) return tuner;

    Vec2f ltuner_tl = Vec2f(window_tl.x + 8, drawstart);
    Vec2f ltuner_br = Vec2f(window_tl.x + 8 + 16, drawstart + 16);

    Vec2f tuner_value_dim;
    GUI::GetTextDimensions(max + "", tuner_value_dim);

    Vec2f rtuner_tl = Vec2f(ltuner_br.x + tuner_value_dim.x, drawstart);
    Vec2f rtuner_br = Vec2f(ltuner_br.x + tuner_value_dim.x + 16, drawstart + 16);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool lhover = mouse_pos.x > ltuner_tl.x && mouse_pos.x < ltuner_br.x && mouse_pos.y > ltuner_tl.y && mouse_pos.y < ltuner_br.y;
    bool rhover = mouse_pos.x > rtuner_tl.x && mouse_pos.x < rtuner_br.x && mouse_pos.y > rtuner_tl.y && mouse_pos.y < rtuner_br.y;
    bool press = controls.mousePressed1;

    int ltuner_index = 0;
    int rtuner_index = 2;

    if (lhover) {
        ltuner_index = 1;
        if (press) {
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                tuner = Maths::Max(min, tuner - 1);
                pressed = true;
            }
        } else {
            pressed = false;
        }
    }

    if (rhover) {
        rtuner_index = 3;
        if (press) {
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                tuner = Maths::Min(max, tuner + 1);
                pressed = true;
            }
        } else {
            pressed = false;
        }
    }

    GUI::DrawIcon("KUI_Icons.png", TUNER_ICONS + ltuner_index, Vec2f(8,8), ltuner_tl, 1, 0);
    GUI::DrawIcon("KUI_Icons.png", TUNER_ICONS + rtuner_index, Vec2f(8,8), rtuner_tl, 1, 0);
    GUI::DrawTextCentered("" + tuner, Vec2f(ltuner_br.x + (rtuner_tl.x - ltuner_br.x) / 2 - 2, ltuner_tl.y + (rtuner_br.y - ltuner_tl.y) / 2 - 1), FG);
    GUI::DrawText(title, Vec2f(rtuner_br.x + 4, drawstart), FG);
    drawstart += 20;
    return tuner;
}

int Keybind(string title, int key) {
    if (controls is null) return key;

    Vec2f tl = Vec2f(window_tl.x + 8, drawstart);
    Vec2f br = Vec2f(window_tl.x + 8 + 100, drawstart + 28);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            DrawButtonPress(getKeyName(key), tl, br);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
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
            DrawButtonHover(getKeyName(key), tl, br);
            pressed = false;
        }
    } else {
        DrawButtonNormal(getKeyName(key), tl, br);
    }

    GUI::DrawText(title, Vec2f(br.x + 4, tl.y + 4), FG);
    return key;
}

}

