//KOTH gamemode logic script
#define SERVER_ONLY

#include "KOTH_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "KOTH_PopulateSpawnList.as"

//edit the variables in the config file below to change the basics
// no scripting required!
void Config(KOTHCore@ this) {
	string configstr = "koth_vars.cfg";

	if (getRules().exists("kothconfig"))
	{
		configstr = getRules().get_string("kothconfig");
	}

	ConfigFile cfg = ConfigFile(configstr);

	//how long to wait for everyone to spawn in?
	s32 warmUpTimeSeconds = cfg.read_s32("warmup_time", 180);
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

	//how long for the game to play out?
	s32 gameDurationMinutes = 0;

	if (gameDurationMinutes <= 0) {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	} else {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}

	//how many players have to be in for the game to start
	this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team", 2);

	//whether to scramble each game or not
	this.scramble_teams = cfg.read_bool("scramble_teams", true);

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));
}

shared string base_name() { return "tent"; }
shared string controlpoint_name() { return "koth_controlpoint"; }

//KOTH spawn system
const s32 spawnspam_limit_time = 10;

shared class KOTHSpawns : RespawnSystem
{
	KOTHCore@ KOTH_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@KOTH_core = cast < KOTHCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < KOTH_core.teams.length; ++team_num)
		{
			KOTHTeamInfo@ team = cast < KOTHTeamInfo@ > (KOTH_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				KOTHPlayerInfo@ info = cast < KOTHPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(KOTHPlayerInfo@ info, int i)
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

			string propname = "koth spawn time " + info.username;

			KOTH_core.rules.set_u8(propname, spawn_property);
			KOTH_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
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
		KOTHPlayerInfo@ info = cast < KOTHPlayerInfo@ > (p_info);

		if (info is null) { warn("KOTH LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		if (force) { return true; }

		return info.can_spawn_time <= 0;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		KOTHPlayerInfo@ c_info = cast < KOTHPlayerInfo@ > (p_info);
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

		return Vec2f(0, 0);
	}

	CBlob@ getSpawnBlob(PlayerInfo@ p_info)
	{
		KOTHPlayerInfo@ c_info = cast < KOTHPlayerInfo@ > (p_info);
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
		KOTHPlayerInfo@ info = cast < KOTHPlayerInfo@ > (p_info);

		if (info is null) { warn("KOTH LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "koth spawn time " + info.username;

		for (uint i = 0; i < KOTH_core.teams.length; i++) {
			KOTHTeamInfo@ team = cast < KOTHTeamInfo@ > (KOTH_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}

		KOTH_core.rules.set_u8(propname, 255);   //not respawning
		KOTH_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		//DONT set this zero - we can re-use it if we didn't actually spawn
		//info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		//s32 tickspawndelay = s32(KOTH_core.spawnTime);
		s32 tickspawndelay = s32(getTicksASecond() * 12);

		KOTHPlayerInfo@ info = cast < KOTHPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("KOTH LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		//clamp it so old bad values don't get propagated
		s32 old_spawn_time = Maths::Max(0, Maths::Min(info.can_spawn_time, tickspawndelay));

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		if (info.team < KOTH_core.teams.length) {
			KOTHTeamInfo@ team = cast < KOTHTeamInfo@ > (KOTH_core.teams[info.team]);

			info.can_spawn_time = ((old_spawn_time > 30) ? old_spawn_time : tickspawndelay);

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		} else {
			error("PLAYER TEAM NOT SET CORRECTLY! " + info.team + " / " + KOTH_core.teams.length + " for player " + player.getUsername());
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		KOTHPlayerInfo@ info = cast < KOTHPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < KOTH_core.teams.length; i++)
		{
			KOTHTeamInfo@ team = cast < KOTHTeamInfo@ > (KOTH_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

shared class KOTHCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;
	s32 stalemateTime;
	s32 stalemateOutcomeTime;

	s32 minimum_players_in_team;

	s32 players_in_small_team;
	bool scramble_teams;

	KOTHSpawns@ koth_spawns;

	KOTHCore() {}

	KOTHCore(CRules@ _rules, RespawnSystem@ _respawns) {
		spawnTime = 0;
		stalemateOutcomeTime = 6; //seconds
		super(_rules, _respawns);
	}

	int gamestart;
	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null) {
		RulesCore::Setup(_rules, _respawns);
		gamestart = getGameTime();
		@koth_spawns = cast < KOTHSpawns@ > (_respawns);
		_rules.set_string("music - base name", base_name());
		server_CreateBlob("koth_music");
		players_in_small_team = -1;
	}

	void Update() {
		if (rules.isGameOver()) { return; }

		s32 ticksToStart = gamestart + warmUpTime - getGameTime();
		koth_spawns.force = false;

		// Change player classes to knight explicity
		if (ticksToStart <= 5 * 30 && rules.getCurrentState() != GAME)
		{
			for (int l = 0; l < getPlayersCount(); ++l)
			{
				CPlayer @p = getPlayer(l);
				if (p !is null)
				{
					CBlob @b = p.getBlob();

					if (b !is null)
					{
						string role;
						int teamNum = p.getTeamNum();

						if (b.getName() == "builder" &&
						!(
							getRules().get_string("team_" + teamNum + "_leader") == p.getUsername() ||
							getRules().get_string("team_" + teamNum + "_builder") == p.getUsername())
						)
						{
							role = "knight";
							CBlob@ test = server_CreateBlobNoInit(role);

							if (test !is null)
							{
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

		if (ticksToStart <= 0 && (rules.isWarmup())) {
			rules.SetCurrentState(GAME);
		} else if (ticksToStart > 0 && rules.isWarmup()) { //is the start of the game, spawn everyone + give mats
			rules.SetGlobalMessage("Match starts in {SEC}");
			rules.AddGlobalMessageReplacement("SEC", "" + ((ticksToStart / 30) + 1));
			koth_spawns.force = true;
		}

		if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers())) {  //CHECK IF TEAMS HAVE ENOUGH PLAYERS
			gamestart = getGameTime();
			rules.set_u32("game_end_time", gamestart + gameDuration);
			rules.SetGlobalMessage("Not enough players in each team for the game to start.\nPlease wait for someone to join...");
			koth_spawns.force = true;
		} else if (rules.isMatchRunning()) {
			rules.SetGlobalMessage("");
		}

		/*
		 * If you want to do something tricky with respawning flags and stuff here, go for it
		 */

		RulesCore::Update(); //update respawns
		CheckTeamWon();
	}

	//HELPERS
	bool allTeamsHavePlayers() {
		for (uint i = 0; i < teams.length; i++) {
			if (teams[i].players_count < minimum_players_in_team) {
				return false;
			}
		}

		return true;
	}

	//team stuff
	void AddTeam(CTeam@ team) {
		KOTHTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "") {
		if (getRules().hasTag("singleplayer")) {
			team = 0;
		} else {
			team = player.getTeamNum();
		}

		KOTHPlayerInfo p(player.getUsername(), team, "knight");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData) {
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null) {
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum()) {
				addKill(killer.getTeamNum());
			}
		}
	}

	void onSetPlayer(CBlob@ blob, CPlayer@ player) {
		if (blob !is null && player !is null) {
			//GiveSpawnResources( blob, player );
		}
	}

	//setup the KOTH bases
	void SetupBase(CBlob@ base) {
		if (base is null) {
			return;
		}

		//nothing to do
	}

	void SetupBases() {
		// destroy all previous spawns if present
		CBlob@[] oldBases;
		getBlobsByName(base_name(), @oldBases);

		for (uint i = 0; i < oldBases.length; i++) {
			oldBases[i].server_Die();
		}

		CMap@ map = getMap();

		if (map !is null && map.tilemapwidth != 0) {
			//spawn the spawns :D
			Vec2f respawnPos;

			f32 auto_distance_from_edge_tents = Maths::Min(map.tilemapwidth * 0.15f * 8.0f, 100.0f);

			if (!getMap().getMarker("blue main spawn", respawnPos)) {
				warn("KOTH: Blue spawn added");
				respawnPos = Vec2f(auto_distance_from_edge_tents, map.getLandYAtX(auto_distance_from_edge_tents / map.tilesize) * map.tilesize - 16.0f);
			}

			respawnPos.y -= 8.0f;
			SetupBase(server_CreateBlob(base_name(), 0, respawnPos));

			if (!getMap().getMarker("red main spawn", respawnPos)) {
				warn("KOTH: Red spawn added");
				respawnPos = Vec2f(map.tilemapwidth * map.tilesize - auto_distance_from_edge_tents, map.getLandYAtX(map.tilemapwidth - (auto_distance_from_edge_tents / map.tilesize)) * map.tilesize - 16.0f);
			}

			respawnPos.y -= 8.0f;
			SetupBase(server_CreateBlob(base_name(), 1, respawnPos));
		} else {
			warn("KOTH: map loading failure");

			for(int i = 0; i < 2; i++) {
				SetupBase(server_CreateBlob(base_name(), i, Vec2f(0,0)));
			}
		}

		rules.SetCurrentState(WARMUP);
	}

	//checks
	void CheckTeamWon() {
		if (!rules.isMatchRunning()) { return; }

		int winteamIndex = -1;
		KOTHTeamInfo@ winteam = null;
		s8 team_wins_on_end = -1;

		// if (GetGamemode(getRules()) == "KOTH")
		if (!getRules().hasTag("some team timer is zero")) {
			for (uint team_num = 0; team_num < teams.length; ++team_num) {
				KOTHTeamInfo@ team = cast < KOTHTeamInfo@ > (teams[team_num]);

				bool win = false;

				if (team_num == 0) {
					if (getRules().get_s32("control_timer_blue") <= 0) {
						win = true;
					}
				} else if(team_num == 1) {
					if (getRules().get_s32("control_timer_red") <= 0) {
						win = true;
					}
				}

				if (win) {
					getRules().Tag("some team timer is zero");
				}
			}
		} else {
			KOTHTeamInfo@ team_blue = cast < KOTHTeamInfo@ > (teams[0]);
			KOTHTeamInfo@ team_red = cast < KOTHTeamInfo@ > (teams[1]);

			if (getRules().get_s32("control_timer_blue") <= 0) {
				winteamIndex = 0;
				@winteam = team_blue;
			}

			if (getRules().get_s32("control_timer_red") <= 0) {
				winteamIndex = 1;
				@winteam = team_red;
			}
		}
		//}

		// unused
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

	void addKill(int team) {
		if (team >= 0 && team < int(teams.length)) {
			KOTHTeamInfo@ team_info = cast < KOTHTeamInfo@ > (teams[team]);
		}
	}

};

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
	this.set_CBitStream("koth_serialised_team_hud", stream);
    this.Sync("koth_serialized_team_hud", true);

	printf("Restarting rules script: " + getCurrentScriptName());
	KOTHSpawns spawns();
	KOTHCore core(this, spawns);
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
