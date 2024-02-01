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
	InitMenu();

	if (isClient())
	{
		ConfigFile file;

		if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
		{
			printf("Bindings file exists.");
		}
		else // default values
		{
			printf("Creating local bindings file for Captains.");
		}

		if(!file.saveFile(BINDINGSFILE + ".cfg"))
		{
			print("Failed to save GRUHSHA_playerbindings.cfg");
		}
		else
		{
			print("Successfully saved GRUHSHA_playerbindings.cfg");
		}
	}

	LoadFileBindings();

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

bool onClientProcessChat( CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player )
{
	if (textIn == "!bindings" && player.isMyPlayer())
	{
		this.set_bool("bindings_open", !this.get_bool("bindings_open"));

		ResetRuleBindings();
		LoadFileBindings();
	}

	return true;
}

ClickableButtonGUI@ BindingGUI;


Vec2f MENU_SIZE = Vec2f(1000, 700);
Vec2f ENTRY_SIZE = Vec2f(900, 30);
Vec2f PAGE_BUTTON_SIZE = Vec2f(150, 60);

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
}
