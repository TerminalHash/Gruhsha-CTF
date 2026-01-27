// GruhshaCommands.as
#include "ChatCommand.as"

class SetInternalGamemode : ChatCommand
{
	SetInternalGamemode()
	{
		super("gm", "Change internal Gruhsha's gamemode");
		AddAlias("gamemode");
		SetUsage("<gm name> (CTF or TDM)");
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

		if (args.size() == 0) {
			server_AddToChat("Write gamemode name before changing!", ConsoleColour::ERROR, player);
			return;
		}

		string MODE_TO_SET = args[0];

		if (MODE_TO_SET.toUpper() == "CTF" || MODE_TO_SET.toUpper() == "GRUHSHA") {
			rules.set_string("internal_game_mode", "gruhsha");
			rules.Sync("internal_game_mode", true);

			LoadMapCycle("mapcycle.cfg");
			server_AddToChat("Changed gamemode to CTF!", SColor(0xff474ac6));
		} 

		if (MODE_TO_SET.toUpper() == "TDM" || MODE_TO_SET.toUpper() == "TAVERN" || MODE_TO_SET.toUpper() == "SLIVA") {
			rules.set_string("internal_game_mode", "tavern");
			rules.Sync("internal_game_mode", true);
			LoadMapCycle("mapcycle_tavern.cfg");

			server_AddToChat("Changed gamemode to TDM!", SColor(0xff474ac6));
		}

		if (MODE_TO_SET.toUpper() == "QUICKCTF" || MODE_TO_SET.toUpper() == "SMOLCTF") {
			rules.set_string("internal_game_mode", "smolctf");
			rules.Sync("internal_game_mode", true);

			LoadMapCycle("mapcycle.cfg");
			server_AddToChat("Changed gamemode to QuickCTF!", SColor(0xff474ac6));
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

class BrokeResupplies : ChatCommand
{
	BrokeResupplies()
	{
		super("fuckres", "Broke resupplies, allowing them to arrive after the death of each player on the team");
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

		if (!rules.hasTag("fucked resupplies")) {
			rules.Tag("fucked resupplies");
			server_AddToChat("Infinity resupplies is on!", SColor(0xff474ac6));
		} else {
			rules.Untag("fucked resupplies");
			server_AddToChat("Infinity resupplies is off!", SColor(0xff474ac6));
		}
	}
}