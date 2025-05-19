// Boilinger Band Width v2.0

#ifndef BBW_IMP
#define BBW_IMP
#include <Streams/AStreamBase.mqh>
#include <Streams/StDevStream.mqh>

class BBW : public AStreamBase
{
   StDevStream *stdev;
   double mult;
public:
   BBW(TIStream<double>* stream, int length, double mult)
   {
      stdev = new StDevStream(stream, length);
      this.mult = mult;
   }
   ~BBW()
   {
      stdev.Release();
   }
   
   virtual int Size()
   {
      return stdev.Size();
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      if (!stdev.GetValues(period, count, val))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = val[i] * mult * 2;
      }
      return true;
   }
};

#endif

