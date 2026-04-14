// Float martix interface
// v1.0

interface IFloatMatrix
{
public:
   virtual IFloatMatrix* Clear(double initialValue) = 0;
   virtual int Rows() = 0;
   virtual int Columns() = 0;
   virtual double Get(int row, int col) = 0;
   virtual void Set(int row, int col, double val) = 0;
};