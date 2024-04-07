#include "TranslationsSystem.as"

string BINDINGSDIR = "../Cache/";
string BINDINGSFILE = "GRUHSHA_playerbindings";
string SETTINGSFILE = "GRUHSHA_customizableplayersettings";

string[] page_texts =
{
	Names::modbindsmenu,
	Names::blocksmenu,
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
		Names::tagwheel,
		Names::emotewheelvanilla,
		Names::emotewheelsecond
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
		Names::drillcommand
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
		"take_out_drill"
	}
};

// Settings
string[][] setting_texts =
{
	{
		Names::buildmode,
		Names::blockbar,
		Names::camerasw,
		Names::bodytilt,
		Names::drillzoneborders,
		Names::annoyingnature
	}
};

string[][] setting_file_names =
{
	{
		"build_mode",
		"blockbar_hud",
		"camera_sway",
		"body_tilting",
		"drillzone_borders",
		"annoying_nature"
	}
};

string[][][] setting_options =
{
	{
		{
			Descriptions::bmoptvan, // 10
			Descriptions::bmoptlag // 20
		},
		{
			Descriptions::blockbaron, // 10
			Descriptions::blockbaroff // 20
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
			Descriptions::universaloff,       // DRILLZONE BORDERS
			Descriptions::universalon
		},
		{
			Descriptions::universaloff,       // BUSHES & LEAFS MUTE
			Descriptions::universalon
		}
	}
};

string[][][] setting_option_names =
{
	{
		{
			"vanilla", // 10
			"lagfriendly" // 20
		},
		{
			"yes", // 10
			"no" // 20
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
			"off",       // DRILLZONE BORDERS
			"on"
		},
		{
			"off",       // BUSHES & LEAFS MUTE
			"on"
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
		print("Failed to save VNR_customizableplayersettings.cfg");
	}
	else
	{
		print("Successfully saved VNR_customizableplayersettings.cfg");
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
