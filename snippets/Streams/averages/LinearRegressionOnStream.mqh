#include <Streams/AOnStream.mqh>
//LinearRegressionOnStream v1.0

class LinearRegressionOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   LinearRegressionOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period < 0)
      {
         return false;
      }
      int size = Size();
      int index = size - 1 - period;
      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
      {
         return false;
      }
      if (index < _length)
      {
         _buffer[index] = price[0];
         return false;
      }

      double lwmw = _length;
      double lwma = lwmw * price[0];
      double sma  = price[0];
      for (int i = 0; i < _length; ++i)
      {
         double weight = _length - i;
         lwmw += weight;
         lwma += weight * _buffer[index - i];  
         sma += _buffer[index - i];
      }
      _buffer[index] = (3.0 * lwma / lwmw - 2.0 * sma / _length);
      val = _buffer[index];
      return true;
   }
};