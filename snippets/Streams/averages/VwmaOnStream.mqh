#include <Streams/AOnStream.mqh>
#include <Streams/SimplePriceStream.mqh>
#include <Enums/PriceType.mqh>
// VwmaOnStream v2.1
class VwmaOnStream : public AOnStream
{
   IStream *_volumeSource;
   int _length;
public:
   VwmaOnStream(IStream *source, IStream *volumeSource, const int length)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _volumeSource.AddRef();
      _length = length;
   }

   VwmaOnStream(string symbol, ENUM_TIMEFRAMES timeframe, IStream *source, const int length)
      :AOnStream(source)
   {
      _volumeSource = new SimplePriceStream(symbol, timeframe, PriceVolume);
      _length = length;
   }

   ~VwmaOnStream()
   {
      _volumeSource.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double price[1];
      double volume[1];
      double sumw = 0;
      double sum = 0;
      for (int k = 0; k < _length; k++)
      {
         if (!_source.GetSeriesValues(period + k, 1, price) || !_volumeSource.GetSeriesValues(period + k, 1, volume))
            return false;
         sumw += volume[0];
         sum += volume[0] * price[0];
      }
      val = sum / sumw;
      return true;
   }
};