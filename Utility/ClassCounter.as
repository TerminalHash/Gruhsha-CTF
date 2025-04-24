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

void onTick(CRules@ this) {
    if (!isServer()) return;

    // TODO: rewrite this shit to something good
    string[] P_Archers_b;
	string[] P_Archers_r;
	string[] P_Builders_b;
	string[] P_Builders_r;
	string[] P_Knights_b;
	string[] P_Knights_r;

    // check technical value of available classes and change factual values
    // we using old code chunk because it's more reliable method
    if (getGameTime() % 900 == 0) { // check every ~30 seconds
        printf("[INFO] Checking players on classes...");

	    // calculating amount of players in classes
	    for (u32 i = 0; i < getPlayersCount(); i++) {
		    if (getPlayer(i).getBlob() is null) continue;

		    if (getPlayer(i).getBlob().getName() == "archer") {
		        if (getPlayer(i).getTeamNum() == 0) P_Archers_b.push_back(getPlayer(i).getUsername());
		        else if (getPlayer(i).getTeamNum() == 1) P_Archers_r.push_back(getPlayer(i).getUsername());
		    }

		    if (getPlayer(i).getBlob().getName() == "builder") {
		        if (getPlayer(i).getTeamNum() == 0) P_Builders_b.push_back(getPlayer(i).getUsername());
		        else if (getPlayer(i).getTeamNum() == 1) P_Builders_r.push_back(getPlayer(i).getUsername());
		    }

		    if (getPlayer(i).getBlob().getName() == "knight") {
		        if (getPlayer(i).getTeamNum() == 0) P_Knights_b.push_back(getPlayer(i).getUsername());
		        else if (getPlayer(i).getTeamNum() == 1) P_Knights_r.push_back(getPlayer(i).getUsername());
		    }

		    //printf("We have: " + P_Archers_r.length + " Archers, " + P_Builders_r.length + " Builders, " + P_Knights_r.length + " Knights in red team");
		    //printf("We have: " + P_Archers_b.length + " Archers, " + P_Builders_b.length + " Builders, " + P_Knights_b.length + " Knights in blue team");
        }

        // change values to real, if they fake
        if (this.get_s32("builder0Count") < P_Builders_b.length() || this.get_s32("builder0Count") > P_Builders_b.length()) {
            printf("[INFO] We have fake value on Blue B! Fixing...");

            this.set_s32("builder0Count", P_Builders_b.length());
            this.Sync("builder0Count", true);
        }
            
        if (this.get_s32("builder1Count") < P_Builders_r.length() || this.get_s32("builder1Count") > P_Builders_r.length()) {
            printf("[INFO] We have fake value on Red B! Fixing...");

            this.set_s32("builder1Count", P_Builders_r.length());
            this.Sync("builder1Count", true);
        }
            
        if (this.get_s32("knight0Count") < P_Knights_b.length() || this.get_s32("knight0Count") > P_Knights_b.length()) {
            printf("[INFO] We have fake value on Blue K! Fixing...");

            this.set_s32("knight0Count", P_Knights_b.length());
            this.Sync("knight0Count", true);
        }
            
        if (this.get_s32("knight1Count") < P_Knights_r.length() || this.get_s32("knight1Count") > P_Knights_r.length()) {
            printf("[INFO] We have fake value on Red K! Fixing...");

            this.set_s32("knight1Count", P_Knights_r.length());
            this.Sync("knight1Count", true);
        }

        if (this.get_s32("archer0Count") < P_Archers_b.length() || this.get_s32("archer0Count") > P_Archers_b.length()) {
            printf("[INFO] We have fake value on Blue A! Fixing...");

            this.set_s32("archer0Count", P_Archers_b.length());
            this.Sync("archer0Count", true);
        }
            
        if (this.get_s32("archer1Count") < P_Archers_r.length() || this.get_s32("archer1Count") > P_Archers_r.length()) {
            printf("[INFO] We have fake value on Red A! Fixing...");

            this.set_s32("archer1Count", P_Archers_r.length());
            this.Sync("archer1Count", true);
        }
    }
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