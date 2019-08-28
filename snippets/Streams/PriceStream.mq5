// PriceStream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

#include <ABaseStream.mq5>
class PriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   PriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;
      double point = MarketInfo(symbol, MODE_POINT);
      int digits = (int)MarketInfo(symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbol;
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
         val[i] += _shift * _pipSize;
      }
      return true;
   }
};

#endif