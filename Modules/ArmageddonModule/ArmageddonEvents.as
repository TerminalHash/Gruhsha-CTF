// ArmageddonEvents.as
/*
    List of events for Armageddon module.
*/

#include "ActivationThrowCommon.as"
#include "Hitters.as"

// Get a random x based on the width of the map
u64 get_random_x() {
	CMap@ map = getMap();
	return XORRandom(map.tilemapwidth * map.tilesize + 100);
}

void TeamWork() { // keg rain
	if (getGameTime() % 3 == 0) {
		Vec2f pos = Vec2f(get_random_x(), 0);
		CBlob@ keg = server_CreateBlob("keg", 34, pos);

		if (keg !is null) {
			server_Activate(keg);
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 - 1;
			keg.setVelocity(Vec2f(spread,0)); // Give it random horizontal momentum
		}
	}
}

void TDMBased() { // bomb rain
	if (getGameTime() % 1 == 0) {
		CBlob@ bomb = server_CreateBlob("bomb", 34, Vec2f(get_random_x(), 0));

		if (bomb !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 + 1;
			bomb.setVelocity(Vec2f(spread, 0)); // Give it random horizontal momentum
		}
	}
}

void EasyKill() { // slidemine rain
	if (getGameTime() % 3 == 0) {
		CBlob@ slidemine = server_CreateBlob("slidemine", 34, Vec2f(get_random_x(), 0));

		if (slidemine !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 + 1;
			slidemine.setVelocity(Vec2f(spread, 0)); // Give it random horizontal momentum
		}
	}
}

void PackOfBisons() // bison rain
{
	if (getGameTime() % 10 == 0) {
		CBlob@ bison = server_CreateBlob("bison", 34, Vec2f(get_random_x(), 0));

		if (bison !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 + 1;
			bison.setVelocity(Vec2f(spread, 0)); // Give it random horizontal momentum
		}
	}
}

void PraiseTheFumo() { // fumokeg rain
	if (getGameTime() % 15 == 0) {
		Vec2f pos = Vec2f(get_random_x(), 0);
		CBlob@ fumokeg = server_CreateBlob("fumokeg", 34, pos);

		if (fumokeg !is null) {
			fumokeg.set_f32("keg_time", 90.0f);
			server_Activate(fumokeg);
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 - 1;
			fumokeg.setVelocity(Vec2f(spread,0)); // Give it random horizontal momentum
		}
	}
}

void PraiseNoko() { // spawn noko
	if (getRules().get_bool("fumo spawned")) return;

	const f32 mapCenter = getMap().tilemapwidth * getMap().tilesize * 0.5;

	CBlob@ fumo = server_CreateBlob("noko", 34, Vec2f(mapCenter, 0));
	
	if (!getRules().get_bool("fumo spawned") && fumo !is null) {
		getRules().set_bool("fumo spawned", true);
	}
}

void PraiseCirnu() { // spawn cirnu
	if (getRules().get_bool("fumo spawned")) return;

	const f32 mapCenter = getMap().tilemapwidth * getMap().tilesize * 0.5;

	CBlob@ fumo = server_CreateBlob("cirnu", 34, Vec2f(mapCenter, 0));
	
	if (!getRules().get_bool("fumo spawned") && fumo !is null) {
		getRules().set_bool("fumo spawned", true);
	}
}

void BydlerWeapon() { // spike rain
	if (getGameTime() % 1 == 0) {
		CBlob@ spike = server_CreateBlob("spikes", 9, Vec2f(get_random_x(), 0));

		if (spike !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 + 1;
			spike.setVelocity(Vec2f(spread, 0)); // Give it random horizontal momentum
		}
	}
}

void NiktoEtogoNeProsil() { // ice bomb rain
	if (getGameTime() % 5 == 0) {
		CBlob@ bomb = server_CreateBlob("icebomb", 34, Vec2f(get_random_x(), 0));

		if (bomb !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 + 1;
			bomb.setVelocity(Vec2f(spread, 0)); // Give it random horizontal momentum
			bomb.set_f32("map_damage_ratio", 0.0f);
			bomb.set_f32("explosive_damage", 0.0f);
			bomb.set_f32("explosive_radius", 128.0f);
			bomb.set_bool("map_damage_raycast", false);
			bomb.set_string("custom_explosion_sound", "/GlassBreak");
			bomb.set_u8("custom_hitter", Hitters::water);
			bomb.Tag("splash ray cast");
		}
	}
}

void FuckingBlocks() { // bedrock rain

	u16[] all_the_kag_tiles = {
		16,
		48,
		80,
		96,
		106,
		196,
		208,
		224
	};

	for (int idx = 0; idx < 4; ++idx)
	if (getGameTime() % 1 == 0) {
		Vec2f pos = Vec2f(get_random_x(), XORRandom(64)-32);
		CBlob@ block = server_CreateBlob("tileentity", 34, pos);

		if (block !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 - 1;
			block.setVelocity(Vec2f(spread,10)); // Give it random horizontal momentum
			block.set_s32("tile_frame", all_the_kag_tiles[XORRandom(all_the_kag_tiles.size())]);
		}
	}
}

void FridgeCult() { // fridge rain
	if (getGameTime() % 15 == 0) {
		Vec2f pos = Vec2f(get_random_x(), 0);
		CBlob@ pepe = server_CreateBlob("fridge", 34, pos);

		if (pepe !is null) {
			s8 spread = XORRandom(getRules().get_u8("armageddon spread")) - getRules().get_u8("armageddon spread")/2 - 1;
			pepe.setVelocity(Vec2f(spread,0)); // Give it random horizontal momentum
		}
	}
}