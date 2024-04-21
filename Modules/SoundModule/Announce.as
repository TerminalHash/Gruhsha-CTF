// Announce.as
/*
	Система анонсов.
	Выводит большую надпись в центре экрана.

	Пользоваться могут исключительно модераторы/админы/капитаны.
*/

#include "RulesCore.as";
#include "pathway.as";

// Utility
#include "GetFont.as";

string soundsdir = getPath();
string sound = soundsdir + "Sounds/";

bool onServerProcessChat( CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null)
		return true;
	
	string[]@ tokens = textIn.split(" ");
	u8 tlen = tokens.length;

	return true;
}

void onRestart(CRules@ this)
{
	this.Untag("offi match");

	this.set_u32("announce time", 0);
	this.set_string("announce text", "");
}

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null || getLocalPlayer() is null)
		return true;

	int teamNum = player.getTeamNum();

	string[]@ tokens = textIn.split(" ");
	u8 tlen = tokens.length;

	if (textIn.find("!") == 0 && player.getTeamNum() == getLocalPlayer().getTeamNum() && player.isMod() || textIn.find("!") == 0 && player.getTeamNum() == getLocalPlayer().getTeamNum() && (getRules().get_string("team_" + teamNum + "_leader") == player.getUsername()))
	{
		Sound::Play(sound + "AnnounceSound.ogg");					// TEAM ONLY ANNOUNCE
		string alert = textIn;
		alert = alert.substr(1);
		this.set_string("announce text", alert);
		this.set_u32("announce time", getGameTime());
	}
	else if (textIn == ("*offi") && player.isMod())
	{
		Sound::Play(sound + "offi.ogg");							// OFFI ANNOUNCE
		this.set_string("announce text", "OFFI");
		this.set_u32("announce time", getGameTime());
		this.Tag("offi match");
	}
	else if (textIn.find("*") == 0 && player.isMod())
	{
		Sound::Play(sound + "AnnounceSound.ogg");					// GLOBAL ANNOUNCE
		string alert = textIn;
		alert = alert.substr(1);
		this.set_string("announce text", alert);
		this.set_u32("announce time", getGameTime());
	}

	return true;
}

void onRender(CRules@ this)
{
	float screen_size_x = getDriver().getScreenWidth();
    float screen_size_y = getDriver().getScreenHeight();
	float resolution_scale = screen_size_y / 720.f;

	string announce_text_font = get_font("SourceHanSansCN-Bold", s32(24.f * resolution_scale));
	GUI::SetFont(announce_text_font);
	if (getGameTime() - this.get_u32("announce time") < 30 * 5)
	{
		string alert = this.get_string("announce text");

		GUI::DrawTextCentered(alert, Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f),
			        SColor(255, 255, 55, 55));
	}
}
