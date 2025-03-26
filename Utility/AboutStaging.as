// AboutStaging.as

#define CLIENT_ONLY

bool isNoteActive = true;
const int time_to_show = getTicksASecond() * 15;

void onInit(CRules@ this) {
    #ifdef STAGING
	return;
	#endif

	this.set_s32("note life", time_to_show);
}

void onTick(CRules@ this) {
    #ifdef STAGING
	return;
	#endif

    if (this.get_s32("note life") > 0)
        this.sub_s32("note life", 1);
    
    if (this.get_s32("note life") <= 0)
        isNoteActive = false;
}

void onRender(CRules@ this) {
    // if player already on staging - dont show that note
	#ifdef STAGING
	return;
	#endif

	if (g_videorecording)
		return;

    if (!isNoteActive) return;

	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }
	
	u32 secs = ((this.get_s32("note life") / getTicksASecond()));
	string units = ((secs != 1) ? " seconds" : " second");

	if (isNoteActive) {
        GUI::SetFont("menu");
        string info = "We officially do not support the vanilla KAG client due to it's\n"+
                "obsolescence and performance issues.\n\n"+
                "We recommend changing your client to Staging, how to get it (in Steam):\n\n"+
                "Properties KAG -> Beta-versions ->\nType transhumandesign in the field ->\nChoose branch 'staging-test'\n\n"+
                "If you are not playing through Steam, visit KAG's Discord server\nfor more information.";
                    
        string hello = "Hi!";
        
        string to_close = "The window will automatically disappear after {SEC}{TIMESUFFIX} ;)".replace("{SEC}", "" + secs)
		.replace("{TIMESUFFIX}", getTranslatedString(units));
		
		Vec2f hello_position = Vec2f(getScreenWidth() /2 - 10, getScreenHeight() / -2 + 160);
		Vec2f info_position = Vec2f(getScreenWidth() /2 - 250, getScreenHeight() / -2 + 185);
		Vec2f to_close_position = Vec2f(getScreenWidth() /2 - 202, getScreenHeight() / -2 + 382);
        
        if (g_locale == "ru") {
            info = "Мы официально не поддерживаем ванильный клиент KAG из-за его\n"+
                "устаревания и проблем с производительностью.\n\n"+
                "Рекомендуем сменить клиент на Staging, как его получить (в Steam):\n\n"+
                "Свойства KAG -> Бета-версии ->\nВведите transhumandesign в поле ->\nВыберите ветку 'staging-test'\n\n"+
                "Если вы играете не через Steam, посетите дискорд-сервер\nигры для получения большей информации.";
            hello = "Привет!";
            to_close = "Окно автоматически пропадёт через {SEC} {TIMESUFFIX} ;)".replace("{SEC}", "" + secs)
            .replace("{TIMESUFFIX}", getTranslatedString(units));

            hello_position = Vec2f(getScreenWidth() /2 - 30, getScreenHeight() / -2 + 160);
            info_position = Vec2f(getScreenWidth() /2 - 240, getScreenHeight() / -2 + 185);
            to_close_position = Vec2f(getScreenWidth() /2 - 162, getScreenHeight() / -2 + 382);
        }

        // main panel
        GUI::DrawIcon("NotePanel.png", 0, Vec2f(287,133), Vec2f(getScreenWidth() /2 - 280, getScreenHeight() / -2 + 150));
        GUI::DrawText(hello, hello_position, SColor(0xffffffff));
        GUI::DrawText(info, info_position, SColor(0xffffffff));
        GUI::DrawText(to_close, to_close_position, SColor(0xffffffff));
        
        
    }
}