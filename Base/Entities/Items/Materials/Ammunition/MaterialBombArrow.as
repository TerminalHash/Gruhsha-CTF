#include "ArrowCommon.as"
#include "HolidaySprites.as";

string materials_file_name;

void onInit(CBlob@ this) {
    this.set_u16("decay time", 300);
    this.getCurrentScript().runFlags |= Script::remove_after_this;

    setArrowHoverRect(this);

    this.set_f32("important-pickup", 30.0f);

    if (getRules().get_string(holiday_prop) == "Christmas") {
        this.AddScript("SetTeamToCarrier.as");
    }
}

void onInit(CSprite@ this) {
	if (isAnyHoliday()) {
		materials_file_name = getHolidayVersionFileName("Materials");
		this.ReloadSprite(materials_file_name);
	}
}