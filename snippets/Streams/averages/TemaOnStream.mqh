#include <Streams/AOnStream.mqh>
// TemaOnStream v2.0

class TemaOnStream : public AOnStream
{
   double _alpha;
   double _buffer1[];
   double _buffer2[];
   double _buffer3[];
public:
   TemaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      int size = Size();
      if (ArrayRange(_buffer1, 0) < size) 
         ArrayResize(_buffer1, size);
      if (ArrayRange(_buffer2, 0) < size) 
         ArrayResize(_buffer2, size);
      if (ArrayRange(_buffer3, 0) < size) 
         ArrayResize(_buffer3, size);

      _buffer1[size - 1 - period] = _buffer1[size - 1 - period - 1] + _alpha * (price[0] - _buffer1[size - 1 - period - 1]);
      _buffer2[size - 1 - period] = _buffer2[size - 1 - period - 1] + _alpha * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period - 1]);
      _buffer3[size - 1 - period] = _buffer3[size - 1 - period - 1] + _alpha * (_buffer2[size - 1 - period] - _buffer3[size - 1 - period - 1]);
      val = (_buffer3[size - 1 - period] + 3.0 * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period]));
      return true;
   }
};