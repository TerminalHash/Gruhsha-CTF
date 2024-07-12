// DebugFlag.as

shared string flag_name() { return "ctf_flag"; }

void onTick (CBlob@ this) {
    u8 team_num = this.getTeamNum();

    CBlob@[] flags;
    getBlobsByName(flag_name(), @flags);

    CBlob@[] flags_red;
    CBlob@[] flags_blue;

    for (uint i = 0; i < flags.length; i++) {
        if (flags[i].getTeamNum() == 0) {
            flags_blue.push_back(flags[i]);
        } else if (flags[i].getTeamNum() == 1) {
            flags_red.push_back(flags[i]);
        }
    }

    if (getControls().isKeyJustPressed(KEY_LSHIFT)) {
        printf("Flags on map: " + flags.length);
        printf("Blue Flags on map: " + flags_blue.length);
        printf("Red Flags on map: " + flags_red.length);
    }
}