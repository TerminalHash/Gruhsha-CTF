#include "MakeDustParticle.as";

void onDie(CBlob@ this)
{
	if (!this.getSprite().getVars().gibbed)
	{
		this.getSprite().PlaySound("/BuildingExplosion");
	}

	// gib no matter what
	if (getRules().get_string("clusterfuck") != "off") {
		this.getSprite().Gib();
	}

	// effects
	if (getRules().get_string("clusterfuck_smoke") != "off") {
		MakeDustParticle(this.getPosition(), "Smoke.png");
	}
}