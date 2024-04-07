void onInit(CBlob@ this)
{
	this.set_u32("next_squeak", XORRandom(300));
}

void onTick(CBlob@ this)
{
	if (this.getPlayer() is null) return;
	if (this.hasTag("dead")) return;

	if ((getGameTime() + this.get_u32("next_squeak")) % 400 == 1 && !this.hasTag("dead") && this.getPlayer().getUsername() == "vladkvs193")
	{
		int random = XORRandom(4) + 1;

		Sound::Play("Squeak" + random + ".ogg", this.getPosition(), 2.0f);
		this.set_u32("next_squeak", XORRandom(200));
	}
}