#include <Streams/AOnStream.mqh>

#ifndef SwmaOnStream_IMPL
#define SwmaOnStream_IMPL

// EMA on stream v2.0

class SwmaOnStream : public AOnStream
{
public:
   SwmaOnStream(TIStream<double> *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (period > totalBars - 4)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double x[4];
      if (!_source.GetSeriesValues(period, 4, x))
      {
         return false;
      }
      val = x[3] * 1 / 6 + x[2] * 2 / 6 + x[1] * 2 / 6 + x[0] * 1 / 6;
      return true;
   }
};
#endif 