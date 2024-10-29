#include "ArrowCommon.as"
#include "HolidayCommon.as";

void onInit(CBlob@ this)
{
  this.set_u16("decay time", 300);

  this.getCurrentScript().runFlags |= Script::remove_after_this;

  setArrowHoverRect(this);

  this.set_f32("important-pickup", 30.0f);
}

void onTick(CSprite@ this)
{
	if (this is null) return;

    if (getRules().get_string(holiday_prop) == "Halloween") {
        this.SetAnimation("default_halloween");
        this.getBlob().SetInventoryIcon("Materials.png", 57, Vec2f(16,16));
    } else {
        this.SetAnimation("default");
        this.getBlob().SetInventoryIcon("Materials.png", 5, Vec2f(16,16));
    }
}