namespace IMGUI {

const SColor BLACK = SColor(0xFF000000);
const SColor DARK_GRAY = SColor(0xFF888888);
const SColor GRAY = SColor(0xFFCFCFCF);
const SColor WHITE = SColor(0xFFFFFFFF);
const SColor BLUE = SColor(0xFF1A6F9E);
const SColor HBLUE = SColor(0xFF4A9FCE);
const SColor RED = SColor(0xFFBA2721);
const SColor HRED = SColor(0xFFEA5751);
const SColor YELLOW = SColor(0xFFFFC700);

bool pressed = false;

bool Button(const string text, Vec2f tl, Vec2f br, SColor button_color = GRAY, SColor hover_button_color = WHITE, SColor text_color = WHITE) {
    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            Panel(text, tl, br, button_color, text_color);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                return true;
            }
        } else {
            Panel(text, tl, br, hover_button_color, text_color);
            pressed = false;
        }
    } else {
        Panel(text, tl, br, button_color, text_color);
    }
    return false;
}

void Panel(string text, Vec2f tl, Vec2f br, SColor panel_color = GRAY, SColor text_color = WHITE) {
    GUI::DrawPane(tl, br, panel_color);
    GUI::DrawTextCentered(text, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), text_color);
}

}
