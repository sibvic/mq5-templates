// VolumeStream v1.2
#include <Streams/Abstract/AIntStream.mqh>

#ifndef VolumeStream_IMPL
#define VolumeStream_IMPL

class VolumeStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   VolumeStream(string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - 1 - period, count, val);
   }
   
   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, int &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = iVolume(_symbol, _timeframe, period + i);
      }
      return true;
   }
};

#endif