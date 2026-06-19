// Matrix
// v1.6

#include <PineScript/Matrix/SimpleTypeMatrix.mqh>
#include <PineScript/Matrix/TableMatrix.mqh>
#include <PineScript/Array/FloatArray.mqh>
#include <PineScript/Array/IntArray.mqh>

class Matrix
{
public:
   template <typename RETURN_TYPE, typename MATRIX_TYPE, typename DUMMY_TYPE, typename DUMMY_TYPE2>
   static RETURN_TYPE Get(MATRIX_TYPE _matrix, int row, int col, RETURN_TYPE emptyValue)
   {
      if (_matrix == NULL) { return emptyValue; }
      return _matrix.Get(row, col);
   }
   static Table* Get(ITableMatrix* _matrix, int row, int col) { if (_matrix == NULL) { return NULL; } return _matrix.Get(row, col); }

   template <typename MATRIX_TYPE, typename DUMMY_TYPE, typename DUMMY_TYPE2, typename VALUE_TYPE>
   static void Set(MATRIX_TYPE _matrix, int row, int col, VALUE_TYPE value)
   {
      if (_matrix == NULL) { return; }
      _matrix.Set(row, col, value);
   }

   static void Set(ITableMatrix* _matrix, int row, int col, Table* val) { if (_matrix == NULL) { return; } _matrix.Set(row, col, val); }

   template <typename MATRIX_TYPE>
   static int Rows(MATRIX_TYPE _matrix)
   {
      if (_matrix == NULL) { return INT_MIN; }
      return _matrix.Rows();
   }

   class MatrixRowDispatchImpl
   {
   public:
      static ITArray<int>* Invoke(ISimpleTypeMatrix<int>* _matrix, int row)
      {
         int cols = _matrix.Columns();
         IntArray* arr = new IntArray(cols, INT_MIN);
         for (int c = 0; c < cols; ++c)
         {
            arr.Set(c, _matrix.Get(row, c));
         }
         return arr;
      }

      static ISimpleTypeArray<double>* Invoke(ISimpleTypeMatrix<double>* _matrix, int row)
      {
         int cols = _matrix.Columns();
         FloatArray* arr = new FloatArray(cols, EMPTY_VALUE);
         for (int c = 0; c < cols; ++c)
         {
            arr.Set(c, _matrix.Get(row, c));
         }
         return arr;
      }
   };

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   struct MatrixRowDispatch
   {
      static ARRAY_IFACE Invoke(MATRIX_TYPE _matrix, ROW_INDEX_TYPE row)
      {
         return MatrixRowDispatchImpl::Invoke(_matrix, row);
      }
   };

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   static ARRAY_IFACE Row(MATRIX_TYPE _matrix, ROW_INDEX_TYPE row, ARRAY_IFACE emptyPlaceholder)
   {
      if (_matrix == NULL)
      {
         return emptyPlaceholder;
      }
      int rowCount = _matrix.Rows();
      if (row < 0 || row >= rowCount)
      {
         return emptyPlaceholder;
      }
      return MatrixRowDispatch<ARRAY_IFACE, MATRIX_TYPE, ROW_INDEX_TYPE>::Invoke(_matrix, row);
   }

   template <typename MATRIX_TYPE, typename ROW_INDEX_TYPE, typename ARRAY_TYPE>
   static void AddRow(MATRIX_TYPE _matrix, ROW_INDEX_TYPE row, ARRAY_TYPE array_id)
   {
      if (_matrix == NULL || array_id == NULL)
      {
         return;
      }
      _matrix.AddRow(row, array_id);
   }

   class MatrixRemoveRowDispatchImpl
   {
   public:
      static ITArray<int>* Invoke(ISimpleTypeMatrix<int>* _matrix, int row)
      {
         return _matrix.RemoveRow(row);
      }

      static ISimpleTypeArray<double>* Invoke(ISimpleTypeMatrix<double>* _matrix, int row)
      {
         return _matrix.RemoveRow(row);
      }
   };

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   struct MatrixRemoveRowDispatch
   {
      static ARRAY_IFACE Invoke(MATRIX_TYPE _matrix, ROW_INDEX_TYPE row)
      {
         return MatrixRemoveRowDispatchImpl::Invoke(_matrix, row);
      }
   };

   template <typename ARRAY_IFACE, typename MATRIX_TYPE, typename ROW_INDEX_TYPE>
   static ARRAY_IFACE RemoveRow(MATRIX_TYPE _matrix, ROW_INDEX_TYPE row, ARRAY_IFACE emptyPlaceholder)
   {
      if (_matrix == NULL)
      {
         return emptyPlaceholder;
      }
      int rowCount = _matrix.Rows();
      if (row < 0 || row >= rowCount)
      {
         return emptyPlaceholder;
      }
      return MatrixRemoveRowDispatch<ARRAY_IFACE, MATRIX_TYPE, ROW_INDEX_TYPE>::Invoke(_matrix, row);
   }

   static ISimpleTypeArray<int>* Mult(ISimpleTypeMatrix<int>* _matrix, ISimpleTypeArray<int>* array)
   {
      if (_matrix == NULL || array == NULL)
      {
         return NULL;
      }
      SimpleTypeMatrix<int>* sm = (SimpleTypeMatrix<int>*)_matrix;
      int rowCount = sm.Rows();
      int colCount = sm.Columns();
      int emptySentinel = sm.MatrixEmptySentinel();
      SimpleTypeArray<int>* result = new SimpleTypeArray<int>(rowCount, sm.MatrixDefaultFill(), emptySentinel);
      for (int r = 0; r < rowCount; ++r)
      {
         int sum = 0;
         bool ok = true;
         for (int c = 0; c < colCount; ++c)
         {
            int m = sm.Get(r, c);
            int v = (c < array.Size()) ? array.Get(c) : emptySentinel;
            if (m == emptySentinel || v == emptySentinel)
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

   static ISimpleTypeArray<double>* Mult(ISimpleTypeMatrix<double>* _matrix, ISimpleTypeArray<double>* array)
   {
      if (_matrix == NULL || array == NULL)
      {
         return NULL;
      }
      SimpleTypeMatrix<double>* sm = (SimpleTypeMatrix<double>*)_matrix;
      int rowCount = sm.Rows();
      int colCount = sm.Columns();
      double emptySentinel = sm.MatrixEmptySentinel();
      SimpleTypeArray<double>* result = new SimpleTypeArray<double>(rowCount, sm.MatrixDefaultFill(), emptySentinel);
      for (int r = 0; r < rowCount; ++r)
      {
         double sum = 0;
         bool ok = true;
         for (int c = 0; c < colCount; ++c)
         {
            double m = sm.Get(r, c);
            double v = (c < array.Size()) ? array.Get(c) : emptySentinel;
            if (m == emptySentinel || v == emptySentinel)
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

   template <typename CLASS_TYPE>
   static ISimpleTypeMatrix<CLASS_TYPE>* Diff(ISimpleTypeMatrix<CLASS_TYPE>* _matrix1, ISimpleTypeMatrix<CLASS_TYPE>* _matrix2)
   {
      if (_matrix1 == NULL || _matrix2 == NULL)
      {
         return NULL;
      }
      int rowCount = _matrix1.Rows();
      int colCount = _matrix1.Columns();
      if (_matrix2.Rows() != rowCount || _matrix2.Columns() != colCount)
      {
         return NULL;
      }
      SimpleTypeMatrix<CLASS_TYPE>* sm1 = (SimpleTypeMatrix<CLASS_TYPE>*)_matrix1;
      CLASS_TYPE emptySentinel = sm1.MatrixEmptySentinel();
      SimpleTypeMatrix<CLASS_TYPE>* result = new SimpleTypeMatrix<CLASS_TYPE>(rowCount, colCount, sm1.MatrixDefaultFill(), emptySentinel);
      for (int r = 0; r < rowCount; ++r)
      {
         for (int c = 0; c < colCount; ++c)
         {
            CLASS_TYPE v1 = _matrix1.Get(r, c);
            CLASS_TYPE v2 = _matrix2.Get(r, c);
            if (v1 == emptySentinel || v2 == emptySentinel)
            {
               continue;
            }
            result.Set(r, c, v1 - v2);
         }
      }
      return result;
   }

   static int SubmatrixResolveToIndex(int to, int size)
   {
      if (to == INT_MIN || to == 0)
      {
         return size;
      }
      return to;
   }

   template <typename CLASS_TYPE>
   static ISimpleTypeMatrix<CLASS_TYPE>* Submatrix(ISimpleTypeMatrix<CLASS_TYPE>* _matrix, int from_row, int to_row, int from_column, int to_column)
   {
      if (_matrix == NULL)
      {
         return NULL;
      }
      int rowCount = _matrix.Rows();
      int colCount = _matrix.Columns();
      to_row = MathMin(SubmatrixResolveToIndex(to_row, rowCount), rowCount);
      to_column = MathMin(SubmatrixResolveToIndex(to_column, colCount), colCount);
      if (from_row < 0 || from_column < 0 || from_row >= to_row || from_column >= to_column)
      {
         return NULL;
      }
      SimpleTypeMatrix<CLASS_TYPE>* sm = (SimpleTypeMatrix<CLASS_TYPE>*)_matrix;
      int newRows = to_row - from_row;
      int newCols = to_column - from_column;
      SimpleTypeMatrix<CLASS_TYPE>* result = new SimpleTypeMatrix<CLASS_TYPE>(newRows, newCols, sm.MatrixDefaultFill(), sm.MatrixEmptySentinel());
      for (int r = 0; r < newRows; ++r)
      {
         for (int c = 0; c < newCols; ++c)
         {
            result.Set(r, c, _matrix.Get(from_row + r, from_column + c));
         }
      }
      return result;
   }
};
