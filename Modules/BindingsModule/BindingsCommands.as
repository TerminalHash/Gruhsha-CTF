// BindingsCommands.as

void onInit(CRules@ this) {
	this.addCommandID("sync drill autopickup");
	this.addCommandID("sync drill autopickup client");
	this.addCommandID("sync bomb autopickup");
	this.addCommandID("sync bomb autopickup client");
	this.addCommandID("lagswitch check");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if (cmd == this.getCommandID("sync drill autopickup") && isServer()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 1) {
			getRules().set_string(player.getUsername() + "pickdrill_knight", autopick);
		} else if (action == 2) {
			getRules().set_string(player.getUsername() + "pickdrill_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickdrill_archer", autopick);
		}
	} else if (cmd == this.getCommandID("sync bomb autopickup") && isServer()) {
		u8 action; // class: 1 knight 2 builder 3 archer
		if (!params.saferead_u8(action)) return;

		bool yes;
		if (!params.saferead_bool(yes)) return;

		string autopick = "yes";
		if (!yes) autopick = "no";

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		if (action == 2) {
			getRules().set_string(player.getUsername() + "pickbomb_builder", autopick);
		} else if (action == 3) {
			getRules().set_string(player.getUsername() + "pickbomb_archer", autopick);
		}
	}

	if (cmd == this.getCommandID("lagswitch check") && isServer()) {
		u8 isLagswitchActive; // 1 active 0 inactive
		if (!params.saferead_u8(isLagswitchActive)) return;

		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		// if sv_deltapos_modifier is > 1 - kick autist from server
		if (isLagswitchActive == 1)
			KickPlayer(callerp);
	}
}