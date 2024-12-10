#include "SocialStatus.as";
#include "BindingsCommon.as";

const string editor_place 	= "editor place";
const string editor_destroy = "editor destroy";
const string editor_copy 	= "editor copy";
const string change_mode 	= "editor mode";

const string cursorTexture 	= "../Mods/PrimitiveEditor/EditorCursor.png";
 
void onInit( CRules@ this )
{
    this.addCommandID(editor_place);
    this.addCommandID(editor_destroy);
	this.addCommandID(editor_copy);
	this.addCommandID(change_mode);
}

void onTick(CRules@ this)
{
	// editor should be disabled by default
	if (!this.hasTag("editor is active")) return;

	CPlayer@ p = getLocalPlayer();
	if (p is null) return;
	
	CBlob@ b = p.getBlob();
	if (b is null) return;
	
	CMap@ map = getMap();
		
	CControls@ controls = p.getControls();
	bool op = (p.isMod() || p.isRCON()) || (isServer() && isClient()) ;
	//if player cannot use the editor we cut it here
	if (!op) return;

	//displaying fancy cursor
	if (controls.isKeyJustPressed(KEY_RCONTROL)) {
		p.set_bool("editor_cursor", !p.get_bool("editor_cursor"));
	}

	//changing mode BLOBS/TILES
	if (b_KeyJustPressed("ed_mode")) {
		CBitStream params;
		params.write_u16(p.getNetworkID());
		this.SendCommand(this.getCommandID(change_mode), params);
	}
	
	if (!b_KeyPressed("ed_modifier")) return;
	//placing/destroing by single item
	if (b_KeyPressed("ed_once_action")) {
		if (b_KeyJustPressed("ed_placing")) {
			CBitStream params;
			params.write_u16(p.getNetworkID());
			params.write_Vec2f(controls.getMouseWorldPos());
			this.SendCommand(this.getCommandID(editor_place), params);
		}
		if (b_KeyJustPressed("ed_destroying")) {
			CBitStream params;
			params.write_u16(p.getNetworkID());
			params.write_Vec2f(controls.getMouseWorldPos());
			this.SendCommand(this.getCommandID(editor_destroy), params);
		}
	}
	//placing/destroying continuously
	else {
		if (b_KeyPressed("ed_placing")) {
			CBitStream params;
			params.write_u16(p.getNetworkID());
			params.write_Vec2f(controls.getMouseWorldPos());
			this.SendCommand(this.getCommandID(editor_place), params);
		}
		if (b_KeyPressed("ed_destroying")) {
			CBitStream params;
			params.write_u16(p.getNetworkID());
			params.write_Vec2f(controls.getMouseWorldPos());
			this.SendCommand(this.getCommandID(editor_destroy), params);
		}
	}
	if (b_KeyJustPressed("ed_copy")) {
		CBitStream params;
		params.write_u16(p.getNetworkID());
		params.write_Vec2f(controls.getMouseWorldPos());
		this.SendCommand(this.getCommandID(editor_copy), params);
	}
}

void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }
	
	if(p.get_bool("editor_cursor")) {

		CBlob@ player_blob = p.getBlob();
		if (player_blob !is null) {
			string copiedBlob = player_blob.get_string("blob_to_copy");
			Vec2f position = player_blob.getAimPos();
			if (!copiedBlob.empty()) {
				if (true || CFileMatcher(copiedBlob).hasMatch()) {
					position = getDriver().getScreenPosFromWorldPos(position) + Vec2f(16, 16);
					//GUI::DrawIcon(copiedBlob+".png", position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
					GUI::DrawIconByName("$"+copiedBlob+"$", position);
				}
			}
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
	CRules@ rules = getRules();

    if (cmd == this.getCommandID(editor_destroy)) {
		u16 player_id; if(!params.saferead_u16(player_id)) return;
	    CPlayer@ p = getPlayerByNetworkId(player_id);
		Vec2f aimpos; if(!params.saferead_Vec2f(aimpos)) return;
		
		CMap@ map = getMap();
		if (p !is null) {
			CBlob@ blob = p.getBlob();
			string player_name = p.getUsername();
			bool mode = rules.get_bool("EditorMode_"+player_name);
			CControls@ controls = p.getControls();
			//if (blob !is null) {
				CBlob@ behindBlob = getMap().getBlobAtPosition(aimpos);
				if (mode) {
					if (behindBlob !is null)
						behindBlob.server_Die();
				}
				else {
					map.server_SetTile(aimpos, CMap::tile_empty);
				}
		}
	}
	else if (cmd == this.getCommandID(editor_place)) {
		u16 player_id; if(!params.saferead_u16(player_id)) return;
	    CPlayer@ p = getPlayerByNetworkId(player_id);
		Vec2f aimpos; if(!params.saferead_Vec2f(aimpos)) return;
		
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (p !is null && blob !is null) {
			string player_name = p.getUsername();
			bool mode = rules.get_bool("EditorMode_"+player_name);
			if (!mode) {
				if (blob.get_TileType("buildtile") != 0)
					map.server_SetTile(aimpos, blob.get_TileType("buildtile"));
			}
			else {
				if (canPlaceBlobAtPos(getBottomOfCursor(aimpos))) {
					CBlob@ newblob = null;
					if (blob.getCarriedBlob() !is null)
					{
						@newblob = server_CreateBlob(blob.getCarriedBlob().getName(), blob.getCarriedBlob().getTeamNum(), getBottomOfCursor(aimpos));
					}
					else if (!blob.get_string("blob_to_copy").empty())
					{
						@newblob = server_CreateBlob(blob.get_string("blob_to_copy"), blob.get_u16("blob_to_copy_team"), getBottomOfCursor(aimpos));
					}
					if (newblob !is null) {
						if (newblob.isSnapToGrid()) {
							CShape@ shape = newblob.getShape();
							shape.SetStatic(true);
						}
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID(editor_copy)) {
		u16 player_id; if(!params.saferead_u16(player_id)) return;
	    CPlayer@ p = getPlayerByNetworkId(player_id);
		Vec2f aimpos; if(!params.saferead_Vec2f(aimpos)) return;
		
		CMap@ map = getMap();
		if (p !is null) {
			CBlob@ blob = p.getBlob();
			CControls@ controls = p.getControls();
			string player_name = p.getUsername();
			bool mode = rules.get_bool("EditorMode_"+player_name);
			if (blob !is null) {
				blob.set_TileType("buildtile", 0);
				CBlob@[] blobs;
				if(mode) {
					if (getMap().getBlobsInRadius(aimpos, 1.0f, blobs)) {
						CBlob@ blob_to_copy = blobs[XORRandom(blobs.length)];
						blob.set_string("blob_to_copy", blob_to_copy.getName());
						blob.set_u16("blob_to_copy_team", blob_to_copy.getTeamNum());
					}
				}
				else {
					blob.set_string("blob_to_copy", "");
					blob.set_TileType("buildtile", map.getTile(aimpos).type);
				}
			}
		}
	}
	else if (cmd == this.getCommandID(change_mode)) {
		CPlayer@ p = ResolvePlayer(params);
		if (p !is null) {
			string player_name = p.getUsername();
			rules.set_bool("EditorMode_"+player_name, !rules.get_bool("EditorMode_"+player_name));
			string the_line = p.getCharacterName() + "'s Editor Mode was changed to " + (rules.get_bool("EditorMode_"+player_name) ? "BLOBS" : "TILES");
			if (p.isMyPlayer())
				client_AddToChat(the_line, SColor(0xff474ac6));
		}
	}
}

bool canPlaceBlobAtPos( Vec2f pos )
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	
	  @_tempBlob = getMap().getBlobAtPosition( pos );
	if(_tempBlob !is null && _tempBlob.isCollidable()) {
		  @_tempShape = _tempBlob.getShape();
		if(_tempShape.isStatic())
		    return false;
	}
	return true;
}

CPlayer@ ResolvePlayer( CBitStream@ data )
{
    u16 playerNetID;
	if(!data.saferead_u16(playerNetID)) return null;
	
	return getPlayerByNetworkId(playerNetID);
}

Vec2f getBottomOfCursor(Vec2f cursorPos)
{
	cursorPos = getMap().getTileSpacePosition(cursorPos);
	cursorPos = getMap().getTileWorldPosition(cursorPos);
	f32 w = getMap().tilesize / 2.0f;
	f32 h = getMap().tilesize / 2.0f;
	int offsetY = Maths::Max(1, Maths::Round(8 / getMap().tilesize)) - 1;
	h -= offsetY * getMap().tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}