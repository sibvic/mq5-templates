// Empty cell v1.0

#include <Grid/ICell.mqh>

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw(int x, int y, int width) { }
   virtual void HandleButtonClicks() { }
   virtual void Measure(int& width, int& height)
   {
      width = 0;
      height = 0;
   }
};

#endif