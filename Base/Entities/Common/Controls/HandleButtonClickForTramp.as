// press action1 to click buttons
void HandleButtonClickKey(CBlob@ this, AttachmentPoint@ point = null)
{
	if (getHUD().hasButtons())
	{
		if (point !is null)
		{
			if ((point.isKeyJustPressed(key_action1)) && !point.isKeyPressed(key_pickup))
			{
				ButtonOrMenuClick(this, this.getAimPos(), false, true);
				this.set_bool("release click", false);
			}
		}
		else
		{
			if ((this.isKeyJustPressed(key_action1)) && !this.isKeyPressed(key_pickup))
			{
				ButtonOrMenuClick(this, this.getAimPos(), false, true);
				this.set_bool("release click", false);
			}
		}
	}
}