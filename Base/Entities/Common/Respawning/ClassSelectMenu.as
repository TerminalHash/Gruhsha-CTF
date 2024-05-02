//stuff for building respawn menus

#include "TranslationsSystem.as"

//class for getting everything needed for swapping to a class at a building

shared class PlayerClass
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
};

// amount variables
int P_Archers;
int P_Builders;
int P_Knights;
// initialization limits
int archers_limit;
int builders_limit;


const f32 CLASS_BUTTON_SIZE = 2;

//adding a class to a blobs list of classes

void addPlayerClass(CBlob@ this, string name, string iconName, string configFilename, string description)
{
	if (!this.exists("playerclasses"))
	{
		PlayerClass[] classes;
		this.set("playerclasses", classes);
	}

	PlayerClass p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	this.push("playerclasses", p);
}

//helper for building menus of classes

void addClassesToMenu(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	P_Archers = 0;
	P_Builders = 0;
	P_Knights = 0;

	// calculating amount of players in classes
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		if (getPlayer(i).getScoreboardFrame() == 2 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Archers++;}
		if (getPlayer(i).getScoreboardFrame() == 1 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Builders++;}
		if (getPlayer(i).getScoreboardFrame() == 3 && getLocalPlayer().getTeamNum() == getPlayer(i).getTeamNum()) {P_Knights++;}
	}

	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			CRules@ rules = getRules();
			PlayerClass @pclass = classes[i];

			CBitStream params;
			params.write_u8(i);

			// Limiting classes stuff
			archers_limit = rules.get_u8("archers_limit");
			builders_limit = rules.get_u8("builders_limit");

			bool is_warmup = rules.get_bool("is_warmup");

			CGridButton@ button = menu.AddButton(pclass.iconName, getTranslatedString(pclass.name), this.getCommandID("change class"), Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
	
			if(pclass.configFilename == "archer")
			{
				if (P_Archers < archers_limit)
				{
					button.SetHoverText( "    " + P_Archers + " / " + archers_limit + "\n");
				}
				else if (P_Archers >= archers_limit)
				{
					button.SetHoverText( "    " + Descriptions::totaltext + P_Archers + " / " + archers_limit + "\n");

					button.SetEnabled(false);
				}
			}
			else if (pclass.configFilename == "builder")
			{
				if (P_Builders < builders_limit && !is_warmup)
				{
					button.SetHoverText( "    " + P_Builders + " / " + builders_limit + "\n");
				}
				else if (P_Builders >= builders_limit && !is_warmup)
				{
					button.SetHoverText( "    " + Descriptions::totaltext + P_Builders + " / " + builders_limit + "\n");

					button.SetEnabled(false);
				}
			}

//			button.SetHoverText( pclass.description + "\n");
		}
	}
}

PlayerClass@ getDefaultClass(CBlob@ this)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		return classes[0];
	}
	else
	{
		return null;
	}
}
