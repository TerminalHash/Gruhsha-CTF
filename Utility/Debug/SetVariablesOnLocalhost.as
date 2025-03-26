// SetVariablesOnLocalhost.as
/*
    This script for easy debugging mod on localhost.
*/

#define SERVER_ONLY

void onInit(CRules@ this) {
	if (!isServer() || !isClient()) { return; }

	this.Tag("editor is active");
	this.set_u8("builders_limit", 99);
	this.set_u8("archers_limit", 99);
}

void onTick (CRules@ this) {
	if (!isServer() || !isClient()) { return; }
	
	// set end time to 99 hours
	if (this.get_s32("end_in")  < 2220) {
		this.set_u32("game_end_time", (99 * 30) * 60);
	}
}