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

//int sum(int a, int b) {
//    return a + b;
//}

#define EOF (-1)

#ifdef __cplusplus    // If used by C++ code, 
extern "C" {          // we need to export the C interface
#endif

    __declspec(dllexport) int multiply(int a, int b)
    {
        return a * b;
    }

    __declspec(dllexport) int blurGauss(int height, int width, std::vector<unsigned char> &v)
    {
        int index = 0;
        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                v[index++] * 1;;
                v[index++] * 2;;
                v[index++] * 3;;
            }
        }
        return index;
    }

    __declspec(dllexport) int kernel[3][3] = { 1, 2, 1,
               2, 4, 2,
               1, 2, 1 };

    __declspec(dllexport) int accessPixel(std::vector<unsigned char>& result, int col, int row, int k, int width, int height)
    {
        int sum = 0;
        int sumKernel = 0;

        for (int j = -1; j <= 1; j++)
        {
            for (int i = -1; i <= 1; i++)
            {
                //Jeśli jestem w obszarze obrazka
                if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
                {
                    int color = result[(row + j) * 3 * width + (col + i) * 3 + k];
                    sum += color * kernel[i + 1][j + 1];
                    sumKernel += kernel[i + 1][j + 1];
                }
            }
        }

        return sum / sumKernel;
    }

    __declspec(dllexport) void guassian_blur2D(std::vector<unsigned char>& result, int width, int startHeight, int endHeight)
    {
        for (int row = startHeight; row < endHeight; row++)
        {
            for (int col = 0; col < width; col++)
            {
                //Brany każdy piksel
                for (int k = 0; k < 3; k++)
                {
                    result[3 * row * width + 3 * col + k] = accessPixel(result, col, row, k, width, endHeight);
                }
            }
        }
    }


#ifdef __cplusplus
}
#endif