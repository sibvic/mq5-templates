#ifndef BoolToFloatStream_IMPL
#define BoolToFloatStream_IMPL

#include <Streams/Abstract/AFloatStream.mqh>
#include <Streams/interfaces/IBoolStream.mqh>
// Bool to float stream v1.0

class BoolToFloatStream : public AFloatStream
{
   IBoolStream* stream;
public:
   BoolToFloatStream(IBoolStream* stream)
   {
      this.stream = stream;
      stream.AddRef();
   }
   ~BoolToFloatStream()
   {
      stream.Release();
   }

   void Init()
   {
   }

   virtual int Size()
   {
      return stream.Size();
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      bool values[];
      ArrayResize(values, count);
      if (!stream.GetValues(period, count, values))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = values[i] ? 1 : 0;
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};

#endif