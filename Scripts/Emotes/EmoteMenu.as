#include "EmotesCommon.as"
#include "WheelMenuCommon.as"
#include "BindingsCommon.as"

#define CLIENT_ONLY

void onInit(CRules@ rules)
{
	ConfigFile@ cfg = loadEmoteConfig();
	LoadEmotes(rules, cfg);

	WheelMenu@ menu = get_wheel_menu("emotes");
	WheelMenu@ rmenu = get_wheel_menu("emotes_grusha");
	menu.option_notice = getTranslatedString("Select emote");

	Emote@[] wheelEmotes = getWheelEmotes(rules, cfg);
	for (uint i = 0; i < wheelEmotes.size(); i++)
	{
		Emote@ emote = wheelEmotes[i];

		IconWheelMenuEntry entry(emote.token);
		entry.visible_name = getTranslatedString(emote.name);
		entry.texture_name = emote.pack.filePath;
		entry.frame = emote.index;
		entry.frame_size = Vec2f(128.0f, 128.0f);
		entry.scale = 0.25f;
		entry.offset = Vec2f(0.0f, -3.0f);
		menu.entries.push_back(@entry);
	}

// HACK
// TODO: Rewrite this shit in future
	Emote@[] wheelEmotesGrusha = getWheelEmotesGrusha(rules, cfg);
	for (uint i = 0; i < wheelEmotesGrusha.size(); i++)
	{
		Emote@ emote = wheelEmotesGrusha[i];

		IconWheelMenuEntry entry(emote.token);
		entry.visible_name = getTranslatedString(emote.name);
		entry.texture_name = emote.pack.filePath;
		entry.frame = emote.index;
		entry.frame_size = Vec2f(128.0f, 128.0f);
		entry.scale = 0.25f;
		entry.offset = Vec2f(0.0f, -3.0f);
		rmenu.entries.push_back(@entry);
	}
}

void onTick(CRules@ rules)
{
	CBlob@ blob = getLocalPlayerBlob();
	CControls@ controls = getControls();

	if (blob is null)
	{
		set_active_wheel_menu(null);
		return;
	}

	WheelMenu@ menu = get_wheel_menu("emotes");


	if (b_KeyJustPressed("emote_wheel"))
	{
		set_active_wheel_menu(@menu);
	}
	else if (b_KeyJustReleased("emote_wheel") && get_active_wheel_menu() is menu)
	{
		WheelMenuEntry@ selected = menu.get_selected();
		set_emote(blob, (selected !is null ? selected.name : ""));
		set_active_wheel_menu(null);
	}

	WheelMenu@ rmenu = get_wheel_menu("emotes_grusha");

	if (b_KeyJustPressed("emote_wheel_two"))
	{
		set_active_wheel_menu(@rmenu);
	}
	else if (b_KeyJustReleased("emote_wheel_two") && get_active_wheel_menu() is rmenu)
	{
		WheelMenuEntry@ selected = rmenu.get_selected();
		set_emote(blob, (selected !is null ? selected.name : ""));
		set_active_wheel_menu(null);
	}
}
