datetime AddPeriods(datetime dt, ENUM_TIMEFRAMES tf, int count)
{
   if (tf == PERIOD_CURRENT)
      return AddPeriods(dt, (ENUM_TIMEFRAMES)_Period, count);
   switch (tf)
   {
      case PERIOD_M1:
         return dt + 60 * count;
      case PERIOD_M2:
         return dt + 120 * count;
      case PERIOD_M3:
         return dt + 180 * count;
      case PERIOD_M4:
         return dt + 240 * count;
      case PERIOD_M5:
         return dt + 300 * count;
      case PERIOD_M6:
         return dt + 360 * count;
      case PERIOD_M10:
         return dt + 600 * count;
      case PERIOD_M12:
         return dt + 720 * count;
      case PERIOD_M15:
         return dt + 900 * count;
      case PERIOD_M20:
         return dt + 1200 * count;
      case PERIOD_M30:
         return dt + 1800 * count;
      case PERIOD_H1:
         return dt + 3600 * count;
      case PERIOD_H2:
         return dt + 7200 * count;
      case PERIOD_H3:
         return dt + 10800 * count;
      case PERIOD_H4:
         return dt + 14400 * count;
      case PERIOD_H6:
         return dt + 21600 * count;
      case PERIOD_H8:
         return dt + 28800 * count;
      case PERIOD_H12:
         return dt + 43200 * count;
      case PERIOD_D1:
         return dt + 86400 * count;
      case PERIOD_W1:
         return dt + 86400 * 7 * count;
      case PERIOD_MN1:
         {
            MqlDateTime date;
            if (!TimeToStruct(dt, date))
               return dt;
            int newMonths = date.mon + count;
            int addYears = (int)MathFloor((newMonths - 1) / 12);
            date.year += addYears;
            date.mon = newMonths - addYears * 12;
            return StructToTime(date);
         }
   }
   return dt;
}