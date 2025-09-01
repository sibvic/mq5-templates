// Variance on stream v1.0

#include <Streams/AOnStream.mqh>
#include <Streams/Custom/IntToFloatStreamWrapper.mqh>

class VarianceOnStream : public AOnStream
{
   int _length;
   bool _biased;
public:
   VarianceOnStream(TIStream<double>* source, int length, bool biased)
      :AOnStream(source)
   {
      _length = length;
      _biased = biased;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (_length == 1)
      {
         return false;
      }
      if (!_biased)
      {
         return false; // not supported yet
      }
      //period is an index for time series (0 = latest)
      int totalBars = _source.Size();

      double values[];
      ArrayResize(values, _length);

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current[1];
         if (!_source.GetValues(period + i, 1, current))
         {
            return false;
         }
         values[i] = current[0];
         sum += current[0];
      }
      double diffSumm = 0;
      for (int i = 0; i < _length; ++i)
      {
         diffSumm += MathSqrt(values[i] - sum);
      }
      val = diffSumm / (_length - 1);
      return true;
   }
};

class VarianceOnStreamFactory
{
public:
   static VarianceOnStream* Create(TIStream<double>* source, int length, bool biased)
   {
      return new VarianceOnStream(source, length, biased);
   }
   static VarianceOnStream* Create(TIStream<int>* source, int length, bool biased)
   {
      IntToFloatStreamWrapper* wrapper = new IntToFloatStreamWrapper(source);
      VarianceOnStream* stream = new VarianceOnStream(wrapper, length, biased);
      wrapper.Release();
      return stream;
   }
};

