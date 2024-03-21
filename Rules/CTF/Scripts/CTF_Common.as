// spawn resources
const u32 materials_wait = 30; //seconds between free mats
const u32 materials_wait_warmup = 40; //seconds between free mats

const int warmup_wood_amount = 500;
const int warmup_stone_amount = 500;

const int matchtime_wood_amount = 275;
const int matchtime_stone_amount = 100;

// Waffle: Materials for the entire team. Drop once at the start of the game
const int crate_warmup_wood_amount = 2500;
const int crate_warmup_stone_amount = 2000;

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";
const string RESUPPLY_TIME_STRING = "team resupply timer";  // Waffle: Team resupply crate

string base_name() { return "tent"; }

//resupply timers
string getCTFTimerPropertyName(CPlayer@ p, string classname)
{
	if (classname == "builder")
	{
		return SPAWN_ITEMS_TIMER_BUILDER + p.getUsername();
	}
	else
	{
		return SPAWN_ITEMS_TIMER_ARCHER + p.getUsername();
	} 
}

s32 getCTFTimer(CRules@ this, CPlayer@ p, string classname)
{
	string property = getCTFTimerPropertyName(p, classname);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, s32 time, string classname)
{
	string property = getCTFTimerPropertyName(p, classname);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

// Waffle: Add check
bool isBuildPhase(CRules@ this)
{
	return this.isWarmup() || this.isIntermission();
}
