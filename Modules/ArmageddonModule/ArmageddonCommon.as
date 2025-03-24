// ArmageddonCommon.as
/*
    Common functions for Armageddon module.
*/

#include "ArmageddonEvents.as"

funcdef void sosality();

void Armageddon(CRules@ this) {
    if (isServer()) {
        this.set_bool("armageddon started", true);
        this.set_bool("armageddon event ran", false);
    }
}

sosality@[] eventsnames = {
	@TeamWork,                 // 0
	@TDMBased,                 // 1
	@EasyKill,                 // 2
	@PackOfBisons,             // 3
	@PraiseTheFumo,            // 4
	@PraiseNoko,               // 5
	@PraiseCirnu,              // 6
	@BydlerWeapon,             // 7
	@NiktoEtogoNeProsil,       // 8
	@FuckingBlocks,            // 9
	@FridgeCult                // 10
};