#include "ChatCommand.as"

class AllMatsCommand : BlobCommand
{
	AllMatsCommand()
	{
		super("allmats", "Spawn all types of materials");
		AddAlias("allmaterials");
		AddAlias("materials");
		AddAlias("mats");
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		getRules().add_s32("personalwood_" + player.getUsername(), 500);
		getRules().Sync("personalwood_" + player.getUsername(), true);

		getRules().add_s32("personalstone_" + player.getUsername(), 500);
		getRules().Sync("personalstone_" + player.getUsername(), true);

		/*CBlob@ wood = server_CreateBlob("mat_wood", -1, pos);
		wood.server_SetQuantity(500);
		CBlob@ stone = server_CreateBlob("mat_stone", -1, pos);
		stone.server_SetQuantity(500);*/
		CBlob@ gold = server_CreateBlob("mat_gold", -1, pos);
		gold.server_SetQuantity(100);
	}
}

class WoodCommand : BlobCommand
{
	WoodCommand()
	{
		super("wood", "Spawn wood");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		//Sound::Play("achievement");

		getRules().add_s32("personalwood_" + player.getUsername(), 500);
		getRules().Sync("personalwood_" + player.getUsername(), true);
	}

	/*void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ wood = server_CreateBlob("mat_wood", -1, pos);
		wood.server_SetQuantity(500);
	}*/
}

class StoneCommand : BlobCommand
{
	StoneCommand()
	{
		super("stone", "Spawn stone");
		AddAlias("stones");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		//Sound::Play("achievement");

		getRules().add_s32("personalstone_" + player.getUsername(), 500);
		getRules().Sync("personalstone_" + player.getUsername(), true);
	}

	/*void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ stone = server_CreateBlob("mat_stone", -1, pos);
		stone.server_SetQuantity(500);
	}*/
}

class GoldCommand : BlobCommand
{
	GoldCommand()
	{
		super("gold", "Spawn gold");
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		CBlob@ gold = server_CreateBlob("mat_gold", -1, pos);
		gold.server_SetQuantity(100);
	}
}

class ConvertStoneToReal : BlobCommand
{
	ConvertStoneToReal()
	{
		super("realstone", "Convert virtual stone to real world");
	}

	bool canPlayerExecute(CPlayer@ player)
	{
		return (
			ChatCommand::canPlayerExecute(player) &&
			!ChatCommands::getManager().whitelistedClasses.empty()
		);
	}

	void SpawnBlobAt(Vec2f pos, string[] args, CPlayer@ player)
	{
		getRules().sub_s32("personalstone_" + player.getUsername(), 50);
		getRules().Sync("personalstone_" + player.getUsername(), true);

		CBlob@ stone = server_CreateBlob("mat_stone", -1, pos);
		stone.server_SetQuantity(50);
	}

}
