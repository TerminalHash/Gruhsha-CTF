#include "Hitters"
#include "ParticleSparks"
#include "Knocked"
#include "RunnerCommon"
#include "Requirements"
//#include "KIWI_Locales"

u32 time_between_attacks = 10;
void onInit(CBlob@ this)
{
	//this.setInventoryName(Names::wrench);
	
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
	if (this.getSprite() !is null) this.getSprite().SetRelativeZ(201);
}

CBitStream getHealReqs()
{
	CBitStream heal_reqs;
	heal_reqs.write_string("blob");
	heal_reqs.write_string("mat_steel");
	heal_reqs.write_string("friendlyName");
	heal_reqs.write_u16(0);
	return heal_reqs;
}

void onTick(CBlob@ this)
{
	bool flip = this.isFacingLeft();
	f32 flip_factor = flip ? -1 : 1;
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;
		RunnerMoveVars@ moveVars;
		if (!holder.get("moveVars", @moveVars))
		{
			return;
		}
		
		CBitStream missing;
		CBitStream heal_reqs = getHealReqs();

		u32 till_next_attack = (this.get_u32("next attack")-getGameTime());
		bool ready = this.get_u32("next attack") < getGameTime();
		if (!(this.get_u32("next attack")+2 < getGameTime())) {
			//no walking while fixing a thing
			point.SetKeysToTake(key_inventory | key_pickup | key_action3 | key_action1 | key_right | key_left | key_down | key_up);
		}
		else
		{
			point.SetKeysToTake(0);
		}
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.ResetTransform();
			sprite.RotateBy(90*flip_factor, Vec2f(0, 6.5));
			sprite.TranslateBy(Vec2f(-4*flip_factor, -4));
			sprite.RotateBy((90*flip_factor)*(Maths::Max(till_next_attack,0)/time_between_attacks)*(ready?0:1), Vec2f(-8.5*flip_factor, 2));
		}
		
		if (!hasRequirements(holder.getInventory(), null, heal_reqs, missing)) return;

		if (getKnocked(holder) <= 0 && !holder.isAttached()) //Cant wrench while stunned
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (!ready) return;
				Vec2f pos = holder.getAimPos();
				
				if ((pos - this.getPosition()).getLength() < 40) //Range
				{
					getMap().rayCastSolidNoBlobs(this.getPosition(), pos, pos);
					CBlob@ blob = getMap().getBlobAtPosition(pos);
					if (blob !is null && blob.getHealth() < blob.getInitialHealth()) //Must be damaged
					{
						if (blob.hasTag("lamp") || blob.hasTag("vehicle") || blob.getShape().isStatic() && !blob.hasTag("nature"))
						{
							if (isServer())
							{
								//blob.Tag("MaterialLess"); //No more materials can be harvested by mining this (prevents abuse with stone doors)
								u32 ticks_since_last_hit = getGameTime()-blob.get_u32("last_hit");
								
								//10 seconds = 300 ticks = 3 percents
								//30 seconds = 9 percents (A LOT)
								//100 percents = 3000 ticks = 100 seconds = 1 min 40 seconds (HUGE)
								//within ~2 minutes they can blast your tank or whatever you have into a cloud of metal dust
								
								f32 health_percent = Maths::Max(1, 0.01f*ticks_since_last_hit);
								blob.server_Heal((blob.getInitialHealth()*2/100)*health_percent);
								server_TakeRequirements(holder.getInventory(), null, heal_reqs);
							}
							if (isClient())
							{
								sparks(blob.getPosition(), 1, 0.25f);
								this.getSprite().PlaySound("clock_wind_up" + XORRandom(3), 3.0f, 0.6 + (XORRandom(50) / 1000.0f));
							}
						}
						this.set_u32("next attack", getGameTime() + time_between_attacks);
						this.Sync("next attack", true);
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