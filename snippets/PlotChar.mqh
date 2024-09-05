// Implementation of PineScript's plotchar
// v1.2

class PlotChar
{
   string _char;
   string _id;
   string _location;
public:
   PlotChar(string ch, string id, string location)
   {
      _char = ch;
      _id = id;
      _location = location;
   }
   void Set(int pos, bool toTrue, color clr = Blue)
   {
      datetime time = iTime(_Symbol, _Period, pos);
      string id = _id + TimeToString(time);
      if (!toTrue)
      {
         ObjectDelete(0, id);
         return;
      }
      ResetLastError();
      double price = GetPrice(pos);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, time);
      ObjectSetDouble(0, id, OBJPROP_PRICE, 1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, _char);
   }
private:
   int GetAnchor()
   {
      if (_location == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_location == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   double GetPrice(int pos)
   {
      if (_location == "abovebar")
      {
         return iHigh(_Symbol, _Period, pos);
      }
      if (_location == "belowbar")
      {
         return iLow(_Symbol, _Period, pos);
      }
      return iClose(_Symbol, _Period, pos);
   }
};