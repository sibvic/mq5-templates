#include <enums/TwoStreamsConditionType.mqh>
#include <conditions/ACondition.mqh>
#include <streams/IStream.mqh>
// Stream level condition v1.0

class StreamLevelCondition : public ACondition
{
   TwoStreamsConditionType _condition;
   IStream* _stream;
   string _name;
   double _level;
public:
   StreamLevelCondition(const string symbol, ENUM_TIMEFRAMES timeframe, TwoStreamsConditionType condition, IStream* stream, double level, string name)
      :ACondition(symbol, timeframe)
   {
      _level = level;
      _name = name;
      _stream = stream;
      _stream.AddRef();
   }
   ~StreamLevelCondition()
   {
      _stream.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      double values[2];
      if (!_stream.GetSeriesValues(period, 2, values))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return values[0] > _level;
         case FirstBelowSecond:
            return values[0] < _level;
         case FirstCrossOverSecond:
            return values[0] >= _level && values[1] < _level;
         case FirstCrossUnderSecond:
            return values[0] <= _level && values[1] > _level;
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return _name + ": " + (result ? "true" : "false");
         case FirstBelowSecond:
            return _name + ": " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return _name + ": " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return _name + ": " + (result ? "true" : "false");
      }
      return _name + ": " + (result ? "true" : "false");
   }
};
