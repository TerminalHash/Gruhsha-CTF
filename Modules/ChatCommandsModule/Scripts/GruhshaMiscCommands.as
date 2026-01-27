// GruhshaMiscCommands.as
#include "ChatCommand.as"

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


class GiveCirnu : BlobCommand
{
	GiveCirnu()
	{
		super("cirnu", "Spawn Cirnu Fumo");
		AddAlias("funky");
		AddAlias("fumo");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		if (player.getUsername() == "TerminalHash") {
			return true;
		}
		/*return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);*/
		return false;
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		u8 team = player.getBlob().getTeamNum();
		CBlob@ newBlob = server_CreateBlob("cirnu", team, pos + Vec2f(0, -5));
	}
}

class GiveNoko : BlobCommand
{
	GiveNoko()
	{
		super("noko", "Spawn Noko Fumo");
		AddAlias("shikanoko");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		if (player.getUsername() == "TerminalHash") {
			return true;
		}
		/*return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);*/
		return false;
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		u8 team = player.getBlob().getTeamNum();
		CBlob@ newBlob = server_CreateBlob("noko", team, pos + Vec2f(0, -5));
	}
}

class SpawnLootChest : BlobCommand
{
	SpawnLootChest()
	{
		super("lootchest", "Spawn loot chest");
		AddAlias("lc");
		SetUsage("<chest type>");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		if (args.size() == 0) {
			server_AddToChat("Write loot chest type before spawn", ConsoleColour::ERROR, player);
			return;
		}

		u8 team = player.getBlob().getTeamNum();

		string MODE_TO_SET = args[0];

		if (MODE_TO_SET.toUpper() == "BRONZE") {
			CBlob@ newBlob = server_CreateBlob("lootchest", team, pos + Vec2f(0, -5));
			if (newBlob !is null) {
				newBlob.set_u8("chest_type", 1);
				newBlob.set_string("lootchest owner", player.getUsername());
			}
		} 

		if (MODE_TO_SET.toUpper() == "SILVER") {
			CBlob@ newBlob = server_CreateBlob("lootchest", team, pos + Vec2f(0, -5));
			if (newBlob !is null) {
				newBlob.set_u8("chest_type", 2);
				newBlob.set_string("lootchest owner", player.getUsername());
			}
		}

		if (MODE_TO_SET.toUpper() == "GOLDEN") {
			CBlob@ newBlob = server_CreateBlob("lootchest", team, pos + Vec2f(0, -5));
			if (newBlob !is null) {
				newBlob.set_u8("chest_type", 3);
				newBlob.set_string("lootchest owner", player.getUsername());
			}
		}
	}
}
