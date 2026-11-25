//Row size v1.1

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
         for (int i = size; i < index + 1; ++i)
         {
            _widths[i] = 0;
         }
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }

   int GetTotalWidth()
   {
      int width = 0;
      int count = ArraySize(_widths);
      for (int i = 0; i < count; ++i)
      {
         width += _widths[i];
      }
      return width;
   }
};