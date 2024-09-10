// AdminPanel.as
/*
	Interface for some admin commands and iteractions.
*/

#include "IMGUI.as"
#include "ScoreboardCommon.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"

bool toggle1 = false;
bool toggle2 = false;

void onInit(CRules@ this) {
    this.set_bool("prototype_menu_open", false);
}

void onTick(CRules@ this) {
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
    Menu::addContextItem(menu, "Prototype Menu", getCurrentScriptName(), "void ShowPrototypeMenu()");
}

void ShowPrototypeMenu()
{
    Menu::CloseAllMenus();
    getRules().set_bool("prototype_menu_open", true);
}

void onRender(CRules@ this) {
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;

	// Ordinary mortals not allowed here
	if (!player.isMod()) {
		getRules().set_bool("prototype_menu_open", false);
		return;
	}

	if (!this.get_bool("prototype_menu_open")) return;

    IMGUI::Begin("KURWA BOBER", Vec2f(200, 200), Vec2f(600, 780));

    /////////////////////////////////////////////////
    // Match Management section
    /////////////////////////////////////////////////
    IMGUI::Text("Match Management");
    IMGUI::Text(" ");
	if (!this.hasTag("sudden death")) {
        IMGUI::Text("Sudden Death is off.");
	} else {
        IMGUI::Text("Sudden Death is on.");
	}

    if (IMGUI::Button("Toggle Sudden Death Mode")) {
		if (!this.hasTag("sudden death")) {
			this.Tag("sudden death");
			this.Sync("sudden death", true);
		} else {
			this.Untag("sudden death");
			this.Sync("sudden death", true);
		}
    }

    IMGUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Map Management Section
    /////////////////////////////////////////////////
    IMGUI::Text("Map Management");

    if (IMGUI::Button("Load next map")) {
        LoadNextMap();
    }

    IMGUI::Text(" ");
    IMGUI::Text("Debug Maps");

    if (IMGUI::Button("Load Bombjump Debug map")) {
        LoadMap("Bombjump_debug");
    }

    if (IMGUI::Button("Load Trampoline Test map")) {
        LoadMap("NewTrampolineTest");
    }

    if (IMGUI::Button("Load Plain Debug map")) {
        LoadMap("PlainDebug");
    }

    if (IMGUI::Button("Load Very Small Plain Debug map")) {
        LoadMap("VerySmallPlain_Debug");
    }

    IMGUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Team Management section
    /////////////////////////////////////////////////
    IMGUI::Text("Team Management");

    if (IMGUI::Button("Put all players into spectators")) {
        if (isServer()) PutEveryoneInSpec();
    }

    if (IMGUI::Button("Demote Captains")) {
        if (isServer()) DemoteLeaders();
    }

    if (IMGUI::Button("Lock teams")) {
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

    IMGUI::Text(" ");
    /////////////////////////////////////////////////

    toggle1 = IMGUI::Toggle("TEST TOGGLE 1", toggle1);
    toggle2 = IMGUI::Toggle("TEST TOGGLE 2", toggle2);

    IMGUI::Text(" ");

    if (IMGUI::Button("Close menu")) {
        this.set_bool("prototype_menu_open", false);
    }

    IMGUI::End();
}
