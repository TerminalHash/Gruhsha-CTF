// ChestForKillstreak.as
// random item on victim's death
#define SERVER_ONLY

const int TIMER_BEFORE_NEXT_ITEM = 30 * getTicksASecond();

void dropChest(CBlob@ this) {
	if (!this.hasTag("dropped lootchest")) { // double check
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();
		if (killer is null || myplayer is null || killer.getUsername() == myplayer.getUsername()) { return; }

		// loot chest allowed to drop only on TavernTDM
		if (getRules().get_string("internal_game_mode") != "tavern") return;

		uint16 kill_count = killer.get_u8("killstreak");
		if (kill_count < 1) return;

		// if player already got item - dont spam with them
		if (killer.getBlob() !is null && killer.getBlob().exists("got chest")) {
			if (getGameTime() < killer.getBlob().get_u16("got chest") + TIMER_BEFORE_NEXT_ITEM)
				return;
		}

		int drop_random = XORRandom(256) / 64;

		this.Tag("dropped lootchest");

		printf("-- -- -- -- -- -- -- -- --");
		printf("Current " + killer.getUsername() + "'s" + " killstreak: " + kill_count);
		printf("Drop Random is " + drop_random);

		if (killer.getBlob() !is null) {
			// BRONZE CHEST
			if (drop_random <= 1.5) {
				CBlob@ lootchest = server_CreateBlob("lootchest", -1, this.getPosition());

				if (lootchest !is null) {
					Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
					lootchest.setVelocity(vel);
					lootchest.set_string("lootchest owner", killer.getUsername());
					lootchest.set_u8("chest_type", 1);

					CBlob@ killerblob = killer.getBlob();
					if (killerblob !is null) {
						CInventory@ killer_inv = killerblob.getInventory();
						lootchest.setPosition(killerblob.getPosition());
					}

					killer.getBlob().set_u16("got chest", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			// SILVER CHEST
			} else if (drop_random > 1.5 && drop_random <= 2.5) {
				CBlob@ lootchest = server_CreateBlob("lootchest", -1, this.getPosition());

				if (lootchest !is null) {
					Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
					lootchest.setVelocity(vel);
					lootchest.set_string("lootchest owner", killer.getUsername());
					lootchest.set_u8("chest_type", 2);

					CBlob@ killerblob = killer.getBlob();
					if (killerblob !is null) {
						CInventory@ killer_inv = killerblob.getInventory();
						lootchest.setPosition(killerblob.getPosition());
					}

					killer.getBlob().set_u16("got chest", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			// GOLDEN CHEST
			} else if (drop_random > 2.5 && drop_random <= 3) {
				CBlob@ lootchest = server_CreateBlob("lootchest", -1, this.getPosition());

				if (lootchest !is null) {
					Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
					lootchest.setVelocity(vel);
					lootchest.set_string("lootchest owner", killer.getUsername());
					lootchest.set_u8("chest_type", 3);

					CBlob@ killerblob = killer.getBlob();
					if (killerblob !is null) {
						CInventory@ killer_inv = killerblob.getInventory();
						lootchest.setPosition(killerblob.getPosition());
					}

					killer.getBlob().set_u16("got chest", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			}
		}
	}
}

void onDie(CBlob@ this) {
	if (this.hasTag("switch class") ||
		this.hasTag("dropped lootchest") ||
		this.hasBlob("lootchest", 1)) { return; }    //don't make a heart on change class, or if this has already run before or if had bread

	dropChest(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
