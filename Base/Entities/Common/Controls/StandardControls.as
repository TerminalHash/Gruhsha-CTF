// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommon.as"
#include "ShopCommon.as"
#include "BindingsCommon.as"

bool zoomModifier = false; // decides whether to use the 3 zoom system or not
int zoomModifierLevel = 4; // for the extra zoom levels when pressing the modifier key
int zoomLevel = 1; // we can declare a global because this script is just used by myPlayer

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	this.set_s32("buy delay", 10);
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);
	this.addCommandID("pickup");
	this.addCommandID("putinheld");
	this.addCommandID("getout");
	this.addCommandID("detach");
	this.addCommandID("switch");
	this.addCommandID("drill command");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	//add to the sprite
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.AddScript("StandardControls.as");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!isServer()) return;

	if (cmd == this.getCommandID("putinheld"))
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;
		if (caller !is this) return;
		if (caller.isInInventory()) return;
		if (caller.isAttached()) return;

		CBlob@ held = this.getCarriedBlob();
		if (held is null) return;

		putInHeld(caller);
	}
	else if (cmd == this.getCommandID("pickup"))
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;
		if (caller !is this) return;
		if (caller.isInInventory()) return;
		if (caller.isAttached()) return;

		u16 pickedup_id;
		if (!params.saferead_u16(pickedup_id)) return;

		CBlob@ pickedup = getBlobByNetworkID(pickedup_id);
		if (pickedup is null) return;

		if (!pickedup.canBePickedUp(caller)) return;

		if (pickedup.isAttached()) return;

		caller.server_Pickup(pickedup);
	}
	else if (cmd == this.getCommandID("detach"))
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;
		if (caller !is this) return;

		u16 attached_id;
		if (!params.saferead_u16(attached_id)) return;

		CBlob@ attached = getBlobByNetworkID(attached_id);
		if (attached is null) return;
		
		if (!this.isAttachedTo(attached)) return;

		this.server_DetachFrom(attached);
	}
	else if (cmd == this.getCommandID("getout"))
	{
		CBlob@ inv = this.getInventoryBlob();
		if (inv is null) return;

		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;

		inv.server_PutOutInventory(this);
	}
	else if (cmd == this.getCommandID("drill command"))
	{
		CBlob@ carried = this.getCarriedBlob();

		CInventory@ inventory = this.getInventory();

		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;

		CBlob@ ourburga = null;

		if (carried !is null && carried.getName() == "drill")
		{
			this.server_PutInInventory(carried);
			return;
		}

		for (int i = 0; i < inventory.getItemsCount(); ++i)
		{
			if (inventory.getItem(i) !is null)
			{
				if (inventory.getItem(i).getName() == "drill")
				{
					@ourburga = inventory.getItem(i);
					this.server_PutOutInventory(ourburga);

					if (carried !is null)
					{
						this.server_PutInInventory(carried);
					}

					this.server_Pickup(ourburga);
					break;
				}
			}
		}
	}
}

bool putInHeld(CBlob@ owner)
{
	if (owner is null) return false;

	CBlob@ held = owner.getCarriedBlob();
	if (held is null) return false;

	return owner.server_PutInInventory(held);
}

bool ClickGridMenu(CBlob@ this, int button)
{
	CGridMenu @gmenu;
	CGridButton @gbutton;

	if (this.ClickGridMenu(button, gmenu, gbutton))   // button gets pressed here - thing get picked up
	{
		if (gmenu !is null)
		{
			// if (gmenu.getName() == this.getInventory().getMenuName() && gmenu.getOwner() !is null)
			{
				if (gbutton is null)    // carrying something, put it in
				{
					client_PutInHeld(this);
				}
				else // take something
				{
					// handled by button cmd   // hardcoded still :/
				}
			}
			return true;
		}
	}

	return false;
}

void ButtonOrMenuClick(CBlob@ this, Vec2f pos, bool clear, bool doClosestClick)
{
	if (!ClickGridMenu(this, 0))
		if (this.ClickInteractButton())
		{
			clear = false;
		}
		else if (doClosestClick)
		{
			if (this.ClickClosestInteractButton(pos, this.getRadius() * 1.0f))
			{
				this.ClearButtons();
				clear = false;
			}
		}

	if (clear)
	{
		this.ClearButtons();
		this.ClearMenus();
	}
}

void onTick(CBlob@ this)
{
	if (getCamera() is null)
	{
		return;
	}
	ManageCamera(this);

	CControls@ controls = getControls();

	// use menu

	if (this.isKeyJustPressed(key_use))
	{
		Tap(this);
		this.set_bool("can button tap", !getHUD().hasMenus());
		this.ClearMenus();
		this.ShowInteractButtons();
		this.set_bool("release click", true);
	}
	else if (this.isKeyJustReleased(key_use))
	{
		if (this.get_bool("release click"))
		{
			CBlob@ carry = this.getCarriedBlob();
			ButtonOrMenuClick(this, carry !is null? carry.getPosition() : this.getPosition(),
							  true, isTap(this) && this.get_bool("can button tap"));
		}

		this.ClearButtons();
	}

	CBlob @carryBlob = this.getCarriedBlob();


	// bubble menu

	if (this.isKeyJustPressed(key_bubbles))
	{
		Tap(this);
	}

	// taunt menu

	if (this.isKeyJustPressed(key_taunts))
	{
		Tap(this);
	}

	// drill thing

	if (b_KeyJustPressed("take_out_drill"))
	{
		this.SendCommand(this.getCommandID("drill command"));
	}

	if (this.get_s32("buy delay") > 0) {
		this.sub_s32("buy delay", 1);
	}

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
	if (getRules().get_string("nomenubuying") == "yes" && this.getName() != "builder") we_buying = true;
	if (getRules().get_string("nomenubuying_b") == "yes" && this.getName() == "builder") we_buying = true;
	if (getGridMenuByName("Buy") !is null) we_buying = true;

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
					printf("wanna_buy bool is true");
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

				if (wanna_buy) {
					dont_show_emotes = true;
					ShopItem @s_item = shopitems[item_id];

					if (s_item !is null) {
						CBitStream params;

						params.write_u8(u8(item_id));
						params.write_bool(true); //used hotkey?

						if (this.get_s32("buy delay") <= 0) {
							theknightshop.SendCommand(theknightshop.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);
						}
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

						if (this.get_s32("buy delay") <= 0) {
							thebuildershop.SendCommand(thebuildershop.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);
						}
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

						if (this.get_s32("buy delay") <= 0) {
							thearchershop.SendCommand(thearchershop.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);
						}
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

						if (this.get_s32("buy delay") <= 0) {
							thekfc.SendCommand(thekfc.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);
						}
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

						if (this.get_s32("buy delay") <= 0) {
							thevehicle.SendCommand(thevehicle.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);
						}
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

						if (this.get_s32("buy delay") <= 0) {
							theboat.SendCommand(theboat.getCommandID("shop buy"), params);
							this.set_s32("buy delay", 10);

						}
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

	/*else dont use this cause menu won't be release/clickable
	if (this.isKeyJustReleased(key_bubbles))
	{
	    this.ClearBubbleMenu();
	} */

	// in crate

	if (this.isInInventory())
	{
		if (this.isKeyJustPressed(key_pickup) && isClient())
		{
			CBlob@ invblob = this.getInventoryBlob();
			// Use the inventoryblob command if it has one (crate for example)
			if (invblob.hasCommandID("getout"))
			{
				invblob.SendCommand(invblob.getCommandID("getout"));
			}
			else
			{
				this.SendCommand(this.getCommandID("getout"));
			}
		}

		return;
	}

	// no more stuff possible while in crate...

	// inventory menu

	if (this.getInventory() !is null && this.getTickSinceCreated() > 10)
	{
		if (this.isKeyJustPressed(key_inventory))
		{
			Tap(this);
			this.set_bool("release click", true);
			// this.ClearMenus();

			//  Vec2f center =  getDriver().getScreenCenterPos(); // center of screen
			Vec2f center = controls.getMouseScreenPos();
			if (this.exists("inventory offset"))
			{
				this.CreateInventoryMenu(center + this.get_Vec2f("inventory offset"));
			}
			else
			{
				this.CreateInventoryMenu(center);
			}

			//controls.setMousePosition( center );
		}
		else if (this.isKeyJustReleased(key_inventory))
		{
			u8 minimum_ticks = 5;
			if (this.getName() == "builder") minimum_ticks = 3; // they have to switch blocks faaaaast

			if (isTap(this, minimum_ticks))     // tap - put thing in inventory
			{
				CBlob@ held = this.getCarriedBlob();

				if (held !is null && getRules().get_string("cycle_with_item") != "yes")
				{
					this.SendCommand(this.getCommandID("putinheld"));
				}
				else
				{
					ControlsCycle@ onCycle;
					if (this.get("onCycle handle", @onCycle))
					{
						CBitStream params;
						params.write_u16(this.getNetworkID());
						params.ResetBitIndex();

						onCycle(params);
					}
				}

				if (getGameTime() - this.get_s32("tap_time") > minimum_ticks) {
					this.SendCommand(this.getCommandID("putinheld"));
				}

				this.ClearMenus();
				return;
			}
			else // click inventory
			{
				if (this.get_bool("release click"))
				{
					ClickGridMenu(this, 0);
				}

				if (!this.hasTag("dont clear menus"))
				{
					this.ClearMenus();
				}
				else
				{
					this.Untag("dont clear menus");
				}
			}
		}
	}

	// release action1 to click buttons

	if (getHUD().hasButtons())
	{
		if ((this.isKeyJustPressed(key_action1) /*|| controls.isKeyJustPressed(KEY_LBUTTON)*/) && !this.isKeyPressed(key_pickup))
		{
			ButtonOrMenuClick(this, this.getAimPos(), false, true);
			this.set_bool("release click", false);
		}
	}

	// clear grid menus on move

	if (!this.isKeyPressed(key_inventory) &&
	        (this.isKeyJustPressed(key_left) || this.isKeyJustPressed(key_right) || this.isKeyJustPressed(key_up) ||
	         this.isKeyJustPressed(key_down) || this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action3))
	   )
	{
		this.ClearMenus();
	}

	//if (this.isKeyPressed(key_action1))
	//{
	//  //server_DropCoins( this.getAimPos(), 100 );
	//  CBlob@ mat = server_CreateBlob( "cata_rock", 0, this.getAimPos());
	//}

	// keybinds

	if (controls.ActionKeyPressed(AK_BUILD_MODIFIER))
	{
		EKEY_CODE[] keybinds = { KEY_KEY_1, KEY_KEY_2, KEY_KEY_3, KEY_KEY_4, KEY_KEY_5, KEY_KEY_6, KEY_KEY_7, KEY_KEY_8, KEY_KEY_9, KEY_KEY_0 };

		// loop backwards so leftmost keybinds have priority
		for (int i = keybinds.size() - 1; i >= 0; i--)
		{
			if (controls.isKeyJustPressed(keybinds[i]))
			{
				ControlsSwitch@ onSwitch;
				if (this.get("onSwitch handle", @onSwitch))
				{
					CBitStream params;
					params.write_u16(this.getNetworkID());
					params.write_u8(i);
					params.ResetBitIndex();

					onSwitch(params);
				}
			}
		}
	}
}

// show dots on chat

void onDie(CBlob@ this)
{
	set_emote(this, "");
}

// CAMERA

void onInit(CSprite@ this)
{
	//backwards compat - tag the blob if we're assigned to the sprite too
	//so if it's not there, the blob can adjust the camera at 30fps at least
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	blob.Tag("60fps_camera");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.isMyPlayer()) return;
	//do 60fps camera
	AdjustCamera(blob, true);

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
		"k_sticky"
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

void AdjustCamera(CBlob@ this, bool is_in_render)
{
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;

	f32 zoomSpeed = 0.1f;
	if (is_in_render)
	{
		zoomSpeed *= getRenderApproximateCorrectionFactor();
	}

	f32 minZoom = 0.5f; // TODO: make vars
	f32 maxZoom = 2.0f;

	f32 zoom_target = 1.0f;

	if (zoomModifier) 
	{
		switch (zoomModifierLevel) 
		{
			case 0:	zoom_target = 0.5f; zoomLevel = 0; break;
			case 1: zoom_target = 0.5625f; zoomLevel = 0; break;
			case 2: zoom_target = 0.625f; zoomLevel = 0; break;
			case 3: zoom_target = 0.75f; zoomLevel = 0; break;
			case 4: zoom_target = 1.0f; zoomLevel = 1; break;
			case 5: zoom_target = 1.5f; zoomLevel = 1; break;
			case 6: zoom_target = 2.0f; zoomLevel = 2; break;
		}
	} 
	else 
	{
		switch (zoomLevel) 
		{
			case 0: zoom_target = 0.5f; zoomModifierLevel = 0; break;
			case 1: zoom_target = 1.0f; zoomModifierLevel = 4; break;
			case 2:	zoom_target = 2.0f; zoomModifierLevel = 6; break;
		}
	}

	if (zoom > zoom_target)
	{
		zoom = Maths::Max(zoom_target, zoom - zoomSpeed);
	}
	else if (zoom < zoom_target)
	{
		zoom = Maths::Min(zoom_target, zoom + zoomSpeed);
	}

	camera.targetDistance = zoom;
}

void ManageCamera(CBlob@ this)
{
	CCamera@ camera = getCamera();
	CControls@ controls = this.getControls();

	// mouse look & zoom
	if ((getGameTime() - this.get_s32("tap_time") > 5) && controls !is null)
	{
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT)))
		{
			zoomModifier = controls.isKeyPressed(KEY_LCONTROL);

			zoomModifierLevel = Maths::Max(0, zoomModifierLevel - 1);
			zoomLevel = Maths::Max(0, zoomLevel - 1);

			Tap(this);
		}
		else  if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN)))
		{
			zoomModifier = controls.isKeyPressed(KEY_LCONTROL);

			zoomModifierLevel = Maths::Min(6, zoomModifierLevel + 1);
			zoomLevel = Maths::Min(2, zoomLevel + 1);

			Tap(this);
		}
	}

	if (!this.hasTag("60fps_camera"))
	{
		AdjustCamera(this, false);
	}

	f32 zoom = camera.targetDistance;
	bool fixedCursor = true;
	if (zoom < 1.0f)  // zoomed out
	{
		camera.mousecamstyle = 1; // fixed
	}
	else
	{
		// gunner
		if (this.isAttachedToPoint("GUNNER"))
		{
			camera.mousecamstyle = 2;
		}
		else if (g_fixedcamera) // option
		{
			camera.mousecamstyle = 1; // fixed
		}
		else
		{
			camera.mousecamstyle = 2; // soldatstyle
		}
	}

	// camera
	camera.mouseFactor = 0.5f; // doesn't affect soldat cam
}
