#ifndef ChartPoint_IMPL
#define ChartPoint_IMPL

// Chart point object v1.0

class ChartPoint
{
   int _refs;
public:
   ChartPoint()
   {
      _refs = 1;
   }
   ~ChartPoint()
   {
   }
   
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   static ChartPoint* Create()
   {
      return new ChartPoint();
   }

   void CopyTo(ChartPoint* other)
   {
   }
private:
};

#endif