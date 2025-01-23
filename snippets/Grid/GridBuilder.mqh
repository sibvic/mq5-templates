// Grid builder v2.0

#include <Grid/ICellFactory.mqh>
#include <Grid/Grid.mqh>

#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory[];
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   color _headerColor;
   int _windowNumber;
public:
   GridBuilder(int headerHeight, int cellHeight, bool verticalMode, ENUM_BASE_CORNER __corner, int fontSize, color headerColor, int windowNumber)
   {
      _windowNumber = windowNumber;
      _fontSize = fontSize;
      _corner = __corner;
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _verticalMode = verticalMode;
      _headerColor = headerColor;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      for (int i = 0; i < ArraySize(_cellFactory); ++i)
      {
         delete _cellFactory[i];
      }
      ArrayResize(_cellFactory, 0);
   }

   void AddCell(ICellFactory* cellFactory)
   {
      int size = ArraySize(_cellFactory);
      ArrayResize(_cellFactory, size + 1);
      _cellFactory[size] = cellFactory;
   }

   void SetSymbols(const string symbols, int x, int y)
   {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);

      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Iterator yIterator(y, _cellHeight);
         if (cellFactorySize > 1)
         {
            yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, _fontSize, _headerColor, _windowNumber));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(x - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, _fontSize, _headerColor, _windowNumber));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Row* column[];
         ArrayResize(column, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            column[ii] = grid.AddRow();
            #ifndef EXCLUDE_PERIOD_HEADER
            if (ii > 0)
            {
               column[ii].Add(new EmptyCell());
            }
            else
            {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, _corner, _fontSize, _headerColor, _windowNumber));
            }
            #endif
         }
         
         if (cellFactorySize > 1)
         {
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), _corner, _fontSize, _headerColor, _windowNumber));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, _corner, _symbols[i], timeframe));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _corner, _fontSize, _headerColor, _windowNumber));
         #endif
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, _corner, _symbols[i], timeframe));
            }
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }
};
#endif