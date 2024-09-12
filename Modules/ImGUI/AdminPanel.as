// AdminPanel.as
/*
	Interface for some admin commands and iteractions.
*/

#include "ImGUI.as"
#include "ScoreboardCommon.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"

//bool toggle1 = false;
//bool toggle2 = false;

void onInit(CRules@ this) {
    this.set_bool("prototype_menu_open", false);
}

void onTick(CRules@ this) {
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
    Menu::addContextItem(menu, "Admin Panel", getCurrentScriptName(), "void ShowPrototypeMenu()");
}

void ShowPrototypeMenu()
{
    Menu::CloseAllMenus();
    getRules().set_bool("prototype_menu_open", true);
}

void onRender(CRules@ this) {
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

    ImGUI::Begin("Admin Menu", Vec2f(200, 200), Vec2f(500, 740));

    /////////////////////////////////////////////////
    // Match Management section
    /////////////////////////////////////////////////
    ImGUI::Text("Match Management");
	/*toggle1 = ImGUI::Toggle("Sudden Death Mode", toggle1);

    if (toggle1) {
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

    if (ImGUI::Button("Start match")) {
		if (!isServer()) return;

		if (!getRules().isMatchRunning())
		{
			getRules().SetCurrentState(GAME);
			server_AddToChat(getTranslatedString("Game started by an admin"), ConsoleColour::GAME);
		}
		else
		{
			server_AddToChat(getTranslatedString("Game is already in progress"), ConsoleColour::ERROR, player);
		}
    }

    if (ImGUI::Button("Restart match")) {
		if (isServer()) {
			LoadMap(getMap().getMapName());
		}
    }

    if (ImGUI::Button("End match")) {
		if (!isServer()) return;

		if (!getRules().isGameOver())
		{
			getRules().SetCurrentState(GAME_OVER);
			server_AddToChat(getTranslatedString("Game ended by an admin"), ConsoleColour::GAME);
		}
		else
		{
			server_AddToChat(getTranslatedString("Game has already ended"), ConsoleColour::ERROR, player);
		}
    }

    ImGUI::Text(" ");
	if (!this.hasTag("sudden death")) {
        ImGUI::Text("Sudden Death is off.");
	} else {
        ImGUI::Text("Sudden Death is on.");
	}

    if (ImGUI::Button("Toggle Sudden Death Mode")) {
		if (!this.hasTag("sudden death")) {
			this.Tag("sudden death");
			this.Sync("sudden death", true);
		} else {
			this.Untag("sudden death");
			this.Sync("sudden death", true);
		}
    }

    ImGUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Map Management Section
    /////////////////////////////////////////////////
    ImGUI::Text("Map Management");

    if (ImGUI::Button("Load next map")) {
        LoadNextMap();
    }

    /*ImGUI::Text(" ");
    ImGUI::Text("Debug Maps");

    if (ImGUI::Button("Load Bombjump Debug map")) {
        LoadMap("Bombjump_debug");
    }

    if (ImGUI::Button("Load Trampoline Test map")) {
        LoadMap("NewTrampolineTest");
    }

    if (ImGUI::Button("Load Plain Debug map")) {
        LoadMap("PlainDebug");
    }

    if (ImGUI::Button("Load Very Small Plain Debug map")) {
        LoadMap("VerySmallPlain_Debug");
    }*/

    ImGUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Team Management section
    /////////////////////////////////////////////////
    ImGUI::Text("Team Management");

    builder_range = ImGUI::Tuner("Builder Limit", builder_range, 0, 99);
    if (builder_range >= 0) {
        this.set_u8("builders_limit", builder_range);
    }

    archer_range = ImGUI::Tuner("Archer Limit", archer_range, 0, 99);
    if (archer_range >= 0) {
        this.set_u8("archers_limit", archer_range);
    }

    if (ImGUI::Button("Put all players into spectators")) {
        if (isServer()) PutEveryoneInSpec();
    }

    if (ImGUI::Button("Demote Captains")) {
        if (isServer()) DemoteLeaders();
    }

    if (ImGUI::Button("Lock teams")) {
		CRules@ rules = getRules();
		ApprovedTeams@ approved_teams;
		if (!rules.get("approved_teams", @approved_teams)) return;

		bool was_locked = isPickingEnded();

		approved_teams.ClearLists();
		if (!was_locked) {
			approved_teams.FormLists();
			server_AddToChat(Descriptions::lockcomchatloc, SColor(0xff474ac6));
		}
		else
			server_AddToChat(Descriptions::lockcomchatunl, SColor(0xff474ac6));

		approved_teams.PrintMembers();
		rules.set("approved_teams", @approved_teams);
    }

    ImGUI::Text(" ");
    /////////////////////////////////////////////////

    //toggle1 = ImGUI::Toggle("TEST TOGGLE 1", toggle1);
    //toggle2 = ImGUI::Toggle("TEST TOGGLE 2", toggle2);

    ImGUI::Text(" ");

    if (ImGUI::Button("Close menu")) {
        this.set_bool("prototype_menu_open", false);
    }

    ImGUI::End();
}
