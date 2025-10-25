// CustomTagWheels.as

// Custom tag wheels for some players
bool tagWheels(string username)
{
    CControls@ controls = getControls();

    if (username == "egor0928931")
    {
        TagMenu@ menu = TagMenu(controls.getMouseScreenPos());

        TagMenuEntry@ entry4 = TagMenuEntry("4", controls.getMouseScreenPos());
        entry4.visible_name = "DANGER";
        entry4.t_color = SColor( 255, 235,  0,  0);
        menu.add_entry(entry4);

        TagMenuEntry@ entry = TagMenuEntry("1", controls.getMouseScreenPos());
        entry.visible_name = "GO HERE";
        entry.t_color = SColor( 255, 122,  255,  104);
        menu.add_entry(entry);

        TagMenuEntry@ entry2 = TagMenuEntry("2", controls.getMouseScreenPos());
        entry2.visible_name = "DIG HERE";
        entry2.t_color = SColor( 255, 169,  113,  80);
        menu.add_entry(entry2);

        TagMenuEntry@ entry7 = TagMenuEntry("7", controls.getMouseScreenPos());
        entry7.visible_name = "KEG";
        entry7.t_color = SColor( 255, 255,  126,  126);
        menu.add_entry(entry7);

        TagMenuEntry@ entry5 = TagMenuEntry("5", controls.getMouseScreenPos());
        entry5.visible_name = "RETREAT";
        entry5.t_color = SColor( 255, 232,  124,  0);
        menu.add_entry(entry5);

        TagMenuEntry@ entry6 = TagMenuEntry("6", controls.getMouseScreenPos());
        entry6.visible_name = "HELP";
        entry6.t_color = SColor( 255, 169,  235,  255);
        menu.add_entry(entry6);

        TagMenuEntry@ entry3 = TagMenuEntry("3", controls.getMouseScreenPos());
        entry3.visible_name = "ATTACK";
        entry3.t_color = SColor( 255, 238,  200,  0);
        menu.add_entry(entry3);

        TagMenuEntry@ entry8 = TagMenuEntry("8", controls.getMouseScreenPos());
        entry8.visible_name = "WiT SENCE";
        entry8.t_color = SColor( 255,  255, 255, 255);
        menu.add_entry(entry8);

        tmenu = menu;

        return true;
    }

    return false;
}
