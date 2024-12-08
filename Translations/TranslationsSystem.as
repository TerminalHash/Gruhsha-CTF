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
	stonearrowdesc		  	    	= Translate(en::d_stonearrowdesc+"\\"+ru::d_stonearrowdesc),
	mountedbowdesc		  	    	= Translate(en::d_mountedbowdesc+"\\"+ru::d_mountedbowdesc),

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
	universalold		  	  		= Translate(en::d_universalold+"\\"+ru::d_universalold),
	universalnew		  	  		= Translate(en::d_universalnew+"\\"+ru::d_universalnew),

	// GameHelp.as
	header1		  	  				= Translate(en::d_header1+"\\"+ru::d_header1),
	header2		  	  				= Translate(en::d_header2+"\\"+ru::d_header2),
	header3		  	  				= Translate(en::d_header3+"\\"+ru::d_header3),
	header4		  	  				= Translate(en::d_header4+"\\"+ru::d_header4),
	header5		  	  				= Translate(en::d_header5+"\\"+ru::d_header5),
	header6		  	  				= Translate(en::d_header6+"\\"+ru::d_header6),
	header7		  	  				= Translate(en::d_header7+"\\"+ru::d_header7),
	header8		  	  				= Translate(en::d_header8+"\\"+ru::d_header8),
	tiptext1		  	  			= Translate(en::d_tiptext1+"\\"+ru::d_tiptext1),
	tiptext2		  	  			= Translate(en::d_tiptext2+"\\"+ru::d_tiptext2),
	tiptext3		  	  			= Translate(en::d_tiptext3+"\\"+ru::d_tiptext3),
	tiptext4		  	  			= Translate(en::d_tiptext4+"\\"+ru::d_tiptext4),
	tiptext5		  	  			= Translate(en::d_tiptext5+"\\"+ru::d_tiptext5),
	tiptext6		  	  			= Translate(en::d_tiptext6+"\\"+ru::d_tiptext6),
	tiptext7		  	  			= Translate(en::d_tiptext7+"\\"+ru::d_tiptext7),
	tiptext8		  	  			= Translate(en::d_tiptext8+"\\"+ru::d_tiptext8),

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

	// KnightShop.as
	stickybombdesc					= Translate(en::d_stickybombdesc+"\\"+ru::d_stickybombdesc),
	goldenminedesc					= Translate(en::d_goldenminedesc+"\\"+ru::d_goldenminedesc),
	slideminedesc					= Translate(en::d_slideminedesc+"\\"+ru::d_slideminedesc),
	icebombdesc						= Translate(en::d_icebombdesc+"\\"+ru::d_icebombdesc),
	fumokegdesc						= Translate(en::d_fumokegdesc+"\\"+ru::d_fumokegdesc),
	boosterdesc						= Translate(en::d_boosterdesc+"\\"+ru::d_boosterdesc),

	// Satchel.as
	satcheldesc			  	       	= Translate(en::d_satcheldesc+"\\"+ru::d_satcheldesc),

	// SoundsCommands.as
	togglesoundscomtext				= Translate(en::d_togglesoundscomtext+"\\"+ru::d_togglesoundscomtext),
	togglesoundschattexton			= Translate(en::d_togglesoundschattexton+"\\"+ru::d_togglesoundschattexton),
	togglesoundschattextoff			= Translate(en::d_togglesoundschattextoff+"\\"+ru::d_togglesoundschattextoff),

	// ScoreboardCommon.as
	oldstatstooltip					= Translate(en::d_oldstatstooltip+"\\"+ru::d_oldstatstooltip),

	// ScoreboardRender.as
	currentversiontext				= Translate(en::d_currentversiontext+"\\"+ru::d_currentversiontext),
	helptip							= Translate(en::d_helptip+"\\"+ru::d_helptip),

	// ClassSelectMenu.as
	totaltext						= Translate(en::d_totaltext+"\\"+ru::d_totaltext),

	// Quarters.as
	beertext						= Translate(en::d_beertext+"\\"+ru::d_beertext),
	mealtext						= Translate(en::d_mealtext+"\\"+ru::d_mealtext),
	burgertext						= Translate(en::d_burgertext+"\\"+ru::d_burgertext),
	peartext						= Translate(en::d_peartext+"\\"+ru::d_peartext),
	sleeptext						= Translate(en::d_sleeptext+"\\"+ru::d_sleeptext),

	// VehicleShop.as
	bomberdesc						= Translate(en::d_bomberdesc+"\\"+ru::d_bomberdesc),

	// TimeToEnd.as
	thirtyminutesleft				= Translate(en::d_thirtyminutesleft+"\\"+ru::d_thirtyminutesleft),
	suddenactive					= Translate(en::d_suddenactive+"\\"+ru::d_suddenactive),
	kegbuff							= Translate(en::d_kegbuff+"\\"+ru::d_kegbuff),
	drillbuff1						= Translate(en::d_drillbuff1+"\\"+ru::d_drillbuff1),
	drillbuff2						= Translate(en::d_drillbuff2+"\\"+ru::d_drillbuff2),
	blockreqdebuff					= Translate(en::d_blockreqdebuff+"\\"+ru::d_blockreqdebuff),
	respawndebuff					= Translate(en::d_respawndebuff+"\\"+ru::d_respawndebuff),
	shielddebuff					= Translate(en::d_shielddebuff+"\\"+ru::d_shielddebuff),
	swordbuff						= Translate(en::d_swordbuff+"\\"+ru::d_swordbuff),
	pricedebuff						= Translate(en::d_pricedebuff+"\\"+ru::d_pricedebuff),

	empty 					= "";
}

namespace Names
{
	const string

	// ArcherShop.as
	woodenarrow		  	      	 	= Translate(en::n_woodenarrow+"\\"+ru::n_woodenarrow),
	stonearrow		  	      	 	= Translate(en::n_stonearrow+"\\"+ru::n_stonearrow),
	bombarrow		  	      	 	= Translate(en::n_bombarrow+"\\"+ru::n_bombarrow),

	// BindingsCommon.as
		// Buttons
	modbindemote		  	    		= Translate(en::n_modbindemote+"\\"+ru::n_modbindemote),
	modbindsmenu		  	      	 	= Translate(en::n_modbindsmenu+"\\"+ru::n_modbindsmenu),
	emotemenu		  	      	 		= Translate(en::n_emotemenu+"\\"+ru::n_emotemenu),
	blocksmenu		  	      	 		= Translate(en::n_blocksmenu+"\\"+ru::n_blocksmenu),
	actionsmenu		  	      	 		= Translate(en::n_actionsmenu+"\\"+ru::n_actionsmenu),
	archernmb		  	      	 		= Translate(en::n_archernmb+"\\"+ru::n_archernmb),
	buildernmb		  	      	 		= Translate(en::n_buildernmb+"\\"+ru::n_buildernmb),
	knightnmb		  	      	 		= Translate(en::n_knightnmb+"\\"+ru::n_knightnmb),
	quartersnmb		  	      	 		= Translate(en::n_quartersnmb+"\\"+ru::n_quartersnmb),
	vehiclenmb		  	      	 		= Translate(en::n_vehiclenmb+"\\"+ru::n_vehiclenmb),
	boatnmb		  	      	 			= Translate(en::n_boatnmb+"\\"+ru::n_boatnmb),
	settingsmenu		  	      	 	= Translate(en::n_settingsmenu+"\\"+ru::n_settingsmenu),
	vsettingsmenu		  	      	 	= Translate(en::n_vsettingsmenu+"\\"+ru::n_vsettingsmenu),
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
	markbuildercommand					= Translate(en::n_markbuildercommand+"\\"+ru::n_markbuildercommand),
	activateorthrowbomb					= Translate(en::n_activateorthrowbomb+"\\"+ru::n_activateorthrowbomb),
	putitemcommand						= Translate(en::n_putitemcommand+"\\"+ru::n_putitemcommand),
	blockrotatecommand					= Translate(en::n_blockrotatecommand+"\\"+ru::n_blockrotatecommand),
	showinvkey							= Translate(en::n_showinvkey+"\\"+ru::n_showinvkey),

		// NoMenuBuying Binds
			// Knight Shop
	bombnmb								= Translate(en::n_bombnmb+"\\"+ru::n_bombnmb),
	waterbombnmb						= Translate(en::n_waterbombnmb+"\\"+ru::n_waterbombnmb),
	minenmb								= Translate(en::n_minenmb+"\\"+ru::n_minenmb),
	kegnmb								= Translate(en::n_kegnmb+"\\"+ru::n_kegnmb),
	drillnmb							= Translate(en::n_drillnmb+"\\"+ru::n_drillnmb),
	satchelnmb							= Translate(en::n_satchelnmb+"\\"+ru::n_satchelnmb),
	stickybombnmb						= Translate(en::n_stickybombnmb+"\\"+ru::n_stickybombnmb),
	goldenminenmb						= Translate(en::n_goldenminenmb+"\\"+ru::n_goldenminenmb),
	icebombnmb							= Translate(en::n_icebombnmb+"\\"+ru::n_icebombnmb),
	slideminenmb						= Translate(en::n_slideminenmb+"\\"+ru::n_slideminenmb),
	boosternmb							= Translate(en::n_boosternmb+"\\"+ru::n_boosternmb),
	fumokegnmb							= Translate(en::n_fumokegnmb+"\\"+ru::n_fumokegnmb),

			// Builder Shop
	drillbnmb							= Translate(en::n_drillbnmb+"\\"+ru::n_drillbnmb),
	spongebnmb							= Translate(en::n_spongebnmb+"\\"+ru::n_spongebnmb),
	bucketwnmb							= Translate(en::n_bucketwnmb+"\\"+ru::n_bucketwnmb),
	bouldernmb							= Translate(en::n_bouldernmb+"\\"+ru::n_bouldernmb),
	lanternnmb							= Translate(en::n_lanternnmb+"\\"+ru::n_lanternnmb),
	bucketnnmb							= Translate(en::n_bucketnnmb+"\\"+ru::n_bucketnnmb),
	trampolinenmb						= Translate(en::n_trampolinenmb+"\\"+ru::n_trampolinenmb),
	sawnmb								= Translate(en::n_sawnmb+"\\"+ru::n_sawnmb),
	cratewoodnmb						= Translate(en::n_cratewoodnmb+"\\"+ru::n_cratewoodnmb),
	cratecoinsnmb						= Translate(en::n_cratecoinsnmb+"\\"+ru::n_cratecoinsnmb),

			// Archer Shop
	arrowsnmb							= Translate(en::n_arrowsnmb+"\\"+ru::n_arrowsnmb),
	waterarrowsnmb						= Translate(en::n_waterarrowsnmb+"\\"+ru::n_waterarrowsnmb),
	firearrowsnmb						= Translate(en::n_firearrowsnmb+"\\"+ru::n_firearrowsnmb),
	bombarrowsnmb						= Translate(en::n_bombarrowsnmb+"\\"+ru::n_bombarrowsnmb),
	blockarrowsnmb						= Translate(en::n_blockarrowsnmb+"\\"+ru::n_blockarrowsnmb),
	stoneblockarrowsnmb					= Translate(en::n_stoneblockarrowsnmb+"\\"+ru::n_stoneblockarrowsnmb),
	mountedbownmb						= Translate(en::n_mountedbownmb+"\\"+ru::n_mountedbownmb),

			// Quarters
	beernmb								 = Translate(en::n_beernmb+"\\"+ru::n_beernmb),
	mealnmb								 = Translate(en::n_mealnmb+"\\"+ru::n_mealnmb),
	eggnmb								 = Translate(en::n_eggnmb+"\\"+ru::n_eggnmb),
	burgernmb							 = Translate(en::n_burgernmb+"\\"+ru::n_burgernmb),
	pearnmb								 = Translate(en::n_pearnmb+"\\"+ru::n_pearnmb),
	sleepnmb							 = Translate(en::n_sleepnmb+"\\"+ru::n_sleepnmb),

			// Vehicle Shop
	catapultnmb								 = Translate(en::n_catapultnmb+"\\"+ru::n_catapultnmb),
	ballistanmb								 = Translate(en::n_ballistanmb+"\\"+ru::n_ballistanmb),
	bombernmb								 = Translate(en::n_bombernmb+"\\"+ru::n_bombernmb),
	outpostnmb								 = Translate(en::n_outpostnmb+"\\"+ru::n_outpostnmb),
	boltsnmb								 = Translate(en::n_boltsnmb+"\\"+ru::n_boltsnmb),
	shellsnmb								 = Translate(en::n_shellsnmb+"\\"+ru::n_shellsnmb),

			// Boat Shop
	dinghynmb							 = Translate(en::n_dinghynmb+"\\"+ru::n_dinghynmb),
	longboatnmb							 = Translate(en::n_longboatnmb+"\\"+ru::n_longboatnmb),
	warboatnmb							 = Translate(en::n_warboatnmb+"\\"+ru::n_warboatnmb),

		// Settings
	buildmode		  	      			 = Translate(en::n_buildmode+"\\"+ru::n_buildmode),
	blockbar		  	      			 = Translate(en::n_blockbar+"\\"+ru::n_blockbar),
	dsewnmb								 = Translate(en::n_dsewnmb+"\\"+ru::n_dsewnmb),
	shownomenubuyingpan					 = Translate(en::n_shownomenubuyingpan+"\\"+ru::n_shownomenubuyingpan),
	nomenubuyingset						 = Translate(en::n_nomenubuyingset+"\\"+ru::n_nomenubuyingset),
	nomenubuyingboldarset				 = Translate(en::n_nomenubuyingboldarset+"\\"+ru::n_nomenubuyingboldarset),
	camerasw		  	      			 = Translate(en::n_camerasw+"\\"+ru::n_camerasw),
	bodytilt		  	      			 = Translate(en::n_bodytilt+"\\"+ru::n_bodytilt),
	headrotating		  	      		 = Translate(en::n_headrotating+"\\"+ru::n_headrotating),
	clusterfuck	  	      				 = Translate(en::n_clusterfuck+"\\"+ru::n_clusterfuck),
	clusterfuck_blood	  	      		 = Translate(en::n_clusterfuck_blood+"\\"+ru::n_clusterfuck_blood),
	clusterfuck_smoke	  	      		 = Translate(en::n_clusterfuck_smoke+"\\"+ru::n_clusterfuck_smoke),
	drillzoneborders		  	      	 = Translate(en::n_drillzoneborders+"\\"+ru::n_drillzoneborders),
	grapplewhilecharging	  	      	 = Translate(en::n_grapplewhilecharging+"\\"+ru::n_grapplewhilecharging),
	annoyingnature		 	 	      	 = Translate(en::n_annoyingnature+"\\"+ru::n_annoyingnature),
	annoyingvoicelines		 	 	     = Translate(en::n_annoyingvoicelines+"\\"+ru::n_annoyingvoicelines),
	annoyingtags		 	 	      	 = Translate(en::n_annoyingtags+"\\"+ru::n_annoyingtags),
	customdpsounds		 	 	      	 = Translate(en::n_customdpsounds+"\\"+ru::n_customdpsounds),
	switchclasschanginginshop			 = Translate(en::n_switchclasschanginginshop+"\\"+ru::n_switchclasschanginginshop),
	drillknight							 = Translate(en::n_drillknight+"\\"+ru::n_drillknight),
	drillbuilder			 			 = Translate(en::n_drillbuilder+"\\"+ru::n_drillbuilder),
	drillarcher							 = Translate(en::n_drillarcher+"\\"+ru::n_drillarcher),
	bombbuilder							 = Translate(en::n_bombbuilder+"\\"+ru::n_bombbuilder),
	bombarcher							 = Translate(en::n_bombarcher+"\\"+ru::n_bombarcher),
	cyclewithitem						 = Translate(en::n_cyclewithitem+"\\"+ru::n_cyclewithitem),
	visualitempick						 = Translate(en::n_visualitempick+"\\"+ru::n_visualitempick),
	pickupsystem						 = Translate(en::n_pickupsystem+"\\"+ru::n_pickupsystem),
	classpanels						 	 = Translate(en::n_classpanels+"\\"+ru::n_classpanels),
	airdroppanel						 = Translate(en::n_airdroppanel+"\\"+ru::n_airdroppanel),
	customboomeffects					 = Translate(en::n_customboomeffects+"\\"+ru::n_customboomeffects),

		// Other
	pressdelete		  	       			= Translate(en::n_pressdelete+"\\"+ru::n_pressdelete),

	// Food.as
	burgerinv		  	       			= Translate(en::n_burgerinv+"\\"+ru::n_burgerinv),

	// KnightShop.as
	stickybomb							= Translate(en::n_stickybomb+"\\"+ru::n_stickybomb),
	goldenmine							= Translate(en::n_goldenmine+"\\"+ru::n_goldenmine),
	slidemine							= Translate(en::n_slidemine+"\\"+ru::n_slidemine),
	icebomb								= Translate(en::n_icebomb+"\\"+ru::n_icebomb),
	fumokegname							= Translate(en::n_fumokegname+"\\"+ru::n_fumokegname),
	booster								= Translate(en::n_booster+"\\"+ru::n_booster),

	// KIWI_Playercard.as
	medalsn		  	       				= Translate(en::n_medalsn+"\\"+ru::n_medalsn),
	partipin		  	       			= Translate(en::n_partipin+"\\"+ru::n_partipin),
	clanbadgetext		  	       		= Translate(en::n_clanbadgetext+"\\"+ru::n_clanbadgetext),

	// ScoreboardCommon.as
	modsettingsbutton	  	       		= Translate(en::n_modsettingsbutton+"\\"+ru::n_modsettingsbutton),
	damagedealtsc	  	       			= Translate(en::n_damagedealtsc+"\\"+ru::n_damagedealtsc),
	killsperminute	  	       			= Translate(en::n_killsperminute+"\\"+ru::n_killsperminute),

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
