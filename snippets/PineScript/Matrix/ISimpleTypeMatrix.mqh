// Simple-type matrix interface (parallel to ISimpleTypeArray)
// v1.0

#ifndef ISIMPLETYPEMATRIX_MQH
#define ISIMPLETYPEMATRIX_MQH

#include <PineScript/Array/SimpleTypeArray.mqh>

template <typename CLASS_TYPE>
interface ISimpleTypeMatrix
{
public:
   virtual void AddRef() = 0;
   virtual int Release() = 0;
   virtual int Rows() = 0;
   virtual int Columns() = 0;
   virtual CLASS_TYPE Get(int row, int col) = 0;
   virtual void Set(int row, int col, CLASS_TYPE val) = 0;
   virtual ISimpleTypeMatrix<CLASS_TYPE>* Fill(CLASS_TYPE initialValue) = 0;
   virtual ISimpleTypeMatrix<CLASS_TYPE>* Clear() = 0;
   virtual ISimpleTypeMatrix<CLASS_TYPE>* Clear(CLASS_TYPE initialValue) = 0;
   virtual void AddRow(int row, ISimpleTypeArray<CLASS_TYPE>* array_id) = 0;
   virtual ISimpleTypeArray<CLASS_TYPE>* RemoveRow(int row) = 0;
};

#endif
