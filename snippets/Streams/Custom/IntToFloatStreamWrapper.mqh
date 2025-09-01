// v2.0
// Wraps IIntStream and provides TIStream<double>

#ifndef IntToFloatStreamWrapper_IMPL
#define IntToFloatStreamWrapper_IMPL
#include <Streams/Abstract/AFloatStream.mqh>
#include <Streams/Abstract/TAStream.mqh>

class IntToFloatStreamWrapper : public AFloatStream
{
   TIStream<int>* _source;
public:
   IntToFloatStreamWrapper(TIStream<int>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~IntToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int intVal[];
      ArrayResize(intVal, count);
      if (!_source.GetValues(period, count, intVal))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = intVal[i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};
#endif