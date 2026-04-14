#include <Streams/AOnStream.mqh>

// Rate of change stream v2.0

class ROCOnStream : public AOnStream
{
   int _length;
public:
   ROCOnStream(TIStream<double> *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      if (period + _length >= totalBars)
      {
         return false;
      }
      double pr[1];
      if (!_source.GetSeriesValues(period + _length, 1, pr) || pr[0] == 0)
      {
         return false;
      }
      double currPrice[1];
      if (!_source.GetSeriesValues(period, 1, currPrice))
      {
         return false;
      }
      val = (currPrice[0] / pr[0] - 1.0) * 100.0;
      return true;
   }
};
