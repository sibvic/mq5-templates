# Variables

PineScript-like variable management system for MQL4. Provides template-based variable classes that handle different data types with proper memory management and initialization tracking.

## SimpleTypeVariable

Template class for managing simple data types (int, double, bool, string, etc.) with initialization tracking and default value support.

**Usage:**
```mql4
// Create a simple type variable with default value
SimpleTypeVariable<double>* priceVar = new SimpleTypeVariable<double>(0.0, NULL);

// Set a value
priceVar.Set(1.2345);

// Check if initialized
if (priceVar.IsInitialized())
{
   double currentPrice = priceVar.Get();
}

// Reset to default
priceVar.Clear();
```

## CustomTypeVariable

Template class for managing complex objects (Box, Line, Label, etc.) with proper memory management using object destructors.

**Usage:**
```mql4
// Create a custom type variable for Box objects
IObjectDestructor<Box*>* boxDestructor = new BoxesCollection::GetDestructor();
CustomTypeVariable<Box>* boxVar = new CustomTypeVariable<Box>(NULL, boxDestructor);

// Set a box object
Box* newBox = BoxesCollection::Create(...);
boxVar.Set(newBox);

// Get the current box
Box* currentBox = boxVar.Get();

// Clear and cleanup
boxVar.Clear();
```

**Memory Management:**
- Automatically handles object destruction using provided destructor
- Supports reference counting with AddRef()/Release()
- Proper cleanup in destructor to prevent memory leaks
