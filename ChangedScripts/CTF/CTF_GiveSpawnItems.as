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
		for (uint i = 0; i < getPlayersCount(); ++i)
		{
			CPlayer@ p = getPlayer(i);
			if (p is null) continue;

			this.set_s32("personalwood_" + p.getUsername(), 1000);
			this.Sync("personalwood_" + p.getUsername(), true);

			this.set_s32("personalstone_" + p.getUsername(), 1000);
			this.Sync("personalstone_" + p.getUsername(), true);
		}
	}
}

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) 
	{
		SetCTFTimer(this, getPlayer(i), 0, "archer");
	}

	if (!isServer()) return;

	this.set_s32("woodpool" + 0, 0);
	this.Sync("woodpool" + 0, true);
	this.set_s32("stonepool" + 0, 0);
	this.Sync("stonepool" + 0, true);

	this.set_s32("woodpool" + 1, 0);
	this.Sync("woodpool" + 1, true);
	this.set_s32("stonepool" + 1, 0);
	this.Sync("stonepool" + 1, true);

	AddTeamMats(this, 0, 800, 2000);
	AddTeamMats(this, 1, 800, 2000);

	for (uint i = 0; i < getPlayersCount(); ++i) 
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;

		this.set_s32("personalwood_" + p.getUsername(), 0);
		this.Sync("personalwood_" + p.getUsername(), true);

		this.set_s32("personalstone_" + p.getUsername(), 0);
		this.Sync("personalstone_" + p.getUsername(), true);
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

	this.add_s32("woodpool" + team, this.get_s32("personalwood_" + player.getUsername()));
	this.Sync("woodpool" + team, true);
	this.set_s32("personalwood_" + player.getUsername(), 0);
	this.Sync("personalwood_" + player.getUsername(), true);

	this.add_s32("stonepool" + team, this.get_s32("personalstone_" + player.getUsername()));
	this.Sync("stonepool" + team, true);
	this.set_s32("personalstone_" + player.getUsername(), 0);
	this.Sync("personalstone_" + player.getUsername(), true);
}

// Take mats from team pool and give them to builder-tagged players.
void GiveOutMats(CRules@ this, u8 team)
{
	s32 wood_pool = this.get_s32("woodpool" + team);
	s32 stone_pool = this.get_s32("stonepool" + team);

	CPlayer@[] players_to_give;
	CPlayer@[] players_to_give_w;
	CPlayer@[] players_to_give_s;

	for (int i=0; i<getPlayersCount(); ++i)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;
		if (p.getTeamNum() != team) continue;
		// didnt play builder for last 2 min && not tagged for alwaysgetmats?
		if ((getGameTime() - this.get_s32("lastbuildertime_" + p.getUsername()) >= 120 * getTicksASecond()) && !this.hasTag("alwaysgetmats_" + p.getUsername())) continue; 

		players_to_give.push_back(p);
		if (this.get_s32("personalwood_" + p.getUsername()) < 3000) players_to_give_w.push_back(p);
		if (this.get_s32("personalstone_" + p.getUsername()) < 1000) players_to_give_s.push_back(p);
	}

	if (players_to_give_w.length > 0)
	{
		u32 wood_per_player = wood_pool / players_to_give_w.length;
		for (int i=0; i<players_to_give_w.length; ++i)
		{
			CPlayer@ p = players_to_give_w[i];
			if (p is null) continue;

			s32 changenumber = wood_per_player;
			u32 personalwood = this.get_s32("personalwood_" + p.getUsername());

			if (personalwood + wood_per_player > 3000)
			{
				changenumber = (3000 - personalwood);
			}
			this.add_s32("personalwood_" + p.getUsername(), changenumber);
			this.sub_s32("woodpool" + team, changenumber);

			this.Sync("personalwood_" + p.getUsername(), true);
		}
	}
	if (players_to_give_s.length > 0)
	{
		u32 stone_per_player = stone_pool / players_to_give_s.length;

		for (int i=0; i<players_to_give_s.length; ++i)
		{
			CPlayer@ p = players_to_give_s[i];
			if (p is null) continue;

			s32 changenumber = stone_per_player;
			u32 personalstone = this.get_s32("personalstone_" + p.getUsername());

			if (personalstone + stone_per_player > 1000)
			{
				changenumber = (1000 - personalstone);
			}
			this.add_s32("personalstone_" + p.getUsername(), changenumber);
			this.sub_s32("stonepool" + team, changenumber);

			this.Sync("personalstone_" + p.getUsername(), true);
		}
	}

	this.Sync("woodpool" + team, true);
	this.Sync("stonepool" + team, true);
}

// Add mats to team pool.
// TAG FOR MATS: getting_mats_username
// PERSONAL MATS: personalwood_username, personalstone_username
void AddTeamMats(CRules@ this, u8 team, u32 stone, u32 wood)
{
	this.add_s32("woodpool" + team, wood);
	this.add_s32("stonepool" + team, stone);

	this.Sync("woodpool" + team, true);
	this.Sync("stonepool" + team, true);
}

u32 resupply_time = 15 * getTicksASecond();

void onTick(CRules@ this)
{
	if (!isServer())
		return;

	u32 mt = getRules().get_u32("match_time");

	if (mt % resupply_time == 1 && this.getCurrentState() == GAME)
	{
		GiveOutMats(this, 0);
		GiveOutMats(this, 1);
		AddTeamMats(this, 0, 140, 375);
		AddTeamMats(this, 1, 140, 375);
	}

	// update last builder time
	if (getGameTime() % 30 == 0)
	{
		for (int i = 0; i < getPlayerCount(); i++) 
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			if (player.getTeamNum() == this.getSpectatorTeamNum()) continue;

			CBlob@ blob = player.getBlob();
			if (blob !is null) 
			{
				if (blob.getName() == "builder" || this.get_s32("lastbuildertime_" + player.getUsername()) > getGameTime())
				{
					this.set_s32("lastbuildertime_" + player.getUsername(), getGameTime());
					this.Sync("lastbuildertime_" + player.getUsername(), true);
				}

				if (blob.getName() != "builder" && this.getCurrentState() != GAME)
				{
					this.set_s32("lastbuildertime_" + player.getUsername(), -3600);
					this.Sync("lastbuildertime_" + player.getUsername(), true);
				}
			}

			// if more than 2min since last being builder, no always tag, give away mats to team pool
			if (getGameTime() - this.get_s32("lastbuildertime_" + player.getUsername()) >= 120 * getTicksASecond() && !this.hasTag("alwaysgetmats_" + player.getUsername()))
			{
				ResetPlayerMats(this, player, player.getTeamNum());
			}
		}
	}
	
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
	}

	s32 next_add_time = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait) * getTicksASecond();

	if (next_add_time < getCTFTimer(this, player, "builder") || next_add_time < getCTFTimer(this, player, "archer"))
	{
		SetCTFTimer(this, player, getGameTime(), "builder");
		SetCTFTimer(this, player, getGameTime(), "archer");
	}
}
