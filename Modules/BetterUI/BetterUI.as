const SColor BLACK = SColor(0xFF000000);
const SColor GRAY = SColor(0xFFCFCFCF);
const SColor WHITE = SColor(0xFFFFFFFF);
const SColor BLUE = SColor(0xFF1A6F9E);
const SColor RED = SColor(0xFFBA2721);

bool pressed = false;

bool textButton(const string text, Vec2f tl, Vec2f br) {
    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;

    if (hover) {
	if (press) {
	    TextPanel(text, tl, br, WHITE);
            if (!pressed) {
	        Sound::Play("option");
                pressed = true;
		return true;
	    }
        } else {
	    TextPanel(text, tl, br, WHITE);
	    pressed = false;
	}
    } else {
        TextPanel(text, tl, br, GRAY);
    }
    return false;
}

void IconButton() {}

void TextPanel(const string text, Vec2f tl, Vec2f br, SColor color) {
    GUI::DrawPane(tl, br, color);
    GUI::DrawTextCentered(text, Vec2f(tl.x + ((br.x - tl.x) * 0.50f), tl.y + ((br.y - tl.y) * 0.50f)), WHITE);
}

void IconPanel() {}
