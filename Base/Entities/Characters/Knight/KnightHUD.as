//knight HUD
#include "/Entities/Common/GUI/ActorHUDStartPos.as";
#include "MaterialIndicatorHUD.as";
#include "HolidaySprites.as";
#include "pathway.as";

const string iconsFilename = "Entities/Characters/Knight/KnightIcons.png";
string icons_file_name;

const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	CBlob@ carried = this.getCarriedBlob();

	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-16, -16) * cl_mouse_scale);
		}
		else if (carried !is null && carried.getName() == "drill")
		{
			/////////////////////////////////////////////////////
			// drill shit
			CRules@ rules = getRules();

			f32 left = getRules().get_u16("barrier_x1");
			f32 right = getRules().get_u16("barrier_x2");

			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

			CBlob@ holder = point.getOccupied();
			if (holder is null) return;

			f32 holder_x = holder.getPosition().x;
			/////////////////////////////////////////////////////

			getHUD().SetCursorImage(getPath() + "Sprites/HUD/Cursors/DrillCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);

			if (!rules.hasTag("sudden death") && (holder_x <= left && holder.getTeamNum() == 1) || (holder_x >= right && holder.getTeamNum() == 0))
			{
				getHUD().SetCursorImage(getPath() + "Sprites/HUD/Cursors/CantDrillCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);
			}
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Knight/KnightCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	ManageCursors(blob);

	if (g_videorecording)
		return;

	CPlayer@ player = blob.getPlayer();

	// draw inventory

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);

	u8 type = blob.get_u8("bomb type");
	u8 frame = 1;

	if (type == 0) {
		frame = 0;
	} else if (type < 255) {
		frame = 1 + type;
	}

	// HACK: because code above just fucking epic, we need use new clause for new bombs
	if (type == 2) {
		frame = 5;
	} else if (type == 3) {
		frame = 6;
	} else if (type == 4) {
		frame = 8;
	}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw mats ui
	DrawPersonalMats();

	// draw class icon
	if (isAnyHoliday()) {
		icons_file_name = getHolidayVersionFileName("KnightIcons");
		GUI::DrawIcon(icons_file_name, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f, blob.getTeamNum());
	} else {
		GUI::DrawIcon(iconsFilename, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f, blob.getTeamNum());
	}

	//GUI::DrawIcon(iconsFilename, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f, blob.getTeamNum());
}
