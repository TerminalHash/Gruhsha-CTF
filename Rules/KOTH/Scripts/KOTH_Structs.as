// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

namespace ItemFlag
{

	const u32 Builder = 0x01;
	const u32 Archer = 0x02;
	const u32 Knight = 0x04;

}
/*
shared class ControlPointInfo : CPInfo {
    CPInfo(){}
  
    int[] teams;
    int[] cp_owned_by_team;
    bool[] cp_is_capped;
    bool[] both_team_on_cp;

    void addTeam(int team)
    {
        for(int i = 0; i < teams.size(); i++)
        {
            if(teams[i] == team)
            {
                return;

            }

        }

        teams.push_back(team);

    }

    CBitStream serialize()
    {
		CBitStream bt;
		bt.write_u16(0x5afe); //check bits

        for(int i = 0; i < teams.size(); i++)
        {
            bt.write_u8(teams[i]);
            string stuff = "";
            for(int j = 0; j < flagTeams.size(); j++)
            {
                if(flagTeams[j] == teams[i])
                {
                    stuff += flagStates[j];

                }

            }
            bt.write_string(stuff);

        }
        return bt;

    }
}
*/
shared class KOTHPlayerInfo : PlayerInfo
{
	u32 can_spawn_time;

	u32 spawn_point;

	u32 items_collected;

	KOTHPlayerInfo() { Setup("", 0, ""); }
	KOTHPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		spawn_point = 0;

		items_collected = 0;
	}
};

//teams

shared class KOTHTeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;

	KOTHTeamInfo() { super(); }

	KOTHTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		//spawns.clear();
	}
};
