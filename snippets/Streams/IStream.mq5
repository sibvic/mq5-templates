// IStream v.1.2
interface IStream
{
public:
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};