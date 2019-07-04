// Stream v.1.2
interface IStream
{
public:
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

class StreamPack : public IStream
{
   IStream *_main;
   IStream *_secondary[];
public:
   StreamPack(IStream *main)
   {
      _main = main;
   }

   ~StreamPack()
   {
      delete _main;
      int count = ArrayRange(_secondary, 0);
      for (int i = 0; i < count; ++i)
      {
         delete _secondary[i];
      }
   }

   void Add(IStream *stream)
   {
      int count = ArrayRange(_secondary, 0);
      ArrayResize(_secondary, count + 1);
      _secondary[count] = stream;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return _main.GetValues(period, count, val);
   }

   virtual int Size()
   {
      return _main.Size();
   }
};

class AStream : public IStream
{
protected:
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;

   AStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe)
   {
      _shift = 0.0;
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbolInfo.GetSymbol(), _timeframe);
   }
};

class PriceStream : public AStream
{
   ENUM_APPLIED_PRICE _price;
public:
   PriceStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :AStream(symbolInfo, timeframe)
   {
      _price = price;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(symbol, _timeframe, period + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(symbol, _timeframe, period + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(symbol, _timeframe, period + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(symbol, _timeframe, period + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i) + iClose(symbol, _timeframe, period + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i) + iClose(symbol, _timeframe, period + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _symbolInfo.GetPipSize();
      }
      return true;
   }
};

class VolumeStream : public AStream
{
public:
   VolumeStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbolInfo, timeframe)
   {
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iVolume(symbol, _timeframe, period + i);
      }
      return true;
   }
};

class LowestPriceStream : public AStream
{
   int _periods;
public:
   LowestPriceStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe, int periods)
      :AStream(symbolInfo, timeframe)
   {
      _periods = periods;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iLowest(symbol, _timeframe, MODE_LOW, _periods, period);
      }
      return true;
   }
};

class HighestPriceStream : public AStream
{
   int _periods;
public:
   HighestPriceStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe, int periods)
      :AStream(symbolInfo, timeframe)
   {
      _periods = periods;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iHighest(symbol, _timeframe, MODE_HIGH, _periods, period);
      }
      return true;
   }
};