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

    ///////////////////////////////////////
    // STANDART COMPONENTS
    Label@ titleLabel = StandardLabel();
    titleLabel.SetText("Mod Settings");
    titleLabel.SetAlignment(0.5f, 0.5f);

	Label@ closeLabel = StandardLabel();
    closeLabel.SetText("x");
    closeLabel.SetColor(color_black);
    closeLabel.SetAlignment(0.5f, 0.5f);

    Button@ closeButton = StandardButton(ui);
    closeButton.SetMinSize(20, 20);
    closeButton.SetAlignment(1.0f, 0.0f);
    closeButton.AddComponent(closeLabel);
    closeButton.AddEventListener(Event::Click, HideComponentHandler(modSettings));
    ///////////////////////////////////////

    //////////////////////////////////////
    // BINDINGS COMPONENTS
    Label@ bindNameLabel = StandardLabel();
    bindNameLabel.SetText("");
    bindNameLabel.SetStretchRatio(1.0f, 0.0f);
    bindNameLabel.SetAlignment(0.0f, 0.5f);
    bindNameLabel.SetWrap(true);
    bindNameLabel.SetMaxLines(5);
    bindNameLabel.SetMinSize(300, 0);

    Label@ setBindNameLabel = StandardLabel();
    setBindNameLabel.SetText("");
    setBindNameLabel.SetStretchRatio(1.0f, 0.0f);
    setBindNameLabel.SetAlignment(0.0f, 0.5f);
    setBindNameLabel.SetWrap(true);
    setBindNameLabel.SetMaxLines(5);
    setBindNameLabel.SetMinSize(300, 0);

    float[] serverColumnSizes = { 2, 1 };
    Pane@ bindingLists = StandardPane(ui, SColor(255, 150, 150, 255));
    bindingLists.SetStretchRatio(0.5f, 0.5f);
    bindingLists.SetPadding(4, 4);
    bindingLists.SetSpacing(10, 10);
    bindingLists.SetMinSize(180, 40);
    bindingLists.SetFlowDirection(FlowDirection::DownRight);
    bindingLists.SetColumnSizes(serverColumnSizes);
    bindingLists.AddComponent(bindNameLabel);

    Pane@ setBindingLists = StandardPane(ui, SColor(255, 150, 150, 255));
    setBindingLists.SetStretchRatio(0.5f, 0.5f);
    setBindingLists.SetPadding(4, 4);
    setBindingLists.SetSpacing(10, 10);
    setBindingLists.SetFlowDirection(FlowDirection::DownRight);
    setBindingLists.SetColumnSizes(serverColumnSizes);
    setBindingLists.AddComponent(setBindNameLabel);
    
    //////////////////////////////////////

    Pane@ settingsPane = StandardPane(ui, StandardPaneType::Sunken);
    settingsPane.SetStretchRatio(1.0f, 1.0f);
    settingsPane.SetPadding(8, 8);
    settingsPane.SetSpacing(2, 2);
    settingsPane.SetFlowDirection(FlowDirection::DownRight);
    settingsPane.SetColumnSizes(serverColumnSizes);
    settingsPane.AddComponent(bindingLists);
    settingsPane.AddComponent(setBindingLists);

	float[] modSettingsColumnSizes = { 5, 3 };
    float[] modSettingsRowSizes = { 0, 1, 0 };
    modSettings.SetMargin(200, 0);
    modSettings.SetPadding(10, 10);
    modSettings.SetAlignment(0.5f, 0.5f);
    modSettings.SetStretchRatio(1.0f, 0.0f);
    modSettings.SetMinSize(900, 720);
    modSettings.SetMaxSize(900, 720);
    modSettings.AddComponent(closeButton);
    //modSettings.AddComponent(titleLabel);
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
    Menu::addContextItem(menu, "Mod Settings (TEST)", getCurrentScriptName(), "void ShowSettings()");
}

void ShowSettings()
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
            sfile.add_string("body_tilting", "on");
			sfile.add_string("drillzone_borders", "on");
			sfile.add_string("annoying_nature", "on");
			sfile.add_string("annoying_voicelines", "on");
			sfile.add_string("annoying_tags", "on");
			sfile.add_string("disable_class_change_in_shops", "no");

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
/*
class BindingsHandler : EventHandler
{
    private Component@ component;

    BindingsHandler(Component@ component)
    {
        @this.component = component;
    }

    void Handle()
    {
        for (int i = 0; i < button_texts.length; ++i)
        {
            ClickableButton[] bts;

            for (int g = 0; g < button_texts[i].length; ++g)
            {
                ClickableButton button;
                {
                    button.cmd_id = getRules().getCommandID("b buttonclick");
                    button.cmd_subid = binding_index;

                    ++binding_index;

                    button.m_text = button_texts[i][g];
                    button.m_i = i;
                    button.m_g = g;
                    button.m_text_position = button.m_clickable_origin + Vec2f(4, 0);
                }

                bts.push_back(button);
            }

            ui.push_back(bindingLists);
        }
    }
}*/
/*
class SettingsHandler : EventHandler
{
    private Component@ component;

    SettingsHandler(Component@ component)
    {
        @this.component = component;
    }

    void Handle()
    {
        for (int i=0; i<setting_texts.length; ++i)
        {
            ClickableButtonThree[] bts;

            for (int g=0; g<setting_texts[i].length; ++g)
            {
                ClickableButtonThree button;
                {
                    //button.m_clickable_origin = center + Vec2f(5, i * 40);
                    //button.m_clickable_size = Vec2f(200, 40);

                    button.cmd_id = getRules().getCommandID("s buttonclick");
                    button.cmd_subid = setting_index;

                    ++setting_index;

                    button.m_text = setting_texts[i][g];
                    button.m_i = i;
                    button.m_g = g;
                    button.m_text_position = button.m_clickable_origin + Vec2f(4, 0);

                    for (int h=0; h<setting_options[i][g].length; ++h)
                    {
                        button.m_hovereds.push_back(false);

                        //if (getRules().get_string(setting_file_names[i][g]) == setting_option_names[i][g][h])
                        if (false)
                        {
                            button.m_selecteds.push_back(true);
                            button.m_state.push_back(ClickableButtonStates::Selected);
                        }
                        else
                        {
                            button.m_selecteds.push_back(false);
                            button.m_state.push_back(ClickableButtonStates::None);
                        }


                        button.possible_options.push_back(setting_options[i][g][h]);
                    }
                }

                bts.push_back(button);
            }

            GUI.settings.push_back(bts);
        }
    }
}*/