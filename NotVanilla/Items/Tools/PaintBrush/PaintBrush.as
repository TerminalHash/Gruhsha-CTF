#include "Hitters"
#include "ParticleSparks"
#include "Knocked"
#include "RunnerCommon"

u32 time_between_attacks = 30;
void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
	if (this.getSprite() !is null) this.getSprite().SetRelativeZ(201);
}

void onTick(CBlob@ this)
{
	bool flip = this.isFacingLeft();
	f32 flip_factor = flip ? -1 : 1;
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null) return;
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;

		u32 till_next_attack = (this.get_u32("next attack")-getGameTime());
		bool ready = this.get_u32("next attack") < getGameTime();
		
		CSprite@ sprite = this.getSprite();
		if (sprite !is null && false)
		{
			sprite.ResetTransform();
			sprite.RotateBy(90*flip_factor, Vec2f(0, 6.5));
			sprite.TranslateBy(Vec2f(-4*flip_factor, -4));
			sprite.RotateBy((90*flip_factor)*(Maths::Max(till_next_attack,0)/time_between_attacks)*(ready?0:1), Vec2f(-8.5*flip_factor, 2));
		}

		if (getKnocked(holder) <= 0 && !holder.isAttached()) //Cant paint while stunned
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (!ready) return;
				Vec2f pos = holder.getAimPos();
				
				if ((pos - this.getPosition()).getLength() < 40) //Range
				{
					getMap().rayCastSolidNoBlobs(this.getPosition(), pos, pos);
					CBlob@ blob = getMap().getBlobAtPosition(pos);
					u8 target_team = Maths::Min(7, holder.getTeamNum());
					if (target_team == 7)
						target_team = -1;
					if (blob !is null && blob.getTeamNum()!=target_team)
					{
						blob.server_setTeamNum(target_team);
						this.set_u32("next attack", getGameTime() + time_between_attacks);
					}
				}
			}
		}
	}
	else {
		CSprite@ sprite = this.getSprite();
		if (sprite !is null) sprite.ResetTransform();
	}
}