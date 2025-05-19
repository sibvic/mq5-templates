#include <Streams/Abstract/AIntStream.mqh>
#include <Streams/SimplePriceStream.mqh>
#include <enums/PriceType.mqh>

// Lowest bars stream v3.0

class LowestBarsStream : public AIntStream
{
   int _loopback;
   double _values[];
   TIStream<double> *_source;
public:
   LowestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }
   LowestBarsStream(TIStream<double>* source, int loopback)
   {
      _source = NULL;
      _loopback = loopback;
      ArrayResize(_values, loopback);
   }
   ~LowestBarsStream()
   {
      if (_source != NULL)
      {
         _source.Release();
      }
   }

   bool GetSeriesValue(const int period, int &val)
   {
      if (!_source.GetSeriesValues(period, _loopback, _values))
      {
         return false;
      }
      int index = 0;
      double current = _values[0];
      for (int i = 1; i < _loopback; ++i)
      {
         if (current < _values[i])
         {
            current = _values[i];
            index = i;
         }
      }
      val = index;
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, int &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         int v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};