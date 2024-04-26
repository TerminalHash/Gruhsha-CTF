//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "KnockedCommon.as";
#include "FallDamageCommon.as";
#include "CrouchCommon.as";

const u8 knockdown_time = 12;

void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickIfTag = "dead";
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	// consts.bullet = true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid || this.isInInventory() || this.hasTag("invincible"))
	{
		return;
	}

	if (blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
	{
		return; //no falldamage when stomping
	}

	f32 vely = this.getOldVelocity().y;

	if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y) * 2) { return; }

	f32 damage = FallDamageAmount(vely);
	if (damage != 0.0f) //interesting value
	{
		bool doknockdown = true;

		// check if we aren't touching a player
		CBlob@[] overlapping;

		//printf("point1: " + point1);

		if (getMap().getBlobsAtPosition(point1 - Vec2f(0, 4), @overlapping))
		{
			for (uint i = 0; i < overlapping.length; i++)
			{
				CBlob@ b = overlapping[i];

				//printf("Overlapped with: " + b.getName());

				if (b.hasTag("no falldamage"))
				{
					return;
				}

				/*if (b.hasTag("player") && b !is this && !isCrouching(b))
				{
					return;
				}*/
			}
		}

		if (getGameTime() - this.get_u32("laststomptime") < 4)
		{
			//printf("Stomped recently");
			return;
		}

		if (damage > 0.0f)
		{
			if (damage > 0.1f)
			{
				//printf("Got fall damage, time: " + getGameTime());
				this.server_Hit(this, point1, normal, damage, Hitters::fall);
			}
			else
			{
				doknockdown = false;
			}
		}

		if (doknockdown)
		{
			setKnocked(this, knockdown_time);
		}

		if (!this.hasTag("should be silent"))
		{				
			if (this.getHealth() > damage) //not dead
				Sound::Play("/BreakBone", this.getPosition());
			else
			{
				Sound::Play("/FallDeath.ogg", this.getPosition());
			}
		}
	}
}

void onTick(CBlob@ this)
{
	this.Tag("should be silent");
	this.getCurrentScript().tickFrequency = 0;
}
