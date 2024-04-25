#include "HolidayCommon"
#include "pathway.as"

int getHeadSpecs(CPlayer@ player, string &out head_file)
{
	CRules@ rules = getRules();
	if (player is null) return 255;

	int head_idx = player.getHead();
	// get dlc pack info
	int headpack_idx = getHeadsPackIndex(head_idx);
	HeadsPack@ pack = getHeadsPackByIndex(headpack_idx);
	head_file = pack.filename;
	bool override_frame = false;

	//get the head index relative to the pack index (without unique heads counting)
	int head_idx_pack = (head_idx - NUM_UNIQUEHEADS) - (headpack_idx * 256);

	//(has default head set)
	bool defaultHead = (head_idx == 255 || head_idx_pack < 0 || head_idx_pack >= pack.count);
	if (defaultHead)
	{
		//accolade custom head handling
		//todo: consider pulling other custom head stuff out to here

		if (player !is null)
		{
			string file_path = getPath() + "Base/Entities/Characters/Sprites/CustomHeads/";
			string png_file = file_path + player.getUsername() + ".png";

			bool customFileExists = CFileMatcher(png_file).hasMatch();
			bool isHeadValid = false;
			if (customFileExists)
				isHeadValid = CFileImage(png_file).getWidth()==64;
			Accolades@ acc = getPlayerAccolades(player.getUsername());
			bool gotAccoladeHead = acc.hasCustomHead();

			if(customFileExists)
			{
				if (rules.exists(player.getUsername() + "HeadIndex"))
				{
					head_idx = rules.get_u8(player.getUsername() + "HeadIndex");
				}
				if (rules.exists(player.getUsername() + "Headpack"))
					head_file = rules.get_string(player.getUsername() + "Headpack");
				else
					head_file = png_file;

				headpack_idx = 0;
				override_frame = true;

			} else if (gotAccoladeHead) {
				head_file = acc.customHeadTexture;
				head_idx = acc.customHeadIndex;
				headpack_idx = 0;
				override_frame = true;
			}
			else if (rules.exists(holiday_prop))
			{
				if (rules.exists(holiday_head_prop))
				{
					head_idx = rules.get_u8(holiday_head_prop);
					headpack_idx = 0;

					if (rules.exists(holiday_head_texture_prop))
					{
						head_file = rules.get_string(holiday_head_texture_prop);
						override_frame = true;

						head_idx += player.getSex();
						//sex for bots
						if (player.isBot())
							head_idx += player.getNetworkID()%512<256?0:1;
					}
				}
			}
		}
	}

	bool got_custom_head = rules.get_bool("custom_head" + player.getUsername());

	if (!got_custom_head) {
		head_file = "anonymous_old.png";
		head_idx = player.getNetworkID()%3;
	}

	//
	head_idx = head_idx % 256; // wrap DLC heads into "pack space"

	// figure out head frame
	s32 head_frame = override_frame ?
		(head_idx * NUM_HEADFRAMES) :
		getHeadFrame(player, head_idx, headpack_idx == 0);

	return head_frame;
}

int getHeadFrame(CPlayer@ player, int headIndex, bool default_pack)
{
	if (headIndex < NUM_UNIQUEHEADS)
	{
		return headIndex * NUM_HEADFRAMES;
	}

	//special heads logic for default heads pack
	if (default_pack && (headIndex == 255 || headIndex < NUM_UNIQUEHEADS))
	{
		string config = player.lastBlobName;
		if (config == "builder")
		{
			headIndex = NUM_UNIQUEHEADS;
		}
		else if (config == "knight")
		{
			headIndex = NUM_UNIQUEHEADS + 1;
		}
		else if (config == "archer")
		{
			headIndex = NUM_UNIQUEHEADS + 2;
		}
		else if (config == "migrant")
		{
			Random _r(player.getNetworkID());
			headIndex = 69 + _r.NextRanged(2); //head scarf or old
		}
		else
		{
			// default
			headIndex = NUM_UNIQUEHEADS;
		}
	}

	bool is_bot = false;
	u8 bot_sex;

	if (player !is null && player.isBot()) {
		is_bot = true;
		bot_sex = player.getNetworkID()%512<256?0:1;
	}

	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) +
	        ((player.getSex() == 0 || (is_bot&&bot_sex==0)) ? 0 : 1)) * NUM_HEADFRAMES;
}

bool isFlagHead(int head_id)
{
	return head_id>=287&&head_id<=363;
}