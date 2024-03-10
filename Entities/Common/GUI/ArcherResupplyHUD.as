#include "CTF_Common.as";

void DrawArchResupplyOnHUD(CBlob@ this, Vec2f tl)
{
	CPlayer@ p = this.getPlayer();
	if (p is null) return;

	string name = this.getName();
	int team = this.getTeamNum();

	GUI::SetFont("menu");

	string propname = getCTFTimerPropertyName(p, "archer");

	if (!getRules().exists(propname)) return;

	int wood_amount = matchtime_wood_amount;
	int stone_amount = matchtime_stone_amount;
	if (getRules().isWarmup())
	{
		wood_amount = warmup_wood_amount;
		stone_amount = warmup_stone_amount;
	}

	s32 next_items = getRules().get_s32(propname);

	u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
	string units = ((secs != 1) ? " seconds" : " second");

	string resupply_available = getTranslatedString("Go to an archer shop or a respawn point to get a resupply of 30 arrows.");

	Vec2f dim_res_av;
	GUI::GetTextDimensions(resupply_available, dim_res_av);

	string resupply_unavailable = getTranslatedString("Next resupply of 30 arrows in {SEC}{TIMESUFFIX}.")
				.replace("{SEC}", "" + secs)
				.replace("{TIMESUFFIX}", getTranslatedString(units));

	Vec2f dim_res_unav;
	GUI::GetTextDimensions(resupply_unavailable, dim_res_unav);

	string short_secs = secs + "s";

	Vec2f icon_pos = tl;
	Vec2f icon_size = Vec2f(16, 16);

	u16 material_display_width = 32;
	u16 material_display_height = 46;

	bool hover = hoverOnResupplyIcon(icon_pos, icon_size);

	GUI::DrawPane(tl + Vec2f(0, 0), tl + Vec2f(material_display_width, material_display_height), SColor(255, 200, 200, 200));
	if (next_items > getGameTime())
	{
		GUI::DrawIcon("ArcherResupplyIcon.png", 0, icon_size, icon_pos, 1.0f, team);
		GUI::DrawTextCentered(short_secs, icon_pos + Vec2f(14, 36), color_white);

		if (hover)
		{
			GUI::DrawText(resupply_unavailable, icon_pos + Vec2f(icon_size.x * 2 - dim_res_unav.x + 8, -24), color_white);
		}
	}
	else
	{
		GUI::DrawIcon("ArcherResupplyIcon.png", 1, icon_size, icon_pos + Vec2f(0, 4), 1.0f, team);

		if (hover)
		{
			GUI::DrawText(resupply_available, icon_pos + Vec2f(icon_size.x * 2 - dim_res_av.x + 8, -24), color_white);
		}
	}
}