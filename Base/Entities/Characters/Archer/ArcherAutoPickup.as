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

	if (blobName == "mat_arrows")
	{
		u32 arrows_count = this.getBlobCount("mat_arrows");
		u32 blob_quantity = blob.getQuantity();
		if (arrows_count + blob_quantity <= 60)
		{
			this.server_PutInInventory(blob);
		}
		else if (arrows_count < 60) //merge into current arrow stacks
		{
			this.getSprite().PlaySound("/PutInInventory.ogg");

			u32 pickup_amount = Maths::Min(blob_quantity, 60 - arrows_count);
			if (blob_quantity - pickup_amount > 0)
				blob.server_SetQuantity(blob_quantity - pickup_amount);
			else
				blob.server_Die();

			CInventory@ inv = this.getInventory();
			for (int i = 0; i < inv.getItemsCount() && pickup_amount > 0; i++)
			{
				CBlob@ arrows = inv.getItem(i);
				if (arrows !is null && arrows.getName() == blobName)
				{
					u32 arrow_amount = arrows.getQuantity();
					u32 arrow_maximum = arrows.getMaxQuantity();
					if (arrow_amount + pickup_amount < arrow_maximum)
					{
						arrows.server_SetQuantity(arrow_amount + pickup_amount);
					}
					else
					{
						pickup_amount -= arrow_maximum - arrow_amount;
						arrows.server_SetQuantity(arrow_maximum);
					}
				}
			}
		}
	}
	if (blobName == "mat_firearrows" || blobName == "mat_bombarrows" ||
	        blobName == "mat_waterarrows" || blobName == "mat_blockarrows" || blobName == "mat_stoneblockarrows")
	{
		if (this.server_PutInInventory(blob))
		{
			return;
		}
	}

    if (blobName == "mat_bombs" || (blobName == "satchel" && !blob.hasTag("exploding")) || blobName == "mat_waterbombs" || blobName == "mat_stickybombs" || blobName == "mat_icebombs")
    {
		CPlayer@ p = this.getPlayer();

		if (p !is null) {
			string username = p.getUsername();

			if (blob.canBePickedUp(this) && blob.canBePutInInventory(this) && getRules().get_string(username + "pickbomb_archer") != "no") {
				if (this.server_PutInInventory(blob)) {
					return;
				}
			}
		}
    }

	if (blobName == "drill") {
		CPlayer@ p = this.getPlayer();

		if (p !is null) {
			string username = p.getUsername();

			if (blob.canBePickedUp(this) && blob.canBePutInInventory(this) && getRules().get_string(username + "pickdrill_archer") != "no") {
				if (this.server_PutInInventory(blob)) {
					return;
				}
			}
		}
	}

	CBlob@ carryblob = this.getCarriedBlob(); // For crate detection
	if (carryblob !is null && carryblob.getName() == "crate")
	{
		if (crateTake(carryblob, blob))
		{
			return;
		}
	}
}
