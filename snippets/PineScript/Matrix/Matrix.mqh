// Matrix
// v1.3

#include <PineScript/Matrix/SimpleTypeMatrix.mqh>
#include <PineScript/Matrix/TableMatrix.mqh>
#include <PineScript/Array/FloatArray.mqh>
#include <PineScript/Array/IntArray.mqh>

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

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   struct MatrixRowDispatch
   {
      static ARRAY_IFACE* Invoke(MATRIX_TYPE matrix, ROW_INDEX_TYPE row);
   };

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   static ARRAY_IFACE* Row(MATRIX_TYPE matrix, ROW_INDEX_TYPE row, ARRAY_IFACE* emptyPlaceholder)
   {
      if (matrix == NULL)
      {
         return emptyPlaceholder;
      }
      int rows = matrix.Rows();
      if (row < 0 || row >= rows)
      {
         return emptyPlaceholder;
      }
      return MatrixRowDispatch<ARRAY_IFACE, MATRIX_TYPE, ROW_INDEX_TYPE>::Invoke(matrix, row);
   }

   template<>
   struct MatrixRowDispatch<ITArray<int>*, ISimpleTypeMatrix<int>*, int>
   {
      static ITArray<int>* Invoke(ISimpleTypeMatrix<int>* matrix, int row)
      {
         int cols = matrix.Columns();
         IntArray* arr = new IntArray(cols, INT_MIN);
         for (int c = 0; c < cols; ++c)
         {
            arr.Set(c, matrix.Get(row, c));
         }
         return arr;
      }
   };

   template<>
   struct MatrixRowDispatch<ISimpleTypeArray<double>*, ISimpleTypeMatrix<double>*, int>
   {
      static ISimpleTypeArray<double>* Invoke(ISimpleTypeMatrix<double>* matrix, int row)
      {
         int cols = matrix.Columns();
         FloatArray* arr = new FloatArray(cols, EMPTY_VALUE);
         for (int c = 0; c < cols; ++c)
         {
            arr.Set(c, matrix.Get(row, c));
         }
         return arr;
      }
   };

   template <typename MATRIX_TYPE, typename ROW_INDEX_TYPE, typename ARRAY_TYPE>
   static void AddRow(MATRIX_TYPE matrix, ROW_INDEX_TYPE row, ARRAY_TYPE array_id)
   {
      if (matrix == NULL || array_id == NULL)
      {
         return;
      }
      matrix.AddRow(row, array_id);
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