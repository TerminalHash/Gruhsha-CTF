// some KOTH-specific variables
const int min_cap_count = 1;								// how many players need for capture point
const s32 cp_cap_time = 30 * getTicksASecond();				// time for capture point, in seconds
const s32 cp_control_time = (60 * 3) * getTicksASecond();   // time for control point, in minutes
//const s32 cp_control_time = (30) * getTicksASecond();     // time for control point (DEBUG)

// spawn resources
const u32 materials_wait = 45; //seconds between free mats
const u32 materials_wait_warmup = 60; //seconds between free mats

const int matchtime_wood_amount = 150;
const int matchtime_stone_amount = 50;

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "KOTH SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "KOTH SpawnItems Archer:";

string base_name() { return "tent"; }

//resupply timers
string getKOTHTimerPropertyName(CPlayer@ p, string classname) {
	if (classname == "builder") {
		return SPAWN_ITEMS_TIMER_BUILDER + p.getUsername();
	} else {
		return SPAWN_ITEMS_TIMER_ARCHER + p.getUsername();
	} 
}

s32 getKOTHTimer(CRules@ this, CPlayer@ p, string classname) {
	string property = getKOTHTimerPropertyName(p, classname);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetKOTHTimer(CRules@ this, CPlayer@ p, s32 time, string classname) {
	string property = getKOTHTimerPropertyName(p, classname);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}