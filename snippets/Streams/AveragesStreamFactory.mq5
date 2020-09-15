#include <SMAOnStream.mq5>
#include <TemaOnStream.mq5>
#include <VwmaOnStream.mq5>
#include <HullOnStream.mq5>
#include <RmaOnStream.mq5>
#include <DEMAOnStream.mq5>

// AveragesStreamFactory v1.2
enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   //ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   ma_dema,    // Double exponential moving average - DEMA
   ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   //ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_rma,       // RMA
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   //ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo     // Smoother
};

class AveragesStreamFactory
{
public:
   static IStream* Create(MATypes method, IStream* source, IStream* volumeSource, int period)
   {
      switch (method)
      {
         case ma_sma:
            return new SMAOnStream(source, period);
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
      }
      return NULL;
   }
};