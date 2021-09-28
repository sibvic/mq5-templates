#include <Streams/AOnStream.mqh>

//RmaOnStream v2.1
class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price[0];
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price[0]) / _length;
      }
      val = _buffer[index];
      return true;
   }
};
