// Armageddon.as
/*
    Main script of Armageddon module.
*/

#include "ArmageddonCommon.as"

#define SERVER_ONLY

void onInit(CRules@ this) {
	Reset(this);
	this.set_u8("armageddon spread", 10);
}

void onRestart(CRules@ this) {
	Reset(this);
}

void Reset(CRules@ this) {
	this.set_s8("armageddon event number", XORRandom(eventsnames.length()));
	this.set_bool("armageddon started", false);
	this.set_bool("fumo spawned", false);
}

void onStateChange(CRules@ this, const u8 oldState) {
    // Check if the game is over
	if (this.getCurrentState() == GAME_OVER && !this.get_bool("armageddon started"))
		Armageddon(this);
}

void onTick(CRules@ this) {
	// Run the apocalypse
	if (this.get_bool("armageddon started") && this.get_s8("armageddon event number") >= 0 && this.get_s8("armageddon event number") < eventsnames.length()) {	// Avoid out of bounds access
		// Execute apocalypse				
		eventsnames[this.get_s8("armageddon event number")]();

		// Flag for apocalypses to execute once
		if (!this.get_bool("armageddon event ran"))
			this.set_bool("armageddon event ran", true);
	}
}
