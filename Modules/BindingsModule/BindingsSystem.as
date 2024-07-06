#define CLIENT_ONLY

#include "BindingsCommon.as"

void onReload(CRules@ this)
{
	onInit(this);
}

void onInit(CRules@ this)
{
	this.addCommandID("b buttonclick");
	this.addCommandID("p buttonclick");
	this.addCommandID("s buttonclick");

	ResetRuleBindings();
	ResetRuleSettings();
	ResetRuleVSettings();

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

		// FUNCTIONAL SETTINGS
		if (sfile.loadFile(BINDINGSDIR + SETTINGSFILE)) // file exists
		{
			printf("Settings file exists.");

			if (!sfile.exists("grapple_with_charging"))
			{
				sfile.add_string("grapple_with_charging", "yes");
			}

			if (!sfile.exists("disable_class_change_in_shops"))
			{
				sfile.add_string("disable_class_change_in_shops", "no");
			}

			if (!sfile.exists("pickdrill_knight"))
			{
				sfile.add_string("pickdrill_knight", "yes");
			}

			if (!sfile.exists("pickdrill_builder"))
			{
				sfile.add_string("pickdrill_builder", "yes");
			}

			if (!sfile.exists("pickdrill_archer"))
			{
				sfile.add_string("pickdrill_archer", "yes");
			}

			if (!sfile.exists("pickbomb_builder"))
			{
				sfile.add_string("pickdrill_builder", "yes");
			}

			if (!sfile.exists("pickbomb_archer"))
			{
				sfile.add_string("pickdrill_archer", "yes");
			}
		}
		else // default settings
		{
			sfile.add_string("grapple_with_charging", "yes");
			sfile.add_string("disable_class_change_in_shops", "no");
			sfile.add_string("pickdrill_knight", "yes");
			sfile.add_string("pickdrill_builder", "yes");
			sfile.add_string("pickdrill_archer", "yes");
			sfile.add_string("pickbomb_builder", "yes");
			sfile.add_string("pickbomb_archer", "yes");

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

		// VISUAL/SOUND SETTINGS
		if (sfile.loadFile(BINDINGSDIR + VSETTINGSFILE)) // file exists
		{
			printf("Settings file exists.");

			if (!sfile.exists("camera_sway"))
			{
				sfile.add_string("camera_sway", "5");
			}

			if (!sfile.exists("blockbar_hud"))
			{
				sfile.add_string("blockbar_hud", "yes");
			}

			if (!sfile.exists("body_tilting"))
			{
				sfile.add_string("body_tilting", "on");
			}

			if (!sfile.exists("head_rotating"))
			{
				sfile.add_string("head_rotating", "on");
			}

			if (!sfile.exists("clusterfuck"))
			{
				sfile.add_string("clusterfuck", "on");
			}

			if (!sfile.exists("drillzone_borders"))
			{
				sfile.add_string("drillzone_borders", "on");
			}

			if (!sfile.exists("annoying_nature"))
			{
				sfile.add_string("annoying_nature", "on");
			}

			if (!sfile.exists("annoying_voicelines"))
			{
				sfile.add_string("annoying_voicelines", "on");
			}

			if (!sfile.exists("annoying_tags"))
			{
				sfile.add_string("annoying_tags", "on");
			}

			if (!sfile.exists("custom_death_and_pain_sounds"))
			{
				sfile.add_string("custom_death_and_pain_sounds", "on");
			}
		}
		else // default settings
		{
			sfile.add_string("blockbar_hud", "yes");
			sfile.add_string("camera_sway", "5");
			sfile.add_string("body_tilting", "on");
			sfile.add_string("head_rotating", "on");
			sfile.add_string("clusterfuck", "on");
			sfile.add_string("drillzone_borders", "on");
			sfile.add_string("annoying_nature", "on");
			sfile.add_string("annoying_voicelines", "on");
			sfile.add_string("annoying_tags", "on");
			sfile.add_string("custom_death_and_pain_sounds", "on");

			printf("Creating local visual and sound settings file with default values for Gruhsha.");
		}

		if(!sfile.saveFile(VSETTINGSFILE + ".cfg"))
		{
			print("Failed to save GRUHSHA_visualandsoundsettings.cfg");
		}
		else
		{
			print("Successfully saved GRUHSHA_visualandsoundsettings.cfg");
		}
	}

	LoadFileBindings();
	LoadFileSettings();
	LoadFileVSettings();

	InitMenu();
}

void onRender(CRules@ this)
{
	if (!this.get_bool("bindings_open"))
	{
		return;
	}

	if (BindingGUI !is null)
	{
		BindingGUI.Render();
	}
}

void onReset(CRules@ this)
{
	pressed_1_time = 0;
}

string last_pressed = "hi";

int key_1 = -1;
int key_2 = -1;

int pressed_1_time = 0;

void onTick(CRules@ this)
{
	CControls@ controls = getControls();

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

	if (getGameTime() % 30 == 0 && !this.get_bool("loadedvsettings"))
	{
		ResetRuleVSettings();
		LoadFileVSettings();
	}

	if (controls !is null)
	{
		if (controls.isKeyPressed(EKEY_CODE::KEY_LMENU))
		{
			this.add_u32("lmenu_pressed_for", 1);
		}
		else
		{
			this.set_u32("lmenu_pressed_for", 0);
		}
	}

	if (!this.get_bool("bindings_open"))
	{
		return;
	}

	if (BindingGUI !is null && controls !is null && isClient())
	{
		if (this.get_bool("BGUI OPEN") == false)
			this.set_bool("BGUI OPEN", true);

		BindingGUI.Update();

		for (int i=0; i<BindingGUI.buttons.length; ++i)
		{
			for (int g=0; g<BindingGUI.buttons[i].length; ++g)
			{
				if (BindingGUI.buttons[i][g].m_selected == true)
				{
					for (int h=0; h<1200; ++h)
					{
						bool iskey = controls.isKeyPressed(h);

						if (h == EKEY_CODE::KEY_ESCAPE)
						{
							//BindingGUI.buttons[i][g].m_selected = false;
						}
						if (h == EKEY_CODE::KEY_LBUTTON)
						{
							continue;
						}

						if (iskey)
						{
							string name = getKeyName(h);
							if (name == "UNKNOWN") name += ("_" + h);

							if (key_1 == -1)
							{
								key_1 = h;
								pressed_1_time = getGameTime();
							}
							else if (key_1 != h && controls.isKeyPressed(key_1))
							{
								key_2 = h;

								//BindingGUI.buttons[i][g].bindings[0] = getKeyName(key_1) + "+" + getKeyName(key_2);

								UpdateFileBinding(i, g, key_1, key_2);

								key_1 = -1;
								key_2 = -1;

								BindingGUI.buttons[i][g].m_selected = false;
								break;
							}
						}
						else if (!controls.isKeyPressed(key_1) && key_1 != -1)
						{
							//BindingGUI.buttons[i][g].bindings[0] = getKeyName(key_1);
							UpdateFileBinding(i, g, key_1, -1);
							key_1 = -1;
							key_2 = -1;
							BindingGUI.buttons[i][g].m_selected = false;
						}
					}
					break;
				}
			}
		}
	}
	else
	{
		if (this.get_bool("BGUI OPEN") == true)
			this.set_bool("BGUI OPEN", false);
	}
}

//ClickableButtonGUI@ BindingGUI;


Vec2f MENU_SIZE = Vec2f(1000, 700);
Vec2f ENTRY_SIZE = Vec2f(900, 30);
Vec2f PAGE_BUTTON_SIZE = Vec2f(150, 40);

void InitMenu()
{
	ClickableButtonGUI GUI = ClickableButtonGUI();

	f32 screen_width = getDriver().getScreenWidth();
	f32 screen_height = getDriver().getScreenHeight();
	Vec2f center = Vec2f(screen_width / 2, screen_height / 2);

	GUI.m_clickable_origin = center - Vec2f(MENU_SIZE.x * 0.5, MENU_SIZE.y * 0.5);
	GUI.m_clickable_size = MENU_SIZE;
	GUI.button_size = ENTRY_SIZE;
	GUI.page_button_size = PAGE_BUTTON_SIZE;
	GUI.current_page = 0;

	u16 binding_index = 0;

	// Close Button
	ClickableButtonFour closebutton;
	{
		closebutton.cmd_id = 69540;
		closebutton.cmd_subid = 6942;

		closebutton.m_text = "X";
		closebutton.m_i = 69;
		closebutton.m_g = 69;
		closebutton.m_text_position = closebutton.m_clickable_origin + Vec2f(4, 0);
	}

	GUI.closebutton = closebutton;

	// Binding Buttons
	for (int i=0; i<button_texts.length; ++i)
	{
		ClickableButton[] bts;

		for (int g=0; g<button_texts[i].length; ++g)
		{
			ClickableButton button;
			{
				//button.m_clickable_origin = center + Vec2f(5, i * 40);
				//button.m_clickable_size = Vec2f(200, 40);

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

		GUI.buttons.push_back(bts);
	}

	u16 setting_index = 0;

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

	u16 vsetting_index = 0;

	for (int i=0; i<vsetting_texts.length; ++i)
	{
		ClickableButtonFive[] bts;

		for (int g=0; g<vsetting_texts[i].length; ++g)
		{
			ClickableButtonFive button;
			{
				//button.m_clickable_origin = center + Vec2f(5, i * 40);
				//button.m_clickable_size = Vec2f(200, 40);

				button.cmd_id = getRules().getCommandID("s buttonclick");
				button.cmd_subid = vsetting_index;

				++setting_index;

				button.m_text = vsetting_texts[i][g];
				button.m_i = i;
				button.m_g = g;
				button.m_text_position = button.m_clickable_origin + Vec2f(4, 0);

				for (int h=0; h<vsetting_options[i][g].length; ++h)
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


					button.possible_options.push_back(vsetting_options[i][g][h]);
				}
			}

			bts.push_back(button);
		}

		GUI.vsettings.push_back(bts);
	}

	// Page Buttons

	for (int i=0; i<page_texts.length; ++i)
	{
		ClickableButtonTwo buttontwo;
		{
			buttontwo.cmd_id = getRules().getCommandID("p buttonclick");
			buttontwo.cmd_subid = i;

			buttontwo.m_text = page_texts[i];
			buttontwo.m_text_position = buttontwo.m_clickable_origin + Vec2f(4, 0);

			if (i == 0) buttontwo.m_selected = true;
		}

		GUI.page_buttons.push_back(buttontwo);
	}

	@BindingGUI = GUI;
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("p buttonclick"))
	{
		return;
		bool selected = params.read_bool();
		u16 id = params.read_u16();
		string username = params.read_string();

		if (getLocalPlayer().getUsername() != username) return;

		for (int i=0; i<BindingGUI.page_buttons.length; ++i)
		{
			if (i != id)
				BindingGUI.page_buttons[i].m_selected = false;
		}

		for (int i=0; i<BindingGUI.buttons.length; ++i)
		{
			for (int g=0; g<BindingGUI.buttons[i].length; ++g)
			{
				BindingGUI.buttons[i][g].m_selected = false;
			}
		}

		BindingGUI.current_page = id;

		//printf("hi, id: " + id);
	}

	if (cmd == this.getCommandID("b buttonclick"))
	{
		bool selected = params.read_bool();
		u16 id = params.read_u16();
		string username = params.read_string();

		if (getLocalPlayer().getUsername() != username) return;

		u16 binding_index = 0;

		for (int i=0; i<BindingGUI.buttons.length; ++i)
		{
			for (int g=0; g<BindingGUI.buttons[i].length; ++g)
			{
				if (binding_index != id)
					BindingGUI.buttons[i][g].m_selected = false;

				binding_index++;
			}
		}

		//printf("hi, id: " + id);
	}

	if (cmd == this.getCommandID("sync drill autopickup") && isServer()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 1) {
			getRules().set_string(player.getUsername() + "pickdrill_knight", autopick);
		} else if (action == 2) {
			getRules().set_string(player.getUsername() + "pickdrill_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickdrill_archer", autopick);
		}

		this.SendCommand(this.getCommandID("sync drill autopickup client"), params);
	} else 	if (cmd == this.getCommandID("sync drill autopickup client") && isClient()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 1) {
			getRules().set_string(player.getUsername() + "pickdrill_knight", autopick);
		} else if (action == 2) {
			getRules().set_string(player.getUsername() + "pickdrill_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickdrill_archer", autopick);
		}

	} else if (cmd == this.getCommandID("sync bomb autopickup") && isServer()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 2) {
			getRules().set_string(player.getUsername() + "pickbomb_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickbomb_archer", autopick);
		}

		this.SendCommand(this.getCommandID("sync bomb autopickup client"), params);
	} else if (cmd == this.getCommandID("sync bomb autopickup client") && isClient()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 2) {
			getRules().set_string(player.getUsername() + "pickbomb_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickbomb_archer", autopick);
		}
	}
}
