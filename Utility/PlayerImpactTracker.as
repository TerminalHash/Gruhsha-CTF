// PlayerImpactTracker.as
/*
    This script tracking player's damage dealt and time.
    Almost part of code picked from VanillaNoRequem by bunnie (thanks for it).
*/

string[] players_list = {};

void onTick(CRules@ this) {
	if (this.getCurrentState() != WARMUP && this.getCurrentState() != INTERMISSION) {
		if (getGameTime() % 30 == 0) {
			for (int i=0; i<getPlayersCount(); i++) {
				string current_player = getPlayer(i).getUsername();

				if (players_list.find(current_player) == -1) {
					players_list.push_back(current_player);
				}

				if (getPlayer(i).getTeamNum() != 0 && getPlayer(i).getTeamNum() != 1) {
					// do nothing
				} else {
					this.add_s32("play_time" + current_player, 1);
					this.Sync("play_time" + current_player, true);
				}
			}
		}
	}

	if (getGameTime() % 150 == 0 && isServer()) {
		for (int i=0; i<getPlayersCount(); i++) {
			CPlayer@ cp = getPlayer(i);

			if (cp.getTeamNum() != 0 && cp.getTeamNum() != 1) {
				string current_player = cp.getUsername();
				this.Sync("play_time" + current_player, true);
			}
		}
	}
}

void onRestart(CRules@ this) {
	if (isServer()) {
		for (int i=0; i<players_list.length; ++i) {
			this.set_s32("play_time" + players_list[i], 0);
			this.Sync("play_time" + players_list[i], true);

			this.set_f32("damage_impact_" + players_list[i], 0);
			this.Sync("damage_impact_" + players_list[i], true);
		}
	}
}

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale) {
	if (isServer()) {
		if (victim !is null && attacker !is null && isServer()) {
			if ((attacker.getTeamNum() != victim.getTeamNum()) && this.isMatchRunning()) {
				if (attacker !is victim && victim.getBlob() !is null) {
					this.add_f32("damage_impact_" + attacker.getUsername(), Maths::Min(DamageScale * 2, victim.getBlob().getHealth() * 2));
					this.Sync("damage_impact_" + attacker.getUsername(), true);
				}
			}
		}
	}

	return DamageScale;
}