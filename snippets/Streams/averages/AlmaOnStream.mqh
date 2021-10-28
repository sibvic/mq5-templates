#include <streams/AOnStream.mqh>

// ALMA on stream v1.0

#ifndef AlmaOnStream_IMP
#define AlmaOnStream_IMP

class ALMAOnStream : public AOnStream
{
   int _length;
   double _m;
   double _s;
public:
   ALMAOnStream(IStream *source, const int length, double offset, double sigma)
      :AOnStream(source)
   {
      _length = length;
      _m = MathFloor(offset * (_length - 1));
      _s = _length / sigma;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double sum = 0, wsum = 0;
      for (int i = 0; i < _length; i++)
      {
         double w = MathExp(-((i - _m) * (i - _m)) / (2 * _s * _s));
         wsum += w;
         double price[1];
         if (!_source.GetSeriesValues(period + (_length - 1 - i), 1, price))
            return false;
         sum += price[0] * w;
      }

      if (wsum != 0)
         val = sum / wsum;

      return true;
   }
};

#endif