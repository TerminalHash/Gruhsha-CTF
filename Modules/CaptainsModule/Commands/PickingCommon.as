bool canChangeTeamByRequest()
{
	CRules@ rules = getRules();

	for (u8 team_num = 0; team_num<2; ++team_num) {
		if (!rules.get_string("team_"+team_num+"_leader").empty())
			return false;
	}

	return true;
}

void DemoteLeaders()
{
	CRules@ rules = getRules();

	for (u8 team_num = 0; team_num<2; ++team_num) {
		rules.set_string("team_"+team_num+"_leader", "");
	}
}

void SyncLeaders()
{
	CRules@ rules = getRules();
	//so sync thinks it's desynced
	if (isClient())
		DemoteLeaders();

	for (u8 team_num = 0; team_num<2; ++team_num) {
		rules.Sync("team_"+team_num+"_leader", true);
	}
}

void PutEveryoneInSpec()
{
	CRules@ rules = getRules();

	RulesCore@ core;

	rules.get("core", @core);
	if (core is null) return;

	const u8 SPEC_TEAM = rules.getSpectatorTeamNum();

	for (u8 plr_idx = 0; plr_idx<getPlayerCount(); ++plr_idx) {
		CPlayer@ particular_player = getPlayer(plr_idx);
		if (particular_player is null) continue;
		core.ChangePlayerTeam(particular_player, SPEC_TEAM);
	}
}

CPlayer@ getPlayerByNamePart(string username)
{
	username = username.toLower();

	for (int i=0; i<getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		string player_name = player.getUsername().toLower();
		string player_nickname = player.getCharacterName().toLower();

		bool match_in_username = player_name == username || (username.size()>=3 && player_name.findFirst(username,0)==0);
		bool match_in_nickname = player_nickname == username || (username.size()>=3 && player_nickname.findFirst(username,0)==0);

		if (match_in_username || match_in_nickname) return player;
	}
	return null;
}