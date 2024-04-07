void onInit(CBlob@ this)
{
	this.set_u32("next_squeak", XORRandom(300));
}

void onTick(CBlob@ this)
{
	if (this is null) return;
	if (this.hasTag("dead")) return;

	string username = this.getPlayer().getUsername();

	if (username == "vladkvs193")
	{
		if ((getGameTime() + this.get_u32("next_squeak")) % 400 == 1 && !this.hasTag("dead"))
		{
			int random = XORRandom(4) + 1;

			Sound::Play("Squeak" + random + ".ogg", this.getPosition(), 2.0f);
			this.set_u32("next_squeak", XORRandom(200));
		}
	}
	else
	{
		return;
	}
}