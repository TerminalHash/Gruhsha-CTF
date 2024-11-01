// AirdropPanel.as
#define CLIENT_ONLY

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	if (!this.isMatchRunning() || !this.exists("airdrop timer")) return;

	if (getRules().get_string("airdrop_panel") == "off") return;

	s32 airdrop = this.get_s32("airdrop timer");

	if (airdrop > 0)
	{
		GUI::DrawIcon("airdrop_panel.png", Vec2f(12, 190));
		s32 timeToAirDrop = airdrop;

		s32 secondsToEnd = timeToAirDrop / 30 % 60;
		s32 MinutesToEnd = timeToAirDrop / 60 / 30;
		drawRulesFont(getTranslatedString("{MIN}:{SEC}")
						.replace("{MIN}", "" + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd))
						.replace("{SEC}", "" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd)),
		              SColor(255, 255, 255, 255), Vec2f(10, 207), Vec2f(150, 180), true, false);
	}
}