// spawn resources

#include "RulesCore.as";
#include "KOTH_Structs.as";
#include "KOTH_Common.as"; // resupply stuff

// Limit stuff
int builders_limit;

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool drop = false)
{
	CInventory@ inv = blob.getInventory();
	
	//avoid over-stacking arrows
	if (name == "mat_arrows")
	{
		inv.server_RemoveItems(name, quantity);
	}
	
	CBlob@ mat = server_CreateBlobNoInit(name);
	
	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();
		
		mat.server_SetQuantity(quantity);
		
		if (drop || not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}
	
	return true;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!isServer()) return;
	
	if (blob is null) return;
	if (player is null) return;
	
	doGiveSpawnMats(this, player, blob);
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		SetKOTHTimer(this, victim, 0, "archer");
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b)
{
	s32 gametime = getGameTime();
	string name = b.getName();
	builders_limit = this.get_u8("builders_limit");

	/*if (name == "archer")  {
		if (gametime > getKOTHTimer(this, p, "archer"))  {
			CInventory@ inv = b.getInventory();

			if (inv.isInInventory("mat_arrows", 30))  {
				return; // don't give arrows if they have 30 already
			}
			else if (SetMaterials(b, "mat_arrows", 30))  {
				SetKOTHTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond(), "archer");
			}
		}
	}*/

	if (name == "builder" && !this.get_bool("is_warmup")) {
		if (gametime > getKOTHTimer(this, p, "builder")) {
			u8 team = p.getTeamNum();

			int wood_amount = matchtime_wood_amount;
			int stone_amount = matchtime_stone_amount;

			// check amount of builders and give mats depending on the number of builders
			// ONLY FOR OFFI MATCHES
			if (this.hasTag("offi match")) {
				if (builders_limit > 1) {
					wood_amount = matchtime_wood_amount * builders_limit;
					stone_amount = matchtime_stone_amount * builders_limit;
				}
			}

			this.add_s32("teamwood" + team, wood_amount);
			this.Sync("teamwood" + team, true);

			this.add_s32("teamstone" + team, stone_amount);
			this.Sync("teamstone" + team, true);

			SetKOTHTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond(), "builder");
		}
	}
}

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) 
	{
		SetKOTHTimer(this, getPlayer(i), 0, "builder");
		//SetKOTHTimer(this, getPlayer(i), 0, "archer");
	}

	if (!isServer()) return;

	this.set_s32("teamwood" + 0, 0);
	this.Sync("teamwood" + 0, true);
	this.set_s32("teamstone" + 0, 0);
	this.Sync("teamstone" + 0, true);
	//this.set_s32("teamgold" + 0, 0);
	//this.Sync("teamgold" + 0, true);

	this.set_s32("teamwood" + 1, 0);
	this.Sync("teamwood" + 1, true);
	this.set_s32("teamstone" + 1, 0);
	this.Sync("teamstone" + 1, true);
	//this.set_s32("teamgold" + 1, 0);
	//this.Sync("teamgold" + 1, true);
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
	} else {
		CBlob@[] spots;
		getBlobsByName(base_name(),   @spots);
		getBlobsByName("outpost",	@spots);
		getBlobsByName("warboat",	 @spots);
		getBlobsByName("buildershop", @spots);
		//getBlobsByName("archershop",  @spots);
		// getBlobsByName("knightshop",  @spots);
		for (uint step = 0; step < spots.length; ++step) {
			CBlob@ spot = spots[step];
			if (spot is null) continue;

			CBlob@[] overlapping;
			if (!spot.getOverlapping(overlapping)) continue;

			string name = spot.getName();
			bool isShop = (name.find("shop") != -1);

			for (uint o_step = 0; o_step < overlapping.length; ++o_step) {
				CBlob@ overlapped = overlapping[o_step];
				if (overlapped is null) continue;
				
				if (!overlapped.hasTag("player")) continue;
				CPlayer@ p = overlapped.getPlayer();
				if (p is null) continue;

				CBlob@ player_blob = p.getBlob();
				if (player_blob is null) continue;

				u8 team = player_blob.getTeamNum();

				string class_name = overlapped.getName();
				
				if (isShop && name.find(class_name) == -1) continue; // NOTE: builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop

				if (this.get_u8("builders_limit") == 1) {
					if (this.get_s32("teamwood" + team) < 750 && this.get_s32("teamstone" + team) < 500)
						doGiveSpawnMats(this, p, overlapped);
				} else if (this.get_u8("builders_limit") > 1) {
					if (this.get_s32("teamwood" + team) < 1000 && this.get_s32("teamstone" + team) < 750)
						doGiveSpawnMats(this, p, overlapped);
				}
			}
		}
	}

	if (this.getCurrentState() == GAME) { // automatic resupplies for builders
		for (int i = 0; i < getPlayerCount(); i++) {
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			CBlob@ blob = player.getBlob();
			if (blob is null) return;

			u8 team = blob.getTeamNum();

			if (blob !is null && blob.getConfig() == "builder") {
				if (this.get_u8("builders_limit") == 1) {
					if (this.get_s32("teamwood" + team) < 750 && this.get_s32("teamstone" + team) < 500)
						doGiveSpawnMats(this, player, blob);
				} else if (this.get_u8("builders_limit") > 1) {
					if (this.get_s32("teamwood" + team) < 1000 && this.get_s32("teamstone" + team) < 750)
						doGiveSpawnMats(this, player, blob);
				}
			}
		}
	}
}

// Reset timer in case player who joins has an outdated timer
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	s32 next_add_time = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait) * getTicksASecond();

	//if (next_add_time < getKOTHTimer(this, player, "builder") || next_add_time < getKOTHTimer(this, player, "archer"))
	if (next_add_time < getKOTHTimer(this, player, "builder"))
	{
		SetKOTHTimer(this, player, getGameTime(), "builder");
		//SetKOTHTimer(this, player, getGameTime(), "archer");
	}
}
