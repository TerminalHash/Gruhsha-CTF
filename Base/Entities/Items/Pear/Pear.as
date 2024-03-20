void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.Tag("ignore_arrow");
	this.Tag("ignore_saw");
}
