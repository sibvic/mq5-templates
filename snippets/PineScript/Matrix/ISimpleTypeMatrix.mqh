// Simple-type matrix interface (parallel to ISimpleTypeArray)
// v1.0

#ifndef ISIMPLETYPEMATRIX_MQH
#define ISIMPLETYPEMATRIX_MQH

#include <PineScript/Array/SimpleTypeArray.mqh>

template <typename CLASS_TYPE>
interface ISimpleTypeMatrix : public ISimpleTypeArray<CLASS_TYPE>
{
public:
   virtual int Rows() = 0;
   virtual int Columns() = 0;
   virtual CLASS_TYPE Get(int row, int col) = 0;
   virtual void Set(int row, int col, CLASS_TYPE val) = 0;
   virtual ISimpleTypeMatrix<CLASS_TYPE>* Fill(CLASS_TYPE initialValue) = 0;
   virtual void AddRow(int row, ISimpleTypeArray<CLASS_TYPE>* array_id) = 0;
   virtual ISimpleTypeArray<CLASS_TYPE>* Mult(ISimpleTypeArray<CLASS_TYPE>* array) = 0;
};

#endif
