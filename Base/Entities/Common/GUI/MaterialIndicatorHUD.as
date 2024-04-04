// MaterialIndicatorHUD.as
void DrawPersonalMats()
{
	if (g_videorecording)
	return;

	CMap@ map = getMap();

	CBlob@[] wood_list;
	getBlobsByName("mat_wood", @wood_list);
	int wood_count_blue = 0;
	int wood_count_red = 0;

	for (int i=0; i<wood_list.length; ++i)
	{
		Vec2f pos_to_use = wood_list[i].getPosition();
		if(wood_list[i].isInInventory())
		{
			if(wood_list[i].getInventoryBlob() !is null)
			{
				if (wood_list[i].getInventoryBlob().getName() != "tent")
				{
					continue;
				}
				pos_to_use = wood_list[i].getInventoryBlob().getPosition();
			}
		}
		else
		{
			continue;
		}

		if (pos_to_use.x < map.tilemapwidth * 8 / 2)
		{
			wood_count_blue += wood_list[i].getQuantity();
		}
		else
		{
			wood_count_red += wood_list[i].getQuantity();
		}
	}

	CBlob@[] stone_list;
	getBlobsByName("mat_stone", @stone_list);
	int stone_count_blue = 0;
	int stone_count_red = 0;

	for (int i=0; i<stone_list.length; ++i)
	{
		Vec2f pos_to_use = stone_list[i].getPosition();

		if(stone_list[i].isInInventory())
		{
			if(stone_list[i].getInventoryBlob() !is null)
			{
				pos_to_use = stone_list[i].getInventoryBlob().getPosition();
			}
		}
		else
		{
			continue;
		}

		if (pos_to_use.x < map.tilemapwidth * 8 / 2)
		{
			stone_count_blue += stone_list[i].getQuantity();
		}
		else
		{
			stone_count_red += stone_list[i].getQuantity();
		}
	}

	CBlob@[] gold_list;
	getBlobsByName("mat_gold", @gold_list);
	int gold_count_blue = 0;
	int gold_count_red = 0;

	for (int i = 0; i < gold_list.length; ++i)
	{
		Vec2f pos_to_use = gold_list[i].getPosition();
		if (gold_list[i].isInInventory())
		{
			if (gold_list[i].getInventoryBlob() !is null)
			{
				if (gold_list[i].getInventoryBlob().getName() != "tent")
				{
					continue;
				}
				pos_to_use = gold_list[i].getInventoryBlob().getPosition();
			}
		}
		else
		{
			continue;
		}

		if (pos_to_use.x < map.tilemapwidth * 8 / 2)
		{
			gold_count_blue += gold_list[i].getQuantity();
		}
		else
		{
			gold_count_red += gold_list[i].getQuantity();
		}
	}

	CPlayer@ p = getLocalPlayer();
	u8 team = p.getTeamNum();

	if (p is null || !p.isMyPlayer()) { return; }

	if (p.getBlob() !is null)
	{
		GUI::SetFont("hud");
		u16 leftside_indent = 4;
		u16 text_indent = 32;
		u16 material_display_width = 90;
		u16 material_display_height = 40;
		u16 material_display_height1 = 44;
		Vec2f icon_dimensions = Vec2f(16, 16);
		string icon = "Materials.png";
		SColor wood_color = SColor(255, 164, 103, 39);
		SColor stone_color = SColor(255, 151, 167, 146);
		SColor gold_color = SColor(255, 254, 165, 61);
		CTeam@ red = getRules().getTeam(1);
		CTeam@ blue = getRules().getTeam(0);
		Vec2f dim = Vec2f(342, 64);
		Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
		ul += Vec2f(480, -74);

		Vec2f ul2 = ul + Vec2f(0, 40);
		Vec2f ul3 = ul2 + Vec2f(0, 40);

		string msg1 = wood_count_blue;
		string msg2 = wood_count_red;
		string msg3 = stone_count_blue;
		string msg4 = stone_count_red;
		string msg5 = gold_count_blue;
		string msg6 = gold_count_red;
		//string msg3 = getRules().get_s32("personalgold_" + p.getUsername());

		SColor dcolor = blue.color;

		if (p.getTeamNum() == 1)
		{
			dcolor = red.color;
		}

		//GUI::DrawPane(ul + Vec2f(0, 4), ul + Vec2f(material_display_width+leftside_indent, material_display_height), SColor(255, 200, 200, 200));
		GUI::DrawIcon("mats_ui.png", ul + Vec2f(0,-15));

		//GUI::DrawPane(ul2 + Vec2f(0, 4), ul2 + Vec2f(material_display_width+leftside_indent, material_display_height), SColor(255, 200, 200, 200));
		GUI::DrawIcon("mats_ui.png", ul2 + Vec2f(0,-8));

		//GUI::DrawPane(ul3 + Vec2f(0, 4), ul3 + Vec2f(material_display_width+leftside_indent, material_display_height), SColor(255, 200, 200, 200));
		GUI::DrawIcon("mats_ui.png", ul3 + Vec2f(0,-1));

		//wood
		GUI::DrawIcon(
			icon,
			24, //matwood icon
			icon_dimensions,
			ul2 + Vec2f(leftside_indent + 3, -6),
			1.0f,
			0);
		if (p.getTeamNum() == 0)
		{
			GUI::DrawText(msg1, ul + Vec2f(leftside_indent*1.5+44, material_display_height - 40), color_white);
		}
		else
		{
			GUI::DrawText(msg2, ul + Vec2f(leftside_indent*1.5+44, material_display_height - 40), color_white);
		}

		//stone
		GUI::DrawIcon(
			icon,
			25, //matstone icon
			icon_dimensions,
			ul + Vec2f(leftside_indent + 4, -12),
			1.0f,
			0);
		if (p.getTeamNum() == 0)
		{
			GUI::DrawText(msg3, ul2 + Vec2f(leftside_indent*1.5+44, material_display_height/5.5), color_white);
		}
		else
		{
			GUI::DrawText(msg4, ul2 + Vec2f(leftside_indent*1.5+44, material_display_height/5.5), color_white);
		}

		//gold
		GUI::DrawIcon(
			icon,
			26, //matgold icon
			icon_dimensions,
			ul3 + Vec2f(leftside_indent + 4, 0),
			1.0f,
			0);
		if (p.getTeamNum() == 0)
		{
			GUI::DrawText(msg5, ul3 + Vec2f(leftside_indent*1.5+44, material_display_height/3), color_white);
		}
		else
		{
			GUI::DrawText(msg6, ul3 + Vec2f(leftside_indent*1.5+44, material_display_height/3), color_white);
		}
	}
}