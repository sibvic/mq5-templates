#include <../AOnStream.mqh>
#include <RmaOnStream.mqh>
#include <../ChangeStream.mqh>
#include <../AbsStream.mqh>

//TSIOnStream v1.0
class TSIOnStream : public AOnStream
{
   double _length;
   ChangeStream* delta;
   AbsStream* absDelta;
   RmaOnStream* ema_r1;
   RmaOnStream* ema_r2;
   RmaOnStream* ema_s1;
   RmaOnStream* ema_s2;
public:
   TSIOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      delta = new ChangeStream(source);
      absDelta = new AbsStream(delta);
      ema_r1 = new RmaOnStream(delta, length);
      ema_r2 = new RmaOnStream(absDelta, length);
      ema_s1 = new RmaOnStream(ema_r1, length);
      ema_s2 = new RmaOnStream(ema_r2, length);
   }

   ~TSIOnStream()
   {
      delta.Release();
      absDelta.Release();
      ema_r1.Release();
      ema_r2.Release();
      ema_s1.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      double s2[1];
      if (!ema_s2.GetSeriesValues(period, 1, s2))
      {
         return false;
      }
      double s1[1];
      if (!ema_s1.GetSeriesValues(period, 1, s1))
      {
         return false;
      }
      val = s2[0] == 0 ? 0 : 100 * s1[0] / s2[0];
      return true;
   }
};