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
	if (!this.get_bool("prototype_menu_open")) return;

    IMGUI::Begin("KURWA BOBER", Vec2f(200, 200), Vec2f(600, 600));
    IMGUI::Text("Match management");
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

	if (!this.hasTag("offi match")) {
        IMGUI::Text("This match is not offi.");
	} else {
        IMGUI::Text("This match is offi.");
	}

    if (IMGUI::Button("Toggle OFFI")) {
    		if (!this.hasTag("offi match")) {
			this.Tag("offi match");
			this.Sync("offi match", true);
		} else {
			this.Untag("offi match");
			this.Sync("offi match", true);
		}

		if (isServer()) {
			if (!this.hasTag("offi match")) {
				server_AddToChat("This match is not offi!", SColor(0xff474ac6));
			} else {
				server_AddToChat("This match is offi!", SColor(0xff474ac6));
			}
		}
    }

    IMGUI::Text(" ");
    IMGUI::Text("Team management");

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

    toggle1 = IMGUI::Toggle("TEST TOGGLE 1", toggle1);

    toggle2 = IMGUI::Toggle("TEST TOGGLE 2", toggle2);

    IMGUI::Text(" ");

    if (IMGUI::Button("Close menu")) {
        this.set_bool("prototype_menu_open", false);
    }

    IMGUI::End();
}
