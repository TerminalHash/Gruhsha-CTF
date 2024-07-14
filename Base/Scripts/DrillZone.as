// DrillZone.as
/*
    Код зоны, в которой возможно пользоваться дрелью.
    Она исключительно для ограничения дрели, чтобы снизить её имбовость.

    Базируется на ширине красного барьера и на каждой карте ширина этой зоны будет различаться.
*/

void onTick(CRules@ rules)
{
    // check, if it's not a server
	if (!isServer()) return;
}

void onRender(CRules@ rules)
{
	Driver@ driver = getDriver();
    CPlayer@ my_player = getLocalPlayer();
	if (my_player is null) return;
	if (getGameTime() < 45) return;

	const f32 scalex = getDriver().getResolutionScaleFactor();
	f32 zoom = getCamera().targetDistance * scalex;

	CMap@ map = getMap();
	f32 map_height = map.tilemapheight*map.tilesize;

	SColor color_b = SColor(40, 229, 212, 27);

	u8 opacity = 55;

	if (rules.exists("opacity"))
	{
		opacity = 255 * rules.get_s32("opacity") * 0.01;
	}

	SColor white = SColor(opacity, 255, 255, 255);

	const u16 left = rules.get_u16("barrier_x1");
	const u16 right = rules.get_u16("barrier_x2");

	if (rules.hasTag("sudden death")) return;
	if (rules.get_string("drillzone_borders") == "off") return;

    Vec2f leftzone_u = driver.getScreenPosFromWorldPos(Vec2f(left - 0.5, 0));
    Vec2f leftzone_l = driver.getScreenPosFromWorldPos(Vec2f(left + 0.5, driver.getScreenHeight()));
	GUI::DrawRectangle(leftzone_u, leftzone_l, white);

    Vec2f rightzone_u = driver.getScreenPosFromWorldPos(Vec2f(right - 0.5, 0));
    Vec2f rightzone_l = driver.getScreenPosFromWorldPos(Vec2f(right + 0.5, driver.getScreenHeight()));
	GUI::DrawRectangle(rightzone_u,rightzone_l, white);

	//printf("Oaoaoaoaoa");
}
