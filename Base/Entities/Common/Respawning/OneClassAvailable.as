// OneClassAvailable.as

#include "StandardRespawnCommand.as";
#include "GenericButtonCommon.as";

const string req_class = "required class";

void onInit(CBlob@ this)
{
	this.Tag("change class drop inventory");
	if (!this.exists("class offset"))
		this.set_Vec2f("class offset", Vec2f_zero);

	if (!this.exists("class button radius"))
	{
		CShape@ shape = this.getShape();
		f32 ts = getMap().tilesize;
		if (shape !is null)
		{
			this.set_u8("class button radius", Maths::Max(this.getRadius(), Maths::Max(shape.getWidth(), shape.getHeight()) + ts));
		}
		else
		{
			this.set_u8("class button radius", ts * 2);
		}
	}
	this.addCommandID("change class");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CRules@ rules = getRules();
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

	bool disallow_class_change_on_shops = rules.get_bool("no_class_change_on_shop");

	// HACK: since we need to lock class changing on shops, we do a new boolean vars
	bool is_no_button_for_buildersh = false;
	bool is_no_button_for_archersh = false;

	bool is_warmup = rules.get_bool("is_warmup");

	if (!canSeeButtons(this, caller) || !this.exists(req_class)) return;

	string cfg = this.get_string(req_class);
	if (cfg == "archer" && P_Archers >= rules.get_u8("archers_limit")) {is_no_button_for_archersh = true;}
	if (cfg == "builder" && P_Builders >= rules.get_u8("builders_limit" ) && !is_warmup) {is_no_button_for_buildersh = true;}
//	if (cfg == "knight" && P_Knights >= rules.get_u8("knight_limit")) {disallow_class_change_on_shops = true;}

	if (canChangeClass(this, caller) && caller.getName() != cfg)
	{
		if (caller.getPlayer() is null) return;

		if (getRules().get_string("disable_class_change_in_shops") == "yes") return;
		if (is_no_button_for_archersh == true) return;
		if (is_no_button_for_buildersh == true) return;

		if (disallow_class_change_on_shops == false)
		{
			CBitStream params;
			params.write_u8(0);

		CButton@ button = caller.CreateGenericButton(
			"$change_class$",                         	  // icon token
			this.get_Vec2f("class offset"),            	 // button offset
			this,                                      	 // button attachment
			this.getCommandID("change class"),           // command id
			getTranslatedString("Swap Class"),           // description
			params                                   	 // bit stream
		);

		button.enableRadius = this.get_u8("class button radius");
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}
