// Matrix
// v1.1

#include <PineScript/Matrix/FloatMatrix.mqh>
#include <PineScript/Matrix/TableMatrix.mqh>
#include <PineScript/Array/FloatArray.mqh>

class Matrix
{
public:
   static double Get(IFloatMatrix* _matrix, int row, int col) { if (_matrix == NULL) { return EMPTY_VALUE; } return _matrix.Get(row, col); }
   static Table* Get(ITableMatrix* _matrix, int row, int col) { if (_matrix == NULL) { return NULL; } return _matrix.Get(row, col); }
   
   static void Set(IFloatMatrix* _matrix, int row, int col, double val) { if (_matrix == NULL) { return; } _matrix.Set(row, col, val); }
   static void Set(ITableMatrix* _matrix, int row, int col, Table* val) { if (_matrix == NULL) { return; } _matrix.Set(row, col, val); }

   static FloatArray* Row(IFloatMatrix* _matrix, int row)
   {
      if (_matrix == NULL)
      {
         return NULL;
      }
      int rows = _matrix.Rows();
      int cols = _matrix.Columns();
      if (row < 0 || row >= rows)
      {
         return NULL;
      }
      FloatArray* arr = new FloatArray(cols, EMPTY_VALUE);
      for (int c = 0; c < cols; ++c)
      {
         arr.Set(c, _matrix.Get(row, c));
      }
      return arr;
   }
};