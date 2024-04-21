void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(this !is null && blob !is null)
	{
		if(this.getPlayer() !is null)
		{
			// food
			if(blob.getName() == "food" || blob.getName() == "grain" || blob.getName() == "egg" || blob.getName() == "pear" )
			{
				CInventory@ inventory = this.getInventory();
				int hasitem = 0;
				CBlob@ myitem = null;

				for(int i=0; i < inventory.getItemsCount(); ++i)
				{
					if (inventory.getItem(i) !is null)
					{
						if (inventory.getItem(i).getName() == "food" || inventory.getItem(i).getName() == "grain" || inventory.getItem(i).getName() == "egg" || inventory.getItem(i).getName() == "pear")
						{
							hasitem += 1;
							@myitem = inventory.getItem(i);
						}
					}
				}

				if (hasitem > 1 && myitem !is null)
				{
					this.server_PutOutInventory(blob);
					if(blob !is null)
					{
						this.server_Pickup(blob);
					}

					if (this.getPlayer().isMyPlayer())
						this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.8);
				}
			}

			if(blob.getName() == "drill")
			{
				CInventory@ inventory = this.getInventory();
				int hasitem = 0;
				CBlob@ myitem = null;

				for(int i=0; i < inventory.getItemsCount(); ++i)
				{
					if (inventory.getItem(i) !is null)
					{
						if (inventory.getItem(i).getName() == "drill")
						{
							hasitem += 1;
							@myitem = inventory.getItem(i);
						}
					}
				}

				CBlob@ carry = this.getCarriedBlob();
				if (carry !is null)
				{
					if (carry.getName() == "drill")
					{
						hasitem += 1;
						@myitem = carry;
					}
				}

				if(hasitem > 0 && myitem !is null && myitem !is blob)
				{
					this.server_PutOutInventory(myitem);
					if(blob !is null)
					{
						this.server_Pickup(blob);
					}

					if (this.getPlayer().isMyPlayer())
						this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.8);
				}
			}
		}
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.getName() == "drill" && this.getPlayer() !is null)
	{
		CInventory@ inventory = this.getInventory();
		int hasitem = 0;
		CBlob@ myitem = null;

		for(int i=0; i < inventory.getItemsCount(); ++i)
		{
			if (inventory.getItem(i) !is null)
			{
				if (inventory.getItem(i).getName() == "drill")
				{
					hasitem += 1;
					@myitem = inventory.getItem(i);
				}
			}
		}

		if(hasitem > 0 && myitem !is null && myitem !is attached)
		{
			this.server_PutOutInventory(myitem);

			if (this.getPlayer().isMyPlayer())
						this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.8);
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	string blobName = blob.getName();

	if (blobName == "drill" && !blob.isAttached())
	{
		// inventory variant
		CInventory@ inventory = this.getInventory();
		int hasitem = 0;
		CBlob@ myitem = null;

		for(int i=0; i < inventory.getItemsCount(); ++i)
		{
			if (inventory.getItem(i) !is null)
			{
				if (inventory.getItem(i).getName() == "drill")
				{
					hasitem += 1;
					@myitem = inventory.getItem(i);
				}
			}
		}

		if(hasitem > 0 && myitem !is null && myitem.get_u8("drill heat") > blob.get_u8("drill heat"))
		{
			f32 lower_drill_heat = blob.get_u8("drill heat");
			f32 higher_drill_heat = myitem.get_u8("drill heat");

			myitem.set_u8("drill heat", lower_drill_heat);
			blob.set_u8("drill heat", higher_drill_heat);
			myitem.Sync("drill heat", true);
			blob.Sync("drill heat", true);
			return;
		}

		// carry variant

		CBlob@ carry = this.getCarriedBlob();
		if (carry !is null)
		{
			if (carry.getName() == "drill")
			{
				if (carry.get_u8("drill heat") > blob.get_u8("drill heat"))
				{
					f32 lower_drill_heat = blob.get_u8("drill heat");
					f32 higher_drill_heat = carry.get_u8("drill heat");

					carry.set_u8("drill heat", lower_drill_heat);
					blob.set_u8("drill heat", higher_drill_heat);
					carry.Sync("drill heat", true);
					blob.Sync("drill heat", true);
					return;
				}
			}
		}
	}
}
