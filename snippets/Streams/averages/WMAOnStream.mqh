// WMA on stream v1.1

#include <Streams/AOnStream.mqh>
#include <Streams/StreamBuffer.mqh>

class WMAOnStream : public AOnStream
{
   int _length;
   double _k;
   StreamBuffer _buffer;
public:
   WMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _k = 1.0 / (_length);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      _buffer.EnsureSize(totalBars);
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current[1];
      if (!_source.GetSeriesValues(period, 1, current))
      {
         return false;
      }
      
      double last = _buffer._data[bufferIndex - 1] != EMPTY_VALUE ? _buffer._data[bufferIndex - 1] : current[0];

      _buffer._data[bufferIndex] = (current[0] - last) * _k + last;
      val = _buffer._data[bufferIndex];
      return true;
   }
};