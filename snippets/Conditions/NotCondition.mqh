#include <Conditions/AConditionBase.mqh>

// Not condition v1.1

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

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Not (" + _condition.GetLogMessage(period, date) + (IsPass(period, date) ? ")=true" : ")=false");
   }
};
#endif