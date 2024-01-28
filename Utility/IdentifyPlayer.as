// IdentifyPlayer.as

CPlayer@ GetPlayerByIdent(string ident)
{
    // Takes an identifier, which is a prefix of the player's character name
    // or username. If there is 1 matching player then they are returned.
    ident = ident.toLower();
    CPlayer@[] matches; // players matching ident

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        string username = p.getUsername().toLower();
        string charname = p.getCharacterName().toLower();

        if (username == ident || charname == ident) {
            return p;
        }
        else if (username.find(ident) >= 0 || charname.find(ident) >= 0) {
            matches.push_back(p);
        }
    }

	if (matches.length == 1) {
        return matches[0];
    }

    return null;
}
