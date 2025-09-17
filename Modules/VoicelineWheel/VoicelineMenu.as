#include "WheelMenuCommon.as"
#include "VoicelinesCommon.as"
#include "BindingsCommon.as"

const int GLOBAL_COOLDOWN = 120;
const int TEAM_COOLDOWN = 60;
const bool CAN_REPEAT_TAUNT = true;
const bool CLICK_CATEGORY = false;
const bool SHOW_IN_CHAT = true;

string menu_selected = "VOICELINES";
string last_taunt;
int cooldown_time = 0;

void onInit(CRules@ rules)
{
	rules.addCommandID("play voiceline");
	rules.addCommandID("play voiceline client");

	if (isServer()) return;

	string filename = "VoicelineEntries.cfg";
	string cachefilename = "../Cache/" + filename;
	ConfigFile cfg;

	//attempt to load from cache first
	bool loaded = false;
	if (CFileMatcher(cachefilename).getFirst() == cachefilename && cfg.loadFile(cachefilename))
	{
		loaded = true;
	}
	else if (cfg.loadFile(filename))
	{
		loaded = true;
	}

	if (!loaded)
	{
		return;
	}

	//init main menu
	WheelMenu@ menu = get_wheel_menu(menu_selected);
	menu.option_notice = getTranslatedString("Select category");

	string[] names;
	cfg.readIntoArray_string(names, "VOICELINES");

	if (names.length % 2 != 0)
	{
		error("VoicelineEntries.cfg is not in the form of visible_name; token;");
		return;
	}

	for (uint i = 0; i < names.length; i += 2)
	{
		WheelMenuEntry entry(names[i+1]);
		entry.visible_name = getTranslatedString(names[i]);
		menu.entries.push_back(@entry);

		//init each submenu
		WheelMenu@ submenu = get_wheel_menu(entry.name);
		submenu.option_notice = getTranslatedString("Select phrase");

		string[] more_names;
		cfg.readIntoArray_string(more_names, entry.name);

		if (more_names.length % 2 != 0)
		{
			error("VoicelineEntries.cfg is not in the form of visible_name; token;");
			return;
		}

		for (uint j = 0; j < more_names.length; j += 2)
		{
			WheelMenuEntry subentry(more_names[j+1]);
			subentry.visible_name = getTranslatedString(more_names[j]);
			submenu.entries.push_back(@subentry);
		}
	}
}

void onTick(CRules@ rules)
{
	if (isServer()) return;

	CBlob@ blob = getLocalPlayerBlob();

	if (blob is null)
	{
		set_active_wheel_menu(null);
		return;
	}
	
	Vec2f pos = blob.getPosition();

	WheelMenu@ menu = get_wheel_menu(menu_selected);

	if (cooldown_time > 0) //spam cooldown
	{
		cooldown_time--;

		if (b_KeyJustPressed("voicelinewheel"))
		{
			blob.getSprite().PlaySound("NoAmmo.ogg", 0.5);
		}
	}
	else if (b_KeyPressed("voicelinewheel") && get_active_wheel_menu() is null) //activate taunt menu
	{
		set_active_wheel_menu(@menu);
	}
	else if (b_KeyJustReleased("voicelinewheel") && get_active_wheel_menu() is menu) //exit taunt menu
	{
		if (menu_selected != "VOICELINES")
		{
			WheelMenuEntry@ selected = menu.get_selected();
			if (selected !is null)
			{
				//same taunt spam prevention
				if (CAN_REPEAT_TAUNT || selected.visible_name != last_taunt)
				{
					bool globalTaunt = isGlobalTauntCategory(menu_selected);
					last_taunt = selected.visible_name;
					cooldown_time = globalTaunt ? GLOBAL_COOLDOWN : TEAM_COOLDOWN;

					if (rules.get_string("annoying_voicelines") != "off" || !rules.get_bool(blob.getPlayer().getUsername() + "is_sounds_muted"))
					{
						if (selected.name == "kurwa") {
							int random_kurwa = XORRandom(11) + 1;
							Sound::Play(selected.name + random_kurwa + ".ogg", pos, 5.0f);
						} else if (selected.name == "sosal") {
							int random_sosal = XORRandom(2) + 1;
							Sound::Play(selected.name + random_sosal + ".ogg", pos, 5.0f);
						} else if (selected.name == "tuturu") {
							int random_tuturu = XORRandom(9) + 1;
							Sound::Play(selected.name + random_tuturu + ".ogg", pos, 5.0f);
						} else {
							Sound::Play(selected.name + ".ogg", pos, 5.0f);
						}
					}
					//else
					//{
					//	CBitStream params;
					//	params.write_string(selected.visible_name);
					//	params.write_bool(globalTaunt);
					//	rules.SendCommand(rules.getCommandID("play voiceline"), params, true);
					//}
				}
				else
				{
					blob.getSprite().PlaySound("NoAmmo.ogg", 0.5);
				}
			}
		}

		menu_selected = "VOICELINES";
		set_active_wheel_menu(null);
	}
	else if ( //select category
		get_active_wheel_menu() is menu && menu_selected == "VOICELINES" &&
		(!CLICK_CATEGORY || blob.isKeyJustPressed(key_action1))
	) {
		WheelMenuEntry@ selected = menu.get_selected();
		if (selected !is null)
		{
			menu_selected = selected.name;
			WheelMenu@ submenu = get_wheel_menu(menu_selected);
			set_active_wheel_menu(@submenu);
		}
	}
}
/*
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("play voiceline") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		string taunt;
		if (!params.saferead_string(taunt)) return;

		bool globalTaunt;
		if (!params.saferead_bool(globalTaunt)) return;

		CBitStream bt;
		bt.write_u16(caller.getNetworkID());
		bt.write_string(taunt);
		bt.write_bool(globalTaunt);
		this.SendCommand(this.getCommandID("play voiceline client"), bt);
	}
	else if (cmd == this.getCommandID("play voiceline client") && isClient())
	{
		u16 id;
		if (params.saferead_u16(id)) return;

		string taunt;
		if (!params.saferead_string(taunt)) return;

		bool globalTaunt;
		if (!params.saferead_bool(globalTaunt)) return;

		CBlob@ caller = getBlobByNetworkID(id);

		if (caller is null || !cl_chatbubbles)
		{
			return;
		}

		CPlayer@ player = getLocalPlayer();
		
		Vec2f pos = caller.getPosition();

		//only show team taunts to teammates
		if (globalTaunt || (player !is null && player.getTeamNum() == caller.getTeamNum()))
		{
			Sound::Play(taunt + ".ogg", pos, 5.0f);
		}
	}
}
*/