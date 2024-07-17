#include "HolidayCommon"
#include "pathway.as"

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

int getHeadSpecs(CPlayer@ player, string &out head_file)
{
	CRules@ rules = getRules();
	if (player is null)
	{
		head_file = "Entities/Characters/Sprites/Heads.png";
		return (NUM_UNIQUEHEADS+2)*NUM_HEADFRAMES; //knight male head
		return 255;
	}

	int headIndex = player.getHead();

	// get dlc pack info
	int headsPackIndex = getHeadsPackIndex(headIndex);
	HeadsPack@ pack = getHeadsPackByIndex(headsPackIndex);
	string texture_file = pack.filename;

	bool override_frame = false;

	//get the head index relative to the pack index (without unique heads counting)
	int headIndexInPack = (headIndex - NUM_UNIQUEHEADS) - (headsPackIndex * 256);

	//(has default head set)
	bool defaultHead = (headIndex == 255 || headIndexInPack < 0 || headIndexInPack >= pack.count);
	if (defaultHead)
	{
		//accolade custom head handling
		//todo: consider pulling other custom head stuff out to here
		u8 head_idx = 0;
		if (player !is null)
		{
			string file_path = getPath() + "Base/Entities/Characters/Sprites/CustomHeads/";
			string head_file = file_path + player.getUsername() + ".png";

			bool customFileExists = CFileMatcher(head_file).hasMatch();
			bool isHeadValid = false;
			if (customFileExists) {
				//isHeadValid = CFileImage(head_file).getWidth()==64;
				isHeadValid = CFileMatcher(head_file).getFirst().find("Headpacks")>-1;
			}
			Accolades@ acc = getPlayerAccolades(player.getUsername());
			bool gotAccoladeHead = acc.hasCustomHead();

			if (g_debug > 0) {
				print("headfile "+head_file);
			}
			//print("got accolade head "+gotAccoladeHead);

			if(customFileExists&&isHeadValid)
			{
				if (g_debug>0) {
					CFileMatcher(head_file).printMatches();
					//print(player.getCharacterName() + " the " + blob.getName() + " has their head set properly! Congratz");
				}
				if (rules.exists(player.getUsername() + "HeadIndex"))
				{
					head_idx = rules.get_u8(player.getUsername() + "HeadIndex");
				}
				if (rules.exists(player.getUsername() + "Headpack"))
					texture_file = rules.get_string(player.getUsername() + "Headpack");
				else
					texture_file = head_file;
				headIndex = head_idx;
				headsPackIndex = 0;
				override_frame = true;
				//player.Tag("custom_head");
				rules.set_bool("custom_head"+player.getUsername(), true);
			} else if (gotAccoladeHead) {
				texture_file = acc.customHeadTexture;
				headIndex = acc.customHeadIndex;
				headsPackIndex = 0;
				override_frame = true;
				rules.set_bool("custom_head"+player.getUsername(), true);
			}
			else if (rules.exists(holiday_prop))
			{
				if (rules.exists(holiday_head_prop))
				{
					headIndex = rules.get_u8(holiday_head_prop);
					headsPackIndex = 0;

					if (rules.exists(holiday_head_texture_prop))
					{
						texture_file = rules.get_string(holiday_head_texture_prop);
						override_frame = true;

						headIndex += player.getSex();
						//sex for bots
						if (player.isBot())
							headIndex += player.getNetworkID()%512<256?0:1;
					}
				}
			}
			else
			{
				//player.Untag("custom_head");
				rules.set_bool("custom_head"+player.getUsername(), false);
				if (g_debug>0)
					print("no head fo ya :C");
			}
		}
	}
	else
	{
		//it's not a custom head but it's definitely not a default one too ?_?
		if (player !is null)
			rules.set_bool("custom_head"+player.getUsername(), true);
	}

	int team = doTeamColour(headsPackIndex) ? player.getTeamNum() : 0;
	int skin = doSkinColour(headsPackIndex) ? player.getSkin() : 0;

	//if player is a mere grunt or doesn't have a cool head to show off in role of CO they get a super basic head (commanders will still have a cool hat though)
	if (g_debug > 0)
		print("head n "+headIndex);

	//
	headIndex = headIndex % 256; // wrap DLC heads into "pack space"

	// figure out head frame
	s32 headFrame = override_frame ?
		(headIndex * NUM_HEADFRAMES) :
		getHeadFrame(player, headIndex, headsPackIndex == 0);

	head_file = texture_file;

	return headFrame;
}

bool doTeamColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

bool doSkinColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

//handling Heads pack DLCs

int getHeadsPackIndex(int headIndex)
{
	if (headIndex > 255) {
		if ((headIndex % 256) >= NUM_UNIQUEHEADS) {
			return Maths::Min(getHeadsPackCount() - 1, Maths::Floor(headIndex / 256.0f));
		}
	}
	return 0;
}

string getHeadTexture(int headIndex)
{
	return getHeadsPackByIndex(getHeadsPackIndex(headIndex)).filename;
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
