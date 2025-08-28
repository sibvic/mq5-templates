// PolyLine object v1.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/ChartPoint.mqh>

class Polyline
{
   string _id;
   int _refs;
   string _collectionId;
   int _window;
   uint _lineColor;
   uint _fillColor;
   int _lineWidth;
   bool _curved;
   bool _closed;
   bool _forceOverlay;
   ICustomTypeArray<ChartPoint*>* _points;
public:
   Polyline(ICustomTypeArray<ChartPoint*>* points, string id, string collectionId, int window)
   {
      _refs = 1;
      _id = id;
      _window = window;
      _lineWidth = 1;
      _collectionId = collectionId;
      _points = points;
      if (_points != NULL)
      {
         _points.AddRef();
      }
   }
   ~Polyline()
   {
      if (_points != NULL)
      {
         _points.Release();
      }
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
      line._points = _points;
      line._lineColor = _lineColor;
      line._fillColor = _fillColor;
      line._lineWidth = _lineWidth;
      line._curved = _curved;
      line._closed = _closed;
      line._forceOverlay = _forceOverlay;
      line._points = _points;
      if (line._points != NULL)
      {
         line._points.AddRef();
      }
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
      if (_points == NULL)
      {
         return;
      }
      int size = _points.Size();
      if (size == 0)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _Period);
      
      ChartPoint* prev = _points.Get(0);
      for (int i = 1; i < size; ++i)
      {
         ChartPoint* point = _points.Get(i);
         datetime x1 = GetTime(prev.GetIndex(), totalBars);
         datetime x2 = GetTime(point.GetIndex(), totalBars);
         string lineId = _id + i;
         if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, prev.GetPrice(), x2, point.GetPrice()))
         {
            ObjectSetInteger(0, lineId, OBJPROP_COLOR, _lineColor);
            ObjectSetInteger(0, lineId, OBJPROP_WIDTH, _lineWidth);
         }
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 0, prev.GetPrice());
         ObjectSetDouble(0, lineId, OBJPROP_PRICE, 1, point.GetPrice());
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 0, x1);
         ObjectSetInteger(0, lineId, OBJPROP_TIME, 1, x2);
         prev = point;
      }
      
   }
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _Period, 0) + MathAbs(pos) * PeriodSeconds(_Period) : iTime(_Symbol, _Period, pos);
   }
   
   Polyline* SetLineColor(uint clr)
   {
      _lineColor = clr;
      return &this;
   }
   Polyline* SetFillColor(uint clr)
   {
      _fillColor = clr;
      return &this;
   }
   Polyline* SetLineWidth(int width)
   {
      _lineWidth = width;
      return &this;
   }
   Polyline* SetCurved(bool val)
   {
      _curved = val;
      return &this;
   }
   Polyline* SetClosed(bool val)
   {
      _closed = val;
      return &this;
   }
   Polyline* SetForceOverlay(bool val)
   {
      _forceOverlay = val;
      return &this;
   }
};