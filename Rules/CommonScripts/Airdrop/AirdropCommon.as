// AirdropCommon.as
// Based on LootCommon.as

const string LOOT = "loot_table";
const string DROP = "loot_dropped";
const string PURSE = "coins_carried";

enum                Index
{
	MAT_WATERARROWS = 0,
	MAT_FIREARROWS,
    MAT_BLOCKARROWS,
    MAT_STONEBLOCKARROWS,
	MAT_WOOD,
	MAT_STONE,
	MAT_GOLD,
	DRILL,
	MAT_BOMBS,
	MAT_WATERBOMBS,
    MAT_STICKYBOMBS,
    SATCHEL,
	MINE,
	FOOD,
	PEAR,
	BISON
};

const string[]      NAME =
{
	"mat_waterarrows",
	"mat_firearrows",
    "mat_blockarrows",
    "mat_stoneblockarrows",
	"mat_wood",
	"mat_stone",
	"mat_gold",
	"drill",
	"mat_bombs",
	"mat_waterbombs",
    "mat_stickybombs",
    "satchel",
	"mine",
	"food",
	"pear",
	"bison"
};

const u8[]          WEIGHT =
{
	30,                     // mat_waterarrows
	35,                     // mat_firearrows
	30,                     // mat_blockarrows
    25,                     // mat_stoneblockarrows
	50,                     // mat_wood
	45,                     // mat_stone
	5,                      // mat_gold
	45,                     // drill
	55,                     // mat_bombs
	35,                     // mat_waterbombs
    25,                     // mat_stickybombs
    30,                     // satchel
	25,                     // mine
	30,                     // food
	40,                     // pear
	5                       // bison
};

// pre-set 'CLASS' arrays
// ━━━━━━━━━━━━━━━━━
const u8[]          INDEX_AIRDROP =
{
    // Archer items
	MAT_WATERARROWS,
	MAT_FIREARROWS,
    MAT_BLOCKARROWS,
    MAT_STONEBLOCKARROWS,
    // Knight items
    MAT_BOMBS,
	MAT_WATERBOMBS,
    MAT_STICKYBOMBS,
    SATCHEL,
	MINE,
    // Tools
    DRILL,
    // Mats
    MAT_WOOD,
	MAT_STONE,
	MAT_GOLD,
    // Other
    FOOD,
    PEAR,
    // Trolling
    BISON
};

// add a single piece of 'LOOT'
// ━━━━━━━━━━━━━━━━━
// addLoot(this, "mat_bombs");
void addLoot(CBlob@ this, const string &in NAME)
{
	if (!this.exists(LOOT))
	{
		string[] loot_table;
		this.set(LOOT, loot_table);
	}
	this.push(LOOT, NAME);
}

// add multiple pieces of 'LOOT'
// ━━━━━━━━━━━━━━━━━
// const u8[] INDEX = {0, 1, 2, 3};
// addLoot(this, INDEX);
// or
// addLoot(this, INDEX_ARCHER);
void addLoot(CBlob@ this, const u8[]&in INDEX)
{
	for(u8 i = 0; i < INDEX.length; i++)
	{
		addLoot(this, NAME[INDEX[i]]);
	}
}

// add 'count' pieces of 'LOOT' based on 'INDEX'
// ━━━━━━━━━━━━━━━━━
// const u8[] INDEX = {0, 1, 2, 3};
// addLoot(this, INDEX, 1, 0);
// or
// addLoot(this, INDEX_ARCHER, 1, 0);
void addLoot(CBlob@ this, const u8[]&in INDEX, u8 &in count, const u8 &in NONE)
{
	while(count > 0)
	{
		--count;
		const u16 RANDOM = XORRandom(getSumOfWeight(INDEX) + NONE);
		u16 total = 0;
		for(u8 i = 0; i < INDEX.length; i++)
		{
			total += WEIGHT[INDEX[i]];
			if (total > RANDOM)
			{
				addLoot(this, NAME[INDEX[i]]);
				break;
			}
		}
	}
}

// create coins from 'PURSE' and LOOT' from this
// ━━━━━━━━━━━━━━━━━
// createLoot(this, this.getPosition(), this.getTeamNum());
void server_CreateLoot(CBlob@ this, const Vec2f &in POSITION, const u8 &in TEAM)
{
	if (this.exists(DROP))
	{
		return;
	}

	if (this.exists(PURSE))
	{
		server_DropCoins(POSITION, this.get_u16(PURSE));
	}

	string[]@ loot;
	if (this.get(LOOT, @loot))
	{
		for(u8 i = 0; i < loot.length; i++)
		{
			CBlob@ item = server_CreateBlob(loot[i], TEAM, POSITION);
			if (item !is null)
			{
				const f32 ANGLE = XORRandom(300) * 0.1f - 15;
				Vec2f force = Vec2f(0, -1);
				force.RotateBy(ANGLE);
				force *= item.getMass() * 3.6f;
				item.AddForce(force);
			}
		}
	}
	this.Tag(DROP);
	this.Sync(DROP, true);
}

// add 'COUNT' coins to 'PURSE'
// ━━━━━━━━━━━━━━━━━
// addCoin(this, 100);
void addCoin(CBlob@ this, const u16 &in COUNT)
{
	if (!this.exists(PURSE))
	{
		this.set_u16(PURSE, COUNT);
		return;
	}
	this.set_u16(PURSE, this.get_u16(PURSE) + COUNT);
}

// get the 'sum' of 'WEIGHT'
// ━━━━━━━━━━━━━━━━━
// u16 sum = getSumOfWeight(WEIGHT);
u16 getSumOfWeight(const u8[]&in INDEX)
{
	u16 sum = 0;
	for(u8 i = 0; i < INDEX.length; i++)
	{
		sum += WEIGHT[INDEX[i]];
	}
	return sum;
}