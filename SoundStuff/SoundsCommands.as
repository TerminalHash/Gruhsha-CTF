#include "ChatCommand.as"
#include "RulesCore.as"

class ToggleSounds : ChatCommand
{
	ToggleSounds()
	{
		super("togglesounds", "Mute/unmute sound commangs");
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
			if (rules.get_bool(player.getUsername() + "is_deaf") == false)
			{
				client_AddToChat("Annoying sounds is muted for you, " + player.getUsername(), SColor(0xff474ac6));
			}
			else
			{
				client_AddToChat("Annoying sounds is unmuted for you, " + player.getUsername(), SColor(0xff474ac6));
			}
		}

		// Server log
		if (rules.get_bool(player.getUsername() + "is_deaf") == false)
		{
			printf("Player " + player.getUsername() + " is muted sound commands");
		}
		else
		{
			printf("Player " + player.getUsername() + " is unmuted sound commands");
		}
	}
}
