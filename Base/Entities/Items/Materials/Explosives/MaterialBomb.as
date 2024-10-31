#include "HolidayCommon.as";

void onInit(CBlob@ this) {
    this.set_u16("decay time", 300);
    this.getCurrentScript().runFlags |= Script::remove_after_this;

    if (getRules().get_string(holiday_prop) == "Christmas") {
        this.AddScript("SetTeamToCarrier.as");
    }
}

void onTick(CSprite@ this) {
	if (this is null) return;

    if (getRules().get_string(holiday_prop) == "Halloween") {
        this.SetAnimation("default_halloween");
        this.getBlob().SetInventoryIcon("Materials.png", 56, Vec2f(16,16));
    } else if (getRules().get_string(holiday_prop) == "Christmas") {
        this.SetAnimation("default_christmas");
        this.getBlob().SetInventoryIcon("Materials.png", 59, Vec2f(16,16));
    } else {
        this.SetAnimation("default");
        this.getBlob().SetInventoryIcon("Materials.png", 13, Vec2f(16,16));
    }
}