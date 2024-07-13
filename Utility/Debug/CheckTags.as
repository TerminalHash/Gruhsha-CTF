// CheckTags.as

void onRender(CRules@ this) {
	if (getLocalPlayer() is null) return;

    bool stats = this.hasTag("track_stats");
    bool suddendeath = this.hasTag("sudden death");
    bool offi = this.hasTag("offi match");
    bool warmup = this.get_bool("is_warmup");

    string stats_message = "Stats in this match:";
    string sudden_message = "Sudden Death Mode in this match:";
    string offi_message = "Offi in this match:";
    string warmup_message = "Warmup in this match:";
    string activated = "ACTIVE";
    string notactivated = "NOT ACTIVE";

    SColor green = 0xff00ff02;
    SColor red = ConsoleColour::ERROR;

	if (getLocalPlayer().getUsername() == "TerminalHash") {

        if (getControls().isKeyPressed(KEY_NUMPAD5)) {
            GUI::SetFont("menu");

            GUI::DrawTextCentered(stats_message, Vec2f(1280, 450), color_white);
            if (stats) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 464), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 464), red);
            }

            GUI::DrawTextCentered(sudden_message, Vec2f(1280, 480), color_white);
            if (suddendeath) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 494), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 494), red);
            }

            GUI::DrawTextCentered(offi_message, Vec2f(1280, 510), color_white);
            if (offi) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 524), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 524), red);
            }

            GUI::DrawTextCentered(warmup_message, Vec2f(1280, 540), color_white);
            if (warmup) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 554), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 554), red);
            }
        }
    }
}