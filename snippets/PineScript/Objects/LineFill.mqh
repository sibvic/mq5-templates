// Linefill object v1.6
#include <PineScript/Objects/Line.mqh>
#include <PineScriptUtils.mqh>
#ifndef Linefill_IMPL
#define Linefill_IMPL

class LineFill
{
   string _id;
   Line* _line1;
   Line* _line2;
   uint _clr;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   string _collectionId;
   int _window;
public:
   LineFill(Line* line1, Line* line2, uint clr, string id, string collectionId, int window)
   {
      _refs = 1;
      _line1 = line1;
      if (_line1 != NULL)
      {
         _line1.AddRef();
      }
      _line2 = line2;
      if (_line2 != NULL)
      {
         _line2.AddRef();
      }
      _id = id;
      _clr = clr;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
   }
   ~LineFill()
   {
      if (_line1 != NULL)
      {
         _line1.Release();
      }
      if (_line2 != NULL)
      {
         _line2.Release();
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
      int transp = GetTranparency(_clr);
      if (_line1 == NULL || _line2 == NULL || transp == 100)
      {
         return;
      }
      int totalBars = iBars(_Symbol, _timeframe);
      string id1 = _id + "t1";
      string id2 = _id + "t2";
      datetime x1 = GetTime(_line1.GetX1(), totalBars);
      datetime x2 = GetTime(_line1.GetX2(), totalBars);
      datetime x3 = GetTime(_line2.GetX1(), totalBars);
      datetime x4 = GetTime(_line2.GetX2(), totalBars);
      double y1 = _line1.GetY1();
      double y2 = _line1.GetY2();
      double y3 = _line2.GetY1();
      double y4 = _line2.GetY2();
      if (y1 == EMPTY_VALUE || y2 == EMPTY_VALUE || y3 == EMPTY_VALUE || y4 == EMPTY_VALUE)
      {
         return;
      }
      if (ObjectFind(0, id1) == -1)
      {
         color usedColor = GetColorOnly(_clr);
         if (ObjectCreate(0, id1, OBJ_TRIANGLE, 0, x1, y1, x2, y2, x3, y3))
         {
            ObjectSetInteger(0, id1, OBJPROP_COLOR, usedColor);
            ObjectSetInteger(0, id1, OBJPROP_FILL, true);
            ObjectSetInteger(0, id1, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id1, OBJPROP_RAY_RIGHT, false);
         }
         if (ObjectCreate(0, id2, OBJ_TRIANGLE, 0, x4, y4, x2, y2, x3, y3))
         {
            ObjectSetInteger(0, id2, OBJPROP_COLOR, usedColor);
            ObjectSetInteger(0, id2, OBJPROP_FILL, true);
            ObjectSetInteger(0, id2, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id2, OBJPROP_RAY_RIGHT, false);
         }
      }
      ObjectSetDouble(0, id1, OBJPROP_PRICE, 0, y1);
      ObjectSetDouble(0, id1, OBJPROP_PRICE, 1, y2);
      ObjectSetDouble(0, id1, OBJPROP_PRICE, 2, y3);
      ObjectSetInteger(0, id1, OBJPROP_TIME, 0, x1);
      ObjectSetInteger(0, id1, OBJPROP_TIME, 1, x2);
      ObjectSetInteger(0, id1, OBJPROP_TIME, 2, x3);
      
      ObjectSetDouble(0, id2, OBJPROP_PRICE, 0, y4);
      ObjectSetDouble(0, id2, OBJPROP_PRICE, 1, y2);
      ObjectSetDouble(0, id2, OBJPROP_PRICE, 2, y3);
      ObjectSetInteger(0, id2, OBJPROP_TIME, 0, x4);
      ObjectSetInteger(0, id2, OBJPROP_TIME, 1, x2);
      ObjectSetInteger(0, id2, OBJPROP_TIME, 2, x3);
   }
private:
   datetime GetTime(int x, int totalBars)
   {
      int pos = totalBars - x - 1;
      return pos < 0 ? iTime(_Symbol, _timeframe, 0) + MathAbs(pos) * PeriodSeconds(_timeframe) : iTime(_Symbol, _timeframe, pos);
   }
};
#endif