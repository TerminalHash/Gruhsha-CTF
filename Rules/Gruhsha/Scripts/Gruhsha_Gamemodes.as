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