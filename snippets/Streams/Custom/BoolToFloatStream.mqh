#ifndef BoolToFloatStream_IMPL
#define BoolToFloatStream_IMPL

#include <Streams/Abstract/AFloatStream.mqh>
#include <Streams/Interfaces/TIStream.mqh>
// Bool to float stream v2.0

class BoolToFloatStream : public AFloatStream
{
   TIStream<int>* stream;
public:
   BoolToFloatStream(TIStream<int>* stream)
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
      int values[];
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