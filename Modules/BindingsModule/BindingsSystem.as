#include "BindingsCommon.as"
#include "EasyUI.as"

#define CLIENT_ONLY

EasyUI@ ui;
Pane@ modSettings;

void onReload(CRules@ this)
{
	settingsReload();
}

void onInit(CRules@ this)
{
	settingsReload();
    onRestart(this);
}

void onRestart(CRules@ this)
{
    @ui = EasyUI();

    @modSettings = StandardPane();

    Label@ titleLabel = StandardLabel();
    titleLabel.SetText("Mod Settings");
    titleLabel.SetMargin(450, 10);

	Label@ closeLabel = StandardLabel();
    closeLabel.SetText("x");
    closeLabel.SetColor(color_black);
    closeLabel.SetAlignment(0.5f, 0.5f);

    Label@ bindNameLabel = StandardLabel();
    bindNameLabel.SetText("testtesttesttesttest");
    bindNameLabel.SetStretchRatio(1.0f, 0.0f);
    bindNameLabel.SetAlignment(0.0f, 0.5f);
    bindNameLabel.SetWrap(true);
    bindNameLabel.SetMaxLines(1);
    bindNameLabel.SetMinSize(300, 0);

    float[] serverColumnSizes = { 0, 1, 0 };
    Pane@ bindingLists = StandardPane(ui, SColor(255, 150, 150, 255));
    bindingLists.SetStretchRatio(1.0f, 0.0f);
    bindingLists.SetPadding(10, 10);
    bindingLists.SetSpacing(10, 10);
    bindingLists.SetFlowDirection(FlowDirection::DownRight);
    bindingLists.SetColumnSizes(serverColumnSizes);
    bindingLists.AddComponent(bindNameLabel);

    Button@ closeButton = StandardButton(ui);
    closeButton.SetMinSize(20, 20);
    closeButton.SetAlignment(1.0f, 0.0f);
    closeButton.AddComponent(closeLabel);
    closeButton.AddEventListener(Event::Click, HideComponentHandler(modSettings));

    Pane@ settingsPane = StandardPane(ui, StandardPaneType::Sunken);
    settingsPane.SetStretchRatio(1.0f, 1.0f);
    settingsPane.SetPadding(8, 8);
    settingsPane.SetSpacing(2, 2);
    settingsPane.AddComponent(bindingLists);

	float[] modSettingsColumnSizes = { 5, 3 };
    float[] modSettingsRowSizes = { 0, 1, 0 };
    modSettings.SetMargin(200, 0);
    modSettings.SetPadding(10, 10);
    modSettings.SetAlignment(0.5f, 0.5f);
    modSettings.SetStretchRatio(1.0f, 0.0f);
    modSettings.SetMaxSize(900, 720);
    modSettings.AddComponent(closeButton);
    modSettings.AddComponent(titleLabel);
    modSettings.AddComponent(settingsPane);
    modSettings.SetVisible(false);

    ui.AddComponent(modSettings);
}

void onTick(CRules@ this)
{
    ui.Update();

	if (getGameTime() % 30 == 0 && !this.get_bool("loadedbindings"))
	{
		ResetRuleBindings();
		LoadFileBindings();
	} 

	if (getGameTime() % 30 == 0 && !this.get_bool("loadedsettings"))
	{
		ResetRuleSettings();
		LoadFileSettings();
	}
}

void onRender(CRules@ this)
{
	if (ui is null) return;
    ui.Render();

    CControls@ controls = getControls();
    bool shift = controls.isKeyPressed(KEY_LSHIFT);
    bool ctrl = controls.isKeyPressed(KEY_LCONTROL);

    if (ctrl || shift)
    {
        ui.Debug(shift);
    }
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
    Menu::addContextItem(menu, "Mod Settings (TEST)", getCurrentScriptName(), "void ShowModSettings()");
}

void ShowModSettings()
{
    Menu::CloseAllMenus();
    modSettings.SetVisible(true);
}

void settingsReload()
{
	ResetRuleBindings();
	ResetRuleSettings();

	if (isClient())
	{
		ConfigFile file;

		if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
		{
			printf("Bindings file exists.");
		}
		else // default values
		{
			printf("Creating local bindings file for Gruhsha.");
		}

		if(!file.saveFile(BINDINGSFILE + ".cfg"))
		{
			print("Failed to save GRUHSHA_playerbindings.cfg");
		}
		else
		{
			print("Successfully saved GRUHSHA_playerbindings.cfg");
		}

		// settings
		ConfigFile sfile;
		ConfigFile sfile2;

		if (sfile.loadFile(BINDINGSDIR + SETTINGSFILE)) // file exists
		{
			printf("Settings file exists.");
		}
		else // default settings
		{
			sfile.add_string("blockbar_hud", "yes");
			sfile.add_string("build_mode", "vanilla");
			sfile.add_string("camera_sway", "5");

			printf("Creating local settings file with default values for Gruhsha.");
		}

		if(!sfile.saveFile(SETTINGSFILE + ".cfg"))
		{
			print("Failed to save GRUHSHA_customizableplayersettings.cfg");
		}
		else
		{
			print("Successfully saved GRUHSHA_customizableplayersettings.cfg");
		}
	}

	LoadFileBindings();
	LoadFileSettings();
}

class HideComponentHandler : EventHandler
{
    private Component@ component;

    HideComponentHandler(Component@ component)
    {
        @this.component = component;
    }

    void Handle()
    {

        component.SetVisible(false);
    }
}