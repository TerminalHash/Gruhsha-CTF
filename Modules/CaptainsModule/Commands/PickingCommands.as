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
				error("[CAPTAINS SYSTEM] blue leader doesn't not exists! try again");
				return;
			}
			if (red_leader is null) {
				error("[CAPTAINS SYSTEM] red leader doesn't not exists! try again");
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

class PreventVoicelineSpamming : ChatCommand
{
	PreventVoicelineSpamming()
	{
		super("mutevoice", Descriptions::preventvoicelinespamtext);
		AddAlias("mutevc");
		AddAlias("mvc");
		SetUsage("<username>");
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

		const string MUTED_PLAYER_USERNAME = args[0];

		CPlayer@ muted_player = getPlayerByNamePart(MUTED_PLAYER_USERNAME);

		if (muted_player is null) return;

		rules.set_bool(muted_player.getUsername() + "is_sounds_muted", !rules.get_bool(muted_player.getUsername() + "is_sounds_muted"));
		if (rules.get_bool(muted_player.getUsername() + "is_sounds_muted") == true)
		{
			printf("[ADMIN COMMAND] Player " + muted_player.getUsername() + " was forbidden using voiceline for spamming");
		}
		else
		{
			printf("[ADMIN COMMAND] Player " + muted_player.getUsername() + " was allowed using voicelines");
		}
	}
}

class ToggleOffi : ChatCommand
{
	ToggleOffi()
	{
		super("offi", "Toggle offi match tag");
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

		if (!rules.hasTag("offi match")) {
			rules.Tag("offi match");
			rules.Sync("offi match", true);
		} else {
			rules.Untag("offi match");
			rules.Sync("offi match", true);
		}

		if (isServer()) {
			if (!rules.hasTag("offi match")) {
				server_AddToChat("This match is not offi!", SColor(0xff474ac6));
			} else {
				server_AddToChat("This match is offi!", SColor(0xff474ac6));
			}
		}
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
	}
}

class ToggleEditor : ChatCommand
{
	ToggleEditor()
	{
		super("editor", "Toggle map editor");
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

		if (!rules.hasTag("editor is active")) {
			rules.Tag("editor is active");
			rules.Sync("editor is active", true);
		} else {
			rules.Untag("editor is active");
			rules.Sync("editor is active", true);
		}

		if (isServer()) {
			if (!rules.hasTag("editor is active")) {
				server_AddToChat("Map editor is disabled", SColor(0xff474ac6));
			} else {
				server_AddToChat("Map editor is enabled", SColor(0xff474ac6));
			}
		}
	}
}

class UpdateMats : ChatCommand
{
	UpdateMats()
	{
		super("updmats", "Update material pool for someone team");
		SetUsage("<team> <wood> <stone>");
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

		const string TEAM = args[0];
		const s32 WOOD = args.size() > 0 ? parseInt(args[1]) : rules.get_s32("teamwood" + TEAM);
		const s32 STONE = args.size() > 0 ? parseInt(args[2]) : rules.get_s32("teamstone" + TEAM);

		if (args[1].size() > 1) {
			rules.set_s32("teamwood" + TEAM, WOOD);
			rules.Sync("teamwood" + TEAM, true);
		}

		if (args[2].size() > 1) {
			rules.set_s32("teamstone" + TEAM, STONE);
			rules.Sync("teamstone" + TEAM, true);
		}
	}
}