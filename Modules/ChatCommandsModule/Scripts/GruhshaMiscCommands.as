// GruhshaMiscCommands.as

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

class TeamRandomizer : ChatCommand
{
	TeamRandomizer()
	{
		super("teamrandom", "Make teams with random");
		AddAlias("random");
		AddAlias("rand");
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

		RulesCore@ core;
		rules.get("core", @core);

		for (int i = 0; i < getPlayerCount(); i++) 
		{
			CPlayer@ p = getPlayer(i);
			if (p is null) continue;

			u8 team = XORRandom(2);
			u8 playersinteam = getPlayerCount();
			if (CountPlayersInTeam(team) > playersinteam)
				if (team == 1) team = 0;
			else team = 1;

			core.ChangePlayerTeam(p, team);
		}

		server_AddToChat("Teams randomized, have fun!", SColor(0xff474ac6));
	}
}


class RememberTime : ChatCommand
{
	RememberTime()
	{
		super("reusetime", "Toggle for save day time of previous match for next matches");
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

		if (!rules.hasTag("reuse previous day time")) {
			rules.Tag("reuse previous day time");
			rules.set_f32("old day time", getMap().getDayTime());
			server_AddToChat("Reusing previous day time", SColor(0xff474ac6));
		} else {
			rules.Untag("reuse previous day time");
			server_AddToChat("Using default day time", SColor(0xff474ac6));
		}
	}
}

class ToggleTimeCycle : ChatCommand
{
	ToggleTimeCycle()
	{
		super("timespeed", "Set timecycle speed");
		SetUsage("<time in mimutes>");
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

		if (isServer()) {
			int time = parseInt(args[0]);
			rules.daycycle_speed = time;
		}
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