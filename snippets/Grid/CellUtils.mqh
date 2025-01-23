#ifndef CellUtilsIMPL
#define CellUtilsIMPL

void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
{ 
   ObjectDelete(0, nm); 
   ObjectCreate(0, nm, OBJ_LABEL, Window, 0, 0); 
   ObjectSetInteger(0, nm, OBJPROP_CORNER, LabelCorner); 
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, xoff); 
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, yoff); 
   ObjectSetInteger(0, nm, OBJPROP_BACK, false); 
   ObjectSetString(0, nm, OBJPROP_TEXT, text);
   ObjectSetString(0, nm, OBJPROP_FONT, Font);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, LabelColor);
}
#endif