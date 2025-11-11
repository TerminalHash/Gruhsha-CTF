// ControlPoint.as
#define SERVER_ONLY

void onInit(CBlob@ this) {
    this.getShape().SetStatic(true);

    // shape
	Vec2f pos_off(12, 0);
	{
		Vec2f[] shape = { Vec2f(19.0f,  0.0f) - pos_off,
		                  Vec2f(28.0f,  5.2f) - pos_off,
		                  Vec2f(0.0f,  5.2f) - pos_off,
		                  Vec2f(10.0f,  0.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
}

void onTick (CBlob@ this) {
    CRules@ rules = getRules();
    if (rules is null) return;

    if (this.getTickSinceCreated() > 30 && !this.hasTag("nobuild sector added"))
	{
		this.Tag("nobuild sector added");
		Vec2f pos = this.getPosition();

		CMap@ map = getMap();
		map.server_AddSector(pos + Vec2f(-60, -52), pos + Vec2f(68, 36), "no build", "", this.getNetworkID());

		//clear the no build zone so we dont get unbreakable blocks
		for (int x = -60; x < 68; x += 8)
		{
			for (int y = -48; y < 8; y += 8)
			{
				if (map.isTileSolid(pos + Vec2f(x, y)))
				{
					map.server_SetTile(pos + Vec2f(x, y), CMap::tile_empty);
				}
			}
		}

		//map.server_SetTile(pos + Vec2f(-8, 12), CMap::tile_bedrock);
		//map.server_SetTile(pos + Vec2f(0, 12), CMap::tile_bedrock);
		//map.server_SetTile(pos + Vec2f(8, 12), CMap::tile_bedrock);
	}

    if (this.getTickSinceCreated() > 60 && !this.hasTag("holding sector added"))
	{
		this.Tag("holding sector added");
		Vec2f pos = this.getPosition();

		CMap@ map = getMap();
		map.server_AddSector(pos + Vec2f(-52, -48), pos + Vec2f(60, 32), "hold zone", "", this.getNetworkID());
	}

    bool blue_player_overlapping = false;
	bool red_player_overlapping = false;

    bool isControlPointCappedByBlue = getRules().get_bool("cp_controlled_blue");
    bool isControlPointCappedByRed = getRules().get_bool("cp_controlled_red");
    bool isStalemate = getRules().get_bool("koth_stalemate");

	CBlob@[] overlapping;

    // logic for blobs on control point itself
	/*if (getMap().getBlobsInRadius(this.getPosition(), 8.0f, overlapping)) {
		for (int i = 0; i < overlapping.length; ++i) {
			if (overlapping[i].hasTag("player") && overlapping[i].getTeamNum() == 0) {
				blue_player_overlapping = true;
			} else if (overlapping[i].hasTag("player") && overlapping[i].getTeamNum() == 1) {
				red_player_overlapping = true;
			}
		}
	}*/

    // logic for blobs in hold sector
    if (getMap().getBlobsInSector(getMap().getSector("hold zone"), overlapping)) {
        for (int i = 0; i < overlapping.length; ++i) {
            if (overlapping[i].hasTag("player") && !overlapping[i].hasTag("dead") && overlapping[i].getTeamNum() == 0) {
                blue_player_overlapping = true;

				// give coins when players of that team actually holding on point
				if (!isStalemate && isControlPointCappedByBlue) {
					if (getGameTime() % 450 == 0) // every 15 seconds
						overlapping[i].getPlayer().server_setCoins(overlapping[i].getPlayer().getCoins() + 25);
				}
            }

            if (overlapping[i].hasTag("player") && !overlapping[i].hasTag("dead") && overlapping[i].getTeamNum() == 1) {
                red_player_overlapping = true;

				// give coins when players of that team actually holding on point
				if (!isStalemate && isControlPointCappedByRed) {
					if (getGameTime() % 450 == 0) // every 15 seconds
						overlapping[i].getPlayer().server_setCoins(overlapping[i].getPlayer().getCoins() + 25);
				}
            }
        }
    }

    // part of main cap/control logic
     if (!isStalemate) {
         if (blue_player_overlapping) {
            rules.set_bool("blue_on_cp", true);
         } else {
            rules.set_bool("blue_on_cp", false);
        }

        if (red_player_overlapping) {
            rules.set_bool("red_on_cp", true);
        } else {
            rules.set_bool("red_on_cp", false);
        }
    }

    // stalemate check
    if (red_player_overlapping && blue_player_overlapping) {
        rules.set_bool("koth_stalemate", true);
		rules.Sync("koth_stalemate", true);
    } else {
		rules.set_bool("koth_stalemate", false);
		rules.Sync("koth_stalemate", true);
	}

}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob) {
    return false;
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob) {
    return false;
}
