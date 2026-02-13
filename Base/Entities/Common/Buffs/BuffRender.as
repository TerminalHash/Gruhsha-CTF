// BuffRender.as

void onRender(CSprite@ this) {
    CBlob@ blob = this.getBlob();
	if (blob is null) return;

	// ice bomb effect
    if (blob.hasTag("icy") && blob.get_s32("icy time") > 0) {
        blob.RenderForHUD(Vec2f(0, 0), 0, SColor(255, 55, 50, 185), RenderStyle::additive);
    }

    // jarate effect
    if (blob.hasTag("peed") && blob.get_s32("peed time") > 0) {
        blob.RenderForHUD(Vec2f(0, 0), 0, SColor(255, 180, 90, 0), RenderStyle::additive);
    }
}
