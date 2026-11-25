// PineScript display.* bit flags
// v1.0
// none=0, pane=1, data_window=2, price_scale=4, status_line=8, all=15
#ifndef Display_IMPL
#define Display_IMPL

class Display
{
public:
   static const int None;
   static const int Pane;
   static const int DataWindow;
   static const int PriceScale;
   static const int StatusLine;
   static const int All;
};

const int Display::None = 0;
const int Display::Pane = 1;
const int Display::DataWindow = 2;
const int Display::PriceScale = 4;
const int Display::StatusLine = 8;
const int Display::All = 15;

#endif
