#include <Conditions/ACondition.mqh>
#include <enums/TwoStreamsConditionType.mqh>
#include <streams/IStream.mqh>

// Stream-stream condition v1.0

class StreamStreamCondition : public ACondition
{
   TwoStreamsConditionType _condition;
   IStream* _stream1;
   string _name;
   IStream* _stream2;
public:
   StreamStreamCondition(const string symbol, ENUM_TIMEFRAMES timeframe, TwoStreamsConditionType condition, IStream* stream1, IStream* stream2, string name)
      :ACondition(symbol, timeframe)
   {
      _name = name;
      _stream1 = stream1;
      _stream1.AddRef();
      _stream2 = stream2;
      _stream2.AddRef();
   }
   ~StreamStreamCondition()
   {
      _stream1.Release();
      _stream2.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      double values1[2];
      if (!_stream1.GetSeriesValues(period, 2, values1))
      {
         return false;
      }
      double values2[2];
      if (!_stream2.GetSeriesValues(period, 2, values2))
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return values1[0] > values2[0];
         case FirstBelowSecond:
            return values1[0] < values2[0];
         case FirstCrossOverSecond:
            return values1[0] >= values2[0] && values1[1] < values2[1];
         case FirstCrossUnderSecond:
            return values1[0] <= values2[0] && values1[1] > values2[1];
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
