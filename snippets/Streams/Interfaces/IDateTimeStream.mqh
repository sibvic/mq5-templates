// Boolean Stream v.1.0

#ifndef IDateTimeStream_IMPL
#define IDateTimeStream_IMPL

interface IDateTimeStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, datetime &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, datetime &val[]) = 0;
};

#endif