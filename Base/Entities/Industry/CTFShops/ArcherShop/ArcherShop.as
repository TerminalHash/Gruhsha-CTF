// ArcherShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "Costs.as"
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
	this.set_Vec2f("shop menu size", Vec2f(7, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	int team_num = this.getTeamNum();

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "archer");

	// ICONS
	AddIconToken("$blockarrows$", "blockarrows_icon.png", Vec2f(16, 16), 0);

	// Dynamic prices
	u32 dynamic_fire_arrow_cost = 30;
	u32 dynamic_bomb_arrow_cost = 75;
	u32 player_amount = getRules().get_s32("amount_in_team");

	if (player_amount >= 12 && player_amount < 14)
	{
		dynamic_fire_arrow_cost = 35;
		dynamic_bomb_arrow_cost = 80;
	}
	else if (player_amount >= 14 && player_amount < 16)
	{
		dynamic_fire_arrow_cost = 40;
		dynamic_bomb_arrow_cost = 85;
	}
	else if (player_amount >= 16 && player_amount < 18)
	{
		dynamic_fire_arrow_cost = 45;
		dynamic_bomb_arrow_cost = 90;
	}
	else if (player_amount >= 18 && player_amount < 19)
	{
		dynamic_fire_arrow_cost = 45;
		dynamic_bomb_arrow_cost = 90;
	}
	else if (player_amount >= 19)
	{
		dynamic_fire_arrow_cost = 50;
		dynamic_bomb_arrow_cost = 95;
	}

	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", Descriptions::arrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::arrows);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterarrows);
		AddRequirement(s.requirements, "no more", "mat_waterarrows", "Water Arrows", 2); // half of inventory
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", dynamic_fire_arrow_cost /*CTFCosts::firearrows*/);
	}
	{
		ShopItem@ s = addShopItem(this, Names::bombarrow, "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::bombarrows);
		AddRequirement(s.requirements, "buy delay", "mat_bombarrows", "Bomb Arrow", 25);
	}
	{
		ShopItem@ s = addShopItem(this, Names::woodenarrow, "$blockarrows$", "mat_blockarrows", Descriptions::woodenarrowdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::blockarrows);
	}
	{
		ShopItem@ s = addShopItem(this, Names::stonearrow, "$stoneblockarrows$", "mat_stoneblockarrows", Descriptions::stonearrowdesc, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::stoneblockarrows);
	}
	{
		string mountedbow_icon = getTeamIcon("mounted_bow", "MountedBow.png", team_num, Vec2f(16, 16), 6);
		ShopItem@ s = addShopItem(this, "Mounted Bow", mountedbow_icon, "mounted_bow", Descriptions::mountedbowdesc, false, true);
		s.crate_icon = 3;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::mountedbow);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	int P_Archers = getRules().get_s32("archer" + getLocalPlayer().getTeamNum() + "Count");

	CRules@ rules = getRules();
	bool disallow_class_change_on_shops = rules.get_bool("no_class_change_on_shop");
	string disabled_class_changing_in_shops = getRules().get_string("disable_class_change_in_shops");

	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class") || disallow_class_change_on_shops == true || disabled_class_changing_in_shops == "yes" || P_Archers >= rules.get_u8("archers_limit"))
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

		if (name == "mat_bombarrows")
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
