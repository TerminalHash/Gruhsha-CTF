// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	this.Tag("has window");

	int team_num = this.getTeamNum();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// ICONS
	AddIconToken("$matshop_stone_little$", "Materials.png", Vec2f(16, 16), 0);
	AddIconToken("$matshop_stone_avg$", "Materials.png", Vec2f(16, 16), 8);
	AddIconToken("$matshop_stone_big$", "Materials.png", Vec2f(16, 16), 16);
	AddIconToken("$matshop_wood_little$", "Materials.png", Vec2f(16, 16), 1);
	AddIconToken("$matshop_wood_avg$", "Materials.png", Vec2f(16, 16), 9);
	AddIconToken("$matshop_wood_big$", "Materials.png", Vec2f(16, 16), 17);

	// STONE
	{
		ShopItem@ s = addShopItem(this, "Stone (50)", "$matshop_stone_little$", "stone_little", "Little amount of stone for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Stone (150)", "$matshop_stone_avg$", "stone_avg", "Average amount of stone for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Stone (250)", "$matshop_stone_big$", "stone_big", "Big amount of stone for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Stone (500)", "$mat_stone$", "stone_huge", "Huge amount of stone for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 225);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	// WOOD
	{
		ShopItem@ s = addShopItem(this, "Wood (50)", "$matshop_wood_little$", "wood_little", "Little amount of wood for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Wood (150)", "$matshop_wood_avg$", "wood_avg", "Average amount of wood for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Wood (250)", "$matshop_wood_big$", "wood_big", "Big amount of wood for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Wood (500)", "$mat_wood$", "wood_huge", "Huge amount of wood for builder", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

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

	if (name == "stone_little") {
		CBlob@ b = server_CreateBlobNoInit("mat_stone");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(50);
		caller.server_PutInInventory(b);
	} else if (name == "stone_avg") {
		CBlob@ b = server_CreateBlobNoInit("mat_stone");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(150);
		caller.server_PutInInventory(b);
	} else if (name == "stone_big") {
		CBlob@ b = server_CreateBlobNoInit("mat_stone");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(250);
		caller.server_PutInInventory(b);
	} else if (name == "stone_huge") {
		CBlob@ b = server_CreateBlobNoInit("mat_stone");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(500);
		caller.server_PutInInventory(b);
	} else if (name == "wood_little") {
		CBlob@ b = server_CreateBlobNoInit("mat_wood");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(50);
		caller.server_PutInInventory(b);
	} else if (name == "wood_avg") {
	CBlob@ b = server_CreateBlobNoInit("mat_wood");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(150);
		caller.server_PutInInventory(b);
	} else if (name == "wood_big") {
	CBlob@ b = server_CreateBlobNoInit("mat_wood");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(250);
		caller.server_PutInInventory(b);
	} else if (name == "wood_huge") {
	CBlob@ b = server_CreateBlobNoInit("mat_wood");
		b.setPosition(caller.getPosition());
		b.server_setTeamNum(caller.getTeamNum());
		b.Init();
		b.server_SetQuantity(500);
		caller.server_PutInInventory(b);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}