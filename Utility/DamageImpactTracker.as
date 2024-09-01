// DamageImpactTracker.as
/*
    This script tracking player's damage dealt.
    Code picked from VanillaNoRequem by bunnie (thanks for it).
*/

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