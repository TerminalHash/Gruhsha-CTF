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

	string painsound = this.get_string("pain_sound");
	string painsoundshort = this.get_string("pain_sound_short");
	string custon_sounds = getRules().get_string("custom_death_and_pain_sounds");

	if (damage > 1.45f) //sound for anything 2 heart+
	{
		if (custon_sounds == "off")
		{
			Sound::Play("ArgLong.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play(painsound, this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}
	else if (damage > 0.45f)
	{
		if (custon_sounds == "off")
		{
			Sound::Play("ArgShort.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play(painsoundshort, this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}
	else if (damage > 0.1f)
	{
		if (custon_sounds == "off")
		{
			Sound::Play("ArgShort.ogg", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
		else
		{
			Sound::Play(painsoundshort, this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		}
	}

	return damage;
}

// HACK: set the pain sound for the players by writing it into strings of blob
void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (this is null) return;
	if (player is null) return;
	if (!getNet().isServer()) return;

	// Default pain sound
	this.set_string("pain_sound", "ArgLong.ogg");
	this.set_string("pain_sound_short", "ArgShort.ogg");

	// Custom pain sounds
	if (player.getUsername() == "TerminalHash")
	{
		this.set_string("pain_sound", "th_pain_long.ogg");
		this.set_string("pain_sound_short", "th_pain_short.ogg");
	}
	else if (player.getUsername() == "vladkvs193")
	{
		this.set_string("pain_sound", "vladkvs_pain_long.ogg");
		this.set_string("pain_sound_short", "vladkvs_pain_short.ogg");
	}
	else if (player.getUsername() == "kusaka79")
	{
		this.set_string("pain_sound", "v1_p_long.ogg");
		this.set_string("pain_sound_short", "v1_p_short.ogg");
	}
	else if (player.getUsername() == "arsenpip")
	{
		this.set_string("pain_sound", "aidic_pain_long.ogg");
		this.set_string("pain_sound_short", "aidic_pain_short.ogg");
	}
	else if (player.getUsername() == "H1996R")
	{
		this.set_string("pain_sound", "hahalios_pain_long.ogg");
		this.set_string("pain_sound_short", "hahalios_pain_short.ogg");
	}
}