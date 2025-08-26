#include <Streams/AOnStream.mqh>
#include <Streams/AStreamBase.mqh>
#include <Streams/IBarStream.mqh>
#include <Streams/Averages/TrueRangeOnStream.mqh>
#include <Streams/Averages/EMAOnStream.mqh>
#include <Streams/CustomStream.mqh>
#include <Streams/Averages/RmaOnStream.mqh>
#include <Streams/BarStream.mqh>

// DMI stream v1.0

#ifndef DMIStream_IMP
#define DMIStream_IMP

class DMIOnStream : TIStream<double>
{
protected:
   IBarStream *_source;
   int _references;
   TrueRangeOnStream* tr;
   CustomStream* avgPlusDM;
   CustomStream* avgMinusDM;
   EMAOnStream* SmoothedDirectionalMovementPlus;
   EMAOnStream* SmoothedDirectionalMovementMinus;
   CustomStream* rmaSource;
   RmaOnStream* rma;
public:
   DMIOnStream(string symbol, ENUM_TIMEFRAMES timeframe, int diLength, int adxSmoothing)
   {
      _source = new BarStream(symbol, timeframe);
      Init(diLength, adxSmoothing);
   }
   
   DMIOnStream(IBarStream* stream, int diLength, int adxSmoothing)
   {
      _source = stream;
      _source.AddRef();
      Init(diLength, adxSmoothing);
   }
   
   void Init(int diLength, int adxSmoothing)
   {
      _references = 1;
      if (_source != NULL)
      {
         _source.AddRef();
         tr = new TrueRangeOnStream(_source);
         avgPlusDM = new CustomStream(tr);
         avgMinusDM = new CustomStream(tr);
         SmoothedDirectionalMovementPlus = new EMAOnStream(avgPlusDM, diLength);
         SmoothedDirectionalMovementMinus = new EMAOnStream(avgMinusDM, diLength);
         rmaSource = new CustomStream(tr);
         rma = new RmaOnStream(rmaSource, adxSmoothing);
      }
   }

   ~DMIOnStream()
   {
      _source.Release();
      tr.Release();
      avgPlusDM.Release();
      avgMinusDM.Release();
      SmoothedDirectionalMovementPlus.Release();
      SmoothedDirectionalMovementMinus.Release();
      rmaSource.Release();
      rma.Release();
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
   
   virtual bool GetValues(const int period, const int count, double &ADX[], double& DIPlus[], double& DIMinus[])
   {
      int totalBars = _source.Size();
      for (int i = 0; i < count; ++i)
      {
         double h, h1;
         if (!_source.GetHigh(period - i, h) || !_source.GetHigh(period - i - 1, h1))
         {
            return false;
         }
         double l, l1;
         if (!_source.GetLow(period - i, l) || !_source.GetLow(period - i - 1, l1))
         {
            return false;
         }
         double DirectionalMovementPlus = MathAbs(h - h1);
         double DirectionalMovementMinus = MathAbs(l - l1);
         if (DirectionalMovementPlus == DirectionalMovementMinus)
         {
            DirectionalMovementPlus = 0;
            DirectionalMovementMinus = 0;
         }
         else if (DirectionalMovementPlus < DirectionalMovementMinus)
         {
            DirectionalMovementPlus = 0;
         }
         else if (DirectionalMovementMinus < DirectionalMovementPlus)
         {
            DirectionalMovementMinus = 0;
         }
         double TR[1];
         if (!tr.GetValues(period - i, 1, TR))
         {
            return false;
         }
         avgPlusDM.SetValue(period - i, TR[0] == 0 ? 0 : 100 * DirectionalMovementPlus / TR[0]);
         avgMinusDM.SetValue(period - i, TR[0] == 0 ? 0 : 100 * DirectionalMovementMinus / TR[0]);
        
         double dip[1];
         double dim[1];
         if (!SmoothedDirectionalMovementPlus.GetValues(period - i, 1, dip) || !SmoothedDirectionalMovementMinus.GetValues(period - i, 1, dim))
         {
            return false;
         }
         
         double DX = (MathAbs(dip[0] - dim[0]) / (dip[0] + dim[0])) * 100;
         rmaSource.SetValue(period - i, DX);
         double adx[1];
         if (!rma.GetValues(period - i, 1, adx))
         {
            return false;
         }
         ADX[i] = adx[0];
         DIPlus[i] = dip[0];
         DIMinus[i] = dim[0];
      }
      return true;
   }
};

#endif