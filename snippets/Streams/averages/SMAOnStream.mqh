#include <Streams/AOnStream.mqh>
//SMAOnStream v4.0

class SmaOnStream : public AOnStream
{
   double _length;
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double summ = 0;
      for (int i = 0; i < _length; ++i)
      {
         double price[1];
         if (!_source.GetSeriesValues(period + i, 1, price))
            return false;
         summ += price[0];
      }
      val = summ / _length;
      return true;
   }
};