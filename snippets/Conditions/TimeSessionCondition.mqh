// Time session condition v1.0

#include <Conditions/AConditionBase.mqh>
#include <PineScript/Time.mqh>

#ifndef TimeSessionCondition_IMP
#define TimeSessionCondition_IMP

class TimeSessionCondition : public AConditionBase
{
   bool _hasSession;
   int _sessionFrom[];
   int _sessionTo[];
   int _sessionDays[];
public:
   TimeSessionCondition(string session)
      :AConditionBase("Trading Session")
   {
      _hasSession = false;
      ParseSessions(session);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!_hasSession)
      {
         return true;
      }
      return InSession(date);
   }
private:
   bool IsEmpty(string &value)
   {
      StringTrimLeft(value);
      StringTrimRight(value);
      return StringLen(value) == 0;
   }

   void ParseSessions(string session)
   {
      if (IsEmpty(session))
      {
         return;
      }
      _hasSession = true;
      string parts[];
      int count = StringSplit(session, ',', parts);
      for (int i = 0; i < count; ++i)
      {
         AddSession(parts[i]);
      }
   }

   void AddSession(string spec)
   {
      if (IsEmpty(spec))
      {
         return;
      }

      int days = 0x7F;
      int colon = StringFind(spec, ":");
      string range = spec;
      if (colon >= 0)
      {
         range = StringSubstr(spec, 0, colon);
         string daySpec = StringSubstr(spec, colon + 1);
         days = 0;
         int dayCount = StringLen(daySpec);
         for (int i = 0; i < dayCount; ++i)
         {
            int d = (int)StringGetCharacter(daySpec, i) - '0';
            if (d >= 1 && d <= 7)
            {
               days |= 1 << (d - 1);
            }
         }
      }

      string times[];
      if (StringSplit(range, '-', times) != 2)
      {
         Print("Bad format for " + spec);
         return;
      }
      string error = "";
      int from = PineScriptTime::ParseTime(times[0], error);
      if (from < 0)
      {
         Print(error);
         return;
      }
      error = "";
      int to = PineScriptTime::ParseTime(times[1], error);
      if (to < 0)
      {
         Print(error);
         return;
      }

      int n = ArraySize(_sessionFrom);
      ArrayResize(_sessionFrom, n + 1);
      ArrayResize(_sessionTo, n + 1);
      ArrayResize(_sessionDays, n + 1);
      _sessionFrom[n] = from;
      _sessionTo[n] = to;
      _sessionDays[n] = days;
   }

   bool InSession(const datetime t)
   {
      if (ArraySize(_sessionFrom) == 0)
      {
         return false;
      }
      MqlDateTime dt;
      if (!TimeToStruct(t, dt))
      {
         return false;
      }
      int tod = PineScriptTime::TimeToInt(dt);
      int day = dt.day_of_week;
      int n = ArraySize(_sessionFrom);
      for (int i = 0; i < n; ++i)
      {
         int from = _sessionFrom[i];
         int to = _sessionTo[i];
         int mask = _sessionDays[i];
         if (from == to)
         {
            if ((mask & (1 << day)) != 0)
            {
               return true;
            }
            continue;
         }
         if (from < to)
         {
            if (tod >= from && tod <= to && (mask & (1 << day)) != 0)
            {
               return true;
            }
            continue;
         }
         if (tod >= from && (mask & (1 << day)) != 0)
         {
            return true;
         }
         int prevDay = (day + 6) % 7;
         if (tod <= to && (mask & (1 << prevDay)) != 0)
         {
            return true;
         }
      }
      return false;
   }
};

#endif
