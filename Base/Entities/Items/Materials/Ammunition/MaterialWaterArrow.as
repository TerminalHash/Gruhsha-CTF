#include "ArrowCommon.as"
#include "HolidaySprites.as";

string materials_file_name;

void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16("decay time", 180);
  }

  this.maxQuantity = 1;

  this.getCurrentScript().runFlags |= Script::remove_after_this;

  setArrowHoverRect(this);
}

void onInit(CSprite@ this) {
	if (isAnyHoliday()) {
		materials_file_name = getHolidayVersionFileName("Materials");
		this.ReloadSprite(materials_file_name);
	}
}