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

		// Client chat
		if (isClient())
		{
			if (rules.get_bool(player.getUsername() + "is_deaf") == true)
			{
				client_AddToChat(Descriptions::togglesoundschattexton + player.getUsername(), SColor(0xff474ac6));
			}
			else
			{
				client_AddToChat(Descriptions::togglesoundschattextoff + player.getUsername(), SColor(0xff474ac6));
			}
		}

		// Server log
		/*if (rules.get_bool(player.getUsername() + "is_deaf") == false)
		{
			printf("Player " + player.getUsername() + " is muted sound commands");
		}
		else
		{
			printf("Player " + player.getUsername() + " is unmuted sound commands");
		}*/
	}
}
