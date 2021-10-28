// Filter.cpp : Definiuje eksportowane funkcje dla biblioteki DLL.
//

#include "pch.h"
#include "framework.h"
#include "Filter.h"


// To jest przykład wyeksportowanej zmiennej
FILTER_API int nFilter=0;

// To jest przykład wyeksportowanej funkcji.
FILTER_API int fnFilter(void)
{
    return 0;
}

// To jest konstruktor wyeksportowanej klasy.
CFilter::CFilter()
{
    return;
}
