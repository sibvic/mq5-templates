#include <enums/PriceType.mqh>
#include <streams/AStream.mqh>
#include <streams/IBarStream.mqh>

// PriceStream v2.1

class PriceStream : public IStream
{
   ENUM_APPLIED_PRICE _price;
   IBarStream* _source;
   int _references;
public:
   PriceStream(IBarStream* source, const ENUM_APPLIED_PRICE __price)
   {
      _source = source;
      _source.AddRef();
      _price = __price;
      _references = 1;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PRICE_CLOSE:
               if (!_source.GetClose(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_OPEN:
               if (!_source.GetOpen(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_HIGH:
               if (!_source.GetHigh(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_LOW:
               if (!_source.GetLow(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_MEDIAN:
               {
                  double high, low;
                  if (!_source.GetHighLow(period + i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PRICE_TYPICAL:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PRICE_WEIGHTED:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         }
         values[i] = val;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = Size();
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

