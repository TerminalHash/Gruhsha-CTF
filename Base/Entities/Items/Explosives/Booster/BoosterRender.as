// BoosterRender.as

void onRender(CSprite@ this) {
    CBlob@ blob = this.getBlob();
	if (blob is null) return;

    // Player doesnt frozen - script not allowed to work
    if (!blob.hasTag("boosted with air")) return;

    if (blob.hasTag("boosted with air") && blob.get_s32("boosted time") < (getGameTime() + (5 * 30))) {
        blob.RenderForHUD(Vec2f(0, 0), 0, SColor(255, 255, 255, 255), RenderStyle::additive);
    }
}