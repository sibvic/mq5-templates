#include <Streams/AOnStream.mqh>
#include <Streams/Averages/SMAOnStream.mqh>

// Measure of difference between the series and it's SMA stream 
// v1.0

class DevStream : public AOnStream
{
   SmaOnStream* sma;
public:
   DevStream (IStream *source, const int length)
      :AOnStream(source)
   {
      sma = new SmaOnStream(source, length);
   }

   ~DevStream ()
   {
      sma.Release();
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
      double src[];
      ArrayResize(src, count);
      double smaValue[];
      ArrayResize(smaValue, count);
      if (!_source.GetValues(period, count, src) || !sma.GetValues(period, count, smaValue))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = src[i] - smaValue[i];
      }
      return true;
   }
};