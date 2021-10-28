// FilterASM.cpp : Definiuje eksportowane funkcje dla biblioteki DLL.
//

#include "pch.h"
#include "framework.h"
#include "FilterASM.h"


// To jest przykład wyeksportowanej zmiennej
FILTERASM_API int nFilterASM=0;

// To jest przykład wyeksportowanej funkcji.
FILTERASM_API int fnFilterASM(void)
{
    return 0;
}

// To jest konstruktor wyeksportowanej klasy.
CFilterASM::CFilterASM()
{
    return;
}
