
//CTF gamemode logic script

#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "CTF_PopulateSpawnList.as"

//edit the variables in the config file below to change the basics
// no scripting required!
void Config(CTFCore@ this)
{
	string configstr = "gruhsha_vars.cfg";

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
	if (getRules().get_string("internal_game_mode") == "tavern")
		getRules().set_f32("fall vel modifier", cfg.read_f32("fall_dmg_nerf", 1.3f));
}

shared string base_name() { return "tent"; }
shared string base_name_tavern() { return "tdm_spawn"; }
shared string flag_name() { return "ctf_flag"; }
shared string flag_spawn_name() { return "flag_base"; }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
/*
	Here should be a fucking bunch of functions for our gamemodes, which would be included into Gruhsha.
	For now, that zone planned for rework and idk when it's would be done, so let's wait, when fantastic and 
	ideal future will come to our world.

	Composition of functions picked from VNR as placeholder for for future code, their number and composition 
	may vary significantly depending on how I implement the modes.
*/

// CLASSES
// we need this???
class DistanceClass {}

// OUR FUNCTIONS
void CheckStalemate(CRules@ rules) {}
void CheckTeamWon(CRules@ rules) {}
void UpdateSpawns(CRules@ this) {}
void UpdateState(CRules@ rules) {}
void SetRespawnTime(CRules@ this, CPlayer@ player, u16 overridetime=0) {}
void SpawnPlayer(CRules@ this, CPlayer@ player) {}
void SortByPosition(CBlob@[]@ spawns) {}

// HOOKS
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData) {}
void onNewPlayerJoin(CRules@ this, CPlayer@ player) {}
void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam) {}
void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam) {}
void onPlayerLeave(CRules@ this, CPlayer@ player) {}

f32 onPlayerTakeDamage( CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale ) {}
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

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
