#include "BindingsCommon.as"

namespace KUI {

const int TOGGLE_ICONS = 0;
const int TUNER_ICONS = 4;

namespace Colors {
    const SColor FG = SColor(0xFFFFFFFF);
    const SColor WINDOW_BG = SColor(0xFF647160);
    const SColor WINDOW_BORDER = SColor(0xFF130D1D);
    const SColor WINDOW_TITLE = SColor(0xFF7E8C79);
    const SColor BUTTON_NORMAL = SColor(0xFF7E8C79);
    const SColor BUTTON_HOVER = SColor(0xFF97A792);
    const SColor BUTTON_PRESS = SColor(0xFF97A792);
    const SColor BUTTON_BORDER_NORMAL = SColor(0xFF130D1D);
    const SColor BUTTON_BORDER_HOVER = SColor(0xFFFFFFFF);
    const SColor BUTTON_BORDER_PRESS = SColor(0xFFAAAAAA);
};

CControls@ controls = getControls();

Vec2f window_tl = Vec2f(0,0);
Vec2f window_br = Vec2f(0,0);
float drawstart = 0.0;
bool pressed = false;

void Begin(string title, Vec2f tl, Vec2f br) {
    GUI::SetFont("KUI");

    //    GUI::DrawRectangle(tl, br, Colors::WINDOW_BORDER);
    //    GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::WINDOW_BG);
    //    GUI::DrawRectangle(tl + Vec2f(2, 2), Vec2f(br.x - 2, tl.y + 22), Colors::WINDOW_TITLE);

    GUI::DrawFramedPane(tl, br);
    GUI::DrawPane(tl, Vec2f(br.x, tl.y + 26));
    GUI::DrawText(title, Vec2f(tl.x + 6, tl.y + 4), Colors::FG);

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
    GUI::DrawLine2D(p1, p2, Colors::FG);
    drawstart += 4;
}

void Text(string text) {
    GUI::DrawText(text, Vec2f(window_tl.x + 8, drawstart), Colors::FG);
    drawstart += 18;
}

bool Button(string title) {
    if (controls is null) return false;

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
                return true;
            }
        } else {
            DrawButtonHover(title, tl, br);
            pressed = false;
        }
    } else {
        DrawButtonNormal(title, tl, br);
    }

    return false;
}

void DrawButtonNormal(string title, Vec2f tl, Vec2f br) {
  //GUI::DrawRectangle(tl, br, Colors::BUTTON_BORDER_NORMAL);
  //GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::BUTTON_NORMAL);
    GUI::DrawButton(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
    drawstart = br.y + 4;
}

void DrawButtonHover(string title, Vec2f tl, Vec2f br) {
  //GUI::DrawRectangle(tl, br, Colors::BUTTON_BORDER_HOVER);
  //GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::BUTTON_HOVER);
    GUI::DrawButtonHover(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
    drawstart = br.y + 4;
}

void DrawButtonPress(string title, Vec2f tl, Vec2f br) {
  //GUI::DrawRectangle(tl, br, Colors::BUTTON_BORDER_PRESS);
  //GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::BUTTON_PRESS);
    GUI::DrawButtonPressed(tl, br);
    GUI::DrawTextCentered(title, Vec2f(tl.x + (br.x - tl.x) / 2 - 2, tl.y + (br.y - tl.y) / 2 - 2), Colors::FG);
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
    GUI::DrawText(title, tl + Vec2f(20, 0), Colors::FG);

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
    GUI::DrawTextCentered("" + tuner, Vec2f(ltuner_br.x + (rtuner_tl.x - ltuner_br.x) / 2 - 2, ltuner_tl.y + (rtuner_br.y - ltuner_tl.y) / 2 - 1), Colors::FG);
    GUI::DrawText(title, Vec2f(rtuner_br.x + 4, drawstart), Colors::FG);
    drawstart += 20;
    return tuner;
}

int ButtonKeybind(int key) {
    if (controls is null) return key;

    Vec2f tl = Vec2f(window_tl.x + 8, drawstart);
    Vec2f br = Vec2f(window_br.x - 8, drawstart + 28);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        DrawButtonHover(getKeyName(key), tl, br);
        if (press) {
            DrawButtonPress(getKeyName(key), tl, br);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                return key;
            }

            for (int i = 1; i <= 512; i++) {
                if (i == EKEY_CODE::KEY_LBUTTON) continue;
                bool key_pressed = controls.isKeyPressed(i);
                if (!key_pressed) continue;
                key = i;
                break;
            }
        }
    } else {
        DrawButtonNormal(getKeyName(key), tl, br);
    }

    return key;
}

}

