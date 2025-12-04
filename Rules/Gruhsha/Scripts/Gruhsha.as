
//CTF gamemode logic script

#define SERVER_ONLY

#include "Gruhsha_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "Gruhsha_Gamemodes.as";

#include "CTF_PopulateSpawnList.as"

//edit the variables in the config file below to change the basics
// no scripting required!
void Config(CTFCore@ this)
{
	CRules@ rules = getRules();

	string configstr = "gruhsha_vars.cfg";
	string gamemode = InternalGamemode(rules);

	ConfigFile cfg = ConfigFile(configstr);
	cfg.loadFile(configstr);

	s32 warmUpTimeSeconds = cfg.read_s32("warmup_time", 30);
	//how long to wait for everyone to spawn in?
	if (getRules().get_string("internal_game_mode") == "tavern") {
		warmUpTimeSeconds = 3;
	}

	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

	s32 stalemateTimeSeconds = cfg.read_s32("stalemate_time", 30);
	this.stalemateTime = (getTicksASecond() * stalemateTimeSeconds);

	//how long for the game to play out?
	//s32 gameDurationMinutes = 60; // 1 hour
	s32 gameDurationMinutes = 38; // 35 minutes + 3 minutes of warmup
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	//how many players have to be in for the game to start
	this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team", 2);
	//whether to scramble each game or not
	this.scramble_teams = cfg.read_bool("scramble_teams", true);

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

	// TDM stuff
	//how many kills needed to win the match, per player on the smallest team
	this.kills_to_win_per_player = cfg.read_s32("killsPerPlayer", 2);

	// modifies if the fall damage velocity is higher or lower - TDM has lower velocity
	s32 FallDMGModifier = cfg.read_f32("fall_dmg_nerf", 1.3f);
	if (gamemode == "tavern" || gamemode == "vinograd") {
		rules.set_f32("fall vel modifier", FallDMGModifier);
	} else {
		rules.set_f32("fall vel modifier", 1.0f);
	}
}

shared string base_name() { return "tent"; }
shared string base_name_tavern() { return "tdm_spawn"; }
shared string flag_name() { return "ctf_flag"; }
shared string flag_spawn_name() { return "flag_base"; }

//CTF spawn system

const s32 spawnspam_limit_time = 10;

shared class CTFSpawns : RespawnSystem
{
	CTFCore@ CTF_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@CTF_core = cast < CTFCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < CTF_core.teams.length; ++team_num)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (CTF_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				// Round time up (except for final few ticks)
				spawn_property = u8(Maths::Min(250, ((info.can_spawn_time + getTicksASecond() - 5) / getTicksASecond())));
			}

			string propname = "ctf spawn time " + info.username;

			CTF_core.rules.set_u8(propname, spawn_property);
			CTF_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}

	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (canSpawnPlayer(p_info))
		{
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			// tutorials hack
			if (getRules().hasTag("singleplayer"))
			{
				p_info.team = 0;
			}

			// spawn as builder in warmup
			if (getRules().isWarmup())
			{
				p_info.blob_name = "builder";
			}

			CBlob@ spawnBlob = getSpawnBlob(p_info);

			if (spawnBlob !is null)
			{
				if (spawnBlob.exists("custom respawn immunity"))
				{
					p_info.customImmunityTime = spawnBlob.get_u8("custom respawn immunity");
				}
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}

			CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);

			if (playerBlob !is null)
			{
				// spawn resources
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("CTF LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		if (force) { return true; }

		return info.can_spawn_time <= 0;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ c_info = cast < CTFPlayerInfo@ > (p_info);
		if (getRules().get_string("internal_game_mode") != "tavern") {
			return SpawnLocationGeneric(p_info);
		} else {
			return SpawnLocationTDM(p_info);
		}

		return Vec2f(0, 0);
	}

	//////////////////////////////////////////////////////////
	//	Get spawn locations for specific gamemodes
	//	SpawnLocationGeneric should be used for all
	//	gamemodes, where we dont overriding spawn locations!!!
	//////////////////////////////////////////////////////////
	Vec2f SpawnLocationGeneric(PlayerInfo@ p_info) {
		CTFPlayerInfo@ c_info = cast < CTFPlayerInfo@ > (p_info);
		if (c_info !is null)
		{
			CBlob@ pickSpawn = getBlobByNetworkID(c_info.spawn_point);
			if (pickSpawn !is null &&
					pickSpawn.hasTag("respawn") &&
					!pickSpawn.hasTag("under raid") &&
					pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn.getPosition();
			}
			else
			{
				CBlob@[] spawns;
				PopulateSpawnList(spawns, p_info.team);

				for (uint step = 0; step < spawns.length; ++step)
				{
					if (spawns[step].getTeamNum() == s32(p_info.team))
					{
						return spawns[step].getPosition();
					}
				}
			}
		}

		// because we using Vec2f, it's just for prevent yapping about
		// returning values
		return Vec2f(0, 0);
	}

	Vec2f SpawnLocationTDM(PlayerInfo@ p_info) {
		CBlob@[] spawns;
		CBlob@[] teamspawns;

		if (getBlobsByName("tdm_spawn", @spawns)) {
			for (uint step = 0; step < spawns.length; ++step) {
				if (spawns[step].getTeamNum() == s32(p_info.team)) {
					teamspawns.push_back(spawns[step]);
				}
			}
		}

		if (teamspawns.length > 0) {
			int spawnindex = XORRandom(997) % teamspawns.length;
			return teamspawns[spawnindex].getPosition();
		}

		// because we using Vec2f, it's just for prevent yapping about
		// returning values
		return Vec2f(0, 0);
	}

	//////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////

	CBlob@ getSpawnBlob(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ c_info = cast < CTFPlayerInfo@ > (p_info);
		if (c_info !is null) {
			CBlob@ pickSpawn = getBlobByNetworkID(c_info.spawn_point);
			if (pickSpawn !is null &&
			        pickSpawn.hasTag("respawn") && 
			        !pickSpawn.hasTag("under raid") &&
			        pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn;
			} else {
				CBlob@[] spawns;
				PopulateSpawnList(spawns, p_info.team);

				for (uint step = 0; step < spawns.length; ++step) {
					if (spawns[step].getTeamNum() == s32(p_info.team)) {
						return spawns[step];
					}
				}
			}
		}

		return null;
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("CTF LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "ctf spawn time " + info.username;

		for (uint i = 0; i < CTF_core.teams.length; i++) {
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (CTF_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}

		CTF_core.rules.set_u8(propname, 255);   //not respawning
		CTF_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		//DONT set this zero - we can re-use it if we didn't actually spawn
		//info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(getTicksASecond() * 5);

		// Sudden Death Mode: increase respawn time, if we have stalemate
		// formula - 60 * n + 180
		if (getRules().hasTag("offi match")) {
			if (getGameTime() >= 780 * getTicksASecond() && getGameTime() <= 1380 * getTicksASecond()) {			// 10 min
				tickspawndelay = s32(getTicksASecond() * 7);
			} else if (getGameTime() >= 1380 * getTicksASecond() && getGameTime() <= 1680 * getTicksASecond()) {	// 20 min
				tickspawndelay = s32(getTicksASecond() * 10);
			} else if (getGameTime() >= 1680 * getTicksASecond() && getGameTime() <= 1980 * getTicksASecond()) {	// 25 min
				tickspawndelay = s32(getTicksASecond() * 15);
			} else if (getGameTime() >= 1980 * getTicksASecond()) {													// 30 min
				tickspawndelay = s32(getTicksASecond() * 20);
			}
		}

		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("CTF LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		//clamp it so old bad values don't get propagated
		s32 old_spawn_time = Maths::Max(0, Maths::Min(info.can_spawn_time, tickspawndelay));

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		if (info.team < CTF_core.teams.length) {
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (CTF_core.teams[info.team]);

			info.can_spawn_time = ((old_spawn_time > 30) ? old_spawn_time : tickspawndelay);

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		} else {
			error("PLAYER TEAM NOT SET CORRECTLY! " + info.team + " / " + CTF_core.teams.length + " for player " + player.getUsername());
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < CTF_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (CTF_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

shared class CTFCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;
	s32 stalemateTime;
	s32 stalemateOutcomeTime;

	s32 minimum_players_in_team;

	// TDM stuff
	s32 kills_to_win;
	s32 kills_to_win_per_player;

	s32 players_in_small_team;
	bool scramble_teams;

	CTFSpawns@ ctf_spawns;

	CTFCore() {}

	CTFCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		spawnTime = 0;
		stalemateOutcomeTime = 6; //seconds
		super(_rules, _respawns);
	}


	int gamestart;
	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		gamestart = getGameTime();
		@ctf_spawns = cast < CTFSpawns@ > (_respawns);
		_rules.set_string("music - base name", base_name());
		server_CreateBlob("ctf_music");
		// HACK: spawn special blob for sudden death sound
		server_CreateBlob("sudden_death_sound_blob");
		players_in_small_team = -1;
	}

	void Update()
	{
		//HUD
		// lets save the CPU and do this only once in a while
		if (InternalGamemode(rules) == "tavern") {
			if (getGameTime() % 16 == 0)
			{
				updateHUD();
			}
		}

		if (rules.isGameOver()) { return; }

		s32 ticksToStart = gamestart + warmUpTime - getGameTime();
		ctf_spawns.force = false;

		// Change player classes to knight explicity
		if (ticksToStart <= 5 * 30 && rules.getCurrentState() != GAME)
		{
			if (InternalGamemode(rules) != "tavern") {
				for (int l = 0; l < getPlayersCount(); ++l) {
					CPlayer @p = getPlayer(l);
					if (p !is null) {
						CBlob @b = p.getBlob();

						if (b !is null) {
							string role;
							int teamNum = p.getTeamNum();

							if (b.getName() == "builder" &&
							!(
								getRules().get_string("team_" + teamNum + "_leader") == p.getUsername() ||
								getRules().get_string("team_" + teamNum + "_builder") == p.getUsername())
							) {
								role = "knight";
								CBlob@ test = server_CreateBlobNoInit(role);

								if (test !is null) {
									test.setPosition(b.getPosition());
									b.server_Die();
									test.Init();
									test.server_SetPlayer(p);
									test.server_setTeamNum(p.getTeamNum());
								}
							}
						}
					}
				}
			}
		}

		if (ticksToStart <= 0 && (rules.isWarmup()))
		{
			rules.SetCurrentState(GAME);
		}
		else if (ticksToStart > 0 && rules.isWarmup()) //is the start of the game, spawn everyone + give mats
		{
			rules.SetGlobalMessage("Match starts in {SEC}");
			rules.AddGlobalMessageReplacement("SEC", "" + ((ticksToStart / 30) + 1));
			ctf_spawns.force = true;

			//set kills and cache #players in smaller team
			if (InternalGamemode(rules) == "tavern") {
				if (players_in_small_team == -1 || (getGameTime() % 30) == 4) {
					players_in_small_team = 100;

					for (uint team_num = 0; team_num < teams.length; ++team_num) {
						CTFTeamInfo@ team = cast < CTFTeamInfo@ > (teams[team_num]);

						if (team.players_count < players_in_small_team) {
							players_in_small_team = team.players_count;
						}
					}

					kills_to_win = Maths::Max(players_in_small_team, 1) * kills_to_win_per_player;
				}
			}
		}

		if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers()))  //CHECK IF TEAMS HAVE ENOUGH PLAYERS
		{
			gamestart = getGameTime();
			rules.set_u32("game_end_time", gamestart + gameDuration);
			rules.SetGlobalMessage("Not enough players in each team for the game to start.\nPlease wait for someone to join...");
			ctf_spawns.force = true;
		}
		else if (rules.isMatchRunning())
		{
			rules.SetGlobalMessage("");
		}

		/*
		 * If you want to do something tricky with respawning flags and stuff here, go for it
		 */

		RulesCore::Update(); //update respawns
		// move all gamemode checks here, we want a more universal solution
		// for adding more gamemodes in future into Gruhsha's default base
		// TODO: check how it works on server
		if (InternalGamemode(rules) != "tavern") {
			CheckStalemate();
			CheckTeamWon();
		} else {
			CheckTeamWonTDM();
		}
	}

	// TDM hud
	void updateHUD()
	{
		bool hidekills = (rules.isIntermission() || rules.isWarmup());
		CBitStream serialised_tavern_hud;
		serialised_tavern_hud.write_u16(0x5afe); //check bits

		for (uint team_num = 0; team_num < teams.length; ++team_num)
		{
			TAVERN_HUD hud;
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (teams[team_num]);
			hud.team_num = team_num;
			hud.kills = team.kills;
			hud.kills_limit = -1;
			if (!hidekills)
			{
				if (kills_to_win <= 0)
					hud.kills_limit = -2;
				else
					hud.kills_limit = kills_to_win;
			}

			string temp = "";

			for (uint player_num = 0; player_num < players.length; ++player_num)
			{
				CTFPlayerInfo@ player = cast < CTFPlayerInfo@ > (players[player_num]);

				if (player.team == team_num)
				{
					CPlayer@ e_player = getPlayerByUsername(player.username);

					if (e_player !is null)
					{
						CBlob@ player_blob = e_player.getBlob();
						bool blob_alive = player_blob !is null && player_blob.getHealth() > 0.0f;

						if (blob_alive)
						{
							string player_char = "k"; //default to sword

							if (player_blob.getName() == "archer")
							{
								player_char = "a";
							}

							temp += player_char;
						}
						else
						{
							temp += "s";
						}
					}
				}
			}

			hud.unit_pattern = temp;

			bool set_spawn_time = false;
			if (team.spawns.length > 0 && !rules.isIntermission())
			{
				u32 st = cast < CTFPlayerInfo@ > (team.spawns[0]).can_spawn_time;
				if (st < 200)
				{
					hud.spawn_time = (st / 30);
					set_spawn_time = true;
				}
			}
			if (!set_spawn_time)
			{
				hud.spawn_time = 255;
			}

			hud.Serialise(serialised_tavern_hud);
		}

		rules.set_CBitStream("tavern_serialised_team_hud", serialised_tavern_hud);
		rules.Sync("tavern_serialised_team_hud", true);
	}

	//HELPERS
	bool allTeamsHavePlayers()
	{
		for (uint i = 0; i < teams.length; i++)
		{
			if (teams[i].players_count < minimum_players_in_team)
			{
				return false;
			}
		}

		return true;
	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		CTFTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		if (getRules().hasTag("singleplayer"))
		{
			team = 0;
		}
		else
		{
			team = player.getTeamNum();
		}
		CTFPlayerInfo p(player.getUsername(), team, "knight");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

	void onSetPlayer(CBlob@ blob, CPlayer@ player)
	{
		if (blob !is null && player !is null) {
			if (InternalGamemode(rules) == "tavern") {
				GiveSpawnResources(blob, player);
			}
		}
	}

	//setup the CTF bases

	void SetupBase(CBlob@ base)
	{
		if (base is null)
		{
			return;
		}

		//nothing to do
	}

	void SetupBases()
	{
		// destroy all previous spawns if present
		CBlob@[] oldBases;

		if (InternalGamemode(rules) != "tavern") {
			getBlobsByName(base_name(), @oldBases);
		} else {
			getBlobsByName(base_name_tavern(), @oldBases);
		}

		for (uint i = 0; i < oldBases.length; i++)
		{
			oldBases[i].server_Die();
		}

		CMap@ map = getMap();

		if (map !is null && map.tilemapwidth != 0)
		{
			//spawn the spawns :D
			Vec2f respawnPos;

			f32 auto_distance_from_edge_tents = Maths::Min(map.tilemapwidth * 0.15f * 8.0f, 100.0f);

			if (!getMap().getMarker("blue main spawn", respawnPos))
			{
				warn("CTF: Blue spawn added");
				respawnPos = Vec2f(auto_distance_from_edge_tents, map.getLandYAtX(auto_distance_from_edge_tents / map.tilesize) * map.tilesize - 16.0f);
			}

			if (InternalGamemode(rules) != "tavern") {
				respawnPos.y -= 8.0f;
				SetupBase(server_CreateBlob(base_name(), 0, respawnPos));
			} else {
				respawnPos.y -= 15.0f;
				SetupBase(server_CreateBlob(base_name_tavern(), 0, respawnPos));
			}

			if (!getMap().getMarker("red main spawn", respawnPos))
			{
				warn("CTF: Red spawn added");
				respawnPos = Vec2f(map.tilemapwidth * map.tilesize - auto_distance_from_edge_tents, map.getLandYAtX(map.tilemapwidth - (auto_distance_from_edge_tents / map.tilesize)) * map.tilesize - 16.0f);
			}

			if (InternalGamemode(rules) != "tavern") {
				respawnPos.y -= 8.0f;
				SetupBase(server_CreateBlob(base_name(), 1, respawnPos));
			} else {
				respawnPos.y -= 15.0f;
				SetupBase(server_CreateBlob(base_name_tavern(), 1, respawnPos));
			}

			//setup the flags

			//temp to hold them all
			Vec2f[] flagPlaces;

			f32 auto_distance_from_edge = Maths::Min(map.tilemapwidth * 0.25f * 8.0f, 400.0f);

			// set flags for CTF gamemode, but disable them, if we playing in TDM
			if (InternalGamemode(rules) != "tavern") {
				//blue flags
				if (getMap().getMarkers("blue spawn", flagPlaces))
				{
					for (uint i = 0; i < flagPlaces.length; i++)
					{
						server_CreateBlob(flag_spawn_name(), 0, flagPlaces[i] + Vec2f(0, map.tilesize));
					}

					flagPlaces.clear();
				}
				else
				{
					warn("CTF: Blue flag added");
					f32 x = auto_distance_from_edge;
					respawnPos = Vec2f(x, (map.getLandYAtX(x / map.tilesize) - 2) * map.tilesize);
					server_CreateBlob(flag_spawn_name(), 0, respawnPos);
				}

				//red flags
				if (getMap().getMarkers("red spawn", flagPlaces))
				{
					for (uint i = 0; i < flagPlaces.length; i++)
					{
						server_CreateBlob(flag_spawn_name(), 1, flagPlaces[i] + Vec2f(0, map.tilesize));
					}

					flagPlaces.clear();
				}
				else
				{
					warn("CTF: Red flag added");
					f32 x = (map.tilemapwidth-1) * map.tilesize - auto_distance_from_edge;
					respawnPos = Vec2f(x, (map.getLandYAtX(x / map.tilesize) - 2) * map.tilesize);
					server_CreateBlob(flag_spawn_name(), 1, respawnPos);
				}
			}
		}
		else
		{
			warn("CTF: map loading failure");
			for(int i = 0; i < 2; i++)
			{
				SetupBase(server_CreateBlob(base_name(), i, Vec2f(0,0)));
				server_CreateBlob(flag_spawn_name(), i, Vec2f(0,0));
			}
		}

		rules.SetCurrentState(WARMUP);
	}

	//checks
	void CheckTeamWon() {
		if (!rules.isMatchRunning()) { return; }

		int winteamIndex = -1;
		CTFTeamInfo@ winteam = null;
		s8 team_wins_on_end = -1;

		// get all the flags
		CBlob@[] flags;			// Total flags
		CBlob@[] flags_red;		// Red flags
		CBlob@[] flags_blue;	// Blue flags
		getBlobsByName(flag_name(), @flags);

		for (uint i = 0; i < flags.length; i++) {
			if (flags[i].getTeamNum() == 0) {
				flags_blue.push_back(flags[i]);
			} else if (flags[i].getTeamNum() == 1) {
				flags_red.push_back(flags[i]);
			}
		}

		for (uint team_num = 0; team_num < teams.length; ++team_num) {
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (teams[team_num]);

			bool win = true;

			for (uint i = 0; i < flags.length; i++) {
				//if there exists an enemy flag, we didn't win yet
				if (flags[i].getTeamNum() != team_num) {
					win = false;
					break;
				}
			}

			if (team_num == 0 && flags_red.length < flags_blue.length) {
				team_wins_on_end = 0;
			} else if (team_num == 1 && flags_blue.length < flags_red.length) {
				team_wins_on_end = 1;
			} else if (flags_blue.length == flags_red.length) {
				team_wins_on_end = -1;
			}

			if (win) {
				winteamIndex = team_num;
				@winteam = team;
			}
		}

		rules.set_s8("team_wins_on_end", team_wins_on_end);

		if (winteamIndex >= 0)
		{
			// add winning team coins
			if (rules.isMatchRunning())
			{
				CBlob@[] players;
				getBlobsByTag("player", @players);
				for (uint i = 0; i < players.length; i++)
				{
					CPlayer@ player = players[i].getPlayer();
					if (player !is null && players[i].getTeamNum() == winteamIndex)
					{
						player.server_setCoins(player.getCoins() + 150);
					}
				}
			}

			rules.SetTeamWon(winteamIndex);   //game over!
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage("{WINNING_TEAM} wins the game!");
			rules.AddGlobalMessageReplacement("WINNING_TEAM", winteam.name);
		}
	}

	void CheckTeamWonTDM()
	{
		if (!rules.isMatchRunning()) { return; }

		int winteamIndex = -1;
		CTFTeamInfo@ winteam = null;
		s8 team_wins_on_end = -1;

		int highkills = 0;
		for (uint team_num = 0; team_num < teams.length; ++team_num) {
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (teams[team_num]);

			if (team.kills > highkills) {
				highkills = team.kills;
				team_wins_on_end = team_num;

				if (team.kills >= kills_to_win) {
					@winteam = team;
					winteamIndex = team_num;
				}
			} else if (team.kills > 0 && team.kills == highkills) {
				team_wins_on_end = -1;
			}
		}

		rules.set_s8("team_wins_on_end", team_wins_on_end);

		if (winteamIndex >= 0) {
			// add winning team coins
			if (rules.isMatchRunning()) {
				CBlob@[] players;
				getBlobsByTag("player", @players);
				for (uint i = 0; i < players.length; i++) {
					CPlayer@ player = players[i].getPlayer();

					if (player !is null && players[i].getTeamNum() == winteamIndex) {
						player.server_setCoins(player.getCoins() + 150);
					}
				}
			}

			rules.SetTeamWon(winteamIndex);   //game over!
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage("{WINNING_TEAM} wins the game!");
			rules.AddGlobalMessageReplacement("WINNING_TEAM", winteam.name);
		}
	}

	void CheckStalemate()
	{
		//Stalemate code courtesy of Pirate-Rob

		//cant stalemate outside of match time
		if (!rules.isMatchRunning()) return;

		//stalemate disabled in config?
		if (stalemateTime < 0) return;

		// get all the flags
		CBlob@[] flags;
		getBlobsByName(flag_name(), @flags);

		//figure out if there's currently a stalemate condition
		bool stalemate = true;
		for (uint i = 0; i < flags.length; i++)
		{
			CBlob@ flag = flags[i];
			CBlob@ holder = flag.getAttachments().getAttachmentPointByName("FLAG").getOccupied();
			//If any flag is held by an ally (ie the flag base), no stalemate
			if (holder !is null && holder.getTeamNum() == flag.getTeamNum())
			{
				stalemate = false;
				break;
			}
		}

		if(stalemate)
		{
			if(!rules.exists("stalemate_breaker"))
			{
				rules.set_s16("stalemate_breaker", stalemateTime);
			}
			else
			{
				rules.sub_s16("stalemate_breaker", 1);
			}

			int stalemate_seconds_remaining = Maths::Ceil(rules.get_s16("stalemate_breaker") / 30.0f);
			if(stalemate_seconds_remaining > 0)
			{
				rules.SetGlobalMessage("Stalemate: both teams have no uncaptured flags.\nFlags returning in: {TIME}");
				rules.AddGlobalMessageReplacement("TIME", ""+stalemate_seconds_remaining);
			}
			else
			{
				rules.set_s16("stalemate_breaker", -(stalemateOutcomeTime * 30));

				//flags tagged serverside for return
				for (uint i = 0; i < flags.length; i++)
				{
					CBlob@ flag = flags[i];
					flag.Tag("stalemate_return");
				}
			}
		}
		else
		{
			int stalemate_timer = rules.get_s16("stalemate_breaker");
			if(stalemate_timer > -10 && stalemate_timer != stalemateTime)
			{
				rules.SetGlobalMessage("");
				rules.set_s16("stalemate_breaker", stalemateTime);
			}
			else if(stalemate_timer <= -10)
			{
				rules.SetGlobalMessage("Stalemate resolved: Flags returned.");
				rules.add_s16("stalemate_breaker", 1);
			}
		}

		rules.Sync("stalemate_breaker", true);
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			CTFTeamInfo@ team_info = cast < CTFTeamInfo@ > (teams[team]);

			// increase kills count in team info, while it TDM
			if (rules.get_string("internal_game_mode") == "tavern")
				team_info.kills++;
		}
	}

	void GiveSpawnResources(CBlob@ blob, CPlayer@ player) {
		if (blob.getName() == "builder") {
			// first check if its in surroundings
			CBlob@[] blobsInRadius;
			CMap@ map = getMap();
			bool found = false;
			if (map.getBlobsInRadius(blob.getPosition(), 60.0f, @blobsInRadius)) {
				for (uint i = 0; i < blobsInRadius.length; i++) {
					CBlob @b = blobsInRadius[i];
					if (b.getName() == "drill") {
						found = true;
						if (!found) {
							blob.server_PutInInventory(b);
						} else {
							b.server_Die();
						}
					}
				}
			}

			if (!found) {
				CBlob@ mat = server_CreateBlob("drill");
				if (mat !is null) {
					if (!blob.server_PutInInventory(mat)) {
						mat.setPosition(blob.getPosition());
					}
				}
			}
		}
	}
};

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
	this.set_CBitStream("ctf_serialised_team_hud", stream);
    this.Sync("ctf_serialized_team_hud", true);

	printf("Restarting rules script: " + getCurrentScriptName());
	CTFSpawns spawns();
	CTFCore core(this, spawns);
	Config(core);
	core.SetupBases();
	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	this.Tag("faster mining");

	// Reset builders in team, captains should set them by hands
	this.set_string("team_" + "0" + "_builder", "");
	this.set_string("team_" + "1" + "_builder", "");

	this.Sync("team_" + "0" + "_builder", true);
	this.Sync("team_" + "1" + "_builder", true);

	// set previous gamemode, if we changed it
	if (this.exists("previous_game_mode")) {
		this.set_string("internal_game_mode", PreviousGamemode(this));
		this.Sync("internal_game_mode", true);
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);

	const int restart_after = (!this.hasTag("tutorial") ? 30 : 5) * 30;
	this.set_s32("restart_rules_after_game_time", restart_after);

	// set internal gamemode as CTF by default
	if (!this.exists("previous_game_mode")) {
		this.set_string("internal_game_mode", "gruhsha");
		this.Sync("internal_game_mode", true);
	}
}

void onStateChange(CRules@ this, const u8 oldState)
{
	if (this.getCurrentState() == GAME)
	{
		CBlob@[] list;

		getBlobsByName("building", @list);

		for (int i=0; i<list.length; ++i)
		{
			//printf("test");
			list[i].SendCommand(list[i].getCommandID("reset menu"));
		}
	}

	if (this.getCurrentState() == GAME_OVER) {
		this.set_string("previous_game_mode", InternalGamemode(this));
		this.Sync("previous_game_mode", true);
	}
}

// had to add it here for tutorial cause something didnt work in the tutorial script
void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (this.hasTag("tutorial"))
	{
		const string name = blob.getName();
		if ((name == "archer" || name == "knight" || name == "chicken") && !blob.hasTag("dropped coins"))
		{
			server_DropCoins(blob.getPosition(), XORRandom(15) + 5);
			blob.Tag("dropped coins");
		}
	}
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "mat_gold")
	{
		blob.RemoveScript("DecayQuantity.as");
	}
}
