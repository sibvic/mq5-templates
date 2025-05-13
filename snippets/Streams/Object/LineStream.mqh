// Label stream v1.0

#ifndef LineStream_IMPL
#define LineStream_IMPL

#include <Streams/Custom/TStream.mqh>
#include <PineScript/Objects/Line.mqh>

class LineStream : public TStream<Line*>
{
public:
   LineStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : TStream<Line*>(symbol, timeframe, NULL)
   {
   }
};
#endif