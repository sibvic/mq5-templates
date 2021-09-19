#include <AOnStream.mq5>

//ChangeStream v1.0
class ChangeStream : public AOnStream
{
public:
   ChangeStream(IStream *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period < 1)
      {
         return false;
      }
      int size = Size();
      double price[2];
      if (!_source.GetSeriesValues(period, 2, price))
      {
         return false;
      }
      val = price[0] - price[1];
      return true;
   }
};
