// ArcherBackStabDebug.as

void onTick(CBlob@ this) {
    CBlob@[] overlapping;

    // logic for blobs on control point itself
	if (getMap().getBlobsInRadius(this.getPosition(), 9.0f, overlapping)) {
		for (int i = 0; i < overlapping.length; ++i) {
            // dont count our player
            if (overlapping[i].isMyPlayer()) continue;
            // dont count our teammates
            if (overlapping[i].getTeamNum() == this.getTeamNum()) continue;

            if (overlapping[i].getConfig() == "archer" ||
                overlapping[i].getConfig() == "builder" ||
                overlapping[i].getConfig() == "knight" ||
                overlapping[i].getConfig() == "crusher" ||
                overlapping[i].getConfig() == "rogue" ||
                overlapping[i].getConfig() == "flail") {

                if (getGameTime() % 60 == 0) {
                    printf("---------------------");
                    printf("Current overlapping blob " + overlapping[i].getConfig());
                }
            }
		}
	}
}

void onRender(CSprite@ this) {
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;

	CBlob@ localBlob = local.getBlob();
	if (localBlob is null) return;

	Vec2f localPos = localBlob.getPosition();

	GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(localPos), (9.0f * 3) * getCamera().targetDistance, SColor(255, 255, 55, 55));
}