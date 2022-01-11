#include <Streams/ConditionStream.mqh>
#include <Conditions/StreamStreamCondition.mqh>
#include <Conditions/OrCondition.mqh>
#include <enums/TwoStreamsConditionType.mqh>

//CrossStream v1.0

class CrossStream : public ConditionStream
{
public:
   CrossStream(IStream *left, IStream* right)
      :ConditionStream(new OrCondition())
   {
      OrCondition* or = (OrCondition*)(_condition);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      or.Release();
   }
};