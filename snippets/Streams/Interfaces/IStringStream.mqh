// String array stream v1.0

interface IStringStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, string &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, string &val[]) = 0;
};