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
        int redSum = 1, greenSum = 0, blueSum = 0;

        int sumMask = 16;

        for (int j = -1; j <= 1; j++)
        {
            for (int i = -1; i <= 1; i++)
            {
                //Jeśli jestem w obszarze obrazka
                //if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
                {
                    //red
                    int redColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 0];
                    redSum += redColor * mask[i + 1][j + 1];

                    //green
                    int greenColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 1];
                    greenSum += greenColor * mask[i + 1][j + 1];

                    //blue
                    int blueColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 2];
                    blueSum += blueColor * mask[i + 1][j + 1];
                    sumMask += mask[i + 1][j + 1];
                }
            }
        }
        return redSum / sumMask;
        //return sum;
    }


    // Funkcja odpowiedzialna za filtrację obrazka metodą Gaussa
    __declspec(dllexport) void blurGauss(unsigned char* colorsBeforeFilter, unsigned char* colorsAfterFilter, int width, int startHeight, int endHeight)
    {
        for (int row = startHeight; row < endHeight; row++)
        {
            for (int col = 0; col < width; col++)
            {
                int redSum = 0, greenSum = 0, blueSum = 0;
                int sumMask = 0;

                for (int j = -1; j <= 1; j++)
                {
                    for (int i = -1; i <= 1; i++)
                    {
                        //Jeśli jestem w obszarze obrazka
                        if ((row + j) >= 0 && (row + j) < endHeight && (col + i) >= 0 && (col + i) < width)
                        {
                            //red
                            int redColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 0];
                            redSum += redColor * mask[i + 1][j + 1];

                            //green
                            int greenColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 1];
                            greenSum += greenColor * mask[i + 1][j + 1];

                            //blue
                            int blueColor = colorsBeforeFilter[(row + j) * 3 * width + (col + i) * 3 + 2];
                            blueSum += blueColor * mask[i + 1][j + 1];
                            sumMask += mask[i + 1][j + 1];
                        }
                    }
                }

                colorsAfterFilter[3 * row * width + 3 * col + 0] = redSum / sumMask;
                colorsAfterFilter[3 * row * width + 3 * col + 1] = greenSum / sumMask;         //Tutaj dzielenie wektorowe
                colorsAfterFilter[3 * row * width + 3 * col + 2] = blueSum / sumMask;
            }
        }
    }


#ifdef __cplusplus
}
#endif