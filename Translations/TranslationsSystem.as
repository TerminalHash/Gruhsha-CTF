// TranslationsSystem.as
/*
	Система переводов для Grusha CTF

	Основана на наработках GingerBeard и использует отдельные
	скриптовые файлы для определения слов, описаний и тд.

	Имеющиеся языки:
	Russian
	English
*/

#include "language_en.as"
#include "language_ru.as"

// works by seperating each language by token '\\'
// all translations are only set on startup, therefore changing language mid-game will not update the strings
shared const string Translate(const string&in words)
{
	string[]@ tokens = words.split("\\");
	if (g_locale == "ru" && tokens.length > 1 && !tokens[1].empty()) 	//russian
		return tokens[1];	
		
	return tokens[0];													//english
}

namespace Descriptions
{
	const string

	// Accolades.as
	goldgrushatext		  	    	= Translate(en::d_goldgrushatext+"\\"+ru::d_goldgrushatext),

	// BindingsCommon.as
	modbindplaceholder		  	    = Translate(en::d_modbindplaceholder+"\\"+ru::d_modbindplaceholder),
	modbindnull		  	    		= Translate(en::d_modbindnull+"\\"+ru::d_modbindnull),

			// Settings
	bmoptlag						= Translate(en::d_bmoptlag+"\\"+ru::d_bmoptlag),
	bmoptvan						= Translate(en::d_bmoptvan+"\\"+ru::d_bmoptvan),
	blockbaron		  	  			= Translate(en::d_blockbaron+"\\"+ru::d_blockbaron),
	blockbaroff		  	  			= Translate(en::d_blockbaroff+"\\"+ru::d_blockbaroff),
	universalon		  	  			= Translate(en::d_universalon+"\\"+ru::d_universalon),
	universaloff		  	  		= Translate(en::d_universaloff+"\\"+ru::d_universaloff),

	// CommandsHelpHUD.as
		// Page 1 (2)
	pageonelinemain					= Translate(en::d_pageonelinemain+"\\"+ru::d_pageonelinemain),
	pageonelinecaptain				= Translate(en::d_pageonelinecaptain+"\\"+ru::d_pageonelinecaptain),
	pageonelineone					= Translate(en::d_pageonelineone+"\\"+ru::d_pageonelineone),
	pageonelinetwo					= Translate(en::d_pageonelinetwo+"\\"+ru::d_pageonelinetwo),
	pageonelinethree				= Translate(en::d_pageonelinethree+"\\"+ru::d_pageonelinethree),
	pageonelinefour					= Translate(en::d_pageonelinefour+"\\"+ru::d_pageonelinefour),
	pageonelinefive					= Translate(en::d_pageonelinefive+"\\"+ru::d_pageonelinefive),
	pageonelinesix					= Translate(en::d_pageonelinesix+"\\"+ru::d_pageonelinesix),
	pageonelineseven				= Translate(en::d_pageonelineseven+"\\"+ru::d_pageonelineseven),
	pageonelineeight				= Translate(en::d_pageonelineeight+"\\"+ru::d_pageonelineeight),
	pageonelineplayer				= Translate(en::d_pageonelineplayer+"\\"+ru::d_pageonelineplayer),
	pageonelinenine					= Translate(en::d_pageonelinenine+"\\"+ru::d_pageonelinenine),
	pageonelineten					= Translate(en::d_pageonelineten+"\\"+ru::d_pageonelineten),
	pageonelineel					= Translate(en::d_pageonelineel+"\\"+ru::d_pageonelineel),
	pageonelinefooter				= Translate(en::d_pageonelinefooter+"\\"+ru::d_pageonelinefooter),

		// Page 2 (1)
	pagetwolinemain					= Translate(en::d_pagetwolinemain+"\\"+ru::d_pagetwolinemain),
	pagetwolineone					= Translate(en::d_pagetwolineone+"\\"+ru::d_pagetwolineone),
	pagetwolinetwo					= Translate(en::d_pagetwolinetwo+"\\"+ru::d_pagetwolinetwo),
	pagetwolinethree				= Translate(en::d_pagetwolinethree+"\\"+ru::d_pagetwolinethree),
	pagetwolinefour					= Translate(en::d_pagetwolinefour+"\\"+ru::d_pagetwolinefour),
	pagetwolinefive					= Translate(en::d_pagetwolinefive+"\\"+ru::d_pagetwolinefive),
	pagetwolinesix					= Translate(en::d_pagetwolinesix+"\\"+ru::d_pagetwolinesix),
	pagetwolineseven				= Translate(en::d_pagetwolineseven+"\\"+ru::d_pagetwolineseven),
	pagetwolineeight				= Translate(en::d_pagetwolineeight+"\\"+ru::d_pagetwolineeight),
	pagetwolinekek					= Translate(en::d_pagetwolinekek+"\\"+ru::d_pagetwolinekek),
	pagetwolinenine					= Translate(en::d_pagetwolinenine+"\\"+ru::d_pagetwolinenine),
	pagetwolineten					= Translate(en::d_pagetwolineten+"\\"+ru::d_pagetwolineten),
	pagetwolineel					= Translate(en::d_pagetwolineel+"\\"+ru::d_pagetwolineel),
	pagetwolinetwen					= Translate(en::d_pagetwolinetwen+"\\"+ru::d_pagetwolinetwen),
	pagetwolinefooter				= Translate(en::d_pagetwolinefooter+"\\"+ru::d_pagetwolinefooter),

		// Page 3
	pagethreelinemain				= Translate(en::d_pagethreelinemain+"\\"+ru::d_pagethreelinemain),
	pagethreelineone				= Translate(en::d_pagethreelineone+"\\"+ru::d_pagethreelineone),
	pagethreelinetwo				= Translate(en::d_pagethreelinetwo+"\\"+ru::d_pagethreelinetwo),
	pagethreelinethree				= Translate(en::d_pagethreelinethree+"\\"+ru::d_pagethreelinethree),
	pagethreelinefour				= Translate(en::d_pagethreelinefour+"\\"+ru::d_pagethreelinefour),
	pagethreelinefive				= Translate(en::d_pagethreelinefive+"\\"+ru::d_pagethreelinefive),
	pagethreelinesix				= Translate(en::d_pagethreelinesix+"\\"+ru::d_pagethreelinesix),

	// PickingCommands.as
	bindingscom		  	       		= Translate(en::d_bindingscom+"\\"+ru::d_bindingscom),
	togglechcomtext		  	       	= Translate(en::d_togglechcomtext+"\\"+ru::d_togglechcomtext),
	togglechcomchat		  	       	= Translate(en::d_togglechcomchat+"\\"+ru::d_togglechcomchat),
	togglechcom2		  	       	= Translate(en::d_togglechcom2+"\\"+ru::d_togglechcom2),
	togglechcom3		  	       	= Translate(en::d_togglechcom3+"\\"+ru::d_togglechcom3),
	archerlimchat		  	       	= Translate(en::d_archerlimchat+"\\"+ru::d_archerlimchat),
	archerlimtext		  	       	= Translate(en::d_archerlimtext+"\\"+ru::d_archerlimtext),
	builderlimchat		  	       	= Translate(en::d_builderlimchat+"\\"+ru::d_builderlimchat),
	builderlimtext		  	       	= Translate(en::d_builderlimtext+"\\"+ru::d_builderlimtext),
	lockcomtext		  	      	 	= Translate(en::d_lockcomtext+"\\"+ru::d_lockcomtext),
	lockcomchatunl		  	      	= Translate(en::d_lockcomchatunl+"\\"+ru::d_lockcomchatunl),
	lockcomchatloc		  	       	= Translate(en::d_lockcomchatloc+"\\"+ru::d_lockcomchatloc),
	pickcomtext		  	    	   	= Translate(en::d_pickcomtext+"\\"+ru::d_pickcomtext),
	demotecomtext		  	       	= Translate(en::d_demotecomtext+"\\"+ru::d_demotecomtext),
	appointcomtext		  	       	= Translate(en::d_appointcomtext+"\\"+ru::d_appointcomtext),
	specallcomtext		  	       	= Translate(en::d_specallcomtext+"\\"+ru::d_specallcomtext),

	// Satchel.as
	satcheldesc			  	       	= Translate(en::d_satcheldesc+"\\"+ru::d_satcheldesc),

	// SoundsCommands.as
	togglesoundscomtext				= Translate(en::d_togglesoundscomtext+"\\"+ru::d_togglesoundscomtext),
	togglesoundschattexton			= Translate(en::d_togglesoundschattexton+"\\"+ru::d_togglesoundschattexton),
	togglesoundschattextoff			= Translate(en::d_togglesoundschattextoff+"\\"+ru::d_togglesoundschattextoff),

	// ScoreboardRender.as
	currentversiontext				= Translate(en::d_currentversiontext+"\\"+ru::d_currentversiontext),

	// ClassSelectMenu.as
	totaltext						= Translate(en::d_totaltext+"\\"+ru::d_totaltext),

	// Quarters.as
	peartext						= Translate(en::d_peartext+"\\"+ru::d_peartext),

	empty 					= "";
}

namespace Names
{
	const string

	// BindingsCommon.as
		// Buttons
	modbindsmenu		  	      	 	= Translate(en::n_modbindsmenu+"\\"+ru::n_modbindsmenu),
	blocksmenu		  	      	 		= Translate(en::n_blocksmenu+"\\"+ru::n_blocksmenu),
	actionsmenu		  	      	 		= Translate(en::n_actionsmenu+"\\"+ru::n_actionsmenu),
	settingsmenu		  	      	 	= Translate(en::n_settingsmenu+"\\"+ru::n_settingsmenu),
	tagwheel		  	       			= Translate(en::n_tagwheel+"\\"+ru::n_tagwheel),
	emotewheelvanilla		  	       	= Translate(en::n_emotewheelvanilla+"\\"+ru::n_emotewheelvanilla),
	emotewheelsecond		  	       	= Translate(en::n_emotewheelsecond+"\\"+ru::n_emotewheelsecond),

		// Blocks
	stonebl		  	      	 			= Translate(en::n_stonebl+"\\"+ru::n_stonebl),
	stoneback		  	      	 		= Translate(en::n_stoneback+"\\"+ru::n_stoneback),
	stonedoor		  	      	 		= Translate(en::n_stonedoor+"\\"+ru::n_stonedoor),
	woodbl		  	      	 			= Translate(en::n_woodbl+"\\"+ru::n_woodbl),
	woodback		  	      		 	= Translate(en::n_woodback+"\\"+ru::n_woodback),
	wooddoor		  	      		 	= Translate(en::n_wooddoor+"\\"+ru::n_wooddoor),
	platformt		  	     	 	 	= Translate(en::n_platformt+"\\"+ru::n_platformt),
	ladder		  	      	 			= Translate(en::n_ladder+"\\"+ru::n_ladder),
	platform		  	     	 	 	= Translate(en::n_platform+"\\"+ru::n_platform),
	shop		  	      	 			= Translate(en::n_shop+"\\"+ru::n_shop),
	spikes		  	      			 	= Translate(en::n_spikes+"\\"+ru::n_spikes),

		// Actions
	drillcommand		  	      		= Translate(en::n_drillcommand+"\\"+ru::n_drillcommand),

		// Settings
	buildmode		  	      			 = Translate(en::n_buildmode+"\\"+ru::n_buildmode),
	blockbar		  	      			 = Translate(en::n_blockbar+"\\"+ru::n_blockbar),
	camerasw		  	      			 = Translate(en::n_camerasw+"\\"+ru::n_camerasw),
	bodytilt		  	      			 = Translate(en::n_bodytilt+"\\"+ru::n_bodytilt),
	drillzoneborders		  	      	 = Translate(en::n_drillzoneborders+"\\"+ru::n_drillzoneborders),

		// Other
	pressdelete		  	       			= Translate(en::n_pressdelete+"\\"+ru::n_pressdelete),

	// ScoreboardCommon.as
	modsettingsbutton	  	       		= Translate(en::n_modsettingsbutton+"\\"+ru::n_modsettingsbutton),

	// ScoreboardRender.as
	matssection	  	   		    		= Translate(en::n_matssection+"\\"+ru::n_matssection),

	// Quarters.as
	beeritem		  	       			= Translate(en::n_beeritem+"\\"+ru::n_beeritem),
	mealitem		  	       			= Translate(en::n_mealitem+"\\"+ru::n_mealitem),
	eggitem		  	       				= Translate(en::n_eggitem+"\\"+ru::n_eggitem),
	burgeritem		  	       			= Translate(en::n_burgeritem+"\\"+ru::n_burgeritem),
	pearitem		  	       			= Translate(en::n_pearitem+"\\"+ru::n_pearitem),

	empty					= "";
}
