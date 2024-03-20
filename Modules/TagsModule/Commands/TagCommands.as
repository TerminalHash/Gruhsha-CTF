#include "ChatCommand.as"
#include "RulesCore.as"

class MuteTags : ChatCommand
{
	MuteTags()
	{
		super("mutetags", "Mute tags from players to you");
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
		rules.set_bool(player.getUsername() + "is_tag_muted", true);

		if (isServer()) client_AddToChat("Звуки меток выключены", SColor(0xff474ac6));
	}
}

class UnmuteTags : ChatCommand
{
	UnmuteTags()
	{
		super("unmutetags", "Unmute tags from players to you");
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
		rules.set_bool(player.getUsername() + "is_tag_muted", false);

		if (isServer()) client_AddToChat("Звуки меток включены", SColor(0xff474ac6));
	}
}
