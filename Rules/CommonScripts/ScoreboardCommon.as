#include "ColoredNameToggleCommon.as"
#include "TranslationsSystem.as"

// Waffle: Add support for seeing previous match's stats
const SColor OLD_STATS_COLOR = SColor(0xffa0ffa0);
const string OLD_STATS_TOOLTIP = "Hold \"shift\" to see stats from previous match";

bool mouseWasPressed1 = false;
bool hoveringSettings = false;

f32 getKDR(CPlayer@ p)
{
	return p.getKills() / Maths::Max(f32(p.getDeaths()), 1.0f);
}

SColor getNameColour(CPlayer@ p)
{
	SColor c;
	CPlayer@ localplayer = getLocalPlayer();
	bool showColor = (p !is localplayer && isSpecial(localplayer)) || coloredNameEnabled(getRules(), p);
	bool customColor = false;

	string username = p.getUsername();

	// set custom color for rolas
	if (p.isDev() && showColor && !customColor) {
		c = SColor(0xffb400ff); //dev
	} else if (p.isGuard() && showColor && !customColor) {
		c = SColor(0xffa0ffa0); //guard
	} else if (isAdmin(p) && showColor && !customColor) {
		c = SColor(0xfffa5a00); //admin
	} else if (p.getOldGold() && !p.isBot() && !customColor) {
		c = SColor(0xffffEE44); //my player
	}
	// set custom color for some players
	else if (username == "TerminalHash") {
		customColor = true;
		c = SColor(0xff75507b);
	} else if (username == "kusaka79") {
		customColor = true;
		c = SColor(0xff000000);
	} 
	// set default color for other
	else {
		c = SColor(0xffffffff); //normal
	}

	if(p.getBlob() is null && p.getTeamNum() != getRules().getSpectatorTeamNum())
	{
		uint b = c.getBlue();
		uint g = c.getGreen();
		uint r = c.getRed();

		b -= 75;
		g -= 75;
		r -= 75;

		b = Maths::Max(b, 25);
		g = Maths::Max(g, 25);
		r = Maths::Max(r, 25);

		c.setBlue(b);
		c.setGreen(g);
		c.setRed(r);

	}

	return c;

}

void setSpectatePlayer(string username)
{
	CPlayer@ player = getLocalPlayer();
	CPlayer@ target = getPlayerByUsername(username);
	if((player.getBlob() is null || player.getBlob().hasTag("dead")) && player !is target && target !is null)
	{
		CRules@ rules = getRules();
		rules.set_bool("set new target", true);
		rules.set_string("new target", username);

	}

}

float drawServerInfo(float y)
{
	GUI::SetFont("menu");

	Vec2f pos(getScreenWidth()/2, y);
	// Waffle: Add extra tooltip for old stats
	float width = 533;


	CNet@ net = getNet();
	CMap@ map = getMap();
	CRules@ rules = getRules();

	string info = getTranslatedString(rules.gamemode_name) + ": " + getTranslatedString(rules.gamemode_info);
	SColor white(0xffffffff);
	string mapName = getTranslatedString("Map name : ")+rules.get_string("map_name");
	Vec2f dim;
	GUI::GetTextDimensions(info, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(net.joined_servername, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(mapName, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;


	pos.x -= width/2;
	Vec2f bot = pos;
	bot.x += width;
	bot.y += 112;  // Waffle: Add space for extra row
	
	Vec2f mid(getScreenWidth()/2, y);


	GUI::DrawFramedPane(pos, bot);

	mid.y += 15;
	GUI::DrawTextCentered(net.joined_servername, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(info, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(net.joined_ip, mid, white);
	mid.y += 17;
	GUI::DrawTextCentered(mapName, mid, white);
	mid.y += 17;
	GUI::DrawTextCentered(getTranslatedString("Match time: {TIME}").replace("{TIME}", "" + timestamp((getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime())/getTicksASecond())), mid, white);

	// Waffle: Add extra tooltip for old stats
	mid.y += 17;
	GUI::DrawTextCentered(Descriptions::oldstatstooltip, mid, OLD_STATS_COLOR);

	// Draw grusha icons
	GUI::DrawIcon("grusha.png", 0, Vec2f(64, 64), Vec2f(getScreenWidth()/2 - width/2 + 34, y + 16), 0.5f, 0);
	GUI::DrawIcon("grusha_flip.png", 0, Vec2f(64, 64), Vec2f(getScreenWidth()/2 + width/2 - 130 + 32, y + 16), 0.5f, 0);

	return bot.y;

}

void drawSettingsButton()
{
	GUI::SetFont("menu");

	Vec2f startpos(getScreenWidth()/2 - 400, 120);

	CControls@ controls = getControls();
	if (controls is null) return;

	Vec2f mpos = controls.getMouseScreenPos();
	if (mpos.x > startpos.x && mpos.x < startpos.x + 110 &&
		mpos.y > startpos.y && mpos.y < startpos.y + 32)
	{
		if (hoveringSettings == false)
		{
			Sound::Play("select.ogg");
		}

		hoveringSettings = true;

		if (true)
		{
			if (controls.mousePressed1) {
				if (!mouseWasPressed1) {
					Sound::Play("ButtonClick.ogg");
					getRules().set_bool("bindings_open", true);
					mouseWasPressed1 = true;
				}
				else {
					mouseWasPressed1 = false;
				}
			}
		}
		GUI::DrawPane(startpos, startpos + Vec2f(120, 32), SColor(255, 200, 200, 200));
	}
	else
	{
		hoveringSettings = false;
		GUI::DrawPane(startpos, startpos + Vec2f(120, 32), SColor(255, 250, 250, 250));
	}

	GUI::DrawIcon("MenuItems.png", 26, Vec2f(32, 32), startpos, 0.5, 0);
	GUI::DrawText(Names::modsettingsbutton, startpos + Vec2f(32, 8), color_white);
}

string timestamp(uint s)
{
	string ret;
	int hours = s/60/60;
	if (hours > 0)
		ret += hours + getTranslatedString("h ");

	int minutes = s/60%60;
	if (minutes < 10)
		ret += "0";

	ret += minutes + getTranslatedString("m ");

	int seconds = s%60;
	if (seconds < 10)
		ret += "0";

	ret += seconds + getTranslatedString("s ");

	return ret;
}

void drawPlayerCard(CPlayer@ player, Vec2f pos)
{
	/*
	if(player!is null)
	{
		GUI::SetFont("menu");

		f32 stepheight = 8;
		Vec2f atopleft = pos;
		atopleft.x -= stepheight;
		atopleft.y -= stepheight*2;
		Vec2f abottomright = atopleft;
		abottomright.y += 96 + 16 + 48;
		abottomright.x += 96 + 16;

		//int namecolour = getNameColour(player);
		GUI::DrawIconDirect("playercard.png", atopleft, Vec2f(0, 0), Vec2f(60, 94));
		GUI::DrawText(player.getUsername(), Vec2f(pos.x + 2, atopleft.y+10), SColor(0xffffffff));
		player.drawAvatar(Vec2f(atopleft.x+6*2, atopleft.y+16*2), 1.0f);
		atopleft.y += 96 + 30;
		atopleft.x += 8;
		GUI::DrawIconDirect("playercardicons.png", Vec2f(atopleft.x, atopleft.y), Vec2f(16*2, 0), Vec2f(16, 16));
		GUI::DrawText("9600", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));
		atopleft.y += 23;
		GUI::DrawIconDirect("playercardicons", Vec2f(atopleft.x, atopleft.y), Vec2f(16*3, 0), Vec2f(16, 16));
		GUI::DrawText("450", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));

	}
	*/

}
