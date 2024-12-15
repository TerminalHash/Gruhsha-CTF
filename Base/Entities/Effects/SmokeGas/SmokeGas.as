void onInit(CBlob@ this)
{
	this.Tag("smoke");
	this.Tag("gas");

	this.getShape().SetGravityScale(-0.01f);

	this.getSprite().SetZ(10.0f);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.50f);
	
	this.server_SetTimeToDie(0.5f);
	
	CShape@ shape = this.getShape();
	//shape.getConsts().mapCollisions = false;
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();

	MakeParticle(this);
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmokeGray")
{
	if (!isClient() && !this.isOnScreen()) return;

	if (getRules().get_string("custom_boom_effects") == "off") return;

	CParticle@ p = ParticleAnimated(filename, this.getPosition() + Vec2f(XORRandom(200) / 10.0f - 10.0f, XORRandom(200) / 10.0f - 10.0f), Vec2f(), float(XORRandom(360)), 0.2f * this.get_f32("flares") + (XORRandom(50) / 100.0f), 3, 0.0f, false);
	if (p !is null) {
		//p.setRenderStyle(RenderStyle::additive);
		p.Z=260+XORRandom(30)*0.01;
		p.growth = 0.005*this.get_f32("flares");
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
   return blob.hasTag("smoke");
}
