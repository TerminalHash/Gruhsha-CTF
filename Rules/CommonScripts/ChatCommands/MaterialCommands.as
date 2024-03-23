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
		getRules().add_s32("personalwood_" + player.getTeamNum(), 500);
		getRules().Sync("personalwood_" + player.getTeamNum(), true);

		getRules().add_s32("personalstone_" + player.getTeamNum(), 500);
		getRules().Sync("personalstone_" + player.getTeamNum(), true);

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

		getRules().add_s32("personalwood_" + player.getTeamNum(), 500);
		getRules().Sync("personalwood_" + player.getTeamNum(), true);
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

		getRules().add_s32("personalstone_" + player.getTeamNum(), 500);
		getRules().Sync("personalstone_" + player.getTeamNum(), true);
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

class ConvertStoneToReal : ChatCommand
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

	void Execute(string[] args, CPlayer@ player)
	{
		CRules@ rules = getRules();

		u8 team = player.getBlob().getTeamNum();
		Vec2f pos = player.getBlob().getPosition();

		if (player.isMyPlayer())
		{
			rules.sub_s32("personalstone_" + player.getTeamNum(), 250);
			rules.Sync("personalwood_" + player.getTeamNum(), true);

			server_CreateBlob("mat_stone" + player.getTeamNum(), team, pos + Vec2f(0, -5));
		}

		//printf("Boolean no_class_change_on_shop is " + rules.get_bool("no_class_change_on_shop"));
	}
}
