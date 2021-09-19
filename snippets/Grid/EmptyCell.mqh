// Empty cell v1.0

#include <ICell.mqh>

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
};

#endif