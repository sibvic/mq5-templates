// Interface for a cell factory v2.0

#include <ICell.mqh>

#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual string GetHeader() = 0;
};

#endif