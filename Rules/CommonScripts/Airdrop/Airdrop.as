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
}

void onTick(CRules@ this) {
	if (!isServer() || this.isWarmup() || !(this.gamemode_name == "CTF" || this.gamemode_name == "SmallCTF"))
		return;

	if (!this.exists("airdrop timer")) {
		return;
	} else if (this.get_s32("airdrop timer") <= 0) {
		// reset present timer
		this.set_s32("airdrop timer", airdrop_interval);

		CMap@ map = getMap();
		f32 left = getRules().get_u16("barrier_x1");
		f32 right = getRules().get_u16("barrier_x2");
		const f32 mapCenter = map.tilemapwidth * map.tilesize * 0.5;

		for (uint i = 0; i < crates_to_spawn; i++) {
		    spawnAirdrop(Vec2f(mapCenter, 0), XORRandom(8)).Tag("parachute");
            //spawnAirdrop(Vec2f(map.tilemapwidth * map.tilesize - XORRandom(map.tilemapwidth * map.tilesize / 2), 0), XORRandom(8)).Tag("parachute");
        }
	} else {
		this.sub_s32("airdrop timer", 1);
	}
}

CBlob@ spawnAirdrop(Vec2f spawnpos, u8 team)
{
	return server_CreateBlob("airdropcrate", team, spawnpos);
}