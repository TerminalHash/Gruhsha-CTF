void DrawCommandsHelp ()
{
    if (g_videorecording)
	return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

    CControls@ c = p.getControls();

	Vec2f tl = Vec2f(8, 920);
	SColor colorcock = SColor(255, 255, 255, 255);
	GUI::DrawPane(tl, tl + Vec2f(60, 60));

	GUI::SetFont("hud");

	GUI::DrawIcon("InteractionIcons.png", 14, Vec2f(32, 32), (tl + Vec2f(-19, -19)), 1.5, p.getTeamNum());

    if (c.getMouseScreenPos().x > tl.x && c.getMouseScreenPos().x < tl.x + 60 && c.getMouseScreenPos().y > tl.y && c.getMouseScreenPos().y < tl.y + 60)
		{
			SColor colorura = SColor(255, 255, 255, 255);
			SColor colorbubu = SColor(255, 255, 221, 156);

			Vec2f top_left_info_pane = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2, getScreenHeight() / 2) + Vec2f(-450, -120);

			Vec2f title = top_left_info_pane + Vec2f(450, 24);

            Vec2f footer = top_left_info_pane + Vec2f(450, 315);

			Vec2f topleft_text = top_left_info_pane + Vec2f(12, 24);

            Vec2f dim = Vec2f_zero;

			GUI::DrawPane(top_left_info_pane, top_left_info_pane + Vec2f(900, 340), SColor(255, 150, 150, 150)); // "\n"
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane, 1.0f, 0);
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane + Vec2f(870, 0), 1.0f, 0);

			GUI::SetFont("menu");

			// Title
			string line_main = "Список команд мода:";
			GUI::DrawTextCentered(line_main, title, colorura);
			GUI::GetTextDimensions(line_main, dim);
			topleft_text += Vec2f(0, dim.y + 2);

            if (p.isMod())
            {
            // Category
			string line_captain = "Капитанская система:";
			GUI::DrawText(line_captain, topleft_text, colorura);
			GUI::GetTextDimensions(line_captain, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			GUI::DrawLine2D(Vec2f(topleft_text.x, topleft_text.y), Vec2f(topleft_text.x + 874, topleft_text.y), colorura);
			topleft_text += Vec2f(0, 5);

			// line 1
			string line_one = "/specall - сделать всех игроков наблюдателями";
			GUI::DrawText(line_one, topleft_text, colorura);
			GUI::GetTextDimensions(line_one, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 2
			string line_two = "/appoint - повысить двух игроков до Капитанов";
			GUI::DrawText(line_two, topleft_text, colorura);
			GUI::GetTextDimensions(line_two, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 3
			string line_third = "/demote - понизить Капитанов до обычных игроков";
			GUI::DrawText(line_third, topleft_text, colorura);
			GUI::GetTextDimensions(line_third, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 4
			string line_four = "/pick - берёт указанного игрока из наблюдателей в твою команду и передаёт право выбора другому Капитану";
			GUI::DrawText(line_four, topleft_text, colorura);
			GUI::GetTextDimensions(line_four, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 5
			string line_five = "/lock - запрещает набирать людей в команды, запоминая состав и останавливая процесс набора игроков";
			GUI::DrawText(line_five, topleft_text, colorura);
			GUI::GetTextDimensions(line_five, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 6
			string line_six = "/blim - устанавливает лимит на строителей в командах";
			GUI::DrawText(line_six, topleft_text, colorura);
			GUI::GetTextDimensions(line_six, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 7
			string line_seven = "/alim - устанавливает лимит на лучников в командах";
			GUI::DrawText(line_seven, topleft_text, colorura);
			GUI::GetTextDimensions(line_seven, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 8
			string line_eight = "/togglechclass - переключить смену классов в магазинах";
			GUI::DrawText(line_eight, topleft_text, colorura);
			GUI::GetTextDimensions(line_eight, dim);
			topleft_text += Vec2f(0, dim.y + 12);
            }

            // Category
			string line_player = "Личные:";
			GUI::DrawText(line_player, topleft_text, colorura);
			GUI::GetTextDimensions(line_player, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			GUI::DrawLine2D(Vec2f(topleft_text.x, topleft_text.y), Vec2f(topleft_text.x + 874, topleft_text.y), colorura);
			topleft_text += Vec2f(0, 5);

			// line 9
			string line_nine = "/bindings - открыть меню настроек мода";
			GUI::DrawText(line_nine, topleft_text, colorura);
			GUI::GetTextDimensions(line_nine, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 10
			string line_ten = "/realstone - сконвертировать 50 единиц виртуального камня в реальный";
			GUI::DrawText(line_ten, topleft_text, colorura);
			GUI::GetTextDimensions(line_ten, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			// line 11
			string line_el = "/togglesounds - переключить воспроизведение звуков войслайнов для себя";
			GUI::DrawText(line_el, topleft_text, colorura);
			GUI::GetTextDimensions(line_el, dim);
			topleft_text += Vec2f(0, dim.y + 2);

            // Footer
			string line_footer = "Колесо меток, колесо модовых эмоций, бинды и настройки игрока находятся в меню настроек мода!";
			GUI::DrawTextCentered(line_footer, footer, colorura);
			GUI::GetTextDimensions(line_footer, dim);
	}
}