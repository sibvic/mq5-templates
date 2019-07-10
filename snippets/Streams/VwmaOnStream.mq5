// VwmaOnStream v1.0
class VwmaOnStream : public AOnStream
{
   IStream *_volumeSource;
   int _length;
public:
   VwmaOnStream(IStream *source, IStream *volumeSource, const int length)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      double price[1];
      double volume[1];
      double sumw = 0;
      double sum = 0;
      for (int k = 0; k < _length; k++)
      {
         if (!_source.GetValues(period + k, 1, price) || !_volumeSource.GetValues(period + k, 1, volume))
            return false;
         sumw += volume[0];
         sum += volume[0] * price[0];
      }
      val = sum / sumw;
      return true;
   }
};