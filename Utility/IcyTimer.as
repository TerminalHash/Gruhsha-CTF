// IcyTimer.as

const int icy_state_time = getTicksASecond() * 10; // 10 seconds

void onInit(CRules@ this) {
	onRestart(this);
}

void onRestart(CRules@ this) {
	this.set_s32("icy time", icy_state_time);
}