#include <Streams/averages/SMAOnStream.mqh>
#include <Streams/averages/TemaOnStream.mqh>
#include <Streams/averages/VwmaOnStream.mqh>
#include <Streams/averages/HullOnStream.mqh>
#include <Streams/averages/RmaOnStream.mqh>
#include <Streams/averages/DEMAOnStream.mqh>
#include <Streams/averages/LinearRegressionOnStream.mqh>
#include <Streams/averages/EMAOnStream.mqh>
#include <enums/MATypes.mqh>

// AveragesStreamFactory v1.2

class AveragesStreamFactory
{
public:
   static IStream* Create(MATypes method, IStream* source, IStream* volumeSource, int period)
   {
      switch (method)
      {
         case ma_sma:
            return new SmaOnStream(source, period);
         case ma_ema:
            return new EMAOnStream(source, period);
         case ma_tema:
            return new TemaOnStream(source, period);
         case ma_vwma:
            return new VwmaOnStream(source, volumeSource, period);
         case ma_hull:
            return new HullOnStream(source, period);
         case ma_rma:
            return new RmaOnStream(source, period);
         case ma_dema:
            return new DEMAOnStream(source, period);
         case ma_linr:
            return new LinearRegressionOnStream(source, period);
      }
      return NULL;
   }
};