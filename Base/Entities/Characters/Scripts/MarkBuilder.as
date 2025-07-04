// MarkBuilder.as

#include "BindingsCommon.as"

void onRender(CRules@ this)
{
	const uint update_latency = 15;
	uint ticks_since_pressed = 0;
	const float base_brightness = Maths::Abs(Maths::Sin((ticks_since_pressed - update_latency) / 20.0f));

	CMap@ map = getMap();
	if (map is null) return;

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	if (b_KeyPressed("mark_team_builder"))
	{
		CBlob@[] boldarlist;

		if (getBlobsByName("builder", boldarlist))
		{
			for (int i = 0; i < boldarlist.size(); ++i)
			{
				CBlob@ builder = boldarlist[i];

				const u8 map_luminance = map.getColorLight(builder.getPosition()).getLuminance();
				const uint effect_brightness = base_brightness * map_luminance;

				if (builder.getTeamNum() != me.getTeamNum() || builder.hasTag("dead")) {
					continue;
				} else {
					CBlob@ player = me.getBlob();

					if (player !is null) {
						GUI::DrawArrow2D(player.getInterpolatedScreenPos(), builder.getInterpolatedScreenPos(), SColor(255, 235,  0,  0));
						GUI::DrawIcon("Characters/Sprites/MarkArrow.png", 0, Vec2f(32, 16), Vec2f(builder.getInterpolatedScreenPos().x - 30, builder.getInterpolatedScreenPos().y - 55), 1.0f, 255);
						builder.RenderForHUD(RenderStyle::outline);
						builder.RenderForHUD(RenderStyle::normal);
					}
				}
			}
		}
	}

	CBlob@ myblob = me.getBlob();
	if (myblob is null) return;

	if (me !is null && myblob !is null) {
		int bobr = 70;

		if (myblob.hasTag("icy")) {
			GUI::DrawIcon("Sprites/HUD/DebuffIcons.png", 0, Vec2f(17, 19), Vec2f(myblob.getInterpolatedScreenPos().x - 15, myblob.getInterpolatedScreenPos().y - bobr), 1.0f, 255);
			bobr += 40;
		}

		if (myblob.hasTag("broken shield")) {
			GUI::DrawIcon("Sprites/HUD/DebuffIcons.png", 1, Vec2f(17, 19), Vec2f(myblob.getInterpolatedScreenPos().x - 15, myblob.getInterpolatedScreenPos().y - bobr), 1.0f, me.getTeamNum());
		}
	}
}
