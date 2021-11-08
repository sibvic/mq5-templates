#include <Conditions/ACondition.mqh>
#include <Conditions/AndCondition.mqh>
#include <Conditions/OrCondition.mqh>
#include <Conditions/StreamLevelCondition.mqh>
#include <Streams/IStream.mqh>
#include <Streams/BarsSinceStream.mqh>

class MaxDistanceBetweenConditionsCondition : public ACondition
{
   AndCondition* _condition;
public:
   MaxDistanceBetweenConditionsCondition(string symbol, ENUM_TIMEFRAMES timeframe, ICondition* condition1, ICondition* condition2, int maxDistance)
      :ACondition(symbol, timeframe, "Max distance between conditions")
   {
      _condition = new AndCondition();
      _condition.Add(CreatePair(condition1, condition2, "condition 2", maxDistance), false);
      _condition.Add(CreatePair(condition2, condition1, "condition 1", maxDistance), false);
   }

   ~MaxDistanceBetweenConditionsCondition()
   {
      _condition.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return _condition.IsPass(period, date);
   }
private:
   ICondition* CreatePair(ICondition* exactCondition, ICondition* distanceCondition, string name, int maxDistance)
   {
      OrCondition* or = new OrCondition();
      or.Add(exactCondition, true);

      IStream* barsSince = new BarsSinceStream(_symbol, _timeframe, distanceCondition);
      ICondition* maxDistCondition = new StreamLevelCondition(_symbol, _timeframe, FirstBelowSecond, barsSince, maxDistance + 1, "Bars since " + name + " <= " + IntegerToString(maxDistance));
      barsSince.Release();
      or.Add(maxDistCondition, true);
      maxDistCondition.Release();
      return or;
   }
};