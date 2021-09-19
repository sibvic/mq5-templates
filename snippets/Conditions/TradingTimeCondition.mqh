#include <Conditions/AConditionBase.mqh>
#include <Conditions/NoCondition.mqh>
#include <enums/DayOfWeek.mqh>

// Trading time condition v1.2

#ifndef TradingTimeCondition_IMP
#define TradingTimeCondition_IMP


int ParseTime(const string time, string &error)
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
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
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

ICondition* CreateTradingTimeCondition(const string startTime, const string endTime, bool useWeekly,
   const DayOfWeek startDay, const string weekStartTime, const DayOfWeek stopDay, 
   const string weekEndTime, string &error)
{
   int _startTime = ParseTime(startTime, error);
   if (_startTime == -1)
      return NULL;
   int _endTime = ParseTime(endTime, error);
   if (_endTime == -1)
      return NULL;
   if (!useWeekly)
   {
      if (_startTime == _endTime)
         return new NoCondition();
      return new TradingTimeCondition(_startTime, _endTime);
   }

   int _weekStartTime = ParseTime(weekStartTime, error);
   if (_weekStartTime == -1)
      return NULL;
   int _weekEndTime = ParseTime(weekEndTime, error);
   if (_weekEndTime == -1)
      return NULL;

   return new TradingTimeCondition(_startTime, _endTime, startDay, _weekStartTime, stopDay, _weekEndTime);
}

class TradingTimeCondition : public AConditionBase
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTimeCondition(int startTime, int endTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = false;
   }

   TradingTimeCondition(int startTime, int endTime, const DayOfWeek startDay,
      int weekStartTime, const DayOfWeek stopDay, int weekEndTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
      _useWeekTime = true;
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      _weekStartTime = weekStartTime;
      _weekStopTime = weekEndTime;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }

   void GetStartEndTime(const datetime date, datetime &start, datetime &end)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime referece = StructToTime(current_time);

      start = referece + _startTime;
      end = referece + _endTime;
      if (_startTime > _endTime)
      {
         start += 86400;
      }
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }
};

class TokyoTimezoneCondition : public TradingTimeCondition
{
public:
   TokyoTimezoneCondition()
      : TradingTimeCondition((-5) * 3600, (-5 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Tokyo TZ: " + (result ? "true" : "false");
   }
};

class NewYorkTimezoneCondition : public TradingTimeCondition
{
public:
   NewYorkTimezoneCondition()
      : TradingTimeCondition(8 * 3600, (8 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "NY TZ: " + (result ? "true" : "false");
   }
};

class LondonTimezoneCondition : public TradingTimeCondition
{
public:
   LondonTimezoneCondition()
      : TradingTimeCondition(3 * 3600, (3 + 9) * 3600)
   {

   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "London TZ: " + (result ? "true" : "false");
   }
};

class DayTimeCondition : public TradingTimeCondition
{
   int _dayOfMonth;
public:
   DayTimeCondition(int dayOfMonth, int startTime, int intervalSeconds)
      :TradingTimeCondition(startTime, startTime + intervalSeconds)
   {
      _dayOfMonth = dayOfMonth;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time) || current_time.day != _dayOfMonth)
      {
         return false;
      }
      
      return TradingTimeCondition::IsPass(period, date);
   }
};
#endif