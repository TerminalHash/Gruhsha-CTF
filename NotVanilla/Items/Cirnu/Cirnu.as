void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
}

void onInit(CSprite@ this)
{
	this.ScaleBy(Vec2f(0.25f, 0.25f));

	this.SetEmitSound("/funky.ogg");
	this.SetEmitSoundSpeed(1.0f);
	this.SetEmitSoundPaused(false);
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	//attachedPoint.offsetZ = -10.0f;
	//this.getSprite().SetRelativeZ(-10.0f);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	attachedPoint.offsetZ = 0.0f;
	this.getSprite().SetRelativeZ(0.0f);
}
