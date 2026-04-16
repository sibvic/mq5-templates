// v2.0
// Wraps TIStream<bool> and provides TIStream<double>

#ifndef BoolToFloatStreamWrapper_IMPL
#define BoolToFloatStreamWrapper_IMPL
#include <Streams/Abstract/TAStream.mqh>

class BoolToFloatStreamWrapper : public TAStream<double>
{
   TIStream<bool>* _source;
public:
   BoolToFloatStreamWrapper(TIStream<bool>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~BoolToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      bool bVal[];
      ArrayResize(bVal, count);
      if (!_source.GetValues(period, count, bVal))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = bVal[i] ? 1.0 : 0.0;
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
};
#endif
