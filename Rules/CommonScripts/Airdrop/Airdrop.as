// Airdrop.as
// Based on Christmas.as
/*
    Erzats-airdrop system for Gruhsha CTF
    Loot table in AirdropCommon.as, here only logic for airdrop itself!
*/

const int airdrop_interval = getTicksASecond() * 60 * 8; // 8 minutes
const int crates_to_spawn = 1;

void onInit(CRules@ this) {
	onRestart(this);
}

void onRestart(CRules@ this) {
	this.set_s32("airdrop timer", airdrop_interval);
	this.set_s32("airdrop_in", getGameTime() + airdrop_interval);
}

void onTick(CRules@ this) {
	if (!isServer() || this.isWarmup() || !(this.gamemode_name == "CTF" || this.gamemode_name == "SmallCTF"))
		return;

	if (!this.exists("airdrop timer")) {
		return;
	} else if (this.get_s32("airdrop timer") <= 0) {
		// reset present timer
		this.set_s32("airdrop timer", airdrop_interval);
		this.set_s32("airdrop_in", getGameTime() + airdrop_interval);

		CMap@ map = getMap();
		const f32 mapCenter = map.tilemapwidth * map.tilesize * 0.5;

		for (uint i = 0; i < crates_to_spawn; i++) {
		    spawnAirdrop(Vec2f(mapCenter, 0), XORRandom(8)).Tag("parachute");
            //spawnAirdrop(Vec2f(map.tilemapwidth * map.tilesize - XORRandom(map.tilemapwidth * map.tilesize / 2), 0), XORRandom(8)).Tag("parachute");
        }
	} else {
		this.sub_s32("airdrop timer", 1);

		s32 airdrop_in = this.get_s32("airdrop_in");

		this.set_s32("airdrop will drop in", (s32(airdrop_in) - s32(getGameTime())) / 30);
		this.Sync("airdrop will drop in", true);
	}
}

CBlob@ spawnAirdrop(Vec2f spawnpos, u8 team)
{
	return server_CreateBlob("airdropcrate", team, spawnpos);
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	if (!this.isMatchRunning() || !this.exists("airdrop timer")) return;

	if (getRules().get_string("airdrop_panel") == "off") return;

	s32 airdrop = this.get_s32("airdrop will drop in");

	if (airdrop > 0)
	{
		GUI::DrawIcon("airdrop_panel.png", Vec2f(12, 190));
		s32 timeToAirDrop = airdrop;

		s32 secondsToEnd = timeToAirDrop % 60;
		s32 MinutesToEnd = timeToAirDrop / 60;
		drawRulesFont(getTranslatedString("{MIN}:{SEC}")
						.replace("{MIN}", "" + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd))
						.replace("{SEC}", "" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd)),
		              SColor(255, 255, 255, 255), Vec2f(10, 207), Vec2f(150, 180), true, false);
	}
}