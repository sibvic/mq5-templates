// Not condition v1.0

#include <AConditionBase.mq5>

#ifndef NotCondition_IMP
#define NotCondition_IMP

class NotCondition : public AConditionBase
{
   ICondition* _condition;
public:
   NotCondition(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~NotCondition()
   {
      _condition.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return !_condition.IsPass(period, date);
   }
};
#endif