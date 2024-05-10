#include "ScoreboardCommon.as";
#include "KIWI_Playercard.as";
#include "Accolades.as";
#include "ColoredNameToggleCommon.as";
#include "ApprovedTeams.as";
#include "RunnerHead.as";
#include "pathway.as";
#include "TranslationsSystem.as";
//#include "RulesCore"

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;
Vec2f hovered_pos;
Vec2f card_pos;

int hovered_player;
int hovered_card = -1;
bool draw_age = false;
bool draw_tier = false;

float scoreboardMargin = 52.0f;
float scrollOffset = 0.0f;
float scrollSpeed = 4.0f;
float maxMenuWidth = 700;

Vec2f screen_dims = Vec2f(getScreenWidth(), getScreenHeight());

bool mouseWasPressed2 = false;

const string OLD_PLAYER_STATS_CORE = "player stats core";

const string mod_version = "v3.0.2";

class OldPlayerStatsCore {
	dictionary stats;
}

class OldPlayerStats {
	s32 kills;
	s32 deaths;
	s32 assists;

	OldPlayerStats() {
		kills   = 0;
		deaths  = 0;
		assists = 0;
	}
}

//returns the bottom
float drawScoreboard(CPlayer@ localPlayer, CPlayer@[] players, Vec2f tl, CTeam@ team, Vec2f &out pane_tl, Vec2f &out pane_br, Vec2f emblem)
{
	if (players.size() <= 0)
		return tl.y;

	int localTeamNum = localPlayer.getTeamNum();
	SColor teamColor = SColor(255, 200, 200, 200);
	string teamName = "Spectators";

	if (team !is null)
	{
		teamColor = team.color;
		teamName = team.getName();
	}

	CRules@ rules = getRules();

	Vec2f orig = tl;

	f32 lineheight = 16;
	f32 padheight = 6;
	f32 stepheight = lineheight + padheight;
	Vec2f br(Maths::Min(getScreenWidth() - 100, getScreenWidth()/2 + maxMenuWidth), tl.y + (players.length + 5.5) * stepheight);
	GUI::DrawPane(tl, br, teamColor);

	pane_tl = tl;
	pane_br = br;

	//offset border
	tl.x += stepheight;
	br.x -= stepheight;
	tl.y += stepheight;

	GUI::SetFont("Balkara_Condensed");

	//draw team info
	GUI::DrawText(getTranslatedString(teamName), Vec2f(tl.x, tl.y), SColor(0xffffffff));

	GUI::SetFont("menu");
	GUI::DrawText(getTranslatedString("Players: {PLAYERCOUNT}").replace("{PLAYERCOUNT}", "" + players.length), Vec2f(br.x - 400, tl.y), SColor(0xffffffff));

	tl.y += stepheight * 2;

	const int accolades_start = 770;
	const int age_start = accolades_start + 80;
	f32 ping_offset = 26;
	f32 info_icon_offset = ping_offset + 480;

	//const int tier_start = (draw_age ? age_start : accolades_start) + 70;

	// Waffle: Change header color for old stats
	CControls@ controls = getControls();
	bool old_stats = controls.isKeyPressed(KEY_SHIFT) || controls.isKeyPressed(KEY_LSHIFT) || controls.isKeyPressed(KEY_RSHIFT);
	SColor kdr_color = old_stats ? OLD_STATS_COLOR : SColor(0xffffffff);

	//draw player table header
	GUI::DrawText(getTranslatedString("Player"), Vec2f(tl.x, tl.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("Username"), Vec2f(br.x - 470, tl.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("Ping"), Vec2f(br.x - 330, tl.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("Kills"), Vec2f(br.x - 260, tl.y), kdr_color);      // Waffle: Change header color for old stats
	GUI::DrawText(getTranslatedString("Deaths"), Vec2f(br.x - 190, tl.y), kdr_color);     // Waffle: --
	GUI::DrawText(getTranslatedString("Assists"), Vec2f(br.x - 120, tl.y), kdr_color);    // Waffle: --
	GUI::DrawText(getTranslatedString("KDR"), Vec2f(br.x - 50, tl.y), kdr_color);         // Waffle: --

	// Old accolades shit, we dont using this anymore
	/*GUI::DrawText(getTranslatedString("Accolades"), Vec2f(br.x - accolades_start, tl.y), SColor(0xffffffff));
	if(draw_age)
	{
		GUI::DrawText(getTranslatedString("Age"), Vec2f(br.x - age_start, tl.y), SColor(0xffffffff));
	}
	if(draw_tier)
	{
		GUI::DrawText(getTranslatedString("Tier"), Vec2f(br.x - tier_start, tl.y), SColor(0xffffffff));
	}*/

	//GUI::DrawText(Names::matssection, Vec2f(br.x - 600, tl.y), SColor(0xffffffff));

	tl.y += stepheight * 0.5f;

	string playerCardToDraw = "";

	Vec2f mousePos = controls.getMouseScreenPos();

	//draw players
	for (u32 i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		CBlob@ b = p.getBlob(); // REMINDER: this can be null if you're using this down below

		bool dead = (b is null || b.hasTag("dead"));

		tl.y += stepheight;
		br.y = tl.y + lineheight;

		bool playerHover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

		if (playerHover)
		{
			if (controls.mousePressed1)
			{
				setSpectatePlayer(p.getUsername());
			}
			if (controls.mousePressed2 && !mouseWasPressed2)
			{
				// reason for this is because this is called multiple per click (since its onRender, and clicking is updated per tick)
				// we don't want to spam anybody using a clipboard history program
				if (getFromClipboard() != p.getUsername())
				{
					CopyToClipboard(p.getUsername());
					rules.set_u16("client_copy_time", getGameTime());
					rules.set_string("client_copy_name", p.getUsername());
					rules.set_Vec2f("client_copy_pos", mousePos + Vec2f(0, -10));
				}
			}
		}

		Vec2f lineoffset = Vec2f(0, -2);

		u32 underlinecolor = 0xff404040;
		u32 playercolour = (p.getBlob() is null || p.getBlob().hasTag("dead")) ? 0xff505050 : 0xff808080;
		if (playerHover)
		{
			playercolour = 0xffcccccc;
			@hoveredPlayer = p;
			hoveredPos = tl;
			hoveredPos.x = br.x - 150;
		}

		GUI::DrawLine2D(Vec2f(tl.x, br.y + 1) + lineoffset, Vec2f(br.x, br.y + 1) + lineoffset, SColor(underlinecolor));
		GUI::DrawLine2D(Vec2f(tl.x, br.y) + lineoffset, br + lineoffset, SColor(playercolour));

		// class icon

		string classTexture = "";
		u16 classIndex = 0;
		Vec2f classIconSize;
		Vec2f classIconOffset = Vec2f(0, 0);
		if (p.isMyPlayer())
		{
			classTexture = "ScoreboardIcons.png";
			classIndex = 4;
			classIconSize = Vec2f(16, 16);
		}
		else
		{
			classTexture = "playercardicons.png";
			classIndex = 0;

			// why are player-scoreboard functions hardcoded
			// after looking into it let's not bother moving it to scripts for now
			classIndex = p.getScoreboardFrame();

			// knight is 3 but should be 0 for this texture
			// fyi it's pure coincidence builder and archer are already a match
			classIndex %= 3;

			classIconSize = Vec2f(16, 16);

			if (dead)
			{
				classIndex += 8;
			}
		}
		// don't draw class for specs
		if (team !is null && classTexture != "")
		{
			GUI::DrawIcon(classTexture, classIndex, classIconSize, tl + classIconOffset, 0.5f, p.getTeamNum());
		}

		string username = p.getUsername();
		string playername = p.getCharacterName();
		string clantag = p.getClantag();

		if(getSecurity().isPlayerNameHidden(p) && localPlayer !is p)
		{
			if(isAdmin(localPlayer))
			{
				playername = username + "(hidden: " + clantag + " " + playername + ")";
				clantag = "";

			}
			else
			{
				playername = username;
				clantag = "";
			}

		}

		// head icon

		string headTexture = "Heads.png";
		int headIndex = 32*4;
		int teamIndex = p.getTeamNum();
		Vec2f headOffset = Vec2f(22, -12);
		float headScale = 1.0f;
		SColor headColor(0xFFFFFFFF);

		string customHeadTexture = getPath() + "Characters/CustomHeads/" + username + ".png";
		//string customHeadTexture = ""; // comment out line above and uncomment this for debug

		Accolades@ acchead = getPlayerAccolades(p.getUsername());

		// show normally colored head for specs, they're never alive
		if (team !is null && dead)
		{
			headColor = 0xFF808080;
		}

		if (b !is null)
		{
			headIndex = b.get_s32("head index");
			headTexture = b.get_string("head texture");
			teamIndex = b.get_s32("head team");
		}
		else if (p.exists("head index"))
		{
			// HACK: no better infrastructure to know a player's head when
			// they're dead
			headIndex = p.get_s32("head index");
			headTexture = p.get_string("head texture");
		}
// 		else if (customHeadTexture != "" && !p.isBot()) // if player has custom head
// 		{
// 			headIndex = p.get_s32("head index");
// 			headTexture = customHeadTexture;
// 			teamIndex = p.get_s32("head team");
//
 			//printf ("We set " + headTexture + " for player " + username + " from custom heads"); // debug shit
// 		}
		else
		{
			headColor = 0x00000000;
		}

		GUI::DrawIcon(headTexture, headIndex, Vec2f(16, 16), tl + headOffset, headScale, headScale, teamIndex, headColor);

		// Mark captain in scoreboard
		if (getRules().get_string("team_"+teamIndex+"_leader")==username)
		{
			// set custom plate first
			if (username == "kusaka79")
				GUI::DrawIcon("CaptainMark/Custom/cm_kusaka.png", 0, Vec2f(33, 9), tl + Vec2f(-74, 0), 1.0f, 0);
			else if (username == "TerminalHash")
				GUI::DrawIcon("CaptainMark/Custom/cm_terminal.png", 0, Vec2f(33, 9), tl + Vec2f(-72, 0), 1.0f, 0);
			else if (username == "Pnext")
				GUI::DrawIcon("CaptainMark/Custom/cm_pnext.png", 0, Vec2f(33, 9), tl + Vec2f(-72, 0), 1.0f, 0);
			else if (username == "egor0928931")
				GUI::DrawIcon("CaptainMark/Custom/cm_egor.png", 0, Vec2f(35, 9), tl + Vec2f(-76, 0), 1.0f, 0);
			else if (username == "Think_About")
				GUI::DrawIcon("CaptainMark/Custom/cm_think.png", 0, Vec2f(31, 9), tl + Vec2f(-72, 0), 1.0f, 0);
			else if (username == "Bohdanu")
				GUI::DrawIcon("CaptainMark/Custom/cm_bohdanu.png", 0, Vec2f(34, 9), tl + Vec2f(-72, 0), 1.0f, 0);
			// if player doesn't have custom plate - set default
			else if (g_locale == "ru")
				GUI::DrawIcon("CaptainMark/ru.png", 0, Vec2f(38, 9), tl + Vec2f(-84, 0), 1.0f, 0);
			else if (g_locale == "de")
				GUI::DrawIcon("CaptainMark/de.png", 0, Vec2f(38, 9), tl + Vec2f(-82, 0), 1.0f, 0);
			else
				GUI::DrawIcon("CaptainMark/en.png", 0, Vec2f(38, 9), tl + Vec2f(-82, 0), 1.0f, 0);
		}

		//have to calc this from ticks
		s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);

		//how much room to leave for names and clantags
		float name_buffer = 56.0f;
		Vec2f clantag_actualsize(0, 0);

		//render the player + stats
		SColor namecolour = getNameColour(p);

		//right align clantag
		if (clantag != "") {
			GUI::GetTextDimensions(clantag, clantag_actualsize);
			GUI::DrawText(clantag, tl + Vec2f(name_buffer, 0), SColor(0xff888888));

			if (clantag.toUpper() == "MINECULT") {
				GUI::DrawIcon("Sprites/clan_badges.png", 0, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, teamIndex);
			} else if (clantag.toUpper() == "TTOGAD") {
				GUI::DrawIcon("Sprites/clan_badges.png", 1, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, 0);
			} else if (clantag.toUpper() == "MAGMUS") {
				GUI::DrawIcon("Sprites/clan_badges.png", 2, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, teamIndex);
			} else if (clantag.toUpper() == "HOMEK") {
				GUI::DrawIcon("Sprites/clan_badges.png", 3, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, 0);
			} else if (clantag.toUpper() == "BUTTER") {
				GUI::DrawIcon("Sprites/clan_badges.png", 4, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, 0);
			} else if (clantag.toUpper() == "GRUHSHA") {
				GUI::DrawIcon("Sprites/clan_badges.png", 5, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, 0);
			} else if (clantag.toUpper() == "BUTTERMINA" || clantag.toUpper() == "BUTTERCULT") {
				GUI::DrawIcon("Sprites/clan_badges.png", 6, Vec2f(16, 16), Vec2f(br.x, tl.y), 0.5f, teamIndex);
			}

			// recolor clantag for TerminalHash
			if (username == "TerminalHash") {
				GUI::DrawText(clantag, tl + Vec2f(name_buffer, 0), SColor(0xffad7fa8));
			}
			//draw name alongside
			GUI::DrawText(playername, tl + Vec2f(name_buffer + clantag_actualsize.x + 8, 0), namecolour);
		} else {
			//draw name alone
			GUI::DrawText(playername, tl + Vec2f(name_buffer, 0), namecolour);
		}

		///////////////////////////////////////////////
		// Player card section
		///////////////////////////////////////////////

		u8 card_variants_amount = CFileImage("id_card_icon").getWidth()/16;
		Vec2f card_icon_pos = Vec2f(br.x - info_icon_offset, tl.y-8);
		GUI::DrawIcon(
			"id_card_icon",
			p.getNetworkID() % card_variants_amount + (p.getOldGold() && !p.isBot() ? card_variants_amount : 0),
			Vec2f(16, 16),
			card_icon_pos,
			1.0f,
			69
		);

		if (playerHover && mousePos.x > br.x - info_icon_offset && mousePos.x < br.x - info_icon_offset + 24)
		{
			if (hovered_card < 0) {
				hovered_card = i;
				hovered_pos = card_icon_pos;
			}
		}
		///////////////////////////////////////////////

		// Old accolades shit, we dont using this anymore
		//draw account age indicator
		/*if (draw_age)
		{
			int regtime = p.getRegistrationTime();
			if (regtime > 0)
			{
				int reg_month = Time_Month(regtime);
				int reg_day = Time_MonthDate(regtime);
				int reg_year = Time_Year(regtime);

				int days = Time_DaysSince(regtime);

				int age_icon_start = 32;
				int icon = 0;
				bool show_years = false;
				int age = 0;
				//less than a month?
				if (days < 28)
				{
					int week = days / 7;
					icon = week;
				}
				else
				{
					//we use 30 day "months" here
					//for simplicity and consistency of badge allocation
					int months = days / 30;
					if (months < 12)
					{
						switch(months) {
							case 0:
							case 1:
								icon = 0;
								break;
							case 2:
								icon = 1;
								break;
							case 3:
							case 4:
							case 5:
								icon = 2;
								break;
							case 6:
							case 7:
							case 8:
								icon = 3;
								break;
							case 9:
							case 10:
							case 11:
							default:
								icon = 4;
								break;
						}
						icon += 4;
					}
					else
					{
						//figure out birthday
						int month_delta = Time_Month() - reg_month;
						int day_delta = Time_MonthDate() - reg_day;
						int birthday_delta = -1;

						if (month_delta < 0 || month_delta == 0 && day_delta < 0)
						{
							birthday_delta = -1;
						}
						else if (month_delta == 0 && day_delta == 0)
						{
							birthday_delta = 0;
						}
						else
						{
							birthday_delta = 1;
						}

						//check if its cake day
						if (birthday_delta == 0)
						{
							icon = 9;
						}
						else
						{
							//check if we're in the extra "remainder" days from using 30 month days
							if(days < 366)
							{
								//(9 months badge still)
								icon = 8;
							}
							else
							{
								//years delta
								icon = (Time_Year() - reg_year) - 1;
								//before or after birthday?
								if (birthday_delta == -1)
								{
									icon -= 1;
								}
								show_years = true;
								age = icon + 1; // icon frames start from 0
								//ensure sane
								icon = Maths::Clamp(icon, 0, 9);
								//shift line
								icon += 16;
							}
						}
					}
				}

				float x = br.x - age_start + 8;
				float extra = 8;

				if(show_years)
				{
					drawAgeIcon(age, Vec2f(x, tl.y));
				}
				else
				{
					GUI::DrawIcon("AccoladeBadges", age_icon_start + icon, Vec2f(16, 16), Vec2f(x, tl.y), 0.5f, teamIndex);
				}

				if (playerHover && mousePos.x > x - extra && mousePos.x < x + 16 + extra)
				{
					hovered_age = icon;
				}
			}

		}

		//draw support tier
		if(draw_tier)
		{
			int tier = p.getSupportTier();

			if(tier > 0)
			{
				int tier_icon_start = 15;
				float x = br.x - tier_start + 8;
				float extra = 8;
				GUI::DrawIcon("AccoladeBadges", tier_icon_start + tier, Vec2f(16, 16), Vec2f(x, tl.y), 0.5f, teamIndex);

				if (playerHover && mousePos.x > x - extra && mousePos.x < x + 16 + extra)
				{
					hovered_tier = tier;
				}
			}

		}

		//render player accolades
		Accolades@ acc = getPlayerAccolades(username);
		if (acc !is null)
		{
			//(remove crazy amount of duplicate code)
			int[] badges_encode = {
				//count,                icon,  show_text, group

				//misc accolades
				(acc.community_contributor ?
					1 : 0),             4,     0,         0,
				(acc.github_contributor ?
					1 : 0),             5,     0,         0,
				(acc.map_contributor ?
					1 : 0),             6,     0,         0,
				(acc.moderation_contributor && (
						//always show accolade of others if local player is special
						(p !is localPlayer && isSpecial(localPlayer)) ||
						//always show accolade for ex-admins
						!isSpecial(p) ||
						//show accolade only if colored name is visible
						coloredNameEnabled(getRules(), p)
					) ?
					1 : 0),             7,     0,         0,
				(p.getOldGold() ?
					1 : 0),             8,     0,         0,
				(acc.grusha_contributor ?
					1 : 0),				9,     0,         0,

				//tourney badges
				acc.gold,               0,     1,         1,
				acc.silver,             1,     1,         1,
				acc.bronze,             2,     1,         1,
				acc.participation,      3,     1,         1,

				//(final dummy)
				0, 0, 0, 0,
			};
			//encoding per-group
			int[] group_encode = {
				//singles
				accolades_start,                 24,
				//medals
				accolades_start - (24 * 5 + 12), 38,
			};

			for(int bi = 0; bi < badges_encode.length; bi += 4)
			{
				int amount    = badges_encode[bi+0];
				int icon      = badges_encode[bi+1];
				int show_text = badges_encode[bi+2];
				int group     = badges_encode[bi+3];

				int group_idx = group * 2;

				if(
					//non-awarded
					amount <= 0
					//erroneous
					|| group_idx < 0
					|| group_idx >= group_encode.length
				) continue;

				int group_x = group_encode[group_idx];
				int group_step = group_encode[group_idx+1];

				float x = br.x - group_x;

				GUI::DrawIcon("AccoladeBadges", icon, Vec2f(16, 16), Vec2f(x, tl.y), 0.5f, teamIndex);
				if (show_text > 0)
				{
					string label_text = "" + amount;
					int label_center_offset = label_text.size() < 2 ? 4 : 0;
					GUI::DrawText(
						label_text,
						Vec2f(x + 15 + label_center_offset, tl.y),
						SColor(0xffffffff)
					);
				}

				if (playerHover && mousePos.x > x && mousePos.x < x + 16)
				{
					hovered_accolade = icon;
				}

				//handle repositioning
				group_encode[group_idx] -= group_step;

			}
		}*/

		// Waffle: Keep old stats
		s32 kills   = p.getKills();
		s32 deaths  = p.getDeaths();
		s32 assists = p.getAssists();

		if (old_stats)
		{
			OldPlayerStatsCore@ old_player_stats_core;
			rules.get(OLD_PLAYER_STATS_CORE, @old_player_stats_core);
			if (old_player_stats_core !is null)
			{
				OldPlayerStats@ old_player_stats;
				if (old_player_stats_core.stats.exists(username))
				{
					old_player_stats_core.stats.get(username, @old_player_stats);
				}
				else
				{
					@old_player_stats = OldPlayerStats();
					old_player_stats_core.stats.set(username, @old_player_stats);
				}
				kills   = old_player_stats.kills;
				deaths  = old_player_stats.deaths;
				assists = old_player_stats.assists;
			}
		}

		GUI::DrawText("" + username, Vec2f(br.x - 470, tl.y), namecolour);
		GUI::DrawText("" + ping_in_ms, Vec2f(br.x - 330, tl.y), SColor(0xffffffff));
		GUI::DrawText("" + kills, Vec2f(br.x - 260, tl.y), kdr_color);
		GUI::DrawText("" + deaths, Vec2f(br.x - 190, tl.y), kdr_color);
		GUI::DrawText("" + assists, Vec2f(br.x - 120, tl.y), kdr_color);
		GUI::DrawText("" + formatFloat(kills / Maths::Max(f32(deaths), 1.0f), "", 0, 2), Vec2f(br.x - 50, tl.y), kdr_color);

		int teamIndexSpectators = 200;
		int teamIndexBlue = 0;
		int teamIndexRed = 1;

		bool localIsCaptain = localPlayer !is null && localPlayer.getUsername() == rules.get_string("team_"+localTeamNum+"_leader");
		bool playerIsOur = localPlayer !is null && teamIndex == localTeamNum || localPlayer !is null && teamIndex == teamIndexSpectators;
		bool playerIsNotLocal = localPlayer !is null && p !is localPlayer;


		// picking buttons for captains/admins
		if (controls.isKeyPressed(KEY_LSHIFT) &&
			controls.isKeyPressed(KEY_LCONTROL)) {
			if (isAdmin(localPlayer)) {
				if(teamIndex == teamIndexSpectators) {
					DrawPickButton(
						Vec2f(tl.x + 400, br.y - 24),
						Vec2f(tl.x + 450, br.y),
						"BLUE", "blue", username
					);
					DrawPickButton(
						Vec2f(tl.x + 450, br.y - 24),
						Vec2f(tl.x + 500, br.y),
						"RED", "red", username
					);
				} else if (teamIndex == teamIndexBlue) {
					DrawPickButton(
						Vec2f(tl.x + 400, br.y - 24),
						Vec2f(tl.x + 450, br.y),
						"SPEC", "spec", username
					);
					DrawPickButton(
						Vec2f(tl.x + 450, br.y - 24),
						Vec2f(tl.x + 500, br.y),
						"RED", "red", username
					);
				} else if (teamIndex == teamIndexRed) {
					DrawPickButton(
						Vec2f(tl.x + 400, br.y - 24),
						Vec2f(tl.x + 450, br.y),
						"SPEC", "spec", username
					);
					DrawPickButton(
						Vec2f(tl.x + 450, br.y - 24),
						Vec2f(tl.x + 500, br.y),
						"BLUE", "blue", username
					);
				} else {
					DrawPickButton(
						Vec2f(tl.x + 400, br.y - 24),
						Vec2f(tl.x + 450, br.y),
						"SPEC", "spec", username
					);
				}
			} else if (localIsCaptain && playerIsOur && playerIsNotLocal) {
				if (teamIndex == teamIndexSpectators) {
					if (localTeamNum == teamIndexBlue) {
						DrawPickButton(
							Vec2f(tl.x + 400, br.y - 24),
							Vec2f(tl.x + 450, br.y),
							"PICK", "blue", username
						);
					} else if(localTeamNum == teamIndexRed) {
						DrawPickButton(
							Vec2f(tl.x + 400, br.y - 24),
							Vec2f(tl.x + 450, br.y),
							"PICK", "red", username
						);
					}
				} else if (teamIndex != teamIndexSpectators) {
					DrawPickButton(
						Vec2f(tl.x + 400, br.y - 24),
						Vec2f(tl.x + 450, br.y),
						"spec", "spec", username
					);
				}
			}
		} else if ((localIsCaptain || isAdmin(localPlayer)) && (p is localPlayer)) {
			GUI::DrawPane(
				Vec2f(tl.x + 400, br.y - 24),
				Vec2f(tl.x + 500, br.y),
				SColor(0xffffffff)
			);
			GUI::DrawTextCentered(
				"SHIFT+CTRL",
				Vec2f(tl.x + 400 + (100.0f * 0.47f), br.y - (24.0f * 0.53f)),
				SColor(0xffffffff)
			);
		}
	}

	// username copied text, goes at bottom to overlay above everything else
	uint durationLeft = rules.get_u16("client_copy_time");

	if ((durationLeft + 64) > getGameTime())
	{
		durationLeft = getGameTime() - durationLeft;
		DrawFancyCopiedText(rules.get_string("client_copy_name"), rules.get_Vec2f("client_copy_pos"), durationLeft);
	}

	return tl.y;

}

void onRenderScoreboard(CRules@ this)
{
	if (this.get_bool("bindings_open")) return;

	//sort players
	CPlayer@[] blueplayers;
	CPlayer@[] redplayers;
	CPlayer@[] spectators;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = getKDR(p);
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}

		int teamIndex = p.getTeamNum();
		if (teamIndex == 0) //blue team
		{
			for (u32 j = 0; j < blueplayers.length; j++)
			{
				if (getKDR(blueplayers[j]) < kdr)
				{
					blueplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				blueplayers.push_back(p);

		}
		else //if (teamIndex == 1)
		{
			for (u32 j = 0; j < redplayers.length; j++)
			{
				if (getKDR(redplayers[j]) < kdr)
				{
					redplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				redplayers.push_back(p);

		} /*
		else
		{
			for (u32 j = 0; j < spectators.length; j++)
			{
				if (getKDR(spectators[j]) < kdr)
				{
					spectators.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				spectators.push_back(p);
		} */
	}

	//draw board

	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
		return;
	int localTeamNum = localPlayer.getTeamNum();
	if (localTeamNum != 0 && localTeamNum != 1)
		localTeamNum = 0;

	@hoveredPlayer = null;

	Vec2f tl(Maths::Max( 100, getScreenWidth()/2 -maxMenuWidth), 150);
	drawServerInfo(40);

	drawSettingsButton();

	// start the scoreboard lower or higher.
	tl.y -= scrollOffset;

	//(reset)
	hovered_accolade = -1;
	hovered_age = -1;
	hovered_tier = -1;

	//need those to know which array of players we should check for creating a player card
	Vec2f bluz_pane_tl();
	Vec2f bluz_pane_br();

	Vec2f redz_pane_tl();
	Vec2f redz_pane_br();

	Vec2f spec_pane_tl();
	Vec2f spec_pane_br();

	//draw the scoreboards
	tl.y += 10;

	if (localTeamNum == 0)
		tl.y = drawScoreboard(localPlayer, blueplayers, tl, this.getTeam(0), bluz_pane_tl, bluz_pane_br,  Vec2f(0, 0));
	else
		tl.y = drawScoreboard(localPlayer, redplayers, tl, this.getTeam(1), redz_pane_tl, redz_pane_br, Vec2f(32, 0));

	if (blueplayers.length > 0)
		tl.y += 52;

	if (localTeamNum == 1)
		tl.y = drawScoreboard(localPlayer, blueplayers, tl, this.getTeam(0), bluz_pane_tl, bluz_pane_br, Vec2f(0, 0));
	else
		tl.y = drawScoreboard(localPlayer, redplayers, tl, this.getTeam(1), redz_pane_tl, redz_pane_br, Vec2f(32, 0));

	if (redplayers.length > 0)
		tl.y += 52;

	tl.y = drawScoreboard(localPlayer, spectators, tl, this.getTeam(255), spec_pane_tl, spec_pane_br, Vec2f(32, 0));


	float scoreboardHeight = tl.y + scrollOffset;
	float screenWidth = getScreenWidth();
	float screenHeight = getScreenHeight();
	CControls@ controls = getControls();

	if(scoreboardHeight > screenHeight) {
		Vec2f mousePos = controls.getMouseScreenPos();

		float fullOffset = (scoreboardHeight + scoreboardMargin) - screenHeight;

		if(scrollOffset < fullOffset && mousePos.y > screenHeight*0.83f) {
			scrollOffset += scrollSpeed;
		}
		else if(scrollOffset > 0.0f && mousePos.y < screenHeight*0.16f) {
			scrollOffset -= scrollSpeed;
		}

		scrollOffset = Maths::Clamp(scrollOffset, 0.0f, fullOffset);
	}

	Vec2f mousePos = controls.getMouseScreenPos();
	bool left_side = mousePos.x<getScreenWidth()/2;

	///////////////////////////////////////////////
	// matetials section

	// BLUE TEAM
	GUI::DrawText(getRules().get_s32("teamwood" + 0) + " ", Vec2f(bluz_pane_br.x - 1032, bluz_pane_tl.y + 22), SColor(0xffffffff));
	GUI::DrawText("" " | ", Vec2f(bluz_pane_br.x - 1065, bluz_pane_tl.y + 20), SColor(0xffffffff));
	GUI::DrawText(getRules().get_s32("teamstone" + 0) + " ", Vec2f(bluz_pane_br.x - 1100, bluz_pane_tl.y + 22), SColor(0xffffffff));

		// icons for mats
	GUI::DrawIcon("Materials.png", 25, Vec2f(16, 16), Vec2f(bluz_pane_br.x - 1050, bluz_pane_tl.y + 20), 0.50f, 0); // wood
	GUI::DrawIcon("Materials.png", 24, Vec2f(16, 16), Vec2f(bluz_pane_br.x - 1118, bluz_pane_tl.y + 20), 0.50f, 0); // stone

	// RED TEAM
	GUI::DrawText(getRules().get_s32("teamwood" + 1) + " ", Vec2f(redz_pane_br.x - 1032, redz_pane_tl.y + 22), SColor(0xffffffff));
	GUI::DrawText("" " | ", Vec2f(redz_pane_br.x - 1065, redz_pane_tl.y + 20), SColor(0xffffffff));
	GUI::DrawText(getRules().get_s32("teamstone" + 1) + " ", Vec2f(redz_pane_br.x - 1100, redz_pane_tl.y + 22), SColor(0xffffffff));

		// icons for mats
	GUI::DrawIcon("Materials.png", 25, Vec2f(16, 16), Vec2f(redz_pane_br.x - 1050, redz_pane_tl.y + 20), 0.50f, 0); // wood
	GUI::DrawIcon("Materials.png", 24, Vec2f(16, 16), Vec2f(redz_pane_br.x - 1118, redz_pane_tl.y + 20), 0.50f, 0); // stone
	///////////////////////////////////////////////


	///////////////////////////////////////////////
	// Player card section
	///////////////////////////////////////////////

	//Vec2f card_pos = Vec2f(left_side?tl.x:getScreenWidth()/2, tl.y)+Vec2f(getScreenWidth()/3.75, tl.y-64+(23+9)*hovered_card);

	//have to keep the whole scoreboard offset in mind :>
	//card_pos.y -= scrollOffset;
	Vec2f card_topLeft = hovered_pos+Vec2f(-0.164f*screen_dims.x,0);
	card_topLeft = hovered_pos-Vec2f(playerCardDims.x/2, 0);

	Vec2f card_botRight = card_topLeft+Vec2f(playerCardDims.x,playerCardDims.y);

	//prevent algorythm from drawing card which doesn't fit on screen
	f32 outbounds_y_difference = card_botRight.y-getDriver().getScreenHeight()+32.0f/704*getDriver().getScreenHeight();
	//printf("Cock " + outbounds_y_difference);

	//do something about drawing position if it doesn't fit
	if (outbounds_y_difference > 0)
	{
		card_topLeft = Vec2f(card_topLeft.x, card_topLeft.y-outbounds_y_difference);
		card_botRight = card_topLeft + Vec2f(playerCardDims.x, playerCardDims.y);
	}

	bool click_to_close = controls.mousePressed1;
	bool left_card_bounds = mousePos.y>card_botRight.y||mousePos.y<card_topLeft.y||mousePos.x>card_botRight.x||mousePos.x<card_topLeft.x;

	if (click_to_close || left_card_bounds) {
		//debug thing to check the borderlines
		if (g_debug > 0 && hovered_card > -1)
			GUI::DrawBubble(card_topLeft, card_botRight);

		hovered_card = -1;
	}

	bool on_blue_pane = hovered_pos.x > bluz_pane_tl.x && hovered_pos.x < bluz_pane_br.x && hovered_pos.y > bluz_pane_tl.y && hovered_pos.y < bluz_pane_br.y;
	bool on_red_pane = hovered_pos.x > redz_pane_tl.x && hovered_pos.x < redz_pane_br.x && hovered_pos.y > redz_pane_tl.y && hovered_pos.y < redz_pane_br.y;
	bool on_spec_pane = hovered_pos.x > spec_pane_tl.x && hovered_pos.x < spec_pane_br.x && hovered_pos.y > spec_pane_tl.y && hovered_pos.y < spec_pane_br.y;

	if (hovered_card != -1) {
		CPlayer@ player = null;

		if (on_blue_pane) {
			if (blueplayers.size() > hovered_card) @player = blueplayers[hovered_card];
		}
		if (on_red_pane) {
			if (redplayers.size() > hovered_card) @player = redplayers[hovered_card];
		}
		if (on_spec_pane) {
			if (spectators.size() > hovered_card) @player = spectators[hovered_card];
		}

		if (player !is null) {
			makePlayerCard(player, card_topLeft);
		}
	}

	drawPlayerCard(hoveredPlayer, hoveredPos);
	///////////////////////////////////////////////

	// Old accolades shit, we dont using this anymore
	/*drawHoverExplanation(hovered_accolade, hovered_age, hovered_tier, Vec2f(getScreenWidth() * 0.5, tl.y));*/

	ScoreboardField(
		Vec2f(screenWidth - tl.x - 200, 115 - scrollOffset),
		Vec2f(screenWidth - tl.x,       115 - scrollOffset + 40),
		Descriptions::currentversiontext + mod_version
	);
	LinkButton(
		Vec2f(screenWidth - tl.x - 275, 115 - scrollOffset),
		Vec2f(screenWidth - tl.x - 205, 115 - scrollOffset + 40),
		"Github ",
		"https://github.com/TerminalHash/Gruhsha-CTF"
	);

	mouseWasPressed2 = controls.mousePressed2;
}

void onTick(CRules@ this)
{

	if (!isPlayerListShowing() && hovered_card>-1)
	{
		hovered_card = -1; //deactivate any cards
	}

	if (this.getCurrentState() == GAME)
	{
		this.add_u32("match_time", 1);

		if (isServer() && this.get_u32("match_time") % (10 * getTicksASecond()) == 0)
		{
			this.Sync("match_time", true);
		}
	}

	// plain stupidity to track player heads even when dead
	const int playerCount = getPlayersCount();
	for (int i = 0; i < playerCount; ++i)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) { continue; }

		CBlob@ b = p.getBlob();
		if (b is null) { continue; }

		const int headIndex = b.get_s32("head index");
		const string headTexture = b.get_string("head texture");
		const int teamIndex = b.get_s32("head team");
		p.set_s32("head index", headIndex);
		p.set_string("head texture", headTexture);
		p.set_s32("head team", teamIndex);
	}
}

void onInit(CRules@ this)
{
	// Waffle: Keep old stats
	OldPlayerStatsCore@ old_player_stats_core = OldPlayerStatsCore();
	this.set(OLD_PLAYER_STATS_CORE, @old_player_stats_core);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	// Waffle: Reset scoreboard
	OldPlayerStatsCore@ old_player_stats_core;
	this.get(OLD_PLAYER_STATS_CORE, @old_player_stats_core);
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null)
		{
			continue;
		}

		// Cache previous game
		if (old_player_stats_core !is null)
		{
			string player_name = player.getUsername();
			OldPlayerStats@ old_player_stats;
			if (old_player_stats_core.stats.exists(player_name))
			{
				old_player_stats_core.stats.get(player_name, @old_player_stats);
			}
			else
			{
				@old_player_stats = OldPlayerStats();
				old_player_stats_core.stats.set(player_name, @old_player_stats);
			}

			old_player_stats.kills    = player.getKills();
			old_player_stats.deaths   = player.getDeaths();
			old_player_stats.assists = player.getAssists();
		}

		// Reset for next game
		player.setKills(0);
		player.setDeaths(0);
		player.setAssists(0);
	}

	if(isServer())
	{
		this.set_u32("match_time", 0);
		this.Sync("match_time", true);
		getMapName(this);
	}
}

void getMapName(CRules@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		string[] name = map.getMapName().split('/');	 //Official server maps seem to show up as
		string mapName = name[name.length() - 1];		 //``Maps/CTF/MapNameHere.png`` while using this instead of just the .png
		mapName = getFilenameWithoutExtension(mapName);  // Remove extension from the filename if it exists

		this.set_string("map_name", mapName);
		this.Sync("map_name",true);
	}
}

/*
void drawAgeIcon(int age, Vec2f position)
{
	int number_gap = 8;
	int years_frame_start = 48;
	if(age >= 10)
	{
		position.x -= number_gap - 4;
		GUI::DrawIcon("AccoladeBadges", years_frame_start + (age / 10), Vec2f(16, 16), position, 0.5f, 0);
		age = age % 10;
		position.x += number_gap;
	}
	GUI::DrawIcon("AccoladeBadges", years_frame_start + age, Vec2f(16, 16), position, 0.5f, 0);
	position.x += 4;
	if(age == 1) position.x -= 1; // fix y letter offset for number 1
	GUI::DrawIcon("AccoladeBadges", 58, Vec2f(16, 16), position, 0.5f, 0); // y letter
}
*/

void DrawFancyCopiedText(string username, Vec2f mousePos, uint duration)
{
	string text = "Username copied: " + username;
	Vec2f pos = mousePos - Vec2f(0, duration);
	int col = (255 - duration * 3);

	GUI::DrawTextCentered(text, pos, SColor((255 - duration * 4), col, col, col));
}

void DrawPickButton(Vec2f tl, Vec2f br, const string&in text, const string&in team, const string username)
{
	CRules@ rules = getRules();
	CBitStream params;
	params.write_string(username);

	const f32 w = br.x - tl.x;
	const f32 h = br.y - tl.y;
	CControls@ controls = getControls();
	const Vec2f mousePos = controls.getMouseScreenPos();

	SColor buttonColor = SColor(0xFFFFFFFF);
	if(team == "blue") {
		buttonColor = SColor(0xFF1A6F9E);
	} else if (team == "red") {
		buttonColor = SColor(0xFFBA2721);
	}

	const bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

	if (hover)
	{
		if (controls.mousePressed1) { // press
			GUI::DrawPane(tl, br, buttonColor);
			GUI::DrawPane(tl, br, 0x5f000000);
			GUI::DrawPane(tl + Vec2f(4, 4), br - Vec2f(4, 4), 0x5f000000);

			if (!mouseWasPressed1 && team == "spec") {
				rules.SendCommand(rules.getCommandID("put to spec"), params);
				mouseWasPressed1 = true;
			} else if (!mouseWasPressed1 && team == "blue") {
				rules.SendCommand(rules.getCommandID("put to blue"), params);
				mouseWasPressed1 = true;
			} else if (!mouseWasPressed1 && team == "red") {
				rules.SendCommand(rules.getCommandID("put to red"), params);
				mouseWasPressed1 = true;
			}
		} else { // focus
			GUI::DrawPane(tl, br, buttonColor);
			GUI::DrawPane(tl, br, 0x5f000000);

			mouseWasPressed1 = false;
		}
	} else { // empty
		GUI::DrawPane(tl, br, buttonColor);
	}

	// пишет текст кнопки по центру
	// в общем кнопки надо чтобы были хоть какие-то. От них сдесь нужны именно чёрные уголки
	GUI::DrawTextCentered(text, Vec2f(tl.x + (w * 0.47f), tl.y + (h * 0.47f)), 0xffffffff);
}

// website button
void LinkButton(Vec2f tl, Vec2f br, const string&in text, const string&in website)
{
	CControls@ controls = getControls();
	const Vec2f mousePos = controls.getMouseScreenPos();

	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);

	if (hover)
	{
		GUI::DrawButton(tl, br);
		if (controls.mousePressed1) {
			if (!mouseWasPressed1) {
				Sound::Play("option");
				OpenWebsite(website);
				mouseWasPressed1 = true;
			}
		}
		else {
			mouseWasPressed1 = false;
		}

	}
	else {
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}

	GUI::DrawTextCentered(text, Vec2f(tl.x + ((br.x - tl.x) * 0.50f), tl.y + ((br.y - tl.y) * 0.50f)), 0xffffffff);
}

// text field
void ScoreboardField(Vec2f tl, Vec2f br, const string&in text)
{
	GUI::DrawPane(tl, br, 0xffcfcfcf);
	GUI::DrawTextCentered(text, Vec2f(tl.x + ((br.x - tl.x) * 0.50f), tl.y + ((br.y - tl.y) * 0.50f)), 0xffffffff);
}
