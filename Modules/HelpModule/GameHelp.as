// GameHelp.as
/* 
	Help system from GingerBeard's mods.
	Picked from KIWI and modified.
*/
#define CLIENT_ONLY

#include "TranslationsSystem.as"

bool mousePress = false;
u8 page = 0;

const u8 pages = 8;

void onInit(CRules@ this) {
	this.set_bool("show_gamehelp", true);
	CFileImage@ image = CFileImage("HelpBackground.png");
	const Vec2f imageSize = Vec2f(image.getWidth(), image.getHeight());
	AddIconToken("$HELP$", "HelpBackground.png", imageSize, 0);
	AddIconToken("$arrow_right$", "InteractionIcons.png", Vec2f(32, 32), 17);
	AddIconToken("$arrow_left$", "InteractionIcons.png", Vec2f(32, 32), 18);
}

void onTick(CRules@ this) {
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;
	
	CControls@ controls = getControls();

	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MENU))) {
		this.set_bool("show_gamehelp", !this.get_bool("show_gamehelp"));
	}
	if (this.get_bool("show_gamehelp") && controls.isKeyJustPressed(KEY_ESCAPE)) {
		this.set_bool("show_gamehelp", false);
	}
}

void onRender(CRules@ this) {
	if (!this.get_bool("show_gamehelp")) return;
	
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;
	
	Vec2f center = getDriver().getScreenCenterPos();
	
	//background
	Vec2f imageSize;
	GUI::GetIconDimensions("$HELP$", imageSize);
	GUI::DrawIconByName("$HELP$", Vec2f(center.x - imageSize.x, center.y - imageSize.y));
	
	//pages
	managePages(imageSize, center);
	
	//clickable buttons
	CControls@ controls = getControls();
	const Vec2f mousePos = controls.getMouseScreenPos();

	makeExitButton(this, Vec2f(center.x + imageSize.x - 20, center.y - imageSize.y + 20), controls, mousePos);
	makePageChangeButton(Vec2f(center.x + 22, center.y + imageSize.y + 30), controls, mousePos, true);
	makePageChangeButton(Vec2f(center.x - 22, center.y + imageSize.y + 30), controls, mousePos, false);

	//page num
	drawTextWithFont((page + 1) + "/" + pages, center + imageSize - Vec2f(30, 25), "menu");
	
	mousePress = controls.mousePressed1; 
}

void managePages(Vec2f&in imageSize, Vec2f&in center) {
	switch(page) {
		case 0: drawPage(imageSize, center, Descriptions::header1, Vec2f(center.x - imageSize.x + 150, center.y - imageSize.y/14));
			break;
		case 1: drawPage(imageSize, center, Descriptions::header2, Vec2f(center.x - imageSize.x + 50, center.y - imageSize.y/8));
			break;
		case 2: drawPage(imageSize, center, Descriptions::header3, Vec2f(center.x - imageSize.x + 200, center.y - imageSize.y/8));
			break;
		case 3: drawPage(imageSize, center, Descriptions::header4, Vec2f(center.x - imageSize.x/2, center.y - imageSize.y/8));
			break;
		case 4: drawPage(imageSize, center, Descriptions::header5, Vec2f(center.x - imageSize.x + 80, center.y - imageSize.y + 180));
			break;
		case 5: drawPage(imageSize, center, Descriptions::header6, Vec2f(center.x - imageSize.x + 170, center.y - imageSize.y/4));
			break;
		case 6: drawPage(imageSize, center, Descriptions::header7, Vec2f(center.x - imageSize.x + 80, center.y - imageSize.y/5));
			break;
		case 7: drawPage(imageSize, center, Descriptions::header8, Vec2f(center.x - imageSize.x + 150, center.y - imageSize.y/6));
			break;
	};
}

void drawPage(Vec2f&in imageSize, Vec2f&in center, const string&in header, Vec2f&in imagePos) {
	GUI::DrawIcon("Page" + (page + 1) + ".png", imagePos, 0.5f);
	drawTextWithFont(header, center - Vec2f(0, imageSize.y - 50), "Balkara_Condensed");
	drawTextWithFont(page_tips[page], center - Vec2f(0, imageSize.y - 140), "menu");
}

const string[] page_tips = {
	Descriptions::tiptext1,
	Descriptions::tiptext2,
	Descriptions::tiptext3,
	Descriptions::tiptext4,
	Descriptions::tiptext5,
	Descriptions::tiptext6,
	Descriptions::tiptext7,
	Descriptions::tiptext8
};

void drawTextWithFont(const string&in text, const Vec2f&in pos, const string&in font) {
	GUI::SetFont(font);
	GUI::DrawTextCentered(text, pos, color_black);
}

void makeExitButton(CRules@ this, Vec2f&in pos, CControls@ controls, Vec2f&in mousePos) {
	Vec2f tl = pos + Vec2f(-20, -20);
	Vec2f br = pos + Vec2f(20, 20);
	
	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		GUI::DrawButton(tl, br);
		
		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			this.set_bool("show_gamehelp", false);
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}
	GUI::DrawIcon("MenuItems", 29, Vec2f(32,32), Vec2f(pos.x-32, pos.y-32), 1.0f);
}

void makePageChangeButton(Vec2f&in pos, CControls@ controls, Vec2f&in mousePos, const bool&in right) {
	Vec2f tl = pos + Vec2f(-20, -20);
	Vec2f br = pos + Vec2f(20, 20);
	
	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);

	if (hover) {
		GUI::DrawButton(tl, br);
		
		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			if (right)
				page = page == pages - 1 ? 0 : page + 1;
			else
				page = page == 0 ? pages - 1 : page - 1;
		}
	} else {
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}

	GUI::DrawIconByName(right ? "$arrow_right$" : "$arrow_left$", Vec2f(pos.x - 32, pos.y - 32), 1.0f);
}
