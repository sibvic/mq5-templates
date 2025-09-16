#ifndef ChartPoint_IMPL
#define ChartPoint_IMPL

// Chart point object v2.0

class ChartPoint
{
   int _refs;
   int _index;
   double _price;
public:
   ChartPoint(int index, double price)
   {
      _refs = 1;
      _index = index;
      _price = price;
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
   
   static ChartPoint* Create(int time, int index, double price)
   {
      if (time != INT_MIN)
      {
         return NULL;//not supported yet
      }
      return new ChartPoint(index, price);
   }
   
   static ChartPoint* FromIndex(int index, double price)
   {
      return new ChartPoint(index, price);
   }

   void CopyTo(ChartPoint* other)
   {
      other._index = _index;
      other._price = _price;
   }
   
   int GetIndex() { return _index; }
   double GetPrice() { return _price; }
private:
};

#endif