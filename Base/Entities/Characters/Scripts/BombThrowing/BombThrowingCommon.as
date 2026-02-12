// BombThrowingCommon.as

namespace BombType
{
	enum type
	{
		bomb = 0,
		water,
		sticky,
		ice,
		//booster,
		count
	};
}

const string[] bombNames = { "Bomb",
                             "Water Bomb",
                             "Sticky Bomb",
							 "Ice Bomb"
							 //"Booster"
                           };

const string[] bombIcons = { "$BombIcon$",
                             "$WaterBombIcon$",
                             "$StickyBomb$",
							 "$IceBomb$"
							 //"$Booster$"
                           };

const string[] bombTypeNames = { "mat_bombs",
                                 "mat_waterbombs",
                                 "mat_stickybombs",
								 "mat_icebombs"
								 //"mat_boosters"
                               };

bool hasBombs(CBlob@ this, u8 bombType)
{
	return bombType < BombType::count && this.getBlobCount(bombTypeNames[bombType]) > 0;
}
