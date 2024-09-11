namespace ImGUI {

namespace Colors {
    const SColor FG = SColor(0xFFFFFFFF);
    const SColor WINDOW_BG = SColor(0xFF000000);
    const SColor WINDOW_TITLE = SColor(0xFF888888);
    const SColor BUTTON_NORMAL = SColor(0xFF888888);
    const SColor BUTTON_HOVER = SColor(0xFFCFCFCF);
    const SColor BUTTON_PRESS = SColor(0xFF888888);
};

Vec2f begin_tl = Vec2f(0,0);
Vec2f begin_br = Vec2f(0,0);
Vec2f draw_point = Vec2f(0,0);
bool pressed = false;

void Begin(string title, Vec2f tl, Vec2f br) {
    GUI::SetFont("ImGUI");
    GUI::DrawRectangle(tl, br, Colors::WINDOW_BG);
    GUI::DrawRectangle(tl, Vec2f(br.x, tl.y + 25), Colors::WINDOW_TITLE);
    GUI::DrawText(title, Vec2f(tl.x + 4, tl.y + 3), Colors::FG);
    begin_tl = tl;
    begin_br = br;
    draw_point = Vec2f(tl.x + 4, tl.y + 25);
}

void End() {
    GUI::SetFont("menu");
    draw_point = Vec2f(0,0);
}

void Text(string text) {
    GUI::DrawText(text, draw_point, Colors::FG);
    draw_point.y += 16;
}

bool Button(const string title, int width = 0) {
    Vec2f tl = Vec2f(begin_tl.x + 2, draw_point.y);
    Vec2f br = Vec2f(begin_br.x - 2, draw_point.y + 25);

    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            GUI::DrawRectangle(tl, br, Colors::BUTTON_PRESS);
            GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), Colors::FG);
            draw_point = Vec2f(tl.x, br.y);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                return true;
            }
        } else {
            draw_point = Vec2f(tl.x, br.y);
            GUI::DrawRectangle(tl, br, Colors::BUTTON_HOVER);
            pressed = false;
        }
    } else {
        draw_point = Vec2f(tl.x, br.y);
        GUI::DrawRectangle(tl, br, Colors::BUTTON_NORMAL);
    }

    GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), Colors::FG);
    return false;
}

bool Toggle(string title, bool toggle) {
    Vec2f tl = draw_point + Vec2f(0,2);
    Vec2f br = tl + Vec2f(20, 20);
    
    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
   
    if (hover) {
        if (press) {
            GUI::DrawRectangle(tl, br, Colors::BUTTON_PRESS);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                toggle = not toggle;
            }
        } else {
            GUI::DrawRectangle(tl, br, Colors::BUTTON_HOVER);
            pressed = false;
        }
    } else {
        GUI::DrawRectangle( tl, br, Colors::BUTTON_NORMAL);
    }

    GUI::DrawText(title, Vec2f(br.x, tl.y), Colors::FG);

    if (toggle) GUI::DrawIcon("ImGUI_Icons.png", 1, Vec2f(16,16), tl + Vec2f(2,2), 0.5, 0);
    if (!toggle) GUI::DrawIcon("ImGUI_Icons.png", 0, Vec2f(16,16), tl + Vec2f(2,2), 0.5, 0);

    draw_point += Vec2f(0, 22);
    return toggle;
}

float SliderFloat(string title, float slider) {
    return slider;
}

}
