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
    int widthOfImg;
    int heightOfImg;
    unsigned char* colorsBeforeFilter;
    unsigned char* colorsAfterFilter;

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
    //std::vector<unsigned char> getVectorForColors();
};