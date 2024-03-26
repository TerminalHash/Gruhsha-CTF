// language_en.as
/*
    English translation for Grusha CTF.
    -- -- -- -- -- -- -- -- --
    Authors of localization:
    TerminalHash
*/
namespace en
{
	const string

	//////////////////////////////////////////////////////////
	// Descriptions
	//////////////////////////////////////////////////////////

	// Accolades.as
	d_goldgrushatext						= "Gruhsha Contributor - for developing mod Gruhsha CTF",

	// BindingsCommon.as
	d_modbindplaceholder					= "placeholder",
	d_modbindnull							= "No binding",

			// Settings
	d_bmoptlag								= "Lag-Friendly",
	d_bmoptvan								= "Vanilla",
	d_blockbaron							= "Yes",
	d_blockbaroff							= "No",
	d_universalon							= "On",
	d_universaloff							= "Off",

	// CommandsHelpHUD.as
		// Page 1 (2)
	d_pageonelinemain						= "Command list:",
	d_pageonelinecaptain					= "Captains System:",
	d_pageonelineone						= "/specall - puts everyone in Spectators",
	d_pageonelinetwo						= "/appoint - appoints two Team Leaders (they pick players in their teams)",
	d_pageonelinethree						= "/demote - demotes the Team Leaders",
	d_pageonelinefour						= "/pick - picks one player FROM SPECTATORS to your team and passes an opportunity to pick to next Team Leader",
	d_pageonelinefive						= "/lock - ends picking process by approving team personnel",
	d_pageonelinesix						= "/blim - limits count of builders for every team",
	d_pageonelineseven						= "/alim - limits count of archers for every team",
	d_pageonelineeight						= "/togglechclass - switch change of classes in shops",
	d_pageonelineplayer						= "Personal:",
	d_pageonelinenine						= "/bindings - show mod settings menu (оставлена как альтернатива кнопке)",
	d_pageonelineten						= "/realstone - convert 50 units of virtual stone to real stone",
	d_pageonelineel							= "/togglesounds - mute or unmute sound commands",
	d_pageonelinefooter						= "The tag wheel, mod emote wheel, bindings and player settings are in the mod settings menu!",

		// Page 2 (1)
	d_pagetwolinemain						= "Gruhsha CTF: RU Captains Modification",
	d_pagetwolineone						= "Gruhsha CTF - this is the Russian Captains version.",
	d_pagetwolinetwo						= "Our goal is to turn vanilla CTF into a competitive mode, keeping the core rules and balancing the available items",
	d_pagetwolinethree						= "and mechanics around the principle of team play, destroying known unfair ways to win.",
	d_pagetwolinefour						= "A brief excursion into the main changes of the mod:",
	d_pagetwolinefive						= "- Builder and archer classes have limits on the number of people playing them simultaneously;",
	d_pagetwolinesix						= "- Knights are allowed to use drills in specific zones (team base and inside the red zone boundary);",
	d_pagetwolineseven						= "- Changed the physics of trampolines: they push you forward with a force determined by your jump height or speed;",
	d_pagetwolineeight						= "- Each player has his own pool of materials, stone and wood are virtual from now on;",
	d_pagetwolinekek						= "- Saws produce wood for the player who bought it (introduced to help builders with wood);",
	d_pagetwolinenine						= "- Carefully balanced the properties of some items and their prices;",
	d_pagetwolineten						= "- Added custom mod settings (menu is called through the button above the player tables);",
	d_pagetwolineel							= "- Fixed some braindead bugs of the vanilla game;",
	d_pagetwolinetwen						= "- And much, much more.",
	d_pagetwolinefooter						= "Click on any button to the left of the panel to go to another page.",

		// Page 3
	d_pagethreelinemain						= "Mod authors",
	d_pagethreelineone						= "Skemonde - first developer of Gruhsha CTF",
	d_pagethreelinetwo						= "TerminalHash - mod maintainer",
	d_pagethreelinethree					= "Programmers:",
	d_pagethreelinefour						= "TerminalHash, Skemonde, kussakaa, egor0928931, Vagrament aka FeenRant",
	d_pagethreelinefive						= "Artists:",
	d_pagethreelinesix						= "TerminalHash, Skemonde, kussakaa",

	// PickingCommands.as
	d_bindingscom							= "Show mod bindings menu",
	d_togglechcomtext						= "Switch change of classes in shops",
	d_togglechcomchat						= "Class change is now ",
	d_togglechcom2							= "allowed",
	d_togglechcom3							= "disallowed",
	d_archerlimchat							= "Maximum archers now is ",
	d_archerlimtext							= "Limits count of archers for every team",
	d_builderlimchat						= "Maximum builders now is ",
	d_builderlimtext						= "Limits count of builders for every team",
	d_lockcomtext							= "Ends picking process by approving team personnel",
	d_lockcomchatunl						= "Teams unlocked",
	d_lockcomchatloc						= "Teams locked",
	d_pickcomtext							= "Picks one player FROM SPECTATORS to your team and passes an opportunity to pick to next Team Leader",
	d_demotecomtext							= "Demotes the Team Leaders",
	d_appointcomtext						= "Appoints two Team Leaders (they pick players in their teams)",
	d_specallcomtext						= "Puts everyone in Spectators",

	// Satchel.as
	d_satcheldesc							= "Ignites flammable blocks, activated by throw key",

	// SoundsCommands.as
	d_togglesoundscomtext					= "Mute or unmute sound commands",
	d_togglesoundschattexton				= "Annoying sounds is muted for you, ",
	d_togglesoundschattextoff				= "Annoying sounds is unmuted for you, ",

	// ScoreboardRender.as
	d_currentversiontext					= "Current version: ",

	// ClassSelectMenu.as
	d_totaltext								= "Total ",

	// Quarters.as
	d_peartext								= "A juicy and sweet pear.",

	//////////////////////////////////////////////////////////
	// Names
	//////////////////////////////////////////////////////////

	//BindingsCommon.as

		// Buttons
	n_modbindsmenu							= "Emotes/Tags",
	n_blocksmenu							= "Blocks",
	n_actionsmenu							= "Actions",
	n_settingsmenu							= "Settings",
	n_tagwheel								= "Tag Wheel",
	n_emotewheelvanilla						= "Vanilla Emote Wheel",
	n_emotewheelsecond						= "Mod Emote Wheel",

		// Blocks
	n_stonebl								= "Stone Block",
	n_stoneback								= "Stone Backwall",
	n_stonedoor								= "Stone Door",
	n_woodbl								= "Wood Block",
	n_woodback								= "Wood Backwall",
	n_wooddoor								= "Wood Door",
	n_platformt								= "Team Platform",
	n_ladder								= "Ladder",
	n_platform								= "Platform",
	n_shop									= "Shop",
	n_spikes								= "Spikes",

		// Actions
	n_drillcommand							= "Take out drill",

		// Settings
	n_buildmode								= "Build Mode",
	n_blockbar								= "Show block bar HUD",
	n_camerasw								= "Camera Sway (DEFAULT: 5)",
	n_bodytilt								= "Immersive body behaviour",
	n_drillzoneborders						= "Drill Zone Borders",

		// Other
	n_pressdelete							= "Choose a bind and press [DELETE] to remove key",

	// ScoreboardCommon.as
	n_modsettingsbutton						= " Settings",

	// ScoreboardRender.as
	n_matssection							= "Materials",

	// Quarters.as
	n_beeritem								= "Beer - 1 Heart",
	n_mealitem								= "Meal - Full Health",
	n_eggitem								= "Egg - Full Health",
	n_burgeritem							= "Burger - Full Health",
	n_pearitem								= "Pear - 2 Hearts",

	empty 					= ""; // keep last
}
