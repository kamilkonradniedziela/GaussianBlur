#include "Image.h"
#include <fstream>

#include "atlbase.h"
#include "atlstr.h"
#include "comutil.h"

Image::Image()
{
}

void Image::setImagePath(wchar_t* n)
{
	pathToTheImg = n;
}

void Image::filter(int start, int end)
{
	//HINSTANCE hDLL2 = LoadLibrary(L"Filter"); // Load JALib.dll library dynamically
	//LPFNDLLFUNC lpfnDllFunc2; // Function pointer

	//x = 3, y = 4, z = 0;
	//if (NULL != hDLL2) {
	//	lpfnDllFunc2 = (LPFNDLLFUNC)GetProcAddress(hDLL2, "multiply");
	//	if (NULL != lpfnDllFunc2) {
	//		z = lpfnDllFunc2(x, y); // Call MyProc1 from the JALib.dll library dynamically
	//	}
	//}
	//TODO


}

Image::~Image()
{
}

void Image::setColor(float r, float g, float b, int x, int y)
{

}

void Image::read()
{
	std::ifstream f;
	CStringA path(pathToTheImg);
	f.open(path, std::ios::in | std::ios::binary);

	if (!f.is_open())
	{
		return;
	}

	const int fileHeaderSize = 14;
	const int informationHeaderSize = 40;
	f.read(reinterpret_cast<char*>(fileHeader), fileHeaderSize);
	f.read(reinterpret_cast<char*>(informationHeader), informationHeaderSize);


	//File header jest trzymany w bajcie 2
	fileSize = fileHeader[2] + (fileHeader[3] << 8) + (fileHeader[4] << 16) + (fileHeader[5] << 24);
	widthOfImg = informationHeader[4] + (informationHeader[5] << 8) + (informationHeader[6] << 16) + (informationHeader[7] << 24);
	heightOfImg = informationHeader[8] + (informationHeader[9] << 8) + (informationHeader[10] << 16) + (informationHeader[11] << 24);

	//OD TAD
	
	const int paddingAmount = ((4 - (widthOfImg * 3) % 4) % 4);

	//do tablicy charow

	vectorForColors.resize(widthOfImg * heightOfImg * 3);

	int indeks = 0;
	for (int y = 0; y < heightOfImg; y++)
	{
		for (int x = 0; x < widthOfImg; x++)
		{
			unsigned char color[3];
			f.read(reinterpret_cast<char*>(color), 3);
			vectorForColors[indeks] = color[0]; 
			indeks++;
			vectorForColors[indeks] = color[1]; 
			indeks++;
			vectorForColors[indeks] = color[2]; 
			indeks++;

		}
		f.ignore(paddingAmount);
	}
	//DO TAD

	f.close();
}

void Image::save()
{
	std::ofstream f;

	CStringA path(pathToTheImg);
	path.Replace(".bmp", "afterGaussianBlurFilter.bmp");
	f.open(path, std::ios::out | std::ios::binary);
	if (!f.is_open())
	{
		return;
	}

	//Nie mo¿e byæ wiêcej ni¿ 3 bajty paddingu!!!
	unsigned char bmpPad[3] = { 0,0,0 };
	const int paddingAmount = ((4 - (widthOfImg * 3) % 4) % 4);

	const int fileHeaderSize = 14;
	const int informationHeaderSize = 40;
	fileSize = fileHeaderSize + informationHeaderSize + widthOfImg * heightOfImg * 3 + paddingAmount * heightOfImg;

	//file type
	fileHeader[0] = 'B';
	fileHeader[1] = 'M';

	//File size
	fileHeader[2] = fileSize;
	fileHeader[3] = fileSize >> 8;
	fileHeader[4] = fileSize >> 16;
	fileHeader[5] = fileSize >> 24;


	fileHeader[6] = 0;
	fileHeader[7] = 0;


	fileHeader[8] = 0;
	fileHeader[9] = 0;


	fileHeader[10] = fileHeaderSize + informationHeaderSize;
	fileHeader[11] = 0;
	fileHeader[12] = 0;
	fileHeader[13] = 0;




	//header size
	informationHeader[0] = informationHeaderSize;
	informationHeader[1] = 0;
	informationHeader[2] = 0;
	informationHeader[3] = 0;

	//Image width
	informationHeader[4] = widthOfImg; //width informarmation
	informationHeader[5] = widthOfImg >> 8;
	informationHeader[6] = widthOfImg >> 16;
	informationHeader[7] = widthOfImg >> 24;

	//Image height
	informationHeader[8] = heightOfImg; //height informarmation
	informationHeader[9] = heightOfImg >> 8;
	informationHeader[10] = heightOfImg >> 16;
	informationHeader[11] = heightOfImg >> 24;
	
	//Planes
	informationHeader[12] = 1; //planes
	informationHeader[13] = 0;
	informationHeader[14] = 24; //bit per pixel
	for (int i = 15; i <= 39; i++)
		informationHeader[i] = 0;

	f.write(reinterpret_cast<char*>(fileHeader), fileHeaderSize);
	f.write(reinterpret_cast<char*>(informationHeader), informationHeaderSize);

	int indeks = 0;
	for (int y = 0; y < heightOfImg; y++)
	{
		for (int x = 0; x < widthOfImg; x++)
		{
			unsigned char b = vectorForColors[indeks]; //b
			indeks++;
			unsigned char g = vectorForColors[indeks]; //g
			indeks++;
			unsigned char r = vectorForColors[indeks]; //r
			indeks++;

			unsigned char color[] = { b, g, r };
			f.write(reinterpret_cast<char*>(color), 3);
		}
		f.write(reinterpret_cast<char*>(bmpPad), paddingAmount);
	}

	f.close();
}

