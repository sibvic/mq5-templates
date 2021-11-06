// Condition stream v1.1

#ifndef ConditionStream_IMP
#define ConditionStream_IMP

class ConditionStream : public AStream
{
   ICondition* _conditions[];
   double _weights[];
public:
   ConditionStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
      
   }

   ~ConditionStream()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Release();
      }
   }

   void Add(ICondition *condition, double weight, bool addRef)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      ArrayResize(_weights, size + 1);
      _conditions[size] = condition;
      _weights[size] = weight;
      if (addRef)
      {
         condition.AddRef();
      }
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = period; i < period + count; ++i)
      {
         double total = 0;
         double totalMax = 0;
         for (int ii = 0; ii < ArraySize(_conditions); ++ii)
         {
            if (_conditions[ii].IsPass(i, iTime(_symbol, _timeframe, i)))
            {
               total += _weights[i];
            }
            totalMax += _weights[i];
         }
         val[i - period] = total / totalMax;
      }
      return true;
   }
};

#endif