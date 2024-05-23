#include "TranslationsSystem.as"

string BINDINGSDIR = "../Cache/";
string BINDINGSFILE = "GRUHSHA_playerbindings";
string SETTINGSFILE = "GRUHSHA_customizableplayersettings";

string[] page_texts =
{
	Names::modbindsmenu,
	Names::blocksmenu,
	Names::emotemenu,
	Names::actionsmenu,
	Names::settingsmenu
};

string[][] button_texts =
{
	{
		"GO HERE",
		"DIG HERE",
		"ATTACK",
		"DANGER",
		"RETREAT",
		"HELP",
		"KEG",
		"WiT SENCE",
		Names::tagwheel
		//Names::emotewheelvanilla,
		//Names::emotewheelsecond
	},
	{
		Names::stonebl,
		Names::stoneback,
		Names::stonedoor,
		Names::woodbl,
		Names::woodback,
		Names::wooddoor,
		Names::platformt,
		Names::ladder,
		Names::platform,
		Names::shop,
		Names::spikes
	},
	{
		Names::modbindemote + "1",
		Names::modbindemote + "2",
		Names::modbindemote + "3",
		Names::modbindemote + "4",
		Names::modbindemote + "5",
		Names::modbindemote + "6",
		Names::modbindemote + "7",
		Names::modbindemote + "8",
		Names::modbindemote + "9",
		Names::emotewheelvanilla,
		Names::emotewheelsecond
	},
	{
		Names::drillcommand,
		Names::cancelarrowschargingcommand
	}
};

string[][] button_file_names =
{
	{
		"tag1",
		"tag2",
		"tag3",
		"tag4",
		"tag5",
		"tag6",
		"tag7",
		"tag8",
		"tag_wheel",
		"emote_wheel_vanilla",
		"emote_wheel_two"
	},
	{
		"stone_block",
		"stone_backwall",
		"stone_door",
		"wood_block",
		"wood_backwall",
		"wood_door",
		"team_platform",
		"ladder",
		"platform",
		"shop",
		"spikes"
	},
	{
		"emote1",
		"emote2",
		"emote3",
		"emote4",
		"emote5",
		"emote6",
		"emote7",
		"emote8",
		"emote9",
		"emote_wheel_vanilla",
		"emote_wheel_two"
	},
	{
		"take_out_drill",
		"cancel_charging"
	}
};

// Settings
string[][] setting_texts =
{
	{
		//Names::buildmode,           // rip
		Names::blockbar,
		Names::camerasw,
		Names::bodytilt,
		Names::headrotating,
		Names::clusterfuck,
		Names::drillzoneborders,
		Names::annoyingnature,
		Names::annoyingvoicelines,
		Names::annoyingtags,
		Names::customdpsounds,
		Names::switchclasschanginginshop
	}
};

string[][] setting_file_names =
{
	{
		//"build_mode",                 // rip
		"blockbar_hud",
		"camera_sway",
		"body_tilting",
		"head_rotating",
		"clusterfuck",
		"drillzone_borders",
		"annoying_nature",
		"annoying_voicelines",
		"annoying_tags",
		"custom_death_and_pain_sounds",
		"disable_class_change_in_shops"
	}
};

string[][][] setting_options =
{
	{
		//{                              // rip
		//	Descriptions::bmoptvan, // 10
		//	Descriptions::bmoptlag // 20
		//},
		{
			Descriptions::universalno, // 10
			Descriptions::universalyes // 20
		},
		{
			"1", // 1
			"2", // 2
			"3", // 3
			"4", // 4
			"5" // 5
		},
		{
			Descriptions::universaloff,       // BODY TILTING
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // HEAD ROTATING
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // CLUSTERFUCK
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // DRILLZONE BORDERS
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // BUSHES & LEAFS MUTE
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // VOICELINES
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // TAGS
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // DEATH AND PAIN
			Descriptions::universalon
		},
		{
			Descriptions::universalno, // 10
			Descriptions::universalyes // 20
		}
	}
};

string[][][] setting_option_names =
{
	{
		//{                              // rip
		//	"vanilla", // 10
		//	"lagfriendly" // 20
		//},
		{
			"no", // 10    BLOCKBAR
			"yes" // 20
		},
		{
			"1", // 1
			"2", // 2
			"3", // 3
			"4", // 4
			"5" // 5
		},
		{
			"off",       // BODY TILTING
			"on"
		},
		{
			"off",       // HEAD ROTATING
			"on"
		},
		{
			"off",       // CLUSTERFUCK
			"on"
		},
		{
			"off",       // DRILLZONE BORDERS
			"on"
		},
		{
			"off",       // BUSHES & LEAFS MUTE
			"on"
		},
		{
			"off",       // VOICELINES
			"on"
		},
		{
			"off",       // TAGS
			"on"
		},
		{
			"off",       // DEATH AND PAIN
			"on"
		},
		{
			"no", // 10    CLASS CHANGING IN SHOPS
			"yes" // 20
		}
	}
};

// bindings[i][g] = h
void UpdateFileBinding(int i, int g, int h, int j)
{
	ConfigFile file;

	if (h == 46)
	{
		h = -1;
	}

	if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
	{
		file.add_s32(button_file_names[i][g] + "$1", h);
		file.add_s32(button_file_names[i][g] + "$2", j);
		printf("Updating bindings file");
	}

	if(!file.saveFile(BINDINGSFILE + ".cfg"))
	{
		print("Failed to save GRUHSHA_playerbindings.cfg");
	}
	else
	{
		print("Successfully saved GRUHSHA_playerbindings.cfg");
	}

	ResetRuleBindings();
	LoadFileBindings();
}

void LoadFileBindings()
{
	getRules().set_bool("loadedbindings", true);

	ConfigFile file;

	if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
	{
		for (int i=0; i<button_texts.length; ++i)
		{
			for (int g=0; g<button_texts[i].length; ++g)
			{
				string file_entry = button_file_names[i][g] + "$1";
				string file_entry_2 = button_file_names[i][g] + "$2";

				if (file.exists(file_entry))
				{
					getRules().set_s32(file_entry, file.read_s32(file_entry));
				}
				if (file.exists(file_entry_2))
				{
					getRules().set_s32(file_entry_2, file.read_s32(file_entry_2));
				}
			}
		}
	}
}

void ResetRuleBindings()
{
	CRules@ rules = getRules();

	for (int i=0; i<button_texts.length; ++i)
	{
		for (int g=0; g<button_texts[i].length; ++g)
		{
			rules.set_s32(button_file_names[i][g] + "$1", -1);
			rules.set_s32(button_file_names[i][g] + "$2", -1);
		}
	}
}

// settings

void UpdateSetting(int i, int g, string h)
{
	ConfigFile file;

	if (file.loadFile(BINDINGSDIR + SETTINGSFILE)) 
	{ 
		file.add_string(setting_file_names[i][g], h);
		printf("Updating settings file");
	}

	if(!file.saveFile(SETTINGSFILE + ".cfg"))
	{	
		print("Failed to save GRUHSHA_customizableplayersettings.cfg");
	}
	else
	{
		print("Successfully saved GRUHSHA_customizableplayersettings.cfg");
	}

	ResetRuleSettings();
	LoadFileSettings();
}

void LoadFileSettings()
{
	getRules().set_bool("loadedsettings", true);
	
	ConfigFile file;

	if (file.loadFile(BINDINGSDIR + SETTINGSFILE)) 
	{ 
		for (int i=0; i<setting_texts.length; ++i)
		{
			for (int g=0; g<setting_texts[i].length; ++g)
			{
				string file_entry = setting_file_names[i][g];

				if (file.exists(file_entry))
				{
					if (file_entry == "camera_sway")
					{
						CCamera@ camera = getCamera();
						if (camera !is null)
						{
							camera.posLag = Maths::Max(1.0, f32(parseInt(file.read_string(file_entry))));
						}
					}

					getRules().set_string(file_entry, file.read_string(file_entry));
				}
			}
		}
	}
}

void ResetRuleSettings()
{
	CRules@ rules = getRules();

	for (int i=0; i<setting_texts.length; ++i)
	{
		for (int g=0; g<setting_texts[i].length; ++g)
		{
			rules.set_string(setting_file_names[i][g], "null");
		}
	}
}

bool b_KeyJustPressed(string s)
{
	CRules@ rules = getRules();
	CControls@ controls = getControls();

	if (controls is null) return false;
	if (rules is null) return false;

	if (rules.get_s32(s + "$2") != -1)
	{
		if (controls.isKeyPressed(rules.get_s32(s + "$1")) && controls.isKeyJustPressed(rules.get_s32(s + "$2")))
		{
			rules.set_u32("just_pressed_multi_bind" + rules.get_s32(s + "$2"), getGameTime());
			return true;
		}
	}
	else if (rules.get_s32(s + "$1") != -1)
	{
		if (controls.isKeyJustPressed(rules.get_s32(s + "$1")))
		{
			if (rules.get_u32("just_pressed_multi_bind" + rules.get_s32(s + "$1")) != getGameTime())
			{
				return true;
			}
		}
	}

	return false;
}

bool b_KeyPressed(string s)
{
	CRules@ rules = getRules();
	CControls@ controls = getControls();

	if (controls is null) return false;
	if (rules is null) return false;

	if (rules.get_s32(s + "$2") != -1)
	{
		if (controls.isKeyPressed(rules.get_s32(s + "$1")) && controls.isKeyPressed(rules.get_s32(s + "$2")))
		{
			rules.set_u32("just_pressed_multi_bind" + rules.get_s32(s + "$2"), getGameTime());
			return true;
		}
	}
	else if (rules.get_s32(s + "$1") != -1)
	{
		if (controls.isKeyPressed(rules.get_s32(s + "$1")))
		{
			if (rules.get_u32("just_pressed_multi_bind" + rules.get_s32(s + "$1")) != getGameTime())
			{
				return true;
			}
		}
	}

	return false;
}

bool b_KeyJustReleased(string s)
{
	CRules@ rules = getRules();
	CControls@ controls = getControls();

	if (controls is null) return false;
	if (rules is null) return false;

	if (rules.get_s32(s + "$2") != -1)
	{
		if (controls.isKeyPressed(rules.get_s32(s + "$1")) && controls.isKeyJustReleased(rules.get_s32(s + "$2")))
		{
			return true;
		}
	}
	else if (rules.get_s32(s + "$1") != -1)
	{
		if (controls.isKeyJustReleased(rules.get_s32(s + "$1")))
		{
			return true;
		}
	}

	return false;
}

enum ClickableButtonStates
{
	None = 0,
	Hovered,
	Selected,
	SelectedHovered
};

class ClickableButton
{
	bool use_own_pos;
	SColor m_custom_color;
	// Draw text, if applies
	bool m_center_text;
	string m_text;
	Vec2f m_text_position;
	string m_font;

	string[] bindings;

	// Clickable stuff
	Vec2f m_clickable_origin, m_clickable_size;

	// Bools for sounds and stuff
	bool m_selected, m_hovered;

	// State: none/hovered/selected/s&h
	int m_state;

	// Rules cmd_id
	u16 cmd_id;
	u16 cmd_subid;

	// uhhh
	s32 m_i;
	s32 m_g;

	bool deselect_instantly;
	bool m_clickable;

	ClickableButton()
	{
		this.use_own_pos = false;
		this.m_custom_color = SColor(255, 255, 255, 255);
		this.m_center_text = false;
		this.m_clickable = true;
		this.m_selected = false;
		this.deselect_instantly = false;
		this.bindings.push_back(Descriptions::modbindplaceholder);
		//printf("Init button");
	}

	bool isHovered(Vec2f mouse_pos, Vec2f clickable_origin, Vec2f clickable_size)
	{
		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		if (mouse_pos.x > tl.x && mouse_pos.y > tl.y &&
			 mouse_pos.x < br.x && mouse_pos.y < br.y)
		{
			return true;
		}
		return false;
	}

	void Render(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;
		CControls@ controls = player.getControls();
		if (controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		if (this.use_own_pos)
		{
			clickable_origin = this.m_clickable_origin;
			clickable_size = this.m_clickable_size;
		}

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		Vec2f tl_2 = clickable_origin + Vec2f(clickable_size.x * button_percentage, 0);
		Vec2f br_2 = tl_2 + Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		bool is_hovered = this.isHovered(mouse_pos, tl_2, Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y));

		SColor color = color_white;
		if (m_custom_color != color_white) color = m_custom_color;

		if (m_selected && !is_hovered) color = SColor(255, 100, 255, 100);
		else if (!m_selected && is_hovered) color = SColor(255, 220, 220, 220);
		else if (m_selected && is_hovered) color = SColor(255, 45, 200, 45);

		GUI::DrawText(m_text, tl + Vec2f(10, 10), color_white);
		GUI::DrawPane(tl_2, br_2, color);

		string binding = bindings[0];

		if (getRules().get_s32(button_file_names[m_i][m_g] + "$1") != -1)
		{
			binding = getKeyName(getRules().get_s32(button_file_names[m_i][m_g] + "$1"));

			if (getRules().get_s32(button_file_names[m_i][m_g] + "$2") != -1)
			{
				binding += ("+" + getKeyName(getRules().get_s32(button_file_names[m_i][m_g] + "$2")));
			}
		}

		GUI::DrawTextCentered(binding, tl_2 + Vec2f(clickable_size.x * anti_button_percentage * 0.5, clickable_size.y * 0.5), color_white);

		GUI::DrawLine2D(clickable_origin + Vec2f(-10, clickable_size.y + 3), clickable_origin + Vec2f(clickable_size.x + 10, clickable_size.y + 3), SColor(125, 100, 100, 100));

		GUI::SetFont("hud");
	}

	void Update(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if(player is null) return;
		CControls@ controls = player.getControls();
		if(controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl = clickable_origin + Vec2f(clickable_size.x * button_percentage, 0);
		Vec2f cs = Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mouse_pos, tl, cs))
		{
			m_hovered = true;

			if (this.m_state == ClickableButtonStates::None)
			{
				this.m_state = ClickableButtonStates::Hovered; 
				Sound::Play("select.ogg");
			}
			else if (this.m_state == ClickableButtonStates::Selected)
			{
				this.m_state = ClickableButtonStates::SelectedHovered; 
				Sound::Play("select.ogg");
			}

			// On click
			if (mouseJustReleased && this.m_clickable)
			{
				if (this.m_state == ClickableButtonStates::Selected || this.m_state == ClickableButtonStates::SelectedHovered) this.m_state = ClickableButtonStates::Hovered;
				if (this.m_state == ClickableButtonStates::Hovered || this.m_state == ClickableButtonStates::None) this.m_state = ClickableButtonStates::SelectedHovered;

				Sound::Play("buttonclick.ogg");
				if (!deselect_instantly)
				{
					this.m_selected = !this.m_selected;
				}

				CBitStream params;
				params.write_bool(this.m_selected);
				params.write_u16(cmd_subid);
				params.write_string(getLocalPlayer().getUsername());
				params.ResetBitIndex();
				//getRules().SendCommand(cmd_id, params);
				fakeCommand(getRules(), cmd_id, @params);
			}
		}
		else
		{
			m_hovered = false;
			this.m_state = (m_selected ? ClickableButtonStates::Selected : ClickableButtonStates::None);
		}
	}
}

class ClickableButtonFour
{
	bool use_own_pos;
	SColor m_custom_color;
	// Draw text, if applies
	bool m_center_text;
	string m_text;
	Vec2f m_text_position;
	string m_font;

	string[] bindings;

	// Clickable stuff
	Vec2f m_clickable_origin, m_clickable_size;

	// Bools for sounds and stuff
	bool m_selected, m_hovered;

	// State: none/hovered/selected/s&h
	int m_state;

	// Rules cmd_id
	u16 cmd_id;
	u16 cmd_subid;

	// uhhh
	s32 m_i;
	s32 m_g;

	bool deselect_instantly;
	bool m_clickable;

	ClickableButtonFour()
	{
		this.use_own_pos = false;
		this.m_custom_color = SColor(255, 255, 255, 255);
		this.m_center_text = false;
		this.m_clickable = true;
		this.m_selected = false;
		this.deselect_instantly = false;
		this.bindings.push_back("placeholder");
		//printf("Init button");
	}

	bool isHovered(Vec2f mouse_pos, Vec2f clickable_origin, Vec2f clickable_size)
	{
		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		if (mouse_pos.x > tl.x && mouse_pos.y > tl.y &&
			 mouse_pos.x < br.x && mouse_pos.y < br.y)
		{
			return true;
		}
		return false;
	}

	void Render(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;
		CControls@ controls = player.getControls();
		if (controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		if (this.use_own_pos)
		{
			clickable_origin = this.m_clickable_origin;
			clickable_size = this.m_clickable_size;
		}

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl_2 = clickable_origin;
		Vec2f br_2 = tl_2 + Vec2f(clickable_size.x, clickable_size.y);

		bool is_hovered = this.isHovered(mouse_pos, tl_2, Vec2f(clickable_size.x, clickable_size.y));

		SColor color = SColor(255, 250, 0, 0);
		if (is_hovered) color = SColor(255, 200, 0, 0);

		//GUI::DrawText(m_text, tl + Vec2f(10, 10), color_white);
		GUI::DrawPane(tl_2, br_2, color);

		string binding = bindings[0];

		//GUI::DrawTextCentered("X", tl_2 + Vec2f(clickable_size.x * 0.5, clickable_size.y * 0.5), color_white);

		GUI::DrawIcon("close_button.png", tl_2 + Vec2f(clickable_size.x * 0.3, clickable_size.y * 0.3), 0.25);

		GUI::SetFont("hud");
	}

	void Update(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if(player is null) return;
		CControls@ controls = player.getControls();
		if(controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl = clickable_origin;
		Vec2f cs = Vec2f(clickable_size.x, clickable_size.y);

		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mouse_pos, tl, cs))
		{
			m_hovered = true;

			if (this.m_state == ClickableButtonStates::None)
			{
				this.m_state = ClickableButtonStates::Hovered; 
				Sound::Play("select.ogg");
			}
			else if (this.m_state == ClickableButtonStates::Selected)
			{
				this.m_state = ClickableButtonStates::SelectedHovered; 
				Sound::Play("select.ogg");
			}

			// On click
			if (mouseJustReleased && this.m_clickable)
			{
				if (this.m_state == ClickableButtonStates::Selected || this.m_state == ClickableButtonStates::SelectedHovered) this.m_state = ClickableButtonStates::Hovered;
				if (this.m_state == ClickableButtonStates::Hovered || this.m_state == ClickableButtonStates::None) this.m_state = ClickableButtonStates::SelectedHovered;

				Sound::Play("buttonclick.ogg");

				getRules().set_bool("bindings_open", false);

				ResetRuleBindings();
				LoadFileBindings();

				ResetRuleSettings();
				LoadFileSettings();
			}
		}
		else
		{
			m_hovered = false;
			this.m_state = (m_selected ? ClickableButtonStates::Selected : ClickableButtonStates::None);
		}
	}
}


class ClickableButtonThree
{
	bool use_own_pos;
	SColor m_custom_color;
	// Draw text, if applies
	bool m_center_text;
	string m_text;
	Vec2f m_text_position;
	string m_font;

	string[] bindings;

	string[] possible_options;

	// Clickable stuff
	Vec2f m_clickable_origin, m_clickable_size;

	// Bools for sounds and stuff
	bool[] m_selecteds;
	bool[] m_hovereds;

	// State: none/hovered/selected/s&h
	int[] m_state;

	// Rules cmd_id
	u16 cmd_id;
	u16 cmd_subid;

	// uhhh
	s32 m_i;
	s32 m_g;

	bool deselect_instantly;
	bool m_clickable;

	ClickableButtonThree()
	{
		this.use_own_pos = false;
		this.m_custom_color = SColor(255, 255, 255, 255);
		this.m_center_text = false;
		this.m_clickable = true;
		this.deselect_instantly = false;
		this.bindings.push_back(Descriptions::modbindnull);
		//printf("Init button");
	}

	bool isHovered(Vec2f mouse_pos, Vec2f clickable_origin, Vec2f clickable_size)
	{
		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		if (mouse_pos.x > tl.x && mouse_pos.y > tl.y &&
			 mouse_pos.x < br.x && mouse_pos.y < br.y)
		{
			return true;
		}
		return false;
	}

	void Render(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;
		CControls@ controls = player.getControls();
		if (controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		if (this.use_own_pos)
		{
			clickable_origin = this.m_clickable_origin;
			clickable_size = this.m_clickable_size;
		}

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		GUI::DrawText(m_text, tl + Vec2f(10, 10), color_white);

		Vec2f tl_2 = clickable_origin + Vec2f(clickable_size.x * button_percentage, 0);
		Vec2f br_2 = tl_2 + Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		GUI::DrawLine2D(clickable_origin + Vec2f(-10, clickable_size.y + 3), clickable_origin + Vec2f(clickable_size.x + 10, clickable_size.y + 3), SColor(125, 100, 100, 100));

		f32 allbuttonwidth = br_2.x - tl_2.x;

		f32 onebuttonwidth = allbuttonwidth / possible_options.length;

		Vec2f current_tl = tl_2;

		for (int i=0; i<possible_options.length; ++i)
		{
			Vec2f itl = current_tl;
			Vec2f ibr = itl + Vec2f(onebuttonwidth, br_2.y - tl_2.y);

			bool is_hovered = this.isHovered(mouse_pos, itl, Vec2f(ibr - itl));

			SColor color = color_white;
			if (m_custom_color != color_white) color = m_custom_color;

			if (this.m_selecteds[i] && !is_hovered) color = SColor(255, 100, 255, 100);
			else if (!this.m_selecteds[i] && is_hovered) color = SColor(255, 220, 220, 220);
			else if (this.m_selecteds[i] && is_hovered) color = SColor(255, 45, 200, 45);

			GUI::DrawPane(itl, ibr, color);
			GUI::DrawTextCentered(possible_options[i], itl + Vec2f((ibr.x - itl.x) * 0.5, (ibr.y - itl.y) * 0.5), color_white);

			current_tl += Vec2f(onebuttonwidth, 0);
		}
	}

	void Update(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if(player is null) return;
		CControls@ controls = player.getControls();
		if(controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		f32 button_percentage = 0.3;
		f32 anti_button_percentage = 1.0 - button_percentage;

		Vec2f tl = clickable_origin + Vec2f(clickable_size.x * button_percentage, 0);
		Vec2f cs = Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		Vec2f tl_2 = clickable_origin + Vec2f(clickable_size.x * button_percentage, 0);
		Vec2f br_2 = tl_2 + Vec2f(clickable_size.x * anti_button_percentage, clickable_size.y);

		f32 allbuttonwidth = br_2.x - tl_2.x;

		f32 onebuttonwidth = allbuttonwidth / possible_options.length;

		Vec2f current_tl = tl_2;

		for (int i=0; i<possible_options.length; ++i)
		{
			if (getRules().get_string(setting_file_names[this.m_i][this.m_g]) == setting_option_names[this.m_i][this.m_g][i])
			{
				this.m_selecteds[i] = true;
				this.m_state[i] == ClickableButtonStates::Selected;
			}

			Vec2f itl = current_tl;
			Vec2f ibr = itl + Vec2f(onebuttonwidth, br_2.y - tl_2.y);

			bool is_hovered = this.isHovered(mouse_pos, itl, Vec2f(ibr - itl));

			m_hovereds[i] = is_hovered;

			if (is_hovered)
			{
				if (this.m_state[i] == ClickableButtonStates::None)
				{
					this.m_state[i] = ClickableButtonStates::Hovered; 
					Sound::Play("select.ogg");
				}
				else if (this.m_state[i] == ClickableButtonStates::Selected)
				{
					this.m_state[i] = ClickableButtonStates::SelectedHovered; 
					Sound::Play("select.ogg");
				}

				// On click
				if (mouseJustReleased)
				{
					if (this.m_state[i] == ClickableButtonStates::Selected || this.m_state[i] == ClickableButtonStates::SelectedHovered) this.m_state[i] = ClickableButtonStates::Hovered;
					if (this.m_state[i] == ClickableButtonStates::Hovered || this.m_state[i] == ClickableButtonStates::None) this.m_state[i] = ClickableButtonStates::SelectedHovered;

					Sound::Play("buttonclick.ogg");


					this.m_selecteds[i] = true;

					// deselect other buttons
					for (int g=0; g<possible_options.length; ++g)
					{
						if (g != i) this.m_selecteds[g] = false;
					}

					UpdateSetting(this.m_i, this.m_g, setting_option_names[this.m_i][this.m_g][i]);
				}
			}
			else
			{
				this.m_state[i] = (m_selecteds[i] ? ClickableButtonStates::Selected : ClickableButtonStates::None);
			}

			current_tl += Vec2f(onebuttonwidth, 0);
		}
	}
}

class ClickableButtonTwo
{
	bool use_own_pos;
	SColor m_custom_color;
	// Draw text, if applies
	bool m_center_text;
	string m_text;
	Vec2f m_text_position;
	string m_font;

	// Clickable stuff
	Vec2f m_clickable_origin, m_clickable_size;

	// Bools for sounds and stuff
	bool m_selected, m_hovered;

	// State: none/hovered/selected/s&h
	int m_state;

	// Rules cmd_id
	u16 cmd_id;
	u16 cmd_subid;

	bool deselect_instantly;
	bool m_clickable;

	ClickableButtonTwo()
	{
		this.use_own_pos = false;
		this.m_custom_color = SColor(255, 255, 255, 255);
		this.m_center_text = true;
		this.m_clickable = true;
		this.m_selected = false;
		this.deselect_instantly = false;
		//printf("Init button");
	}

	bool isHovered(Vec2f mouse_pos, Vec2f clickable_origin, Vec2f clickable_size)
	{
		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		if (mouse_pos.x > tl.x && mouse_pos.y > tl.y &&
			 mouse_pos.x < br.x && mouse_pos.y < br.y)
		{
			return true;
		}
		return false;
	}

	void Render(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;
		CControls@ controls = player.getControls();
		if (controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		if (this.use_own_pos)
		{
			clickable_origin = this.m_clickable_origin;
			clickable_size = this.m_clickable_size;
		}

		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		bool is_hovered = this.isHovered(mouse_pos, tl, clickable_size);

		SColor color = color_white;
		if (m_custom_color != color_white) color = m_custom_color;

		if (m_selected && !is_hovered) color = SColor(255, 100, 255, 100);
		else if (!m_selected && is_hovered) color = SColor(255, 220, 220, 220);
		else if (m_selected && is_hovered) color = SColor(255, 100, 255, 100);

		GUI::DrawPane(tl, br, color);
		GUI::DrawTextCentered(m_text, tl + Vec2f(clickable_size.x / 2, clickable_size.y / 2), color_white);

		GUI::SetFont("hud");
	}

	void Update(Vec2f clickable_origin = Vec2f_zero, Vec2f clickable_size = Vec2f_zero)
	{
		CPlayer@ player = getLocalPlayer();
		if(player is null) return;
		CControls@ controls = player.getControls();
		if(controls is null) return;
		Vec2f mouse_pos = controls.getMouseScreenPos();

		Vec2f tl = clickable_origin;
		Vec2f br = clickable_origin + clickable_size;

		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mouse_pos, tl, clickable_size))
		{
			m_hovered = true;

			if (this.m_state == ClickableButtonStates::None)
			{
				this.m_state = ClickableButtonStates::Hovered; 
				Sound::Play("select.ogg");
			}
			else if (this.m_state == ClickableButtonStates::Selected)
			{
				//this.m_state = ClickableButtonStates::SelectedHovered; 
				//Sound::Play("select.ogg");
			}

			// On click
			if (mouseJustReleased && this.m_clickable && !this.m_selected)
			{
				if (this.m_state == ClickableButtonStates::Selected || this.m_state == ClickableButtonStates::SelectedHovered) this.m_state = ClickableButtonStates::Hovered;
				if (this.m_state == ClickableButtonStates::Hovered || this.m_state == ClickableButtonStates::None) this.m_state = ClickableButtonStates::SelectedHovered;

				Sound::Play("buttonclick.ogg");

				if (!deselect_instantly)
				{
					this.m_selected = !this.m_selected;
				}

				CBitStream params;
				params.write_bool(this.m_selected);
				params.write_u16(cmd_subid);
				params.write_string(getLocalPlayer().getUsername());
				params.ResetBitIndex();
				//getRules().SendCommand(cmd_id, params);
				fakeCommand(getRules(), cmd_id, @params);
			}
		}
		else
		{
			m_hovered = false;
			this.m_state = (m_selected ? ClickableButtonStates::Selected : ClickableButtonStates::None);
		}
	}
}

u8 magic_number = 4;

class ClickableButtonGUI
{
	Vec2f m_clickable_size;
	Vec2f m_clickable_origin;

	u8 current_page;

	Vec2f button_size;
	Vec2f page_button_size;

	ClickableButtonFour closebutton;
	ClickableButton[][] buttons;
	ClickableButtonThree[][] settings;
	ClickableButtonTwo[] page_buttons;

	ClickableButtonGUI()
	{
		current_page = 1;
		printf("initing gui");
	}

	void Render()
	{
		GUI::DrawFramedPane(m_clickable_origin, m_clickable_origin+m_clickable_size);

		GUI::SetFont("hud");

		GUI::SetFont("big score font");
		GUI::SetFont("menu");

		Vec2f start_offset = Vec2f(50, 540);

		closebutton.Render(m_clickable_origin + Vec2f(1000 - 40, 0), Vec2f(40, 40));

		for (int i=0; i<page_buttons.length; ++i)
		{
			page_buttons[i].Render(m_clickable_origin + start_offset, page_button_size);

			start_offset += Vec2f(page_button_size.x + 35, 0);
		}

		if (current_page < magic_number)
		{
			for (int i=0; i<buttons[current_page].length; ++i)
			{
				buttons[current_page][i].Render(m_clickable_origin + Vec2f(0, 50) + Vec2f((m_clickable_size.x - button_size.x) * 0.5, 0) + Vec2f(0, i * (button_size.y + 6)), button_size);
			}

			CControls@ controls = getControls();
			if (controls !is null)
			{
				if (controls.isKeyPressed(EKEY_CODE::KEY_LMENU) && getRules().get_u32("lmenu_pressed_for") > 25)
				{
					GUI::DrawTextCentered("!!!! THE GAME THINKS YOU'RE CURRENTLY HOLDING [ALT] !!! Press it once to fix", m_clickable_origin + Vec2f(m_clickable_size.x * 0.5, 20), SColor(255, 250, 100, 100));
					GUI::DrawTextCentered("!!!! THE GAME THINKS YOU'RE CURRENTLY HOLDING [ALT] !!! Press it once to fix", m_clickable_origin + Vec2f(m_clickable_size.x * 0.5, 40), SColor(255, 250, 100, 100));
				}
			}

			GUI::DrawTextCentered(Names::pressdelete, m_clickable_origin + Vec2f(m_clickable_size.x * 0.5, m_clickable_size.y - 40), SColor(255, 255, 255, 255));
		}
		else
		{
			for (int i=0; i<settings[magic_number - current_page].length; ++i)
			{
				settings[magic_number - current_page][i].Render(m_clickable_origin + Vec2f(0, 50) + Vec2f((m_clickable_size.x - button_size.x) * 0.5, 0) + Vec2f(0, i * (button_size.y + 6)), button_size);
			}
		}
	}

	void Update()
	{
		f32 screen_width = getDriver().getScreenWidth();
		f32 screen_height = getDriver().getScreenHeight();
		u8 scale = screen_height / 720.0;

		Vec2f start_offset = Vec2f(50, 540);

		closebutton.Update(m_clickable_origin + Vec2f(1000 - 40, 0), Vec2f(40, 40));

		for (int i=0; i<page_buttons.length; ++i)
		{
			page_buttons[i].Update(m_clickable_origin + start_offset, page_button_size);

			start_offset += Vec2f(page_button_size.x + 35, 0);
		}

		if (current_page < magic_number)
		{
			for (int i=0; i<buttons[current_page].length; ++i)
			{
				buttons[current_page][i].Update(m_clickable_origin + Vec2f(0, 50) + Vec2f((m_clickable_size.x - button_size.x) * 0.5, 0) + Vec2f(0, i * (button_size.y + 6)), button_size);
			}
		}
		else
		{
			for (int i=0; i<settings[magic_number - current_page].length; ++i)
			{
				settings[magic_number - current_page][i].Update(m_clickable_origin + Vec2f(0, 50) + Vec2f((m_clickable_size.x - button_size.x) * 0.5, 0) + Vec2f(0, i * (button_size.y + 6)), button_size);
			}
		}
	}
};

string getKeyName(u32 i, bool short=false)
{
	switch (i)
	{
		case EKEY_CODE::KEY_LBUTTON: return "LMB";
		case EKEY_CODE::KEY_RBUTTON: return "RMB";
		case EKEY_CODE::KEY_MBUTTON: return "MIDDLE CLICK";
		case EKEY_CODE::KEY_CANCEL: return "CANCEL";
		case EKEY_CODE::KEY_XBUTTON1: return "KEY_XBUTTON1";
		case EKEY_CODE::KEY_XBUTTON2: return "KEY_XBUTTON2";
		case EKEY_CODE::KEY_BACK: return "BACK";
		case EKEY_CODE::KEY_TAB: return "TAB";
		case EKEY_CODE::KEY_CLEAR: return "CLEAR";
		case EKEY_CODE::KEY_RETURN: return "RETURN";
		case EKEY_CODE::KEY_SHIFT: return "SHIFT";
		case EKEY_CODE::KEY_CONTROL: return (short ? "c" : "CONTROL");
		case EKEY_CODE::KEY_MENU: return "MENU";
		case EKEY_CODE::KEY_PAUSE: return "PAUSE";
		case EKEY_CODE::KEY_CAPITAL: return (short ? "cps" : "CAPS LOCK");
		case EKEY_CODE::KEY_ESCAPE: return "ESC";
		case EKEY_CODE::KEY_SPACE: return short ? "spc" : "SPACE";
		case EKEY_CODE::KEY_PRIOR: return "PRIOR";
		case EKEY_CODE::KEY_NEXT: return "NEXT";
		case EKEY_CODE::KEY_END: return "END";
		case EKEY_CODE::KEY_HOME: return "HOME";
		case EKEY_CODE::KEY_LEFT: return "LEFT";
		case EKEY_CODE::KEY_UP: return "UP";
		case EKEY_CODE::KEY_RIGHT: return "RIGHT";
		case EKEY_CODE::KEY_DOWN: return "DOWN";
		case EKEY_CODE::KEY_SELECT: return "SELECT";
		case EKEY_CODE::KEY_PRINT: return "PRNTSCR";
		case EKEY_CODE::KEY_EXECUT: return "EXECUTE";
		case EKEY_CODE::KEY_INSERT: return "INSERT";
		case EKEY_CODE::KEY_DELETE: return "DEL";
		case EKEY_CODE::KEY_HELP: return "HELP";
		case EKEY_CODE::KEY_KEY_0: return "0";
		case EKEY_CODE::KEY_KEY_1: return "1";
		case EKEY_CODE::KEY_KEY_2: return "2";
		case EKEY_CODE::KEY_KEY_3: return "3";
		case EKEY_CODE::KEY_KEY_4: return "4";
		case EKEY_CODE::KEY_KEY_5: return "5";
		case EKEY_CODE::KEY_KEY_6: return "6";
		case EKEY_CODE::KEY_KEY_7: return "7";
		case EKEY_CODE::KEY_KEY_8: return "8";
		case EKEY_CODE::KEY_KEY_9: return "9";
		case EKEY_CODE::KEY_KEY_A: return "A";
		case EKEY_CODE::KEY_KEY_B: return "B";
		case EKEY_CODE::KEY_KEY_C: return "C";
		case EKEY_CODE::KEY_KEY_D: return "D";
		case EKEY_CODE::KEY_KEY_E: return "E";
		case EKEY_CODE::KEY_KEY_F: return "F";
		case EKEY_CODE::KEY_KEY_G: return "G";
		case EKEY_CODE::KEY_KEY_H: return "H";
		case EKEY_CODE::KEY_KEY_I: return "I";
		case EKEY_CODE::KEY_KEY_J: return "J";
		case EKEY_CODE::KEY_KEY_K: return "K";
		case EKEY_CODE::KEY_KEY_L: return "L";
		case EKEY_CODE::KEY_KEY_M: return "M";
		case EKEY_CODE::KEY_KEY_N: return "N";
		case EKEY_CODE::KEY_KEY_O: return "O";
		case EKEY_CODE::KEY_KEY_P: return "P";
		case EKEY_CODE::KEY_KEY_Q: return "Q";
		case EKEY_CODE::KEY_KEY_R: return "R";
		case EKEY_CODE::KEY_KEY_S: return "S";
		case EKEY_CODE::KEY_KEY_T: return "T";
		case EKEY_CODE::KEY_KEY_U: return "U";
		case EKEY_CODE::KEY_KEY_V: return "V";
		case EKEY_CODE::KEY_KEY_W: return "W";
		case EKEY_CODE::KEY_KEY_X: return "X";
		case EKEY_CODE::KEY_KEY_Y: return "Y";
		case EKEY_CODE::KEY_KEY_Z: return "Z";
		case EKEY_CODE::KEY_LWIN: return "LWIN";
		case EKEY_CODE::KEY_RWIN: return "RWIN";
		case EKEY_CODE::KEY_APPS: return "APPS";
		case EKEY_CODE::KEY_SLEEP: return "SLEEP";
		case EKEY_CODE::KEY_NUMPAD0: return short ? "n0" : "NUMPAD 0";
		case EKEY_CODE::KEY_NUMPAD1: return short ? "n1" : "NUMPAD 1";
		case EKEY_CODE::KEY_NUMPAD2: return short ? "n2" : "NUMPAD 2";
		case EKEY_CODE::KEY_NUMPAD3: return short ? "n3" : "NUMPAD 3";
		case EKEY_CODE::KEY_NUMPAD4: return short ? "n4" : "NUMPAD 4";
		case EKEY_CODE::KEY_NUMPAD5: return short ? "n5" : "NUMPAD 5";
		case EKEY_CODE::KEY_NUMPAD6: return short ? "n6" : "NUMPAD 6";
		case EKEY_CODE::KEY_NUMPAD7: return short ? "n7" : "NUMPAD 7";
		case EKEY_CODE::KEY_NUMPAD8: return short ? "n8" : "NUMPAD 8";
		case EKEY_CODE::KEY_NUMPAD9: return short ? "n9" : "NUMPAD 9";
		case EKEY_CODE::KEY_MULTIPLY: return "MULTIPLY";
		case EKEY_CODE::KEY_ADD: return "ADD";
		case EKEY_CODE::KEY_SEPARATOR: return "SEPARATOR";
		case EKEY_CODE::KEY_SUBTRACT: return "SUBTRACT";
		case EKEY_CODE::KEY_DECIMAL: return "DECIMAL";
		case EKEY_CODE::KEY_DIVIDE: return "DIVIDE";
		case EKEY_CODE::KEY_F1: return "F1";
		case EKEY_CODE::KEY_F2: return "F2";
		case EKEY_CODE::KEY_F3: return "F3";
		case EKEY_CODE::KEY_F4: return "F4";
		case EKEY_CODE::KEY_F5: return "F5";
		case EKEY_CODE::KEY_F6: return "F6";
		case EKEY_CODE::KEY_F7: return "F7";
		case EKEY_CODE::KEY_F8: return "F8";
		case EKEY_CODE::KEY_F9: return "F9";
		case EKEY_CODE::KEY_F10: return "F10";
		case EKEY_CODE::KEY_F11: return "F11";
		case EKEY_CODE::KEY_F12: return "F12";
		case EKEY_CODE::KEY_NUMLOCK: return "NUMLOCK";
		case EKEY_CODE::KEY_SCROLL: return "SCROLL";
		case EKEY_CODE::KEY_LSHIFT: return short ? "s" : "LSHIFT";
		case EKEY_CODE::KEY_RSHIFT: return short ? "s" : "RSHIFT";
		case EKEY_CODE::KEY_LCONTROL: return short ? "c" : "LCONTROL";
		case EKEY_CODE::KEY_RCONTROL: return short ? "c" : "RCONTROL";
		case EKEY_CODE::KEY_LMENU: return short ? "a" : "L ALT";
		case EKEY_CODE::KEY_RMENU: return short ? "a" : "R ALT";
		case EKEY_CODE::KEY_PLUS: return "+";
		case EKEY_CODE::KEY_COMMA: return ",";
		case EKEY_CODE::KEY_MINUS: return "-";
		case EKEY_CODE::KEY_PERIOD: return ".";
		case EKEY_CODE::KEY_PLAY: return "PLAY";
		case EKEY_CODE::MOUSE_SCROLL_UP: return "MOUSE SCROLL UP";
		case EKEY_CODE::MOUSE_SCROLL_DOWN: return "MOUSE SCROLL DOWN";
	}

	if (i == -1)
	{
		return "null";
	}

	return "UNKNOWN";
}

void fakeCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer() && !isClient()) return;

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

ClickableButtonGUI@ BindingGUI;
