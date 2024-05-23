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
	bronzetokentext		  	    	= Translate(en::d_bronzetokentext+"\\"+ru::d_bronzetokentext),
	kiwitext		  	    		= Translate(en::d_kiwitext+"\\"+ru::d_kiwitext),
	captaintext		  	    		= Translate(en::d_captaintext+"\\"+ru::d_captaintext),

	// ArcherShop.as
	woodenarrowdesc		  	    	= Translate(en::d_woodenarrowdesc+"\\"+ru::d_woodenarrowdesc),

	// BindingsCommon.as
	modbindplaceholder		  	    = Translate(en::d_modbindplaceholder+"\\"+ru::d_modbindplaceholder),
	modbindnull		  	    		= Translate(en::d_modbindnull+"\\"+ru::d_modbindnull),

			// Settings
	bmoptlag						= Translate(en::d_bmoptlag+"\\"+ru::d_bmoptlag),
	bmoptvan						= Translate(en::d_bmoptvan+"\\"+ru::d_bmoptvan),
	universalyes		  	  		= Translate(en::d_universalyes+"\\"+ru::d_universalyes),
	universalno		  	  			= Translate(en::d_universalno+"\\"+ru::d_universalno),
	universalon		  	  			= Translate(en::d_universalon+"\\"+ru::d_universalon),
	universaloff		  	  		= Translate(en::d_universaloff+"\\"+ru::d_universaloff),

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
	preventvoicelinespamtext		= Translate(en::d_preventvoicelinespamtext+"\\"+ru::d_preventvoicelinespamtext),

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
	beertext						= Translate(en::d_beertext+"\\"+ru::d_beertext),
	mealtext						= Translate(en::d_mealtext+"\\"+ru::d_mealtext),
	burgertext						= Translate(en::d_burgertext+"\\"+ru::d_burgertext),
	peartext						= Translate(en::d_peartext+"\\"+ru::d_peartext),
	sleeptext						= Translate(en::d_sleeptext+"\\"+ru::d_sleeptext),

	empty 					= "";
}

namespace Names
{
	const string

	// ArcherShop.as
	woodenarrow		  	      	 	= Translate(en::n_woodenarrow+"\\"+ru::n_woodenarrow),
	bombarrow		  	      	 	= Translate(en::n_bombarrow+"\\"+ru::n_bombarrow),

	// BindingsCommon.as
		// Buttons
	modbindemote		  	    		= Translate(en::n_modbindemote+"\\"+ru::n_modbindemote),
	modbindsmenu		  	      	 	= Translate(en::n_modbindsmenu+"\\"+ru::n_modbindsmenu),
	emotemenu		  	      	 		= Translate(en::n_emotemenu+"\\"+ru::n_emotemenu),
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
	cancelarrowschargingcommand			= Translate(en::n_cancelarrowschargingcommand+"\\"+ru::n_cancelarrowschargingcommand),

		// Settings
	buildmode		  	      			 = Translate(en::n_buildmode+"\\"+ru::n_buildmode),
	blockbar		  	      			 = Translate(en::n_blockbar+"\\"+ru::n_blockbar),
	camerasw		  	      			 = Translate(en::n_camerasw+"\\"+ru::n_camerasw),
	bodytilt		  	      			 = Translate(en::n_bodytilt+"\\"+ru::n_bodytilt),
	headrotating		  	      		 = Translate(en::n_headrotating+"\\"+ru::n_headrotating),
	clusterfuck	  	      				 = Translate(en::n_clusterfuck+"\\"+ru::n_clusterfuck),
	drillzoneborders		  	      	 = Translate(en::n_drillzoneborders+"\\"+ru::n_drillzoneborders),
	annoyingnature		 	 	      	 = Translate(en::n_annoyingnature+"\\"+ru::n_annoyingnature),
	annoyingvoicelines		 	 	     = Translate(en::n_annoyingvoicelines+"\\"+ru::n_annoyingvoicelines),
	annoyingtags		 	 	      	 = Translate(en::n_annoyingtags+"\\"+ru::n_annoyingtags),
	customdpsounds		 	 	      	 = Translate(en::n_customdpsounds+"\\"+ru::n_customdpsounds),
	switchclasschanginginshop			 = Translate(en::n_switchclasschanginginshop+"\\"+ru::n_switchclasschanginginshop),

		// Other
	pressdelete		  	       			= Translate(en::n_pressdelete+"\\"+ru::n_pressdelete),

	// Food.as
	burgerinv		  	       			= Translate(en::n_burgerinv+"\\"+ru::n_burgerinv),

	// KIWI_Playercard.as
	medalsn		  	       				= Translate(en::n_medalsn+"\\"+ru::n_medalsn),
	partipin		  	       			= Translate(en::n_partipin+"\\"+ru::n_partipin),

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
	sleepaction		  	       			= Translate(en::n_sleepaction+"\\"+ru::n_sleepaction),

	empty					= "";
}
