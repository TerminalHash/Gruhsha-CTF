namespace IMGUI {

const SColor BLACK = SColor(0xFF000000);
const SColor DARK_GRAY = SColor(0xFF888888);
const SColor GRAY = SColor(0xFFCFCFCF);
const SColor WHITE = SColor(0xFFFFFFFF);
const SColor BLUE = SColor(0xFF1A6F9E);
const SColor HBLUE = SColor(0xFF4A9FCE);
const SColor RED = SColor(0xFFBA2721);
const SColor HRED = SColor(0xFFEA5751);
const SColor GREEN = SColor(0xFD32AB1D);
const SColor HGREEN = SColor(0xFF39C720);
const SColor YELLOW = SColor(0xFFFFC700);

Vec2f draw_point = Vec2f(0,0);
bool pressed = false;

void Begin(string title, Vec2f tl, Vec2f br) {
    GUI::DrawPane(tl, br, GRAY);
    GUI::DrawPane(tl, Vec2f(br.x, tl.y + 25), WHITE);
    GUI::DrawText(title, Vec2f(tl.x + 4, tl.y + 3), WHITE);
    draw_point = Vec2f(tl.x + 4, tl.y + 25);
}

void End() {
    draw_point = Vec2f(0,0);
}

void Text(string text) {
    GUI::DrawText(text, draw_point, WHITE);
    draw_point.y += 16;
}
 
bool Button(const string title, SColor button_color = GRAY, SColor button_color_hover = WHITE, SColor text_color = WHITE) {
    Vec2f title_size;
    GUI::GetTextDimensions(title, title_size);

    Vec2f tl = draw_point + Vec2f(0,2);
    Vec2f br = tl + Vec2f(title_size.x + 14, 25);

    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
    
    if (hover) {
        if (press) {
            GUI::DrawPane(tl, br, button_color);
            GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), text_color);
            draw_point = Vec2f(tl.x, br.y);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                return true;
            }
        } else {
            draw_point = Vec2f(tl.x, br.y);
            GUI::DrawPane(tl, br, button_color_hover);
            pressed = false;
        }
    } else {
        draw_point = Vec2f(tl.x, br.y);
        GUI::DrawPane( tl, br, button_color);
    }
    
    GUI::DrawTextCentered(title, Vec2f(tl.x + ((br.x - tl.x) * 0.50f) - 2, tl.y + ((br.y - tl.y) * 0.50f)), text_color);
    return false;
}

bool Toggle(string title, bool toggle) {
    SColor toggle_color;
    SColor toggle_color_hover;
    if (toggle == true) {
        toggle_color = GREEN;
        toggle_color_hover = HGREEN;
    } else {
        toggle_color = RED;
        toggle_color_hover = HRED;
    }

    Vec2f tl = draw_point + Vec2f(0,2);
    Vec2f br = tl + Vec2f(20, 20);
    
    CControls@ controls = getControls();
    Vec2f mouse_pos = controls.getMouseScreenPos();
    bool hover = mouse_pos.x > tl.x && mouse_pos.x < br.x && mouse_pos.y > tl.y && mouse_pos.y < br.y;
    bool press = controls.mousePressed1;
   
    if (hover) {
        if (press) {
            GUI::DrawPane(tl, br, toggle_color);
            if (!pressed) {
                Sound::Play("ButtonClick.ogg");
                pressed = true;
                toggle = not toggle;
            }
        } else {
            GUI::DrawPane(tl, br, toggle_color_hover);
            pressed = false;
        }
    } else {
        GUI::DrawPane( tl, br, toggle_color);
    }

    GUI::DrawText(title, Vec2f(br.x, tl.y), WHITE);
    if (toggle) GUI::DrawIcon("IMGUI_Icons.png", 0, Vec2f(16,16), tl + Vec2f(2,2), 0.5, 0);
  
    draw_point += Vec2f(0, 22);
    return toggle;
}

}
