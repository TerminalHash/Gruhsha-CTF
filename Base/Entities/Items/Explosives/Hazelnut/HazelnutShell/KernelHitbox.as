void onInit(CBlob@ this)
{
	this.Tag("slash_while_in_hand");
	//this.getShape().SetGravityScale(0);
	//this.server_SetTimeToDie(0.5);
}

void onTick(CBlob@ this)
{

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (hitterBlob.getConfig()!="knight") return 0;

	AttachmentPoint@ hitbox_point = this.getAttachments().getAttachmentPointByName("HITBOX");
	if (hitbox_point is null) return damage;

	CBlob@ kernel = hitbox_point.getOccupied();
	if (kernel is null) return damage;

	f32 vellen = kernel.getVelocity().Length();

	Vec2f dir = kernel.getVelocity()/vellen;

	kernel.setVelocity(velocity/(velocity.Length())*(vellen+2));

	kernel.getSprite().PlaySound("parry_ultrakill.ogg");

	return 0;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}