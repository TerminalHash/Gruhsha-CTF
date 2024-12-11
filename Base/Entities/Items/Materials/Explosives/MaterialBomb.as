void onInit(CBlob@ this) {
    this.set_u16("decay time", 300);
    this.getCurrentScript().runFlags |= Script::remove_after_this;

    if (getHoliday() == Holidays::Christmas) {
        this.AddScript("SetTeamToCarrier.as");
    }
}