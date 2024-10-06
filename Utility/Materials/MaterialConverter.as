// MaterialConverter.as

s32 convert_time_inventory = 10;
s32 convert_time_carried = 5;

///////////////////////////////////////////////
// Converter heart
void onTick(CBlob@ this)
{
    if (!isServer()) return;

    CInventory@ inv = this.getInventory();
    CBlob@ carried = this.getCarriedBlob();

    // Convert material, if player have it in inventory
    if (this !is null && inv !is null) {
    	for (int i = 0; i < inv.getItemsCount(); i++) {
            CBlob@ item = inv.getItem(i);
            const string name = item.getName();

            const int stone_count = inv.getCount("mat_stone");
            const int wood_count = inv.getCount("mat_wood");

            // DEBUG
            /*if (name == "mat_stone") {
                printf("Stone amount in inventory is " + stone_count);
            } else if (name == "mat_wood") {
                printf("Wood amount in inventory is " + wood_count);
            }*/

            if (name == "mat_stone" &&
                    item.get_s32("pickup time") != -1 &&
                    getGameTime() > convert_time_inventory * getTicksASecond() + item.get_s32("pickup time")) {
                getRules().add_s32("teamstone" + this.getTeamNum(), stone_count);
                getRules().Sync("teamstone" + this.getTeamNum(), true);
                inv.server_RemoveItems("mat_stone", stone_count);

                this.SendCommand(this.getCommandID("play convert sound"));
            } else if (name == "mat_wood" &&
                    item.get_s32("pickup time") != -1 &&
                    getGameTime() > convert_time_inventory * getTicksASecond() + item.get_s32("pickup time")) {
                getRules().add_s32("teamwood" + this.getTeamNum(), wood_count);
                getRules().Sync("teamwood" + this.getTeamNum(), true);
                inv.server_RemoveItems("mat_wood", wood_count);

                this.SendCommand(this.getCommandID("play convert sound"));
            }
        }
    }

    // Convert material, if player holds it
    if (this !is null && carried !is null) {
        if (carried.getConfig() == "mat_stone") {
            u16 stone_count = carried.getQuantity();
            //printf("Stone amount in inventory is " + stone_count);

            if (carried.get_s32("attach time") != -1 &&
                getGameTime() > convert_time_carried * getTicksASecond() + carried.get_s32("attach time")) {
                getRules().add_s32("teamstone" + this.getTeamNum(), stone_count);
                getRules().Sync("teamstone" + this.getTeamNum(), true);
                carried.server_Die();

                this.SendCommand(this.getCommandID("play convert sound"));
            }
        } else if (carried.getConfig() == "mat_wood") {
            u16 wood_count = carried.getQuantity();
           // printf("Wood amount in inventory is " + wood_count);

            if (carried.get_s32("attach time") != -1 &&
                getGameTime() > convert_time_carried * getTicksASecond() + carried.get_s32("attach time")) {
                getRules().add_s32("teamwood" + this.getTeamNum(), wood_count);
                getRules().Sync("teamwood" + this.getTeamNum(), true);
                carried.server_Die();

                this.SendCommand(this.getCommandID("play convert sound"));
            }
        }
    }
}
///////////////////////////////////////////////
///////////////////////////////////////////////

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("play convert sound") && isClient()) {
        this.getSprite().PlaySound("/mat_converted.ogg");
    }
}

// Set attach timer
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if (!isServer()) return;

    u16 mats_count = attached.getQuantity();

    if (this !is null && attached !is null) {
        if (attached.getConfig() == "mat_stone") {
            attached.set_s32("attach time", getGameTime());
            attached.Sync("attach time", true);

            //printf("Stone attach time is " + attached.get_s32("attach time"));
        } else if (attached.getConfig() == "mat_wood") {
            attached.set_s32("attach time", getGameTime());
            attached.Sync("attach time", true);

            //printf("Wood attach time is " + attached.get_s32("attach time"));
        }
    }
}

void onDetach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if (!isServer()) return;

    u16 mats_count = attached.getQuantity();

    if (this !is null && attached !is null) {
        if (attached.getConfig() == "mat_stone") {
            attached.set_s32("attach time", -1);
            attached.Sync("attach time", true);

            //printf("Stone attach time is " + attached.get_s32("attach time"));
        } else if (attached.getConfig() == "mat_wood") {
            attached.set_s32("attach time", -1);
            attached.Sync("attach time", true);

            //printf("Wood attach time is " + attached.get_s32("attach time"));
        }
    }
}

// Set pickup timer
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
    if (!isServer()) return;

    if (this !is null && blob !is null) {
        if (blob.getConfig() == "mat_stone") {
            blob.set_s32("pickup time", getGameTime());
            blob.Sync("pickup time", true);

            //printf("Stone pickup time is " + blob.get_s32("pickup time"));
        } else if (blob.getConfig() == "mat_wood") {
            blob.set_s32("pickup time", getGameTime());
            blob.Sync("pickup time", true);

            //printf("Wood pickup time is " + blob.get_s32("pickup time"));
        }
    }
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob) {
    if (!isServer()) return;

    if (this !is null && blob !is null) {
        if (blob.getConfig() == "mat_stone") {
            blob.set_s32("pickup time", -1);
            blob.Sync("pickup time", true);

            //printf("Stone pickup time is " + blob.get_s32("pickup time"));
        } else if (blob.getConfig() == "mat_wood") {
            blob.set_s32("pickup time", -1);
            blob.Sync("pickup time", true);

            //printf("Wood pickup time is " + blob.get_s32("pickup time"));
        }
    }
}

// Drop materials after death
void onDie(CBlob@ this)
{
	if (isServer()) {
        if (this.hasTag("dead") && getRules().get_s32("teamstone" + this.getTeamNum()) > 0) {
            int team_stone = getRules().get_s32("teamstone" + this.getTeamNum());

            CBlob@ stone = server_CreateBlob("mat_stone", this.getPlayer().getTeamNum(), this.getPosition());
            stone.server_SetQuantity(XORRandom(team_stone / 10));

            if (stone !is null) {
                const f32 ANGLE = XORRandom(300) * 0.1f - 15;
                Vec2f force = Vec2f(0, -1);
                force.RotateBy(ANGLE);
                force *= stone.getMass() * 3.6f;
                stone.AddForce(force);
            }

            getRules().sub_s32("teamstone" + this.getTeamNum(), stone.getQuantity());
            getRules().Sync("teamstone" + this.getTeamNum(), true);
        }
        else if (this.hasTag("dead") && getRules().get_s32("teamstone" + this.getTeamNum()) <= 0) { return; } // we dont have material to spawn, lol

        if (this.hasTag("dead") && getRules().get_s32("teamwood" + this.getTeamNum()) > 0) {
            int team_wood = getRules().get_s32("teamwood" + this.getTeamNum());

            CBlob@ wood = server_CreateBlob("mat_wood", this.getPlayer().getTeamNum(), this.getPosition());
            wood.server_SetQuantity(XORRandom(team_wood / 10));

            if (wood !is null) {
                const f32 ANGLE = XORRandom(300) * 0.1f - 15;
                Vec2f force = Vec2f(0, -1);
                force.RotateBy(ANGLE);
                force *= wood.getMass() * 3.6f;
                wood.AddForce(force);
            }

            getRules().sub_s32("teamwood" + this.getTeamNum(), wood.getQuantity());
            getRules().Sync("teamwood" + this.getTeamNum(), true);
        }
        else if (this.hasTag("dead") && getRules().get_s32("teamwood" + this.getTeamNum()) <= 0) { return; } // we dont have material to spawn, lol
	}
}