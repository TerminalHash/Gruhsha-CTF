// NoMenuBuying.as
#include "ShopCommon.as"
#include "BindingsCommon.as"

void onTick(CBlob@ this)
{
	// Shops!
	bool overlapping_knightshop = false;
	bool overlapping_archershop = false;
	bool overlapping_buildershop = false;
	bool overlapping_kfc = false;
	bool overlapping_vehicle = false;
	bool overlapping_boat = false;

	CBlob@ theknightshop;
	CBlob@ thearchershop;
	CBlob@ thebuildershop;
	CBlob@ thekfc;
	CBlob@ thevehicle;
	CBlob@ theboat;

	bool dont_show_emotes = false;

	CBlob@[] overlapping;
	if (getMap().getBlobsInRadius(this.getPosition(), 8.0f, overlapping)) {
		for (int i = 0; i < overlapping.length; ++i) {
			// fix multiply buying shit
			if (!this.isMyPlayer()) return;

			if (overlapping[i].getName() == "knightshop") {
				overlapping_knightshop = true;
				@theknightshop = overlapping[i];
			} else if (overlapping[i].getName() == "archershop") {
				overlapping_archershop = true;
				@thearchershop = overlapping[i];
			} else if (overlapping[i].getName() == "buildershop") {
				overlapping_buildershop = true;
				@thebuildershop = overlapping[i];
			} else if (overlapping[i].getName() == "quarters") {
				overlapping_kfc = true;
				@thekfc = overlapping[i];
			} else if (overlapping[i].getName() == "vehicleshop") {
				overlapping_vehicle = true;
				@thevehicle = overlapping[i];
			} else if (overlapping[i].getName() == "boatshop") {
				overlapping_boat = true;
				@theboat = overlapping[i];
			}
		}
	}

	bool we_buying = false;
	if (getRules().get_string("nomenubuying") == "yes" && this.getName() != "builder") {
		//printf("NOMENUBUYING IS ACTIVE");
		we_buying = true;
	}

	if (getRules().get_string("nomenubuying_b") == "yes" && this.getName() == "builder"){
		//printf("BUILDER NOMENUBUYING IS ACTIVE");
		we_buying = true;
	}

	if (getGridMenuByName("Buy") !is null) {
		//printf("MENU IS OPEN");
		we_buying = true;
	}

	if (we_buying) {
		// Knight shop
		if (overlapping_knightshop && theknightshop !is null) {
			ShopItem[]@ shopitems;

			if (theknightshop.get("shop array", @shopitems)) {
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("k_bomb")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("k_waterbomb")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("k_mine")) {
					wanna_buy = true;
					item_id	= 2;
				}
				if (b_KeyJustPressed("k_keg")) {
					wanna_buy = true;
					item_id	= 3;
				}
				if (b_KeyJustPressed("k_drill")) {
					wanna_buy = true;
					item_id	= 4;
				}
				if (b_KeyJustPressed("k_satchel")) {
					wanna_buy = true;
					item_id	= 5;
				}
				if (b_KeyJustPressed("k_sticky")) {
					wanna_buy = true;
					item_id	= 6;
				}
				if (b_KeyJustPressed("k_icebomb")) {
					wanna_buy = true;
					item_id	= 7;
				}
				if (b_KeyJustPressed("k_goldmine")) {
					wanna_buy = true;
					item_id	= 8;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						theknightshop.SendCommand(theknightshop.getCommandID("shop buy"), params);
					}
				}
			}
		}

		// Builder shop
		if (overlapping_buildershop && thebuildershop !is null)
		{
			ShopItem[]@ shopitems;

			if (thebuildershop.get("shop array", @shopitems))
			{
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("b_drill")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("b_sponge")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("b_bucketw")) {
					wanna_buy = true;
					item_id	= 2;
				}
				if (b_KeyJustPressed("b_boulder")) {
					wanna_buy = true;
					item_id	= 3;
				}
				if (b_KeyJustPressed("b_lantern")) {
					wanna_buy = true;
					item_id	= 4;
				}
				if (b_KeyJustPressed("b_bucketn")) {
					wanna_buy = true;
					item_id	= 5;
				}
				if (b_KeyJustPressed("b_trampoline")) {
					wanna_buy = true;
					item_id	= 6;
				}
				if (b_KeyJustPressed("b_saw")) {
					wanna_buy = true;
					item_id	= 7;
				}
				if (b_KeyJustPressed("b_crate_wood")) {
					wanna_buy = true;
					item_id	= 8;
				}
				if (b_KeyJustPressed("b_crate_coins")) {
					wanna_buy = true;
					item_id	= 9;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						thebuildershop.SendCommand(thebuildershop.getCommandID("shop buy"), params);
					}
				}
			}
		}

        // Archer shop
		if (overlapping_archershop && thearchershop !is null) {
			ShopItem[]@ shopitems;

			if (thearchershop.get("shop array", @shopitems)) {
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("a_arrows")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("a_waterarrows")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("a_firearrows")) {
					wanna_buy = true;
					item_id	= 2;
				}
				if (b_KeyJustPressed("a_bombarrows")) {
					wanna_buy = true;
					item_id	= 3;
				}
				if (b_KeyJustPressed("a_blockarrows")) {
					wanna_buy = true;
					item_id	= 4;
				}
				if (b_KeyJustPressed("a_stoneblockarrows")) {
					wanna_buy = true;
					item_id	= 5;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null)
					{
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						thearchershop.SendCommand(thearchershop.getCommandID("shop buy"), params);
					}
				}
			}
		}

		// Quarters
		if (overlapping_kfc && thekfc !is null) {
			ShopItem[]@ shopitems;

			if (thekfc.get("shop array", @shopitems)) {
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("kfc_beer")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("kfc_meal")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("kfc_egg")) {
					wanna_buy = true;
					item_id	= 2;
				}
				if (b_KeyJustPressed("kfc_burger")) {
					wanna_buy = true;
					item_id	= 3;
				}
				if (b_KeyJustPressed("kfc_pear")) {
					wanna_buy = true;
					item_id	= 4;
				}
				if (b_KeyJustPressed("kfc_sleep")) {
					wanna_buy = true;
					item_id	= 5;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						thekfc.SendCommand(thekfc.getCommandID("shop buy"), params);
					}
				}
			}
		}

		// Vehicle Shop
		if (overlapping_vehicle && thevehicle !is null) {
			ShopItem[]@ shopitems;

			if (thevehicle.get("shop array", @shopitems)) {
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("vehicle_catapult")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("vehicle_ballista")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("vehicle_outpost")) {
					wanna_buy = true;
					item_id	= 2;
				}
				if (b_KeyJustPressed("vehicle_bolts")) {
					wanna_buy = true;
					item_id	= 3;
				}
				if (b_KeyJustPressed("vehicle_shells")) {
					wanna_buy = true;
					item_id	= 4;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						thevehicle.SendCommand(thevehicle.getCommandID("shop buy"), params);
					}
				}
			}
		}

		// Boat Shop
		if (overlapping_boat && theboat !is null) {
			ShopItem[]@ shopitems;

			if (theboat.get("shop array", @shopitems)) {
				bool wanna_buy = false;
				u8 item_id = 250;

				if (b_KeyJustPressed("boat_dinghy")) {
					wanna_buy = true;
					item_id	= 0;
				}
				if (b_KeyJustPressed("boat_longboat")) {
					wanna_buy = true;
					item_id	= 1;
				}
				if (b_KeyJustPressed("boat_warboat")) {
					wanna_buy = true;
					item_id	= 2;
				}

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						theboat.SendCommand(theboat.getCommandID("shop buy"), params);
					}
				}
			}
		}
	}

	if (getRules().get_string("dse_while_using_nomenu_buying") == "yes") {
		if (dont_show_emotes) {
			this.set_u32("boughtitemx", getGameTime());
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.isMyPlayer()) return;

	bool we_buying = false;
	if (getRules().get_string("nomenubuying") == "yes" &&  blob.getName() != "builder") we_buying = true;
	if (getRules().get_string("nomenubuying_b") == "yes" && blob.getName() == "builder") we_buying = true;

	if (!we_buying) return;

	if (getRules().get_string("shownomenupanel") == "no") return;

	bool overlapping_knightshop = false;
	bool overlapping_archershop = false;
	bool overlapping_buildershop = false;
	bool overlapping_kfc = false;
	bool overlapping_vehicle = false;
	bool overlapping_boat = false;

	CBlob@ theknightshop;
	CBlob@ thearchershop;
	CBlob@ thebuildershop;
	CBlob@ thekfc;
	CBlob@ thevehicle;
	CBlob@ theboat;

	int swidth = getDriver().getScreenWidth();
	int sheight = getDriver().getScreenHeight();

	CBlob@[] overlapping;
	if (getMap().getBlobsInRadius(blob.getPosition(), 4.0f, overlapping)) {
		for (int i = 0; i < overlapping.length; ++i) {
			if (overlapping[i].getName() == "knightshop") {
				overlapping_knightshop = true;
				@theknightshop = overlapping[i];
			} else if (overlapping[i].getName() == "archershop") {
				overlapping_archershop = true;
				@thearchershop = overlapping[i];
			} else if (overlapping[i].getName() == "buildershop") {
				overlapping_buildershop = true;
				@thebuildershop = overlapping[i];
			} else if (overlapping[i].getName() == "quarters") {
				overlapping_kfc = true;
				@thekfc = overlapping[i];
			} else if (overlapping[i].getName() == "vehicleshop") {
				overlapping_vehicle = true;
				@thevehicle = overlapping[i];
			} else if (overlapping[i].getName() == "boatshop") {
				overlapping_boat = true;
				@theboat = overlapping[i];
			}
		}
	}

	Vec2f start_drawing_here = Vec2f(150, sheight - 150);
	Vec2f advance_by = Vec2f(48, 48);

	ShopItem[]@ shopitems;

	if (overlapping_knightshop) {
		string[] items = {
		"k_bomb",
		"k_waterbomb",
		"k_mine",
		"k_keg",
		"k_drill",
		"k_satchel",
		"k_sticky",
		"k_icebomb",
		"k_goldmine"
		};

		if (theknightshop.get("shop array", @shopitems)) {
			for (int i=0; i < shopitems.length; ++i) {
				s32 buttonwidth = advance_by.x;
				ShopItem @s_item = shopitems[i];

				if (s_item.name == "Drill") {
					buttonwidth = 96;
				}

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1) {
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, advance_by.y));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(8, 8));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}

	if (overlapping_archershop) {
		string[] items = {
		"a_arrows",
		"a_waterarrows",
		"a_firearrows",
		"a_bombarrows",
		"a_blockarrows",
		"a_stoneblockarrows"
		};

		if (thearchershop.get("shop array", @shopitems)) {
			for (int i=0; i < shopitems.length; ++i) {
				s32 buttonwidth = advance_by.x;
				ShopItem @s_item = shopitems[i];

				if (s_item.name == "Drill") {
					buttonwidth = 96;
				}

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1)
				{
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, advance_by.y));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(8, 8));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}

	if (overlapping_kfc) {
		string[] items = {
		"kfc_beer",
		"kfc_meal",
		"kfc_egg",
		"kfc_burger",
		"kfc_pear",
		"kfc_sleep"
		};

		if (thekfc.get("shop array", @shopitems)) {
			for (int i = 0; i < shopitems.length; ++i) {
				s32 buttonwidth = advance_by.x;
				ShopItem @s_item = shopitems[i];

				if (s_item.blobName == "meal")
				{
					buttonwidth = 96;
				}

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1) {
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, advance_by.y));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(0, 0));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}

	if (overlapping_buildershop) {
		string[] items = {
		"b_drill",
        "b_sponge",
        "b_bucketw",
        "b_boulder",
        "b_lantern",
        "b_bucketn",
        "b_trampoline",
        "b_saw",
        "b_crate_wood",
        "b_crate_coins"
		};

		if (thebuildershop.get("shop array", @shopitems)) {
			for (int i = 0; i < 10; ++i) {
				s32 buttonwidth = advance_by.x;
				ShopItem @s_item = shopitems[i];

				if (s_item.blobName == "drill") {
					buttonwidth = 96;
				}
				if (s_item.blobName == "trampoline") {
					buttonwidth = 96;
				}
				if (s_item.blobName == "saw") {
					buttonwidth = 96;
				}
				if (s_item.blobName == "crate") {
					buttonwidth = 96;
				}

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1) {
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, advance_by.y));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(6, 6));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}

	if (overlapping_vehicle) {
		string[] items = {
		"vehicle_catapult",
        "vehicle_ballista",
        "vehicle_outpost",
        "vehicle_bolts",
        "vehicle_shells"
		};

		if (thevehicle.get("shop array", @shopitems)) {
			for (int i = 0; i < 5; ++i) {
				s32 buttonwidth = advance_by.x;
				s32 buttonheight = advance_by.y;
				ShopItem @s_item = shopitems[i];

				if (s_item.blobName == "catapult") {
					buttonwidth = 72;
					buttonheight = 64;
				}
				if (s_item.blobName == "ballista") {
					buttonwidth = 72;
					buttonheight = 64;
				}
				if (s_item.blobName == "outpost") {
					buttonwidth = 72;
					buttonheight = 64;
				}

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1) {
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, buttonheight));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(6, 6));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}

	if (overlapping_boat) {
		string[] items = {
		"boat_dinghy",
        "boat_longboat",
        "boat_warboat"
		};

		if (theboat.get("shop array", @shopitems)) {
			for (int i = 0; i < 3; ++i) {
				s32 buttonwidth = 72;
				s32 buttonheight = 64;
				ShopItem @s_item = shopitems[i];

				string binding;
				if (getRules().get_s32(items[i] + "$1") != -1) {
					binding = getKeyName(getRules().get_s32(items[i] + "$1"));

					if (getRules().get_s32(items[i] + "$2") != -1)
					{
						binding += ("+" + getKeyName(getRules().get_s32(items[i] + "$2")));
					}
				}

				GUI::DrawPane(start_drawing_here, start_drawing_here+Vec2f(buttonwidth, buttonheight));
				GUI::DrawIconByName(s_item.iconName, start_drawing_here + Vec2f(6, 6));
				GUI::DrawText(binding, start_drawing_here + Vec2f(0, 0), color_white);
				start_drawing_here.x += buttonwidth;
			}
		}
	}
}