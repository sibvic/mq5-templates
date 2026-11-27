#include <Streams/AOnStream.mqh>
#include <Streams/HighestHighStream.mqh>
#include <Streams/LowestLowStream.mqh>

// Stochastics on stream v1.0
// 100 * (source - lowest(low, length)) / (highest(high, length) - lowest(low, length))
// A flat range or a missing value returns no value.

#ifndef StochOnStream_IMP
#define StochOnStream_IMP

class StochOnStream : public AOnStream
{
   HighestHighStream* _highest;
   LowestLowStream* _lowest;
public:
   StochOnStream(TIStream<double>* source, TIStream<double>* high, TIStream<double>* low, int length)
      :AOnStream(source)
   {
      _highest = new HighestHighStream(high, length);
      _lowest = new LowestLowStream(low, length);
   }

   ~StochOnStream()
   {
      _highest.Release();
      _lowest.Release();
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      int pos = Size() - period - 1;
      if (pos < 0)
      {
         return false;
      }
      return GetValue(pos, val);
   }

   bool GetValue(const int period, double &val)
   {
      double src[1];
      if (!_source.GetValues(period, 1, src) || src[0] == EMPTY_VALUE)
      {
         return false;
      }
      double highest[1];
      if (!_highest.GetValues(period, 1, highest) || highest[0] == EMPTY_VALUE)
      {
         return false;
      }
      double lowest[1];
      if (!_lowest.GetValues(period, 1, lowest) || lowest[0] == EMPTY_VALUE)
      {
         return false;
      }
      double diff = highest[0] - lowest[0];
      if (diff == 0)
      {
         return false;
      }
      val = 100.0 * (src[0] - lowest[0]) / diff;
      return true;
   }
};

#endif
