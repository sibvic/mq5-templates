#include <ACustomBarStream.mqh>
#include <../InstrumentInfo.mqh>

// Renko stream v1.0

#ifndef RenkoStream_IMP
#define RenkoStream_IMP

enum RenkoMode
{
   RenkoTraditional, // Traditional
   RenkoATR // ATR
};

class RenkoStream : public ACustomBarStream
{
   int _barsLimit;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _step;
   RenkoMode _mode;
   int _lastDirection;
   double _initialPrice;
   InstrumentInfo _instrument;
   int _atr;
public:
   RenkoStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int barsLimit)
      :_instrument(symbol)
   {
      _barsLimit = barsLimit;
      _symbol = symbol;
      _timeframe = timeframe;
      _lastDirection = 0;
      _initialPrice = 0;
      _atr = 0;
   }

   ~RenkoStream()
   {
      if (_atr != 0)
      {
         IndicatorRelease(_atr);
      }
   }

   bool SetStep(const RenkoMode mode, const double step)
   {
      _mode = mode;
      if (_mode != RenkoATR)
      {
         _step = _instrument.RoundRate(step * _instrument.GetPipSize());
         _atr = 0;
         return _step != 0;
      }
      _atr = iATR(_symbol, _timeframe, (int)step);
      _step = step;
      return true;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
      {
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);
      }
      start = MathMin(_barsLimit, start);

      for (int i = start; i >= 0; --i)
      {
         if (_initialPrice == 0 || _size == 0)
         {
            calcFirstValueValue(i);
            continue;
         }
         double diff = _instrument.RoundRate(_close[_size - 1] - _open[_size - 1]);
         if (diff > 0 || (diff == 0 && _lastDirection == 1))
         {
            HandleUp(i);
         }
         if (diff < 0 || (diff == 0 && _lastDirection == -1))
         {
            HandleDown(i);
         }
      }
   }
private:

   bool GetStep(const int period, double &step)
   {
      if (_mode == RenkoATR)
      {
         double atrValue[1];
         if (CopyBuffer(_atr, 0, period, 1, atrValue) != 1)
         {
            return false;
         }
         if (atrValue[0] == EMPTY_VALUE)
            return false;
         step = _instrument.RoundRate(atrValue[0]);
         return step != 0.0;
      }
      
      step = _step;
      return step != 0;
   }

   void AddBar(datetime date)
   {
      ++_size;
      ArrayResize(_dates, _size);
      ArrayResize(_open, _size);
      ArrayResize(_high, _size);
      ArrayResize(_low, _size);
      ArrayResize(_close, _size);
      if (_size == 1)
         _dates[_size - 1] = date;
      else if (_dates[_size - 2] >= date)
         _dates[_size - 1] = _dates[_size - 2] + 1;
      else
         _dates[_size - 1] = date;
   }

   void calcFirstValueValue(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      double price = iClose(_symbol, _timeframe, period);
      if (_initialPrice == 0.0)
      {
         _initialPrice = price;
         return;
      }
      datetime date = iTime(_symbol, _timeframe, period);
      double openVal = _instrument.RoundRate(MathFloor(_initialPrice / step) * step);
      if (price > _instrument.RoundRate(openVal + step))
      {
         while (price > _instrument.RoundRate(openVal + step))
         {
            AddBar(date);
            _open[_size - 1] = openVal;
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
            _low[_size - 1] = _open[_size - 1];
            _high[_size - 1] = _close[_size - 1];
            openVal = _instrument.RoundRate(openVal + step);
         }
         _lastDirection = 1;
         return;
      }
      
      while (price < _instrument.RoundRate(openVal - step))
      {
         AddBar(date);
         _open[_size - 1] = openVal;
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
         _high[_size - 1] = _open[_size - 1];
         _low[_size - 1] = _close[_size - 1];
         openVal = _instrument.RoundRate(openVal - step);
      }
      _lastDirection = -1;
   }
   void HandleUp(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      
      double price = iClose(_symbol, _timeframe, period);
      datetime date = iTime(_symbol, _timeframe, period);
      _lastDirection = 1;
      while (price > _instrument.RoundRate(_close[_size - 1] + step))
      {
         AddBar(date);
         _open[_size - 1] = _close[_size - 2];
         _low[_size - 1] = _open[_size - 1];
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
         _high[_size - 1] = _close[_size - 1];
      }
      double doubleStep = _instrument.RoundRate(step * 2);
      if (price < _instrument.RoundRate(_close[_size - 1] - doubleStep))
      {
         while (price < _instrument.RoundRate(_close[_size - 1] - step))
         {
            AddBar(date);
            if (_close[_size - 2] > _open[_size - 2])
            {
               _open[_size - 1] = _instrument.RoundRate(_close[_size - 2] - step);
            }
            else
            {
               _open[_size - 1] = _close[_size - 2];
            }
            _high[_size - 1] = _open[_size - 1];
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
            _low[_size - 1] = _close[_size - 1];
         }
      }
   }

   void HandleDown(const int period)
   {
      double step;
      if (!GetStep(period, step))
         return;
      
      double price = iClose(_symbol, _timeframe, period);
      datetime date = iTime(_symbol, _timeframe, period);
      _lastDirection = -1;
      while (price < _instrument.RoundRate(_close[_size - 1] - step))
      {
         AddBar(date);
         _open[_size - 1] = _close[_size - 2];
         _high[_size - 1] = _open[_size - 1];
         _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] - step);
         _low[_size - 1] = _close[_size - 1];
      }
      double doubleStep = _instrument.RoundRate(step * 2);
      if (price > _instrument.RoundRate(_close[_size - 1] + doubleStep))
      {
         while (price > _instrument.RoundRate(_close[_size - 1] + step))
         {
            AddBar(date);
            if (_close[_size - 2] < _open[_size - 2])
            {
               _open[_size - 1] = _instrument.RoundRate(_close[_size - 2] + step);
            }
            else
            {
               _open[_size - 1] = _close[_size - 2];
            }
            _low[_size - 1] = _open[_size - 1];
            _close[_size - 1] = _instrument.RoundRate(_open[_size - 1] + step);
            _high[_size - 1] = _close[_size - 1];
         }
      }
   }
};

#endif