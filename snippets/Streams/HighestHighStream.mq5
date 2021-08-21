// Highest high stream v1.0

#include <AOnStream.mq5>

class HighestHighStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      ArrayResize(_values, loopback);
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      val = _values[0];

      for (int i = 1; i < _loopback; ++i)
      {
         val = MathMax(val, _values[i]);
      }
      return true;
   }
};