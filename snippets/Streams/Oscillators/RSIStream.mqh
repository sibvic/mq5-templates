#include <Streams/AOnStream.mqh>
#include <Streams/ChangeStream.mqh>

// RSI stream v1.0

class RSIStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSIStream(IStream* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      if (period == totalBars - 1 || _pos[period + 1])
      {
         double diff[];
         ArrayResize(diff, _period);
         if (!_source.GetSeriesValues(period, _period, diff))
         {
            return false;
         }
         for (int i = 0; i < _period; ++i)
         {
            if (diff[i] >= 0)
            {
               sump = sump + diff[i];
            }
            else
            {
               sumn = sumn - diff[i];
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         double diff[1];
         if (!_source.GetValue(period, 1, diff))
         {
            return false;
         }
         if (diff[0] > 0)
         {
            sump = diff[0];
         }
         else
         {
            sumn = -diff[0];
         }
         positive = (_pos[period + 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period + 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};
