// Chest.as

#include "LootChestCommon.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this) {
	this.Tag("activatable");
	this.addCommandID("activate");
	this.addCommandID("activate client");

	// used by RunnerMovement.as & ActivateHeldObject.as
	this.Tag("medium weight");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$chest_close$", "InteractionIcons.png", Vec2f(32, 32), 13);

	// spawn bronze chest by default
	if (isServer()) {
		if (!this.exists("chest_type")) { this.set_u8("chest_type", CHEST_TYPE::BRONZE); }
	}

	//printf("[LOOTCHEST] Chest type onInit is " + this.get_u8("chest_type"));

	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		u8 team_color = XORRandom(5);
		this.set_u8("team_color", team_color);

		sprite.SetZ(-10.0f);
		sprite.ReloadSprites(team_color, 0);

		if (this.hasTag("_chest_open")) {
			if (this.get_u8("chest_type") == CHEST_TYPE::SILVER) {
				sprite.SetAnimation("open_silver");
			} else if (this.get_u8("chest_type") == CHEST_TYPE::GOLDEN) {
				sprite.SetAnimation("open_golden");
			} else {
				sprite.SetAnimation("open");
			}

			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}
}

// HACK:
// update chest sprite
// also update inventory name and icon
void onTick(CSprite@ this) {
	CBlob@ chest = this.getBlob();
	if (chest is null || chest.get_u8("chest_type") == CHEST_TYPE::BRONZE || chest.hasTag("chest_updated")) return;

	if (chest !is null && chest.get_u8("chest_type") == CHEST_TYPE::SILVER) {
		this.SetAnimation("default_silver");
		chest.Tag("chest_updated");
	} else if (chest !is null && chest.get_u8("chest_type") == CHEST_TYPE::GOLDEN) {
		this.SetAnimation("default_golden");
		chest.Tag("chest_updated");
	}
}

void onTick(CBlob@ this) {
	if (this is null || this.hasTag("chest_blob_updated")) return;

	if (this !is null && this.get_u8("chest_type") == CHEST_TYPE::SILVER) {
		this.SetInventoryIcon("LootChest.png", 4, Vec2f(16,16));
		this.setInventoryName("Silver Loot Chest");
		this.Tag("chest_blob_updated");
	} else if (this !is null && this.get_u8("chest_type") == CHEST_TYPE::GOLDEN) {
		this.SetInventoryIcon("LootChest.png", 8, Vec2f(16,16));
		this.setInventoryName("Golden Loot Chest");
		this.Tag("chest_blob_updated");
	} else {
		this.setInventoryName("Bronze Loot Chest");
		this.Tag("chest_blob_updated");
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller) {
	if (!canSeeButtons(this, caller) || this.exists(DROP)) return;

	const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
	if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

	// only chest owner allowed to open loot chest
	if (this.get_string("lootchest owner") != caller.getPlayer().getUsername()) return;

	CButton@ button = caller.CreateGenericButton(
	"$chest_open$",                             // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("activate"),              // command id
	getTranslatedString("Open"));               // description

	button.radius = 8.0f;
	button.enableRadius = 20.0f;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) {
	if (cmd == this.getCommandID("activate") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;
					
		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		// range check
		const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
		if (this.getDistanceTo(caller) > DISTANCE_MAX || this.isAttached()) return;

		this.AddForce(Vec2f(0, -800));

		// add guaranteed piece of loot from your class index
		const string NAME = caller.getName();
		if (NAME == "archer") {
			addLoot(this, INDEX_ARCHER, 1, 0);
		} else if (NAME == "builder") {
			addLoot(this, INDEX_BUILDER, 1, 0);
		} else if (NAME == "knight") {
			addLoot(this, INDEX_KNIGHT, 1, 0);
		}

		server_CreateLoot(this, this.getPosition(), caller.getTeamNum());

		this.Tag("_chest_open");
		this.Sync("_chest_open", true);

		this.server_SetTimeToDie(3);

		this.SendCommand(this.getCommandID("activate client"));
	} else if (cmd == this.getCommandID("activate client") && isClient()) {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null) {
			if (this.get_u8("chest_type") == CHEST_TYPE::SILVER) {
				sprite.SetAnimation("open_silver");
			} else if (this.get_u8("chest_type") == CHEST_TYPE::GOLDEN) {
				sprite.SetAnimation("open_golden");
			} else {
				sprite.SetAnimation("open");
			}

			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}
}

void onDie(CBlob@ this) {
	int chest_lid_num = 0;

	if (this.get_u8("chest_type") == CHEST_TYPE::SILVER) {
		chest_lid_num = 1;
	} else if (this.get_u8("chest_type") == CHEST_TYPE::GOLDEN) {
		chest_lid_num = 2;
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		sprite.Gib();

		makeGibParticle(
		sprite.getFilename(),               // file name
		this.getPosition(),                 // position
		getRandomVelocity(90, 2, 360),      // velocity
		chest_lid_num,                      // column
		3,                                  // row
		Vec2f(16, 16),                      // frame size
		1.0f,                               // scale?
		0,                                  // ?
		"",                                 // sound
		this.get_u8("team_color"));         // team number
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob) {
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob) {
	return true;
}
