// AdminPanel.as
/*
	Interface for some admin commands and iteractions.
*/

#include "KUI.as"
#include "ScoreboardCommon.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"

int tab = 0;
bool toggle1 = false;

void onTick(CRules@ this) {
   /* if (toggle1) {
		if (!this.hasTag("sudden death")) {
			this.Tag("sudden death");
			this.Sync("sudden death", true);
		}
    } else {
        if (this.hasTag("sudden death")) {
			this.Untag("sudden death");
			this.Sync("sudden death", true);
        }
    }*/
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
    #ifdef STAGING
    // show button only for superadmins
    if (getLocalPlayer().isRCON())
        Menu::addContextItem(menu, "Admin Panel", getCurrentScriptName(), "void ShowPrototypeMenu()");
    #endif
}

void ShowPrototypeMenu()
{
    Menu::CloseAllMenus();
    getRules().set_bool("prototype_menu_open", true);
}

void onRender(CRules@ this) {
    // dont allow code to be executed on vanilla,
    // it's extremely broken on vanilla client
    #ifdef STAGING

	CPlayer@ player = getLocalPlayer();
	if (player is null || !player.isMyPlayer()) return;

	// Ordinary mortals not allowed here
	if (!player.isRCON()) {
		getRules().set_bool("prototype_menu_open", false);
		return;
	}

	if (!this.get_bool("prototype_menu_open")) return;

    int builder_range = this.get_u8("builders_limit");
    int archer_range = this.get_u8("archers_limit");

    KUI::Begin();

    KUI::WindowConfig config1();
    //config1.pos = Vec2f(900, 600);
    config1.alignment = KUI::Alignment::CC;
    //config1.closable = true;

    KUI::Window("Admin Menu", Vec2f(500, 500), config1);
    tab = KUI::TabBar(tab, {"Main", "Debug"});
    switch (tab) {
    case 0:
    /////////////////////////////////////////////////
    // Match Management section
    /////////////////////////////////////////////////
        KUI::Text("Match Management");
	    //toggle1 = KUI::Toggle("Sudden Death Mode", toggle1);

        if (KUI::Button("Start match")) {
		    if (!isServer()) return;

		    if (!getRules().isMatchRunning()) {
			    getRules().SetCurrentState(GAME);
			    server_AddToChat(getTranslatedString("Game started by an admin"), ConsoleColour::GAME);
		    } else {
			    server_AddToChat(getTranslatedString("Game is already in progress"), ConsoleColour::ERROR, player);
		    }
        }

        if (KUI::Button("Restart match")) {
		    if (isServer()) {
			    LoadMap(getMap().getMapName());
		    }
        }

        if (KUI::Button("End match")) {
		    if (!isServer()) return;

		    if (!getRules().isGameOver()) {
			    getRules().SetCurrentState(GAME_OVER);
			    server_AddToChat(getTranslatedString("Game ended by an admin"), ConsoleColour::GAME);
		    } else {
			    server_AddToChat(getTranslatedString("Game has already ended"), ConsoleColour::ERROR, player);
		    }
        }

        KUI::Spacing(1);
	    if (!this.hasTag("sudden death")) {
            KUI::Text("Sudden Death is off.");
	    } else {
            KUI::Text("Sudden Death is on.");
	    }

        if (KUI::Button("Toggle Sudden Death Mode")) {
		    if (!this.hasTag("sudden death")) {
			    this.Tag("sudden death");
			    this.Sync("sudden death", true);
		    } else {
			    this.Untag("sudden death");
			    this.Sync("sudden death", true);
		    }
        }

        KUI::Spacing(1);
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Map Management Section
    /////////////////////////////////////////////////
        KUI::Text("Map Management");

        if (KUI::Button("Load next map")) {
            LoadNextMap();
        }

        if (KUI::Button("Open map list (NOT READY)")) {
            //getRules().set_bool("prototype_menu_open", false);
            //getRules().set_bool("map_list_menu", true);
        }

        KUI::Spacing(1);
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Team Management section
    /////////////////////////////////////////////////
        KUI::Text("Team Management");

        builder_range = KUI::Stepper(builder_range, "Builder Limit", 0, 99);
        if (builder_range >= 0) {
            this.set_u8("builders_limit", builder_range);
        }

        archer_range = KUI::Stepper(archer_range, "Archer Limit", 0, 99);
        if (archer_range >= 0) {
            this.set_u8("archers_limit", archer_range);
        }

        if (KUI::Button("Put all players into spectators")) {
            if (isServer()) PutEveryoneInSpec();
        }

        if (KUI::Button("Demote Captains")) {
            if (isServer()) DemoteLeaders();
        }

        if (KUI::Button("Lock teams")) {
		    CRules@ rules = getRules();
		    ApprovedTeams@ approved_teams;

		    if (!rules.get("approved_teams", @approved_teams)) return;

		    bool was_locked = isPickingEnded();

		    approved_teams.ClearLists();
		    if (!was_locked) {
			    approved_teams.FormLists();
			    server_AddToChat(Descriptions::lockcomchatloc, SColor(0xff474ac6));
		    } else {
			    server_AddToChat(Descriptions::lockcomchatunl, SColor(0xff474ac6));
            }

		    approved_teams.PrintMembers();
		    rules.set("approved_teams", @approved_teams);
        }

        KUI::Spacing(1);
    /////////////////////////////////////////////////

        if (KUI::Button("Close menu")) {
            this.set_bool("prototype_menu_open", false);
        }

        break;
    case 1:
        KUI::Text("Debug Maps");

        if (KUI::Button("Load Bombjump Debug map")) {
            LoadMap("Bombjump_debug");
        }

        if (KUI::Button("Load Trampoline Test map")) {
            LoadMap("NewTrampolineTest");
        }

        if (KUI::Button("Load Plain Debug map")) {
            LoadMap("PlainDebug");
        }

        if (KUI::Button("Load Very Small Plain Debug map")) {
            LoadMap("VerySmallPlain_Debug");
        }

        KUI::Spacing(1);   

        if (KUI::Button("Close menu")) {
            this.set_bool("prototype_menu_open", false);
        }

        break;
    }

    KUI::End();
    #endif
}
