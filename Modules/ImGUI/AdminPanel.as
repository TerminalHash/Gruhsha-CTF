// AdminPanel.as
/*
	Interface for some admin commands and iteractions.
*/

#include "ImGUI.as"
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

    ImGUI::Begin("KURWA BOBER", Vec2f(200, 200), Vec2f(600, 780));

    /////////////////////////////////////////////////
    // Match Management section
    /////////////////////////////////////////////////
    ImGUI::Text("Match Management");
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

    ImGUI::Text(" ");
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
    }

    ImGUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Team Management section
    /////////////////////////////////////////////////
    ImGUI::Text("Team Management");

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

    toggle1 = ImGUI::Toggle("TEST TOGGLE 1", toggle1);
    toggle2 = ImGUI::Toggle("TEST TOGGLE 2", toggle2);

    ImGUI::Text(" ");

    if (ImGUI::Button("Close menu")) {
        this.set_bool("prototype_menu_open", false);
    }

    ImGUI::End();
}
