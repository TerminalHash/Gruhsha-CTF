//#define DEBUG_CLASSCOUNTER

u8[][] numberPlayersInClassTeam = {{0,0,0,0,0,0},{0,0,0,0,0,0}};
// 0 - knight blue
// 1 - knight red
// 2 - builder blue
// 3 - builder red
// 4 - archer blue
// 5 - archer red

u8 oldMas = 0;
u8 newMas = 1;

void onTick(CRules@ this) {
    if (!isServer() || getGameTime() % 30 != 0) return;
	// check every one second

	// check technical value of available classes and change factual values
	for(int i = 0; i < 6; i++)
		numberPlayersInClassTeam[newMas][i] = 0;

	for(u32 i = 0, playersCount = getPlayersCount(); i < playersCount; i++) {
		CPlayer@ player = getPlayer(i);
		u8 team = player.getTeamNum();
		if(team < 2 && player.lastBlobConfig != "") {
			u8 blobConfig = player.lastBlobConfig[0];

			if(blobConfig == 107) // == 'k'
				numberPlayersInClassTeam[newMas][0 + team] += 1;
			else if(blobConfig == 98) // == 'b'
				numberPlayersInClassTeam[newMas][2 + team] += 1;
			else //if(blobConfig == 97) // == 'a'
				numberPlayersInClassTeam[newMas][4 + team] += 1;
		}
	}

	if (numberPlayersInClassTeam[oldMas][0] != numberPlayersInClassTeam[newMas][0]) {
        printf("[CLASS COUNTER] Adding new blue knight");
		this.set_s32("knight0Count", numberPlayersInClassTeam[newMas][0]);
		this.Sync("knight0Count", true);
	}

	if (numberPlayersInClassTeam[oldMas][1] != numberPlayersInClassTeam[newMas][1]) {
        printf("[CLASS COUNTER] Adding new red knight");
		this.set_s32("knight1Count", numberPlayersInClassTeam[newMas][1]);
		this.Sync("knight1Count", true);
	}

	if (numberPlayersInClassTeam[oldMas][2] != numberPlayersInClassTeam[newMas][2]) {
        printf("[CLASS COUNTER] Adding new blue builder");
		this.set_s32("builder0Count", numberPlayersInClassTeam[newMas][2]);
		this.Sync("builder0Count", true);
	}

	if (numberPlayersInClassTeam[oldMas][3] != numberPlayersInClassTeam[newMas][3]) {
        printf("[CLASS COUNTER] Adding new red builder");
		this.set_s32("builder1Count", numberPlayersInClassTeam[newMas][3]);
		this.Sync("builder1Count", true);
	}

	if (numberPlayersInClassTeam[oldMas][4] != numberPlayersInClassTeam[newMas][4]) {
        printf("[CLASS COUNTER] Adding new blue archer");
		this.set_s32("archer0Count", numberPlayersInClassTeam[newMas][4]);
		this.Sync("archer0Count", true);
	}

	if (numberPlayersInClassTeam[oldMas][5] != numberPlayersInClassTeam[newMas][5]) {
        printf("[CLASS COUNTER] Adding new red archer");
		this.set_s32("archer1Count", numberPlayersInClassTeam[newMas][5]);
		this.Sync("archer1Count", true);
	}

	//! к числам не работает аутизм поэтому вот такая фигня аналог так сказать
	//В начале мы инвертируем биты числа затем отбрасываем все биты кроме первого
	oldMas = ~oldMas&1;
	newMas = ~newMas&1;
	//printf("" + oldMas + " " + newMas+ "");

	//Что бы начать дебаг нужно раскомментрировать "#define DEBUG_CLASSCOUNTER"
	#ifdef DEBUG_CLASSCOUNTER
		//По возможности весь код для дебага фигачить сюда
		printf("[INFO] Checking players on classes...");
		for(int i = 0; i < 2; i++)
			printf("We have: " + numberPlayersInClassTeam[newMas][i] + " Knights, " + numberPlayersInClassTeam[newMas][2 + i] + " Builders, " + numberPlayersInClassTeam[newMas][4 + i] + " Archers in" + i + " team");
	#endif
}