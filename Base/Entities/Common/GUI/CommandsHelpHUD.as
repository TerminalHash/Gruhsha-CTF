bool mouseWasPressed1 = false;
bool mouseWasPressed2 = false;
bool mouseWasPressed3 = false;
bool mouseWasPressed4 = false;

void DrawCommandsHelp ()
{
    if (g_videorecording)
	return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

    CControls@ controls = p.getControls();

	Vec2f tl = Vec2f(12, 140);

	const Vec2f mousePos = controls.getMouseScreenPos();
	const bool hover = (mousePos.x > tl.x && mousePos.x < tl.x + 60 && mousePos.y > tl.y && mousePos.y < tl.y + 60);

	SColor colorcock = SColor(255, 255, 255, 255);

	if (hover)
	{
		GUI::DrawPane(tl, tl + Vec2f(60, 60), 0xffcfcfcf);
	}
	else
	{
		GUI::DrawPane(tl, tl + Vec2f(60, 60));
	}

	GUI::SetFont("hud");

	GUI::DrawIcon("InteractionIcons.png", 14, Vec2f(32, 32), (tl + Vec2f(-19, -19)), 1.5, p.getTeamNum());

    if (mousePos.x > tl.x && mousePos.x < tl.x + 60 && mousePos.y > tl.y && mousePos.y < tl.y + 60 && controls.mousePressed1)
    {
		if (!mouseWasPressed1)
		{
			Sound::Play("option");
			getRules().set_bool("show help", !getRules().get_bool("show help"));
			getRules().set_bool("show help page 1", !getRules().get_bool("show help page 1"));
			mouseWasPressed1 = true;
		}
    }
    else
    {
		mouseWasPressed1 = false;
    }

    if (getRules().get_bool("show help"))
	{

		SColor colorura = SColor(255, 255, 255, 255);
		SColor colorbubu = SColor(255, 255, 221, 156);

		Vec2f top_left_info_pane = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2, getScreenHeight() / 2) + Vec2f(-450, -220);

		// Page buttons with arrows
		//Vec2f left_page_button = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2.15, getScreenHeight() / 2) + Vec2f(-430, -120);
		//Vec2f right_page_button = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2.15, getScreenHeight() / 2) + Vec2f(530, -120);

		// Page buttons with numbers
		Vec2f first_page_button = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2.15, getScreenHeight() / 2) + Vec2f(-430, -220);
		bool hover_first_page_button = (mousePos.x > first_page_button.x && mousePos.x < first_page_button.x + 30 && mousePos.y > first_page_button.y && mousePos.y < first_page_button.y + 40);

		Vec2f second_page_button = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2.15, getScreenHeight() / 2) + Vec2f(-430, -170);
		bool hover_second_page_button = (mousePos.x > second_page_button.x && mousePos.x < second_page_button.x + 30 && mousePos.y > second_page_button.y && mousePos.y < second_page_button.y + 40);

		Vec2f third_page_button = Vec2f(0, 0) + Vec2f(getScreenWidth() / 2.15, getScreenHeight() / 2) + Vec2f(-430, -120);
		bool hover_third_page_button = (mousePos.x > third_page_button.x && mousePos.x < third_page_button.x + 30 && mousePos.y > third_page_button.y && mousePos.y < third_page_button.y + 40);


		// Text stuff
		Vec2f title = top_left_info_pane + Vec2f(450, 24);
		Vec2f footer = top_left_info_pane + Vec2f(450, 355);
		Vec2f topleft_text = top_left_info_pane + Vec2f(12, 24);
		Vec2f dim = Vec2f_zero;

		/*GUI::DrawPane(left_page_button, left_page_button + Vec2f(30, 40), SColor(255, 150, 150, 150));
		GUI::DrawIcon("arrow_left.png", 0, Vec2f(10, 23), left_page_button + Vec2f(10, 8), 0.5f, 0);

		GUI::DrawPane(right_page_button, right_page_button + Vec2f(30, 40), SColor(255, 150, 150, 150));
		GUI::DrawIcon("arrow_right.png", 0, Vec2f(10, 23), right_page_button + Vec2f(10, 8), 0.5f, 0);

		if (mousePos.x > left_page_button.x && mousePos.x < left_page_button.x + 30 && mousePos.y > left_page_button.y && mousePos.y < left_page_button.y +60 && controls.mousePressed1)
		{
			if (!mouseWasPressed1)
			{
				//Sound::Play("option");
				getRules().set_bool("show help page 2", false);
				getRules().set_bool("show help page 1", true);
				mouseWasPressed1 = true;
			}
			else
			{
				mouseWasPressed1 = false;
			}
		}

		if (mousePos.x > right_page_button.x && mousePos.x < right_page_button.x + 30 && mousePos.y > right_page_button.y && mousePos.y < right_page_button.y +60 && controls.mousePressed1)
		{
			if (!mouseWasPressed1)
			{
				//Sound::Play("option");
				getRules().set_bool("show help page 1", false);
				getRules().set_bool("show help page 2", true);
				mouseWasPressed1 = true;
			}
			else
			{
				mouseWasPressed1 = false;
			}
		}*/

		////////////////////////////////////////////////////
		/////////           First Page            /////////
		if (hover_first_page_button)
		{
			GUI::DrawPane(first_page_button, first_page_button + Vec2f(30, 40), 0xffcfcfcf);
		}
		else
		{
			GUI::DrawPane(first_page_button, first_page_button + Vec2f(30, 40), SColor(255, 150, 150, 150));
		}

		GUI::DrawText("1", first_page_button + Vec2f(8, 10), colorura);

		if (mousePos.x > first_page_button.x && mousePos.x < first_page_button.x + 30 && mousePos.y > first_page_button.y && mousePos.y < first_page_button.y +60 && controls.mousePressed1)
		{
			if (!mouseWasPressed2)
			{
				Sound::Play("buttonclick");
				getRules().set_bool("show help page 1", true);
				getRules().set_bool("show help page 2", false);
				getRules().set_bool("show help page 3", false);
				mouseWasPressed2 = true;
			}
		}
		else
		{
			mouseWasPressed2 = false;
		}
		////////////////////////////////////////////////////
		////////////////////////////////////////////////////

		////////////////////////////////////////////////////
		/////////           Second Page           /////////
		if (hover_second_page_button)
		{
			GUI::DrawPane(second_page_button, second_page_button + Vec2f(30, 40), 0xffcfcfcf);
		}
		else
		{
			GUI::DrawPane(second_page_button, second_page_button + Vec2f(30, 40), SColor(255, 150, 150, 150));
		}

		GUI::DrawText("2", second_page_button + Vec2f(8, 10), colorura);

		if (mousePos.x > second_page_button.x && mousePos.x < second_page_button.x + 30 && mousePos.y > second_page_button.y && mousePos.y < second_page_button.y +60 && controls.mousePressed1)
		{
			if (!mouseWasPressed3)
			{
				Sound::Play("buttonclick");
				getRules().set_bool("show help page 1", false);
				getRules().set_bool("show help page 2", true);
				getRules().set_bool("show help page 3", false);
				mouseWasPressed3 = true;
			}
		}
		else
		{
			mouseWasPressed3 = false;
		}
		////////////////////////////////////////////////////
		////////////////////////////////////////////////////

		////////////////////////////////////////////////////
		/////////           Third Page            /////////
		if (hover_third_page_button)
		{
			GUI::DrawPane(third_page_button, third_page_button + Vec2f(30, 40), 0xffcfcfcf);
		}
		else
		{
			GUI::DrawPane(third_page_button, third_page_button + Vec2f(30, 40), SColor(255, 150, 150, 150));
		}
		GUI::DrawText("3", third_page_button + Vec2f(8, 10), colorura);

		if (mousePos.x > third_page_button.x && mousePos.x < third_page_button.x + 30 && mousePos.y > third_page_button.y && mousePos.y < third_page_button.y +60 && controls.mousePressed1)
		{
			if (!mouseWasPressed4)
			{
				Sound::Play("buttonclick");
				getRules().set_bool("show help page 1", false);
				getRules().set_bool("show help page 2", false);
				getRules().set_bool("show help page 3", true);
				mouseWasPressed4 = true;
			}
		}
		else
		{
			mouseWasPressed4 = false;
		}
		////////////////////////////////////////////////////
		////////////////////////////////////////////////////


		if (getRules().get_bool("show help page 2"))
		{
			GUI::DrawPane(top_left_info_pane, top_left_info_pane + Vec2f(900, 380), SColor(255, 150, 150, 150)); // "\n"
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
			string line_nine = "/bindings - открыть меню настроек мода (оставлена как альтернатива кнопке)";
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
		else if (getRules().get_bool("show help page 1"))
		{
			GUI::DrawPane(top_left_info_pane, top_left_info_pane + Vec2f(900, 380), SColor(255, 150, 150, 150)); // "\n"
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane, 1.0f, 0);
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane + Vec2f(870, 0), 1.0f, 0);

			GUI::SetFont("menu");

			// Title
			string line_main = "Gruhsha CTF: RU Captains Modification";
			GUI::DrawTextCentered(line_main, title, colorura);
			GUI::GetTextDimensions(line_main, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			GUI::DrawLine2D(Vec2f(topleft_text.x, topleft_text.y), Vec2f(topleft_text.x + 874, topleft_text.y), colorura);
			topleft_text += Vec2f(0, 5);

            // Category
			string line_one = "Gruhsha CTF или же Груша - это русскоязычный вариант Captains-модов.";
			GUI::DrawText(line_one, topleft_text, colorura);
			GUI::GetTextDimensions(line_one, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_two = "Здесь сохранены правила ванильного CTF-режима в максимально-исходном виде и проведён аккуратный ребаланс.";
			GUI::DrawText(line_two, topleft_text, colorura);
			GUI::GetTextDimensions(line_two, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_three = "Вам по-прежнему требуется захватить флаги противника для победы в матче, но теперь за команды отвечают Капитаны.";
			GUI::DrawText(line_three, topleft_text, colorura);
			GUI::GetTextDimensions(line_three, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_empty1 = " ";
			GUI::DrawText(line_empty1, topleft_text, colorura);
			GUI::GetTextDimensions(line_empty1, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_four = "Краткий экскурс в основные изменения мода:";
			GUI::DrawText(line_four, topleft_text, colorura);
			GUI::GetTextDimensions(line_four, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_five = "- Классы строителя и лучника имеют лимиты по количеству человек, одновременно играющих на них;";
			GUI::DrawText(line_five, topleft_text, colorura);
			GUI::GetTextDimensions(line_five, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_six = "- Рыцарям разрешено использовать дрели в конкретных зонах (база команды и внутри границы красной зоны);";
			GUI::DrawText(line_six, topleft_text, colorura);
			GUI::GetTextDimensions(line_six, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_seven = "- Изменена физика батутов: они толкают вас вперёд с силой, определяемой высотой прыжка или скоростью;";
			GUI::DrawText(line_seven, topleft_text, colorura);
			GUI::GetTextDimensions(line_seven, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_eight = "- Каждый игрок имеет свой собственный пул материалов, камень и дерево отныне виртуальныe;";
			GUI::DrawText(line_eight, topleft_text, colorura);
			GUI::GetTextDimensions(line_eight, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_kek = "- Аккуратно сбалансированы свойства некоторых предметов и цены на них;";
			GUI::DrawText(line_kek, topleft_text, colorura);
			GUI::GetTextDimensions(line_kek, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			/*string line_nine = "- Введён динамический респаун игроков (зависит от количества игроков в командах);";
			GUI::DrawText(line_nine, topleft_text, colorura);
			GUI::GetTextDimensions(line_nine, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_ten = "- Введены динамические на некоторые предметы (так же зависят от количества игроков в командах);";
			GUI::DrawText(line_ten, topleft_text, colorura);
			GUI::GetTextDimensions(line_ten, dim);
			topleft_text += Vec2f(0, dim.y + 2);*/

			string line_el = "- Добавлены собственные настройки мода (меню вызывается через кнопку над таблицами игроков);";
			GUI::DrawText(line_el, topleft_text, colorura);
			GUI::GetTextDimensions(line_el, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			/*string line_tw = "- Изменены требования (добавлено что-то или изменено имеющееся) к некоторым предметам;";
			GUI::DrawText(line_tw, topleft_text, colorura);
			GUI::GetTextDimensions(line_tw, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_th = "- Добавлены ограничения на кол-во переносимых дрелей и еды;";
			GUI::DrawText(line_th, topleft_text, colorura);
			GUI::GetTextDimensions(line_th, dim);
			topleft_text += Vec2f(0, dim.y + 2);*/

			/*string line_fr = "- Добавлены различные кастомные штуки по типу войслайнов, эмоций и голов;";
			GUI::DrawText(line_fr, topleft_text, colorura);
			GUI::GetTextDimensions(line_fr, dim);
			topleft_text += Vec2f(0, dim.y + 2);*/

			string line_fif = "- Пофикшены некоторые мозговыносящие баги ванильной игры;";
			GUI::DrawText(line_fif, topleft_text, colorura);
			GUI::GetTextDimensions(line_fif, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_sixt = "- И многое-многое другое.";
			GUI::DrawText(line_sixt, topleft_text, colorura);
			GUI::GetTextDimensions(line_sixt, dim);
			topleft_text += Vec2f(0, dim.y + 2);

            // Footer
			string line_footer = "Нажмите на любую кнопку слева от панели, чтобы перейти к другой странице.";
			GUI::DrawTextCentered(line_footer, footer /*+ Vec2f(0, 40)*/, colorura);
			GUI::GetTextDimensions(line_footer, dim);
		}
		else if (getRules().get_bool("show help page 3"))
		{
			GUI::DrawPane(top_left_info_pane, top_left_info_pane + Vec2f(900, 380), SColor(255, 150, 150, 150)); // "\n"
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane, 1.0f, 0);
            GUI::DrawIcon("pear_big.png", 0, Vec2f(16, 16), top_left_info_pane + Vec2f(870, 0), 1.0f, 0);

			// Title
			string line_main = "Авторы модификации";
			GUI::DrawTextCentered(line_main, title, colorura);
			GUI::GetTextDimensions(line_main, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			GUI::DrawLine2D(Vec2f(topleft_text.x, topleft_text.y), Vec2f(topleft_text.x + 874, topleft_text.y), colorura);
			topleft_text += Vec2f(0, 5);

            // Category
			string line_one = "Skemonde - создатель Груши";
			GUI::DrawText(line_one, topleft_text, colorura);
			GUI::GetTextDimensions(line_one, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_two = "TerminalHash - основной майнтайнер мода";
			GUI::DrawText(line_two, topleft_text, colorura);
			GUI::GetTextDimensions(line_two, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_empty1 = " ";
			GUI::DrawText(line_empty1, topleft_text, colorura);
			GUI::GetTextDimensions(line_empty1, dim);
			topleft_text += Vec2f(0, dim.y + 2);


			string line_third = "Програмисты:";
			GUI::DrawText(line_third, topleft_text, colorura);
			GUI::GetTextDimensions(line_third, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_four = "TerminalHash, Skemonde, kussakaa, egor0928931, Vagrament aka FeenRant";
			GUI::DrawText(line_four, topleft_text, colorura);
			GUI::GetTextDimensions(line_four, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_empty2 = " ";
			GUI::DrawText(line_empty2, topleft_text, colorura);
			GUI::GetTextDimensions(line_empty2, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_five = "Художники:";
			GUI::DrawText(line_five, topleft_text, colorura);
			GUI::GetTextDimensions(line_five, dim);
			topleft_text += Vec2f(0, dim.y + 2);

			string line_six = "TerminalHash, Skemonde, kussakaa";
			GUI::DrawText(line_six, topleft_text, colorura);
			GUI::GetTextDimensions(line_six, dim);
			topleft_text += Vec2f(0, dim.y + 2);
		}
	}
}