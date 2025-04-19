#define SERVER_ONLY

void onInit(CBlob@ this)
{
	if (this.getAttachments().getAttachmentPointByName("PARRY_HITBOX") is null)
	{
		this.Tag("parry hitbox to be added");
		this.getAttachments().AddAttachmentPoint("PARRY_HITBOX", true);
	}
	this.AddScript("KillParryHitboxOnDie.as");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("parry hitbox to be added"))
	{
		if (this.getAttachments().getAttachmentPointByName("PARRY_HITBOX") is null) return;
		
		CBlob@ blob = server_CreateBlobNoInit("parryhitbox");
		if (blob !is null)
		{
			blob.server_setTeamNum(-1);
			blob.Init();
			this.server_AttachTo(blob, "PARRY_HITBOX");
			this.set_u16("parry_hitbox", blob.getNetworkID());
			blob.getShape().getConsts().collideWhenAttached = true;
			blob.set_string("blob_to_hit", this.getConfig());
		}
		this.Untag("parry hitbox to be added");
	}

	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	CBlob@ parry_hitbox = getBlobByNetworkID(this.get_u16("parry_hitbox"));
	if (parry_hitbox is null) return;
	parry_hitbox.setPosition(Vec2f(0, -400));
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	CBlob@ parry_hitbox = getBlobByNetworkID(this.get_u16("parry_hitbox"));
	if (parry_hitbox is null) return;
	this.server_AttachTo(parry_hitbox, "PARRY_HITBOX");
}