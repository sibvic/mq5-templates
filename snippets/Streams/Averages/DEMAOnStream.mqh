#include <Streams/AOnStream.mqh>
#include <Streams/CustomStream.mqh>
#include <Streams/averages/RmaOnStream.mqh>

// DEMAOnStream v2.1
class DEMAOnStream : public AOnStream
{
   double _alpha;
   CustomStream* _buffer;
   CustomStream* _buffer2;
public:
   DEMAOnStream(TIStream<double>* source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
      _source = source;
      _buffer = new CustomStream(source);
      _buffer2 = new CustomStream(source);
   }

   ~DEMAOnStream()
   {
      _buffer.Release();
      _buffer2.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      
      double prices[1];
      if (!_source.GetSeriesValues(period, 1, prices))
      {
         return false;
      }

      double buffer_prev[1];
      if (!_buffer.GetSeriesValues(period - 1, 1, buffer_prev))
      {
         return false;
      }

      double val1 = buffer_prev[0] + _alpha * (prices[0] - buffer_prev[0]);
      _buffer.SetValue(period, val1);

      double buffer2_prev[1];
      if (!_buffer2.GetSeriesValues(period - 1, 1, buffer2_prev))
      {
         return false;
      }

      double val2 = buffer2_prev[0] + _alpha * (val1 - buffer_prev[0]);
      _buffer2.SetValue(period, val2);
      val = val1 * 2.0 - val2;
      return true;
   }
};