// Slope stream v1.0

#ifndef SlopeStream_IMP
#define SlopeStream_IMP

class SlopeStream : public AOnStream
{
public:
   SlopeStream(IStream* stream)
      :AOnStream(stream)
   {

   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      double buffer[];
      ArrayResize(buffer, count + 1);
      if (!_source.GetSeriesValues(period, count + 1, buffer))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = buffer[i + 1] - buffer[i];
      }
      return true;
   }
};

#endif