// Grid builder v1.0

#include <ICellFactory.mq5>

#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   Iterator _xIterator;
   Iterator _yIterator;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory;
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ICellFactory* cellFactory)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _cellFactory = cellFactory;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      delete _cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      split(_symbols, symbols, ",");
      _symbolsCount = ArraySize(_symbols);

      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      if (_verticalMode)
      {
         int x = _xIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, _headerHeight));
         Iterator yIterator(_originalY, _cellHeight);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, x, yIterator.GetNext(), _symbols[i], timeframe));
         }
      }
      else
      {
         int y = _yIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, xIterator.GetNext(), y, _symbols[i], timeframe));
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }

private:
   void split(string& arr[], string str, string sym) 
   {
      ArrayResize(arr, 0);
      int len = StringLen(str);
      for (int i=0; i < len;)
      {
         int pos = StringFind(str, sym, i);
         if (pos == -1)
            pos = len;
   
         string item = StringSubstr(str, i, pos-i);
         StringTrimLeft(item);
         StringTrimRight(item);
   
         int size = ArraySize(arr);
         ArrayResize(arr, size+1);
         arr[size] = item;
   
         i = pos+1;
      }
   }
};
#endif