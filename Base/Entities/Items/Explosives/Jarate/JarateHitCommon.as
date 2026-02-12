// JarateHitCommon.as
#include "Hitters.as";
#include "GruhshaHitters.as";

bool DoublingDamageHitters(u8 type) {
	return type == Hitters::bomb ||
        type == Hitters::crush ||
        type == Hitters::burn ||
        type == Hitters::stomp ||
        type == Hitters::bite ||
        type == Hitters::builder ||
        type == Hitters::sword ||
        type == Hitters::stab ||
        type == Hitters::arrow ||
        type == Hitters::bomb_arrow ||
        type == Hitters::ballista ||
        type == Hitters::cata_stones ||
        type == Hitters::cata_boulder ||
        type == Hitters::boulder ||
        type == Hitters::ram ||
        type == Hitters::explosion ||
        type == Hitters::keg ||
        type == Hitters::mine ||
        type == Hitters::spikes ||
        type == Hitters::saw ||
        type == Hitters::drill ||
        type == Hitters::muscles ||
        type == Hitters::fall ||
        type == Hitters::flying ||
        type == GruhshaHitters::tile_entity ||
        type == GruhshaHitters::slide_mine ||
        type == GruhshaHitters::golden_mine ||
        type == GruhshaHitters::sticky_bomb ||
        type == GruhshaHitters::hazelnut_shell ||
        type == GruhshaHitters::fumo_keg ||
        type == GruhshaHitters::bison ||
        type == GruhshaHitters::hammer ||
        type == GruhshaHitters::hammer_heavy ||
        type == GruhshaHitters::knife ||
        type == GruhshaHitters::flail;
}