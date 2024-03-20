#include "FallDamageCommon.as";

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 25;
	const f32 SCALAR = 10;
	const f32 SOFT_SCALAR = 8; // Cap for bouncing without holding W
	const f32 UP_BOOST = 1.5f;
	const u8 BOOST_RANGE = 60;
	const bool SAFETY = true;
	const int COOLDOWN_LIMIT = 28;

	const bool PHYSICS = true; // adjust angle to account for blob's previous velocity
	const float PERPENDICULAR_BOUNCE = 1.0f; // strength of angle adjustment
}

f32 scaleWithUpBoost(Vec2f vel)
{
	f32 boost = 0.0f;
	if (Trampoline::UP_BOOST != 0)
	{
		// boost factor
		boost = (Trampoline::BOOST_RANGE - Maths::Abs(180 - ((vel.getAngleDegrees() + 90) % 360))) // range - degrees from up
		        / (1.0f * Trampoline::BOOST_RANGE);                                                // / max boost range
		if (boost > 0)
		{
			boost *= Trampoline::UP_BOOST;
		}
		else
		{
			boost = 0.0f;
		}
	}

	return (Trampoline::SCALAR + boost) / vel.getLength();
}
