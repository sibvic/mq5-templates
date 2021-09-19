#include <AValueFormatter.mqh>
// Formats value as a contant/fixed text value v1.0

#ifndef FixedTextFormatter_IMP
#define FixedTextFormatter_IMP

class FixedTextFormatter : public AValueFormatter
{
   string _text;
   color _clr;
   color _bgClr;
public:
   FixedTextFormatter(string text, color clr, color bgClr)
   {
      _bgClr = bgClr;
      _text = text;
      _clr = clr;
   }

   virtual string FormatItem(const int period, const datetime date, color& clr, color& bgColor)
   {
      clr = _clr;
      bgColor = _bgClr;
      return _text;
   }
};

#endif