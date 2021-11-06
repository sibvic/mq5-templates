// VolumeStream v1.1

class VolumeStream : public AStream
{
public:
   VolumeStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iVolume(_symbol, _timeframe, period + i);
      }
      return true;
   }
};