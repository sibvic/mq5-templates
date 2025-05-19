#ifndef CrossStreamV2_IMPL
#define CrossStreamV2_IMPL
#include <Streams/Condition/ConditionStreamV2.mqh>
#include <Conditions/StreamStreamCondition.mqh>
#include <Conditions/OrCondition.mqh>
#include <enums/TwoStreamsConditionType.mqh>
#include <Streams/Custom/IntToFloatStreamWrapper.mqh>

//CrossStreamV2 v2.0

class CrossStreamFactory
{
public:
   static TIStream<int>* CreateCross(TIStream<double> *left, TIStream<double>* right)
   {
      OrCondition* or = new OrCondition();
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", ""), false);
      or.Add(new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, right, left, "", ""), false);
      ConditionStreamV2* result = new ConditionStreamV2(or);
      or.Release();
      return result;
   }

   static TIStream<int>* CreateCrossunder(TIStream<double> *left, TIStream<double>* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossUnderSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static TIStream<int>* CreateCrossunder(TIStream<double> *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossunder(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }

   static TIStream<int>* CreateCrossover(TIStream<double> *left, TIStream<double>* right)
   {
      StreamStreamCondition* condition = new StreamStreamCondition(_Symbol, (ENUM_TIMEFRAMES)_Period, FirstCrossOverSecond, left, right, "", "");
      ConditionStreamV2* result = new ConditionStreamV2(condition);
      condition.Release();
      return result;
   }
   static TIStream<int>* CreateCrossover(IIntStream *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* leftWrapper = new IntToFloatStreamWrapper(left);
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossover(leftWrapper, rightWrapper);
      leftWrapper.Release();
      rightWrapper.Release();
      return condition;
   }
   static TIStream<int>* CreateCrossover(TIStream<double> *left, IIntStream* right)
   {
      IntToFloatStreamWrapper* rightWrapper = new IntToFloatStreamWrapper(right);
      TIStream<int>* condition = CreateCrossover(left, rightWrapper);
      rightWrapper.Release();
      return condition;
   }
};
#endif