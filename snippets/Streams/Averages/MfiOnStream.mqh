// MFI on stream v1.0

#ifndef MfiOnStream_IMP
#define MfiOnStream_IMP
#include <Streams/AOnStream.mqh>

class MfiOnStream : public AOnStream
{
   int _length;
public:
   MfiOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      return GetValue(Size() - period - 1, val);
   }
private:
   bool GetValue(const int period, double &val)
   {
      double current[1];
      if (!_source.GetValues(period, 1, current))
      {
         return false;
      }
      int oldPos = Size() - period - 1;
      double upper = 0;
      double lower = 0;
      for (int i = 0; i < _length; i++)
      {
         double prev[1];
         if (!_source.GetValues(period - i - 1, 1, prev))
         {
            continue;
         }
         if (prev[0] - current[0] >= 0)
         {
            upper += current[0] * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + i);
         }
         else
         {
            lower += current[0] * iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + i);
         }
         current[0] = prev[0];
      }
      if (lower == 0)
      {
         val = 100.0;
         return true;
      }
      val = 100.0 - (100.0 / (1.0 + upper / lower));
      return true;
   }
};

#endif