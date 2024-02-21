#include "ChatCommand.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"
#include "BindingsCommon.as"

class SpecAllCommand : ChatCommand
{
	SpecAllCommand()
	{
		super("specall", "Puts everyone in Spectators");
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
		super("appoint", "Appoints two Team Leaders (they pick players in their teams)");
		AddAlias("caps");
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
				error("blue leader doesn't not exists! try again");
				return;
			}
			if (red_leader is null) {
				error("red leader doesn't not exists! try again");
				return;
			}

			rules.set_string("team_0_leader", blue_leader.getUsername());
			rules.set_string("team_1_leader", red_leader.getUsername());

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
		super("demote", "Demotes the Team Leaders");
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
	}
}

class PickPlayerCommand : ChatCommand
{
	PickPlayerCommand()
	{
		super("pick", "Picks one player FROM SPECTATORS to your team and passes an opportunity to pick to next Team Leader");
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
			rules.get_string("team_"+caller_team+"_leader")==player.getUsername()
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
	}
}

class ApproveTeamsCommand : ChatCommand
{
	ApproveTeamsCommand()
	{
		super("lock", "Ends picking process by approving team personnel");
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
			if (g_locale == "ru")
			{
				server_AddToChat("Команды сформированы", SColor(0xff474ac6));
			}
			else
			{
				server_AddToChat("Teams locked", SColor(0xff474ac6));
			}
		}
		else
			if (g_locale == "ru")
			{
				server_AddToChat("Команды расформированы", SColor(0xff474ac6));
			}
			else
			{
				server_AddToChat("Teams unlocked", SColor(0xff474ac6));
			}

		approved_teams.PrintMembers();
		rules.set("approved_teams", @approved_teams);
	}
}

class SetBuilderLimitCommand : ChatCommand
{
	SetBuilderLimitCommand()
	{
		super("blim", "Limits count of builders for every team");
		SetUsage("<builder limit>");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		/*
		CRules@ rules = getRules();
		u8 caller_team = player.getTeamNum();
		return (rules.get_string("team_"+caller_team+"_leader") == player.getUsername() && !isPickingEnded()); // if he is captain and picking is still going
		*/
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		CRules@ rules = getRules();

		if (args.size() < 1) return;

		rules.set_u8("builders_limit", parseInt(args[0]));

		if (isServer()) server_AddToChat("Максимум строителей теперь "+args[0], SColor(0xff474ac6));
	}
}

class SetArcherLimitCommand : ChatCommand
{
	SetArcherLimitCommand()
	{
		super("alim", "Limits count of archers for every team");
		SetUsage("<archer limit>");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		/*
		CRules@ rules = getRules();
		u8 caller_team = player.getTeamNum();
		return (rules.get_string("team_"+caller_team+"_leader") == player.getUsername() && !isPickingEnded()); // if he is captain and picking is still going
		*/
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		CRules@ rules = getRules();

		if (args.size() < 1) return;

		rules.set_u8("archers_limit", parseInt(args[0]));

		if (isServer()) server_AddToChat("Максимум лучников теперь "+args[0], SColor(0xff474ac6));
	}
}

class ToggleClassChangingOnShops : ChatCommand
{
	ToggleClassChangingOnShops()
	{
		super("togglechclass", "Disallowing class changing on shops");
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
		CRules@ rules = getRules();
		bool isEnable = rules.get_bool("no_class_change_on_shop");
		rules.set_bool("no_class_change_on_shop", !isEnable);
		//printf("Boolean no_class_change_on_shop is " + rules.get_bool("no_class_change_on_shop"));
		string isEnableStr = "включена";
		if(!isEnable) {
			isEnableStr = "выключена";
		}
		if (isServer()) server_AddToChat("Смена классов теперь "+isEnableStr, SColor(0xff474ac6));
	}
}

class BindingsMenu : ChatCommand
{
	BindingsMenu()
	{
		super("bindings", "Show mod bindings menu");
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
		CRules@ rules = getRules();

		if (player.isMyPlayer())
		{
			rules.set_bool("bindings_open", !rules.get_bool("bindings_open"));

			ResetRuleBindings();
			LoadFileBindings();

			ResetRuleSettings();
			LoadFileSettings();
		}

		//printf("Boolean no_class_change_on_shop is " + rules.get_bool("no_class_change_on_shop"));
	}
}
