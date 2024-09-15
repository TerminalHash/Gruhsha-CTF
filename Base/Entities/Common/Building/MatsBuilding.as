// MatsBuilding.as
/*
	Material drop script for shops.
	Should return 50% of mats from destroyed shop (excluding building).

	Material costs table for shops (actual info you can check in Base/Entities/Industry/CTFShops/CTFCosts.cfg):
	-- -- -- -- -- -- -- -- -- -- -- --
	SHOP			WOOD			STONE
	archershop		50				0
	boatshop		150				0
	building		150				0
	buildershop		50				0
	knightshop		50				0
	storage			50				50
	quarters		50				0
	tunnel			50				100
	vehicleshop		150				0
*/


#define SERVER_ONLY

void onDie(CBlob@ this) {
	int wood_drop_amount = 100;                //	150 + 50 / 2
	int wood_drop_amount_building = 75;        //	150 / 2
	int wood_drop_amount_vehicle = 150;        //	150 + 150 / 2
	int stone_drop_amount = 25;                //	50 / 2
	int stone_drop_amount_tunnel = 50;         //	100 / 2

	/*if (this.getConfig() == "building") {
		CBlob@ wood = server_CreateBlobNoInit('mat_wood');

		if (wood !is null) {
			wood.Tag('custom quantity');
			wood.Init();

			wood.server_SetQuantity(wood_drop_amount_building);
			wood.setPosition(this.getPosition());
		}
	}*/

	if (this.getConfig() == "archershop" ||
		this.getConfig() == "knightshop" ||
		this.getConfig() == "buildershop" ||
		this.getConfig() == "quarters" ||
		this.getConfig() == "storage" ||
		this.getConfig() == "tunnel") {
		CBlob@ wood = server_CreateBlobNoInit('mat_wood');

		if (wood !is null) {
			wood.Tag('custom quantity');
			wood.Init();

			wood.server_SetQuantity(wood_drop_amount);
			wood.setPosition(this.getPosition());
		}
	}

	if (this.getConfig() == "boatshop" ||
		this.getConfig() == "vehicleshop") {
		CBlob@ wood = server_CreateBlobNoInit('mat_wood');

		if (wood !is null) {
			wood.Tag('custom quantity');
			wood.Init();

			wood.server_SetQuantity(wood_drop_amount_vehicle);
			wood.setPosition(this.getPosition());
		}
	}

	if (this.getConfig() == "storage") {
		CBlob@ stone = server_CreateBlobNoInit('mat_stone');

		if (stone !is null) {
			stone.Tag('custom quantity');
			stone.Init();

			stone.server_SetQuantity(stone_drop_amount);
			stone.setPosition(this.getPosition());
		}
	}

	if (this.getConfig() == "tunnel") {
		CBlob@ stone = server_CreateBlobNoInit('mat_stone');

		if (stone !is null) {
			stone.Tag('custom quantity');
			stone.Init();

			stone.server_SetQuantity(stone_drop_amount_tunnel);
			stone.setPosition(this.getPosition());
		}
	}
}
