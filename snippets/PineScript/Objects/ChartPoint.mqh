#ifndef ChartPoint_IMPL
#define ChartPoint_IMPL

// Chart point object v1.1

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
   
   static ChartPoint* Create()
   {
      return new ChartPoint(0, 0);
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