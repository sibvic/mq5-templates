#include <Streams/AOnStream.mqh>
#include <Streams/HighestHighStream.mqh>
#include <Streams/LowestLowStream.mqh>

// Williams %R stream v2.0

#ifndef WilliamsRStream_IMP
#define WilliamsRStream_IMP

class WilliamsRStream : public AOnStream
{
   int _period;
   TIStream<double>* high;
   TIStream<double>* low;
public:
   WilliamsRStream(TIStream<double>* source, TIStream<double>* high, TIStream<double>* low, int period)
      :AOnStream(source)
   {
      this.high = new HighestHighStream(high, period);
      this.low = new LowestLowStream(low, period);
      _period = period;
   }

   ~WilliamsRStream()
   {
      high.Release();
      low.Release();
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
      double src[1];
      if (!_source.GetValues(period, 1, src))
      {
         return false;
      }
      double hh[1];
      if (!high.GetValues(period, 1, hh))
      {
         return false;
      }
      double ll[1];
      if (!low.GetValues(period, 1, ll))
      {
         return false;
      }
      val = -(hh[0] - src[0]) / (hh[0] - ll[0]) * 100;
      return true;
   }
};

#endif