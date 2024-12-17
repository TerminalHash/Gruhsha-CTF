// StrangeButton.as
const int fridges_to_spawn = 1;

void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
	
	this.server_setTeamNum(-1);
	//team - force blue unless special
	int team = (this.exists("team colour") ? this.get_u8("team colour") : 0);

	this.addCommandID("spawn above player");
	this.addCommandID("spawn on middle");
	this.addCommandID("spawn on cursor position");
}

void onInit(CSprite@ this)
{
	this.ScaleBy(0.5f, 0.5f);
}

void onTick(CBlob@ this) {
	if (this.isAttachedToPoint("PICKUP")) {
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

		CBlob@ holder = point.getOccupied();
		if (holder is null || holder.isAttached()) return;

		CControls@ controls = holder.getControls();

		if (controls.isKeyJustPressed(KEY_MBUTTON)) {
			this.SendCommand(this.getCommandID("spawn on middle"));
		}

		if (controls.isKeyJustPressed(KEY_RBUTTON)) {
			this.SendCommand(this.getCommandID("spawn above player"));
		}

		if (controls.isKeyJustPressed(KEY_LBUTTON)) {
			this.SendCommand(this.getCommandID("spawn on cursor position"));
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) {
	this.server_setTeamNum(attached.getTeamNum());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) {
	if (cmd == this.getCommandID("spawn on cursor position") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		CBlob@ fridge = server_CreateBlob("fridge", caller.getTeamNum(), Vec2f(caller.getAimPos().x, 0));
		if (fridge !is null) {
			fridge.SetDamageOwnerPlayer(caller.getPlayer());
		}

		this.server_Die();
	} else if (cmd == this.getCommandID("spawn on middle") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		CMap@ map = getMap();
		const f32 mapCenter = map.tilemapwidth * map.tilesize * 0.5;

		CBlob@ fridge = server_CreateBlob("fridge", caller.getTeamNum(), Vec2f(mapCenter, 0));
		if (fridge !is null) {
			fridge.SetDamageOwnerPlayer(caller.getPlayer());
		}

		this.server_Die();
	} else if (cmd == this.getCommandID("spawn above player") && isServer()) {
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		CBlob@ fridge = server_CreateBlob("fridge", caller.getTeamNum(), Vec2f(caller.getPosition().x, 0));
		if (fridge !is null) {
			fridge.SetDamageOwnerPlayer(caller.getPlayer());
		}

		this.server_Die();
	}
}