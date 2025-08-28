// Collection of polylines v1.0

#ifndef PolyLinesCollection_IMPL
#define PolyLinesCollection_IMPL

#include <PineScript/Objects/PolyLine.mqh>
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/ChartPoint.mqh>

class PolyLinesCollection
{
   string _id;
   ICustomTypeArray<Polyline*>* _array;
   static PolyLinesCollection* _collections[];
   static PolyLinesCollection* _all;
   static int _max;
   static uint _nextId;
public:
   static Polyline* Get(Polyline* PolyLine, int index)
   {
      if (PolyLine == NULL)
      {
         return NULL;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new PolyLinesCollection("");
         }
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Polyline* PolyLine)
   {
      if (PolyLine == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(PolyLine))
      {
         return;
      }
      PolyLinesCollection* collection = FindCollection(PolyLine.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(PolyLine);
   }

   static Polyline* Create(string id, ICustomTypeArray<ChartPoint*>* points, datetime dateId)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1);
      MqlDateTime date;
      TimeToStruct(dateId, date);
      uint currentId = _nextId;
      _nextId += 1;
      string polyLineId = id + "_" + IntegerToString(currentId);
      
      Polyline* polyLine = new Polyline(points, polyLineId, id, ChartWindowOnDropped());
      PolyLinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new PolyLinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(polyLine);
      _all.Add(polyLine);
      if (_all.Count() > _max)
      {
         Delete(_all.GetFirst());
      }
      polyLine.Release();
      return polyLine;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawPolyLines();
      }
   }
   
   static ICustomTypeArray<Polyline*>* GetArray()
   {
      return _all._array;
   }
private:
   PolyLinesCollection(string id)
   {
      _id = id;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }

   ~PolyLinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      delete _array;
      _array = new CustomTypeArray<Polyline*>(0, NULL);
   }
   
   int Count()
   {
      return _array.Size();
   }

   Polyline* GetFirst()
   {
      return _array.First();
   }

   Polyline* Get(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(index);
   }
   Polyline* GetByIndex(int index)
   {
      int size = _array.Size();
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array.Get(size - 1 - index);
   }
   
   int FindIndex(Polyline* polyline)
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         if (_array.Get(i) == polyline)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Polyline* polyline)
   {
      int index = FindIndex(polyline);
      if (index == -1)
      {
         return false;
      }
      _array.Remove(index);
      return true;
   }
   
   void Add(Polyline* polyline)
   {
      _array.Push(polyline);
   }

   void RedrawPolyLines()
   {
      for (int i = 0; i < _array.Size(); ++i)
      {
         _array.Get(i).Redraw();
      }
   }
   
   static void AddCollection(PolyLinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static PolyLinesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
PolyLinesCollection* PolyLinesCollection::_collections[];
PolyLinesCollection* PolyLinesCollection::_all;
int PolyLinesCollection::_max = 50;
uint PolyLinesCollection::_nextId = 0;
#endif