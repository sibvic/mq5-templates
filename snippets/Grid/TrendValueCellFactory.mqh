// Trend value cell factory v2.0

#include <ICellFactory.mqh>
#include <TrendValueCell.mqh>
#include <FixedTextFormatter.mqh>

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   TrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
      _outputMode = OutputLabels;
      _alertShift = alertShift;
      _upColor = upColor;
      _downColor = downColor;
      _historicalUpColor = historicalUpColor;
      _historicalDownColor = historicalDownColor;
   }

   void SetNeutralColor(color clr)
   {
      _neutralColor = clr;
   }

   void SetButtonTextColor(color clr)
   {
      _buttonTextColor = clr;
   }

   virtual string GetHeader()
   {
      return "Value";
   }

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new UpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new DownCondition(symbol, timeframe);
      IValueFormatter* downValue = new FixedTextFormatter("Sell", GetTextColor(_downColor), GetBackgroundColor(_downColor));
      IValueFormatter* historyDownValue = new FixedTextFormatter("Sell", GetTextColor(_historicalDownColor), GetBackgroundColor(_historicalDownColor));
      cell.AddCondition(downCondition, downValue, historyDownValue, downValue);
      downCondition.Release();
      downValue.Release();
      historyDownValue.Release();

      return cell;
   }
private:
   color GetTextColor(color clr)
   {
      return _outputMode == OutputLabels ? clr : _buttonTextColor;
   }
   color GetBackgroundColor(color clr)
   {
      return _outputMode != OutputLabels ? clr : _buttonTextColor;
   }
};
#endif