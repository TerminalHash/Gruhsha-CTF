// Flesh hit
#include "JarateHitCommon.as"

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// return doubled damage if our player covered in pee
	if (DoublingDamageHitters(customData)) {
		if (this !is null && hitterBlob !is null && this.hasTag("player") && this.hasTag("peed")) {
            damage *= 2.0f;
		}
	}

	this.Damage(damage, hitterBlob);
	// Gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);

	//printf("ON HIT " + damage + " he " + this.getHealth() + " g " + gibHealth );
	// blob server_Die()() and then gib

	//printf("gibHealth " + gibHealth + " health " + this.getHealth() );
	if (this.getHealth() <= gibHealth)
	{
		if (getRules().get_string("clusterfuck") != "off") {
			this.getSprite().Gib();
		}

		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}
