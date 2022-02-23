#include <Streams/AStreamBase.mqh>

// Custom stream base v1.0
class ACustomStreamBase : public AStreamBase
{
public:
   virtual int Size()
   {
      return iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int oldIndex = Size() - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
protected:
   virtual bool GetValue(const int period, double &val) = 0;
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int index = SeriesIndexToArray(period);
      return GetValue(index, val);
   }
   
   int SeriesIndexToArray(int index)
   {
      return Size() - 1 - index;
   }
};