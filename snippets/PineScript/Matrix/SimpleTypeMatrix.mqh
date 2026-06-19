// Simple-type matrix (row-major linear storage; mirrors SimpleTypeArray semantics on flat indices)
// v1.0

#ifndef SIMPLETYPEMATRIX_MQH
#define SIMPLETYPEMATRIX_MQH

#include <PineScript/Matrix/ISimpleTypeMatrix.mqh>

int MatrixEmptyDefault(int) { return INT_MIN; }
double MatrixEmptyDefault(double) { return EMPTY_VALUE; }
uint MatrixEmptyDefault(uint) { return 0; }
bool MatrixEmptyDefault(bool) { return false; }
datetime MatrixEmptyDefault(datetime) { return 0; }

template <typename CLASS_TYPE>
class SimpleTypeMatrix : public ISimpleTypeMatrix<CLASS_TYPE>
{
   CLASS_TYPE values[];
   int rows;
   int columns;
   int _defaultRows;
   int _defaultColumns;
   CLASS_TYPE _defaultValue;
   CLASS_TYPE _emptyValue;
   int _refs;

   void syncRowsFromSize()
   {
      int sz = ArraySize(values);
      if (columns <= 0)
      {
         rows = (sz > 0) ? sz : 0;
         return;
      }
      rows = (sz + columns - 1) / columns;
   }

public:
   SimpleTypeMatrix(int matrixRows, int matrixColumns)
   {
      _refs = 1;
      _defaultValue = (CLASS_TYPE)0;
      _emptyValue = MatrixEmptyDefault(_defaultValue);
      _defaultRows = matrixRows == INT_MIN ? 0 : matrixRows;
      _defaultColumns = matrixColumns == INT_MIN ? 0 : matrixColumns;
      rows = _defaultRows;
      columns = _defaultColumns;
      Clear();
   }

   SimpleTypeMatrix(int matrixRows, int matrixColumns, CLASS_TYPE defaultValue, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      _defaultValue = defaultValue;
      _emptyValue = emptyValue;
      _defaultRows = matrixRows == INT_MIN ? 0 : matrixRows;
      _defaultColumns = matrixColumns == INT_MIN ? 0 : matrixColumns;
      rows = _defaultRows;
      columns = _defaultColumns;
      Clear();
   }

   ~SimpleTypeMatrix()
   {
      Clear();
   }

   virtual void AddRef() override { _refs++; }
   virtual int Release() override
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }

   virtual ISimpleTypeMatrix<CLASS_TYPE>* Clear() override
   {
      rows = _defaultRows;
      columns = _defaultColumns;
      int sz = rows * columns;
      ArrayResize(values, sz);
      for (int i = 0; i < sz; ++i)
      {
         values[i] = _defaultValue;
      }
      return &this;
   }

   virtual ISimpleTypeMatrix<CLASS_TYPE>* Clear(CLASS_TYPE initialValue) override
   {
      _defaultValue = initialValue;
      return Clear();
   }

   virtual ISimpleTypeMatrix<CLASS_TYPE>* Fill(CLASS_TYPE initialValue) override
   {
      _defaultValue = initialValue;
      int sz = ArraySize(values);
      for (int i = 0; i < sz; ++i)
      {
         values[i] = initialValue;
      }
      return &this;
   }

   virtual int Rows() override { return rows; }
   virtual int Columns() override { return columns; }

   CLASS_TYPE MatrixDefaultFill() { return _defaultValue; }
   CLASS_TYPE MatrixEmptySentinel() { return _emptyValue; }

   virtual CLASS_TYPE Get(int row, int col) override
   {
      if (row < 0 || col < 0 || row >= rows || col >= columns)
      {
         return _emptyValue;
      }
      return values[row * columns + col];
   }

   virtual void Set(int row, int col, CLASS_TYPE val) override
   {
      if (row < 0 || col < 0 || row >= rows || col >= columns)
      {
         return;
      }
      values[row * columns + col] = val;
   }

   virtual void AddRow(int row, ISimpleTypeArray<CLASS_TYPE>* array_id) override
   {
      if (row == INT_MIN)
      {
         row = rows;
      }
      if (row < 0 || row > rows)
      {
         return;
      }
      int n = (array_id != NULL) ? array_id.Size() : 0;
      if (columns <= 0)
      {
         if (rows > 0)
         {
            return;
         }
         if (array_id != NULL && n > 0)
         {
            columns = n;
         }
         else
         {
            columns = 1;
         }
      }
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
         CLASS_TYPE val = (array_id != NULL && c < n) ? array_id.Get(c) : _emptyValue;
         values[row * columns + c] = val;
      }
      rows = newRows;
   }

   virtual ISimpleTypeArray<CLASS_TYPE>* RemoveRow(int row) override
   {
      if (row < 0 || row >= rows || columns <= 0)
      {
         return NULL;
      }
      SimpleTypeArray<CLASS_TYPE>* removed = new SimpleTypeArray<CLASS_TYPE>(columns, _defaultValue, _emptyValue);
      for (int c = 0; c < columns; ++c)
      {
         removed.Set(c, values[row * columns + c]);
      }
      for (int r = row + 1; r < rows; ++r)
      {
         for (int c = 0; c < columns; ++c)
         {
            values[(r - 1) * columns + c] = values[r * columns + c];
         }
      }
      rows--;
      if (_defaultRows > 0)
      {
         _defaultRows--;
      }
      ArrayResize(values, rows * columns);
      return removed;
   }

   void Sort(bool ascending)
   {
      ArraySort(values);
      if (!ascending)
      {
         ArrayReverse(values);
      }
   }

   void Unshift(CLASS_TYPE value)
   {
      int sz = ArraySize(values);
      ArrayResize(values, sz + 1);
      for (int i = sz - 1; i >= 0; --i)
      {
         values[i + 1] = values[i];
      }
      values[0] = value;
      syncRowsFromSize();
   }

   int Size()
   {
      return ArraySize(values);
   }

   ISimpleTypeMatrix<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int sz = ArraySize(values);
      if (columns <= 0 && sz == 0)
      {
         columns = 1;
      }
      ArrayResize(values, sz + 1);
      values[sz] = value;
      syncRowsFromSize();
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int sz = ArraySize(values);
      CLASS_TYPE value = values[sz - 1];
      ArrayResize(values, sz - 1);
      syncRowsFromSize();
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index >= Size())
      {
         return _emptyValue;
      }
      if (index < 0)
      {
         index = Size() + index;
      }
      return values[index];
   }

   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      values[index] = value;
   }

   CLASS_TYPE Remove(int index)
   {
      int sz = ArraySize(values);
      CLASS_TYPE value = values[index];
      for (int i = index; i < sz - 1; ++i)
      {
         values[i] = values[i + 1];
      }
      ArrayResize(values, sz - 1);
      syncRowsFromSize();
      return value;
   }

   int Includes(CLASS_TYPE value)
   {
      int sz = ArraySize(values);
      for (int i = 0; i < sz; ++i)
      {
         if (values[i] == value)
         {
            return true;
         }
      }
      return false;
   }

   CLASS_TYPE PercentRank(int index)
   {
      int arraySize = Size();
      if (arraySize == 0 || arraySize <= index)
      {
         return _emptyValue;
      }
      CLASS_TYPE target = Get(index);
      if (target == _emptyValue)
      {
         return _emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         CLASS_TYPE current = Get(i);
         if (current != _emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }

   CLASS_TYPE Max()
   {
      if (Size() == 0)
      {
         return _emptyValue;
      }
      CLASS_TYPE maxVal = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (maxVal == _emptyValue || (current != _emptyValue && maxVal < current))
         {
            maxVal = current;
         }
      }
      return maxVal;
   }

   CLASS_TYPE Min()
   {
      if (Size() == 0)
      {
         return _emptyValue;
      }
      CLASS_TYPE minVal = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (minVal == _emptyValue || (current != _emptyValue && minVal > current))
         {
            minVal = current;
         }
      }
      return minVal;
   }

   CLASS_TYPE Sum()
   {
      CLASS_TYPE sum = 0;
      for (int i = 0; i < Size(); ++i)
      {
         sum += Get(i);
      }
      return sum;
   }

   double Stdev()
   {
      double sum = 0;
      double ssum = 0;
      int sz = Size();
      if (sz < 2)
      {
         return 0;
      }
      for (int i = 0; i < sz; i++)
      {
         CLASS_TYPE value = Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * sz - sum * sum) / (sz * (sz - 1)));
   }
};

#endif
