#include <Grid/Row.mqh>
#include <Grid/RowSize.mqh>

// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      if (index == INT_MIN)
      {
         return NULL;
      }
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int rowHeight = widths.GetMaxHeight();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int columnsCount = _rows[i].GetColumnsCount();
         for (int j = 0; j < columnsCount; ++j)
         {
            ICell* cell = _rows[i].GetCell(j);
            if (cell == NULL || cell.IsMergeSkipped())
            {
               continue;
            }
            int tillRow = cell.GetMergeTillRow();
            int drawHeight = 0;
            if (tillRow >= i)
            {
               drawHeight = rowHeight * (tillRow - i + 1);
            }
            cell.SetDrawHeight(drawHeight);
         }
         _rows[i].Draw(x, y, widths);
         y += rowHeight;
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif