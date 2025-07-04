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
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	// ICONS
	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);
	AddIconToken("builderfleximage", "builderfleximage.png", Vec2f(17, 15), 0, 255);

	{
		ShopItem@ s = addShopItem(this, "Drill", getTeamIcon("drill", "Drill.png", team_num, Vec2f(32, 16), 0), "drill", Descriptions::drill, false);
		/*AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);*/
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::drill);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::sponge);
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$_buildershop_filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::filled_bucket);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::boulder_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", getTeamIcon("trampoline", "Trampoline.png", team_num, Vec2f(32, 16), 3), "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::trampoline_coins);
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood);
		//AddRequirement(s.requirements, "builder", "builder", "You should be a builder", 0);
		AddRequirement(s.requirements, "no more", "trampoline", "Trampoline", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", getTeamIcon("saw", "VehicleIcons.png", team_num, Vec2f(32, 32), 3), "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone);
		//AddRequirement(s.requirements, "no more", "saw", "Saw", 3);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (wood)", getTeamIcon("crate", "Crate.png", team_num, Vec2f(32, 16), 5), "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::crate_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (coins)", getTeamIcon("crate", "Crate.png", team_num, Vec2f(32, 16), 5), "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::crate);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	int P_Builders = getRules().get_s32("builder" + getLocalPlayer().getTeamNum() + "Count");;

	CRules@ rules = getRules();
	bool disallow_class_change_on_shops = rules.get_bool("no_class_change_on_shop");
	string disabled_class_changing_in_shops = getRules().get_string("disable_class_change_in_shops");
	bool is_warmup = rules.get_bool("is_warmup");

	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class") || disallow_class_change_on_shops == true || disabled_class_changing_in_shops == "yes" || P_Builders >= rules.get_u8("builders_limit") && !is_warmup)
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
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