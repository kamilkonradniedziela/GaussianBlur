#pragma once
#include <vector>
#include <string>
#include <cstddef>

//odczytywanie informacji o pliku
class Image
{
private:
    int fileSize;
    wchar_t* pathToTheImg;

    unsigned char* colors;

    unsigned char informationHeader[40];
    unsigned char fileHeader[14];

public:
    Image();
    ~Image();

    void read();
    void save();

    void setColor(float r, float g, float b, int x, int y);
    void setImagePath(wchar_t* n);
    //Color GetColor(int x, int y) const;

    void filter(std::vector<unsigned char>& result, int width, int startHeight, int endHeight);

    const int getHeight() 
    {
        return heightOfImg; 
    }

    int widthOfImg;
    int heightOfImg;
    std::vector<unsigned char> vectorForColors;
    std::vector<unsigned char> getVectorForColors();


    int kernel[3][3] = { 1, 2, 1,
                   2, 4, 2,
                   1, 2, 1 };

    void guassian_blur2D(std::vector<unsigned char> &result, int width, int startHeight, int endHeight)
    {
        for (int row = startHeight; row < endHeight; row++)
        {
            for (int col = 0; col < width; col++)
            {
                //Brany ka¿dy piksel
                for (int k = 0; k < 3; k++)
                {
                    result[3 * row * width + 3 * col + k] = accessPixel(result, col, row, k, width, endHeight);
                }
            }
        }
    }

    int accessPixel(std::vector<unsigned char>& result, int col, int row, int k, int width, int height)
    {
        int sum = 0;
        int sumKernel = 0;

        for (int j = -1; j <= 1; j++)
        {
            for (int i = -1; i <= 1; i++)
            {
                //Jeœli jestem w obszarze obrazka
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

};