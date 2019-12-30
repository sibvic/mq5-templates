// Trend value cell factory v1.0

#include <ICellFactory.mq5>
#include <TrendValueCell.mq5>

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      return new TrendValueCell(id, x, y, symbol, timeframe);
   }
};
#endif