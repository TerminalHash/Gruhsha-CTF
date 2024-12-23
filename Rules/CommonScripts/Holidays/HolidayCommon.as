// HolidayCommon.as;

const string holiday_prop = "holiday";
const string holiday_head_prop = "holiday head num";
const string holiday_head_texture_prop = "holiday head custom texture";

// QUICK FIX: Whitelist scripts as a quick sanitization check
string[] scriptlist = {
	"Birthday",
	"Halloween",
	"Christmas",
};

shared class Holiday
{
	string m_name;
	u16 m_date;
	u8 m_length;

	Holiday()
	{
		m_name = "";
		m_date = 0;
		m_length = 0;
	}

	Holiday(
	const string &in NAME,
	const u16 &in DATE,
	const u8 &in LENGTH)
	{
		m_name = NAME;
		m_date = DATE;
		m_length = LENGTH;
	}
};

string getActiveHolidayName()
{
	u16 server_year = Time_Year();
	s16 server_date = Time_YearDate();
	u8 server_leap = ((server_year % 4 == 0 && server_year % 100 != 0) || server_year % 400 == 0)? 1 : 0;

	Holiday[] calendar = {
		  Holiday(scriptlist[0], 116 + server_leap - 1, 3)
		, Holiday(scriptlist[1], 301 + server_leap - 1, 8)
		, Holiday(scriptlist[2], 352 + server_leap - 2, 36)
	};

	s16 holiday_start;
	s16 holiday_end;
	for(u8 i = 0; i < calendar.length; i++)
	{
		holiday_start = calendar[i].m_date;
		holiday_end = (holiday_start + calendar[i].m_length) % (365 + server_leap);

		bool holiday_active = false;

		if(holiday_start <= holiday_end)
		{
			holiday_active = server_date >= holiday_start && server_date < holiday_end;
		}
		else
		{
			holiday_active = server_date >= holiday_start || server_date < holiday_end;
		}

		if (holiday_active)
		{
			return calendar[i].m_name;
		}
	}

	return "";
}