#include <Streams/AOnStream.mqh>

// Cumulative on stream v1.1

#ifndef CumOnStream_IMP
#define CumOnStream_IMP

class CumOnStream : public AOnStream
{
   double _buffer[];
public:
   CumOnStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetValues(bufferIndex, 1, current))
         return false;
      
      if (period > totalBars - 1 && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + current[0];
      }
      else 
      {
         _buffer[bufferIndex] = current[0];
      }
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif