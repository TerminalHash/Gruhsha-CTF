#include "Accolades"
#include "SocialStatus"
#include "HeadCommon.as"
#include "TranslationsSystem.as"

Vec2f playerCardDims(256, 198+26);

int hovered_accolade = -1;
int hovered_age = -1;
int hovered_tier = -1;
int hovered_ping = -1;

void makePlayerCard(CPlayer@ player, Vec2f pos)
{
	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;
	
	//colors
	u32 col_white = 0xffffffff;
	u32 col_gold = 0xffe0e050;
	u32 col_deadred = 0xffC65B5B;
	u32 col_darkgrey = 0xff404040;
	u32 col_middlegrey = 0xff808080;
	u32 col_lightgrey = 0xffcccccc;
	
	//some bools idk
	bool draw_age = true;
	bool draw_tier = true;
	
	//name stuff
	string username = player.getUsername();
	string charname = player.getCharacterName();
	string clantag = player.getClantag();
	
	//main pane
	Vec2f paneDims = playerCardDims;
	Vec2f topLeft = pos;//-Vec2f(paneDims.x/2+32,-8);
	Vec2f botRight = topLeft+Vec2f(paneDims.x,paneDims.y);
	GUI::DrawPane(topLeft, botRight);
	
	Vec2f paneGap(0, 2);
	Vec2f sideGap(6, 6);
	
	//charname stuff
	Vec2f charnameTopLeft(sideGap.x, sideGap.y);
	Vec2f charnamePaneDims(paneDims.x-charnameTopLeft.x*2, 28);
	Vec2f charnameBotRight = Vec2f(botRight.x-charnameTopLeft.x, topLeft.y+charnameTopLeft.y+charnamePaneDims.y);
	GUI::DrawPane(topLeft+charnameTopLeft, charnameBotRight, SColor(0xff777777));
	
	//username stuff
	SColor nameColor = getNameColour(player);
	Vec2f usernameTopLeft(charnameTopLeft.x, charnamePaneDims.y+sideGap.y-2);
	Vec2f usernameBotRight = Vec2f(botRight.x-usernameTopLeft.x, topLeft.y+usernameTopLeft.y+charnamePaneDims.y);
	GUI::DrawPane(topLeft+usernameTopLeft, usernameBotRight, SColor(0xff777777));
	const string USR_PREFIX = "usr: ";
	Vec2f prefix_dims;
	GUI::GetTextDimensions(USR_PREFIX, prefix_dims);
	GUI::DrawShadowedText(USR_PREFIX, topLeft+usernameTopLeft+Vec2f(4,charnamePaneDims.y/6), col_middlegrey);
	GUI::DrawShadowedText(username, topLeft+usernameTopLeft+Vec2f(4+prefix_dims.x,charnamePaneDims.y/6), nameColor);
	/* if (mousePos.x > usernameTopLeft.x && mousePos.x < usernameBotRight.x && mousePos.y < usernameBotRight.y && mousePos.y > usernameTopLeft.y && controls.mousePressed2)
	{
		// reason for this is because this is called multiple per click (since its onRender, and clicking is updated per tick)
		// we don't want to spam anybody using a clipboard history program
		if (getFromClipboard() != username)
		{
			CopyToClipboard(username);
			getRules().set_u16("client_copy_time", getGameTime());
			getRules().set_string("client_copy_name", username);
			getRules().set_Vec2f("client_copy_pos", mousePos + Vec2f(0, -10));
		}
	} */
	
	//how much room to leave for names and clantags
	Vec2f clantagDims(0, 0);
	Vec2f charnameDims(0, 0);
	GUI::GetTextDimensions(charname, charnameDims);
	
	//drawing name + clantag
	if (clantag != "") {
		GUI::GetTextDimensions(clantag, clantagDims);
		GUI::DrawShadowedText(clantag, topLeft+charnameTopLeft+Vec2f(4,charnamePaneDims.y/6), col_middlegrey);
		GUI::DrawShadowedText(charname, topLeft+charnameTopLeft+Vec2f(4,charnamePaneDims.y/6)+Vec2f(clantagDims.x + 8, 0), color_white);
	}
	else {
		GUI::DrawShadowedText(charname, topLeft+charnameTopLeft+Vec2f(4,charnamePaneDims.y/6), color_white);
	}
	
	//accolades stuff
	Vec2f accoladeShift(80, 0);
	Vec2f accoladePaneTopLeft(sideGap.x+accoladeShift.x-2, usernameTopLeft.y+charnamePaneDims.y+paneGap.y);
	Vec2f accoladePaneBotRight(botRight.x-sideGap.x, topLeft.y+accoladePaneTopLeft.y+156);
	Vec2f accoladePaneDims(paneDims.x-sideGap.x*2, paneDims.x-sideGap.x*2+10);
	
	//potrait tl br
	Vec2f portraitTopLeft = topLeft+Vec2f(usernameTopLeft.x, accoladePaneTopLeft.y);
	Vec2f portraitBotRight = portraitTopLeft+Vec2f(76, 76);
	
	//frame behind the portrat
	GUI::DrawFramedPane(portraitTopLeft, portraitBotRight);
	
	//making the portrait
	string portrait_name = "face_knight.png";
	CBlob@ blob = player.getBlob();
		
	//for the cool guys
	string title = getStatus(username, 0, portrait_name);

	GUI::DrawIcon(portrait_name, 0, Vec2f(32, 32), portraitTopLeft+Vec2f(6,6), 1.0f, player.getTeamNum());
	
	//pane for accolades
	GUI::DrawPane(topLeft+accoladePaneTopLeft, accoladePaneBotRight);
	
	//pane for crown/tier and age
	Vec2f agePaneTopLeft = Vec2f(portraitTopLeft.x, portraitBotRight.y+2);
	GUI::DrawPane(agePaneTopLeft, Vec2f(topLeft.x+accoladePaneTopLeft.x-2, accoladePaneBotRight.y));
	
	//render player accolades
	Accolades@ acc = getPlayerAccolades(username);
	int accolades_start = -accoladePaneTopLeft.x;
	int accolades_y = accoladePaneTopLeft.y+2+16;
	GUI::DrawShadowedText(getTranslatedString("Accolades"), topLeft+accoladePaneTopLeft+Vec2f(4,charnameDims.y/4), SColor(0xffffffff));
	GUI::DrawShadowedText(Names::medalsn, topLeft+accoladePaneTopLeft+Vec2f(4,charnameDims.y/4+48), SColor(0xffffffff));
	GUI::DrawShadowedText(Names::partipin, topLeft+accoladePaneTopLeft+Vec2f(4,charnameDims.y/4+96), SColor(0xffffffff));
	
	//draw support tier
	int tier = player.getSupportTier();
	if(draw_tier && !player.isBot())
	{

		if(tier > 0)
		{
			int tier_icon_start = 15;
			Vec2f icon_pos = topLeft+Vec2f(charnameDims.x+16, usernameTopLeft.y+4);
			Vec2f tier_icon_pos = Vec2f(portraitTopLeft.x,portraitBotRight.y)+Vec2f(38, 8);
			GUI::DrawIcon("AccoladeBadges", tier_icon_start + tier, Vec2f(16, 16), tier_icon_pos, 1.0f, player.getTeamNum());

			if (mousePos.x > tier_icon_pos.x -4 && mousePos.x < tier_icon_pos.x + 24 && mousePos.y < tier_icon_pos.y + 24 && mousePos.y > tier_icon_pos.y -4)
			{
				hovered_tier = tier;
			}
		}

	}
	
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
					(player !is localplayer && isSpecial(localplayer)) ||
					//always show accolade for ex-admins
					!isSpecial(player) ||
					//show accolade only if colored name is visible
					coloredNameEnabled(getRules(), player)
				) ?
				1 : 0),             7,     0,         0,
			(acc.grusha_contributor ?
				1 : 0),				9,     0,         0,
			(acc.kiwi_contributor   ?
				1 : 0),             11,     0,         0,
			(acc.best_captain   	?
				1 : 0),             12,     0,         0,

			//medals
			acc.gold,               0,     1,         1,
			acc.silver,             1,     1,         1,
			acc.bronze,             2,     1,         1,
			
			//participation
			acc.participation,      3,     1,         2,

			//(final dummy)
			0, 0, 0, 0,
		};
		//encoding per-group
		int[] group_encode = {
			//singles
			accolades_start,				24,
			//medals
			accolades_start+4,				50,
			//participation
			accolades_start,				0,
		};

		for(int bi = 0; bi < badges_encode.length; bi += 4)
		{
			int amount    = badges_encode[bi+0];
			int icon      = badges_encode[bi+1];
			int show_text = badges_encode[bi+2];
			int group     = badges_encode[bi+3];

			int group_idx = group * 2;
			
			int group_y = group_idx*24;

			if(
				//non-awarded
				amount <= 0
				//erroneous
				|| group_idx < 0
				|| group_idx >= group_encode.length
			) continue;

			int group_x = group_encode[group_idx];
			int group_step = group_encode[group_idx+1];

			float x = topLeft.x + 8 - group_x;
			
			Vec2f icon_pos = Vec2f(x, topLeft.y+accolades_y+2+group_y);
			GUI::DrawIcon("AccoladeBadges", icon, Vec2f(16, 16), icon_pos, 1.0f, player.getTeamNum());
			if (show_text > 0)
			{
				string label_text = "" + amount;
				int label_center_offset = label_text.size() < 2 ? 4 : 0;
				GUI::DrawText(
					label_text,
					Vec2f(x + label_center_offset + 30 + (group == 2? 3:0), topLeft.y+accolades_y+12+group_y),
					SColor(0xffffffff)
				);
			}
			
			if (mousePos.x > x -4 && mousePos.x < x + 24 && mousePos.y < icon_pos.y + 24 && mousePos.y > icon_pos.y -4)
			{
				hovered_accolade = icon;
			}
			
			//handle repositioning
			group_encode[group_idx] -= group_step;
		}
	}
	//draw account age indicator
	if (draw_age)
	{
		int regtime = player.getRegistrationTime();
		if (regtime > 0 && !player.isBot())
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

			float extra = 8;
			Vec2f age_icon_pos = Vec2f(portraitTopLeft.x, portraitBotRight.y)+Vec2f(4, 40);

			if (show_years)
			{
				drawAgeIcon(age, age_icon_pos);
			}
			else
			{
				GUI::DrawIcon("AccoladeBadges", age_icon_start + icon, Vec2f(16, 16), age_icon_pos, 1.0f);
			}

			if (mousePos.x > age_icon_pos.x -4 && mousePos.x < age_icon_pos.x + 24 && mousePos.y < age_icon_pos.y + 24 && mousePos.y > age_icon_pos.y -4)
			{
				hovered_age = icon;
			}
		}
	}
		//making golden crown for those who paid the game
		//making bronze coin for those who's f2p
		if (!player.isBot()) {
			Vec2f paid_icon_pos = Vec2f(portraitTopLeft.x,portraitBotRight.y)+Vec2f(4, 8);
			u8 membership_type = player.getOldGold()?8:10;
			GUI::DrawIcon("AccoladeBadges", membership_type, Vec2f(16, 16), paid_icon_pos, 1.0f);
			if (mousePos.x > paid_icon_pos.x -4 && mousePos.x < paid_icon_pos.x + 24 && mousePos.y < paid_icon_pos.y + 24 && mousePos.y > paid_icon_pos.y -4)
			{
				hovered_accolade = membership_type;
			}
		}
		
		string head_file;
		int head_frame;
		
		if (player.getBlob() is null) {
			head_frame = getHeadSpecs(player, head_file);
		} else {
			head_frame = player.getBlob().get_s32("head index");
			head_file = player.getBlob().get_string("head texture");
		}
		
		Vec2f head_dims(16,16);
		f32 head_icon_scale = 1.0f;
		Vec2f head_icon_pos = Vec2f(portraitTopLeft.x,portraitBotRight.y)+Vec2f(38, 40);
		GUI::DrawIcon(head_file, head_frame+(getGameTime()%90<60?(getGameTime()%90<40?1:2):0), head_dims, head_icon_pos, head_icon_scale, head_icon_scale, player.getTeamNum(), SColor(0xaaffffff));

		// TODO: need more space for clan badges
		/*f32 clan_badge_icon_scale = 1.0f;
		Vec2f clan_badge_icon_pos = Vec2f(portraitTopLeft.x,portraitBotRight.y)+Vec2f(40, 8);
		if (clantag.toUpper() == "MINECULT") {
			GUI::DrawIcon("Sprites/clan_badges.png", 0, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, player.getTeamNum());
		} else if (clantag.toUpper() == "TTOGAD") {
			GUI::DrawIcon("Sprites/clan_badges.png", 1, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, 0);
		} else if (clantag.toUpper() == "MAGMUS") {
			GUI::DrawIcon("Sprites/clan_badges.png", 2, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, player.getTeamNum());
		} else if (clantag.toUpper() == "HOMEK") {
			GUI::DrawIcon("Sprites/clan_badges.png", 3, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, 0);
		} else if (clantag.toUpper() == "BUTTER") {
			GUI::DrawIcon("Sprites/clan_badges.png", 4, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, 0);
		} else if (clantag.toUpper() == "GRUHSHA") {
			GUI::DrawIcon("Sprites/clan_badges.png", 5, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, 0);
		} else if (clantag.toUpper() == "BUTTERMINA" || clantag.toUpper() == "BUTTERCULT") {
			GUI::DrawIcon("Sprites/clan_badges.png", 6, Vec2f(16, 16), clan_badge_icon_pos, clan_badge_icon_scale, player.getTeamNum());
		}*/
		
	drawHoverExplanation(hovered_accolade, hovered_age, hovered_tier, Vec2f(mousePos.x, mousePos.y+32));
}

void drawHoverExplanation(int hovered_accolade, int hovered_age, int hovered_tier, Vec2f centre_top)
{
	if( //(invalid/"unset" hover)
		(hovered_accolade < 0
		 || hovered_accolade >= accolade_description.length) &&
		(hovered_age < 0
		 || hovered_age >= age_description.length) &&
		(hovered_tier < 0
		 || hovered_tier >= tier_description.length)
	) {
		return;
	}

	string desc = getTranslatedString(
		(hovered_accolade >= 0) ?
			accolade_description[hovered_accolade] :
			hovered_age >= 0 ?
				age_description[hovered_age] :
				tier_description[hovered_tier]
	);

	Vec2f size(0, 0);
	GUI::GetTextDimensions(desc, size);

	Vec2f tl = centre_top - Vec2f(size.x / 2, 0);
	Vec2f br = tl + size;

	//margin
	Vec2f expand(8, 8);
	tl -= expand;
	br += expand;

	GUI::DrawPane(tl, br, SColor(0xffffffff));
	GUI::DrawText(desc, tl + expand, SColor(0xffffffff));
}

void drawAgeIcon(int age, Vec2f position)
{
	int number_gap = 8;
	int years_frame_start = 48;

	if (age >= 10)
	{
		position.x -= number_gap - 4 * 0.5;
		GUI::DrawIcon("AccoladeBadges", years_frame_start + (age / 10), Vec2f(16, 16), position, 1.0f, 0);
		age = age % 10;
		position.x += number_gap;
	}

	GUI::DrawIcon("AccoladeBadges", years_frame_start + age, Vec2f(16, 16), position, 1.0f, 0);
	position.x += 4;

	if(age == 1) position.x -= 1; // fix y letter offset for number 1
	GUI::DrawIcon("AccoladeBadges", 58, Vec2f(16, 16), position, 1.0f, 0); // y letter
}

string[] age_description = {
	"New Player - Welcome them to the game!",
	//first month
	"This player has 1 to 2 weeks of experience",
	"This player has 2 to 3 weeks of experience",
	"This player has 3 to 4 weeks of experience",
	//first year
	"This player has 1 to 2 months of experience",
	"This player has 2 to 3 months of experience",
	"This player has 3 to 6 months of experience",
	"This player has 6 to 9 months of experience",
	"This player has 9 to 12 months of experience",
	//cake day
	"Cake Day - it's this player's KAG Birthday!",
	//(gap in the sheet)
	"", "", "", "", "", "",
	//established player
	"This player has 1 year of experience",
	"This player has 2 years of experience",
	"This player has 3 years of experience",
	"This player has 4 years of experience",
	"This player has 5 years of experience",
	"This player has 6 years of experience",
	"This player has 7 years of experience",
	"This player has 8 years of experience",
	"This player has 9 years of experience",
	"This player has over a decade of experience"
};

string[] tier_description = {
	"", //f2p players, no description
	"This player is a Squire Supporter",
	"This player is a Knight Supporter",
	"This player is a Royal Guard Supporter",
	"This player is a Round Table Supporter"
};