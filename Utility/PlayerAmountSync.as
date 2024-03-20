// PlayerAmountSync.as
// by bunnie
void UpdatePlayerCount(CRules@ this)
{
	u32 pcount = 0;
	for (int i=0; i<getPlayersCount(); ++i)
	{
		CPlayer@ p = getPlayer(i);

		if (p !is null)
		{
			if (p.getTeamNum() == 0 || p.getTeamNum() == 1)
			{
				pcount++;
			}
		}
	}

	if (isServer())
	{
		CBitStream params;
		params.write_s32(pcount);
		this.SendCommand(this.getCommandID("SYNC_PLAYER_VALUE"), params);

		this.set_s32("amount_in_team", pcount);
	}
}

void onRestart(CRules@ this)
{
	UpdatePlayerCount(this);
}

void onInit(CRules@ this)
{
	this.addCommandID("SYNC_PLAYER_VALUE");
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("SYNC_PLAYER_VALUE") && isClient())
	{
		s32 player_amount = params.read_s32();
		printf("AMOUNT OF PLAYERS IN TEAM: " + player_amount);
		this.set_s32("amount_in_team", player_amount);

		CBlob@[] shoplist;
		if (getBlobsByTag("can reset menu", shoplist))
		{ 
			for (int i = 0; i < shoplist.size(); ++i)
			{
				CBlob@ currentshop = shoplist[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	if (!isServer()) return;

	if (player !is null)
	{
		u32 pcount = this.get_s32("amount_in_team");

		CBitStream params;
		params.write_s32(pcount);
		this.SendCommand(this.getCommandID("SYNC_PLAYER_VALUE"), params, player);
	}
}