#define CLIENT_ONLY

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getPlayer() is null) return damage;

	if (this is hitterBlob)
	{
		return damage;
	}

	if (this.hasTag("dead"))
	{
		return damage;
	}

	if (damage > 1.45f) //sound for anything 2 heart+
	{
		if (this.getPlayer() !is null && this.getPlayer().getUsername() == "TerminalHash")
		{
			Sound::Play("ai1.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play("ArgLong.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}
	else if (damage > 0.45f)
	{
		if (this.getPlayer() !is null && this.getPlayer().getUsername() == "TerminalHash")
		{
			Sound::Play("oi2.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play("ArgShort.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}
	else if (damage > 0.1f)
	{
		if (this.getPlayer() !is null && this.getPlayer().getUsername() == "TerminalHash")
		{
			Sound::Play("oi2.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play("ArgShort.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}

	return damage;
}
