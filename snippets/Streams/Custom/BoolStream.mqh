#ifndef BoolStream_IMPL
#define BoolStream_IMPL

#include <Streams/Custom/TStream.mqh>
// Bool stream v3.0

class BoolStream : public TStream<int>
{
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = -1)
      : TStream<int>(symbol, timeframe, emptyValue)
   {
   }
};

#endif