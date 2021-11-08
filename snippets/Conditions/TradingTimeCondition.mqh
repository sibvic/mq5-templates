#include <Conditions/AConditionBase.mqh>
#include <Conditions/OrCondition.mqh>
#include <enums/DayOfWeek.mqh>

// Trading time condition v2.0

class TradingTimeFactory
{
public:
   static ICondition* Create(string tradingTime, string& error)
   {
      string sessions[];
      StringSplit(tradingTime, ',', sessions);
      OrCondition* sessionCondtions = new OrCondition();
      for (int i = 0; i < ArraySize(sessions); ++i)
      {
         ICondition* sessionCondition = CreateSessionCondition(sessions[i], error);
         if (sessionCondition == NULL)
         {
            delete sessionCondtions;
            return NULL;
         }
         sessionCondtions.Add(sessionCondition, true);
         sessionCondition.Release();
      }
      return sessionCondtions;
   }
private:
   static ICondition* CreateSessionCondition(string session, string& error)
   {
      string times[];
      StringSplit(session, '-', times);
      int size = ArraySize(times);
      if (size != 2)
      {
         error = "Wrong format for session " + session;
         return NULL;
      }
      int from = ParseTime(times[0], error);
      if (from < 0)
      {
         return NULL;
      }
      int to = ParseTime(times[1], error);
      if (to < 0)
      {
         return NULL;
      }
      return new TradingTimeCondition(from, to);
   }

   static int ParseTime(string time, string& error)
   {
      int time_parsed = (int)StringToInteger(time);
      time_parsed /= 100;
      int minutes = time_parsed % 100;
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }

      time_parsed /= 100;
      int hours = time_parsed % 100;
      if (hours > 24)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      if (hours == 24 && minutes != 0)
      {
         error = "Incorrect time";
         return -1;
      }
      return (hours * 60 + minutes) * 60;
   }
};

class TradingTimeCondition : public AConditionBase
{
   int _startTime;
   int _endTime;
public:
   TradingTimeCondition(int startTime, int endTime)
      :AConditionBase("Trading Time")
   {
      _startTime = startTime;
      _endTime = endTime;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time))
         return false;
      return IsIntradayTradingTime(current_time);
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
};

class DayOfWeekCondition : public AConditionBase
{
   bool _days[7];
public:
   DayOfWeekCondition()
      :AConditionBase("Day of week")
   {
   }

   void Set(int index)
   {
      _days[index - 1] = true;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(TimeCurrent(), current_time) || !_days[current_time.day_of_week])
      {
         return false;
      }
      
      return true;
   }
};