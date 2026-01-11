#include "ChatCommand.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"
#include "BindingsCommon.as"
#include "TranslationsSystem.as"

class SpecAllCommand : ChatCommand
{
	SpecAllCommand()
	{
		super("specall", Descriptions::specallcomtext);
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		//Sound::Play("achievement");

		if (!isServer()) return;

		PutEveryoneInSpec();
	}
}

class AppointCommand : ChatCommand
{
	AppointCommand()
	{
		super("appoint", Descriptions::appointcomtext);
		AddAlias("caps");
		AddAlias("captains");
		SetUsage("<blue leader username> <red leader username>");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (args.size() > 1)
		{
			CRules@ rules = getRules();

			const string BLUE_LEADER_NAME = args[0];
			const string RED_LEADER_NAME = args[1];

			CPlayer@ blue_leader = getPlayerByNamePart(BLUE_LEADER_NAME);
			CPlayer@ red_leader = getPlayerByNamePart(RED_LEADER_NAME);

			if (blue_leader is null) {
				error("[CAPTAINS SYSTEM] blue leader doesn't exists! try again");
				return;
			}
			if (red_leader is null) {
				error("[CAPTAINS SYSTEM] red leader doesn't exists! try again");
				return;
			}

			// if admin accidentally wrote the same player's name twice
			if (blue_leader.getUsername() == red_leader.getUsername() || red_leader.getUsername() == blue_leader.getUsername())
			{
				error("[CAPTAINS SYSTEM] One player cannot be a leader in two teams at the same time!");
				return;
			}

			rules.set_string("team_0_leader", blue_leader.getUsername());
			rules.set_string("team_1_leader", red_leader.getUsername());

			printf("[CAPTAINS SYSTEM] Picked two captains, blue captain is " + rules.get_string("team_0_leader") + " red captain is " + rules.get_string("team_1_leader"));

			PutEveryoneInSpec();

			RulesCore@ core;
			rules.get("core", @core);

			if (core is null) return;

			core.ChangePlayerTeam(blue_leader, 0);
			core.ChangePlayerTeam(red_leader, 1);

			if (!isServer()) return;
			ApprovedTeams@ approved_teams;
			if (!rules.get("approved_teams", @approved_teams)) return;

			approved_teams.ClearLists();
			rules.set("approved_teams", @approved_teams);
		}
	}
}

class DemoteCommand : ChatCommand
{
	DemoteCommand()
	{
		super("demote", Descriptions::demotecomtext);
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		DemoteLeaders();

		if (isServer()) server_AddToChat("Teams unlocked and captains demoted!", SColor(0xff474ac6));
	}
}

class PickPlayerCommand : ChatCommand
{
	PickPlayerCommand()
	{
		super("pick", Descriptions::pickcomtext);
		SetUsage("<username>");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		CRules@ rules = getRules();

		RulesCore@ core;
		rules.get("core", @core);

		if (core is null) return false;

		u8 caller_team = player.getTeamNum();
		u8 first_team_picking = 0;

		return (
			rules.get_string("team_" + caller_team + "_leader") == player.getUsername()
			&& !isPickingEnded()
			//&& ((getSmallestTeam(core.teams)==caller_team || getTeamDifference(core.teams) == 0) && caller_team == first_team_picking)
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		CRules@ rules = getRules();

		if (args.size() < 1) return;

		const string PICKED_PLAYER_USERNAME = args[0];

		CPlayer@ picked_player = getPlayerByNamePart(PICKED_PLAYER_USERNAME);

		if (picked_player is null) return;
		if (picked_player.getTeamNum()!=rules.getSpectatorTeamNum()) return;

		RulesCore@ core;
		rules.get("core", @core);

		if (core is null) return;

		core.ChangePlayerTeam(picked_player, player.getTeamNum());

		printf("[CAPTAINS SYSTEM] Captain " + player.getUsername() + "is picked player " + picked_player.getUsername() + "to his team via /pick");
	}
}

class ApproveTeamsCommand : ChatCommand
{
	ApproveTeamsCommand()
	{
		super("lock", Descriptions::lockcomtext);
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		//if (!isServer()) return;
		CRules@ rules = getRules();
		ApprovedTeams@ approved_teams;
		if (!rules.get("approved_teams", @approved_teams)) return;

		bool was_locked = isPickingEnded();

		approved_teams.ClearLists();
		if (!was_locked) {
			approved_teams.FormLists();
			server_AddToChat(Descriptions::lockcomchatloc, SColor(0xff474ac6));
		}
		else
			server_AddToChat(Descriptions::lockcomchatunl, SColor(0xff474ac6));

		approved_teams.PrintMembers();
		rules.set("approved_teams", @approved_teams);
	}
}