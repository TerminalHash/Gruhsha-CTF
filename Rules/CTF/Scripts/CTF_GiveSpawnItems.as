// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_Common.as"; // resupply stuff

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
		SetCTFTimer(this, victim, 0, "archer");
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b)
{
	s32 gametime = getGameTime();
	string name = b.getName();

	if (name == "archer") 
	{
		if (gametime > getCTFTimer(this, p, "archer")) 
		{
			CInventory@ inv = b.getInventory();
			if (inv.isInInventory("mat_arrows", 30)) 
			{
				return; // don't give arrows if they have 30 already
			}
			else if (SetMaterials(b, "mat_arrows", 30)) 
			{
				SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond(), "archer");
			}
		}
	}

	if (name == "builder")
	{
		if (gametime > getCTFTimer(this, p, "builder"))
		{

			int wood_amount = matchtime_wood_amount;
			int stone_amount = matchtime_stone_amount;

			if (this.isWarmup())
			{
				wood_amount = warmup_wood_amount;
				stone_amount = warmup_stone_amount;
			}

			if (getGameTime() > lower_mats_timer * getTicksASecond())
			{
				wood_amount = lower_wood;
				stone_amount = lower_stone;
			}

			if (this.get_s32("personalwood_" + p.getUsername()) < 2000)
			{
				this.add_s32("personalwood_" + p.getUsername(), wood_amount);
				this.Sync("personalwood_" + p.getUsername(), true);
			}

			if (this.get_s32("personalstone_" + p.getUsername()) < 2000)
			{
				this.add_s32("personalstone_" + p.getUsername(), stone_amount);
				this.Sync("personalstone_" + p.getUsername(), true);
			}

			SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond(), "builder");
		}
	}
}

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) 
	{
		SetCTFTimer(this, getPlayer(i), 0, "builder");
		SetCTFTimer(this, getPlayer(i), 0, "archer");
	}

	if (!isServer()) return;

/*
	this.set_s32("teamwood" + 0, 0);
	this.Sync("teamwood" + 0, true);
	this.set_s32("teamstone_" + 0, 0);
	this.Sync("teamstone_" + 0, true);
	this.set_s32("teamgold" + 0, 0);
	this.Sync("teamgold" + 0, true);


	this.set_s32("teamwood" + 1, 0);
	this.Sync("teamwood" + 1, true);
	this.set_s32("teamstone" + 1, 0);
	this.Sync("teamstone" + 1, true);
	this.set_s32("teamgold" + 1, 0);
	this.Sync("teamgold" + 1, true);
*/

	for (uint i = 0; i < getPlayersCount(); ++i)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;

		this.set_s32("personalwood_" + p.getUsername(), 0);
		this.Sync("personalwood_" + p.getUsername(), true);

		this.set_s32("personalstone_" + p.getUsername(), 0);
		this.Sync("personalstone_" + p.getUsername(), true);

		//this.set_s32("personalgold_" + p.getUsername(), 0);
		//this.Sync("personalgold_" + p.getUsername(), true);
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if (!isServer()) return;

	ResetPlayerMats(this, player, player.getTeamNum());
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
	ResetPlayerMats(this, player, oldteam);
}

// and give to team
void ResetPlayerMats(CRules@ this, CPlayer@ player, u8 team)
{
	if (this is null) return;
	if (!isServer()) return;
	if (player is null) return;

	this.set_s32("personalwood_" + player.getUsername(), 0);
	this.Sync("personalwood_" + player.getUsername(), true);

	this.set_s32("personalstone_" + player.getUsername(), 0);
	this.Sync("personalstone_" + player.getUsername(), true);

	//this.set_s32("personalgold_" + player.getUsername(), 0);
	//this.Sync("personalgold_" + player.getUsername(), true);
}

void onTick(CRules@ this)
{
	if (!isServer())
		return;

	s32 gametime = getGameTime();

	if ((gametime % 15) != 5)
		return;

	if (this.isWarmup()) 
	{
		// during building time, give everyone resupplies no matter where they are
		for (int i = 0; i < getPlayerCount(); i++) 
		{
			CPlayer@ player = getPlayer(i);
			CBlob@ blob = player.getBlob();
			if (blob !is null) 
			{
				doGiveSpawnMats(this, player, blob);
			}
		}
	}
	else
	{
		CBlob@[] spots;
		getBlobsByName(base_name(),   @spots);
		getBlobsByName("outpost",	@spots);
		getBlobsByName("warboat",	 @spots);
		getBlobsByName("buildershop", @spots);
		getBlobsByName("archershop",  @spots);
		// getBlobsByName("knightshop",  @spots);
		for (uint step = 0; step < spots.length; ++step)
		{
			CBlob@ spot = spots[step];
			if (spot is null) continue;

			CBlob@[] overlapping;
			if (!spot.getOverlapping(overlapping)) continue;

			string name = spot.getName();
			bool isShop = (name.find("shop") != -1);

			for (uint o_step = 0; o_step < overlapping.length; ++o_step)
			{
				CBlob@ overlapped = overlapping[o_step];
				if (overlapped is null) continue;
				
				if (!overlapped.hasTag("player")) continue;
				CPlayer@ p = overlapped.getPlayer();
				if (p is null) continue;

				string class_name = overlapped.getName();
				
				if (isShop && name.find(class_name) == -1) continue; // NOTE: builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop

				doGiveSpawnMats(this, p, overlapped);
			}
		}
	}


	if (this.getCurrentState() == GAME) // automatic resupplies for builders
	{
		for (int i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			CBlob@ blob = player.getBlob();

			if (blob !is null && blob.getConfig() == "builder")
			{
				doGiveSpawnMats(this, player, blob);
			}
		}
	}
}

// Reset timer in case player who joins has an outdated timer
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		this.set_s32("personalwood_" + player.getUsername(), 0);
		this.Sync("personalwood_" + player.getUsername(), true);

		this.set_s32("personalstone_" + player.getUsername(), 0);
		this.Sync("personalstone_" + player.getUsername(), true);

		//this.set_s32("personalgold_" + player.getUsername(), 0);
		//this.Sync("personalgold_" + player.getUsername(), true);
	}

	s32 next_add_time = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait) * getTicksASecond();

	if (next_add_time < getCTFTimer(this, player, "builder") || next_add_time < getCTFTimer(this, player, "archer"))
	{
		SetCTFTimer(this, player, getGameTime(), "builder");
		SetCTFTimer(this, player, getGameTime(), "archer");
	}
}
