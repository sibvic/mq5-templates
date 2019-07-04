// Position cap v.1.1
interface IPositionCapStrategy
{
public:
   virtual bool IsLimitHit() = 0;
};

class PositionCapStrategy : public IPositionCapStrategy
{
   int _totalPositions;
   string _symbol;
   bool _useMagicNumber;
   int _magicNumber;
public:
   PositionCapStrategy(const int totalPositions)
   {
      _totalPositions = totalPositions;
      _symbol = "";
      _useMagicNumber = false;
   }

   PositionCapStrategy* WhenSymbol(string symbol)
   {
      _symbol = symbol;
      return &this;
   }

   PositionCapStrategy* WhenMagicNumber(int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   bool IsLimitHit()
   {
      TradesIterator it();
      if (_symbol != "")
         it.WhenSymbol(_symbol);
      if (_useMagicNumber)
         it.WhenMagicNumber(_magicNumber);
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

class NoPositionCapStrategy : public IPositionCapStrategy
{
public:
   bool IsLimitHit()
   {
      return false;
   }
};