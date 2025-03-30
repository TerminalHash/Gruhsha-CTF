// spawn resources
const u32 materials_wait = 30; //seconds between free mats (one builder)
const u32 materials_wait_longer = 45; //seconds between free mats (few builders)
const u32 materials_wait_warmup = 45; //seconds between free mats (unused)

const int warmup_wood_amount = 500;
const int warmup_stone_amount = 500;

const int matchtime_wood_amount = 250;
const int matchtime_stone_amount = 75;

////////////////////////////////////////////
// Reducing resupplies stuff
const u32 lower_mats_timer = 1380; // 20 min

const int lower_wood = 150;
const int lower_stone = 50;
///////////////////////////////////////////

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";

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