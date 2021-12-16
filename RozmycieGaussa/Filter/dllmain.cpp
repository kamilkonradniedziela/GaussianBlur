// dllmain.cpp : Definiuje punkt wejścia dla aplikacji DLL.
#include "pch.h"
#include <vector>

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

#define EOF (-1)

#ifdef __cplusplus    // If used by C++ code, 
extern "C" {          // we need to export the C interface
#endif

    __declspec(dllexport) int multiply(int a, int b)
    {
        return a * b;
    }

    // Maska wykorzystywana do flltracji metodą Gaussa
    int mask[3][3] = { 1, 2, 1,
                         2, 4, 2,
                         1, 2, 1 };

    // Metoda filtrująca każdy piksel obrazka 
    int modifyPixel(unsigned char* colorsBeforeFilter, int col, int row, int k, int width, int height)
    {
        int sum = 0;
        int sumMask = 0;

        for (int j = -1; j <= 1; j++)
        {
            for (int i = -1; i <= 1; i++)
            {
                //Jeśli jestem w obszarze obrazka
                if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
                {
                    int color = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + k];
                    int debug1 = (row + j) * 3 * width + (col + i) * 3 + k;
                    sum += color * mask[i + 1][j + 1];
                    int debug2 = mask[i + 1][j + 1];
                    int debug3 = sum;
                    sumMask += mask[i + 1][j + 1];
                }
            }
        }

        return sum / sumMask;
    }


    // Funkcja odpowiedzialna za filtrację obrazka metodą Gaussa
    __declspec(dllexport) void blurGauss(unsigned char* colorsBeforeFilter, unsigned char* colorsAfterFilter, int width, int startHeight, int endHeight)
    {
        for (int row = startHeight; row < endHeight; row++)
        {
            for (int col = 0; col < width; col++)
            {
                //Brany każdy piksel przez maske
                for (int k = 0; k < 3; k++)
                {
                    colorsAfterFilter[3 * row * width + 3 * col + k] = modifyPixel(colorsBeforeFilter, col, row, k, width, endHeight);
                }
            }
        }
    }


#ifdef __cplusplus
}
#endif