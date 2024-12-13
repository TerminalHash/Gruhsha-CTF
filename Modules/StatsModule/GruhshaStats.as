// GruhshaStats.as
/*
	Скрипт кастомной статистики для Gruhsha CTF.
	Основан на наработках Bunnie.
*/
#define SERVER_ONLY

#include "Hitters.as";
#include "GruhshaHitters.as";

const string mapStatsTag = "map stats";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

    if (text_in == "*offi" && (player.getUsername() == "TerminalHash" || player.getUsername() == "Pnext" || player.getUsername() == "egor0928931" || player.getUsername() == "kusaka79") || player.getUsername() == "H1996R"))
	{
		if(!this.hasTag("track_stats"))
		{
			this.Tag("track_stats");
			this.Sync("track_stats", true);
			printf("[INFO] Statistic tracking enabled on this match!");

			this.Tag("offi match");
			this.Sync("offi match", true);
			printf("[INFO] This match tagged as offi by " + player.getUsername());

			// disable internal map editor
			this.Untag("editor is active");
			this.Sync("editor is active", true);

			// disable sv_test
			if (sv_test)
				sv_test = false;

			tcpr("MatchBegin" + " " + getGameTime());

			for (int i=0; i < getPlayerCount(); i++) 
			{
				CPlayer@ p = getPlayer(i);
				if (p is null) continue;

				if (p.getTeamNum() != 0 && p.getTeamNum() != 1) continue;
				
				string player_name = p.getUsername();

				tcpr("PlayerJoin " + player_name + " " + p.getTeamNum() + " " + getGameTime());

				if (p.getBlob() !is null)
				{
					tcpr("SwitchClass " + player_name + " " + p.getBlob().getName() + " " + getGameTime());
				}
			}
		}
	}

	if (text_in == "*tcprtest" && player.getUsername() == "TerminalHash")
	{
		tcpr("TCPRTEST LOSHADINUI HUI JARA IUL");
	}

	if (text_in == "*close" && player.getUsername() == "TerminalHash")
	{
		tcpr("CLOSE");
	}

	return true;
}

void onRestart(CRules@ this)
{
	if (this.hasTag("track_stats"))
	{
		tcpr("EMERGENCYCLEAN");
	}

	this.Untag("track_stats");
	this.Sync("track_stats", true);

	this.Untag("offi match");
	this.Sync("offi match", true);

	this.Untag("sudden death");
	this.Sync("sudden death", true);
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player ) 
{
	//tcpr("PlayerJoin " + player.getUsername());
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!this.hasTag("track_stats"))
	{
		return;
	}

	if (this.getCurrentState() != GAME)
	{
		return;
	}

	if (sv_tcpr && victim !is null )
	{
		string hitter_string;

			switch (customData)
			{
				case Hitters::fall:     		hitter_string = "fall"; break;

				case Hitters::drown:     		hitter_string = "water"; break;

				case Hitters::fire:
				case Hitters::burn:     		hitter_string = "fire"; break;

				case Hitters::stomp:    		hitter_string = "stomp"; break;

				case Hitters::builder:  		hitter_string = "builder"; break;

				case Hitters::spikes:  			hitter_string = "spikes"; break;

				case Hitters::sword:    		hitter_string = "sword"; break;

				case Hitters::shield:   		hitter_string = "shield"; break;

				case Hitters::bomb_arrow:		hitter_string = "bombarrow"; break;

				case Hitters::bomb:
				case Hitters::explosion:     	hitter_string = "bomb"; break;

				case Hitters::keg:     			hitter_string = "keg"; break;

				case Hitters::mine:             hitter_string = "mine"; break;
				case Hitters::mine_special:     hitter_string = "mine"; break;

				case Hitters::arrow:    		hitter_string = "arrow"; break;

				case Hitters::ballista: 		hitter_string = "ballista"; break;

				case Hitters::boulder:			hitter_string = "boulder"; break;
				case Hitters::cata_stones:		hitter_string = "stones"; break;
				case Hitters::cata_boulder:  	hitter_string = "boulder"; break;

				case Hitters::drill:			hitter_string = "drill"; break;
				case Hitters::saw:				hitter_string = "saw"; break;

				case GruhshaHitters::tile_entity:	hitter_string = "tile_entity"; break;

				default: 						hitter_string = "fall";
			}

		string victim_name = victim.getUsername();
		string victim_class = victim.lastBlobName;

		string killer_name = victim_name;
		string killer_class = victim_class;
		int killer_team = victim.getTeamNum();

		if (killer !is null)
		{
			killer_name = killer.getUsername();
			killer_class = killer.lastBlobName;
			killer_team = killer.getTeamNum();
		}

		tcpr("Kill " + killer_name + " " + killer_class	+ " " + killer_team + " " +  
			victim_name + " " + victim_class + " " + victim.getTeamNum() + " " + 
			hitter_string + " " + getGameTime());
	}
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 old_team, u8 newteam )
{
	if (!this.hasTag("track_stats") || player is null || this is null) return;

	string player_name = player.getUsername();

	if(old_team == 1 || old_team == 0)
		tcpr("PlayerLeave " + player_name + " " + old_team + " " + getGameTime());

	if(newteam == 1 || newteam == 0)
		tcpr("PlayerJoin " + player_name + " " + newteam + " " + getGameTime());
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if (!this.hasTag("track_stats") || player is null) return;

	if (player.getTeamNum() != 0 && player.getTeamNum() != 1) return;

	string player_name = player.getUsername();

	tcpr("PlayerLeave " + player_name + " " + player.getTeamNum() + " " + getGameTime());
}

void onStateChange( CRules@ this, const u8 oldState )
{
	if (!this.hasTag("track_stats")) return;

	if (this.isGameOver()) {
		string mapName = getFilenameWithoutExtension(getFilenameWithoutPath(getMap().getMapName()));

		for (int i=0; i < getPlayerCount(); i++)  {
			CPlayer@ p = getPlayer(i);
			if (p is null) continue;

			if (p.getTeamNum() != 0 && p.getTeamNum() != 1) continue;

			string player_damage = getRules().get_f32("damage_impact_" + p.getUsername());
			
			string player_name = p.getUsername();

			tcpr("PlayerDamage " + player_name + " " +  player_damage);

			tcpr("PlayerLeave " + player_name + " " + p.getTeamNum() + " " + getGameTime());
		}

		if (this.getTeamWon() >= 0)
			tcpr("MatchEnd " + this.getTeamWon() + " " + mapName + " " + getGameTime());
		else
			tcpr("MatchEnd " + "TIE" + " " + mapName + " " + getGameTime());

		this.Untag("track_stats");
		this.Sync("track_stats", true);
	}
}

// Wrong limit message
/*void onRender(CRules@ this) {
	CPlayer@ my_player = getLocalPlayer();
	if (my_player is null) return;

	// dont show message to non-admin users
	if (my_player.getUsername() != "TerminalHash") return;

	if (this.hasTag("track_stats") && this.get_u8("archers_limit") > 2 && this.get_u8("builders_limit") > 2) {
		GUI::SetFont("Balkara_Condensed");
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 450), color_white);
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 500), color_white);
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 550), color_white);
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 600), color_white);
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 650), color_white);
		GUI::DrawTextCentered("DOLBAEB FIX LIMIT INACHE SOSAL", Vec2f(getScreenWidth()/2, 700), color_white);
	}

}*/
