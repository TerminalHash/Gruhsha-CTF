#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("slash_while_in_hand");
	//this.Tag("builder always hit");
	this.Tag("flesh");
	this.getShape().SetGravityScale(0);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//no explosives can deflect blobs
	if (customData==Hitters::keg || customData==Hitters::bomb) return 0;

	//only slashes from knight can deflect blobs
	if (customData==Hitters::sword && damage < 2) return 0;

	AttachmentPoint@ hitbox_point = this.getAttachments().getAttachmentPointByName("PARRY_HITBOX");
	if (hitbox_point is null) return damage;

	CBlob@ blob_to_parry = hitbox_point.getOccupied();
	if (blob_to_parry is null) return damage;

	if (blob_to_parry.isAttached()) return 0;

	f32 vellen = blob_to_parry.getVelocity().Length();

	Vec2f dir = blob_to_parry.getVelocity()/vellen;

	blob_to_parry.setVelocity((velocity/(velocity.Length()))*(vellen+2));

	blob_to_parry.getSprite().PlaySound("parry_ultrakill.ogg");

	return 0;
}

void ChangeOwner(CBlob@ this, CBlob@ hitterBlob)
{
	AttachmentPoint@ hitbox_point = this.getAttachments().getAttachmentPointByName("PARRY_HITBOX");
	if (hitbox_point is null) return;

	CBlob@ blob_to_parry = hitbox_point.getOccupied();
	if (blob_to_parry is null) return;

	CPlayer@ owner = hitterBlob.getDamageOwnerPlayer();
	if (owner is null) return;

	blob_to_parry.SetDamageOwnerPlayer(owner);
	blob_to_parry.server_setTeamNum(-1);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.hasTag("projectile");
}