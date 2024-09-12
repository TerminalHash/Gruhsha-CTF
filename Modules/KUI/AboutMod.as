#include "KUI.as"
#include "ScoreboardCommon.as"
#include "RulesCore.as"
#include "PickingCommon.as"
#include "ApprovedTeams.as"

bool toggle1 = false;
bool toggle2 = false;

void onInit(CRules@ this) {
    this.set_bool("mod_info_open", true);
}

void onTick(CRules@ this) {
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
    Menu::addContextItem(menu, "Mod Information", getCurrentScriptName(), "void ShowHelpMenu()");
}

void ShowHelpMenu()
{
    Menu::CloseAllMenus();
    getRules().set_bool("mod_info_open", true);
}

void onRender(CRules@ this) {
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;

	if (!this.get_bool("mod_info_open")) return;

    KUI::Begin("GRUHSHA CTF: О моде", Vec2f(500, 200), Vec2f(1500, 530));

    /////////////////////////////////////////////////
    // Main section: short information about mod
    /////////////////////////////////////////////////
    KUI::Text("Gruhsha CTF или же Груша - это русскоязычный вариант Captains-модов.");
    KUI::Text("Здесь сохранены правила ванильного CTF-режима в максимально-исходном виде и проведён аккуратный ребаланс.");
    KUI::Text("Ваша цель не изменилась - вам необходимо захватывать флаги для победы в матче, но время матча строго ограничено - ");
    KUI::Text("у вас есть 45 минут на то, чтобы захватить все имеющиеся флаги у противника. За 5 минут до конца раунда включается");
    KUI::Text("режим 'Внезапная смерть', при которой накладываются баффы и дебаффы на определённые вещи, стимулирующие к действу.");
    KUI::Text("Посмотреть изменения при внезапной смерти можно, наведя курсор на иконку черепа под панелью времени.");

    KUI::Text(" ");
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    // Information about changes
    /////////////////////////////////////////////////
    KUI::Text("Краткий экскурс в основные изменения мода:");
    KUI::Text("- Основная система материалов - виртуальная, они общие на команду (реальные материалы конвертируются складом и строителем);");
    KUI::Text("- Туннели, построенные в основной зоне карты ломаются за три минуты, а на территории противника - за минуту;");
    KUI::Text("- Классы строителя и лучника имеют лимиты по количеству человек, одновременно играющих на них;");
    KUI::Text("- Рыцарям и лучникам разрешено использовать дрели в конкретных зонах (база команды и внутри границы красной зоны);");
    KUI::Text("- Изменена физика батутов: они толкают вас вперёд с силой, определяемой высотой прыжка или скоростью;");
    KUI::Text("- Добавлены собственные настройки мода (меню вызывается через кнопку над таблицами игроков);");
    KUI::Text("- Пофикшены некоторые мозговыносящие баги ванильной игры;");
    KUI::Text("- И многое-многое другое.");

    KUI::Text(" ");

    if (KUI::Button("Close menu")) {
        this.set_bool("mod_info_open", false);
    }
    KUI::End();
}
