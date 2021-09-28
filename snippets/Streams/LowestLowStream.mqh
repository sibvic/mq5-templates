#include <Streams/AOnStream.mqh>

// Lowest low stream v1.1

class LowestLowStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
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
         val = MathMin(val, _values[i]);
      }
      return true;
   }
};