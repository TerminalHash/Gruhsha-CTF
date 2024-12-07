// BindingsPort.as
/*
    Functional for porting bindings and settings from EU Captains and back.
    Can work like shit because KAG is not ideal, but i hope, what it will work without problems/

    Compatible bindings:
    -=====================================-
    NAME                    Compatibility
    -=====================================-
    CAPTAINS-Related
    ---------------------------------------
    Emotes                  All keys
    Blocks                  All keys
    Pings                   Almost all keys (except one)
    Misc                    Only few keys
    Archer Shop             All keys except wooden block arrows
    Builder Shop            All keys
    Knight Shop             All keys except Gruhsha-exclusive items
    Quarters                All keys except pear
    Midshop (Archer)        Doesn't exist in Gruhsha
    Midshop (Builder)       Doesn't exist in Gruhsha
    Midshop (Knight)        Doesn't exist in Gruhsha

    GRUHSHA-Related
    ---------------------------------------
    Tags                    Almost all keys (except one)
    Blocks                  All keys
    Emotes                  All keys
    Actions                 Only few keys
    Archer Shop             All keys except wooden block arrows
    Builder Shop            All keys
    Knight Shop             All keys except Gruhsha-exclusive items
    Quarters                All keys except pear
    Boat Shop               Doesn't exist in Captains
    Vehicle Shop            Doesn't exist in Captains


    Compatible settings:
    -===========================================-
    NAME                            Compatibility
    -===========================================-
    CAPTAINS-Related
    ---------------------------------------
    Build Mode                      Doesn't exist in Gruhsha
    Drill autopickup (Archer)       Yes
    Drill autopickup (Builder)      Yes
    Drill autopickup (Knight)       Yes
    NoMenu Buying                   Yes
    NoMenu Buying (Builder)         Yes
    Auto burger eating              Doesn't exist in Gruhsha
    Pickup System                   Doesn't exist in Gruhsha
    -- -- -- -- -- -- -- -- -- -- -- -- --
    Blockbar HUD                    Yes
    Camera Sway                     Yes
    Disable Gibs                    Partially (different key names)
    NoMenuByuing Panel              Yes
    
    GRUHSHA-Related
    ---------------------------------------
    Grapple while charging          Doesn't exist in Captains
    Class changing on shops         Doesn't exist in Captains
    Cycle with item in hand         Doesn't exist in Captains
    Drill autopickup (Archer)       Yes
    Drill autopickup (Builder)      Yes
    Drill autopickup (Knight)       Yes
    Bomb autopickup (Archer)        Doesn't exist in Captains
    Bomb autopickup (Builder)       Doesn't exist in Captains
    NoMenu Buying                   Yes
    NoMenu Buying (Builder)         Yes
    -- -- -- -- -- -- -- -- -- -- -- -- --
    Blockbar HUD                    Yes
    NoMenuByuing Panel              Yes
    Emotes with NMB                 Doesn't exist in Captains
    Camera Sway                     Yes
    Body tilting                    Doesn't exist in Captains
    Head rotating                   Doesn't exist in Captains
    Disable Gibs                    Partially (different key names)
    Disable Blood                   Doesn't exist in Captains
    Disable Smoke                   Doesn't exist in Captains
    Drillzone Borders               Doesn't exist in Captains
    Annoying Nature                 Doesn't exist in Captains
    Annoying Voicelines             Doesn't exist in Captains
    Annoying Tags                   Doesn't exist in Captains
    Custom death/pain sounds        Doesn't exist in Captains
    Class Panels                    Doesn't exist in Captains
    Airdrop Panel                   Doesn't exist in Captains
    KIWI-like Effects               Doesn't exist in Captains

*/
// This script should be CLIENT ONLY!
#define CLIENT_ONLY

#include "BindingsCommon.as"

// some important vars
string config_dir = "../Cache/";

// Gruhsha files
string Gruhsha_Bindings = "GRUHSHA_playerbindings";
string Gruhsha_Settings = "GRUHSHA_customizableplayersettings";
string Gruhsha_Visual_Settings = "GRUHSHA_visualandsoundsettings";

// EU Captains files
string Captains_Bindings = "CAPTAINSBUNNIE_playerbindings";
string Captains_Settings = "CAPTAINSBUNNIE_customizableplayersettings";

// DEBUG CONFIGS
/*
string test_config1 = "1_test_binds";               // GRUHSHA
string test_config2 = "2_test_binds";               // CAPTAINS
string test_config3 = "2_test_settings";            // CAPTAINS
string test_config4 = "1_test_settings";            // GRUHSHA
string test_config5 = "1_test_visualsettings";      // GRUHSHA
*/

// command, clientside
bool onClientProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    /////////////////////////////////////
    // HELP
    /////////////////////////////////////
    if (textIn == ".importconfig" && player is getLocalPlayer())
	{
        client_AddToChat("Mod Settings Import/Export v1.0", SColor(255, 180, 24, 94));
        client_AddToChat("-- -- -- -- -- -- -- -- -- --", SColor(255, 180, 24, 94));
        client_AddToChat("How to use: .importconfig <option>", SColor(255, 180, 24, 94));
        client_AddToChat(" ", SColor(255, 180, 24, 94));
        client_AddToChat("Available options:", SColor(255, 180, 24, 94));
        client_AddToChat("all - import bindings and settings (it can reset some visual settings)", SColor(255, 180, 24, 94));
        client_AddToChat("bindings - import bindings only", SColor(255, 180, 24, 94));
        client_AddToChat("settings - import settings only", SColor(255, 180, 24, 94));
        client_AddToChat("vsettigs - import visual settings only", SColor(255, 180, 24, 94));
	}

    if (textIn == ".exportconfig" && player is getLocalPlayer())
	{
        client_AddToChat("Mod Settings Import/Export v1.0", SColor(255, 180, 24, 94));
        client_AddToChat("-- -- -- -- -- -- -- -- -- --", SColor(255, 180, 24, 94));
        client_AddToChat("How to use: .exportconfig <option>", SColor(255, 180, 24, 94));
        client_AddToChat(" ", SColor(255, 180, 24, 94));
        client_AddToChat("Available options:", SColor(255, 180, 24, 94));
        client_AddToChat("all - export bindings and settings", SColor(255, 180, 24, 94));
        client_AddToChat("bindings - export bindings only", SColor(255, 180, 24, 94));
        client_AddToChat("settings - export settings only", SColor(255, 180, 24, 94));
        client_AddToChat("vsettings - export visual settings only", SColor(255, 180, 24, 94));
	}
    /////////////////////////////////////

    /////////////////////////////////////
    // IMPORTING
    /////////////////////////////////////
	if (textIn == ".importconfig all" && player is getLocalPlayer())
	{
		client_AddToChat("Starting bindings and settings import process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("import_from_captains", true);
        this.set_bool("import_bindings", true);
        this.set_bool("import_settings", true);
        this.set_bool("import_vsettings", true);
	}

    if (textIn == ".importconfig bindings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting bindings import process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("import_from_captains", true);
        this.set_bool("import_bindings", true);
	}

    if (textIn == ".importconfig settings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting settings import process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("import_from_captains", true);
        this.set_bool("import_settings", true);
	}

    if (textIn == ".importconfig vsettings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting visual settings import process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("import_from_captains", true);
        this.set_bool("import_vsettings", true);
	}
    /////////////////////////////////////

    /////////////////////////////////////
    // EXPORTING
    /////////////////////////////////////
	if (textIn == ".exportconfig all" && player is getLocalPlayer())
	{
		client_AddToChat("Starting bindings and settings export process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("export_to_captains", true);
        this.set_bool("export_bindings", true);
        this.set_bool("export_settings", true);
        this.set_bool("export_vsettings", true);
	}

    if (textIn == ".exportconfig bindings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting bindings export process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("export_to_captains", true);
        this.set_bool("export_bindings", true);
	}

    if (textIn == ".exportconfig settings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting settings export process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("export_to_captains", true);
        this.set_bool("export_settings", true);
	}

    if (textIn == ".exportconfig vsettings" && player is getLocalPlayer())
	{
		client_AddToChat("Starting visual settings export process, please, wait...", SColor(255, 180, 24, 94));
		this.set_bool("export_to_captains", true);
        this.set_bool("export_vsettings", true);
	}
    /////////////////////////////////////

	return true;
}

// main logic
void onTick(CRules@ this)
{
    // configs not loaded? script should stop working lol
	if (!this.get_bool("loadedbindings") && !this.get_bool("loadedsettings") && !this.get_bool("loadedvsettings")) {
		return;
	}

	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;

	ConfigFile gruhshafile;
	ConfigFile captainsfile;

	////////////////////////////////////////////////
	// Import bindings and settings from EU Captains
	if (this.get_bool("import_from_captains")) {
        if (this.get_bool("import_bindings")) {
            if (this.get_bool("loadedbindings")) {
                ResetRuleBindings();

                // BINDINGS
                if (gruhshafile.loadFile(config_dir + Gruhsha_Bindings))  {
                    printf("Gruhsha Bindings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Bindings))  {
                    printf("Captains Bindings file exists.");
                }

                ///////////////////////////////////
                // SHOPS
                ///////////////////////////////////
                // knight shop
                if (gruhshafile.exists("k_bomb$1") && captainsfile.exists("k_bomb$1")) {
                    gruhshafile.add_s32("k_bomb$1", captainsfile.read_s32("k_bomb$1"));
                }
                if (gruhshafile.exists("k_bomb$2") && captainsfile.exists("k_bomb$2")) {
                    gruhshafile.add_s32("k_bomb$2", captainsfile.read_s32("k_bomb$2"));
                }

                if (gruhshafile.exists("k_waterbomb$1") && captainsfile.exists("k_waterbomb$1")) {
                    gruhshafile.add_s32("k_waterbomb$1", captainsfile.read_s32("k_waterbomb$1"));
                }
                if (gruhshafile.exists("k_waterbomb$2") && captainsfile.exists("k_waterbomb$2")) {
                    gruhshafile.add_s32("k_waterbomb$2", captainsfile.read_s32("k_waterbomb$2"));
                }

                if (gruhshafile.exists("k_mine$1") && captainsfile.exists("k_mine$1")) {
                    gruhshafile.add_s32("k_mine$1", captainsfile.read_s32("k_mine$1"));
                }
                if (gruhshafile.exists("k_mine$2") && captainsfile.exists("k_mine$2")) {
                    gruhshafile.add_s32("k_mine$2", captainsfile.read_s32("k_mine$2"));
                }

                if (gruhshafile.exists("k_keg$1") && captainsfile.exists("k_keg$1")) {
                    gruhshafile.add_s32("k_keg$1", captainsfile.read_s32("k_keg$1"));
                }
                if (gruhshafile.exists("k_keg$2") && captainsfile.exists("k_keg$2")) {
                    gruhshafile.add_s32("k_keg$2", captainsfile.read_s32("k_keg$2"));
                }

                if (gruhshafile.exists("k_drill$1") && captainsfile.exists("k_drill$1")) {
                    gruhshafile.add_s32("k_drill$1", captainsfile.read_s32("k_drill$1"));
                }
                if (gruhshafile.exists("k_drill$2") && captainsfile.exists("k_drill$2")) {
                    gruhshafile.add_s32("k_drill$2", captainsfile.read_s32("k_drill$2"));
                }

                if (gruhshafile.exists("k_satchel$1") && captainsfile.exists("k_satchel$1")) {
                    gruhshafile.add_s32("k_satchel$1", captainsfile.read_s32("k_satchel$1"));
                }
                if (gruhshafile.exists("k_satchel$2") && captainsfile.exists("k_satchel$2")) {
                    gruhshafile.add_s32("k_satchel$2", captainsfile.read_s32("k_satchel$2"));
                }

                // builder shop
                if (gruhshafile.exists("b_drill$1") && captainsfile.exists("b_drill$1")) {
                    gruhshafile.add_s32("b_drill$1", captainsfile.read_s32("b_drill$1"));
                }
                if (gruhshafile.exists("b_drill$2") && captainsfile.exists("b_drill$2")) {
                    gruhshafile.add_s32("b_drill$2", captainsfile.read_s32("b_drill$2"));
                }

                if (gruhshafile.exists("b_sponge$1") && captainsfile.exists("b_sponge$1")) {
                    gruhshafile.add_s32("b_sponge$1", captainsfile.read_s32("b_sponge$1"));
                }
                if (gruhshafile.exists("b_sponge$2") && captainsfile.exists("b_sponge$2")) {
                    gruhshafile.add_s32("b_sponge$2", captainsfile.read_s32("b_sponge$2"));
                }

                if (gruhshafile.exists("b_bucketw$1") && captainsfile.exists("b_bucketw$1")) {
                    gruhshafile.add_s32("b_bucketw$1", captainsfile.read_s32("b_bucketw$1"));
                }
                if (gruhshafile.exists("b_bucketw$2") && captainsfile.exists("b_bucketw$2")) {
                    gruhshafile.add_s32("b_bucketw$2", captainsfile.read_s32("b_bucketw$2"));
                }

                if (gruhshafile.exists("b_boulder$1") && captainsfile.exists("b_boulder$1")) {
                    gruhshafile.add_s32("b_boulder$1", captainsfile.read_s32("b_boulder$1"));
                }
                if (gruhshafile.exists("b_boulder$2") && captainsfile.exists("b_boulder$2")) {
                    gruhshafile.add_s32("b_boulder$2", captainsfile.read_s32("b_boulder$2"));
                }

                if (gruhshafile.exists("b_lantern$1") && captainsfile.exists("b_lantern$1")) {
                    gruhshafile.add_s32("b_lantern$1", captainsfile.read_s32("b_lantern$1"));
                }
                if (gruhshafile.exists("b_lantern$2") && captainsfile.exists("b_lantern$2")) {
                    gruhshafile.add_s32("b_lantern$2", captainsfile.read_s32("b_lantern$2"));
                }

                if (gruhshafile.exists("b_bucketn$1") && captainsfile.exists("b_bucketn$1")) {
                    gruhshafile.add_s32("b_bucketn$1", captainsfile.read_s32("b_bucketn$1"));
                }
                if (gruhshafile.exists("b_bucketn$2") && captainsfile.exists("b_bucketn$2")) {
                    gruhshafile.add_s32("b_bucketn$2", captainsfile.read_s32("b_bucketn$2"));
                }

                if (gruhshafile.exists("b_trampoline$1") && captainsfile.exists("b_trampoline$1")) {
                    gruhshafile.add_s32("b_trampoline$1", captainsfile.read_s32("b_trampoline$1"));
                }
                if (gruhshafile.exists("b_trampoline$2") && captainsfile.exists("b_trampoline$2")) {
                    gruhshafile.add_s32("b_trampoline$2", captainsfile.read_s32("b_trampoline$2"));
                }

                if (gruhshafile.exists("b_saw$1") && captainsfile.exists("b_saw$1")) {
                    gruhshafile.add_s32("b_saw$1", captainsfile.read_s32("b_saw$1"));
                }
                if (gruhshafile.exists("b_saw$2") && captainsfile.exists("b_saw$2")) {
                    gruhshafile.add_s32("b_saw$2", captainsfile.read_s32("b_saw$2"));
                }

                if (gruhshafile.exists("b_crate$1") && captainsfile.exists("b_crate$1")) {
                    gruhshafile.add_s32("b_crate$1", captainsfile.read_s32("b_crate$1"));
                }
                if (gruhshafile.exists("b_crate$1") && captainsfile.exists("b_crate2")) {
                    gruhshafile.add_s32("b_crate$2", captainsfile.read_s32("b_crate$2"));
                }

                // archer shop
                if (gruhshafile.exists("a_arrows$1") && captainsfile.exists("a_arrows$1")) {
                    gruhshafile.add_s32("a_arrows$1", captainsfile.read_s32("a_arrows$1"));
                }
                if (gruhshafile.exists("a_arrows$2") && captainsfile.exists("a_arrows$2")) {
                    gruhshafile.add_s32("a_arrows$2", captainsfile.read_s32("a_arrows$2"));
                }

                if (gruhshafile.exists("a_waterarrows$1") && captainsfile.exists("a_waterarrows$1")) {
                    gruhshafile.add_s32("a_waterarrows$1", captainsfile.read_s32("a_waterarrows$1"));
                }
                if (gruhshafile.exists("a_waterarrows$2") && captainsfile.exists("a_waterarrows$2")) {
                    gruhshafile.add_s32("a_waterarrows$2", captainsfile.read_s32("a_waterarrows$2"));
                }

                if (gruhshafile.exists("a_firearrows$1") && captainsfile.exists("a_firearrows$1")) {
                    gruhshafile.add_s32("a_firearrows$1", captainsfile.read_s32("a_firearrows$1"));
                }
                if (gruhshafile.exists("a_firearrows$2") && captainsfile.exists("a_firearrows$2")) {
                    gruhshafile.add_s32("a_firearrows$2", captainsfile.read_s32("a_firearrows$2"));
                }

                if (gruhshafile.exists("a_bombarrows$1") && captainsfile.exists("a_bombarrows$1")) {
                    gruhshafile.add_s32("a_bombarrows$1", captainsfile.read_s32("a_bombarrows$1"));
                }
                if (gruhshafile.exists("a_bombarrows$2") && captainsfile.exists("a_bombarrows$2")) {
                    gruhshafile.add_s32("a_bombarrows$2", captainsfile.read_s32("a_bombarrows$2"));
                }

                if (gruhshafile.exists("a_stoneblockarrows$1") && captainsfile.exists("a_blockarrows$1")) {
                    gruhshafile.add_s32("a_stoneblockarrows$1", captainsfile.read_s32("a_blockarrows$1"));
                }
                if (gruhshafile.exists("a_stoneblockarrows$2") && captainsfile.exists("a_blockarrows$2")) {
                    gruhshafile.add_s32("a_stoneblockarrows$2", captainsfile.read_s32("a_blockarrows$2"));
                }

                // kfc
                if (gruhshafile.exists("kfc_beer$1") && captainsfile.exists("kfc_beer$1")) {
                    gruhshafile.add_s32("kfc_beer$1", captainsfile.read_s32("kfc_beer$1"));
                }
                if (gruhshafile.exists("kfc_beer$2") && captainsfile.exists("kfc_beer$2")) {
                    gruhshafile.add_s32("kfc_beer$2", captainsfile.read_s32("kfc_beer$2"));
                }

                if (gruhshafile.exists("kfc_meal$1") && captainsfile.exists("kfc_meal$1")) {
                    gruhshafile.add_s32("kfc_meal$1", captainsfile.read_s32("kfc_meal$1"));
                }
                if (gruhshafile.exists("kfc_meal$2") && captainsfile.exists("kfc_meal$2")) {
                    gruhshafile.add_s32("kfc_meal$2", captainsfile.read_s32("kfc_meal$2"));
                }

                if (gruhshafile.exists("kfc_egg$1") && captainsfile.exists("kfc_chicken$1")) {
                    gruhshafile.add_s32("kfc_egg$1", captainsfile.read_s32("kfc_chicken$1"));
                }
                if (gruhshafile.exists("kfc_egg$2") && captainsfile.exists("kfc_chicken$2")) {
                    gruhshafile.add_s32("kfc_egg$2", captainsfile.read_s32("kfc_chicken$2"));
                }

                if (gruhshafile.exists("kfc_burger$1") && captainsfile.exists("kfc_burger$1")) {
                    gruhshafile.add_s32("kfc_burger$1", captainsfile.read_s32("kfc_burger$1"));
                }
                if (gruhshafile.exists("kfc_burger$2") && captainsfile.exists("kfc_burger$2")) {
                    gruhshafile.add_s32("kfc_burger$2", captainsfile.read_s32("kfc_burger$2"));
                }

                if (gruhshafile.exists("kfc_sleep$1") && captainsfile.exists("kfc_sleep$1")) {
                    gruhshafile.add_s32("kfc_sleep$1", captainsfile.read_s32("kfc_sleep$1"));
                }
                if (gruhshafile.exists("kfc_sleep$2") && captainsfile.exists("kfc_sleep$2")) {
                    gruhshafile.add_s32("kfc_sleep$2", captainsfile.read_s32("kfc_sleep$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // TAGS
                ///////////////////////////////////
                if (gruhshafile.exists("tag1$1") && captainsfile.exists("ping2$1")) {
                    gruhshafile.add_s32("tag1$1", captainsfile.read_s32("ping2$1"));
                };
                if (gruhshafile.exists("tag1$2") && captainsfile.exists("ping2$2")) {
                    gruhshafile.add_s32("tag1$2", captainsfile.read_s32("ping2$2"));
                }

                if (gruhshafile.exists("tag2$1") && captainsfile.exists("ping3$1")) {
                    gruhshafile.add_s32("tag2$1", captainsfile.read_s32("ping3$1"));
                }
                if (gruhshafile.exists("tag2$2") && captainsfile.exists("ping3$2")) {
                    gruhshafile.add_s32("tag2$2", captainsfile.read_s32("ping3$2"));
                }

                if (gruhshafile.exists("tag3$1") && captainsfile.exists("ping7$1")) {
                    gruhshafile.add_s32("tag3$1", captainsfile.read_s32("ping7$1"));
                }
                if (gruhshafile.exists("tag3$2") && captainsfile.exists("ping7$2")) {
                    gruhshafile.add_s32("tag3$2", captainsfile.read_s32("ping7$2"));
                }

                if (gruhshafile.exists("tag4$1") && captainsfile.exists("ping1$1")) {
                    gruhshafile.add_s32("tag4$1", captainsfile.read_s32("ping1$1"));
                }
                if (gruhshafile.exists("tag4$2") && captainsfile.exists("ping1$2")) {
                    gruhshafile.add_s32("tag4$2", captainsfile.read_s32("ping1$2"));
                }

                if (gruhshafile.exists("tag5$1") && captainsfile.exists("ping5$1")) {
                    gruhshafile.add_s32("tag5$1", captainsfile.read_s32("ping5$1"));
                }
                if (gruhshafile.exists("tag5$2") && captainsfile.exists("ping5$2")) {
                    gruhshafile.add_s32("tag5$2", captainsfile.read_s32("ping5$2"));
                }

                if (gruhshafile.exists("tag6$1") && captainsfile.exists("ping6$1")) {
                    gruhshafile.add_s32("tag6$1", captainsfile.read_s32("ping6$1"));
                }
                if (gruhshafile.exists("tag6$2") && captainsfile.exists("ping6$2")) {
                    gruhshafile.add_s32("tag6$2", captainsfile.read_s32("ping6$2"));
                }

                if (gruhshafile.exists("tag7$1") && captainsfile.exists("ping4$1")) {
                    gruhshafile.add_s32("tag7$1", captainsfile.read_s32("ping4$1"));
                }
                if (gruhshafile.exists("tag7$2") && captainsfile.exists("ping4$2")) {
                    gruhshafile.add_s32("tag7$2", captainsfile.read_s32("ping4$2"));
                }

                if (gruhshafile.exists("tag8$1") && captainsfile.exists("ping8$1")) {
                    gruhshafile.add_s32("tag8$1", captainsfile.read_s32("ping8$1"));
                }
                if (gruhshafile.exists("tag8$2") && captainsfile.exists("ping8$2")) {
                    gruhshafile.add_s32("tag8$2", captainsfile.read_s32("ping8$2"));
                }

                if (gruhshafile.exists("tag_wheel$1") && captainsfile.exists("ping_wheel$1")) {
                    gruhshafile.add_s32("tag_wheel$1", captainsfile.read_s32("ping_wheel$1"));
                }
                if (gruhshafile.exists("tag_wheel$2") && captainsfile.exists("ping_wheel$2")) {
                    gruhshafile.add_s32("tag_wheel$2", captainsfile.read_s32("ping_wheel$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // EMOTES
                ///////////////////////////////////
                if (gruhshafile.exists("emote1$1") && captainsfile.exists("emote1$1")) {
                    gruhshafile.add_s32("emote1$1", captainsfile.read_s32("emote1$1"));
                }
                if (gruhshafile.exists("emote1$2") && captainsfile.exists("emote1$2")) {
                    gruhshafile.add_s32("emote1$2", captainsfile.read_s32("emote1$2"));
                }

                if (gruhshafile.exists("emote2$1") && captainsfile.exists("emote2$1")) {
                    gruhshafile.add_s32("emote2$1", captainsfile.read_s32("emote2$1"));
                }
                if (gruhshafile.exists("emote2$2") && captainsfile.exists("emote2$2")) {
                    gruhshafile.add_s32("emote2$2", captainsfile.read_s32("emote2$2"));
                }

                if (gruhshafile.exists("emote3$1") && captainsfile.exists("emote3$1")) {
                    gruhshafile.add_s32("emote3$1", captainsfile.read_s32("emote3$1"));
                }
                if (gruhshafile.exists("emote3$2") && captainsfile.exists("emote3$2")) {
                    gruhshafile.add_s32("emote3$2", captainsfile.read_s32("emote3$2"));
                }

                if (gruhshafile.exists("emote4$1") && captainsfile.exists("emote4$1")) {
                    gruhshafile.add_s32("emote4$1", captainsfile.read_s32("emote4$1"));
                }
                if (gruhshafile.exists("emote4$2") && captainsfile.exists("emote4$2")) {
                    gruhshafile.add_s32("emote4$2", captainsfile.read_s32("emote4$2"));
                }

                if (gruhshafile.exists("emote5$1") && captainsfile.exists("emote5$1")) {
                    gruhshafile.add_s32("emote5$1", captainsfile.read_s32("emote5$1"));
                }
                if (gruhshafile.exists("emote5$2") && captainsfile.exists("emote5$2")) {
                    gruhshafile.add_s32("emote5$2", captainsfile.read_s32("emote5$2"));
                }

                if (gruhshafile.exists("emote6$1") && captainsfile.exists("emote6$1")) {
                    gruhshafile.add_s32("emote6$1", captainsfile.read_s32("emote6$1"));
                }
                if (gruhshafile.exists("emote6$2") && captainsfile.exists("emote6$2")) {
                    gruhshafile.add_s32("emote6$2", captainsfile.read_s32("emote6$2"));
                }

                if (gruhshafile.exists("emote7$1") && captainsfile.exists("emote7$1")) {
                    gruhshafile.add_s32("emote7$1", captainsfile.read_s32("emote7$1"));
                }
                if (gruhshafile.exists("emote7$2") && captainsfile.exists("emote7$2")) {
                    gruhshafile.add_s32("emote7$2", captainsfile.read_s32("emote7$2"));
                }

                if (gruhshafile.exists("emote8$1") && captainsfile.exists("emote8$1")) {
                    gruhshafile.add_s32("emote8$1", captainsfile.read_s32("emote8$1"));
                }
                if (gruhshafile.exists("emote8$2") && captainsfile.exists("emote8$2")) {
                    gruhshafile.add_s32("emote8$2", captainsfile.read_s32("emote8$2"));
                }

                if (gruhshafile.exists("emote9$1") && captainsfile.exists("emote9$1")) {
                    gruhshafile.add_s32("emote9$1", captainsfile.read_s32("emote9$1"));
                }
                if (gruhshafile.exists("emote9$2") && captainsfile.exists("emote9$2")) {
                    gruhshafile.add_s32("emote9$2", captainsfile.read_s32("emote9$2"));
                }

                if (gruhshafile.exists("emote_wheel_vanilla$1") && captainsfile.exists("emote_wheel$1")) {
                    gruhshafile.add_s32("emote_wheel_vanilla$1", captainsfile.read_s32("emote_wheel$1"));
                }
                if (gruhshafile.exists("emote_wheel_vanilla$2") && captainsfile.exists("emote_wheel$2")) {
                    gruhshafile.add_s32("emote_wheel_vanilla$2", captainsfile.read_s32("emote_wheel$2"));
                }

                if (gruhshafile.exists("emote_wheel_two$1") && captainsfile.exists("emote_wheel_two$1")) {
                    gruhshafile.add_s32("emote_wheel_two$1", captainsfile.read_s32("emote_wheel_two$1"));
                }
                if (gruhshafile.exists("emote_wheel_two$2") && captainsfile.exists("emote_wheel_two$2")) {
                    gruhshafile.add_s32("emote_wheel_two$2", captainsfile.read_s32("emote_wheel_two$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // BLOCKS
                ///////////////////////////////////
                if (gruhshafile.exists("stone_block$1") && captainsfile.exists("stone_block$1")) {
                    gruhshafile.add_s32("stone_block$1", captainsfile.read_s32("stone_block$1"));
                }
                if (gruhshafile.exists("stone_block$2") && captainsfile.exists("stone_block$2")) {
                    gruhshafile.add_s32("stone_block$2", captainsfile.read_s32("stone_block$2"));
                }

                if (gruhshafile.exists("stone_backwall$1") && captainsfile.exists("stone_backwall$1")) {
                    gruhshafile.add_s32("stone_backwall$1", captainsfile.read_s32("stone_backwall$1"));
                }
                if (gruhshafile.exists("stone_backwall$2") && captainsfile.exists("stone_backwall$2")) {
                    gruhshafile.add_s32("stone_backwall$2", captainsfile.read_s32("stone_backwall$2"));
                }

                if (gruhshafile.exists("stone_door$1") && captainsfile.exists("stone_door$1")) {
                    gruhshafile.add_s32("stone_door$1", captainsfile.read_s32("stone_door$1"));
                }
                if (gruhshafile.exists("stone_door$2") && captainsfile.exists("stone_door$2")) {
                    gruhshafile.add_s32("stone_door$2", captainsfile.read_s32("stone_door$2"));
                }

                if (gruhshafile.exists("wood_block$1") && captainsfile.exists("wood_block$1")) {
                    gruhshafile.add_s32("wood_block$1", captainsfile.read_s32("wood_block$1"));
                }
                if (gruhshafile.exists("wood_block$2") && captainsfile.exists("wood_block$2")) {
                    gruhshafile.add_s32("wood_block$2", captainsfile.read_s32("wood_block$2"));
                }

                if (gruhshafile.exists("wood_backwall$1") && captainsfile.exists("wood_backwall$1")) {
                    gruhshafile.add_s32("wood_backwall$1", captainsfile.read_s32("wood_backwall$1"));
                }
                if (gruhshafile.exists("wood_backwall$2") && captainsfile.exists("wood_backwall$2")) {
                    gruhshafile.add_s32("wood_backwall$2", captainsfile.read_s32("wood_backwall$2"));
                }

                if (gruhshafile.exists("wood_door$1") && captainsfile.exists("wood_door$1")) {
                    gruhshafile.add_s32("wood_door$1", captainsfile.read_s32("wood_door$1"));
                }
                if (gruhshafile.exists("wood_door$2") && captainsfile.exists("wood_door$2")) {
                    gruhshafile.add_s32("wood_door$2", captainsfile.read_s32("wood_door$2"));
                }

                if (gruhshafile.exists("team_platform$1") && captainsfile.exists("team_platform$1")) {
                    gruhshafile.add_s32("team_platform$1", captainsfile.read_s32("team_platform$1"));
                }
                if (gruhshafile.exists("team_platform$2") && captainsfile.exists("team_platform$2")) {
                    gruhshafile.add_s32("team_platform$2", captainsfile.read_s32("team_platform$2"));
                }

                if (gruhshafile.exists("ladder$1") && captainsfile.exists("ladder$1")) {
                    gruhshafile.add_s32("ladder$1", captainsfile.read_s32("ladder$1"));
                }
                if (gruhshafile.exists("ladder$2") && captainsfile.exists("ladder$2")) {
                    gruhshafile.add_s32("ladder$2", captainsfile.read_s32("ladder$2"));
                }

                if (gruhshafile.exists("platform$1") && captainsfile.exists("platform$1")) {
                    gruhshafile.add_s32("platform$1", captainsfile.read_s32("platform$1"));
                }
                if (gruhshafile.exists("platform$2") && captainsfile.exists("platform$2")) {
                    gruhshafile.add_s32("platform$2", captainsfile.read_s32("platform$2"));
                }

                if (gruhshafile.exists("shop$1") && captainsfile.exists("shop$1")) {
                    gruhshafile.add_s32("shop$1", captainsfile.read_s32("shop$1"));
                }
                if (gruhshafile.exists("shop$2") && captainsfile.exists("shop$2")) {
                    gruhshafile.add_s32("shop$2", captainsfile.read_s32("shop$2"));
                }

                if (gruhshafile.exists("spikes$1") && captainsfile.exists("spikes$1")) {
                    gruhshafile.add_s32("spikes$1", captainsfile.read_s32("spikes$1"));
                }
                if (gruhshafile.exists("spikes$2") && captainsfile.exists("spikes$2")) {
                    gruhshafile.add_s32("spikes$2", captainsfile.read_s32("spikes$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // ACTIONS
                ///////////////////////////////////
                if (gruhshafile.exists("take_out_drill$1") && captainsfile.exists("take_out_drill$1")) {
                    gruhshafile.add_s32("take_out_drill$1", captainsfile.read_s32("take_out_drill$1"));
                }
                if (gruhshafile.exists("take_out_drill$2") && captainsfile.exists("take_out_drill$2")) {
                    gruhshafile.add_s32("take_out_drill$2", captainsfile.read_s32("take_out_drill$2"));
                }

                if (gruhshafile.exists("cancel_charging$1") && captainsfile.exists("cancel_charge$1")) {
                    gruhshafile.add_s32("cancel_charging$1", captainsfile.read_s32("cancel_charge$1"));
                }
                if (gruhshafile.exists("cancel_charging$2") && captainsfile.exists("cancel_charge$2")) {
                    gruhshafile.add_s32("cancel_charging$2", captainsfile.read_s32("cancel_charge$2"));
                }

                if (gruhshafile.exists("mark_team_builder$1") && captainsfile.exists("highlight_builder$1")) {
                    gruhshafile.add_s32("mark_team_builder$1", captainsfile.read_s32("highlight_builder$1"));
                }
                if (gruhshafile.exists("mark_team_builder$2") && captainsfile.exists("highlight_builder$2")) {
                    gruhshafile.add_s32("mark_team_builder$2", captainsfile.read_s32("highlight_builder$2"));
                }

                if (gruhshafile.exists("blob_rotate$1") && captainsfile.exists("rotate_block1")) {
                    gruhshafile.add_s32("blob_rotate$1", captainsfile.read_s32("rotate_block$1"));
                }
                if (gruhshafile.exists("blob_rotate$2") && captainsfile.exists("rotate_block$2")) {
                    gruhshafile.add_s32("blob_rotate$2", captainsfile.read_s32("rotate_block$2"));
                }
                ///////////////////////////////////

                if (!gruhshafile.saveFile(Gruhsha_Bindings + ".cfg")) {
                    print("Failed to save GRUHSHA_playerbindings.cfg");
                } else {
                    print("Successfully saved GRUHSHA_playerbindings.cfg");
                }

                LoadFileBindings();
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Bindings import is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("import_bindings", false);
        }

        // SETTINGS
        if (this.get_bool("import_settings")) {
            if (this.get_bool("loadedsettings")) {
                ResetRuleSettings();

                if (gruhshafile.loadFile(config_dir + Gruhsha_Settings))  {
                    printf("Gruhsha Settings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Settings))  {
                    printf("Captains Settings file exists.");
                }

                if (gruhshafile.exists("pickdrill_knight") && captainsfile.exists("autodrill_knight")) {
                    gruhshafile.add_string("pickdrill_knight", captainsfile.read_string("autodrill_knight"));
                }

                if (gruhshafile.exists("pickdrill_builder") && captainsfile.exists("autodrill_builder")) {
                    gruhshafile.add_string("pickdrill_builder", captainsfile.read_string("autodrill_builder"));
                }

                if (gruhshafile.exists("pickdrill_archer") && captainsfile.exists("autodrill_archer")) {
                    gruhshafile.add_string("pickdrill_archer", captainsfile.read_string("autodrill_archer"));
                }

                if (gruhshafile.exists("nomenubuying") && captainsfile.exists("specialshopbuy")) {
                    gruhshafile.add_string("nomenubuying", captainsfile.read_string("specialshopbuy"));
                }

                if (gruhshafile.exists("nomenubuying_b") && captainsfile.exists("specialshopbuy_b")) {
                    gruhshafile.add_string("nomenubuying_b", captainsfile.read_string("specialshopbuy_b"));
                }

                if (!gruhshafile.saveFile(Gruhsha_Settings + ".cfg")) {
                    print("Failed to save GRUHSHA_customizableplayersettings.cfg");
                } else {
                    print("Successfully saved GRUHSHA_customizableplayersettings.cfg");
                }

                LoadFileSettings();
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Settings import is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("import_settings", false);
        }

        // VISUAL AND SOUND SETTINGS
        if (this.get_bool("import_vsettings")) {
            if (this.get_bool("loadedvsettings")) {
                ResetRuleVSettings();

                if (gruhshafile.loadFile(config_dir + Gruhsha_Visual_Settings))  {
                    printf("Gruhsha Visual Settings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Settings))  {
                    printf("Captains Settings file exists.");
                }

                if (gruhshafile.exists("camera_sway") && captainsfile.exists("camera_sway"))
                {
                    gruhshafile.add_string("camera_sway", captainsfile.read_string("camera_sway"));
                }

                if (gruhshafile.exists("blockbar_hud") && captainsfile.exists("blockbar_hud"))
                {
                    gruhshafile.add_string("blockbar_hud", captainsfile.read_string("blockbar_hud"));
                }

                if (gruhshafile.exists("shownomenupanel") && captainsfile.exists("shownomenu"))
                {
                    gruhshafile.add_string("shownomenupanel", captainsfile.read_string("shownomenu"));
                }

                if (gruhshafile.exists("clusterfuck") && captainsfile.exists("disable_gibs"))
                {
                    if (captainsfile.read_string("disable_gibs") == "yes") {
                        gruhshafile.add_string("clusterfuck", "off");
                    } else if (captainsfile.read_string("disable_gibs") == "no") {
                        gruhshafile.add_string("clusterfuck", "on");
                    }
                }

                if (!gruhshafile.saveFile(Gruhsha_Visual_Settings + ".cfg")) {
                    print("Failed to save GRUHSHA_visualandsoundsettings.cfg");
                } else {
                    print("Successfully saved GRUHSHA_visualandsoundsettings.cfg");
                }

                LoadFileVSettings();
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Visual Settings import is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("import_vsettings", false);
        }

        if (localplayer !is null && localplayer.isMyPlayer()) {
            client_AddToChat("Configuration import is done.", SColor(255, 180, 24, 94));
        }

        this.set_bool("import_from_captains", false);
	}
	////////////////////////////////////////////////


	////////////////////////////////////////////////
	// Export bindings and settings to EU Captains
	if (this.get_bool("export_to_captains")) {
        // BINDINGS
        if (this.get_bool("export_bindings")) {
            if (this.get_bool("loadedbindings")) {
                if (gruhshafile.loadFile(config_dir + Gruhsha_Bindings))  {
                    printf("Gruhsha Bindings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Bindings))  {
                    printf("Captains Bindings file exists.");
                }

                ///////////////////////////////////
                // SHOPS
                ///////////////////////////////////
                // knight shop
                if (gruhshafile.exists("k_bomb$1") && captainsfile.exists("k_bomb$1")) {
                    captainsfile.add_s32("k_bomb$1", gruhshafile.read_s32("k_bomb$1"));
                }
                if (gruhshafile.exists("k_bomb$2") && captainsfile.exists("k_bomb$2")) {
                    captainsfile.add_s32("k_bomb$2", gruhshafile.read_s32("k_bomb$2"));
                }

                if (gruhshafile.exists("k_waterbomb$1") && captainsfile.exists("k_waterbomb$1")) {
                    captainsfile.add_s32("k_waterbomb$1", gruhshafile.read_s32("k_waterbomb$1"));
                }
                if (gruhshafile.exists("k_waterbomb$2") && captainsfile.exists("k_waterbomb$2")) {
                    captainsfile.add_s32("k_waterbomb$2", gruhshafile.read_s32("k_waterbomb$2"));
                }

                if (gruhshafile.exists("k_mine$1") && captainsfile.exists("k_mine$1")) {
                    captainsfile.add_s32("k_mine$1", gruhshafile.read_s32("k_mine$1"));
                }
                if (gruhshafile.exists("k_mine$2") && captainsfile.exists("k_mine$2")) {
                    captainsfile.add_s32("k_mine$2", gruhshafile.read_s32("k_mine$2"));
                }

                if (gruhshafile.exists("k_keg$1") && captainsfile.exists("k_keg$1")) {
                    captainsfile.add_s32("k_keg$1", gruhshafile.read_s32("k_keg$1"));
                }
                if (gruhshafile.exists("k_keg$2") && captainsfile.exists("k_keg$2")) {
                    captainsfile.add_s32("k_keg$2", gruhshafile.read_s32("k_keg$2"));
                }

                if (gruhshafile.exists("k_drill$1") && captainsfile.exists("k_drill$1")) {
                    captainsfile.add_s32("k_drill$1", gruhshafile.read_s32("k_drill$1"));
                }
                if (gruhshafile.exists("k_drill$2") && captainsfile.exists("k_drill$2")) {
                    captainsfile.add_s32("k_drill$2", gruhshafile.read_s32("k_drill$2"));
                }

                if (gruhshafile.exists("k_satchel$1") && captainsfile.exists("k_satchel$1")) {
                    captainsfile.add_s32("k_satchel$1", gruhshafile.read_s32("k_satchel$1"));
                }
                if (gruhshafile.exists("k_satchel$2") && captainsfile.exists("k_satchel$2")) {
                    captainsfile.add_s32("k_satchel$2", gruhshafile.read_s32("k_satchel$2"));
                }

                // builder shop
                if (gruhshafile.exists("b_drill$1") && captainsfile.exists("b_drill$1")) {
                    captainsfile.add_s32("b_drill$1", gruhshafile.read_s32("b_drill$1"));
                }
                if (gruhshafile.exists("b_drill$2") && captainsfile.exists("b_drill$2")) {
                    captainsfile.add_s32("b_drill$2", gruhshafile.read_s32("b_drill$2"));
                }

                if (gruhshafile.exists("b_sponge$1") && captainsfile.exists("b_sponge$1")) {
                    captainsfile.add_s32("b_sponge$1", gruhshafile.read_s32("b_sponge$1"));
                }
                if (gruhshafile.exists("b_sponge$2") && captainsfile.exists("b_sponge$2")) {
                    captainsfile.add_s32("b_sponge$2", gruhshafile.read_s32("b_sponge$2"));
                }

                if (gruhshafile.exists("b_bucketw$1") && captainsfile.exists("b_bucketw$1")) {
                    captainsfile.add_s32("b_bucketw$1", gruhshafile.read_s32("b_bucketw$1"));
                }
                if (gruhshafile.exists("b_bucketw$2") && captainsfile.exists("b_bucketw$2")) {
                    captainsfile.add_s32("b_bucketw$2", gruhshafile.read_s32("b_bucketw$2"));
                }

                if (gruhshafile.exists("b_boulder$1") && captainsfile.exists("b_boulder$1")) {
                    captainsfile.add_s32("b_boulder$1", gruhshafile.read_s32("b_boulder$1"));
                }
                if (gruhshafile.exists("b_boulder$2") && captainsfile.exists("b_boulder$2")) {
                    captainsfile.add_s32("b_boulder$2", gruhshafile.read_s32("b_boulder$2"));
                }

                if (gruhshafile.exists("b_lantern$1") && captainsfile.exists("b_lantern$1")) {
                    captainsfile.add_s32("b_lantern$1", gruhshafile.read_s32("b_lantern$1"));
                }
                if (gruhshafile.exists("b_lantern$2") && captainsfile.exists("b_lantern$2")) {
                    captainsfile.add_s32("b_lantern$2", gruhshafile.read_s32("b_lantern$2"));
                }

                if (gruhshafile.exists("b_bucketn$1") && captainsfile.exists("b_bucketn$1")) {
                    captainsfile.add_s32("b_bucketn$1", gruhshafile.read_s32("b_bucketn$1"));
                }
                if (gruhshafile.exists("b_bucketn$2") && captainsfile.exists("b_bucketn$2")) {
                    captainsfile.add_s32("b_bucketn$2", gruhshafile.read_s32("b_bucketn$2"));
                }

                if (gruhshafile.exists("b_trampoline$1") && captainsfile.exists("b_trampoline$1")) {
                    captainsfile.add_s32("b_trampoline$1", gruhshafile.read_s32("b_trampoline$1"));
                }
                if (gruhshafile.exists("b_trampoline$2") && captainsfile.exists("b_trampoline$2")) {
                    captainsfile.add_s32("b_trampoline$2", gruhshafile.read_s32("b_trampoline$2"));
                }

                if (gruhshafile.exists("b_saw$1") && captainsfile.exists("b_saw$1")) {
                    captainsfile.add_s32("b_saw$1", gruhshafile.read_s32("b_saw$1"));
                }
                if (gruhshafile.exists("b_saw$2") && captainsfile.exists("b_saw$2")) {
                    captainsfile.add_s32("b_saw$2", gruhshafile.read_s32("b_saw$2"));
                }

                if (gruhshafile.exists("b_crate$1") && captainsfile.exists("b_crate$1")) {
                    captainsfile.add_s32("b_crate$1", gruhshafile.read_s32("b_crate$1"));
                }
                if (gruhshafile.exists("b_crate$1") && captainsfile.exists("b_crate2")) {
                    captainsfile.add_s32("b_crate$2", gruhshafile.read_s32("b_crate$2"));
                }

                // archer shop
                if (gruhshafile.exists("a_arrows$1") && captainsfile.exists("a_arrows$1")) {
                    captainsfile.add_s32("a_arrows$1", gruhshafile.read_s32("a_arrows$1"));
                }
                if (gruhshafile.exists("a_arrows$2") && captainsfile.exists("a_arrows$2")) {
                    captainsfile.add_s32("a_arrows$2", gruhshafile.read_s32("a_arrows$2"));
                }

                if (gruhshafile.exists("a_waterarrows$1") && captainsfile.exists("a_waterarrows$1")) {
                    captainsfile.add_s32("a_waterarrows$1", gruhshafile.read_s32("a_waterarrows$1"));
                }
                if (gruhshafile.exists("a_waterarrows$2") && captainsfile.exists("a_waterarrows$2")) {
                    captainsfile.add_s32("a_waterarrows$2", gruhshafile.read_s32("a_waterarrows$2"));
                }

                if (gruhshafile.exists("a_firearrows$1") && captainsfile.exists("a_firearrows$1")) {
                    captainsfile.add_s32("a_firearrows$1", gruhshafile.read_s32("a_firearrows$1"));
                }
                if (gruhshafile.exists("a_firearrows$2") && captainsfile.exists("a_firearrows$2")) {
                    captainsfile.add_s32("a_firearrows$2", gruhshafile.read_s32("a_firearrows$2"));
                }

                if (gruhshafile.exists("a_bombarrows$1") && captainsfile.exists("a_bombarrows$1")) {
                    captainsfile.add_s32("a_bombarrows$1", gruhshafile.read_s32("a_bombarrows$1"));
                }
                if (gruhshafile.exists("a_bombarrows$2") && captainsfile.exists("a_bombarrows$2")) {
                    captainsfile.add_s32("a_bombarrows$2", gruhshafile.read_s32("a_bombarrows$2"));
                }

                if (gruhshafile.exists("a_stoneblockarrows$1") && captainsfile.exists("a_blockarrows$1")) {
                    captainsfile.add_s32("a_blockarrows$1", gruhshafile.read_s32("a_stoneblockarrows$1"));
                }
                if (gruhshafile.exists("a_stoneblockarrows$2") && captainsfile.exists("a_blockarrows$2")) {
                    captainsfile.add_s32("a_blockarrows$2", gruhshafile.read_s32("a_stoneblockarrows$2"));
                }

                // kfc
                if (gruhshafile.exists("kfc_beer$1") && captainsfile.exists("kfc_beer$1")) {
                    captainsfile.add_s32("kfc_beer$1", gruhshafile.read_s32("kfc_beer$1"));
                }
                if (gruhshafile.exists("kfc_beer$2") && captainsfile.exists("kfc_beer$2")) {
                    captainsfile.add_s32("kfc_beer$2", gruhshafile.read_s32("kfc_beer$2"));
                }

                if (gruhshafile.exists("kfc_meal$1") && captainsfile.exists("kfc_meal$1")) {
                    captainsfile.add_s32("kfc_meal$1", gruhshafile.read_s32("kfc_meal$1"));
                }
                if (gruhshafile.exists("kfc_meal$2") && captainsfile.exists("kfc_meal$2")) {
                    captainsfile.add_s32("kfc_meal$2", gruhshafile.read_s32("kfc_meal$2"));
                }

                if (gruhshafile.exists("kfc_egg$1") && captainsfile.exists("kfc_chicken$1")) {
                    captainsfile.add_s32("kfc_chicken$1", gruhshafile.read_s32("kfc_egg$1"));
                }
                if (gruhshafile.exists("kfc_egg$2") && captainsfile.exists("kfc_chicken$2")) {
                    captainsfile.add_s32("kfc_chicken$2", gruhshafile.read_s32("kfc_egg$2"));
                }

                if (gruhshafile.exists("kfc_burger$1") && captainsfile.exists("kfc_burger$1")) {
                    captainsfile.add_s32("kfc_burger$1", gruhshafile.read_s32("kfc_burger$1"));
                }
                if (gruhshafile.exists("kfc_burger$2") && captainsfile.exists("kfc_burger$2")) {
                    captainsfile.add_s32("kfc_burger$2", gruhshafile.read_s32("kfc_burger$2"));
                }

                if (gruhshafile.exists("kfc_sleep$1") && captainsfile.exists("kfc_sleep$1")) {
                    captainsfile.add_s32("kfc_sleep$1", gruhshafile.read_s32("kfc_sleep$1"));
                }
                if (gruhshafile.exists("kfc_sleep$2") && captainsfile.exists("kfc_sleep$2")) {
                    captainsfile.add_s32("kfc_sleep$2", gruhshafile.read_s32("kfc_sleep$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // TAGS
                ///////////////////////////////////
                if (gruhshafile.exists("tag1$1") && captainsfile.exists("ping2$1")) {
                    captainsfile.add_s32("ping2$1", gruhshafile.read_s32("tag1$1"));
                };
                if (gruhshafile.exists("tag1$2") && captainsfile.exists("ping2$2")) {
                    captainsfile.add_s32("ping2$2", gruhshafile.read_s32("tag1$2"));
                }

                if (gruhshafile.exists("tag2$1") && captainsfile.exists("ping3$1")) {
                    captainsfile.add_s32("ping3$1", gruhshafile.read_s32("tag2$1"));
                }
                if (gruhshafile.exists("tag2$2") && captainsfile.exists("ping3$2")) {
                    captainsfile.add_s32("ping3$2", gruhshafile.read_s32("tag2$2"));
                }

                if (gruhshafile.exists("tag3$1") && captainsfile.exists("ping7$1")) {
                    captainsfile.add_s32("ping7$1", gruhshafile.read_s32("tag3$1"));
                }
                if (gruhshafile.exists("tag3$2") && captainsfile.exists("ping7$2")) {
                    captainsfile.add_s32("ping7$2", gruhshafile.read_s32("tag3$2"));
                }

                if (gruhshafile.exists("tag4$1") && captainsfile.exists("ping1$1")) {
                    captainsfile.add_s32("ping1$1", gruhshafile.read_s32("tag4$1"));
                }
                if (gruhshafile.exists("tag4$2") && captainsfile.exists("ping1$2")) {
                    captainsfile.add_s32("ping1$2", gruhshafile.read_s32("tag4$2"));
                }

                if (gruhshafile.exists("tag5$1") && captainsfile.exists("ping5$1")) {
                    captainsfile.add_s32("ping5$1", gruhshafile.read_s32("tag5$1"));
                }
                if (gruhshafile.exists("tag5$2") && captainsfile.exists("ping5$2")) {
                    captainsfile.add_s32("ping5$2", gruhshafile.read_s32("tag5$2"));
                }

                if (gruhshafile.exists("tag6$1") && captainsfile.exists("ping6$1")) {
                    captainsfile.add_s32("ping6$1", gruhshafile.read_s32("tag6$1"));
                }
                if (gruhshafile.exists("tag6$2") && captainsfile.exists("ping6$2")) {
                    captainsfile.add_s32("ping6$2", gruhshafile.read_s32("tag6$2"));
                }

                if (gruhshafile.exists("tag7$1") && captainsfile.exists("ping4$1")) {
                    captainsfile.add_s32("ping4$1", gruhshafile.read_s32("tag7$1"));
                }
                if (gruhshafile.exists("tag7$2") && captainsfile.exists("ping4$2")) {
                    captainsfile.add_s32("ping4$2", gruhshafile.read_s32("tag7$2"));
                }

                if (gruhshafile.exists("tag8$1") && captainsfile.exists("ping8$1")) {
                    captainsfile.add_s32("ping8$1", gruhshafile.read_s32("tag8$1"));
                }
                if (gruhshafile.exists("tag8$2") && captainsfile.exists("ping8$2")) {
                    captainsfile.add_s32("ping8$2", gruhshafile.read_s32("tag8$2"));
                }

                if (gruhshafile.exists("tag_wheel$1") && captainsfile.exists("ping_wheel$1")) {
                    captainsfile.add_s32("ping_wheel$1", gruhshafile.read_s32("tag_wheel$1"));
                }
                if (gruhshafile.exists("tag_wheel$2") && captainsfile.exists("ping_wheel$2")) {
                    captainsfile.add_s32("ping_wheel$2", gruhshafile.read_s32("tag_wheel$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // EMOTES
                ///////////////////////////////////
                if (gruhshafile.exists("emote1$1") && captainsfile.exists("emote1$1")) {
                    captainsfile.add_s32("emote1$1", gruhshafile.read_s32("emote1$1"));
                }
                if (gruhshafile.exists("emote1$2") && captainsfile.exists("emote1$2")) {
                    captainsfile.add_s32("emote1$2", gruhshafile.read_s32("emote1$2"));
                }

                if (gruhshafile.exists("emote2$1") && captainsfile.exists("emote2$1")) {
                    captainsfile.add_s32("emote2$1", gruhshafile.read_s32("emote2$1"));
                }
                if (gruhshafile.exists("emote2$2") && captainsfile.exists("emote2$2")) {
                    captainsfile.add_s32("emote2$2", gruhshafile.read_s32("emote2$2"));
                }

                if (gruhshafile.exists("emote3$1") && captainsfile.exists("emote3$1")) {
                    captainsfile.add_s32("emote3$1", gruhshafile.read_s32("emote3$1"));
                }
                if (gruhshafile.exists("emote3$2") && captainsfile.exists("emote3$2")) {
                    captainsfile.add_s32("emote3$2", gruhshafile.read_s32("emote3$2"));
                }
                ResetRuleSettings();
                if (gruhshafile.exists("emote4$1") && captainsfile.exists("emote4$1")) {
                    captainsfile.add_s32("emote4$1", gruhshafile.read_s32("emote4$1"));
                }
                if (gruhshafile.exists("emote4$2") && captainsfile.exists("emote4$2")) {
                    captainsfile.add_s32("emote4$2", gruhshafile.read_s32("emote4$2"));
                }

                if (gruhshafile.exists("emote5$1") && captainsfile.exists("emote5$1")) {
                    captainsfile.add_s32("emote5$1", gruhshafile.read_s32("emote5$1"));
                }
                if (gruhshafile.exists("emote5$2") && captainsfile.exists("emote5$2")) {
                    captainsfile.add_s32("emote5$2", gruhshafile.read_s32("emote5$2"));
                }

                if (gruhshafile.exists("emote6$1") && captainsfile.exists("emote6$1")) {
                    captainsfile.add_s32("emote6$1", gruhshafile.read_s32("emote6$1"));
                }
                if (gruhshafile.exists("emote6$2") && captainsfile.exists("emote6$2")) {
                    captainsfile.add_s32("emote6$2", gruhshafile.read_s32("emote6$2"));
                }

                if (gruhshafile.exists("emote7$1") && captainsfile.exists("emote7$1")) {
                    captainsfile.add_s32("emote7$1", gruhshafile.read_s32("emote7$1"));
                }
                if (gruhshafile.exists("emote7$2") && captainsfile.exists("emote7$2")) {
                    captainsfile.add_s32("emote7$2", gruhshafile.read_s32("emote7$2"));
                }

                if (gruhshafile.exists("emote8$1") && captainsfile.exists("emote8$1")) {
                    captainsfile.add_s32("emote8$1", gruhshafile.read_s32("emote8$1"));
                }
                if (gruhshafile.exists("emote8$2") && captainsfile.exists("emote8$2")) {
                    captainsfile.add_s32("emote8$2", gruhshafile.read_s32("emote8$2"));
                }

                if (gruhshafile.exists("emote9$1") && captainsfile.exists("emote9$1")) {
                    captainsfile.add_s32("emote9$1", gruhshafile.read_s32("emote9$1"));
                }
                if (gruhshafile.exists("emote9$2") && captainsfile.exists("emote9$2")) {
                    captainsfile.add_s32("emote9$2", gruhshafile.read_s32("emote9$2"));
                }

                if (gruhshafile.exists("emote_wheel_vanilla$1") && captainsfile.exists("emote_wheel$1")) {
                    captainsfile.add_s32("emote_wheel$1", gruhshafile.read_s32("emote_wheel_vanilla$1"));
                }
                if (gruhshafile.exists("emote_wheel_vanilla$2") && captainsfile.exists("emote_wheel$2")) {
                    captainsfile.add_s32("emote_wheel$2", gruhshafile.read_s32("emote_wheel_vanilla$2"));
                }

                if (gruhshafile.exists("emote_wheel_two$1") && captainsfile.exists("emote_wheel_two$1")) {
                    captainsfile.add_s32("emote_wheel_two$1", gruhshafile.read_s32("emote_wheel_two$1"));
                }
                if (gruhshafile.exists("emote_wheel_two$2") && captainsfile.exists("emote_wheel_two$2")) {
                    captainsfile.add_s32("emote_wheel_two$2", gruhshafile.read_s32("emote_wheel_two$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // BLOCKS
                ///////////////////////////////////
                if (gruhshafile.exists("stone_block$1") && captainsfile.exists("stone_block$1")) {
                    captainsfile.add_s32("stone_block$1", gruhshafile.read_s32("stone_block$1"));
                }
                if (gruhshafile.exists("stone_block$2") && captainsfile.exists("stone_block$2")) {
                    captainsfile.add_s32("stone_block$2", gruhshafile.read_s32("stone_block$2"));
                }

                if (gruhshafile.exists("stone_backwall$1") && captainsfile.exists("stone_backwall$1")) {
                    captainsfile.add_s32("stone_backwall$1", gruhshafile.read_s32("stone_backwall$1"));
                }
                if (gruhshafile.exists("stone_backwall$2") && captainsfile.exists("stone_backwall$2")) {
                    captainsfile.add_s32("stone_backwall$2", gruhshafile.read_s32("stone_backwall$2"));
                }

                if (gruhshafile.exists("stone_door$1") && captainsfile.exists("stone_door$1")) {
                    captainsfile.add_s32("stone_door$1", gruhshafile.read_s32("stone_door$1"));
                }
                if (gruhshafile.exists("stone_door$2") && captainsfile.exists("stone_door$2")) {
                    captainsfile.add_s32("stone_door$2", gruhshafile.read_s32("stone_door$2"));
                }

                if (gruhshafile.exists("wood_block$1") && captainsfile.exists("wood_block$1")) {
                    captainsfile.add_s32("wood_block$1", gruhshafile.read_s32("wood_block$1"));
                }
                if (gruhshafile.exists("wood_block$2") && captainsfile.exists("wood_block$2")) {
                    captainsfile.add_s32("wood_block$2", gruhshafile.read_s32("wood_block$2"));
                }

                if (gruhshafile.exists("wood_backwall$1") && captainsfile.exists("wood_backwall$1")) {
                    captainsfile.add_s32("wood_backwall$1", gruhshafile.read_s32("wood_backwall$1"));
                }
                if (gruhshafile.exists("wood_backwall$2") && captainsfile.exists("wood_backwall$2")) {
                    captainsfile.add_s32("wood_backwall$2", gruhshafile.read_s32("wood_backwall$2"));
                }

                if (gruhshafile.exists("wood_door$1") && captainsfile.exists("wood_door$1")) {
                    captainsfile.add_s32("wood_door$1", gruhshafile.read_s32("wood_door$1"));
                }
                if (gruhshafile.exists("wood_door$2") && captainsfile.exists("wood_door$2")) {
                    captainsfile.add_s32("wood_door$2", gruhshafile.read_s32("wood_door$2"));
                }

                if (gruhshafile.exists("team_platform$1") && captainsfile.exists("team_platform$1")) {
                    captainsfile.add_s32("team_platform$1", gruhshafile.read_s32("team_platform$1"));
                }
                if (gruhshafile.exists("team_platform$2") && captainsfile.exists("team_platform$2")) {
                    captainsfile.add_s32("team_platform$2", gruhshafile.read_s32("team_platform$2"));
                }

                if (gruhshafile.exists("ladder$1") && captainsfile.exists("ladder$1")) {
                    captainsfile.add_s32("ladder$1", gruhshafile.read_s32("ladder$1"));
                }
                if (gruhshafile.exists("ladder$2") && captainsfile.exists("ladder$2")) {
                    captainsfile.add_s32("ladder$2", gruhshafile.read_s32("ladder$2"));
                }

                if (gruhshafile.exists("platform$1") && captainsfile.exists("platform$1")) {
                    captainsfile.add_s32("platform$1", gruhshafile.read_s32("platform$1"));
                }
                if (gruhshafile.exists("platform$2") && captainsfile.exists("platform$2")) {
                    captainsfile.add_s32("platform$2", gruhshafile.read_s32("platform$2"));
                }

                if (gruhshafile.exists("shop$1") && captainsfile.exists("shop$1")) {
                    captainsfile.add_s32("shop$1", gruhshafile.read_s32("shop$1"));
                }
                if (gruhshafile.exists("shop$2") && captainsfile.exists("shop$2")) {
                    captainsfile.add_s32("shop$2", gruhshafile.read_s32("shop$2"));
                }

                if (gruhshafile.exists("spikes$1") && captainsfile.exists("spikes$1")) {
                    captainsfile.add_s32("spikes$1", gruhshafile.read_s32("spikes$1"));
                }
                if (gruhshafile.exists("spikes$2") && captainsfile.exists("spikes$2")) {
                    captainsfile.add_s32("spikes$2", gruhshafile.read_s32("spikes$2"));
                }
                ///////////////////////////////////

                ///////////////////////////////////
                // ACTIONS
                ///////////////////////////////////
                if (gruhshafile.exists("take_out_drill$1") && captainsfile.exists("take_out_drill$1")) {
                    captainsfile.add_s32("take_out_drill$1", gruhshafile.read_s32("take_out_drill$1"));
                }
                if (gruhshafile.exists("take_out_drill$2") && captainsfile.exists("take_out_drill$2")) {
                    captainsfile.add_s32("take_out_drill$2", gruhshafile.read_s32("take_out_drill$2"));
                }

                if (gruhshafile.exists("cancel_charging$1") && captainsfile.exists("cancel_charge$1")) {
                    captainsfile.add_s32("cancel_charge$1", gruhshafile.read_s32("cancel_charging$1"));
                }
                if (gruhshafile.exists("cancel_charging$2") && captainsfile.exists("cancel_charge$2")) {
                    captainsfile.add_s32("cancel_charge$2", gruhshafile.read_s32("cancel_charging$2"));
                }

                if (gruhshafile.exists("mark_team_builder$1") && captainsfile.exists("highlight_builder$1")) {
                    captainsfile.add_s32("highlight_builder$1", gruhshafile.read_s32("mark_team_builder$1"));
                }
                if (gruhshafile.exists("mark_team_builder$2") && captainsfile.exists("highlight_builder$2")) {
                    captainsfile.add_s32("highlight_builder$2", gruhshafile.read_s32("mark_team_builder$2"));
                }

                if (gruhshafile.exists("blob_rotate$1") && captainsfile.exists("rotate_block1")) {
                    captainsfile.add_s32("rotate_block$1", gruhshafile.read_s32("blob_rotate$1"));
                }
                if (gruhshafile.exists("blob_rotate$2") && captainsfile.exists("rotate_block$2")) {
                    captainsfile.add_s32("rotate_block$2", gruhshafile.read_s32("blob_rotate$2"));
                }
                ///////////////////////////////////

                if (!captainsfile.saveFile(Captains_Bindings + ".cfg")) {
                    print("Failed to save CAPTAINSBUNNIE_playerbindings.cfg");
                } else {
                    print("Successfully saved CAPTAINSBUNNIE_playerbindings.cfg");
                }
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Bindings export is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("export_bindings", false);
        }

        // SETTINGS
        if (this.get_bool("export_settings")) {
            if (this.get_bool("loadedsettings")) {
                if (gruhshafile.loadFile(config_dir + Gruhsha_Settings))  {
                    printf("Gruhsha Settings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Settings))  {
                    printf("Captains Settings file exists.");
                }

                if (gruhshafile.exists("pickdrill_knight") && captainsfile.exists("autodrill_knight")) {
                    captainsfile.add_string("autodrill_knight", gruhshafile.read_string("pickdrill_knight"));
                }

                if (gruhshafile.exists("pickdrill_builder") && captainsfile.exists("autodrill_builder")) {
                    captainsfile.add_string("autodrill_builder", gruhshafile.read_string("pickdrill_builder"));
                }

                if (gruhshafile.exists("pickdrill_archer") && captainsfile.exists("autodrill_archer")) {
                    captainsfile.add_string("autodrill_archer", gruhshafile.read_string("pickdrill_archer"));
                }

                if (gruhshafile.exists("nomenubuying") && captainsfile.exists("specialshopbuy")) {
                    captainsfile.add_string("specialshopbuy", gruhshafile.read_string("nomenubuying"));
                }

                if (gruhshafile.exists("nomenubuying_b") && captainsfile.exists("specialshopbuy_b")) {
                    captainsfile.add_string("specialshopbuy_b", gruhshafile.read_string("nomenubuying_b"));
                }

                if (!captainsfile.saveFile(Captains_Settings + ".cfg")) {
                    print("Failed to save CAPTAINSBUNNIE_customizableplayersettings.cfg");
                } else {
                    print("Successfully saved CAPTAINSBUNNIE_customizableplayersettings.cfg");
                }
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Settings export is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("export_settings", false);
        }

        // VISUAL AND SOUND SETTINGS
        if (this.get_bool("export_vsettings")) {
            if (this.get_bool("loadedvsettings")) {
                if (gruhshafile.loadFile(config_dir + Gruhsha_Visual_Settings))  {
                    printf("Gruhsha Visual Settings file exists.");
                }

                if (captainsfile.loadFile(config_dir + Captains_Settings))  {
                    printf("Captains Settings file exists.");
                }

                if (gruhshafile.exists("camera_sway") && captainsfile.exists("camera_sway"))
                {
                    captainsfile.add_string("camera_sway", gruhshafile.read_string("camera_sway"));
                    printf("GNIDA " + gruhshafile.read_string("camera_sway"));
                }

                if (gruhshafile.exists("blockbar_hud") && captainsfile.exists("blockbar_hud"))
                {
                    captainsfile.add_string("blockbar_hud", gruhshafile.read_string("blockbar_hud"));
                }

                if (gruhshafile.exists("shownomenupanel") && captainsfile.exists("shownomenu"))
                {
                    captainsfile.add_string("shownomenu", gruhshafile.read_string("shownomenupanel"));
                }

                if (gruhshafile.exists("clusterfuck") && captainsfile.exists("disable_gibs"))
                {
                    if (gruhshafile.read_string("clusterfuck") == "on") {
                        captainsfile.add_string("disable_gibs", "no");
                    } else if (gruhshafile.read_string("clusterfuck") == "off") {
                        captainsfile.add_string("disable_gibs", "yes");
                    }
                }

                if (!captainsfile.saveFile(Captains_Settings + ".cfg")) {
                    print("Failed to save CAPTAINSBUNNIE_customizableplayersettings.cfg");
                } else {
                    print("Successfully saved CAPTAINSBUNNIE_customizableplayersettings.cfg");
                }
            }

            if (localplayer !is null && localplayer.isMyPlayer()) {
                client_AddToChat("Visual Settings export is done.", SColor(255, 180, 24, 94));
            }

            this.set_bool("export_vsettings", false);
        }

        if (localplayer !is null && localplayer.isMyPlayer()) {
            client_AddToChat("Bindings and settings export is done.", SColor(255, 180, 24, 94));
        }

        this.set_bool("export_to_captains", false);
	}
	////////////////////////////////////////////////
}