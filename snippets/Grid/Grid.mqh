#include <Grid/Row.mqh>
#include <Grid/RowSize.mqh>

// Grid v2.3

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
      int count = ArraySize(_rows);
      int rowHeights[];
      ArrayResize(rowHeights, count);
      for (int i = 0; i < count; ++i)
      {
         rowHeights[i] = MeasureRowHeight(i);
      }
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
               int end = tillRow;
               if (end >= count)
               {
                  end = count - 1;
               }
               for (int r = i; r <= end; ++r)
               {
                  drawHeight += rowHeights[r];
               }
            }
            cell.SetDrawHeight(drawHeight);
         }
         _rows[i].Draw(x, y, widths);
         y += rowHeights[i];
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

   int GetWidth()
   {
      RowSize* sizes = MeasureColumns();
      int width = sizes.GetTotalWidth();
      delete sizes;
      return width;
   }

   int GetHeight()
   {
      int height = 0;
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         height += MeasureRowHeight(i);
      }
      return height;
   }
private:
   int MeasureRowHeight(const int index)
   {
      RowSize* sizes = new RowSize();
      _rows[index].Measure(sizes);
      int height = sizes.GetMaxHeight();
      delete sizes;
      return height;
   }

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