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
      line._points.AddRef();
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
      //TODO: Implement
      
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