// Table matrix
// v1.1
#include <PineScript/Matrix/ITableMatrix.mqh>
#include <PineScript/Objects/Table.mqh>

class TableMatrix : public ITableMatrix
{
   int rows;
   int columns;
   Table* initialValue;
   Table* values[];
public:
   TableMatrix(int rows, int columns, Table* initialValue)
   {
      this.rows = rows;
      this.columns = columns;
      this.initialValue = initialValue;
      initialValue.Lock();
      Clear();
   }
   
   ~TableMatrix()
   {
      initialValue.Unlock();
   }
   
   ITableMatrix* Clear()
   {
      ArrayResize(values, rows * columns);
      for (int row = 0; row < rows; ++row)
      {
         for (int column = 0; column < columns; ++column)
         {
            values[row * columns + column] = initialValue;
         }
      }
      return &this;
   }
   
   Table* Get(int row, int col)
   {
      return values[row * columns + col];
   }
   
   void Set(int row, int col, Table* val)
   {
      values[row * columns + col] = val;
   }
};