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