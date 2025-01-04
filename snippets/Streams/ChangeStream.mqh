#ifndef ChangeStream_IMPL
#define ChangeStream_IMPL

#include <Streams/AOnStream.mqh>
#include <Streams/Interfaces/IBoolStream.mqh>
#include <Streams/Custom/BoolToFloatStream.mqh>

//ChangeStream v1.2
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      int size = Size();
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }
};

class ChangeStreamFactory
{
public:
   static IStream* Create(IStream* stream, int period = 1)
   {
      return new ChangeStream(stream, period);
   }
   
   static IStream* Create(IBoolStream* stream, int period = 1)
   {
      BoolToFloatStream* wrapper = new BoolToFloatStream(stream);
      ChangeStream* change = new ChangeStream(wrapper, period);
      wrapper.Release();
      return change;
   }
};

#endif 