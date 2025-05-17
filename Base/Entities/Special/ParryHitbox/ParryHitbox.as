#include "Hitters.as";
#include "GruhshaHitters.as";

void onInit(CBlob@ this)
{
	this.Tag("slash_while_in_hand");
	this.Tag("ignore_arrow");
	
	this.getShape().SetGravityScale(0);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//no explosives and water-related shit can deflect blobs
	// btw icebomb has very funny bug, what it's sets the velocity as (-inf, -inf)
	// so dont remove isWaterHitter bool from this condition
	if (customData==Hitters::keg  ||
		customData==Hitters::bomb ||
		isWaterHitter(customData) ||
		customData==GruhshaHitters::hazelnut_shell || 
		customData==GruhshaHitters::sticky_bomb) return 0;

	//only slashes from knight can deflect blobs
	if (customData==Hitters::sword && damage < 2) return 0;

	AttachmentPoint@ hitbox_point = this.getAttachments().getAttachmentPointByName("PARRY_HITBOX");
	if (hitbox_point is null) return damage;

	CBlob@ blob_to_parry = hitbox_point.getOccupied();
	if (blob_to_parry is null) return damage;

	//parry hitbox doesn't work when blob to parry is attached
	if (blob_to_parry.isAttached()) return 0;

	//archer cannot parry bombs
	if (blob_to_parry.getConfig()=="bomb" && customData==Hitters::arrow) return 0;

	//knights cannot parry bombs of its own team
	if (blob_to_parry.getTeamNum()==hitterBlob.getTeamNum() && hitterBlob.getDamageOwnerPlayer() !is blob_to_parry.getDamageOwnerPlayer()) return 0;

	f32 vellen = blob_to_parry.getVelocity().Length();

	Vec2f dir = blob_to_parry.getVelocity()/vellen;

	blob_to_parry.setVelocity((velocity/(velocity.Length()))*Maths::Min(12, vellen+hitterBlob.getVelocity().Length()+2));
	//blob_to_parry.AddForce(Vec2f(Maths::Min(100, (vellen+2)*30), 0).RotateBy(-(velocity/(velocity.Length())).getAngleDegrees()));

	//printf("Velocity of blob is " + blob_to_parry.getVelocity());

	ChangeOwner(this, hitterBlob);

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

	if (blob_to_parry.getTeamNum()!=hitterBlob.getTeamNum())
		blob_to_parry.server_setTeamNum(-1);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.getConfig()=="arrow";
}