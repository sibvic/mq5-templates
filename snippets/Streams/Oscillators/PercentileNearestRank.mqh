#include <Streams/AOnStream.mqh>

// Nearest-rank percentile (Pine ta.percentile_nearest_rank) stream v1.0

#ifndef PercentileNearestRankOnStream_IMP
#define PercentileNearestRankOnStream_IMP

class PercentileNearestRankOnStream : public AOnStream
{
   int _length;
   double _percentage;
   double _sample[];
public:
   PercentileNearestRankOnStream(TIStream<double> *source, const int length, const double percentage)
      :AOnStream(source)
   {
      _length = length;
      _percentage = percentage;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      if (_length < 1 || period > totalBars - _length)
         return false;

      if (ArraySize(_sample) != _length)
      {
         if (ArrayResize(_sample, _length) != _length)
            return false;
      }

      if (!_source.GetSeriesValues(period, _length, _sample))
         return false;

      ArraySort(_sample);

      int n = _length;
      int k = (int)MathCeil(_percentage / 100.0 * n);
      if (k < 1)
         k = 1;
      if (k > n)
         k = n;

      val = _sample[k - 1];
      return true;
   }
};

#endif
