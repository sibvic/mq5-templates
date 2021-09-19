// Grid cells v1.0

#include <GridRow.mqh>

#ifndef GridCells_IMP
#define GridCells_IMP

class GridCells
{
   string _id;
   GridRow* _columns[];
   double _gap;
   int _window;
public:
   GridCells(string id, double gap, int window)
   {
      _window = window;
      _gap = gap;
      _id = id;
   }

   ~GridCells()
   {
      for (int i = 0; i < ArraySize(_columns); ++i)
      {
         delete _columns[i];
      }
      ArrayResize(_columns, 0);
   }

   void Clear()
   {

   }

   void Add(string text, color clr, string fontName, int fontSize, int column, int row, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      EnsureEnoughtColumns(column + 1);
      _columns[column].EnsureEnoughtCells(row + 1);
      _columns[column].Get(row).SetData(text, clr, fontName, fontSize, anchor);
   }

   void Draw(int __x, int __y)
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));
      ArrayInitialize(maxHeight, 0);
      ArrayInitialize(maxWidth, 0);

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }

         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }

      int currentX = __x;
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentY = __y;
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).Draw(currentX, currentY);
            currentY += (int)(maxHeight[rowIndex] * _gap);
         }
         currentX += (int)(maxWidth[columnIndex] * _gap);
      }
   }

   void SetMinWidth(int width)
   {
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).SetMinWidth(width);
         }
      }
   }

   int GetTotalWidth()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxWidth);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxWidth[i] * _gap : maxWidth[i]);
      }
      return total;
   }
   int GetTotalHeight()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxHeight);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxHeight[i] * _gap : maxHeight[i]);
      }
      return total;
   }
private:
   void EnsureEnoughtColumns(int newSize)
   {
      int oldSize = ArraySize(_columns);
      if (oldSize <= newSize)
      {
         ArrayResize(_columns, newSize);
         for (int i = oldSize; i < newSize; ++i)
         {
            _columns[i] = new GridRow(_id + "-" + IntegerToString(i), _window);
         }
      }
   }
};

#endif