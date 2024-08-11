#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	CPlayer@ dmgowner = hitterBlob.getDamageOwnerPlayer();
	CPlayer@ thisplayer = this.getPlayer();

	if (customData == Hitters::bomb || customData == Hitters::water) {
		if (this !is null && this.hasTag("player") && isClient()) {
			u32 secs_since = getGameTime() - this.get_u32("lastbombjumptimetigor");

			if (hitterBlob.hasTag("DONTSTACKBOMBJUMP") && dmgowner is thisplayer) {
				return damage;
			} else {
				this.AddForce(velocity);
			}
		}
	}

	return damage; 
}