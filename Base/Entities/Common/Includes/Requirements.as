#include "ResearchCommon.as"

string getButtonRequirementsText(CBitStream& inout bs, bool missing)
{
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;
	bs.ResetBitIndex();

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);
		string quantityColor;

		if (missing)
		{
			quantityColor = "$RED$";
		}
		else
		{
			quantityColor = "$GREEN$";
		}

		if (requiredType == "blob")
		{
			if (quantity > 0)
			{
				text += quantityColor;
				text += quantity;
				text += quantityColor;
				text += " ";
			}
			text += "$"; text += name; text += "$";
			text += " ";
			text += quantityColor;
			text += getTranslatedString(friendlyName);
			text += quantityColor;
			// text += " required.";
			text += "\n\n";
		}
		else if (requiredType == "tech" && missing)
		{
			text += " \n$"; text += name; text += "$ ";
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			text += "\n\ntechnology required.\n";
		}
		else if (requiredType == "not tech" && missing)
		{
			text += " \n";
			text += quantityColor;
			text += friendlyName;
			text += " technology already acquired.\n";
			text += quantityColor;
		}
		else if (requiredType == "coin")
		{
			text += getTranslatedString("{COINS_QUANTITY} $COIN$ required\n\n").replace("{COINS_QUANTITY}", "" + quantity);
		}
		else if (requiredType == "hurt")
		{
			text += getTranslatedString("$HEART$ Must be hurt\n");
		}
		else if (requiredType == "no more" && missing)
		{
			text += quantityColor;
			text += "Only " + quantity + " " + friendlyName + " per-team possible. \n";
			text += quantityColor;
		}
		else if (requiredType == "no less" && missing)
		{
			text += quantityColor;
			text += "At least " + quantity + " " + friendlyName + " required. \n";
			text += quantityColor;
		}
		else if (requiredType == "builder")
		{
			text += quantityColor;
			text += "You should be a builder ";
			text += "builderfleximage";
			text += " \n\n";
			text += quantityColor;
		}
		else if (requiredType == "buy delay" && missing)
		{
			text += quantityColor;
			text += "You must wait " + quantity + " seconds before buy next " + friendlyName + "!";
			text += " \n\n";
			text += quantityColor;
		}
	}

	return text;
}

void SetItemDescription(CGridButton@ button, CBlob@ caller, CBitStream &in reqs, const string& in description, CInventory@ anotherInventory = null)
{
	if (button !is null && caller !is null && caller.getInventory() !is null)
	{
		CBitStream missing;

		if (hasRequirements(caller.getInventory(), anotherInventory, reqs, missing))
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(reqs, false);
		}
		else
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(missing, true);
			button.SetEnabled(false);
		}
	}
}

// read / write

void AddRequirement(CBitStream &inout bs, const string &in req, const string &in blobName, const string &in friendlyName, u16 &in quantity = 1)
{
	bs.write_string(req);
	bs.write_string(blobName);
	bs.write_string(friendlyName);
	bs.write_u16(quantity);
}

void AddHurtRequirement(CBitStream &inout bs)
{
	bs.write_string("hurt");
}

bool ReadRequirement(CBitStream &inout bs, string &out req, string &out blobName, string &out friendlyName, u16 &out quantity)
{
	if (!bs.saferead_string(req))
	{
		return false;
	}

	if (req == "hurt")
	{
		return true;
	}

	if (!bs.saferead_string(blobName))
	{
		return false;
	}

	if (!bs.saferead_string(friendlyName))
	{
		return false;
	}

	if (!bs.saferead_u16(quantity))
	{
		return false;
	}

	return true;
}

bool hasRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs, CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	string req, blobName, friendlyName;
	u16 quantity = 0;
	missingBs.Clear();
	bs.ResetBitIndex();
	bool has = true;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);

		if (req == "blob")
		{
			if (blobName == "mat_wood" || blobName == "mat_stone")
			{
				CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;

				if (player1 !is null)
				{
					const u16 left = getRules().get_u16("barrier_x1");
					const u16 right = getRules().get_u16("barrier_x2");

					u8 team = player1.getTeamNum();

					string needed = "teamwood";
					if (blobName == "mat_stone") needed = "teamstone";

					// dynamic requirements for building
					if (player1.getBlob().getPosition().x >= left && player1.getBlob().getPosition().x <= right)
					{
						if (getRules().hasTag("sudden death")) {
							if (getRules().get_s32(needed + team) < quantity * 1.4) {
								AddRequirement(missingBs, req, blobName, friendlyName, quantity);
								has = false;
							}
						} else {
							if (getRules().get_s32(needed + team) < quantity * 1.2) {
								AddRequirement(missingBs, req, blobName, friendlyName, quantity);
								has = false;
							}
						}
					}
					else
					{
						if (getRules().get_s32(needed + team) < quantity)
						{
							AddRequirement(missingBs, req, blobName, friendlyName, quantity);
							has = false;
						}
					}
				}
			}
			else
			{
				uint sum;

				if (inventoryOnly)
				{
					sum = (inv1 !is null ? inv1.getCount(blobName) : 0) + (inv2 !is null ? inv2.getCount(blobName) : 0);
				}
				else
				{
					sum = (inv1 !is null ? inv1.getBlob().getBlobCount(blobName) : 0) + (inv2 !is null ? inv2.getBlob().getBlobCount(blobName) : 0);
				}


				if (sum < quantity)
				{
					AddRequirement(missingBs, req, blobName, friendlyName, quantity);
					has = false;
				}
			}
		}
		//else if (req == "tech") in  Requirements_Tech
		else if (req == "coin")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			u16 sum = (player1 !is null ? player1.getCoins() : 0) + (player2 !is null ? player2.getCoins() : 0);
			if (sum < quantity)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "hurt")
		{
			CBlob@ blob = inv1 !is null ? inv1.getBlob() : null;
			if (blob is null || blob.getHealth() >= blob.getInitialHealth())
			{
				AddHurtRequirement(missingBs);
				has = false;
			}
		}
		else if ((req == "no more" || req == "no less") && inv1 !is null)
		{
			int teamNum = inv1.getBlob().getTeamNum();
			int count = 0;
			CBlob@[] blobs;
			if (getBlobsByName(blobName, @blobs))
			{
				for (uint step = 0; step < blobs.length; ++step)
				{
					CBlob@ blob = blobs[step];
					if (blob.getTeamNum() == teamNum)
					{
						count++;
					}
				}
			}

			if ((req == "no more" && count >= quantity) || (req == "no less" && count < quantity))
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "builder")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			if (player1 !is null)
			{
				if (player1.getBlob().getName() != "builder" && player1.getUsername() != getRules().get_string("team_" + player1.getTeamNum() + "_leader"))
				{
					AddRequirement(missingBs, req, blobName, friendlyName, quantity);
					has = false;
				}

			}
		}
		else if (req == "buy delay")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			if (player1 !is null && 
				getRules().exists(player1.getUsername() + "_bought_item_" + blobName) &&
				(getGameTime() < (getRules().get_s32(player1.getUsername() + "_bought_item_" + blobName) + (quantity * getTicksASecond()))) &&
				getRules().get_s32(player1.getUsername() + "_bought_item_" + blobName) != 0)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
	}
	missingBs.ResetBitIndex();
	bs.ResetBitIndex();
	return has;
}

bool hasRequirements(CInventory@ inv, CBitStream &inout bs, CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	return hasRequirements(inv, null, bs, missingBs, inventoryOnly);
}

void server_TakeRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs)
{
	if (!getNet().isServer())
	{
		return;
	}

	string req, blobName, friendlyName;
	u16 quantity;
	bs.ResetBitIndex();
	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);

		if (req == "blob")
		{
			if (blobName == "mat_wood" || blobName == "mat_stone")
			{
				CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;

				if (player1 !is null && isServer())
				{
					const u16 left = getRules().get_u16("barrier_x1");
					const u16 right = getRules().get_u16("barrier_x2");

					u8 team = player1.getTeamNum();

					string needed = "teamwood";
					if (blobName == "mat_stone") needed = "teamstone";

					// dynamic requirements for building
					if (player1.getBlob().getPosition().x >= left && player1.getBlob().getPosition().x <= right && !getRules().hasTag("sudden death")) {
						getRules().sub_s32(needed + team, quantity * 1.2);
						getRules().Sync(needed + team, true);
					} else if (player1.getBlob().getPosition().x >= left && player1.getBlob().getPosition().x <= right && getRules().hasTag("sudden death")) {
						getRules().sub_s32(needed + team, quantity * 1.35);
						getRules().Sync(needed + team, true);
					} else {
						getRules().sub_s32(needed + team, quantity);
						getRules().Sync(needed + team, true);
					}
				}
			}
			else
			{
				u16 taken = 0;
				if (inv1 !is null)
				{
					taken += inv1.getBlob().TakeBlob(blobName, quantity);
				}

				if (inv2 !is null && taken < quantity)
				{
					inv2.getBlob().TakeBlob(blobName, quantity - taken);
				}
			}
		}
		else if (req == "coin") // TODO...
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			int taken = 0;
			if (player1 !is null)
			{
				taken = Maths::Min(player1.getCoins(), quantity);
				player1.server_setCoins(player1.getCoins() - taken);
			}
			if (player2 !is null)
			{
				taken = quantity - taken;
				taken = Maths::Min(player2.getCoins(), quantity);
				player2.server_setCoins(player2.getCoins() - taken);
			}
		}
		else if (req == "buy delay")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			if (player1 !is null)
			{
				getRules().set_s32(player1.getUsername() + "_bought_item_" + blobName, getGameTime());
				getRules().Sync(player1.getUsername() + "_bought_item_" + blobName, true);
			}
		}
	}

	bs.ResetBitIndex();
}

void server_TakeRequirements(CInventory@ inv, CBitStream &inout bs)
{
	server_TakeRequirements(inv, null, bs);
}
