void onRender(CSprite@ this)
{
	if (!isClient()) return;
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getInterpolatedPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	string durability = blob.get_s32("jump_prop");
	CControls@ controls = getLocalPlayer().getControls();
	if (controls.isKeyPressed(KEY_LCONTROL) && mouseOnBlob)
	{
		GUI::SetFont("menu");
		GUI::DrawTextCentered(durability, blob.getScreenPos() + Vec2f(0, -30), color_white);
	}
}
