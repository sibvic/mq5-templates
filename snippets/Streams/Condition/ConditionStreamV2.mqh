#ifndef ConditionStreamV2_IMPL
#define ConditionStreamV2_IMPL
#include <Conditions/ICondition.mqh>
#include <Streams/Abstract/TAStream.mqh>

//ConditionStreamV2 v2.0

class ConditionStreamV2 : public TAStream<int>
{
protected:
   ICondition* _condition;
public:
   ConditionStreamV2(ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~ConditionStreamV2()
   {
      _condition.Release();
   }

   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   bool GetValue(const int period, int &val)
   {
      val = _condition.IsPass(period, 0);
      return true;
   }
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      if (Size() <= period || period - count + 1 < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = _condition.IsPass(period - i, 0) ? 1 : 0;
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      int pos = Size() - period - 1;
      return GetValues(pos, count, val);
   }
};
#endif