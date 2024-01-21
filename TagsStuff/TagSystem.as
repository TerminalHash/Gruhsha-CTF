// TagSystem.as
/*

    Система меток.
    -- -- -- -- -- -- -- -- --
    Позволяет игрокам поставить временную метку в любом месте,
    уведомляющая остальных об опасности или том, что необходимо сделать.
    -- -- -- -- -- -- -- -- --
    Список меток:

    Тег         Название
    -- -- -- -- -- -- --
    keg         KEG
    help        HELP
    attack      ATTACK
    wtf         ???
    go          GO HERE
    dig         DIG HERE
    danger      DANGER
    retreat     RETREAT

*/

#include "pathway.as";
#include "TagCommon.as";
//#include "BindingsCommon.as";

string tag_pos = "tag_pos";
string tag_duration = "tag_duration";
string tag_variable = "tag_variable";
string tag_cmd_id   = "add_tag";

string path_string = getPath();
string soundsdir = path_string + "Sounds/Tags/";

void onInit(CRules@ rules)
{
    rules.addCommandID(tag_cmd_id);
}
