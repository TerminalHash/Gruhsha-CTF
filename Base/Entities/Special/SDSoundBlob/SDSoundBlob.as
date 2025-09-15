// SDSoundBlob.as
/*
	autistic solution for sudden death sound.
*/

void onInit(CBlob@ this) {
	this.getCurrentScript().tickFrequency = 10;
}

void onTick(CBlob@ this) {
	// dont die while it warmup lol
	if (getRules().getCurrentState() == WARMUP || getRules().get_bool("is_warmup")) return;

	s32 end_in = getRules().get_s32("end_in");
	
	if (end_in <= 300)
		this.server_Die();
}

void onDie(CBlob@ this) {
	//if (isClient() && getLocalPlayer() !is null)
		Sound::Play("suddendeath.ogg");
}