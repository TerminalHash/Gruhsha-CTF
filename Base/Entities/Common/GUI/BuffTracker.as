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

        Vec2f kurwa(0, -15);
        Vec2f kurwa2(100,-3);

        // icy time stuff
        s32 icyTime = p.getBlob().get_s32("icy time");
        s32 secondsToIcyEnd = icyTime / 30 % 60;

        // broken shield time stuff
        s32 brokenShieldTime = p.getBlob().get_s32("broken shield timer");
        s32 secondsToBrokenShielsEnd = brokenShieldTime / 30 % 60;

        if (p.getBlob().hasTag("icy")) {
		    GUI::DrawIcon("DebuffOnHUD.png", 0, Vec2f(33, 19),  ul + kurwa);
            drawRulesFont(getTranslatedString("{SEC}")
		    	.replace("{SEC}", "" + ((secondsToIcyEnd < 10) ? "0" + secondsToIcyEnd : "" + secondsToIcyEnd)),
		         SColor(255, 255, 255, 255), ul + kurwa2, ul, true, false);

            kurwa += Vec2f(80, 0);
            kurwa2 += Vec2f(160, 0);
        }

        if (p.getBlob().hasTag("broken shield")) {
            GUI::DrawIcon("DebuffOnHUD.png", 1, Vec2f(33, 19),  ul + kurwa);
            drawRulesFont(getTranslatedString("{SEC}")
		    	.replace("{SEC}", "" + ((secondsToBrokenShielsEnd < 10) ? "0" + secondsToBrokenShielsEnd : "" + secondsToBrokenShielsEnd)),
		         SColor(255, 255, 255, 255), ul + kurwa2, ul, true, false);
        }
	}
}