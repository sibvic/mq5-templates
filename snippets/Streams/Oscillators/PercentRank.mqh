// Percent rank v1.0

#ifndef PercentRank_IMP
#define PercentRank_IMP

#include <Streams/AOnStream.mqh>

class PercentRank : public AOnStream
{
   int length;
public:
   PercentRank(IStream* stream, int length)
      :AOnStream(stream)
   {
      this.length = length;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      return false;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (totalBars == 0)
      {
         return false;
      }
      
      double target[];
      ArrayResize(target, length + 1);
      if (!_source.GetValues(period, length + 1, target))
      {
         return false;
      }
      int count = 0;
      for (int i = 1; i < length; ++i)
      {
         int current = target[i];
         if (current != EMPTY_VALUE && target[0] >= current)
         {
            count++;
         }
      }
      val = (count * 100.0) / length;
      return true;
   }
};


#endif

