#include <Streams/AOnStream.mqh>

// Sum on stream v1.0

class SumOnStream : public AOnStream
{
   double _buffer[];
   int _length;
public:
   SumOnStream(IStream *source, int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current[1];
         if (!_source.GetSeriesValues(period + i, 1, current))
         {
            return false;
         }
         sum += current[0];
      }
      int bufferIndex = totalBars - 1 - period;
      _buffer[bufferIndex] = sum;
      val = _buffer[bufferIndex];
      return true;
   }
};