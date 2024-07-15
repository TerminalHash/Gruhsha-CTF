namespace IMGUI {

const SColor BLACK = SColor(0xFF000000);
const SColor GRAY = SColor(0xFFCFCFCF);
const SColor WHITE = SColor(0xFFFFFFFF);
const SColor BLUE = SColor(0xFF1A6F9E);
const SColor RED = SColor(0xFFBA2721);

bool pressed = false;

bool Button(const string text, Vec2f tl, Vec2f br) {
    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
        if (press) {
            Panel(text, tl, br, GRAY);
            if (!pressed) {
                Sound::Play("option");
                pressed = true;
                return true;
            }
        } else {
            Panel(text, tl, br, WHITE);
            pressed = false;
        }
    } else {
        Panel(text, tl, br, GRAY);
    }
    return false;
}

void Panel(string text, Vec2f tl, Vec2f br, SColor color) {
    GUI::DrawPane(tl, br, color);
    GUI::DrawTextCentered(text, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), WHITE);
}

}
