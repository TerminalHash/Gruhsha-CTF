// GetFont.as

string get_font(string chosen_font, s32 size)
{
    string result = chosen_font + "_"+size;
    if (!GUI::isFontLoaded(result))
    {
        string font_name = CFileMatcher(chosen_font + ".ttf").getFirst();
        GUI::LoadFont(result, font_name, size, true);
    }
    return result;
}
