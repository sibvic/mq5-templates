#include <Streams/AStreamBase.mqh>
#include <Streams/IBarStream.mqh>
#include <Streams/Averages/TrueRangeOnStream.mqh>
#include <Streams/Averages/SMAOnStream.mqh>
#include <Streams/BarStream.mqh>

// Supertrend on stream v1.0

#ifndef SupertrendOnStream_IMP
#define SupertrendOnStream_IMP

class SupertrendOnStream : TIStream<double>
{
protected:
   IBarStream *_source;
   int _references;
   int _atrPeriod;
   TrueRangeOnStream* _tr;
   SmaOnStream* _atr;
   double _upperBand[];
   double _lowerBand[];
   double _supertrend[];
   double _direction[];
public:
   SupertrendOnStream(string symbol, ENUM_TIMEFRAMES timeframe, int atrPeriod)
   {
      _source = new BarStream(symbol, timeframe);
      Init(atrPeriod);
   }

   SupertrendOnStream(IBarStream* stream, int atrPeriod)
   {
      _source = stream;
      _source.AddRef();
      Init(atrPeriod);
   }

   void Init(int atrPeriod)
   {
      _references = 1;
      _atrPeriod = atrPeriod;
      if (_source != NULL)
      {
         _source.AddRef();
         _tr = new TrueRangeOnStream(_source);
         _atr = new SmaOnStream(_tr, _atrPeriod);
      }
   }

   ~SupertrendOnStream()
   {
      _source.Release();
      _tr.Release();
      _atr.Release();
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

   virtual int Size()
   {
      return _source.Size();
   }

   virtual bool GetValue(const int period, double &val)
   {
      return false;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return false;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return false;
   }

   virtual bool GetValues(const int period, const double factor, const int count, double &supertrend[], double &direction[])
   {
      EnsureSize();
      for (int i = 0; i < count; ++i)
      {
         int p = period - i;
         if (!ComputeTo(p, factor))
         {
            return false;
         }
         supertrend[i] = _supertrend[p];
         direction[i] = _direction[p];
      }
      return true;
   }

private:
   void EnsureSize()
   {
      int totalBars = _source.Size();
      if (ArrayRange(_upperBand, 0) != totalBars)
      {
         ArrayResize(_upperBand, totalBars);
         ArrayResize(_lowerBand, totalBars);
         ArrayResize(_supertrend, totalBars);
         ArrayResize(_direction, totalBars);
         ArrayInitialize(_upperBand, EMPTY_VALUE);
         ArrayInitialize(_lowerBand, EMPTY_VALUE);
         ArrayInitialize(_supertrend, EMPTY_VALUE);
         ArrayInitialize(_direction, EMPTY_VALUE);
      }
   }

   bool ComputeBar(const int p, const double factor)
   {
      double h, l, c;
      if (!_source.GetHigh(p, h) || !_source.GetLow(p, l) || !_source.GetClose(p, c))
      {
         return false;
      }

      double atrVal[1];
      if (!_atr.GetValues(p, 1, atrVal))
      {
         return false;
      }

      double src = (h + l) / 2.0;
      double upperBand = src + factor * atrVal[0];
      double lowerBand = src - factor * atrVal[0];
      int totalBars = _source.Size();

      if (p < totalBars - 1)
      {
         double prevClose;
         if (!_source.GetClose(p + 1, prevClose))
         {
            return false;
         }
         double prevLowerBand = _lowerBand[p + 1];
         double prevUpperBand = _upperBand[p + 1];
         lowerBand = (lowerBand > prevLowerBand || prevClose < prevLowerBand) ? lowerBand : prevLowerBand;
         upperBand = (upperBand < prevUpperBand || prevClose > prevUpperBand) ? upperBand : prevUpperBand;
      }

      double dir;
      if (p >= totalBars - 1)
      {
         dir = 1;
      }
      else
      {
         double prevSupertrend = _supertrend[p + 1];
         double prevUpperBand = _upperBand[p + 1];
         if (prevSupertrend == prevUpperBand)
         {
            dir = c > upperBand ? -1 : 1;
         }
         else
         {
            dir = c < lowerBand ? 1 : -1;
         }
      }

      _upperBand[p] = upperBand;
      _lowerBand[p] = lowerBand;
      _direction[p] = dir;
      _supertrend[p] = dir == -1 ? lowerBand : upperBand;
      return true;
   }

   bool ComputeTo(const int period, const double factor)
   {
      int totalBars = _source.Size();
      for (int p = totalBars - 1; p >= period; --p)
      {
         if (_supertrend[p] == EMPTY_VALUE)
         {
            if (!ComputeBar(p, factor))
            {
               return false;
            }
         }
      }
      return true;
   }
};

#endif
