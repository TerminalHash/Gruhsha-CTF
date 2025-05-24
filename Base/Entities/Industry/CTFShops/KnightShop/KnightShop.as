// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"
#include "TranslationsSystem.as"

void onInit(CBlob@ this)
{
	this.addCommandID("reset menu");
	this.Tag("can reset menu");

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("has window");

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(7, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	// Dynamic prices
	u32 dynamic_bomb_cost = 25;
	u32 dynamic_water_bomb_cost = 70;
	u32 dynamic_keg_cost = 160;
	u32 player_amount = getRules().get_s32("amount_in_team");

	if (player_amount >= 12 && player_amount < 14)
	{
		dynamic_bomb_cost = 30;
		dynamic_water_bomb_cost = 80;
	}
	else if (player_amount >= 14 && player_amount < 16)
	{
		dynamic_bomb_cost = 35;
		dynamic_water_bomb_cost = 85;
	}
	else if (player_amount >= 16 && player_amount < 18)
	{
		dynamic_bomb_cost = 40;
		dynamic_water_bomb_cost = 90;
	}
	else if (player_amount >= 18 && player_amount < 19)
	{
		dynamic_bomb_cost = 40;
		dynamic_water_bomb_cost = 90;
	}
	else if (player_amount >= 19)
	{
		dynamic_bomb_cost = 45;
		dynamic_water_bomb_cost = 95;
	}

	if (getRules().hasTag("sudden death")) {
		dynamic_keg_cost = 220;
	}

	int team_num = this.getTeamNum();

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", dynamic_bomb_cost /*CTFCosts::bomb*/);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", dynamic_water_bomb_cost /*CTFCosts::waterbomb*/);
		AddRequirement(s.requirements, "no more", "waterbomb", "Water Bomb", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", getTeamIcon("mine", "Mine.png", team_num, Vec2f(16, 16), 1), "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::mine);
		AddRequirement(s.requirements, "no more", "mine", "Mine", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", getTeamIcon("keg", "Keg.png", team_num, Vec2f(16, 16), 0), "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", dynamic_keg_cost /*CTFCosts::keg*/);
		AddRequirement(s.requirements, "buy delay", "keg", "Keg", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", getTeamIcon("drill", "Drill.png", team_num, Vec2f(32, 16), 0), "drill", Descriptions::drill, false);
		/*AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);*/
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::drill);
	}
	{
		ShopItem@ s = addShopItem(this, "Satchel", getTeamIcon("satchel", "Satchel.png", team_num, Vec2f(16, 16), 0), "satchel", Descriptions::satchel, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::satchel);
		s.spawnToInventory = true;
	}
	{
		ShopItem@ s = addShopItem(this, Names::stickybomb, "$stickybombs$", "mat_stickybombs", Descriptions::stickybombdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::stickybomb);
	}
	{
		ShopItem@ s = addShopItem(this, Names::icebomb, "$icebomb$", "mat_icebombs", Descriptions::icebombdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::icebomb);
	}
	{
		ShopItem@ s = addShopItem(this, Names::goldenmine, getTeamIcon("golden_mine", "GoldenMine.png", team_num, Vec2f(16, 16), 1), "golden_mine", Descriptions::goldenminedesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::golden_mine);
		AddRequirement(s.requirements, "no more", "golden_mine", "Golden Mine", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::slidemine, getTeamIcon("slidemine", "SlideMine.png", team_num, Vec2f(16, 16), 1), "slidemine", Descriptions::slideminedesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::slidemine);
		AddRequirement(s.requirements, "no more", "slidemine", "Slide Mine", 3);
		AddRequirement(s.requirements, "buy delay", "slidemine", "Slide Mine", 30);
	}
	{
		ShopItem@ s = addShopItem(this, Names::booster, "$booster$", "mat_boosters", Descriptions::boosterdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, Names::fumokegname, getTeamIcon("fumokeg", "FumoKegIcon.png", team_num, Vec2f(16, 16), 0), "fumokeg", Descriptions::fumokegdesc, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::fumokeg);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::fumokeg_gold);
		AddRequirement(s.requirements, "no more", "fumokeg", "Fumo Keg", 1);
	}
	{
		ShopItem@ s = addShopItem(this, /*Names::hazelnut*/ "Hazelnut", "$hazelnut$", "hazelnut", /*Descriptions::hazelnutdesc*/ "A genetically modified hazelnut that releases five explosive kernels when shattered.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		AddRequirement(s.requirements, "no more", "hazelnut", "Hazelnut", 2);
		AddRequirement(s.requirements, "buy delay", "hazelnut", "Hazelnut", 60);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CRules@ rules = getRules();
	bool disallow_class_change_on_shops = rules.get_bool("no_class_change_on_shop");
	string disabled_class_changing_in_shops = getRules().get_string("disable_class_change_in_shops");

	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class") || disallow_class_change_on_shops == true || disabled_class_changing_in_shops == "yes")
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		u16 this_id, caller_id, item_id;
		string name;

		if (!params.saferead_u16(this_id) || !params.saferead_u16(caller_id) || !params.saferead_u16(item_id) || !params.saferead_string(name))
		{
			return;
		}

		if (name == "keg")
		{
			this.getSprite().PlaySound("groovy.ogg", 3.5f);
			this.getSprite().PlaySound("/ChaChing.ogg", 0.8f);
		}
		else
		{
			this.getSprite().PlaySound("/ChaChing.ogg");
		}
	}

	if (cmd == this.getCommandID("reset menu"))
	{
		if (this.exists("shop array"))
		{
			ShopItem[] @items;
			this.get("shop array", @items);

			items.clear();
			this.set("shop array", @items);
		}
		onInit(this);
	}
}
