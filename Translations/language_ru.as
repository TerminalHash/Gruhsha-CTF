// language_ru.as
/*
    Русский перевод для Grusha CTF.
    -- -- -- -- -- -- -- -- --
    Авторы перевода:
    TerminalHash
*/
namespace ru
{
	const string

	//////////////////////////////////////////////////////////
	// Descriptions
	//////////////////////////////////////////////////////////

	// Accolades.as
	d_goldgrushatext						= "Контрибьютор Груши - за разработку мода Gruhsha CTF",

	// BindingsCommon.as
	d_modbindplaceholder					= "пусто",
	d_modbindnull							= "Нет клавиши",

			// Settings
	d_bmoptlag								= "Дружелюбный к лагам",
	d_bmoptvan								= "Ванильное",
	d_blockbaron							= "Да",
	d_blockbaroff							= "Нет",
	d_universalon							= "Включено",
	d_universaloff							= "Выключено",

	// CommandsHelpHUD.as
		// Page 1
	d_pageonelinemain						= "Список команд мода:",
	d_pageonelinecaptain					= "Капитанская система:",
	d_pageonelineone						= "/specall - сделать всех игроков наблюдателями",
	d_pageonelinetwo						= "/appoint - повысить двух игроков до Капитанов",
	d_pageonelinethree						= "/demote - понизить Капитанов до обычных игроков",
	d_pageonelinefour						= "/pick - берёт указанного игрока из наблюдателей в твою команду и передаёт право выбора другому Капитану",
	d_pageonelinefive						= "/lock - запрещает набирать людей в команды, запоминая состав и останавливая процесс набора игроков",
	d_pageonelinesix						= "/blim - устанавливает лимит на строителей в командах",
	d_pageonelineseven						= "/alim - устанавливает лимит на лучников в командах",
	d_pageonelineeight						= "/togglechclass - переключить смену классов в магазинах",
	d_pageonelineplayer						= "Личные:",
	d_pageonelinenine						= "/bindings - открыть меню настроек мода (оставлена как альтернатива кнопке)",
	d_pageonelineten						= "/realstone - сконвертировать 50 единиц виртуального камня в реальный",
	d_pageonelineel							= "/togglesounds - переключить воспроизведение звуков войслайнов для себя",
	d_pageonelinefooter						= "Колесо меток, колесо модовых эмоций, бинды и настройки игрока находятся в меню настроек мода!",

		// Page 2
	d_pagetwolinemain						= "Gruhsha CTF: русская Captains модификация",
	d_pagetwolineone						= "Gruhsha CTF или же Груша - это русскоязычный вариант Captains-модов.",
	d_pagetwolinetwo						= "Здесь сохранены правила ванильного CTF-режима в максимально-исходном виде и проведён аккуратный ребаланс.",
	d_pagetwolinethree						= "Вам по-прежнему требуется захватить флаги противника для победы в матче, но теперь за команды отвечают Капитаны.",
	d_pagetwolinefour						= "Краткий экскурс в основные изменения мода:",
	d_pagetwolinefive						= "- Классы строителя и лучника имеют лимиты по количеству человек, одновременно играющих на них;",
	d_pagetwolinesix						= "- Рыцарям разрешено использовать дрели в конкретных зонах (база команды и внутри границы красной зоны);",
	d_pagetwolineseven						= "- Изменена физика батутов: они толкают вас вперёд с силой, определяемой высотой прыжка или скоростью;",
	d_pagetwolineeight						= "- Каждый игрок имеет свой собственный пул материалов, камень и дерево отныне виртуальныe;",
	d_pagetwolinenine						= "- Аккуратно сбалансированы свойства некоторых предметов и цены на них;",
	d_pagetwolineten						= "- Добавлены собственные настройки мода (меню вызывается через кнопку над таблицами игроков);",
	d_pagetwolineel							= "- Пофикшены некоторые мозговыносящие баги ванильной игры;",
	d_pagetwolinetwen						= "- И многое-многое другое.",
	d_pagetwolinefooter						= "Нажмите на любую кнопку слева от панели, чтобы перейти к другой странице.",

		// Page 3
	d_pagethreelinemain						= "Авторы модификации",
	d_pagethreelineone						= "Skemonde - создатель Груши",
	d_pagethreelinetwo						= "TerminalHash - основной майнтайнер мода",
	d_pagethreelinethree					= "Програмисты:",
	d_pagethreelinefour						= "TerminalHash, Skemonde, kussakaa, egor0928931, Vagrament aka FeenRant",
	d_pagethreelinefive						= "Художники:",
	d_pagethreelinesix						= "TerminalHash, Skemonde, kussakaa",

	// PickingCommands.as
	d_bindingscom							= "Открыть меню кастомных биндингов",
	d_togglechcomtext						= "Переключить смену классов в магазинах",
	d_togglechcomchat						= "Смена классов теперь ",
	d_togglechcom2							= "включена",
	d_togglechcom3							= "выключена",
	d_archerlimchat							= "Максимум лучников теперь ",
	d_archerlimtext							= "Устанавливает лимит на лучников в командах",
	d_builderlimchat						= "Максимум строителей теперь ",
	d_builderlimtext						= "Устанавливает лимит на строителей в командах",
	d_lockcomtext							= "Запрещает набирать людей в команды, запоминая состав и останавливая процесс набора игроков",
	d_lockcomchatunl						= "Команды расформированы",
	d_lockcomchatloc						= "Команды сформированы",
	d_pickcomtext							= "Берёт указанного игрока из наблюдателей в твою команду и передаёт право выбора другому Капитану",
	d_demotecomtext							= "Понизить Капитанов до обычных игроков",
	d_appointcomtext						= "Повысить двух игроков до Капитанов (они выбирают остальных игроков к себе в команду)",
	d_specallcomtext						= "Сделать всех игроков наблюдателями",

	// Satchel.as
	d_satcheldesc							= "Поджигает горючие блоки, активируется при помощи клавиши броска",

	// SoundsCommands.as
	d_togglesoundscomtext					= "Включить или выключить звук вокалайзов для себя",
	d_togglesoundschattexton				= "Надоедливые звуки войслайнов выключены, ",
	d_togglesoundschattextoff				= "Надоедливые звуки войслайнов включены, ",

	// ScoreboardRender.as
	d_currentversiontext					= "Текущая версия: ",

	// ClassSelectMenu.as
	d_totaltext								= "Всего ",

	// Quarters.as
	d_peartext								= "Сочная и сладкая груша.",

	//////////////////////////////////////////////////////////
	// Names
	//////////////////////////////////////////////////////////

	//BindingsCommon.as

		// Buttons
	n_modbindsmenu							= "Эмоции/Метки",
	n_blocksmenu							= "Блоки",
	n_actionsmenu							= "Действия",
	n_settingsmenu							= "Настройки",
	n_tagwheel								= "Колесо меток",
	n_emotewheelvanilla					= "Ванильное колесо эмоций",
	n_emotewheelsecond						= "Модовое колесо эмоций",

		// Blocks
	n_stonebl								= "Каменный блок",
	n_stoneback								= "Каменная стена",
	n_stonedoor								= "Каменная дверь",
	n_woodbl								= "Деревянный блок",
	n_woodback								= "Деревянная стена",
	n_wooddoor								= "Деревянная дверь",
	n_platformt								= "Командная платформа",
	n_ladder								= "Лестница",
	n_platform								= "Платформа",
	n_shop									= "Магазин",
	n_spikes								= "Шипы",

		// Actions
	n_drillcommand							= "Достать/Убрать дрель",

		// Settings
	n_buildmode								= "Режим строительства",
	n_blockbar								= "Включить панель с блоками",
	n_camerasw								= "Покачивание камеры (По-умол. 5)",
	n_bodytilt								= "Иммерсивное поведение тела",
	n_drillzoneborders						= "Границы зоны дриллинга",

		// Other
	n_pressdelete							= "Выбери клавишу и нажми [DELETE] для очистки хоткея!",

	// ScoreboardCommon.as
	n_modsettingsbutton						= "Настройки",

	// ScoreboardRender.as
	n_matssection							= "Материалы",

	// Quarters.as
	n_beeritem								= "Пиво - 1 Сердце",
	n_mealitem								= "Мясное блюдо - Полное здоровье",
	n_eggitem								= "Яйцо - Полное здоровье",
	n_burgeritem							= "Бургер - Полное здоровье",
	n_pearitem								= "Груша - 2 Сердца",

	empty 					= ""; // keep last
}
