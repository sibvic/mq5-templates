// Implementation of PineScript's plotchar
// v1.0

class PlotChar
{
   string _char;
   string _id;
public:
   PlotChar(string ch, string id)
   {
      _char = ch;
      _id = id;
   }
   void set(int pos, bool toTrue)
   {
      datetime time = iTime(_Symbol, _Period, pos);
      string id = _id + TimeToString(time);
      if (!toTrue)
      {
         ObjectDelete(id);
         return;
      }
      ResetLastError();
      double price = iHigh(_Symbol, _Period, pos);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, Blue);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LOWER);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, time);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, _char);
   }
};