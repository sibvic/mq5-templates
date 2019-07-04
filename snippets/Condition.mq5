// Conditions v.1.1
interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class DisabledCondition : public ICondition
{
public:
   virtual bool IsPass(const int period) { return false; }
};

class EntryLongCondition : public ICondition
{
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
public:
   EntryLongCondition(InstrumentInfo *symbolInfo, ENUM_TIMEFRAMES timeframe)
   {
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }
   ~EntryLongCondition()
   {
      
   }

   virtual bool IsPass(const int period)
   {
      // TODO: implement
      return false;
   }
};

class EntryShortCondition : public ICondition
{
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
public:
   EntryShortCondition(InstrumentInfo *symbolInfo, ENUM_TIMEFRAMES timeframe)
   {
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }
   ~EntryShortCondition()
   {
      
   }

   virtual bool IsPass(const int period)
   {
      // TODO: implement
      return false;
   }
};

class TradingTimeCondition : public ICondition
{
   TradingTime *_tradingTime;
   ENUM_TIMEFRAMES _timeframe;
public:
   TradingTimeCondition(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
      _tradingTime = new TradingTime();
   }

   ~TradingTimeCondition()
   {
      delete _tradingTime;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      return _tradingTime.Init(startTime, endTime, error);
   }

   virtual bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _timeframe, period);
      return _tradingTime.IsTradingTime(time);
   }
};

class AndCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~AndCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         delete _conditions[i];
      }
   }

   void Add(ICondition *condition)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
   }

   virtual bool IsPass(const int period)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (!_conditions[i].IsPass(period))
            return false;
      }
      return true;
   }
};

class OrCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~OrCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         delete _conditions[i];
      }
   }

   void Add(ICondition *condition)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
   }

   virtual bool IsPass(const int period)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (_conditions[i].IsPass(period))
            return true;
      }
      return false;
   }
};