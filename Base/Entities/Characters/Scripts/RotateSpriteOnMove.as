//add this script last so it rotates all the sprite layers properly

void onTick(CSprite@ this)
{
	if (!isClient()) return;

	if (getRules().get_string("body_tilting") == "off") return;

	CBlob@ blob = this.getBlob();
	
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const uint SPRITES = this.getSpriteLayerCount();
	
	f32 max_airtime = 30;
	f32 body_angle = blob.getVelocity().x*2.8f*float(Maths::Max(0, max_airtime-blob.getAirTime())/max_airtime);
	
	this.ResetTransform();
	if (blob.isKeyPressed(key_down)&&!(blob.isKeyPressed(key_right)||blob.isKeyPressed(key_left))) return;
	
	for (uint i = 0; i < SPRITES; i++)
	{
		CSpriteLayer@ s_layer = this.getSpriteLayer(i);
		
		if (	s_layer.name=="rope"
			||	s_layer.name=="hook"
			||	s_layer.name=="chop"
			||	s_layer.name=="backarm"
			||	s_layer.name=="frontarm"
			||	s_layer.name=="held arrow") continue;

		if (s_layer.name.find("arrow")>=0) continue;
		
		if (s_layer.name=="head")
		{
			s_layer.RotateBy(body_angle, Vec2f(0, 4));
			continue;
		}
		
		if (s_layer.name=="shiny bit")
		{
			s_layer.ResetTransform();
		}
		
		Vec2f offset = s_layer.getOffset();
		Vec2f rotoff = -Vec2f(offset.x*FLIP_FACTOR, offset.y);
		
		//i'm way too stupid to finish this
		/*
		Vec2f arrow_rotoff = -Vec2f(offset.x, offset.y);
		if (s_layer.name.find("arrow")>=0)
		{
			rotoff = arrow_rotoff;
			string current_arrow_name = "arrow"+s_layer.name.substr("arrow".size());

			//printf("sosal "+current_arrow_name);

			s_layer.ResetTransform();
			s_layer.SetOffset(blob.get_Vec2f(current_arrow_name+"offset"));
			body_angle += blob.get_f32(current_arrow_name);
		}
		*/

		s_layer.RotateBy(body_angle, rotoff);
		//s_layer.setRenderStyle(RenderStyle::normal);
	}

	this.RotateBy(body_angle, Vec2f_zero);
}