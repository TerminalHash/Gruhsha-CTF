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
		if (map.getBlobsInRadius(mouse_pos, radius, @targets)) {
			for (int i = 0; i < targets.length(); i++) {
				CBlob@ blob = targets[i];
				if (blob.getInventory() !is null) {
					if (blob.getTeamNum() == this.getBlob().getTeamNum()) {
						DrawInventoryOfBlob(blob);
						DrawCoinsOnHUD(blob);
						break;
					}
				}
			}
		}	
	}
}

void DrawCoinsOnHUD(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;

	int coins = player.getCoins();
	Vec2f tl = this.getControls().getMouseScreenPos();

	if (coins > 0) {
		GUI::DrawIconByName("$COIN$", tl + Vec2f(-80, -60));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, tl + Vec2f(-75, -30), color_white);
	}
}

void DrawInventoryOfBlob(CBlob@ this)
{
	CControls@ controls = this.getControls();
	if (controls is null) return;

	SColor col;
	CInventory@ inv = this.getInventory();
	string[] drawn;
	Vec2f tl = this.getControls().getMouseScreenPos();
	Vec2f offset (-40, -60);
	u8 j = 0;
	for (int i = 0; i < inv.getItemsCount(); i++) {
		CBlob@ item = inv.getItem(i);
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