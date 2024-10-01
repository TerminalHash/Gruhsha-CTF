#include "EmotesCommon.as";

void defaultIdleAnim(CSprite@ this, CBlob@ blob, int direction)
{
	if (blob.isKeyPressed(key_down))
	{
		if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
			this.SetAnimation("crouch_h");
		} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
			this.SetAnimation("crouch_noarm");
		} else {
			this.SetAnimation("crouch");
		}
	}
	else if (is_emote(blob, true))
	{
		this.SetAnimation("point");
		this.animation.frame = 1 + direction;
	}
	else
	{
		if (blob.hasTag("hammer in hand") && !blob.hasTag("blob anim noarm")) {
			this.SetAnimation("default_h");
		} else if (blob.hasTag("blob anim noarm") && !blob.hasTag("hammer in hand")) {
			this.SetAnimation("default_noarm");
		} else {
			this.SetAnimation("default");
		}
	}
}
