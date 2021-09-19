#include <../AOnStream.mqh>
#include <../ChangeStream.mqh>

//RSIOnStream v1.0
class RSIOnStream : public AOnStream
{
   double _length;
   ChangeStream* change;
   double pos[];
   double neg[];
public:
   RSIOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      change = new ChangeStream(source);
   }

   ~RSIOnStream()
   {
      change.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      double diff[1];
      if (!change.GetSeriesValues(period, 1, diff))
         return false;

      bool first = ArrayRange(pos, 0) == 0;
      if (ArrayRange(pos, 0) < size) 
      {
         ArrayResize(pos, size);
         ArrayResize(neg, size);
      }

      int i = 0;
      double sump = 0;
      double sumn = 0;
      double positive = 0;
      double negative = 0;
      int index = size - 1 - period;
      if (first)
      {
         for (int i = 0; i < _length; ++i)
         {
            if (!change.GetSeriesValues(period + i, 1, diff))
            {
               continue;
            }
            if (diff[0] >= 0)
            {
               sump = sump + diff[0];
            }
            else
            {
               sumn = sumn - diff[0];
            }
         }
         positive = sump / _length;
         negative = sumn / _length;
      }
      else
      {
         if (!change.GetSeriesValues(period, 1, diff))
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
         positive = (pos[index - 1] * (_length - 1) + sump) / _length;
         negative = (neg[index - 1] * (_length - 1) + sumn) / _length;
      }
      pos[index] = positive;
      neg[index] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};