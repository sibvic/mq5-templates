#include <Grid/ACell.mqh>
#include <PineScriptUtils.mqh>

// Label cell v5.0

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   uint _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   uint _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
   bool _mergeSkip;
   int _mergeTillColumn;
   int _mergeTillRow;
   int _drawHeight;
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, uint clr, int windowNumber)
   { 
      _mergeSkip = false;
      _mergeTillColumn = -1;
      _mergeTillRow = -1;
      _drawHeight = 0;
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = GetColorOnly(clr);
      _windowNumber = windowNumber;
   }

   virtual void Measure(uint& width, uint& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         uint w, h;
         ACell::Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y, int width)
   {
      int height = _drawHeight > 0 ? _drawHeight : _height;
      if (_withBackground)
      {
         if (ObjectFind(0, _id + "rect") == -1 && !ObjectCreate(0, _id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0))
         {
            return;
         }
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BACK, true);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      int textY = y;
      if (height > _height)
      {
         textY += (height - _height) / 2;
      }
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, textY, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         textY += _linesHeights[i];
      }
   }
   
   virtual bool IsMergeSkipped() { return _mergeSkip; }
   virtual int GetMergeTillColumn() { return _mergeTillColumn; }
   virtual int GetMergeTillRow() { return _mergeTillRow; }
   virtual void SetMergeSkip(bool skip) { _mergeSkip = skip; }
   virtual void SetMergeSpan(int tillColumn, int tillRow)
   {
      _mergeTillColumn = tillColumn;
      _mergeTillRow = tillRow;
      _mergeSkip = false;
   }
   virtual void ClearMergeSpan()
   {
      _mergeTillColumn = -1;
      _mergeTillRow = -1;
   }
   virtual void SetDrawHeight(int height) { _drawHeight = height; }
   virtual int GetDrawHeight() { return _drawHeight; }
   
   bool SetBgColor(uint clr)
   {
      int transp = GetTranparency(clr);
      clr = GetColorOnly(clr);
      bool withBackground = transp <= 50;
      if (_bgColor == clr && _withBackground == withBackground)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = withBackground;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(uint clr)
   {
      clr = GetColorOnly(clr);
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif