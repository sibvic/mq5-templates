// Divergence conditions v1.0

#ifndef DIVERGENCE_IMP
#define DIVERGENCE_IMP

enum DivergenceType
{
   DivergenceRegularBearish,
   DivergenceHiddenBearish,
   DivergenceRegularBullish,
   DivergenceHiddenBulish
};

class DivergencePattern : public ICondition
{
   IStream* _divergenceStream;
   IStream* _mainHighStream;
   IStream* _mainLowStream;
   DivergenceType _divergenceType;
public:
   DivergencePattern(IStream* divergenceStream, IStream* mainHighStream, IStream* mainLowStream, DivergenceType divergenceType)
   {
      _divergenceStream = divergenceStream;
      _divergenceStream.AddRef();
      _mainHighStream = mainHighStream;
      _mainHighStream.AddRef();
      _mainLowStream = mainLowStream;
      _mainLowStream.AddRef();
      _divergenceType = divergenceType;
   }

   ~DivergencePattern()
   {
      _divergenceStream.Release();
      _mainHighStream.Release();
      _mainLowStream.Release();
   }

#define DIVERGENCE_PEAK 1
#define DIVERGENCE_TROUGH -1
#define DIVERGENCE_NO 0

   virtual bool IsPass(const int period)
   {
      int type;
      double divergenceValue;
      if (!GetBarType(period, type, divergenceValue) || type == DIVERGENCE_NO)
      {
         return false;
      }

      int prevPeriod = period + 1;
      int prevType;
      double prevDivergenceValue;
      while (GetBarType(prevPeriod, prevType, prevDivergenceValue))
      {
         if (prevType != type)
         {
            prevPeriod++;
            continue;
         }
         if (type == DIVERGENCE_PEAK)
         {
            double peakHigh, prevPeakHigh;
            if (!_mainHighStream.GetValue(period + 2, peakHigh) || !_mainHighStream.GetValue(prevPeriod + 2, prevPeakHigh))
               return false;
            if (divergenceValue < prevDivergenceValue && peakHigh > prevPeakHigh)
               return _divergenceType == DivergenceRegularBearish;
            if (divergenceValue > prevDivergenceValue && peakHigh < prevPeakHigh)
               return _divergenceType == DivergenceHiddenBearish;
            return false;
         }
         double troughLow, prevTroughLow;
         if (!_mainLowStream.GetValue(period + 2, troughLow) || !_mainLowStream.GetValue(prevPeriod + 2, prevTroughLow))
            return false;
         if (divergenceValue > prevDivergenceValue && troughLow < prevTroughLow)
            return _divergenceType == DivergenceRegularBullish;
         if (divergenceValue < prevDivergenceValue && troughLow > prevTroughLow)
            return _divergenceType == DivergenceHiddenBulish;
         return false;
      }
      return false;
   }
private:
   bool GetBarType(const int period, int &type, double &val)
   {
      double divVal0, divVal1, divVal2, divVal3, divVal4;
      if (!_divergenceStream.GetValue(period, divVal0)
         || !_divergenceStream.GetValue(period + 1, divVal1)
         || !_divergenceStream.GetValue(period + 2, divVal2)
         || !_divergenceStream.GetValue(period + 3, divVal3)
         || !_divergenceStream.GetValue(period + 4, divVal4))
      {
         return false;
      }
      if (divVal2 >= divVal3 && divVal2 > divVal4 && divVal2 >= divVal1 && divVal2 > divVal0)
      {
         type = DIVERGENCE_PEAK;
         val = divVal2;
         return true;
      }
      if (divVal2 <= divVal3 && divVal2 < divVal4 && divVal2 <= divVal1 && divVal2 < divVal0)
      {
         type = DIVERGENCE_TROUGH;
         val = divVal2;
         return true;
      }
      type = DIVERGENCE_NO;
      return true;
   }
};

#endif