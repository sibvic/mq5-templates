// Table martix interface
// v1.0
#include <PineScript/Objects/Table.mqh>

interface ITableMatrix
{
public:
   virtual ITableMatrix* Clear() = 0;
   virtual Table* Get(int row, int col) = 0;
   virtual void Set(int row, int col, Table* val) = 0;
};