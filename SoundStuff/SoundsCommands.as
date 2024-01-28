#include "ChatCommand.as"
#include "RulesCore.as"

class MuteSounds : ChatCommand
{
	MuteSounds()
	{
		super("mutesounds", "Mute tags from players to you");
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
		rules.set_bool(player.getUsername() + "is_sounds_muted", true);

		if (isServer()) client_AddToChat("Звуки вокалайзов выключены", SColor(0xff474ac6));
	}
}

class UnmuteSounds : ChatCommand
{
	UnmuteSounds()
	{
		super("unmutesounds", "Unmute tags from players to you");
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
		rules.set_bool(player.getUsername() + "is_sounds_muted", false);

		if (isServer()) client_AddToChat("Звуки вокалайзов включены", SColor(0xff474ac6));
	}
}
