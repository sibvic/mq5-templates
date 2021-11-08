#include <Streams/AStream.mqh>
#include <Conditions/ICondition.mqh>

class BarsSinceStream : public AStream
{
   ICondition* _condition;
   int _bars[];
public:
   BarsSinceStream(string symbol, ENUM_TIMEFRAMES timeframe, ICondition* condition)
      :AStream(symbol, timeframe)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStream()
   {
      _condition.Release();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if (period + count >= size)
      {
         return false;
      }
      if (ArraySize(_bars) < size)
      {
         ArrayResize(_bars, size);
      }
      for (int i = 0; i < count; ++i)
      {
         int index = size - period - i - 1;
         if (_bars[index] == 0)
         {
            FillHistory(period + i);
         }
         val[i] = _bars[index];
      }
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex < size; ++periodIndex)
      {
         int index = size - periodIndex - 1;
         if (!_condition.IsPass(periodIndex, 0))
         {
            if (_bars[index] == 0)
            {
               continue;
            }
         }
         else
         {
            _bars[index] = 0;
         }
         for (int ii = index + 1; ii <= size - period - 1; ++ii)
         {
            _bars[ii] = _bars[ii - 1] + 1;
         }
         return;
      }
   }
};