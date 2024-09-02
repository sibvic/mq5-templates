#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0

#include <Streams/PriceStream.mqh>
#include <Streams/BarStream.mqh>

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif