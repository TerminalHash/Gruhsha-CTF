namespace ImGUI {
  
namespace Colors {
    const SColor FG = SColor(0xFFFFFFFF);
    const SColor WINDOW_BG = SColor(0xFF333333);
    const SColor WINDOW_TITLE = SColor(0xFF444444);
    const SColor BUTTON_NORMAL = SColor(0xFF666666);
    const SColor BUTTON_HOVER = SColor(0xFF777777);
    const SColor BUTTON_PRESS = SColor(0xFF888888);
};

CControls@ controls = getControls();
Vec2f window_tl = Vec2f(0,0);
Vec2f window_br = Vec2f(0,0);
float drawstart = 0.0;
bool pressed = false;

void Begin(string title, Vec2f tl, Vec2f br) {
    GUI::SetFont("ImGUI");
    GUI::DrawRectangle(tl, br, Colors::WINDOW_BG);
    GUI::DrawRectangle(tl, Vec2f(br.x, tl.y + 24), Colors::WINDOW_TITLE);
    GUI::DrawText(title, Vec2f(tl.x + 4, tl.y + 3), Colors::FG);
    window_tl = tl;
    window_br = br;
    drawstart = tl.y + 28;
}

void End() {
    GUI::SetFont("menu");
    drawstart = 0;
}

void Text(string text) {
    GUI::DrawText(text, Vec2f(window_tl.x + 4, drawstart), Colors::FG);
    drawstart += 20;
}

bool Button(const string title) {
    Vec2f tl = Vec2f(window_tl.x + 4, drawstart);
    Vec2f br = Vec2f(window_br.x - 4, drawstart + 26);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            GUI::DrawRectangle(tl, br, Colors::BUTTON_PRESS);
            GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), Colors::FG);
            drawstart = br.y + 4;
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                return true;
            }
        } else {
            GUI::DrawRectangle(tl, br, Colors::BUTTON_HOVER);
            pressed = false;
        }
    } else {
        GUI::DrawRectangle(tl, br, Colors::BUTTON_NORMAL);
    }

    GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), Colors::FG);
    drawstart = br.y + 4;
    return false;
}

bool Toggle(string title, bool toggle) {
    Vec2f tl = Vec2f(window_tl.x + 4, drawstart);
    Vec2f br = Vec2f(window_br.x - 4, drawstart + 16);

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
                toggle = not toggle;
            }
        } else {
            pressed = false;
        }
    }

    if (toggle) toggle_index += 1;
    GUI::DrawIcon("ImGUI_Icons.png", toggle_index, Vec2f(16,16), tl, 0.5, 0);
    GUI::DrawText(title, tl + Vec2f(20, 0), Colors::FG);

    drawstart = br.y + 4;
    return toggle;
}

int SliderInt(string title, int slider, int min = 0, int max = 10) {
    Vec2f tl = Vec2f(window_tl.x + 4, drawstart);
    Vec2f br = Vec2f(window_br.x - 4, drawstart + 20);

    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    GUI::DrawRectangle(tl, br, Colors::BUTTON_NORMAL);

    return slider;
}

}
