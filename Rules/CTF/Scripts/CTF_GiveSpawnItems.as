// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_Common.as";
#include "CrouchCommon.as";

bool SetMaterials(CBlob@ blob, const string &in name, const int quantity, bool drop = false)
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
	if (!getNet().isServer()) return;
	
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
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, string modifier="none")
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
}

// normal hooks

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) {
		SetCTFTimer(this, getPlayer(i), 0, "archer");
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	s32 next_add_time = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond();

	if (next_add_time < getCTFTimer(this, player, "builder") || next_add_time < getCTFTimer(this, player, "archer"))
	{
		SetCTFTimer(this, player, getGameTime(), "archer");
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onStateChange( CRules@ this, const u8 oldState )
{
	if (this.getCurrentState() == GAME)
	{
		this.set_u32("nextresupplytime", getGameTime() + (30 * getTicksASecond()));

		if (!isServer()) return;
	}
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;
	
	s32 gametime = getGameTime();

	if (this.get_bool("is_warmup"))
	{
		if (getGameTime() == 60)
		{
			CBlob@[] blist;

			if (getBlobsByName("tent", blist))
			{
				for(uint step=0; step<blist.length; ++step)
				{
					SetMaterials(blist[step], "mat_wood", 3000, false);
					SetMaterials(blist[step], "mat_stone", 1500, false);
				}
			}
		}

    	if (true)
    	{
    		u32 hehe = 175 * 30;

    		u32 hehe2 = 176 * 30;
    		if (getGameTime() == hehe)
    		{
    			CBlob@[] klist;
    			CBlob@[] hlist;

    			if (getBlobsByName("mat_wood", klist))
    			{
    				for(uint step=0; step<klist.length; ++step)
					{
						klist[step].server_Die();
					}
    			}

    			if (getBlobsByName("mat_stone", hlist))
    			{
    				for(uint step=0; step<hlist.length; ++step)
					{
						hlist[step].server_Die();
					}
    			}
    		}
    		else if (getGameTime() == hehe2)
    		{
    			CBlob@[] blist;

				if (getBlobsByName("tent", blist))
				{
					for(uint step=0; step<blist.length; ++step)
					{
							SetMaterials(blist[step], "mat_wood", 1000, false);
							SetMaterials(blist[step], "mat_stone", 400, false);
					}
				}
    		}
    	}
	}

	if (this.getCurrentState() == GAME)
	{
		u32 currenttime = getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime()/getTicksASecond();

		if(getGameTime() == this.get_u32("nextresupplytime"))
		{
			CBlob@[] blist;
				
			if (getBlobsByName("tent", blist))
			{
				for(uint step=0; step<blist.length; ++step)
				{
					SetMaterials(blist[step], "mat_wood", matchtime_wood_amount, false);
					SetMaterials(blist[step], "mat_stone", matchtime_stone_amount, false);
				}
			}

			this.set_u32("nextresupplytime", getGameTime() + (30 * getTicksASecond()));
			this.Sync("nextresupplytime", true);
		}
	}

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
				
				if (isShop && name.find(overlapped.getName()) == -1) continue; // NOTE(hobey): builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop
					
				doGiveSpawnMats(this, p, overlapped);
			}
		}
	}
}