// PolyLine object v1.0

class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
public:
   Polyline(string id, string collectionId, int window)
   {
      _refs = 1;
      _id = id;
      _window = window;
      _collectionId = collectionId;
   }
   ~Polyline()
   {
      if (ObjectFind(0, _id) >= 0)
      {
         ObjectDelete(0, _id);
      }
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
   
   void CopyTo(Polyline* line)
   {
      line._window = _window;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   void Redraw()
   {
      int totalBars = iBars(_Symbol, _Period);
      //if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
      
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
};