#include "Gruhsha_Structs.as";
#include "Gruhsha_Gamemodes.as";
#include "ActorHUDStartPos.as";
//#include "CommandsHelpHUD.as";

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/


void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart( CRules@ this )
{
	if (InternalGamemode(this) == "tavern") {
		CBitStream stream;
		stream.write_u16(0xDEAD);
		this.set_CBitStream("tdm_serialised_team_hud", stream);
	} else {
    	UIData ui;

    	CBlob@[] flags;
    	if(getBlobsByName("ctf_flag", flags))
    	{
        	for(int i = 0; i < flags.size(); i++)
        	{
            	CBlob@ blob = flags[i];
            	ui.flagIds.push_back(blob.getNetworkID());
            	ui.flagStates.push_back("f");
            	ui.flagTeams.push_back(blob.getTeamNum());
            	ui.addTeam(blob.getTeamNum());
        	}
    	}

    	this.set("uidata", @ui);

    	CBitStream bt = ui.serialize();
		this.set_CBitStream("ctf_serialised_team_hud", bt);
		this.Sync("ctf_serialised_team_hud", true);

		//set for all clients to ensure safe sync
		this.set_s16("stalemate_breaker", 0);
	}
}

//only for after the fact if you spawn a flag
void onBlobCreated( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

	if (InternalGamemode(this) != "tavern") {
    	if(blob.getName() == "ctf_flag")
    	{
        	UIData@ ui;
        	this.get("uidata", @ui);

        	if(ui is null) return;

        	ui.flagIds.push_back(blob.getNetworkID());
        	ui.flagStates.push_back("f");
        	ui.flagTeams.push_back(blob.getTeamNum());
        	ui.addTeam(blob.getTeamNum());

        	CBitStream bt = ui.serialize();

			this.set_CBitStream("ctf_serialised_team_hud", bt);
			this.Sync("ctf_serialised_team_hud", true);
    	}
	}
}

void onBlobDie( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

	if (this.get_string("internal_game_mode") != "tavern") {
    	if(blob.getName() == "ctf_flag")
    	{
        	UIData@ ui;
        	this.get("uidata", @ui);

        	if(ui is null) return;

        	int id = blob.getNetworkID();

        	for(int i = 0; i < ui.flagIds.size(); i++)
        	{
            	if(ui.flagIds[i] == id)
            	{
                	ui.flagStates[i] = "c";

            	}
        	}

        	CBitStream bt = ui.serialize();
			this.set_CBitStream("ctf_serialised_team_hud", bt);
			this.Sync("ctf_serialised_team_hud", true);
    	}
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	CBitStream serialised_team_hud;
	this.get_CBitStream("ctf_serialised_team_hud", serialised_team_hud);

	CBitStream serialised_tavern_hud;
	this.get_CBitStream("tavern_serialised_team_hud", serialised_tavern_hud);

	if (InternalGamemode(this) != "tavern") {
		if (serialised_team_hud.getBytesUsed() > 8) {
			serialised_team_hud.Reset();
			u16 check;

			if (serialised_team_hud.saferead_u16(check) && check == 0x5afe) {
				const string gui_image_fname = "Rules/CTF/CTFGui.png";

				while (!serialised_team_hud.isBufferEnd()) {
					CTF_HUD hud(serialised_team_hud);
					Vec2f topLeft = Vec2f(8, 80 + 64 * hud.team_num);

					int step = 0;
					Vec2f startFlags = Vec2f(0, 8);

					string pattern = hud.flag_pattern;
					string flag_char = "";
					int size = int(pattern.size());

					GUI::DrawRectangle(topLeft + Vec2f(4, 4), topLeft + Vec2f(size * 32 + 26, 60));

					while (step < size) {
						flag_char = pattern.substr(step, 1);

						int frame = 0;

						if (flag_char == "c") { //c captured
							frame = 2;
						} else if (flag_char == "m") { //m missing
							frame = getGameTime() % 20 > 10 ? 1 : 2;
						} else if (flag_char == "f") { //f fine
							frame = 0;
						}

						GUI::DrawIcon(gui_image_fname, frame , Vec2f(16, 24), topLeft + startFlags + Vec2f(14 + step * 32, 0) , 1.0f, hud.team_num);

						step++;
					}
				}
			}

			serialised_team_hud.Reset();
		}

		string propname = "ctf spawn time " + p.getUsername();
		if (p.getBlob() is null && this.exists(propname)) {
			u8 spawn = this.get_u8(propname);

			if (this.isMatchRunning() && spawn != 255) {
				string spawn_message = getTranslatedString("Respawning in: {SEC}").replace("{SEC}", ((spawn > 250) ? getTranslatedString("approximatively never") : ("" + spawn)));

				GUI::SetFont("hud");
				GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
		}

		// main panel
		GUI::DrawIcon("CTF_NewInterface.png", 0, Vec2f(155,36), Vec2f(5, 5));

		Vec2f state_icon_pos = Vec2f(5, 4);

		// state icons for HUD
		if (!this.hasTag("sudden death")) {
			if (this.get_bool("is_warmup"))
				GUI::DrawIcon("CTF_States.png", 0, Vec2f(32, 32), state_icon_pos, 1.0f);
			else if (this.isMatchRunning() || this.getCurrentState() == GAME)
				GUI::DrawIcon("CTF_States.png", 1, Vec2f(32, 32), state_icon_pos, 1.0f);
			else if (this.getCurrentState() == GAME_OVER)
				GUI::DrawIcon("CTF_States.png", 3, Vec2f(32, 32), state_icon_pos, 1.0f);
		}
	} else {
		GUI::SetFont("menu");
		if (serialised_tavern_hud.getBytesUsed() > 10)
		{
			serialised_tavern_hud.Reset();
			u16 check;

			if (serialised_tavern_hud.saferead_u16(check) && check == 0x5afe)
			{
				const string gui_image_fname = "TDMGui.png";

				while (!serialised_tavern_hud.isBufferEnd())
				{
					TAVERN_HUD hud(serialised_tavern_hud);
					Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);
					GUI::DrawIcon(gui_image_fname, 0, Vec2f(128, 32), topLeft, 1.0f, hud.team_num);
					int team_player_count = 0;
					int team_dead_count = 0;
					int step = 0;
					Vec2f startIcons = Vec2f(64, 8);
					Vec2f startSkulls = Vec2f(160, 8);
					string player_char = "";
					int size = int(hud.unit_pattern.size());

					while (step < size)
					{
						player_char = hud.unit_pattern.substr(step, 1);
						step++;

						if (player_char == " ") { continue; }

						if (player_char != "s")
						{
							int player_frame = 1;

							if (player_char == "a")
							{
								player_frame = 2;
							}

							GUI::DrawIcon(gui_image_fname, 12 + player_frame, Vec2f(16, 16), topLeft + startIcons + Vec2f(team_player_count * 8, 0) , 1.0f, hud.team_num);
							team_player_count++;
						}
						else
						{
							GUI::DrawIcon(gui_image_fname, 12 , Vec2f(16, 16), topLeft + startSkulls + Vec2f(team_dead_count * 16, 0) , 1.0f, hud.team_num);
							team_dead_count++;
						}
					}

					if (hud.spawn_time != 255)
					{
						string time = "" + hud.spawn_time;
						GUI::DrawText(time, topLeft + Vec2f(196, 42), SColor(255, 255, 255, 255));
					}

					string kills = getTranslatedString("WARMUP");

					if (hud.kills_limit > 0)
					{
						kills = getTranslatedString("KILLS: {CURRENT}/{LIMIT}").replace("{CURRENT}", "" + hud.kills).replace("{LIMIT}", "" + hud.kills_limit);
					}
					else if (hud.kills_limit == -2)
					{
						kills = getTranslatedString("SUDDEN DEATH");
					}

					GUI::DrawText(kills, topLeft + Vec2f(64, 42), SColor(255, 255, 255, 255));
				}
			}

			serialised_tavern_hud.Reset();
		}

		string propname = "tdm spawn time " + p.getUsername();
		if (p.getBlob() is null && this.exists(propname))
		{
			u8 spawn = this.get_u8(propname);

			if (spawn != 255)
			{
				if (spawn == 254)
				{
					GUI::DrawText(getTranslatedString("In Queue to Respawn...") , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
				}
				else if (spawn == 253)
				{
					GUI::DrawText(getTranslatedString("No Respawning - Wait for the Game to End.") , Vec2f(getScreenWidth() / 2 - 180, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
				}
				else
				{
					GUI::DrawText(getTranslatedString("Respawning in: {SEC}").replace("{SEC}", "" + spawn), Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
				}
			}
		}

		// main panel
		GUI::DrawIcon("TDM_Timer.png", 0, Vec2f(45,21), Vec2f(10, 145));
	}

	// tracker for current internal gamemode
	// for debug purposes only and only for RCON users
	if (p !is null && p.isRCON()) {
		GUI::SetFont("hud");
		string current_gaemmode;
		
		if (this.get_string("internal_game_mode") == "gruhsha")
			current_gaemmode = "CTF";
		else
			current_gaemmode = "TDM";
		
		GUI::DrawText("Current gamemode is " + current_gaemmode + " (internal name: " + this.get_string("internal_game_mode") + ")", Vec2f(320, 5), SColor(255, 255, 255, 255));
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	this.SyncToPlayer("ctf_serialised_team_hud", player);
}
