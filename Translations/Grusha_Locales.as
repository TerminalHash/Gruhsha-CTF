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

	// Example code: oooolmao		  	       	= Translate(en::d_oooolmao+"\\"+ru::d_oooolmao),

	empty 					= "";
}

namespace Names
{
	const string

	// Example code: oooolmao		  	       	= Translate(en::n_oooolmao+"\\"+ru::n_oooolmao),

	empty					= "";
}
