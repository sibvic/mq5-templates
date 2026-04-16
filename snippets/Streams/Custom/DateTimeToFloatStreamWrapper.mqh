// v2.0
// Wraps IDateTimeStream and provides TIStream<double>

#ifndef DateTimeToFloatStreamWrapper_IMPL
#define DateTimeToFloatStreamWrapper_IMPL
#include <Streams/Abstract/TAStream.mqh>
#include <Streams/Interfaces/TIStream.mqh>

class DateTimeToFloatStreamWrapper : public TAStream<double>
{
   TIStream<datetime>* _source;
public:
   DateTimeToFloatStreamWrapper(TIStream<datetime>* source)
   {
      _source = source;
      _source.AddRef();
   }
   ~DateTimeToFloatStreamWrapper()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      datetime intVal[];
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
