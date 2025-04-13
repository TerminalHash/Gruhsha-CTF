void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!isServer()) return;
	if (blob is null) return;
	if (player is null) return;
	
    string NewPlayerClassTeam = blob.getConfig() + player.getTeamNum();
    string oldPlayerClassTeam = this.get_string(player.getUsername() + "class+team");

    if(oldPlayerClassTeam != NewPlayerClassTeam) {

        if(oldPlayerClassTeam != "") {
            this.add_s32(oldPlayerClassTeam + "Count", -1);
	        this.Sync(oldPlayerClassTeam + "Count", true);
        }
        this.add_s32(NewPlayerClassTeam + "Count", 1);
        this.Sync(NewPlayerClassTeam + "Count", true);

        this.set_string(player.getUsername() + "class+team", NewPlayerClassTeam);
	    this.Sync(player.getUsername() + "class+team", true);
    }
}

void Reset(CRules@ this) {
    if (!isServer()) return;
    //this.set_s32("builder0Count", 0);
    //this.Sync("builder0Count", true);
    //
    //this.set_s32("builder1Count", 0);
    //this.Sync("builder1Count", true);
    //
    //this.set_s32("knight0Count", 0);
    //this.Sync("knight0Count", true);
    //
    //this.set_s32("knight1Count", 0);
    //this.Sync("knight1Count", true);
    //
    //this.set_s32("archer0Count", 0);
    //this.Sync("archer0Count", true);
    //
    //this.set_s32("archer1Count", 0);
    //this.Sync("archer1Count", true);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onPlayerLeave(CRules@ this, CPlayer@ player) {
    if (!isServer()) return;
    string PlayerClassTeam = this.get_string(player.getUsername() + "class+team");
    if(PlayerClassTeam != "") {
        this.add_s32(PlayerClassTeam + "Count", -1);
        this.Sync(PlayerClassTeam + "Count", true);
    }
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam) {
    if (!isServer() || newteam != this.getSpectatorTeamNum()) return;
    string PlayerClassTeam = this.get_string(player.getUsername() + "class+team");
    if(PlayerClassTeam != "") {
        this.add_s32(PlayerClassTeam + "Count", -1);
        this.Sync(PlayerClassTeam + "Count", true);
    }
    this.set_string(player.getUsername() + "class+team", "spectator");
    this.Sync(player.getUsername() + "class+team", true);
}