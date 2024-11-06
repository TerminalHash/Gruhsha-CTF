#include "HolidayCommon.as";

void onInit(CBlob@ this)
{
	this.set_string("eat sound", "/Heart.ogg");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.server_SetTimeToDie(40);
	this.Tag("ignore_arrow");
	this.Tag("ignore_saw");
}

void onInit(CSprite@ this) {
	if (getRules().get_string(holiday_prop) == "Halloween") {
		this.SetAnimation("default_halloween");
	} else {
		this.SetAnimation("default");
	}
}

