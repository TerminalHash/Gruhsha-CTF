#include "ChatCommand.as"

class AddMatchTime : ChatCommand
{
	AddMatchTime()
	{
		super("addsec", "Add additional seconds for match timer");
		SetUsage("<seconds>");
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

		rules.add_u32("game_end_time", parseInt(args[0]) * 30);

		if (isServer()) server_AddToChat("Added " + args[0] + " seconds to match time", SColor(0xff474ac6));
	}
}

class AddMatchTimeMinutes : ChatCommand
{
	AddMatchTimeMinutes()
	{
		super("addmin", "Add additional minutes for match timer");
		SetUsage("<minutes>");
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

		rules.add_u32("game_end_time", (parseInt(args[0]) * 30) * 60);

		if (isServer()) server_AddToChat("Added " + args[0] + " minutes to match time", SColor(0xff474ac6));
	}
}

class ToggleSuddenDeath : ChatCommand
{
	ToggleSuddenDeath()
	{
		super("togglesud", "Toggle sudden death mode");
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

		if (!rules.hasTag("sudden death")) {
			rules.Tag("sudden death");
			rules.Sync("sudden death", true);
		} else {
			rules.Untag("sudden death");
			rules.Sync("sudden death", true);
		}

		CBlob@[] knightshoplist;
		if(getBlobsByName("knightshop", knightshoplist)) {
			for (int i = 0; i < knightshoplist.size(); ++i) {
				CBlob@ currentshop = knightshoplist[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		CBlob@[] archershoplist;
		if(getBlobsByName("archershop", archershoplist)) {
			for (int i = 0; i < archershoplist.size(); ++i) {
				CBlob@ currentshop = archershoplist[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		if (isServer()) {
			if (!rules.hasTag("sudden death")) {
				server_AddToChat("Sudden Death mode is disabled!", SColor(0xff474ac6));
			} else {
				server_AddToChat("Sudden Death mode is enabled!", SColor(0xff474ac6));
			}
		}
	}
}
