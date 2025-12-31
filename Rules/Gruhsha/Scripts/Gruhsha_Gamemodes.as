// GamemodesCore.as
/*
    Main script for internal Gruhsha's gamemode.
    Possible gamemodes in Gruhsha:
	-- -- -- -- -- -- -- -- -- -- -- --
	NAME		VAR				DESC
	-- -- -- -- -- -- -- -- -- -- -- --
	CTF			gruhsha			Capture The Flag! Main Gruhsha's gamemode.
	TDM			tavern			Team Deathmatch! Player waiting gamemode with classes from Brawl's Tavern.
*/

/*
	use that string to edit default gamemode, which will be
	set from main game loop start, dont edit code in Gruhsha.as directly. 

	also, because CTF is main gamemode and we cant load another
	mapcycle on fly, dont forget to change mapcycle file in gamemode.cfg.
*/
const string default_gamemode = "gruhsha";

shared string InternalGamemode(CRules@ this) {
    return this.get_string("internal_game_mode");
}

shared string PreviousGamemode(CRules@ this) {
    return this.get_string("previous_game_mode");
}

bool isTavernTDM(CRules@ this) {
    string gamemode = InternalGamemode(this);

    if (gamemode == "tavern")
        return true;

    return false;
}
