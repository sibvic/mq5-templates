#include <Streams/AOnStream.mqh>
#include <Streams/SimplePriceStream.mqh>
#include <enums/PriceType.mqh>

// Highest bars stream v1.1

class HighestBarsStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   HighestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }
   HighestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      int index = 0;
      double current = _values[0];
      for (int i = 1; i < _loopback; ++i)
      {
         if (current < _values[i])
         {
            current = _values[i];
            index = i;
         }
      }
      val = index;
      return true;
   }
};