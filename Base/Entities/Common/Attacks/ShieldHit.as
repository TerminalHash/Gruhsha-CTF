// Shield hit - make sure to set up the shield vars elsewhere
#include "ShieldCommon.as";
#include "ParticleSparks.as";
#include "KnockedCommon.as";
#include "KnightCommon.as";
#include "Hitters.as";

bool canBlockThisType(u8 type) // this function needs to use a tag on the hitterBlob, like ("bypass shield")
{
	return type == Hitters::stomp ||
	       type == Hitters::builder ||
	       type == Hitters::sword ||
	       type == Hitters::shield ||
	       type == Hitters::arrow ||
	       type == Hitters::bite ||
	       type == Hitters::stab ||
	       type == Hitters::cata_stones ||
	       isExplosionHitter(type);
}

// if your health is lower than it was last time you got hit
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("dead") ||
	        !canBlockThisType(customData) ||
	        this is hitterBlob) {
		return damage;
	}

	//no shield when stunned
	if (isKnocked(this) && !isJustKnocked(this)) {
		return damage;
	}

	CPlayer@ dmgowner = hitterBlob.getDamageOwnerPlayer();
	CPlayer@ thisplayer = this.getPlayer();

	if ((blockAttack(this, velocity, 0.0f) && this.hasTag("shielded"))) {
		if (isExplosionHitter(customData)) { //bomb jump
			bool earlyreturn = false;
			bool preventbombertactic = false;

			if (dmgowner !is null && thisplayer !is null) {
				u32 secs_since = getGameTime() - this.get_u32("lastbombjumptimetigor");
				//printf("Current time: " + getGameTime());
				//printf("Last bomb hit time: " + this.get_u32("lastbombjumptimetigor"));
				//printf("Final time: " + secs_since);

				if (secs_since < 3) {
					earlyreturn = true;
				} else if (secs_since < 90 && dmgowner is thisplayer) {
					if (this.getCarriedBlob() !is null && this.getCarriedBlob().getName() == "keg") {
						setKnocked(this, 7);
						this.DropCarried();
					}
				}

				if (hitterBlob.hasTag("DONTSTACKBOMBJUMP") && dmgowner is thisplayer) {
					earlyreturn = true;
				}
			}

			if (true) {
				Vec2f vel = this.getVelocity();
				//printf("Current velocity: " + vel);

				if (!earlyreturn) {
					this.setVelocity(Vec2f(0.0f, -1.8));
				}

				Vec2f bombforce = Vec2f(0.0f, ((velocity.y > 0) ? 0.7f : -1.3f));

				bombforce.Normalize();
				bombforce *= 2.0f * Maths::Sqrt(damage) * this.getMass();
				bombforce.y -= 2;

				if (!this.isOnGround() && !this.isOnLadder()) {
					if (this.isFacingLeft() && vel.x > 0) {
						//bombforce.x += 50;
						bombforce.y -= 80;
					} else if (!this.isFacingLeft() && vel.x < 0) {
						//bombforce.x -= 50;
						bombforce.y -= 80;
					}
				}

				if (earlyreturn) {
					// Dont touch debug lines needlessly!

					//printf("Early return");
					//printf("Early return is " + earlyreturn);
					//printf("Force: " + bombforce);
					//this.setVelocity(bombforce);
				} else if (!earlyreturn) {
					this.AddForce(bombforce);
				}

			this.Tag("dont stop til ground");

				if (dmgowner !is null && thisplayer !is null) {
						if (dmgowner is thisplayer) {
							this.set_u32("lastbombjumptimetigor", getGameTime());
							this.Sync("lastbombjumptimetigor", true);
					}
				}
			}
		} else if (exceedsShieldBreakForce(this, damage) && customData != Hitters::arrow) {
			knockShieldDown(this);
			this.Tag("force_knock");
		}

		if (getNet().isClient()) {
			this.Tag("shieldDoesBlock");
			this.set_f32("shieldDamage", damage);
			this.set_Vec2f("shieldDamageVel", velocity);
			this.set_Vec2f("ShieldWorldPoint", worldPoint);
		} return 0.0f;

	} else {
		if (getNet().isClient() && isJustKnocked(hitterBlob)) {
			this.Tag("shieldNoBlock");
			this.set_f32("shieldDamage", damage);
			this.set_Vec2f("shieldDamageVel", velocity);
			this.set_Vec2f("ShieldWorldPoint", worldPoint);
		}
	}
	return damage; //no block, damage goes through
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	if (isClient() && (this.hasTag("shieldNoBlock") || this.hasTag("shieldDoesBlock")))
	{
		if (this.getHealth() == oldHealth)
		{
			f32 damage = this.get_f32("shieldDamage");
			Vec2f velocity = this.get_Vec2f("shieldDamageVel");
			Vec2f worldPoint = this.get_Vec2f("ShieldWorldPoint");

			shieldHit(damage, velocity, worldPoint);
		}
		else if(this.hasTag("shieldDoesBlock"))
		{
			// drop shield
			knockShieldDown(this);
			KnightInfo@ knight;
			if (this.get("knightInfo", @knight))
			{
				knight.state = KnightStates::normal;
				this.set_s32("currentKnightState", 0);
			}
		}
		this.Untag("shieldNoBlock");
		this.Untag("shieldDoesBlock");
	}
}

void shieldHit(f32 damage, Vec2f velocity, Vec2f worldPoint)
{
	Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);
	const f32 vellen = velocity.Length();
	sparks(worldPoint, -velocity.Angle(), Maths::Max(vellen * 0.05f, damage));
	//printf("Shield hit!");
}
