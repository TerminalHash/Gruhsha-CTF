//builder HUD
#include "ActorHUDStartPos.as";
#include "BindingsCommon.as";
#include "BuilderCommon.as";
#include "Requirements.as";
#include "CommonBuilderBlocks.as";
#include "/Entities/Common/GUI/ActorHUDStartPos.as";
#include "MaterialTeamIndicatorHUD.as";
#include "pathway.as";

const string iconsFilename = "Entities/Characters/Builder/BuilderIcons.png";
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
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-16, -16) * cl_mouse_scale);
		}
		if (carried !is null && carried.getName() == "drill")
		{
			getHUD().SetCursorImage(getPath() + "Items/Drill/Sprites/DrillCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-11, -11) * cl_mouse_scale);
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Builder/BuilderCursor.png", Vec2f(9, 9));
		}

	}
}

Vec2f[] icon_offsets =
{
	Vec2f(8, 8),
	Vec2f(8, 8),
	Vec2f(-4, 8),
	Vec2f(8, 8),
	Vec2f(8, 8),
	Vec2f(-4, 8), // 5
	Vec2f(8, 8),
	Vec2f(-4, 8),
	Vec2f(8, 8),
	Vec2f(4, 4),
	Vec2f(8, 8), // 10
	Vec2f(0, 0)
};

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

	// draw mats ui
	DrawPersonalMats();
	DrawTeamMaterialsIndicator();

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw resupply icon

	if (shouldRenderResupplyIndicator(blob))
	{
		DrawResupplyOnHUD(blob, tl + Vec2f(8 + (slotsSize) * 40, -4));
	}

	// draw class icon

	BuildBlock[][]@ blocks;
    blob.get(blocks_property, @blocks);
    if (blocks is null) return;
    //CGridButton@ button = menu.AddButton(b.icon, "\n" + block_desc, Builder::make_block + i);

    Vec2f offset = Vec2f(0, 0);

	Vec2f dim = Vec2f(375, 96);
	if (getRules().get_string("blockbar_hud") == "no") return;
	tl = Vec2f(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12) + Vec2f(0, -2);

	u8 selected_i = -1;

	selected_i = blob.get_u8("bunnie_tile");

	for (int i=0; i<11; ++i)
	{
		f32 scale = 1.5;
		if (i == 9) scale = 1.0;

		SColor color = SColor(255, 255, 255, 255);
		SColor block_color = SColor(255, 255, 255, 255);

		BuildBlock@ b = blocks[0][i];
		if (b is null) continue;

		bool missing_reqs = false;

		if (i == selected_i) color = SColor(255, 120, 255, 40);

		CBitStream missing;
		if (!hasRequirements(blob.getInventory(), b.reqs, missing, not b.buildOnGround))
		{
			color = SColor(255, 250, 25, 25);
			block_color = SColor(255, 100, 100, 100);
		}

		GUI::DrawPane(tl, tl+Vec2f(40, 40), color);

   		GUI::DrawIconByName(b.icon, tl + icon_offsets[i], scale, scale, 0, block_color);

   		GUI::SetFont("hud");
   		if (getRules().get_s32(button_file_names[1][i] + "$2") != -1 )
   		{
			GUI::DrawText(getKeyName(getRules().get_s32(button_file_names[1][i] + "$1"), true) + "-" + getKeyName(getRules().get_s32(button_file_names[1][i] + "$2"), true), tl + Vec2f(0, -14), color_white);
   		}
   		else 
   		{
   			GUI::DrawText(getKeyName(getRules().get_s32(button_file_names[1][i] + "$1"), true), tl + Vec2f(0, -14), color_white);
   		}

		tl += Vec2f(40, 0);
	}

	//GUI::DrawIcon(iconsFilename, 3, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -13), 1.0f);
}

void DrawPersonalMats()
{
	if (g_videorecording)
	return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	if (p.getBlob() !is null)
	{
		GUI::SetFont("hud");
		u16 leftside_indent = 4;
		u16 text_indent = 32;
		u16 material_display_width = 90;
		u16 material_display_height = 40;
		Vec2f icon_dimensions = Vec2f(16, 16);
		string icon = "Materials.png";
		SColor wood_color = SColor(255, 164, 103, 39);
		SColor stone_color = SColor(255, 151, 167, 146);
		SColor gold_color = SColor(255, 254, 165, 61);
		CTeam@ red = getRules().getTeam(1);
		CTeam@ blue = getRules().getTeam(0);
		Vec2f dim = Vec2f(342, 64);
		Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
		ul += Vec2f(480, -28);

		Vec2f ul2 = ul + Vec2f(0, 40);

		string msg1 = getRules().get_s32("personalstone_" + p.getUsername());
		string msg2 = getRules().get_s32("personalwood_" + p.getUsername());

		SColor dcolor = blue.color;

		if (p.getTeamNum() == 1)
		{
			dcolor = red.color;
		}

		GUI::DrawPane(ul + Vec2f(0, 4), ul + Vec2f(material_display_width+leftside_indent, material_display_height), SColor(255, 200, 200, 200));

		GUI::DrawPane(ul2 + Vec2f(0, 4), ul2 + Vec2f(material_display_width+leftside_indent, material_display_height), SColor(255, 200, 200, 200));

		//wood
		GUI::DrawIcon(
			icon,
			25, //matwood icon
			icon_dimensions,
			ul2 + Vec2f(leftside_indent, 0),
			1.0f,
			0);
		GUI::DrawText(msg1, ul + Vec2f(leftside_indent*1.5+32, material_display_height/3), color_white);

		//stone
		GUI::DrawIcon(
			icon,
			24, //matstone icon
			icon_dimensions,
			ul + Vec2f(leftside_indent, 0),
			1.0f,
			0);
		GUI::DrawText(msg2, ul2 + Vec2f(leftside_indent*1.5+32, material_display_height/3), color_white);
	}
}
