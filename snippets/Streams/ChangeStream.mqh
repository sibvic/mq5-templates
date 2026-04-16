#ifndef ChangeStream_IMPL
#define ChangeStream_IMPL

#include <Streams/AOnStream.mqh>
#include <Streams/Interfaces/TIStream.mqh>
#include <Streams/Custom/IntToFloatStreamWrapper.mqh>
#include <Streams/Custom/BoolToFloatStreamWrapper.mqh>
#include <Streams/Custom/DateTimeToFloatStreamWrapper.mqh>

//ChangeStream v2.1
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(TIStream<double>* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   ChangeStream(TIStream<int>* stream, int period = 1)
      :AOnStream(new IntToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(TIStream<bool>* stream, int period = 1)
      :AOnStream(new BoolToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }
   
   ChangeStream(TIStream<datetime>* stream, int period = 1)
      :AOnStream(new DateTimeToFloatStreamWrapper(stream))
   {
      _source.Release();
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }

   bool GetSeriesValue(const int period, int &val)
   {
      double tmp;
      if (!GetSeriesValue(period, tmp))
      {
         return false;
      }
      val = (int)tmp;
      return true;
   }

   bool GetValues(const int period, const int count, int &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         int v;
         if (!GetSeriesValue(size - 1 - period + i, v))
         {
            return false;
         }
         val[i] = v;
      }
      return true;
   }
};

class ChangeStreamFactory
{
public:
   static TIStream<double>* Create(TIStream<double>* stream, int period = 1)
   {
      return new ChangeStream(stream, period);
   }
   
   static TIStream<double>* Create(TIStream<int>* stream, int period = 1)
   {
      IntToFloatStreamWrapper* wrapper = new IntToFloatStreamWrapper(stream);
      ChangeStream* change = new ChangeStream(wrapper, period);
      wrapper.Release();
      return change;
   }

   static TIStream<double>* Create(TIStream<bool>* stream, int period = 1)
   {
      BoolToFloatStreamWrapper* wrapper = new BoolToFloatStreamWrapper(stream);
      ChangeStream* change = new ChangeStream(wrapper, period);
      wrapper.Release();
      return change;
   }
};

#endif 