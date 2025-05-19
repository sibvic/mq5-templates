#ifndef CorrelationStream_IMP
#define CorrelationStream_IMP
// Correlation stream v2.0

#include <Streams/AOnStream.mqh>
#include <Streams/Averages/SMAOnStream.mqh>

class CorrelationStream : public AOnStream
{
   SmaOnStream *xx_ma;
   SmaOnStream *yy_ma;
   TIStream<double> *_source2;
   int _length;
public:
   CorrelationStream(TIStream<double> *source1, TIStream<double> *source2, int length)
      :AOnStream(source1)
   {
      xx_ma = new SmaOnStream(source1, length);
      yy_ma = new SmaOnStream(source2, length);
      _length = length;
      _source2 = source2;
      _source2.AddRef();
   }
   
   ~CorrelationStream()
   {
      _source2.Release();
      xx_ma.Release();
      yy_ma.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double xx_ma_val[1];
      if (!xx_ma.GetValues(period, 1, xx_ma_val))
      {
         return false;
      }
      double yy_ma_val[1];
      if (!yy_ma.GetValues(period, 1, yy_ma_val))
      {
         return false;
      }
      double xx = 0;
      double yy = 0;
      double xy = 0;
      for (int i = 0; i < _length; ++i)
      {
         double value1[1];
         if (!_source.GetValues(period + i, 1, value1))
         {
            continue;
         }
         double value2[1];
         if (!_source2.GetValues(period + i, 1, value2))
         {
            continue;
         }
         xx += MathPow(value1[0] - xx_ma_val[0], 2);
         yy += MathPow(value2[0] - yy_ma_val[0], 2);
         xy += (value1[0] - xx_ma_val[0]) * (value2[0] - yy_ma_val[0]);
      }
      double xx_yy_sqrt = MathSqrt(xx * yy);
      if (xx_yy_sqrt == 0)
      {
         return 0;
      }
      val = xy / xx_yy_sqrt;

      return true;
   }
};

#endif