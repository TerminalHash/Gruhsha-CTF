// REQUIRES:
//
//      onRespawnCommand() to be called in onCommand()
//
//  implementation of:
//
//      bool canChangeClass( CBlob@ this, CBlob @caller )
//
// Tag: "change class sack inventory" - if you want players to have previous items stored in sack on class change
// Tag: "change class store inventory" - if you want players to store previous items in this respawn blob

#include "ClassSelectMenu.as"
#include "KnockedCommon.as"


bool canChangeClass(CBlob@ this, CBlob@ blob)
{
    if (blob.hasTag("switch class")) return false;

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}

// default classes
void InitClasses(CBlob@ this)
{
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	this.addCommandID("change class");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), getTranslatedString("Swap class"));
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
	}
}

void buildSpawnMenu(CBlob@ this, CBlob@ caller)
{
	AddIconToken("$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8, caller.getTeamNum());
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12, caller.getTeamNum());
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16, caller.getTeamNum());
	BuildRespawnMenuFor(this, caller);
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("change class") && isServer())
	{
		////////////////////////////////////////////////
		// CLASS LIMIT CODE BLOCK
		CRules@ rules = getRules();
		CPlayer@ player = null;

		string[] P_Archers_b;
		string[] P_Archers_r;
		string[] P_Builders_b;
		string[] P_Builders_r;
		string[] P_Knights_b;
		string[] P_Knights_r;

		archers_limit = rules.get_u8("archers_limit");
		builders_limit = rules.get_u8("builders_limit");

		// calculating amount of players in classes
		for (u32 i = 0; i < getPlayersCount(); i++)
		{
			if (getPlayer(i).getBlob() is null) continue;

			if (getPlayer(i).getBlob().getName() == "archer")
			{
				if (getPlayer(i).getTeamNum() == 0) P_Archers_b.push_back(getPlayer(i).getUsername());
				else if (getPlayer(i).getTeamNum() == 1) P_Archers_r.push_back(getPlayer(i).getUsername());
			}
			if (getPlayer(i).getBlob().getName() == "builder")
			{
				if (getPlayer(i).getTeamNum() == 0) P_Builders_b.push_back(getPlayer(i).getUsername());
				else if (getPlayer(i).getTeamNum() == 1) P_Builders_r.push_back(getPlayer(i).getUsername());
			}
			if (getPlayer(i).getBlob().getName() == "knight")
			{
				if (getPlayer(i).getTeamNum() == 0) P_Knights_b.push_back(getPlayer(i).getUsername());
				else if (getPlayer(i).getTeamNum() == 1) P_Knights_r.push_back(getPlayer(i).getUsername());
			}

			//printf("We have: " + P_Archers_r.length + " Archers, " + P_Builders_r.length + " Builders, " + P_Knights_r.length + " Knights in red team");
			//printf("We have: " + P_Archers_b.length + " Archers, " + P_Builders_b.length + " Builders, " + P_Knights_b.length + " Knights in blue team");
		}
		////////////////////////////////////////////////

		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ caller = callerp.getBlob();
		if (caller is null) return;

		if (!canChangeClass(this, caller)) return;

		u8 id;
		if (!params.saferead_u8(id)) return;

		string classconfig = "knight";

		PlayerClass[]@ classes;
		if (this.get("playerclasses", @classes)) // Multiple classes available?
		{
			if (id >= classes.size())
			{
				string player_username = "(couldn't determine)";
				if (this.getPlayer() !is null)
				{
					player_username = this.getPlayer().getUsername();
				}
				warn("Bad class ID " + id + ", ignoring request of player " + player_username);
				return;
			}

			classconfig = classes[id].configFilename;
		}
		else if (this.exists("required class")) // Maybe single class available?
		{
			classconfig = this.get_string("required class");
		}
		else // No classes available?
		{
			return;
		}

		// Caller overlapping?
		if (!caller.isOverlapping(this)) return;

		// Don't spam the server with class change
		if (caller.getTickSinceCreated() < 10) return;

		////////////////////////////////////////////////
		// CLASS LIMIT CODE BLOCK

		// Limit classes, if game started
		if (classconfig == "archer")
		{
			if (caller.getTeamNum() == 0 && P_Archers_b.length >= archers_limit)
			{
				return;
			}

			if (caller.getTeamNum() == 1 && P_Archers_r.length >= archers_limit)
			{
				return;
			}
		}

		if (classconfig == "builder" && !rules.isWarmup())
		{
			if (caller.getTeamNum() == 0 && P_Builders_b.length >= builders_limit)
			{
				return;
			}

			if (caller.getTeamNum() == 1 && P_Builders_r.length >= builders_limit)
			{
				return;
			}
		}
		////////////////////////////////////////////////

		CBlob @newBlob = server_CreateBlob(classconfig, caller.getTeamNum(), this.getRespawnPosition());

		if (newBlob !is null)
		{
			// copy health and inventory
			// make sack
			CInventory @inv = caller.getInventory();

			if (inv !is null)
			{
				if (this.hasTag("change class drop inventory"))
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob @item = inv.getItem(0);
						caller.server_PutOutInventory(item);
					}
				}
				else if (this.hasTag("change class store inventory"))
				{
					if (this.getInventory() !is null)
					{
						caller.MoveInventoryTo(this);
					}
					else // find a storage
					{
						PutInvInStorage(caller);
					}
				}
				else
				{
					// keep inventory if possible
					caller.MoveInventoryTo(newBlob);
				}
			}

			// set health to be same ratio
			float healthratio = caller.getHealth() / caller.getInitialHealth();
			newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

			//copy air
			if (caller.exists("air_count"))
			{
				newBlob.set_u8("air_count", caller.get_u8("air_count"));
				newBlob.Sync("air_count", true);
			}

			//copy stun
			if (isKnockable(caller))
			{
				setKnocked(newBlob, getKnockedRemaining(caller));
			}

			// plug the soul
			newBlob.server_SetPlayer(caller.getPlayer());
			newBlob.setPosition(caller.getPosition());

			// no extra immunity after class change
			if (caller.exists("spawn immunity time"))
			{
				newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
				newBlob.Sync("spawn immunity time", true);
			}

			caller.Tag("switch class");
			caller.server_SetPlayer(null);
			caller.server_Die();
		}
	}
}

void PutInvInStorage(CBlob@ blob)
{
	CBlob@[] storages;
	if (getBlobsByTag("storage", @storages))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{
				blob.MoveInventoryTo(storage);
				return;
			}
		}
}

const bool enable_quickswap = false;
void CycleClass(CBlob@ this, CBlob@ blob)
{
	//get available classes
	PlayerClass[]@ classes;
	if (this.get("playerclasses", @classes))
	{
		CBitStream params;
		PlayerClass @newclass;

		u8 new_i = 0;

		//find current class
		for (uint i = 0; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];
			if (pclass.name.toLower() == blob.getName())
			{
				//cycle to next class
				new_i = (i + 1) % classes.length;
				break;
			}
		}

		if (classes[new_i] is null)
		{
			//select default class
			new_i = 0;
		}

		//switch to class
		this.SendCommand(this.getCommandID("change class"), params);
	}
}
