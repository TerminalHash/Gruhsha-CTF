// CrusherLogic.as     Code for the main logic of the class

// Include-s   they import information from other scripts
#include "ActivationThrowCommon.as"
#include "CrusherCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "GruhshaHitters.as";
#include "ShieldCommon.as";
#include "KnockedCommon.as"
#include "Help.as";
#include "Requirements.as"
#include "FireParticle.as"
#include "ParticleSparks.as";
#include "StandardControlsCommon.as";
#include "BindingsCommon.as"

//attacks limited to the one time per-actor before reset.
void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

// On entity initialization, this stuff runs when the entity is created for the first time
void onInit(CBlob@ this)
{
	KnightInfo knight;

	// Setting some variables
	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.tileDestructionLimiter = 0;

	this.set("knightInfo", @knight);

	this.set_f32("gib health", -1.5f);
	knight_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	// Tags, these are a simple way to add attributes to an entity
	  //this player tag is useful for letting  other objects recognize this object as a player
	this.Tag("player");
	  //this flesh tag is useful for letting other objects recognize this object as having flesh
	this.Tag("flesh");

	ControlsSwitch@ controls_switch = @onSwitch;
	this.set("onSwitch handle", @controls_switch);

	ControlsCycle@ controls_cycle = @onCycle;
	this.set("onCycle handle", @controls_cycle);

	this.addCommandID("activate/throw bomb");

	this.push("names to activate", "keg");
	this.push("names to activate", "fumokeg");
	this.push("names to activate", "hazelnut");
	this.push("names to activate", "hazelnutshell");
	this.push("names to activate", "satchel");

	this.set_u8("bomb type", 255);
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		this.addCommandID("pick " + bombTypeNames[i]);
	}

	//centered on bomb select
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	SetHelp(this, "help self action", "knight", getTranslatedString("$Jab$Jab        $LMB$"), "", 4);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 15, Vec2f(16, 16));
	}
}

// OnTick -- this runs the below code for every frame
void onTick(CBlob@ this)
{
	bool knocked = isKnocked(this);

	if (this.isInInventory())
		return;

	//knight logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	// Setting some variables
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	const int boulder_cooldown = 2;

	bool swordState = isSwordState(knight.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));
	bool specialShieldState = isSpecialShieldState(knight.state);
	bool myplayer = this.isMyPlayer();

	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if knights dmging stuff while in menus is a real issue and go from there

		// If the entity is stunned
	if (knocked)// || myplayer && getHUD().hasMenus())
	{
		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.slideTime = 0;
		knight.doubleslash = false;

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else // If the entity isn't stunned
	{
		// This sets base speed!! IMPORTANT
		moveVars.jumpFactor *= 0.8f;
		moveVars.walkFactor *= 0.85f;
	}

	if (!pressed_a1 && !swordState &&
	    (pressed_a2 || (specialShieldState)) &&
		!knocked &&
		getGameTime() >= (this.get_s32("last_boulder_time") + boulder_cooldown * getTicksASecond())
	   )
	{
		// This sets speed for when rightclicking

		// This is the boulder throwing script:
		// =--------------------=
		moveVars.jumpFactor *= 0.5f;
		moveVars.walkFactor *= 0.4f;

		CBlob@ projectile = server_CreateBlob("boulder",-1,this.getPosition()+Vec2f((this.isFacingLeft() ? -8 : 8),-4));
		makeSmokeParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));

		setKnocked(this, 41);

		Sound::Play("CatapultFire", this.getPosition());
		Sound::Play("/ArgLong", this.getPosition());

		if(projectile !is null)
		{
			Vec2f vel((this.isFacingLeft() ? -7.0f : 7.0f), -4.5f);
			projectile.setVelocity(vel * 1.2);
			projectile.server_SetTimeToDie(2.0f);
			projectile.server_setTeamNum(this.getTeamNum());

			CPlayer@ player = this.getPlayer();
			if (player !is null)
			{
				projectile.SetDamageOwnerPlayer(player);
			}
		}

		this.set_s32("last_boulder_time", getGameTime());
		// =--------------------=
	}
	else if ((pressed_a1 || swordState) && !moveVars.wallsliding)   //no attacking during a slide
	{
		// Sound effects
		if (getNet().isClient())
		{
			if (knight.swordTimer == KnightVars::slash_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
			else if (knight.swordTimer == KnightVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
		}

		// Stun player if they are charging a slash for too long
		if (knight.swordTimer >= KnightVars::slash_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			setKnocked(this, 15);
		}

		bool strong = (knight.swordTimer > KnightVars::slash_charge_level2);
		moveVars.jumpFactor *= (strong ? 0.8f : 0.8f);
		moveVars.walkFactor *= (strong ? 0.8f : 0.9f);

		if (!inair)
		{
			this.AddForce(Vec2f(vel.x * -10.0, 0.0f));   //horizontal slowing force (prevents SANICS)
			//this.AddForce(Vec2f(0.0, vel.y * -10.0f));   //horizontal slowing force (prevents SANICS)
		}

		if (knight.state == KnightStates::normal ||
		        this.isKeyJustPressed(key_action1) &&
		        (!inMiddleOfAttack(knight.state)))
		{
			knight.state = KnightStates::sword_drawn;
			knight.swordTimer = 0;
		}

		if (knight.state == KnightStates::sword_drawn && getNet().isServer())
		{
			knight_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = knight.swordTimer;
		if (knight.swordTimer < 128)
			knight.swordTimer++;

		if (knight.state == KnightStates::sword_drawn && !pressed_a1 &&
		        !this.isKeyJustReleased(key_action1) && delta > KnightVars::resheath_time)
		{
			knight.state = KnightStates::normal;
		}
		else if (this.isKeyJustReleased(key_action1) && knight.state == KnightStates::sword_drawn)
		{
			knight.swordTimer = 0;

			if (delta < KnightVars::slash_charge)
			{
				if (direction == -1)
				{
					knight.state = KnightStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						knight.state = KnightStates::sword_cut_mid;
					}
					else
					{
						knight.state = KnightStates::sword_cut_mid_down;
					}
				}
				else
				{
					knight.state = KnightStates::sword_cut_down;
				}
			}
			else if (delta < KnightVars::slash_charge_level2)
			{
				knight.state = KnightStates::sword_power;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else if (delta < KnightVars::slash_charge_limit)
			{
				knight.state = KnightStates::sword_power_super;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else
			{
				//knock?
			}
		}
		else if (knight.state >= KnightStates::sword_cut_mid &&
		         knight.state <= KnightStates::sword_cut_down) // cut state
		{
			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 90.0f;
				f32 attackAngle = getCutAngle(this, knight.state);

				if (knight.state == KnightStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, 0.5f, attackAngle, attackarc, GruhshaHitters::hammer, delta, knight); // Stab / bash
				if ((!inair) && (knight.state == KnightStates::sword_cut_down))
				{
					if (Maths::Abs(this.getVelocity().x) < 10.0f)
					{
						this.setVelocity(vel * 1.9);
					}
					else
					{
						this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
						setKnocked(this, 10);
					}
					
					Sound::Play("throw", this.getPosition());

					if (Maths::Abs(this.getVelocity().x) > 6.8f)
					{
						sparks(this.getPosition(), 0, 0.4f);
						Sound::Play("ShieldHit.ogg", this.getPosition(), 0.7f);
					}
				}
			}
			else if (delta >= 9)
			{
				knight.swordTimer = 0;
				knight.state = KnightStates::sword_drawn;
			}
		}
		else if (knight.state == KnightStates::sword_power ||
		         knight.state == KnightStates::sword_power_super)
		{
			//setting double
			if (knight.state == KnightStates::sword_power_super &&
			        this.isKeyJustPressed(key_action1))
			{
				knight.doubleslash = true;
			}

			//attacking + noises
			if (delta == 2)
			{
				Sound::Play("/ArgLong", this.getPosition());
				Sound::Play("/SwordSlash", this.getPosition());
			}
			else if (delta > DELTA_BEGIN_ATTACK && delta < 10)
			{
				DoAttack(this, 3.5f, -(vec.Angle()), 120.0f, GruhshaHitters::hammer_heavy, delta, knight); // SLASH 2.0 = 2hp
			}
			else if (delta >= KnightVars::slash_time ||
			         (knight.doubleslash && delta >= KnightVars::double_slash_time))
			{
				knight.swordTimer = 0;

				if (knight.doubleslash)
				{
					knight_clear_actor_limits(this);
					knight.doubleslash = false;
					knight.state = KnightStates::sword_power;
				}
				else
				{
					knight.state = KnightStates::sword_drawn;
				}
			}
		}

		//special slash movement

		if ((knight.state == KnightStates::sword_power ||
		        knight.state == KnightStates::sword_power_super) &&
		        delta < KnightVars::slash_move_time)
		{

			if (Maths::Abs(vel.x) < KnightVars::slash_move_max_speed &&
			        vel.y > -KnightVars::slash_move_max_speed)
			{
				// Added velocity when slashing
				Vec2f slash_vel =  knight.slash_direction * this.getMass() * 0.5f;
				this.AddForce(slash_vel * 1.5);
			}
		}

		moveVars.canVault = false;

	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1) || this.get_u32("knight_timer") <= getGameTime())
	{
		knight.state = KnightStates::normal;
	}

	//throwing bombs
	if (myplayer)
	{
		// space
        if (getRules().get_s32("bomb_key$1") != -1) {
			if (this.isKeyJustPressed(key_action3)) {
				CBlob@ carried = this.getCarriedBlob();

				if (carried is null || !carried.hasTag("temp blob")) {
					client_SendThrowOrActivateCommand(this);
				}
			}

			if (b_KeyJustPressed("bomb_key")) {
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
							if (bombType >= 5)
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
        } else {
			if (this.isKeyJustPressed(key_action3)) {
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
		}

		// help
		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "knight", getTranslatedString("$Slash$ Slash!    $KEY_HOLD$$LMB$"), "", 13);
		}
	}
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
	u8 type = this.get_u8("bomb type");
	int count = 0;
	while (count < bombTypeNames.length)
	{
		type++;
		count++;
		if (type >= bombTypeNames.length)
			type = 0;
		if (hasBombs(this, type))
		{
			CycleToBombType(this, type);
			CBitStream sparams;
			sparams.write_u8(type);
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

	u8 type;
	if (!params.saferead_u8(type)) return;

	if (hasBombs(this, type))
	{
		CycleToBombType(this, type);
		CBitStream sparams;
		sparams.write_u8(type);
		this.SendCommand(this.getCommandID("switch"), sparams);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("switch") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (caller !is this) return;
		// cycle bombs
		u8 type;
		if (!params.saferead_u8(type)) return;

		CycleToBombType(this, type);
	}
	else if (cmd == this.getCommandID("activate/throw") && isServer())
	{
		SetFirstAvailableBomb(this);
	}
	else if (cmd == this.getCommandID("activate/throw bomb") && isServer())
	{
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
				if(carried.getName() == bombNames[i])
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
				/*else if (bombType == 4)
				{
					CBlob @blob = server_CreateBlob("booster", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 92.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak2");
						blob.set_u8("custom_hitter", Hitters::water);
					}
				}*/
			}
		}
		SetFirstAvailableBomb(this);
	}
	else if (isServer())
	{
		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + bombTypeNames[i]))
			{
				this.set_u8("bomb type", i);
				break;
			}
		}
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

/////////////////////////////////////////////////

bool isJab(f32 damage)
{
	return damage < 1.5f;
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, KnightInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = isJab(damage);
	bool dontHitMoreLogs = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		// HitInfo objects are sorted, first come closest hits
		// start from furthest ones to avoid doing too many redundant raycasts
		for (int i = hitInfos.size() - 1; i >= 0; i--)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;

			if (b !is null)
			{
				if (b.hasTag("ignore sword") 
				    || !canHit(this, b)
				    || knight_has_hit_actor(this, b)) 
				{
					continue;
				}

				Vec2f hitvec = hi.hitpos - pos;

				// we do a raycast to given blob and hit everything hittable between knight and that blob
				// raycast is stopped if it runs into a "large" blob (typically a door)
				// raycast length is slightly higher than hitvec to make sure it reaches the blob it's directed at
				HitInfo@[] rayInfos;
				map.getHitInfosFromRay(pos, -(hitvec).getAngleDegrees(), hitvec.Length() + 2.0f, this, rayInfos);

				for (int j = 0; j < rayInfos.size(); j++)
				{
					CBlob@ rayb = rayInfos[j].blob;
					
					if (rayb is null) break; // means we ran into a tile, don't need blobs after it if there are any
					if (rayb.hasTag("ignore sword") || !canHit(this, rayb)) continue;

					bool large = rayb.hasTag("blocks sword") && !rayb.isAttached() && rayb.isCollidable(); // usually doors, but can also be boats/some mechanisms
					if (knight_has_hit_actor(this, rayb)) 
					{
						// check if we hit any of these on previous ticks of slash
						if (large) break;
						if (rayb.getName() == "log")
						{
							dontHitMoreLogs = true;
						}
						continue;
					}
					if (!canHit(this, rayb)) continue;

					f32 temp_damage = damage;
					
					if (rayb.getName() == "log")
					{
						if (!dontHitMoreLogs)
						{
							temp_damage /= 3;
							dontHitMoreLogs = true; // set this here to prevent from hitting more logs on the same tick
							int quantity = Maths::Ceil(float(temp_damage) * 20.0f);
							int max_quantity = rayb.getHealth() / 0.024f; // initial log health / max mats

							quantity = Maths::Max(
									Maths::Min(quantity, max_quantity),
									0
								);

							if (isServer() && this.getPlayer() !is null)
							{
								u8 team = this.getPlayer().getTeamNum();

								getRules().add_s32("teamwood" + team, quantity);
								getRules().Sync("teamwood" + team, true);
							}
							/*CBlob@ wood = server_CreateBlobNoInit("mat_wood");
							if (wood !is null)
							{
								int quantity = Maths::Ceil(float(temp_damage) * 20.0f);
								int max_quantity = rayb.getHealth() / 0.024f; // initial log health / max mats
								
								quantity = Maths::Max(
									Maths::Min(quantity, max_quantity),
									0
								);

								wood.Tag('custom quantity');
								wood.Init();
								wood.setPosition(rayInfos[j].hitpos);
								wood.server_SetQuantity(quantity);
							}*/
						}
						else 
						{
							// print("passed a log on " + getGameTime());
							continue; // don't hit the log
						}
					}
					
					knight_add_actor_limit(this, rayb);

					
					Vec2f velocity = rayb.getPosition() - pos;
					velocity.Normalize();
					velocity *= 12; // knockback force is same regardless of distance

					if (rayb.getTeamNum() != this.getTeamNum() || rayb.hasTag("dead player")) {
						this.server_Hit(rayb, rayInfos[j].hitpos, velocity, temp_damage, type, true);
					}

					if (large)
					{
						break; // don't raycast past the door after we do damage to it
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool dirt_thick_stone = map.isTileThickStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					bool castle = map.isTileCastle(hi.tile);

					if (ground || wood || dirt_stone || gold || castle)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						Vec2f velocity = hi.hitpos - this.getPosition();
						Vec2f hitpos = hi.hitpos;

						CBitStream params;
						params.write_Vec2f(velocity);
						params.write_Vec2f(hitpos);

						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							if (jab) //fake damage
							{
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);
							}
							else //reset fake dmg for next time
							{
								info.tileDestructionLimiter = 0;
							}

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								if (ground || wood || dirt_stone || gold || castle)
								{
									if (!wood)
										map.server_DestroyTile(hi.hitpos, 0.1f, this);
									else
										map.server_DestroyTile(hi.hitpos, 2.0f, this);

									if (gold)
									{
										// Note: 0.1f damage doesn't harvest anything I guess
										// This puts it in inventory - include MaterialCommon
										//Material::fromTile(this, hi.tile, 1.f);
										int quantity = 4;

										/*if (isServer() && this.getPlayer() !is null)
										{
											getRules().add_s32("personalgold_" + this.getPlayer().getUsername(), quantity);
											getRules().Sync("personalgold_" + this.getPlayer().getUsername(), true);
										}*/

										CBlob@ ore = server_CreateBlobNoInit("mat_gold");
										if (ore !is null)
										{
											ore.Tag('custom quantity');
											ore.Init();
											ore.setPosition(hi.hitpos);
											ore.server_SetQuantity(4);
										}
									}
									else if (dirt_stone)
									{
										int quantity = 4;
										if(dirt_thick_stone)
										{
											quantity = 6;
										}

										if (isServer() && this.getPlayer() !is null)
										{
											u8 team = this.getPlayer().getTeamNum();

											getRules().add_s32("teamstone" + team, quantity);
											getRules().Sync("teamstone" + team, true);
										}

										/*CBlob@ ore = server_CreateBlobNoInit("mat_stone");
										if (ore !is null)
										{
											ore.Tag('custom quantity');
											ore.Init();
											ore.setPosition(hi.hitpos);
											ore.server_SetQuantity(quantity);
										}*/
									}
								}
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool isSliding(KnightInfo@ knight)
{
	return (knight.slideTime > 0 && knight.slideTime < 45);
}

// shieldbash

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}
}


//a little push forward

void pushForward(CBlob@ this, f32 normalForce, f32 pushingForce, f32 verticalForce)
{
	f32 facing_sign = this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	    (facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	    (facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force = normalForce;

	if (pushing_in_facing_direction)
	{
		force = pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign , verticalForce));
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

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	if (customData == GruhshaHitters::hammer &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            knight.state == KnightStates::sword_cut_mid ||
	            knight.state == KnightStates::sword_cut_mid_down ||
	            knight.state == KnightStates::sword_cut_up ||
	            knight.state == KnightStates::sword_cut_down
	        ))
	{

		if (blockAttack(hitBlob, velocity, 0.0f) && hitBlob.hasTag("flesh"))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			setKnocked(this, 15);
			setKnocked(hitBlob, 15);
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

// bomb pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	AddIconToken("$Bomb$", "KnightIcons.png", Vec2f(16, 32), 0, this.getTeamNum());
	AddIconToken("$WaterBomb$", "KnightIcons.png", Vec2f(16, 32), 2, this.getTeamNum());
	AddIconToken("$StickyBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 5, this.getTeamNum());
	AddIconToken("$IceBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 6, this.getTeamNum());
	//AddIconToken("$Booster$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 8, this.getTeamNum());

	if (bombTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(bombTypeNames.length, 2), getTranslatedString("Current bomb"));
	u8 weaponSel = this.get_u8("bomb type");

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < bombTypeNames.length; i++)
		{
			string matname = bombTypeNames[i];
			CBitStream params;
			params.write_u8(i);
			CGridButton @button = menu.AddButton(bombIcons[i], getTranslatedString(bombNames[i]), "KnightLogic.as", "Callback_PickBomb", params);

			if (button !is null)
			{
				bool enabled = hasBombs(this, i);
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


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	for (uint i = 0; i < bombTypeNames.length; i++)
	{
		if (attached.getName() == bombTypeNames[i])
		{
			this.set_u8("bomb type", i);
			break;
		}
	}

	if (!ap.socket) {
		KnightInfo@ knight;
		if (!this.get("knightInfo", @knight))
		{
			return;
		}

		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.doubleslash = false;
		this.set_s32("currentKnightState", 0);
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
	if (this.isMyPlayer() && this.getInventory().getItemsCount() > 1)
	{
		for (uint j = 1; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				SetHelp(this, "help inventory", "knight", "$Help_Bomb1$$Swap$$Help_Bomb2$         $KEY_TAP$$KEY_F$", "", 2);
				break;
			}
		}
	}

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

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type = 255;
	u8 nowType = 255;
	if (this.exists("bomb type"))
		nowType = this.get_u8("bomb type");

	CInventory@ inv = this.getInventory();

	bool typeReal = (uint(nowType) < bombTypeNames.length);
	if (typeReal && inv.getItem(bombTypeNames[nowType]) !is null)
		return;

	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		const string itemname = inv.getItem(i).getName();
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				type = j;
				break;
			}
		}

		if (type != 255)
			break;
	}

	this.set_u8("bomb type", type);
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{
	if (b.hasTag("invincible") || b.hasTag("temp blob"))
		return false;
	
	// don't hit picked up items (except players and specially tagged items)
	return b.hasTag("player") || b.hasTag("slash_while_in_hand") || !isBlobBeingCarried(b);
}

bool isBlobBeingCarried(CBlob@ b)
{	
	CAttachment@ att = b.getAttachments();
	if (att is null)
	{
		return false;
	}

	// Look for a "PICKUP" attachment point where socket=false and occupied=true
	return att.getAttachmentPoint("PICKUP", false, true) !is null;
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
