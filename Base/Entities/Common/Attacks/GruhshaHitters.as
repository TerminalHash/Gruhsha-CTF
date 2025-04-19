namespace GruhshaHitters {
	shared enum gruhsha_hits {
        // tile entity should be first
		tile_entity = 50,

		// mod stuff
		slide_mine = 51,
		golden_mine = 52,
		sticky_bomb = 53,
		ice = 54,
		booster = 55,
		hazelnut_shell = 56,
		fumo_keg = 57,

		// animals
		bison
	};
}

// shield can block only sticky bomb and slide mine, not fumo and kernel :D
// (golden mine also cannot be blocked, it's too powerful thing)
bool isCustomExplosionHitter(u8 type)
{
	return type == GruhshaHitters::sticky_bomb || type == GruhshaHitters::slide_mine;
}