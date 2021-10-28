#pragma once
#include <vector>
#include <string>
#include <cstddef>

//odczytywanie informacji o pliku
class Image
{
private:
    int widthOfImg;
    int heightOfImg;
    int fileSize;
    wchar_t* pathToTheImg;
    std::vector<unsigned char> vectorForColors;

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

    void filter(int start, int end);

    const int getHeight() 
    {
        return heightOfImg; 
    }

};