void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0);
	this.server_SetTimeToDie(0.5);
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated()<5) return;

	//return;
	Vec2f pos = this.getPosition();
	//hit blobs
	CBlob@[] tile_entities_around;
	CMap@ map = getMap();

	f32 radius = this.get_f32("expl_radius");

	int amount_of_tiles_pushed = 0;

	if (map.getBlobsInRadius(pos, radius, @tile_entities_around))
	{
		for (int idx = 0; idx < tile_entities_around.size(); ++idx)
		{
			CBlob@ e_tile = tile_entities_around[idx];
			if (e_tile is null) continue;
			
			Vec2f tpos = e_tile.getPosition();
	
			//if (e_tile.getConfig() != "tileentity") continue;
			if (!e_tile.hasTag("collapsing_tile")) continue;

			CPlayer@ killer = this.getDamageOwnerPlayer();

			if (killer !is null)
			{
				e_tile.SetDamageOwnerPlayer(killer);
			}

			amount_of_tiles_pushed += 1;
			
			this.getShape().SetGravityScale(1);
			
			Vec2f explosion_dir = tpos-pos;
			explosion_dir.Normalize();
			Vec2f ds_dir = Vec2f(0, 1);

			f32 exp_dot = explosion_dir.x*ds_dir.x + explosion_dir.y*ds_dir.y;

			f32 angle_factor_account = exp_dot >= 0.87 ? 180 : 0;

			Vec2f tile_vel = Vec2f(-radius/3.5, 0).RotateBy(-(pos-tpos).getAngle()+angle_factor_account);
			f32 tile_vellen = tile_vel.Length();
			tile_vel.Normalize();
			tile_vel *= Maths::Min(tile_vellen, 14);
			
			e_tile.setVelocity(tile_vel);
		}
	}

	if (amount_of_tiles_pushed > 0)
	{
		//printf(" pushed like "+amount_of_tiles_pushed+" tiles");
		this.server_Die();
	}
}