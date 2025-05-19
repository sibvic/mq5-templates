#include <AOnStream.mqh>

//AbsStream v2.0
class AbsStream : public AOnStream
{
public:
   AbsStream(TIStream<double> *source)
      :AOnStream(source)
   {
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetSeriesValues(period, 1, price))
      {
         return false;
      }
      val = MathAbs(price[0]);
      return true;
   }
};
