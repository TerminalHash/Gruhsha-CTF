#include "EmotesCommon.as";
#include "BindingsCommon.as"

string[] emoteBinds;

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	CPlayer@ me = getLocalPlayer();
	if (me !is null)
	{
		emoteBinds = readEmoteBindings(me);
	}
}

void onTick(CBlob@ this)
{
	CRules@ rules = getRules();
	if (rules.hasTag("reload emotes"))
	{
		rules.Untag("reload emotes");
		onInit(this);
	}
	
	if (getHUD().hasMenus())
	{
		return;
	}

    if (getGameTime() - this.get_u32("boughtitemx") < 3)
    {
        return;
    }

	CControls@ controls = getControls();

	for (uint i = 0; i < 9; i++)
	{
		if (controls.isKeyJustPressed(KEY_NUMPAD1 + i))
		{
			set_emote(this, emoteBinds[9 + i]);
			break;
		}
	}

	if (controls.ActionKeyPressed(AK_BUILD_MODIFIER))
	{
		return;
	}

	ConfigFile file;

	if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
	{
		string custom_emote_1_bind = "emote1" + "$1";
		string custom_emote_2_bind = "emote2" + "$1";
		string custom_emote_3_bind = "emote3" + "$1";
		string custom_emote_4_bind = "emote4" + "$1";
		string custom_emote_5_bind = "emote5" + "$1";
		string custom_emote_6_bind = "emote6" + "$1";
		string custom_emote_7_bind = "emote7" + "$1";
		string custom_emote_8_bind = "emote8" + "$1";
		string custom_emote_9_bind = "emote9" + "$1";

		if (file.exists(custom_emote_1_bind) && file.read_s32(custom_emote_1_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 1))
			{
				set_emote(this, emoteBinds[0]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_1))
			{
				set_emote(this, emoteBinds[0]);
			}
		}

		if (file.exists(custom_emote_2_bind) && file.read_s32(custom_emote_2_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 2))
			{
				set_emote(this, emoteBinds[1]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_2))
			{
				set_emote(this, emoteBinds[1]);
			}
		}

		if (file.exists(custom_emote_3_bind) && file.read_s32(custom_emote_3_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 3))
			{
				set_emote(this, emoteBinds[2]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_3))
			{
				set_emote(this, emoteBinds[2]);
			}
		}

		if (file.exists(custom_emote_4_bind) && file.read_s32(custom_emote_4_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 4))
			{
				set_emote(this, emoteBinds[3]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_4))
			{
				set_emote(this, emoteBinds[3]);
			}
		}

		if (file.exists(custom_emote_5_bind) && file.read_s32(custom_emote_5_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 5))
			{
				set_emote(this, emoteBinds[4]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_5))
			{
				set_emote(this, emoteBinds[4]);
			}
		}

		if (file.exists(custom_emote_6_bind) && file.read_s32(custom_emote_6_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 6))
			{
				set_emote(this, emoteBinds[5]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_6))
			{
				set_emote(this, emoteBinds[5]);
			}
		}

		if (file.exists(custom_emote_7_bind) && file.read_s32(custom_emote_7_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 7))
			{
				set_emote(this, emoteBinds[6]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_7))
			{
				set_emote(this, emoteBinds[6]);
			}
		}

		if (file.exists(custom_emote_8_bind) && file.read_s32(custom_emote_8_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 8))
			{
				set_emote(this, emoteBinds[7]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_8))
			{
				set_emote(this, emoteBinds[7]);
			}
		}

		if (file.exists(custom_emote_9_bind) && file.read_s32(custom_emote_9_bind) != -1)
		{
			if (b_KeyJustPressed("emote" + 9))
			{
				set_emote(this, emoteBinds[8]);
			}
		}
		else
		{
			if (controls.isKeyJustPressed(KEY_KEY_9))
			{
				set_emote(this, emoteBinds[8]);
			}
		}
	}
	else
	{
		for (uint i = 0; i < 9; i++)
		{
			if (controls.isKeyJustPressed(KEY_KEY_1 + i))
			{
				set_emote(this, emoteBinds[i]);
				break;
			}
		}
	}
}
