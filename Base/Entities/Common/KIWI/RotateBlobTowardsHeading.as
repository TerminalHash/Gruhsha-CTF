
void onTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	//no rotating if blob is attached to something
	if (this.isAttached()) return;
	
	Vec2f vel = this.getVelocity();
	f32 vellen = vel.Length();
	
	// no rotation if the speed is small
	if (vellen < 2) return;
	
	this.setAngleDegrees(-vel.Angle()+ANGLE_FLIP_FACTOR);
}