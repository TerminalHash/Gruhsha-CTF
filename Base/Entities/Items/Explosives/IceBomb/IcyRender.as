// IcyRender.as

void onRender(CSprite@ this) {
    CBlob@ blob = this.getBlob();
	if (blob is null) return;

    // Player doesnt frozen - script not allowed to work
    if (!blob.hasTag("icy")) return;

    if (blob.hasTag("icy") && blob.get_s32("icy time") > 0) {
        blob.RenderForHUD(Vec2f(0, 0), 0, SColor(255, 55, 50, 185), RenderStyle::additive);
    }
}