// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	//INIT COSTS
	InitCosts();

	this.set_TileType("background tile", CMap::tile_castle_back);

	//this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(6, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// ICONS
	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);
	AddIconToken("$satchel$", "Satchel.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_blockarrows$", "Materials.png", Vec2f(16, 16), 33);
	AddIconToken("$quarters_pear$", "Pear_Quarters.png", Vec2f(24, 24), 0);

	int team_num = this.getTeamNum();
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
		s.quantityLimit = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, Names::stickybomb, "$stickybombs$", "mat_stickybombs", Descriptions::stickybombdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, Names::icebomb, "$icebomb$", "mat_icebombs", Descriptions::icebombdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, Names::goldenmine, getTeamIcon("golden_mine", "GoldenMine.png", team_num, Vec2f(16, 16), 1), "golden_mine", Descriptions::goldenminedesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::golden_mine);
		AddRequirement(s.requirements, "no more", "golden_mine", "Golden Mine", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
		s.spawnToInventory = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, Names::stonearrow, "$stoneblockarrows$", "mat_stoneblockarrows", Descriptions::stonearrowdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (wood)", getTeamIcon("crate", "Crate.png", team_num, Vec2f(32, 16), 5), "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::crate_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$_buildershop_filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onShopMadeItem(CBitStream@ params)
{
	if (!isServer()) return;

	u16 this_id, caller_id, item_id;
	string name;

	if (!params.saferead_u16(this_id) || !params.saferead_u16(caller_id) || !params.saferead_u16(item_id) || !params.saferead_string(name))
	{
		return;
	}

	CBlob@ caller = getBlobByNetworkID(caller_id);
	if (caller is null) return;

	if (name == "filled_bucket")
	{
		CBlob@ b = server_CreateBlobNoInit("bucket");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Tag("_start_filled");
		b.Init();
		caller.server_Pickup(b);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}