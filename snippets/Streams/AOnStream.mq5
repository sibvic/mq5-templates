//AOnStream v1.0
class AOnStream : public IStream
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
   {
      _source = source;
   }

   virtual bool GetValue(const int period, double &val) = 0;

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};