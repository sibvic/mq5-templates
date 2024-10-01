// Color Stream v.1.0

#ifndef IColorStream_IMPL
#define IColorStream_IMPL

interface IColorStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, uint &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, uint &val[]) = 0;
};

#endif