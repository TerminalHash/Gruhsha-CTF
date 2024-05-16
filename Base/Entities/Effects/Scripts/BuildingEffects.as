#include "MakeDustParticle.as";

void onDie(CBlob@ this)
{
	if (!this.getSprite().getVars().gibbed)
	{
		this.getSprite().PlaySound("/BuildingExplosion");
	}

	if (getRules().get_string("clusterfuck") == "off") return;

	// gib no matter what
	this.getSprite().Gib();
	// effects
	MakeDustParticle(this.getPosition(), "Smoke.png");

}