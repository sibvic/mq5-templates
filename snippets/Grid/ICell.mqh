// Interface for a cell v4.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y, int width) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(uint& width, uint& height) = 0;
};

#endif