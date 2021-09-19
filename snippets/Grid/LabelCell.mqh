// Label cell v2.0

#include <ICell.mqh>

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
   ENUM_BASE_CORNER _corner;
public:
   LabelCell(const string id, const string text, const int x, const int y, ENUM_BASE_CORNER __corner) 
   { 
      _corner = __corner;
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, _corner, ChartWindowFind(), "Arial", font_size); 
   }

   virtual void HandleButtonClicks()
   {
      
   }
};

#endif