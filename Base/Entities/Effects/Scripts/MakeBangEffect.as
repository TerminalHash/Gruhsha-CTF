void MakeBangEffect (
	CBlob@ this = null,
	const string effect_name = "bang",
	const f32 scale = 1.0f,
	const bool super_visible = false,
	const Vec2f vel = Vec2f((XORRandom(10)-5) * 0.1, -(3/2)),
	Vec2f pos = Vec2f_zero )
{
	if (getRules().get_string("custom_boom_effects") == "off") return;
	u8 sus = 4;

	CParticle@ bang = ParticleAnimated(
	effect_name,                   						// file name
	this.getPosition() + pos,            				// position
	vel,                         						// velocity
	XORRandom(18)-9,                              		// rotation
	scale + (XORRandom(sus*2)-sus)*0.01,                // scale
	sus*4 + XORRandom(2),                              	// ticks per frame
	0.0f,                               				// gravity
	true);                             					// self lit
	
	if (bang !is null) 
	{
		bang.deadeffect = -1;
		bang.Z = 900;
		if (!super_visible)
			bang.setRenderStyle(RenderStyle::additive);
	}
}