// TagCommon.as
// Различные штуки для системы меток.

namespace TagMenu
{
    const SColor active_color(0xFFFFFFFF);
    const SColor inactive_color(0xFFAAAAAA);

    const SColor background_color(40, 0, 0, 0);

    const SColor fadeout_inner_color(30, 255, 255, 255);
    const SColor fadeout_outer_color(0, 255, 255, 255);

    const SColor pane_title_color(0xFFCCCCCC);
    const SColor pane_text_color(0xFFFFFFFF);

    const float hover_distance = 0.07f;
    const float auto_selection_distance = 0.3f;

    const Vec2f center_pane_padding(16.0f, 32);
    const Vec2f center_pane_text_margin(0.0f, 12.0f);
    const float center_pane_min_width = 128.0f;
}

class TagMenuEntry
{
    // Identifier for section
    string name;
    float section_distance = 0.4f;
    u32 id;
    Vec2f origin;

    TagMenuEntry(const string&in t_name, Vec2f pos)
    {
        name = t_name;
        origin = pos;
    }

    // Visual parameters
    string visible_name;
    SColor t_color;

    // Other state
    float angle_min, angle_max;
    Vec2f position;
    bool hovered;


    SColor get_color()
    {
        return t_color;
        return hovered ? TagMenu::active_color : TagMenu::inactive_color;
    }

    void update(float angle, float step)
    {
        angle_min = angle;
        angle_max = angle + step;

        float screen_size_y = getDriver().getScreenHeight();
        f32 resolution_scale = (screen_size_y / 720.f);

        float angle_mid = (angle_min + angle_max) / 2.0f;
        float distance = 75 * resolution_scale;

        position = origin - Vec2f(Maths::Cos(angle_mid), Maths::Sin(angle_mid)) * distance;
    }

    void render()
    {
        CCamera@ camera = getCamera();

        if (camera is null) return;

        float screen_size_y = getDriver().getScreenHeight();

        float resolution_scale = (screen_size_y / 720.f);

        GUI::SetFont("AveriaSerif-tagwheel");
        GUI::DrawTextCentered(visible_name, position, get_color());
    }
}

class TagMenu
{
    TagMenuEntry@[] entries;
    TagMenuEntry@ hovered;
    string text;
    Vec2f origin;
    Vec2f world_origin;

    TagMenu(Vec2f pos)
    {
        origin = pos;
        world_origin = getDriver().getWorldPosFromScreenPos(pos);
        text = "d";
    }

    float angle_step()
    {
        return !entries.isEmpty() ? Maths::Pi * 2.0f / float(entries.length) : 0.0f;
    }

    TagMenuEntry@ get_entry_from_position(const Vec2f&in cursor)
    {
        if (entries.isEmpty()) return null;

        Vec2f offset = origin - cursor;
        float angle = Maths::ATan2(offset.y, offset.x) + angle_step() / 2.0f;

        if (angle < 0.0f)
        {
            angle += 2.0f * Maths::Pi;
        }

        uint entry_id = (angle / (Maths::Pi * 2.0f)) * entries.length;

        if (entry_id >= 0 && entry_id < entries.length)
        {
            return @entries[entry_id];
        }

        return null;
    }

    bool is_cursor_in_range(const Vec2f&in cursor, float min_distance)
    {
        Vec2f offset = origin - cursor;
        return offset.getLength() >= 48.0f && offset.getLength() <= 2048.0f;
    }

    void it_hovered()
    {
        TagMenuEntry@ previously_hovered = @hovered;

        @hovered = null;

        Vec2f cursor = getControls().getMouseScreenPos();

        // ignore cursor at center of the screen
        if (is_cursor_in_range(cursor, TagMenu::hover_distance))
        {
            @hovered = get_entry_from_position(cursor);

            if (previously_hovered !is hovered)
            {
                Sound::Play("select.ogg");
            }
        }
    }

    void update()
    {
        const float step = angle_step();

        // Modify the angle by half a step so the first item is properly aligned
        float angle = -step / 2.0f;

        for (uint i = 0; i < entries.length; ++i)
        {
            entries[i].update(angle, step);
            angle += step;
        }

        it_hovered();
    }

    // Displays a gradient effect over the currently hovered item.
    void draw_hover_effect()
    {
        Driver@ driver = getDriver();
        float ray_distance = driver.getScreenDimensions().getLength() / 2.0f;

        if (hovered !is null)
        {
            Vertex[] vertices;

            // Center vertex
            vertices.push_back(Vertex(
                driver.getWorldPosFromScreenPos(origin),
                0.0f,
                Vec2f(0.0f, 0.0f),
                TagMenu::fadeout_inner_color
            ));

            // Small angle vertex
            Vec2f min_direction(Maths::Cos(hovered.angle_min), Maths::Sin(hovered.angle_min));
            vertices.push_back(Vertex(
                driver.getWorldPosFromScreenPos(origin - min_direction * ray_distance),
                0.0f,
                Vec2f(1.0f, 0.0f),
                TagMenu::fadeout_outer_color
            ));

            // Large angle vertex
            Vec2f max_direction(Maths::Cos(hovered.angle_max), Maths::Sin(hovered.angle_max));
            vertices.push_back(Vertex(
                driver.getWorldPosFromScreenPos(origin - max_direction * ray_distance),
                0.0f,
                Vec2f(0.0f, 1.0f),
                TagMenu::fadeout_outer_color
            ));

            Render::RawTriangles("pixel", vertices);
        }
    }

    // Returns the given pane_size vector widened if necessary to fit in the text
    Vec2f extend_pane(const Vec2f&in pane_size, string text)
    {
        Vec2f text_size;
        GUI::GetTextDimensions(text, text_size);
        return Vec2f(Maths::Max(pane_size.x, text_size.x + TagMenu::center_pane_padding.x * 2.0f), pane_size.y);
    }

    // Draws the center pane, which shows a simple title and the currently selected item name
    void draw_center_pane()
    {
        string hover_text = (hovered !is null ? hovered.visible_name : getTranslatedString("(no selection)"));

        Vec2f pane_size(TagMenu::center_pane_min_width, TagMenu::center_pane_padding.y * 2.0f);
        pane_size = extend_pane(pane_size, hover_text);
        pane_size = extend_pane(pane_size, text);

        u8 frame = 0;

        float screen_size_y = getDriver().getScreenHeight();
        f32 resolution_scale = (screen_size_y / 720.f);

        /*GUI::DrawIcon("TagWheel.png", frame, Vec2f(256, 256), origin - Vec2f(128 * resolution_scale, 128 * resolution_scale), 0.5 * resolution_scale, SColor(50, 255, 255, 255));*/
    }

    // Render the wheel menu, including its items.
    // This has to be called from a render script, otherwise the hover effect will not work.
    void render()
    {
        //GUI::DrawRectangle(Vec2f_zero, getDriver().getScreenDimensions(), TagMenu::background_color);

        draw_hover_effect();
        draw_center_pane();

        for (int i = 0; i < entries.length; ++i)
        {
            entries[i].hovered = (entries[i] is hovered);
            entries[i].render();
        }
    }

    // Checking the user input.
    // Note that TagMenu itself doesn't care about managing your select events.
    // 'auto_selection' determines the user input for when you want to do autoselect,
    // i.e. when hovering an option selects it automatically.
    TagMenuEntry@ get_selected(bool auto_selection = false)
    {
        TagMenuEntry@ entry = null;

        if (auto_selection)
        {
            if (is_cursor_in_range(getControls().getMouseScreenPos(), TagMenu::auto_selection_distance))
            {
                @entry = @hovered;
            }
        }
        else
        {
            @entry = @hovered;
        }

        if (entry !is null)
        {
            Sound::Play("buttonclick.ogg");
        }

        return @entry;
    }

    void add_entry(TagMenuEntry@ entry)
    {
        entries.push_back(@entry);
    }

    void remove_entry(TagMenuEntry@ entry)
    {
        int offset = entries.find(@entry);

        if (offset != -1)
        {
            entries.erase(offset);
        }
    }
}
