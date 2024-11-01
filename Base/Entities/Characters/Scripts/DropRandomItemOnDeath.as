// DropRandomItemOnDeath.as
// random item on victim's death
#define SERVER_ONLY

const int TIMER_BEFORE_NEXT_ITEM = 5 * getTicksASecond();

void dropRandomItem(CBlob@ this) {
	if (!this.hasTag("dropped random item")) { // double check
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();
		if (killer is null || myplayer is null || killer.getUsername() == myplayer.getUsername()) { return; }

		uint16 kill_count = killer.get_u8("killstreak");
		if (kill_count < 1) return;
	
		// if player already got item - dont spam with them
		if (killer.getBlob() !is null && killer.getBlob().exists("got item from kill")) {
			if (getGameTime() < killer.getBlob().get_u16("got item from kill") + TIMER_BEFORE_NEXT_ITEM)
				return;
		}

		int drop_random = XORRandom(256) / 64;

		this.Tag("dropped random item");

		//printf("-- -- -- -- -- -- -- -- --");
		//printf("Current " + killer.getUsername() + "'s" + " killstreak: " + kill_count);
		//printf("Drop Random is " + drop_random);

		if (killer.getBlob() !is null) {
			if (drop_random >= 2.5) {
				CBlob@ icebomb = server_CreateBlob("mat_icebombs", -1, this.getPosition());

				if (icebomb !is null) {
					Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
					icebomb.setVelocity(vel);
					icebomb.set_u16("icebomber", killer.getNetworkID());

					CBlob@ killerblob = killer.getBlob();
					if (killerblob !is null) {
						CInventory@ killer_inv = killerblob.getInventory();
						icebomb.setPosition(killerblob.getPosition());
					}

					killer.getBlob().set_u16("got item from kill", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			} else {
				CBlob@ stickybomb = server_CreateBlob("mat_stickybombs", -1, this.getPosition());
				if (stickybomb !is null) {
					Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
					stickybomb.setVelocity(vel);
					stickybomb.set_u16("stickybomber", killer.getNetworkID());

					CBlob@ killerblob = killer.getBlob();
					if (killerblob !is null) {
						CInventory@ killer_inv = killerblob.getInventory();
						stickybomb.setPosition(killerblob.getPosition());
					}

					killer.getBlob().set_u16("got item from kill", getGameTime());
					//printf("Sticky Bomb is dropped for " + killer.getUsername() + "!");
				}
			}
		}
	}
}

void onDie(CBlob@ this) {
	if (this.hasTag("switch class") ||
		this.hasTag("dropped random item") ||
		this.hasBlob("mat_icebombs", 1) ||
		this.hasBlob("mat_stickybombs", 1)) { return; }    //don't make a heart on change class, or if this has already run before or if had bread

	dropRandomItem(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
