// Archer logic

#include "ArcherCommon.as"
#include "ActivationThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "Requirements.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "RedBarrierCommon.as";
#include "StandardControlsCommon.as";
#include "BindingsCommon.as"

void onInit(CBlob@ this)
{
	ArcherInfo archer;
	this.set("archerInfo", @archer);

	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	ControlsSwitch@ controls_switch = @onSwitch;
	this.set("onSwitch handle", @controls_switch);

	ControlsCycle@ controls_cycle = @onCycle;
	this.set("onCycle handle", @controls_cycle);

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.addCommandID("activate/throw bomb");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(grapple_sync_cmd);

	SetHelp(this, "help self hide", "archer", getTranslatedString("Hide    $KEY_S$"), "", 1);
	SetHelp(this, "help self action2", "archer", getTranslatedString("$Grapple$ Grappling hook    $RMB$"), "", 3);

	//add a command ID for each arrow type
	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID("pick " + arrowTypeNames[i]);
	}

	this.set_u8("bomb type", 255);
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		this.addCommandID("pick " + bombTypeNames[i]);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	// [modded] for ability to lit kegs
	this.push("names to activate", "keg");
	this.push("names to activate", "satchel");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}

	if (getRules().hasTag("track_stats") && player !is null)
	{
		tcpr("SwitchClass " + player.getUsername() + " " + this.getName() + " " + getGameTime());
	}
}

void onTick(CBlob@ this)
{
	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}

	CBlob@ carried = this.getCarriedBlob();
	bool magicdrill = false;

	if (carried !is null)
	{
		if (carried.getName() == "drill") magicdrill = true;
	}

	if (magicdrill)
	{
		archer.charge_state = 0;
		archer.charge_time = 0;
		this.getSprite().SetEmitSoundPaused(true);
		getHUD().SetCursorFrame(0);
	}

	if (isKnocked(this) || this.isInInventory())
	{
		archer.grappling = false;
		archer.charge_state = 0;
		archer.charge_time = 0;
		this.getSprite().SetEmitSoundPaused(true);
		getHUD().SetCursorFrame(0);
		return;
	}

	//print("state before: " + archer.charge_state);

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	// activate/throw
	if (this.isKeyJustPressed(key_action3))
	{
		CBlob@ carried = this.getCarriedBlob();
		bool holding = carried !is null;// && carried.hasTag("exploding");

		CInventory@ inv = this.getInventory();
		bool thrown = false;
		u8 bombType = this.get_u8("bomb type");

		if (bombType == 255)
		{
			SetFirstAvailableBomb(this);
			bombType = this.get_u8("bomb type");
		}

		if (bombType < bombTypeNames.length)
		{
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob@ item = inv.getItem(i);
				const string itemname = item.getName();
				if (!holding && bombTypeNames[bombType] == itemname)
				{
					if (bombType >= 4)
					{
						this.server_Pickup(item);
						client_SendThrowOrActivateCommand(this);
						thrown = true;
					}
					else
					{
						client_SendThrowOrActivateCommandBomb(this, bombType);
						thrown = true;
					}
					break;
				}
			}
		}

		if (!thrown)
		{
			client_SendThrowOrActivateCommand(this);
			SetFirstAvailableBomb(this);
		}
	}

	////////////////////////////////////////////
	// ANIMATION DEBUG
	////////////////////////////////////////////

	// LYING
	if (this.isKeyJustPressed(key_action2)) {
		this.Tag("blob lying");
	} else 	if (this.isKeyJustReleased(key_action2)) {
		this.Untag("blob lying");
	}

	// HAMMER ANIMATIONS
	CBlob@ carriedblob = this.getCarriedBlob();
	if (carriedblob is null) return;

	if (carriedblob.getConfig() == "hammer") {
		this.Tag("hammer in hand");
	} else {
		this.Untag("hammer in hand");
	}

	CControls@ controls = getControls();

	// NOARM ANIMATIONS
	if (controls.isKeyJustPressed(KEY_SHIFT)) {
		this.Tag("blob anim noarm");
	} else if (controls.isKeyJustPressed(KEY_SHIFT)) {
		this.Untag("blob anim noarm");
	}

	////////////////////////////////////////////
	////////////////////////////////////////////

	//print("state after: " + archer.charge_state);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

// clientside
void onCycle(CBitStream@ params)
{
	u16 this_id;
	if (!params.saferead_u16(this_id)) return;

	CBlob@ this = getBlobByNetworkID(this_id);
	if (this is null) return;

	if (bombTypeNames.length == 0) return;

	// cycle bombs
	u8 type_b = this.get_u8("bomb type");
	int count_b = 0;
	while (count_b < bombTypeNames.length)
	{
		type_b++;
		count_b++;
		if (type_b >= bombTypeNames.length)
			type_b = 0;
		if (hasBombs(this, type_b))
		{
			CycleToBombType(this, type_b);
			CBitStream sparams;
			sparams.write_u8(type_b);
			this.SendCommand(this.getCommandID("switch"), sparams);
			break;
		}
	}
}

void onSwitch(CBitStream@ params)
{
	u16 this_id;
	if (!params.saferead_u16(this_id)) return;

	CBlob@ this = getBlobByNetworkID(this_id);
	if (this is null) return;

	if (bombTypeNames.length == 0) return;

	u8 type_b;
	if (!params.saferead_u8(type_b)) return;

	if (hasBombs(this, type_b))
	{
		CycleToBombType(this, type_b);
		CBitStream sparams;
		sparams.write_u8(type_b);
		this.SendCommand(this.getCommandID("switch"), sparams);
	}
}

void onSendCreateData(CBlob@ this, CBitStream@ params)
{
	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer)) { return; }

	params.write_u8(archer.arrow_type);
}

bool onReceiveCreateData(CBlob@ this, CBitStream@ params)
{
	return ReceiveArrowState(this, params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}

		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + bombTypeNames[i]))
			{
				this.set_u8("bomb type", i);
				break;
			}
		}
	}

	if (cmd == this.getCommandID("switch") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;
		// cycle bombs
		u8 type_b;
		if (!params.saferead_u8(type_b)) return;

		CycleToBombType(this, type_b);
	} else if (cmd == this.getCommandID("activate/throw") && isServer()) {
		SetFirstAvailableBomb(this);
	} else if (cmd == this.getCommandID("activate/throw bomb") && isServer()) {
		Vec2f pos = this.getVelocity();
		Vec2f vector = this.getAimPos() - this.getPosition();
		Vec2f vel = this.getVelocity();

		u8 bombType;
		if (!params.saferead_u8(bombType)) return;

		CBlob @carried = this.getCarriedBlob();

		if (carried !is null)
		{
			bool holding_bomb = false;
			// are we actually holding a bomb or something else?
			for (uint i = 0; i < bombNames.length; i++)
			{
				if (carried.getName() == bombNames[i])
				{
					holding_bomb = true;
					DoThrow(this, carried, pos, vector, vel);
				}
			}

			if (!holding_bomb)
			{
				ActivateBlob(this, carried, pos, vector, vel);
			}
		}
		else
		{
			if (bombType >= bombTypeNames.length)
				return;

			const string bombTypeName = bombTypeNames[bombType];
			this.Tag(bombTypeName + " done activate");
			if (hasItem(this, bombTypeName))
			{
				if (bombType == 0)
				{
					CBlob @blob = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
					}
				}
				else if (bombType == 1)
				{
					CBlob @blob = server_CreateBlob("waterbomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 92.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak");
						blob.set_u8("custom_hitter", Hitters::water);
						blob.Tag("splash ray cast");
					}
				}
				else if (bombType == 2)
				{
					CBlob @blob = server_CreateBlob("stickybomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
					}
				}
				else if (bombType == 3)
				{
					CBlob @blob = server_CreateBlob("icebomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 128.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak");
						blob.set_u8("custom_hitter", Hitters::water);
						blob.Tag("splash ray cast");
					}
				}
			}
		}
		SetFirstAvailableBomb(this);
	}
}

//bomb management

bool hasItem(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		return hasRequirements(inv, reqs, missing);
	}
	else
	{
		warn("our inventory was null! KnightLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this, const string &in name)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		if (hasRequirements(inv, reqs, missing))
		{
			server_TakeRequirements(inv, reqs);
		}
		else
		{
			warn("took a bomb even though we dont have one! KnightLogic.as");
		}
	}
	else
	{
		warn("our inventory was null! KnightLogic.as");
	}
}

void CycleToBombType(CBlob@ this, u8 bombType)
{
	this.set_u8("bomb type", bombType);
	if (this.isMyPlayer())
	{
		Sound::Play("/CycleInventory.ogg");
	}
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	AddIconToken("$StickyBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 5, this.getTeamNum());
	AddIconToken("$IceBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 6, this.getTeamNum());

	if (bombTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos2(gridmenu.getUpperLeftPosition().x - 1.1f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y + 48);
	CGridMenu@ menu2 = CreateGridMenu(pos2, this, Vec2f(bombTypeNames.length, 2), getTranslatedString("Current bomb"));
	u8 weaponSel = this.get_u8("bomb type");

	if (menu2 !is null)
	{
		menu2.deleteAfterClick = false;

		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			string matname = bombTypeNames[i];
			CBitStream params;
			params.write_u8(i);
			CGridButton @button = menu2.AddButton(bombIcons[i], getTranslatedString(bombNames[i]), "KnightLogic.as", "Callback_PickBomb", params);

			if (button !is null)
			{
				bool enabled = this.getBlobCount(bombTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;
				if (weaponSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

void Callback_PickBomb(CBitStream@ params)
{
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;

	CBlob@ blob = player.getBlob();
	if (blob is null) return;

	u8 bomb_id;
	if (!params.saferead_u8(bomb_id)) return;

	string matname = bombTypeNames[bomb_id];
	blob.set_u8("bomb type", bomb_id);

	blob.SendCommand(blob.getCommandID("pick " + matname));
}

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type_b = 255;
	if (this.exists("bomb type"))
		type_b = this.get_u8("bomb type");

	CInventory@ inv = this.getInventory();

	bool typeReal = (uint(type_b) < bombTypeNames.length);
	if (typeReal && inv.getItem(bombTypeNames[type_b]) !is null)
		return;

	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		const string itemname = inv.getItem(i).getName();
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				type_b = j;
				break;
			}
		}

		if (type_b != 255)
			break;
	}

	this.set_u8("bomb type", type_b);

	//printf("KURWA BOMBER");
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();

	if (this.getInventory().getItemsCount() == 0 || itemname == "mat_bombs")
	{
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				this.set_u8("bomb type", j);
				return;
			}
		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	CheckSelectedBombRemovedFromInventory(this, blob);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	CheckSelectedBombRemovedFromInventory(this, detached);
}

void CheckSelectedBombRemovedFromInventory(CBlob@ this, CBlob@ blob)
{
	string name = blob.getName();
	if (bombTypeNames.find(name) > -1 && this.getBlobCount(name) == 0)
	{
		SetFirstAvailableBomb(this);
	}
}
