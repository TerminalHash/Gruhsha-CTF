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

	for (uint i = 1; i < 10; i++)
	{
		if (b_KeyJustPressed("emote" + i) && emoteBinds.length >= i)
		{
			set_emote(this, emoteBinds[i - 1]);
			break;
		}
	}

	/*ConfigFile file;

	for (uint i = 0; i < 9; i++)
	{
		if (file.loadFile(BINDINGSDIR + BINDINGSFILE))
		{
			string customemotebind = "emote" + i + "$1";

			if (file.exists(customemotebind) && file.read_s32(customemotebind) != -1) // Check custom bind first
			{
				if (b_KeyJustPressed("emote" + i) && emoteBinds.length >= i)
				{
					set_emote(this, emoteBinds[i - 1]);
					break;
				}
			}
			else
			{
				if (controls.isKeyJustPressed(KEY_KEY_1 + i))
				{
					set_emote(this, emoteBinds[i]);
					break;
				}
			}
		}
	}*/
}
