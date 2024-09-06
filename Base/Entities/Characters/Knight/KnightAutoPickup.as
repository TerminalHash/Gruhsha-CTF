#define SERVER_ONLY

#include "CratePickupCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	string blobName = blob.getName();

	if (blobName == "mat_bombs" || (blobName == "satchel" && !blob.hasTag("exploding")) || blobName == "mat_waterbombs" || blobName == "mat_stickybombs" || blobName == "mat_icebombs")
	{
		if (this.server_PutInInventory(blob))
		{
			return;
		}
	}

	if (blobName == "drill") {
		CPlayer@ p = this.getPlayer();

		if (p !is null) {
			string username = p.getUsername();

			if (blob.canBePickedUp(this) && blob.canBePutInInventory(this) && getRules().get_string(username + "pickdrill_knight") != "no") {
				if (this.server_PutInInventory(blob))
				{
					return;
				}
			}
		}
	}

	CBlob@ carryblob = this.getCarriedBlob();
	if (carryblob !is null && carryblob.getName() == "crate")
	{
		if (crateTake(carryblob, blob))
		{
			return;
		}
	}
}
