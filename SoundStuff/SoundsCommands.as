#include "ChatCommand.as"
#include "RulesCore.as"
#include "TranslationsSystem.as"

class ToggleSounds : ChatCommand
{
	ToggleSounds()
	{
		super("togglesounds", Descriptions::togglesoundscomtext);
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
		rules.set_bool(player.getUsername() + "is_deaf", !rules.get_bool(player.getUsername() + "is_deaf"));

		printf("Player " + player.getUsername() + " is muted sound commands");
	}
}
