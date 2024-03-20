#include "ChatCommandManager.as"
#include "TagCommands.as"

//command register order is not important
//actual order in help command is based on the order of commands in ChatCommands.cfg
void RegisterTagChatCommands(ChatCommandManager@ manager)
{
	//tags commands
	manager.RegisterCommand(MuteTags());
	manager.RegisterCommand(UnmuteTags());

}
