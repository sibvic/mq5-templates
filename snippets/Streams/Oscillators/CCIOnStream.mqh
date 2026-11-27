#include <Streams/AOnStream.mqh>

// CCI on stream v1.0
// cci = (source - sma) / (0.015 * meanDeviation)
// meanDeviation is the average of abs(source - sma) over the same window.
// A flat window (mean deviation 0) returns 0.

#ifndef CCIOnStream_IMP
#define CCIOnStream_IMP

class CCIOnStream : public AOnStream
{
   int _length;
public:
   CCIOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (_length < 1)
      {
         return false;
      }
      double prices[];
      ArrayResize(prices, _length);
      if (!_source.GetSeriesValues(period, _length, prices))
      {
         return false;
      }
      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         sum += prices[i];
      }
      double mean = sum / _length;
      double devSum = 0;
      for (int i = 0; i < _length; ++i)
      {
         devSum += MathAbs(prices[i] - mean);
      }
      double meanDev = devSum / _length;
      if (meanDev == 0.0)
      {
         val = 0.0;
         return true;
      }
      val = (prices[0] - mean) / (0.015 * meanDev);
      return true;
   }
};

#endif
