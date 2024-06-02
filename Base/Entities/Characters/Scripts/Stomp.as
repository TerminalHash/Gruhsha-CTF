#include "/Entities/Common/Attacks/Hitters.as";
#include "KnockedCommon.as"
#include "CrouchCommon.as"

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null && isServer())   // map collision?
	{
		//printf("Pondaio! " + getGameTime() );
		float enemydam = 0.0f;
		f32 vely = this.getOldVelocity().y;

		Vec2f current_pos = point1;
		Vec2f old_pos = this.getOldPosition();
		f32 distance = (current_pos - old_pos).Length();
		f32 angle = -(current_pos - old_pos).getAngle();

		Vec2f newpos = Vec2f(1, 0);
		newpos.RotateByDegrees(angle);
		newpos *= distance;

		//print("Newpos length: " + newpos.Length());

		newpos = old_pos + newpos;

		CBlob@[] blist;
		HitInfo@[] hlist;
		//printf("length " + distance + ", angle " + angle);
		//printf("Newpos actual: " + current_pos);
		//printf("Newpos from ray: " + newpos);
		if (getMap().getHitInfosFromArc(old_pos, angle, 0.0, distance, this, hlist))
		{
			//printf("Oi, yo! " + getGameTime());
			for (int i=0; i<hlist.length(); ++i)
			{
				CBlob@ g = @hlist[i].blob;
				if (g !is null)
				{
					if (g !is this)
					{
						if (old_pos.y < g.getPosition().y - 2)
						{
							if (g.getTeamNum() != this.getTeamNum() && !isCrouching(g) && !g.hasTag("dead") && !this.hasTag("dead") && g.hasTag("player"))
							{
								float enemydam = 0.0f;
								f32 vely = this.getOldVelocity().y;

								if (vely > 10.0f || (this.getName() == "archer" && vely > 5.5f))
								{
									enemydam = 2.0f;
								}
								else if (vely > 5.5f)
								{
									enemydam = 1.0f;
								}

								if (enemydam > 0)
								{
									CPlayer@ gp = g.getPlayer();

									if (gp !is null)
									{
										if (this.exists("laststompedplayer" + gp.getUsername()))
										{
											if (getGameTime() - this.get_u32("laststompedplayer" + gp.getUsername()) < 5)
											{
												return;
											}
										}

										this.set_u32("laststompedplayer" + gp.getUsername(), getGameTime());
									}

									this.set_u32("laststomptime", getGameTime());
									this.Sync("laststomptime", true);
									this.server_Hit(g, old_pos, Vec2f(0, 1) , enemydam, Hitters::stomp);
								}
							}
						}
					}
				}
			}
		}
		return;
	}

	if (!solid)
	{
		return;
	}

	//dead bodies dont stomp
	if (this.hasTag("dead"))
	{
		return;
	}

	// server only
	if (!getNet().isServer() || !blob.hasTag("player")) { return; }

	if (this.getPosition().y < blob.getPosition().y - 2)
	{
		float enemydam = 0.0f;
		f32 vely = this.getOldVelocity().y;

		if (vely > 10.0f || (this.getName() == "archer" && vely > 5.5f))
		{
			enemydam = 2.0f;
		}
		else if (vely > 5.5f)
		{
			enemydam = 1.0f;
		}

		if (enemydam > 0)
		{
			CPlayer@ gp = blob.getPlayer();

			if (gp !is null)
			{
				if (this.exists("laststompedplayer" + gp.getUsername()))
				{
					if (getGameTime() - this.get_u32("laststompedplayer" + gp.getUsername()) < 5)
					{
						return;
					}
				}

				this.set_u32("laststompedplayer" + gp.getUsername(), getGameTime());
			}
			this.set_u32("laststomptime", getGameTime());
			this.Sync("laststomptime", true);
			this.server_Hit(blob, this.getPosition(), Vec2f(0, 1) , enemydam, Hitters::stomp);
		}
	}
}

// effects

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::stomp && damage > 0.0f && velocity.y > 0.0f && worldPoint.y < this.getPosition().y)
	{
		this.getSprite().PlaySound("Entities/Characters/Sounds/Stomp.ogg");
		setKnocked(this, 15, true);
	}
	// not stomp but whatever
	if (isServer() && (customData == Hitters::sword || customData == Hitters::fall || customData == Hitters::crush || customData == Hitters::shield) && damage > 0.0f)
	{
		//printf("hi? gt: " + getGameTime());
		hitterBlob.set_u32("laststomptime", getGameTime());
		hitterBlob.Sync("laststomptime", true);
	}
	return damage;
}
