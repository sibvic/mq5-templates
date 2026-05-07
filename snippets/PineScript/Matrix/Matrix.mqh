// Matrix
// v1.3

#include <PineScript/Matrix/FloatMatrix.mqh>
#include <PineScript/Matrix/TableMatrix.mqh>
#include <PineScript/Array/FloatArray.mqh>

class Matrix
{
public:
   template <typename RETURN_TYPE, typename MATRIX_TYPE, typename DUMMY_TYPE, typename DUMMY_TYPE2>
   static RETURN_TYPE Get(MATRIX_TYPE matrix, int row, int col, RETURN_TYPE emptyValue)
   {
      if (matrix == NULL) { return emptyValue; }
      return matrix.Get(row, col);
   }
   static Table* Get(ITableMatrix* _matrix, int row, int col) { if (_matrix == NULL) { return NULL; } return _matrix.Get(row, col); }

   template <typename MATRIX_TYPE, typename DUMMY_TYPE, typename DUMMY_TYPE2, typename VALUE_TYPE>
   static void Set(MATRIX_TYPE matrix, int row, int col, VALUE_TYPE value)
   {
      if (matrix == NULL) { return; }
      matrix.Set(row, col, value);
   }

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

   static void AddRow(IFloatMatrix* _matrix, int row, ISimpleTypeArray<double>* array_id)
   {
      if (_matrix == NULL || array_id == NULL)
      {
         return;
      }
      _matrix.AddRow(row, array_id);
   }

   static ISimpleTypeArray<double>* Mult(IFloatMatrix* _matrix, ISimpleTypeArray<double>* array)
   {
      if (_matrix == NULL)
      {
         return NULL;
      }
      return _matrix.Mult(array);
   }
};