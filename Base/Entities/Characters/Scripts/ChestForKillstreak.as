// ChestForKillstreak.as
// random item on victim's death
#define SERVER_ONLY

const int TIMER_BEFORE_BRONZE = 25 * getTicksASecond();
const int TIMER_BEFORE_SILVER = 50 * getTicksASecond();
const int TIMER_BEFORE_GOLDEN = 75 * getTicksASecond();

void dropChest(CBlob@ this) {
	if (!this.hasTag("dropped lootchest")) { // double check
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();
		if (killer is null || myplayer is null || killer.getUsername() == myplayer.getUsername()) { return; }

		// loot chest allowed to drop only on TavernTDM
		if (getRules().get_string("internal_game_mode") != "tavern") return;

		uint16 kill_count = killer.get_u8("killstreak");
		if (kill_count < 1) return;

		int drop_random = XORRandom(256) / 64;

		this.Tag("dropped lootchest");

		printf("-- -- -- -- -- -- -- -- --");
		printf("Current " + killer.getUsername() + "'s" + " killstreak: " + kill_count);
		printf("Drop Random is " + drop_random);

		if (killer.getBlob() !is null) {
			// BRONZE CHEST
			if (kill_count >= 2 && kill_count < 3) {
				if (killer.getBlob() !is null && killer.getBlob().exists("got bronze chest")) {
					if (getGameTime() < killer.getBlob().get_u16("got bronze chest") + TIMER_BEFORE_BRONZE)
						return;
				}

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

					killer.getBlob().set_u16("got bronze chest", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			// SILVER CHEST
			} else if (kill_count >= 4 && kill_count < 6) {
				if (killer.getBlob() !is null && killer.getBlob().exists("got silver chest")) {
					if (getGameTime() < killer.getBlob().get_u16("got silver chest") + TIMER_BEFORE_SILVER)
						return;
				}
	
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

					killer.getBlob().set_u16("got silver chest", getGameTime());
					//printf("Ice Bomb is dropped for " + killer.getUsername() + "!");
				}
			// GOLDEN CHEST
			} else if (kill_count >= 6) {
				if (killer.getBlob() !is null && killer.getBlob().exists("got golden chest")) {
					if (getGameTime() < killer.getBlob().get_u16("got golden chest") + TIMER_BEFORE_GOLDEN)
						return;
				}

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

					killer.getBlob().set_u16("got golden chest", getGameTime());
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
