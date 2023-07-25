#include <Streams/AOnStream.mqh>
#include <Streams/SimplePriceStream.mqh>
#include <enums/PriceType.mqh>

// Lowest bars stream v1.0

class LowestBarsStream : public AOnStream
{
   int _loopback;
   double _values[];
public:
   LowestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }
   LowestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
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