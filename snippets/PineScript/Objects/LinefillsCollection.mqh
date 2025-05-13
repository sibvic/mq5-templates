// Collection of Linefills v1.2

#ifndef LinefillsCollection_IMPL
#define LinefillsCollection_IMPL

#include <PineScript/Objects/LineFill.mqh>

class LinefillsCollection
{
   string _id;
   LineFill* _linefills[];
   static LinefillsCollection* _collections[];
   static LinefillsCollection* _all;
public:
   LinefillsCollection(string id)
   {
      _id = id;
   }
   
   ~LinefillsCollection()
   {
      ClearCollection();
   }
   
   void ClearCollection()
   {
      for (int i = 0; i < ArraySize(_linefills); ++i)
      {
         delete _linefills[i];
      }
      ArrayResize(_linefills, 0);
   }
   
   string GetId()
   {
      return _id;
   }
   
   int Count()
   {
      return ArraySize(_linefills);
   }
   
   LineFill* GetFirst()
   {
      return _linefills[0];
   }
   
   LineFill* Get(int index)
   {
      int size = ArraySize(_linefills);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _linefills[index];
   }
   LineFill* GetByIndex(int index)
   {
      int size = ArraySize(_linefills);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _linefills[size - 1 - index];
   }

   static LineFill* Get(LineFill* linefill, int index)
   {
      if (linefill == NULL)
      {
         return NULL;
      }
      LinefillsCollection* collection = FindCollection(linefill.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }
   
   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new LinefillsCollection("");
      }
      else
      {
         _all.ClearCollection();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(LineFill* linefill)
   {
      if (linefill == NULL)
      {
         return;
      }
      _all.RemoveLabel(linefill);
      LinefillsCollection* collection = FindCollection(linefill.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLabel(linefill);
   }

   static LineFill* Create(string id, Line* line1, Line* line2, uint clr, datetime dateId)
   {
      if (line1 == NULL || line2 == NULL)
      {
         return NULL;
      }
      ResetLastError();
      string linefillId = id + line1.GetId() + line2.GetId();
      LinefillsCollection* collection = FindCollection(linefillId);
      if (collection == NULL)
      {
         collection = new LinefillsCollection(linefillId);
         AddCollection(collection);
         LineFill* linefill = new LineFill(line1, line2, clr, linefillId, linefillId, ChartWindowOnDropped());
         collection.Add(linefill);
         _all.Add(linefill);
         return linefill;
      }
      return collection.Get(0);
   }
   
   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   int FindIndex(LineFill* linefill)
   {
      int size = ArraySize(_linefills);
      for (int i = 0; i < size; ++i)
      {
         if (_linefills[i] == linefill)
         {
            return i;
         }
      }
      return -1;
   }
   void RemoveLabel(LineFill* linefill)
   {
      int index = FindIndex(linefill);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_linefills);
      for (int i = index + 1; i < size; ++i)
      {
         _linefills[i - 1] = _linefills[i];
      }
      ArrayResize(_linefills, size - 1);
   }
   void DeleteLabel(LineFill* linefill)
   {
      RemoveLabel(linefill);
      delete linefill;
   }
   void Add(LineFill* linefill)
   {
      int index = FindIndex(linefill);
      
      int size = ArraySize(_linefills);
      ArrayResize(_linefills, size + 1);
      _linefills[size] = linefill;
   }

   void RedrawLabels()
   {
      int size = ArraySize(_linefills);
      for (int i = 0; i < size; ++i)
      {
         _linefills[i].Redraw();
      }
   }

   static void AddCollection(LinefillsCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinefillsCollection* FindCollection(string id)
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
LinefillsCollection* LinefillsCollection::_collections[];
LinefillsCollection* LinefillsCollection::_all;
#endif