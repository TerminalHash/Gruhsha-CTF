#define SERVER_ONLY

void onDie( CBlob@ this )
{
	AttachmentPoint@ parry_point = this.getAttachments().getAttachmentPointByName("PARRY_HITBOX");
	if (parry_point is null) return;
	CBlob@ parry_hitbox = parry_point.getOccupied();
	if (parry_hitbox is null) return;

	parry_hitbox.server_Die();
}