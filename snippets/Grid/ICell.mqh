// Interface for a cell v4.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y, int width) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(uint& width, uint& height) = 0;
   virtual bool IsMergeSkipped() { return false; }
   virtual int GetMergeTillColumn() { return -1; }
   virtual int GetMergeTillRow() { return -1; }
   virtual void SetMergeSkip(bool /*skip*/) { }
   virtual void SetMergeSpan(int /*tillColumn*/, int /*tillRow*/) { }
   virtual void ClearMergeSpan() { }
   virtual void SetDrawHeight(int /*height*/) { }
   virtual int GetDrawHeight() { return 0; }
};

#endif