// Time-related functions from Pine Script
// v1.3

class PineScriptTime
{
private:
   static bool IsLeapYear(const int y)
   {
      return ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0);
   }

   static void UnixUtcToStruct(const long t, MqlDateTime &r)
   {
      const long spd = 86400;
      long sec = (long)t;
      long days = sec / spd;
      long rem = sec % spd;
      if (rem < 0)
      {
         rem += spd;
         days--;
      }
      r.hour = (int)(rem / 3600);
      rem %= 3600;
      r.min = (int)(rem / 60);
      r.sec = (int)(rem % 60);

      long dc = days;
      int y = 1970;
      while (true)
      {
         int diy = IsLeapYear(y) ? 366 : 365;
         if (dc < diy)
            break;
         dc -= diy;
         y++;
      }
      int doy = (int)dc;
      int mdays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
      if (IsLeapYear(y))
         mdays[1] = 29;
      int m = 1;
      while (doy >= mdays[m - 1])
      {
         doy -= mdays[m - 1];
         m++;
      }
      r.year = y;
      r.mon = m;
      r.day = doy + 1;
      r.day_of_week = (int)(((days + 4) % 7 + 7) % 7);
   }

   static int ExchangeTimezoneOffsetSeconds()
   {
      return (int)(TimeCurrent() - TimeGMT());
   }

   static int ParseTimezoneOffsetSeconds(string tz)
   {
      StringTrimLeft(tz);
      StringTrimRight(tz);
      if (StringLen(tz) == 0)
         return ExchangeTimezoneOffsetSeconds();

      string u = tz;
      StringToUpper(u);

      if (u == "UTC" || u == "GMT")
         return 0;
      if (u == "EXCHANGE")
         return ExchangeTimezoneOffsetSeconds();

      if (StringFind(u, "/", 0) >= 0)
         return ExchangeTimezoneOffsetSeconds();

      int sign = 1;
      int start = 0;
      if (StringFind(u, "GMT", 0) == 0)
         start = 3;
      else if (StringFind(u, "UTC", 0) == 0)
         start = 3;

      string rest = StringSubstr(u, start);
      StringTrimLeft(rest);
      if (StringLen(rest) == 0)
         return 0;

      if (StringGetCharacter(rest, 0) == '+')
         rest = StringSubstr(rest, 1);
      else if (StringGetCharacter(rest, 0) == '-')
      {
         sign = -1;
         rest = StringSubstr(rest, 1);
      }
      StringTrimLeft(rest);
      if (StringLen(rest) == 0)
         return 0;

      int colon = StringFind(rest, ":", 0);
      int hours = 0;
      int minutes = 0;
      if (colon >= 0)
      {
         hours = (int)StringToInteger(StringSubstr(rest, 0, colon));
         minutes = (int)StringToInteger(StringSubstr(rest, colon + 1));
      }
      else if (StringLen(rest) <= 2)
      {
         hours = (int)StringToInteger(rest);
      }
      else
      {
         hours = (int)StringToInteger(StringSubstr(rest, 0, StringLen(rest) - 2));
         minutes = (int)StringToInteger(StringSubstr(rest, StringLen(rest) - 2, 2));
      }
      return sign * (hours * 3600 + minutes * 60);
   }

   static void TimeToStructInTimezone(const datetime time, const string timezone, MqlDateTime &dt)
   {
      int off = ParseTimezoneOffsetSeconds(timezone);
      UnixUtcToStruct((long)time + off, dt);
   }

public:
   static int Now()
   {
      return TimeCurrent() * 1000;
   }
   static int ToMS(datetime time)
   {
      return time * 1000;
   }
   static int Year(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.year;
   }
   static int Year(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.year;
   }
   static int Month(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.mon;
   }
   static int Month(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.mon;
   }
   static int DayOfMonth(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.day;
   }
   static int DayOfMonth(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.day;
   }
   static int DayOfWeek(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.day_of_week;
   }
   static int DayOfWeek(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.day_of_week;
   }
   static int Hour(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.hour;
   }
   static int Hour(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.hour;
   }
   static int Minute(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.min;
   }
   static int Minute(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.min;
   }
   static int Second(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      return dt.sec;
   }
   static int Second(datetime time, string timezone)
   {
      MqlDateTime dt;
      TimeToStructInTimezone(time, timezone, dt);
      return dt.sec;
   }
   static int Sunday()
   {
      return 0;
   }
   static int Monday()
   {
      return 1;
   }
   static int Tuesday()
   {
      return 2;
   }
   static int Wednesday()
   {
      return 3;
   }
   static int Thursday()
   {
      return 4;
   }
   static int Friday()
   {
      return 5;
   }
   static int Saturday()
   {
      return 6;
   }
   static bool IsIntradayTradingTime(const MqlDateTime &current_time, int startTime, int endTime)
   {
      if (startTime == endTime)
      {
         return true;
      }
      int current_t = TimeToInt(current_time);
      if (startTime > endTime)
      {
         return current_t >= startTime || current_t <= endTime;
      }
      return current_t >= startTime && current_t <= endTime;
   }
   static int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }
   
   static int ParseTime(const string time, string &error)
   {
      string items[];
      StringSplit(time, ':', items);
      int hours;
      int minutes;
      int seconds;
      if (ArraySize(items) > 1)
      {
         if (ArraySize(items) != 3)
         {
            error = "Bad format for " + time;
            return -1;
         }
         //hh:mm:ss
         seconds = (int)StringToInteger(items[2]);
         minutes = (int)StringToInteger(items[1]);
         hours = (int)StringToInteger(items[0]);
      }
      else if (StringLen(time) == 6)
      {
         //hhmmss
         int time_parsed = (int)StringToInteger(time);
         seconds = time_parsed % 100;
         
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else if (StringLen(time) == 4)
      {
         //hhmm
         int time_parsed = (int)StringToInteger(time);
         seconds = 0;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else
      {
         error = "Unknown format: " + time;
         return -1;
      }
      if (hours > 24)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      if (hours == 24 && (minutes != 0 || seconds != 0))
      {
         error = "Incorrect date";
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};