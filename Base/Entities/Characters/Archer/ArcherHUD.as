//archer HUD

#include "ArcherCommon.as";
#include "ActorHUDStartPos.as";
#include "ArcherResupplyHUD.as";
#include "MaterialIndicatorHUD.as";
#include "pathway.as";

const string iconsFilename = "Entities/Characters/Archer/ArcherIcons.png";
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

	// set cursor
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (carried !is null && carried.getName() == "drill")
		{
			/////////////////////////////////////////////////////
			// drill shit
			f32 left = getRules().get_u16("barrier_x1");
			f32 right = getRules().get_u16("barrier_x2");

			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

			CBlob@ holder = point.getOccupied();
			if (holder is null) return;

			f32 holder_x = holder.getPosition().x;
			/////////////////////////////////////////////////////

			getHUD().SetCursorImage(getPath() + "Sprites/HUD/Cursors/DrillCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);

			if ((holder_x <= left && holder.getTeamNum() == 1) || (holder_x >= right && holder.getTeamNum() == 0))
			{
				getHUD().SetCursorImage(getPath() + "Sprites/HUD/Cursors/CantDrillCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);
			}
		} else {
			// set cursor
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-16, -16) * cl_mouse_scale);
			// frame set in logic
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

	const u8 type = getArrowType(blob);
	u8 arrow_frame = 0;

	if (type != ArrowType::normal)
	{
		arrow_frame = type;
	}

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw resupply
	DrawArchResupplyOnHUD(blob, tl + Vec2f(8 + (slotsSize) * 44, -18));

	// draw mats ui
	DrawPersonalMats();

	// class weapon icon
	GUI::DrawIcon(iconsFilename, arrow_frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f, blob.getTeamNum());
}
