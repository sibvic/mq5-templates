#include <AOnStream.mq5>

//RmaOnStream v2.0
class RmaOnStream : public AOnStream
{
   double _alpha;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      _buffer[size - 1 - period] = _alpha * price[0] + (1 - _alpha) * (price[0] - _buffer[size - 1 - period - 1]);
      val = _buffer[size - 1 - period];
      return true;
   }
};