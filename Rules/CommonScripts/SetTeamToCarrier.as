// SetTeamToCarrier.as

#define SERVER_ONLY

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.name!="PICKUP") return;
	
	this.server_setTeamNum(attached.getTeamNum());
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.server_setTeamNum(inventoryBlob.getTeamNum());
}