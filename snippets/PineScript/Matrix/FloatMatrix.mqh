// Float matrix
// v1.2
#include <PineScript/Matrix/IFloatMatrix.mqh>
#include <PineScript/Array/FloatArray.mqh>

class FloatMatrix : public IFloatMatrix
{
   int rows;
   int columns;
   double initialValue;
   double values[];
public:
   FloatMatrix(int rows, int columns)
   {
      this.rows = rows;
      this.columns = columns;
      Clear(EMPTY_VALUE);
   }
   
   IFloatMatrix* Clear(double initialValue)
   {
      this.initialValue = initialValue;
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

   int Rows() { return rows; }
   int Columns() { return columns; }
   
   double Get(int row, int col)
   {
      return values[row * columns + col];
   }
   
   void Set(int row, int col, double val)
   {
      values[row * columns + col] = val;
   }

   void AddRow(int row, ISimpleTypeArray<double>* array_id)
   {
      if (row == INT_MIN)
      {
         row = rows;
      }
      if (array_id == NULL || row < 0 || row > rows)
      {
         return;
      }
      int n = array_id.Size();
      int newRows = rows + 1;
      ArrayResize(values, newRows * columns);
      for (int r = rows - 1; r >= row; --r)
      {
         for (int c = 0; c < columns; ++c)
         {
            values[(r + 1) * columns + c] = values[r * columns + c];
         }
      }
      for (int c = 0; c < columns; ++c)
      {
         double val = (c < n) ? array_id.Get(c) : EMPTY_VALUE;
         values[row * columns + c] = val;
      }
      rows = newRows;
   }

   virtual ISimpleTypeArray<double>* Mult(ISimpleTypeArray<double>* array) override
   {
      if (array == NULL)
      {
         return NULL;
      }
      FloatArray* result = new FloatArray(rows, EMPTY_VALUE);
      for (int r = 0; r < rows; ++r)
      {
         double sum = 0.0;
         bool ok = true;
         for (int c = 0; c < columns; ++c)
         {
            double m = Get(r, c);
            double v = (c < array.Size()) ? array.Get(c) : EMPTY_VALUE;
            if (m == EMPTY_VALUE || v == EMPTY_VALUE)
            {
               ok = false;
               break;
            }
            sum += m * v;
         }
         if (ok)
         {
            result.Set(r, sum);
         }
      }
      return result;
   }
};