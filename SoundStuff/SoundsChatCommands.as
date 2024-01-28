#include "ChatCommandManager.as"
#include "SoundsCommands.as"

//command register order is not important
//actual order in help command is based on the order of commands in ChatCommands.cfg
void RegisterSoundsChatCommands(ChatCommandManager@ manager)
{
	//sounds commands
	manager.RegisterCommand(MuteSounds());
	manager.RegisterCommand(UnmuteSounds());

}
