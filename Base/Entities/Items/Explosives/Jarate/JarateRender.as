// JarateRender.as

void onRender(CSprite@ this) {
    CBlob@ blob = this.getBlob();
	if (blob is null) return;

    // Player doesnt frozen - script not allowed to work
    if (!blob.hasTag("peed")) return;

    if (blob.hasTag("peed") && blob.get_s32("peed time") > 0) {
        blob.RenderForHUD(Vec2f(0, 0), 0, SColor(255, 180, 90, 0), RenderStyle::additive);
    }
}