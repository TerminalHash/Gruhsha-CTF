class ApprovedTeams
{
	string[] blue_members;
	string[] red_members;

	ApprovedTeams()
	{
	}

	void ClearLists()
	{
		blue_members.clear();
		red_members.clear();
	}

	void FormLists()
	{
		for (u8 idx = 0; idx<getPlayerCount(); ++idx) {
			CPlayer@ particular_player = getPlayer(idx);
			if (particular_player is null) continue;

			if (particular_player.getTeamNum()==0)
				blue_members.push_back(particular_player.getUsername());
			else if (particular_player.getTeamNum()==1)
				red_members.push_back(particular_player.getUsername());
		}
	}

	void PrintMembers()
	{
		print("\n\nblue members: \n");
		for (u8 blue_i = 0; blue_i<blue_members.size(); ++blue_i) {
			print("-  "+blue_members[blue_i]);
		}
		print("\n\nred members: \n");
		for (u8 red_i = 0; red_i<red_members.size(); ++red_i) {
			print("-  "+red_members[red_i]);
		}
	}

	bool isApprovedMember(CPlayer@ player)
	{
		return blue_members.find(player.getUsername())>-1||red_members.find(player.getUsername())>-1;
	}

	u8 getPlayerTeam(CPlayer@ player)
	{
		print("searching for "+player.getUsername());
		//when a player rejoins the match they played in they're being put back
		int blue_search = blue_members.find(player.getUsername());
		print("blue search "+blue_search);
		if (blue_search>-1)
			return 0;

		int red_search = red_members.find(player.getUsername());
		print("red search "+red_search);
		if (red_search>-1)
			return 1;

		//otherwise they're put into spectators
		return getRules().getSpectatorTeamNum();
	}
}

bool isPickingEnded()
{
	CRules@ rules = getRules();
	ApprovedTeams@ approved_teams;
	if (!rules.get("approved_teams", @approved_teams)) return true;

	return approved_teams.blue_members.size()>0||approved_teams.red_members.size()>0;
}