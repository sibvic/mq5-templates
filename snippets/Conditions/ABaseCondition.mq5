// Base condition v1.0

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

#include <ACondition.mq5>
#include <../InstrumentInfo.mq5>
class ABaseCondition : public ACondition
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo* _instrument;
   string _symbol;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
};


#endif