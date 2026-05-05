// Float martix interface
// v1.1

#include <PineScript/Array/SimpleTypeArray.mqh>

interface IFloatMatrix
{
public:
   virtual IFloatMatrix* Clear(double initialValue) = 0;
   virtual int Rows() = 0;
   virtual int Columns() = 0;
   virtual double Get(int row, int col) = 0;
   virtual void Set(int row, int col, double val) = 0;
   virtual void AddRow(int row, ISimpleTypeArray<double>* array_id) = 0;
   virtual ISimpleTypeArray<double>* Mult(ISimpleTypeArray<double>* array) = 0;
};