
#define SERVER_ONLY

const string custom_amount_prop = "gold building amount";

void onDie(CBlob@ this)
{
	int drop_amount = this.exists(custom_amount_prop) ?
			this.get_s32(custom_amount_prop) :
			50;
	if (drop_amount == 0) return;

	if (getRules().gamemode_name == "TTH") return; // ballistas and warboats should not drop gold in TTH because they're produced in factories there

	CBlob@ blob = server_CreateBlobNoInit('mat_gold');

	if (blob !is null)
	{
		blob.Tag('custom quantity');
		blob.Init();

		blob.server_SetQuantity(drop_amount);

		if (getRules().getCurrentState() == WARMUP || getRules().getCurrentState() == INTERMISSION || getRules().getCurrentState() == GAME)
		{
			CBlob@[] storages;
			{
				if (getBlobsByName( "tent", @storages ))
				{
					for (uint step = 0; step < storages.length; ++step)
					{
						CBlob@ storage = storages[step];
						if (storage.getTeamNum() == this.getTeamNum())
						{
							storage.server_PutInInventory(blob);
						}
					}
				}
			}
		}
	}
}
