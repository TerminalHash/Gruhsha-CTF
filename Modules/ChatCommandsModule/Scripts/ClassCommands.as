// ClassCommands.as
#include "ChatCommand.as"

class SetBuilderLimitCommand : ChatCommand
{
	SetBuilderLimitCommand()
	{
		super("blim", Descriptions::builderlimtext);
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

		if (isServer()) server_AddToChat(Descriptions::builderlimchat +args[0], SColor(0xff474ac6));
	}
}

class SetArcherLimitCommand : ChatCommand
{
	SetArcherLimitCommand()
	{
		super("alim", Descriptions::archerlimtext);
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

		if (isServer()) server_AddToChat(Descriptions::archerlimchat +args[0], SColor(0xff474ac6));
	}
}

class ToggleClassChangingOnShops : ChatCommand
{
	ToggleClassChangingOnShops()
	{
		super("togglechclass", Descriptions::togglechcomtext);
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

		string isEnableStr = Descriptions::togglechcom2;

		if(!isEnable) {
			isEnableStr = Descriptions::togglechcom3;
		}

		if (isServer()) server_AddToChat(Descriptions::togglechcomchat +isEnableStr, SColor(0xff474ac6));

		printf("[ADMIN COMMAND] Class changing in shops is " + rules.get_bool("no_class_change_on_shop"));
	}
}

class TagBuilder : ChatCommand
{
	TagBuilder()
	{
		super("tagbuilder", "Choose player, what will be builder in match");
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
			rules.get_string("team_" + caller_team + "_leader") == player.getUsername() || player.isMod()
		);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		CRules@ rules = getRules();

		if (args.size() < 1) return;

		const string PLAYER_USERNAME = args[0];

		CPlayer@ tagged_player = getPlayerByNamePart(PLAYER_USERNAME);

		if (tagged_player is null) return;
		if (tagged_player.getTeamNum() != player.getTeamNum()) return;

		RulesCore@ core;
		rules.get("core", @core);

		if (core is null) return;

		rules.set_string("team_" + player.getTeamNum() + "_builder", tagged_player.getUsername());
		rules.Sync("team_" + player.getTeamNum() + "_builder", true);

		printf("[CAPTAINS SYSTEM] " + player.getUsername() + " was tagged " + tagged_player.getUsername() + " as builder in team " + player.getTeamNum());
	}
}

class AppointBuilders : ChatCommand
{
	AppointBuilders()
	{
		super("setbuilders", "Choose players, what will be builder in match");
		SetUsage("<blue builder> <red builder>");
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

		if (args.size() < 1) return;

		const string BLUE_BUILDER_NAME = args[0];
		const string RED_BUILDER_NAME = args[1];

		CPlayer@ blue_builder = getPlayerByNamePart(BLUE_BUILDER_NAME);
		CPlayer@ red_builder = getPlayerByNamePart(RED_BUILDER_NAME);

		if (blue_builder is null) {
			error("[CAPTAINS SYSTEM] blue builder doesn't exists! try again");
			return;
		}
		if (red_builder is null) {
			error("[CAPTAINS SYSTEM] red builder doesn't exists! try again");
			return;
		}

		// if admin accidentally wrote the same player's name twice
		if (blue_builder.getUsername() == red_builder.getUsername() || red_builder.getUsername() == blue_builder.getUsername())
		{
			error("[CAPTAINS SYSTEM] One player cannot be a builder in two teams at the same time!");
			return;
		}

		if (blue_builder !is null && red_builder !is null) {
			rules.set_string("team_" + 0 + "_builder", blue_builder.getUsername());
			rules.set_string("team_" + 1 + "_builder", red_builder.getUsername());
			rules.Sync("team_" + 0 + "_builder", true);
			rules.Sync("team_" + 1 + "_builder", true);
		}

		if (isServer()) server_AddToChat("Builders in that match: " + blue_builder.getUsername() + " for BLUE and " + red_builder.getUsername() + " for RED!", SColor(0xff474ac6));

		printf("[CAPTAINS SYSTEM] Builders is set! Blue builder is " + rules.get_string("team_0_builder") + " red builder is " + rules.get_string("team_1_builder"));
	}
}