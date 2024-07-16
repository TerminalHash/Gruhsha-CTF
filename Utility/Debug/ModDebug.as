// ModDebug.as
#include "CTF_Common.as"

void onRender(CRules@ this) {
	if (getLocalPlayer() is null) return;

    bool stats = this.hasTag("track_stats");
    bool suddendeath = this.hasTag("sudden death");
    bool offi = this.hasTag("offi match");
    bool warmup = this.get_bool("is_warmup");
    bool shopclasschanging = this.get_bool("no_class_change_on_shop");

    int archers_limit = this.get_u8("archers_limit");
    int builders_limit = this.get_u8("builders_limit");
    s32 players_team_amount = this.get_s32("amount_in_team");

    string respawn_message = "Current respawn time:";
    string tickspawndelay_default = "5 sec";
    string tickspawndelay_20 = "11 sec";
    string tickspawndelay_30 = "13 sec";
    string tickspawndelay_40 = "15 sec";

    string resupply_message = "Current resupply:";
    string stonetext = "Stone :";
    string woodtext = "Wood :";
    string stone_amount = matchtime_stone_amount;
    string wood_amount = matchtime_wood_amount;
    string stone_amount_lower = lower_stone;
    string wood_amount_lower = lower_wood;
    string stone_amount_multiple = matchtime_stone_amount * builders_limit;
    string wood_amount_multiple = matchtime_wood_amount * builders_limit;
    string stone_amount_multiple_lower = lower_stone * builders_limit;
    string wood_amount_multiple_lower = lower_wood * builders_limit;

    string alimtext = archers_limit;
    string blimtext = builders_limit;
    string pcounttext = players_team_amount;

    string gamestate_message = "Current game state:";
    string pcount_message = "Current player amount in teams:";

    string intertext = "INTERMISSION";
    string warmuptext = "WARMUP";
    string gametext = "GAME";
    string gameovertext = "GAME_OVER";

    string dynreqmatstext = "1.2";
    string dynreqmatssdtext = "1.35";
    string kegtext = "48.0f";
    string kegsdtext = "72.0f";

    string stats_message = "Stats in this match:";
    string sudden_message = "Sudden Death Mode in this match:";
    string offi_message = "Offi in this match:";
    string warmup_message = "Warmup in this match:";

    string alim_message = "Archers limit in this match:";
    string blim_message = "Builders limit in this match:";
    string scc_message = "Class changing in shops:";
    string lowermats_message = "Lower material resupply in this match:";
    string dynreq_mats_message = "Current dynamic mats multiplier:";
    string keg_message = "Current keg power:";
    string drillzone_message = "Current drillzone state:";

    string activated = "ACTIVE";
    string notactivated = "NOT ACTIVE";
    string allowed = "ALLOWED";
    string notallowed = "NOTALLOWED";

    SColor green = 0xff00ff02;
    SColor red = ConsoleColour::ERROR;

	if (getLocalPlayer().getUsername() == "TerminalHash") {

        if (getControls().isKeyPressed(KEY_NUMPAD5)) {

            GUI::SetFont("menu");

            // Game shit section
            GUI::DrawTextCentered(gamestate_message, Vec2f(1000, 450), color_white);
            if (this.getCurrentState() == INTERMISSION) {
                GUI::DrawTextCentered(intertext, Vec2f(1000, 464), color_white);
            } else if (this.getCurrentState() == WARMUP) {
                GUI::DrawTextCentered(warmuptext, Vec2f(1000, 464), color_white);
            } else if (this.getCurrentState() == GAME) {
                GUI::DrawTextCentered(gametext, Vec2f(1000, 464), color_white);
            } else if (this.getCurrentState() == GAME_OVER) {
                GUI::DrawTextCentered(gameovertext, Vec2f(1000, 464), color_white);
            }

            GUI::DrawTextCentered(pcount_message, Vec2f(1000, 480), color_white);
            GUI::DrawTextCentered(pcounttext, Vec2f(1000, 494), color_white);


            GUI::DrawTextCentered(respawn_message, Vec2f(1000, 510), color_white);
            if (getGameTime() >= 900 * getTicksASecond() && getGameTime() <= 1500 * getTicksASecond()) {
                GUI::DrawTextCentered(tickspawndelay_20, Vec2f(1000, 524), color_white);
            } else if (getGameTime() >= 1500 * getTicksASecond() && getGameTime() <= 2100 * getTicksASecond()) {
                GUI::DrawTextCentered(tickspawndelay_30, Vec2f(1000, 524), color_white);
            } else if (getGameTime() >= 2100 * getTicksASecond()) {
                GUI::DrawTextCentered(tickspawndelay_40, Vec2f(1000, 524), color_white);
            } else {
                GUI::DrawTextCentered(tickspawndelay_default, Vec2f(1000, 524), color_white);
            }

            GUI::DrawTextCentered(resupply_message, Vec2f(1000, 540), color_white);
            if (this.hasTag("offi match")) {
                if (getGameTime() > lower_mats_timer * getTicksASecond()) {
                    if (builders_limit == 1) {
                        GUI::DrawTextCentered(stonetext + stone_amount_lower, Vec2f(1000, 554), color_white);
                        GUI::DrawTextCentered(woodtext + wood_amount_lower, Vec2f(1000, 568), color_white);
                    }

                    if (builders_limit > 1) {
                        GUI::DrawTextCentered(stonetext + stone_amount_multiple_lower, Vec2f(1000, 554), color_white);
                        GUI::DrawTextCentered(woodtext + wood_amount_multiple_lower, Vec2f(1000, 568), color_white);
                    }
                } else {
                    if (builders_limit == 1) {
                        GUI::DrawTextCentered(stonetext + stone_amount, Vec2f(1000, 554), color_white);
                        GUI::DrawTextCentered(woodtext + wood_amount, Vec2f(1000, 568), color_white);
                    }

                    if (builders_limit > 1) {
                        GUI::DrawTextCentered(stonetext + stone_amount_multiple, Vec2f(1000, 554), color_white);
                        GUI::DrawTextCentered(woodtext + wood_amount_multiple, Vec2f(1000, 568), color_white);
                    }
                }
            } else if (!warmup) {
                if (getGameTime() > lower_mats_timer * getTicksASecond()) {
                    GUI::DrawTextCentered(stonetext + stone_amount_lower, Vec2f(1000, 554), color_white);
                    GUI::DrawTextCentered(woodtext + wood_amount_lower, Vec2f(1000, 568), color_white);
                } else {
                    GUI::DrawTextCentered(stonetext + stone_amount, Vec2f(1000, 554), color_white);
                    GUI::DrawTextCentered(woodtext + wood_amount, Vec2f(1000, 568), color_white);
                }
            }

            // Booleans/tags section
            GUI::DrawTextCentered(stats_message, Vec2f(1280, 450), color_white);
            if (stats) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 464), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 464), red);
            }

            GUI::DrawTextCentered(sudden_message, Vec2f(1280, 480), color_white);
            if (suddendeath) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 494), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 494), red);
            }

            GUI::DrawTextCentered(offi_message, Vec2f(1280, 510), color_white);
            if (offi) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 524), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 524), red);
            }

            GUI::DrawTextCentered(warmup_message, Vec2f(1280, 540), color_white);
            if (warmup) {
                GUI::DrawTextCentered(activated, Vec2f(1280, 554), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1280, 554), red);
            }

            // Other section
            GUI::DrawTextCentered(alim_message, Vec2f(1560, 450), color_white);
            if (archers_limit != 0) {
                GUI::DrawTextCentered(alimtext, Vec2f(1560, 464), green);
            } else {
                GUI::DrawTextCentered("NULL", Vec2f(1560, 464), red);
            }

            GUI::DrawTextCentered(blim_message, Vec2f(1560, 480), color_white);
            if (builders_limit != 0) {
                GUI::DrawTextCentered(blimtext, Vec2f(1560, 494), green);
            } else {
                GUI::DrawTextCentered("NULL", Vec2f(1560, 494), red);
            }

            GUI::DrawTextCentered(scc_message, Vec2f(1560, 510), color_white);
            if (!shopclasschanging) {
                GUI::DrawTextCentered(allowed, Vec2f(1560, 524), green);
            } else {
                GUI::DrawTextCentered(notallowed, Vec2f(1560, 524), red);
            }

            GUI::DrawTextCentered(lowermats_message, Vec2f(1560, 540), color_white);
            if (getGameTime() > lower_mats_timer * getTicksASecond()) {
                GUI::DrawTextCentered(activated, Vec2f(1560, 554), green);
            } else {
                GUI::DrawTextCentered(notactivated, Vec2f(1560, 554), red);
            }

            GUI::DrawTextCentered(dynreq_mats_message, Vec2f(1560, 570), color_white);
            if (suddendeath) {
                GUI::DrawTextCentered(dynreqmatssdtext, Vec2f(1560, 584), color_white);
            } else {
                GUI::DrawTextCentered(dynreqmatstext, Vec2f(1560, 584), color_white);
            }

            GUI::DrawTextCentered(keg_message, Vec2f(1560, 600), color_white);
            if (suddendeath) {
                GUI::DrawTextCentered(kegsdtext, Vec2f(1560, 614), color_white);
            } else {
                GUI::DrawTextCentered(kegtext, Vec2f(1560, 614), color_white);
            }

            GUI::DrawTextCentered(drillzone_message, Vec2f(1560, 630), color_white);
            if (suddendeath) {
                GUI::DrawTextCentered(notactivated, Vec2f(1560, 644), red);
            } else {
                GUI::DrawTextCentered(activated, Vec2f(1560, 644), green);
            }
        }
    }
}