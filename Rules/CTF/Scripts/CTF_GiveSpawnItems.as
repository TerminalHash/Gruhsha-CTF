// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_Common.as"; // resupply stuff

// Limit stuff
	// class
int builders_limit;
	// materials
u32 mat_delay;
int wood_limit;
int stone_limit;

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!isServer()) return;
	
	if (blob is null) return;
	if (player is null) return;
	
	//doGiveSpawnMats(this, player, blob);
	//if (blob !is null && blob.getConfig() == "builder")
		//doGiveMats(this);
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData) {
	if (victim !is null) {
		// possible fix issue with broken timer for builder
		SetCTFTimer(this, victim, this.get_s32("nextresuply"), "builder");
	}
}

// egor's function for builder resupplies
// backported from Pear Seed and modified
void doGiveMats(CRules@ this) {
	//printf("[DEBUG] Starting material distribution!");

	s32 gametime = getGameTime();

	mat_delay = materials_wait;

	s32 next_resuply = gametime + mat_delay * getTicksASecond();
	this.set_s32("nextresuply", next_resuply);
	this.Sync("nextresuply", true);

	int wood_amount = matchtime_wood_amount;
	int stone_amount = matchtime_stone_amount;

	builders_limit = this.get_u8("builders_limit");

	if (getGameTime() > lower_mats_timer * getTicksASecond()) {
		wood_amount = lower_wood;
		stone_amount = lower_stone;

		//printf("[DEBUG] We have half of match, lowering materials");
	}

	// check amount of builders and give mats depending on the number of builders
	// ONLY FOR OFFI MATCHES
	if (this.hasTag("offi match")) {
		//printf("[DEBUG] Set limits, wood to " + wood_limit + ", stone to " + stone_limit);
		wood_limit = 2000;
		stone_limit = 1000;

		if (builders_limit > 1) {
			wood_amount = matchtime_wood_amount * builders_limit;
			stone_amount = matchtime_stone_amount * builders_limit;

			mat_delay = materials_wait_longer;

			wood_limit = 4000;
			stone_limit = 2000;

			//printf("[DEBUG] Update material limits, delay and amount of materials");
		}

		if (builders_limit > 1 && getGameTime() > lower_mats_timer * getTicksASecond()) {
			wood_amount = lower_wood * builders_limit;
			stone_amount = lower_stone * builders_limit;

			mat_delay = materials_wait_longer;

			wood_limit = 4000;
			stone_limit = 2000;

			//printf("[DEBUG] Update material limits, delay and lower amount of materials");
		}
	}

	for (int team = 0; team < 2; team++) {
		//printf("[DEBUG] Trying to add wood and stone, checking limits...");
	
		if (this.get_s32("teamwood" + team) < wood_limit) {
			this.add_s32("teamwood" + team, wood_amount);
			this.Sync("teamwood" + team, true);

			//printf("[DEBUG] Add " + wood_amount + " of wood to team " + team);
		}

		if (this.get_s32("teamstone" + team) < stone_limit) {
			this.add_s32("teamstone" + team, stone_amount);
			this.Sync("teamstone" + team, true);

			//printf("[DEBUG] Add " + stone_amount + " of stone to team " + team);
		}
	}

	for (int i = 0; i < getPlayerCount(); i++) {
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		SetCTFTimer(this, player, next_resuply, "builder");
		//printf("[DEBUG] Timer is set for players, material distribution is done!");
		//printf("[DEBUG] Next resupply willwill be delivered in " + next_resuply);
		//printf("[DEBUG] Current time is " + getGameTime());
		//printf("---------------------------------------");
	}
}

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i)  {
		SetCTFTimer(this, getPlayer(i), 0, "builder");
	}

	if (!isServer()) return;

	this.set_s32("teamwood" + 0, 0);
	this.Sync("teamwood" + 0, true);
	this.set_s32("teamstone" + 0, 0);
	this.Sync("teamstone" + 0, true);

	this.set_s32("teamwood" + 1, 0);
	this.Sync("teamwood" + 1, true);
	this.set_s32("teamstone" + 1, 0);
	this.Sync("teamstone" + 1, true);

	this.set_s32("nextresuply", 0);
	this.Sync("nextresuply", true);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	if (!isServer())
		return;

	s32 gametime = getGameTime();

	if (this.getCurrentState() == WARMUP) {
		if (getGameTime() == 60) {
			this.set_s32("teamwood" + 0, 6000);
			this.Sync("teamwood" + 0, true);
			this.set_s32("teamwood" + 1, 6000);
			this.Sync("teamwood" + 1, true);

			this.set_s32("teamstone" + 0, 4500);
			this.Sync("teamstone" + 0, true);
			this.set_s32("teamstone" + 1, 4500);
			this.Sync("teamstone" + 1, true);
		}

		u32 pog = 30 * 179;

		if (getGameTime() == pog && this.hasTag("offi match")) {
			this.set_s32("teamwood" + 0, 1000);
			this.Sync("teamwood" + 0, true);
			this.set_s32("teamwood" + 1, 1000);
			this.Sync("teamwood" + 1, true);

			this.set_s32("teamstone" + 0, 400);
			this.Sync("teamstone" + 0, true);
			this.set_s32("teamstone" + 1, 400);
			this.Sync("teamstone" + 1, true);
		}
	}

	// automatic resupplies for builders
	if (gametime >= this.get_s32("nextresuply")) {
		doGiveMats(this);
	}
}

// Reset timer in case player who joins has an outdated timer
void onNewPlayerJoin(CRules@ this, CPlayer@ player) {
	if (this.getCurrentState() == WARMUP)
		SetCTFTimer(this, player, 0, "builder");
	else
		SetCTFTimer(this, player, this.get_s32("nextresuply"), "builder");
}
