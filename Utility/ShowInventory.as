#include "BindingsCommon.as"

void onRender(CSprite@ this)
{
	CRules@ rules = getRules();
	if (rules is null) return;

	CMap@ map = getMap();
	CPlayer@ player = this.getBlob().getPlayer();
	CControls@ controls = this.getBlob().getControls();

	if (player is null || map is null || controls is null) return;

	Vec2f mouse_pos = controls.getMouseWorldPos();

	if (b_KeyPressed("showinv")) {
		CBlob@[] targets;
		f32 radius = 16.0f;
		//GUI::DrawCircle(this.getBlob().getInterpolatedPosition(), radius, color_white);
		if (map.getBlobsAtPosition(mouse_pos, @targets)) {
		//if (map.getBlobsInRadius(mouse_pos, radius, @targets)) {
			for (int i = 0; i < targets.length(); i++) {
				CBlob@ blob = targets[i];
				if (blob is null) continue;

				if (blob.getInventory() !is null) {
					if (blob.getTeamNum() == this.getBlob().getTeamNum()) {
						if (blob.getPlayer() is null) return;

						int coins = blob.getPlayer().getCoins();
						CInventory@ inv = blob.getInventory();
						if (inv is null) return;

						if (blob.hasTag("player")) {
							Vec2f tl = controls.getMouseScreenPos();

							if (coins > 0) {
								GUI::DrawIconByName("$COIN$", tl + Vec2f(-80, -60));
								GUI::SetFont("menu");
								GUI::DrawText("" + coins, tl + Vec2f(-75, -30), color_white);
							}
						}

						if (inv !is null) {
							string[] drawn;
							SColor col;
							Vec2f tl = controls.getMouseScreenPos();
							Vec2f offset (-40, -60);
							u8 j = 0;

							for (int i = 0; i < inv.getItemsCount(); i++) {
								CBlob@ item = inv.getItem(i);
								if (item is null) continue;

								const string name = item.getName();

								if (drawn.find(name) == -1) {

									if (j % 2 == 0 && j > 0) {
										offset.x += 50;
									} else if (j > 0) offset.x += 50;

									j++;

									Vec2f tempoffset(0,0);
									if (item.hasTag("material")) tempoffset.x = 5;

									const int quantity = blob.getBlobCount(name);
									drawn.push_back(name);

									GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, tl + offset + tempoffset, 1.0f);

									f32 ratio = float(quantity) / float(item.maxQuantity);
									col = SColor(255, 255, 255, 255);

									GUI::SetFont("menu");
									Vec2f dimensions(0,0);
									string disp = "" + quantity;
									GUI::GetTextDimensions(disp, dimensions);
									GUI::DrawText(disp, tl + Vec2f(offset.x + 10, offset.y + 30), col);
								}
							}
						}

						//DrawCoinsOnHUD(blob);
						//DrawInventoryOfBlob(blob);

						// DEBUG
						//GUI::DrawText("Poggers " + blob.getConfig(), mouse_pos, color_white);
						break;
					}
				}
			}
		}
	}
}

/*void onTick(CSprite@ this) {
	CRules@ rules = getRules();
	if (rules is null) return;

	CMap@ map = getMap();
	CPlayer@ player = this.getBlob().getPlayer();
	CControls@ controls = this.getBlob().getControls();

	if (player is null || map is null || controls is null) return;

	Vec2f mouse_pos = controls.getMouseWorldPos();

	if (b_KeyPressed("showinv")) {
		CBlob@[] targets;
		f32 radius = 16.0f;
		if (map.getBlobsAtPosition(mouse_pos, @targets)) {
		//if (map.getBlobsInRadius(mouse_pos, radius, @targets)) {
			for (int i = 0; i < targets.length(); i++) {
				CBlob@ blob = targets[i];
				if (blob is null) continue;

				if (blob.getInventory() !is null) {
					if (blob.getTeamNum() == this.getBlob().getTeamNum()) {
						printf("Pidor " + targets.length());
						break;
					}
				}
			}
		}
	}
}*/

void DrawCoinsOnHUD(CBlob@ this) {
	// coins can be shown only for players
	if (!this.hasTag("player")) return;

	CControls@ controls = this.getControls();
	if (controls is null) return;

	CPlayer@ player = this.getPlayer();
	if (player is null) return;

	int coins = player.getCoins();
	Vec2f tl = controls.getMouseScreenPos();

	if (coins > 0) {
		GUI::DrawIconByName("$COIN$", tl + Vec2f(-80, -60));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, tl + Vec2f(-75, -30), color_white);
	}
}

void DrawInventoryOfBlob(CBlob@ this) {
	CControls@ controls = this.getControls();
	if (controls is null) return;

	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	string[] drawn;
	SColor col;
	Vec2f tl = controls.getMouseScreenPos();
	Vec2f offset (-40, -60);
	u8 j = 0;

	for (int i = 0; i < inv.getItemsCount(); i++) {
		CBlob@ item = inv.getItem(i);
		if (item is null) continue;

		const string name = item.getName();

		if (drawn.find(name) == -1) {

			if (j % 2 == 0 && j > 0) {
				offset.x += 50;
			} else if (j > 0) offset.x += 50;

			j++;

			Vec2f tempoffset(0,0);
			if (item.hasTag("material")) tempoffset.x = 5;

			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);

			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, tl + offset + tempoffset, 1.0f);

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = SColor(255, 255, 255, 255);

			GUI::SetFont("menu");
			Vec2f dimensions(0,0);
			string disp = "" + quantity;
			GUI::GetTextDimensions(disp, dimensions);
			GUI::DrawText(disp, tl + Vec2f(offset.x + 10, offset.y + 30), col);
		}
	}
}