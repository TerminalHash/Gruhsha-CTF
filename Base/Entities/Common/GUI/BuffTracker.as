/*
    BuffTracker.as
    Script for tracking active buffs and debuffs like "icy" effect.
    
*/
void DrawBuffs() {
	if (g_videorecording)
	return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	if (p.getBlob() !is null) {
		GUI::SetFont("hud");
        Vec2f dim = Vec2f(842, 24);
        if (p.getBlob().getConfig() == "builder" && getRules().get_string("blockbar_hud") == "yes") {
            dim = Vec2f(842, 104);

            if (p.getBlob().getCarriedBlob() !is null && p.getBlob().getCarriedBlob().getName() == "drill")
                dim = Vec2f(842, 124);
        }
		
		Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
		ul += Vec2f(280, -68);

        s32 icyTime = p.getBlob().get_s32("icy time");

        s32 secondsToIcyEnd = icyTime / 30 % 60;

        if (!p.getBlob().hasTag("icy")) return;

		GUI::DrawIcon("Icy_Timer.png", ul + Vec2f(0,-15));
        drawRulesFont(getTranslatedString("{SEC}")
			.replace("{SEC}", "" + ((secondsToIcyEnd < 10) ? "0" + secondsToIcyEnd : "" + secondsToIcyEnd)),
		     SColor(255, 255, 255, 255), ul + Vec2f(100,-3), ul, true, false);
	}
}