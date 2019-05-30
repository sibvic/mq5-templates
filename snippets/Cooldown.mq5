// Cooldown controller v1.1
class ICooldownController
{
public:
   virtual bool IsCooldownPeriod(const int period) = 0;

   virtual void RegisterTrading(const int period) = 0;
};

// Allows to trade once per bar
class OncePerBarCooldownController : public ICooldownController
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDate;
public:
   OncePerBarCooldownController(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _lastDate = 0;
   }

   virtual bool IsCooldownPeriod(const int period)
   {
      datetime currentDate = iTime(_symbol, _timeframe, period);
      return _lastDate == currentDate;
   }

   virtual void RegisterTrading(const int period)
   {
      _lastDate = iTime(_symbol, _timeframe, period);
   }
};

#define DT_DAY 86400

// Allows to trade once per time range
class TimeRangeCooldownController : public ICooldownController
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDate;
   int _startTime;
public:
   TimeRangeCooldownController(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _lastDate = 0;
      _startTime = 0;
   }

   bool Init(const string startTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      return true;
   }

   virtual bool IsCooldownPeriod(const int period)
   {
      datetime currentDate = iTime(_symbol, _timeframe, period);
      return (currentDate - _lastDate) < DT_DAY;
   }

   virtual void RegisterTrading(const int period)
   {
      datetime currentDate = iTime(_symbol, _timeframe, period);
      _lastDate = (datetime)(MathFloor(currentDate / DT_DAY) * DT_DAY) + _startTime;
      if (_lastDate > currentDate)
         _lastDate -= DT_DAY;
      ++_trades;
   }
private:
   int ParseTime(const string time, string &error)
   {
      int time_parsed = (int)StringToInteger(time);
      int seconds = time_parsed % 100;
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      time_parsed /= 100;
      int minutes = time_parsed % 100;
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      time_parsed /= 100;
      int hours = time_parsed % 100;
      if (hours > 24 || (hours == 24 && (minutes > 0 || seconds > 0)))
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};