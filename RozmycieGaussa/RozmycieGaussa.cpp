// RozmycieGaussa.cpp : Definiuje punkt wejścia dla aplikacji.
//

#include "framework.h"
#include "RozmycieGaussa.h"
#include "Image.h"

#include <commdlg.h>
#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>


#define MAX_LOADSTRING 100

#define ID_PRZYCISK1 501
#define ID_PRZYCISK2 502
#define ID_PRZYCISK3 503
#define ID_PRZYCISK4 504
#define ID_PRZYCISK5 505
#define ID_PRZYCISK6 506
#define ID_PRZYCISK7 507
#define ID_PRZYCISK8 508
#define ID_PRZYCISK9 509
#define ID_PRZYCISK10 510
#define ID_PRZYCISK11 511

#define ID_BOX1 512
#define ID_BOX2 513


// Namespace odpowiedzialny za operacje na czasie
using namespace std::literals::chrono_literals;


Image img;

HWND loadImageButton, filterImageButton, frameForLibraryOptions, chBoxAsm, chBoxCpp, frameForThreadNumber, threads1, threads2, threads4, threads8, threads16, threads32, threads64;

// Zmienne globalne:
HINSTANCE hInst;                                // bieżące wystąpienie
WCHAR szTitle[MAX_LOADSTRING];                  // Tekst paska tytułu
WCHAR szWindowClass[MAX_LOADSTRING];            // nazwa klasy okna głównego
typedef HRESULT(CALLBACK* LPFNDLLFUNC)(unsigned char* colorsBeforeFilter, unsigned char* colorsAfterFilter, UINT, UINT, UINT); // DLL function handler

// Przekaż dalej deklaracje funkcji dołączone w tym module kodu:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);





//typedef int(__cdecl* filterAsm)(int, int, int, int); // DDL'ka asemblerowa tymczasowa

// Scieżka do pliku
wchar_t frname[100]; 



int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // TODO: W tym miejscu umieść kod.

    // Inicjuj ciągi globalne
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_ROZMYCIEGAUSSA, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);


 //   /************************************************************************************************/
 //// Call the MyProc1 assembler procedure from the JALib.dll library in static mode
 //   int x = 3, y = 4, z = 0, k = 0, e = 0;
 //   HINSTANCE hDLL = LoadLibrary(L"FilterASM"); // Load JALib.dll library dynamically
 //   LPFNDLLFUNC lpfnDllFunc1; // Function pointer

 //   x = 3, y = 4, z = 0, k = 6, e = 10;
 //   if (NULL != hDLL) {
 //       lpfnDllFunc1 = (LPFNDLLFUNC)GetProcAddress(hDLL, "MyProc1");
 //       if (NULL != lpfnDllFunc1) {
 //           z = lpfnDllFunc1(img.vectorForColors, y, k, e); // Call MyProc1 from the JALib.dll library dynamically
 //       }
 //   }
 //   /***********************************************************************************************/

 //       /************************************************************************************************/
 //// Call the multiply cpp function
 //   HINSTANCE hDLL2 = LoadLibrary(L"Filter"); // Load JALib.dll library dynamically
 //   LPFNDLLFUNC lpfnDllFunc2; // Function pointer

 //   x = 3, y = 4, z = 0;
 //   if (NULL != hDLL2) {
 //       lpfnDllFunc2 = (LPFNDLLFUNC)GetProcAddress(hDLL2, "multiply");
 //       if (NULL != lpfnDllFunc2) {
 //           z = lpfnDllFunc2(x, y); // Call MyProc1 from the JALib.dll library dynamically
 //       }
 //   }
 //   /***********************************************************************************************/


    // Wykonaj inicjowanie aplikacji:
    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_ROZMYCIEGAUSSA));

    MSG msg;

    // Główna pętla komunikatów:
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    return (int) msg.wParam;
}



//
//  FUNKCJA: MyRegisterClass()
//
//  PRZEZNACZENIE: Rejestruje klasę okna.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ROZMYCIEGAUSSA));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_ROZMYCIEGAUSSA);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    return RegisterClassExW(&wcex);
}

//
//   FUNKCJA: InitInstance(HINSTANCE, int)
//
//   PRZEZNACZENIE: Zapisuje dojście wystąpienia i tworzy okno główne
//
//   KOMENTARZE:
//
//        W tej funkcji dojście wystąpienia jest zapisywane w zmiennej globalnej i
//        jest tworzone i wyświetlane okno główne programu.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Przechowuj dojście wystąpienia w naszej zmiennej globalnej


   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   loadImageButton = CreateWindowEx(0, L"BUTTON", L"Wybierz obraz do rozmycia", WS_CHILD | WS_VISIBLE,
       1100, 105, 200, 40, hWnd, (HMENU)ID_PRZYCISK10, hInstance, NULL);

   filterImageButton = CreateWindowEx(0, L"BUTTON", L"Rozmyj obraz", WS_CHILD | WS_VISIBLE,
       1100, 155, 200, 40, hWnd, (HMENU)ID_PRZYCISK11, hInstance, NULL);

   frameForLibraryOptions = CreateWindowEx(0, L"BUTTON", L"Biblioteka ktorej chcesz uzyc:", WS_CHILD | WS_VISIBLE | BS_GROUPBOX,
       50, 100, 400, 100, hWnd, (HMENU)ID_BOX1, hInstance, NULL);

   frameForThreadNumber = CreateWindowEx(0, L"BUTTON", L"Ilosc watkow:", WS_CHILD | WS_VISIBLE | BS_GROUPBOX,
       500, 100, 530, 100, hWnd, (HMENU)ID_BOX2, hInstance, NULL);

   chBoxCpp = CreateWindowEx(0, L"BUTTON", L"Biblioteka C++", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON | WS_GROUP,
       90, 150, 120, 10, hWnd, (HMENU)ID_PRZYCISK1, hInstance, NULL);

   chBoxAsm = CreateWindowEx(0, L"BUTTON", L"Biblioteka asemblerowa", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       240, 150, 180, 10, hWnd, (HMENU)ID_PRZYCISK2, hInstance, NULL);
   
   threads1 = CreateWindowEx(0, L"BUTTON", L"1", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON | WS_GROUP,
       530, 150, 30, 10, hWnd, (HMENU)ID_PRZYCISK3, hInstance, NULL);

   threads2 = CreateWindowEx(0, L"BUTTON", L"2", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       600, 150, 30, 10, hWnd, (HMENU)ID_PRZYCISK4, hInstance, NULL);

   threads4 = CreateWindowEx(0, L"BUTTON", L"4", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       670, 150, 30, 10, hWnd, (HMENU)ID_PRZYCISK5, hInstance, NULL);

   threads8 = CreateWindowEx(0, L"BUTTON", L"8", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       740, 150, 30, 10, hWnd, (HMENU)ID_PRZYCISK6, hInstance, NULL);

   threads16 = CreateWindowEx(0, L"BUTTON", L"16", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       810, 150, 40, 10, hWnd, (HMENU)ID_PRZYCISK7, hInstance, NULL);

   threads32 = CreateWindowEx(0, L"BUTTON", L"32", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       880, 150, 40, 10, hWnd, (HMENU)ID_PRZYCISK8, hInstance, NULL);

   threads64 = CreateWindowEx(0, L"BUTTON", L"64", WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,
       950, 150, 40, 10, hWnd, (HMENU)ID_PRZYCISK9, hInstance, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}


//
//  FUNKCJA: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PRZEZNACZENIE: Przetwarza komunikaty dla okna głównego.
//
//  WM_COMMAND  - przetwarzaj menu aplikacji
//  WM_PAINT    - Maluj okno główne
//  WM_DESTROY  - opublikuj komunikat o wyjściu i wróć
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
        case WM_COMMAND:
        {
            // Nasluchuj menu:
            switch (wParam)
            {
                case ID_PRZYCISK11: 
                {
                    LPFNDLLFUNC lpfnDllFunc; // Function pointer
                    if (IsDlgButtonChecked(hWnd, ID_PRZYCISK1))
                    {
                        MessageBox(hWnd, L"Wybrales biblioteke C++", L"Test", MB_ICONINFORMATION);
                        HINSTANCE hDLL = LoadLibrary(L"Filter"); // Load JALib.dll library dynamically
                           if (NULL != hDLL) 
                           {
                               lpfnDllFunc = (LPFNDLLFUNC)GetProcAddress(hDLL, "blurGauss");
                               if (lpfnDllFunc == NULL) 
                               {
                                   MessageBox(hWnd, L"Nie udało się wczytać biblioteki filtrującej", L"komunikat", MB_ICONINFORMATION);
                               }
                           }
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK2))
                    {
                        MessageBox(hWnd, L"Wybrales biblioteke asemblerowa", L"Test", MB_ICONINFORMATION);
                        HINSTANCE hDLL = LoadLibrary(L"FilterASM"); // Load JALib.dll library dynamically
                        if (NULL != hDLL) 
                        {
                            int z = 0;
                            lpfnDllFunc = (LPFNDLLFUNC)GetProcAddress(hDLL, "MyProc1");
                            if (NULL != lpfnDllFunc) 
                            {
                                //z = lpfnDllFunc(img.vectorForColors, img.widthOfImg, 1, 1); // Call MyProc1 from the JALib.dll library dynamically
                            }
                        }
                    }

                    int threadsNumber = 0;
                    if (IsDlgButtonChecked(hWnd, ID_PRZYCISK3))
                    {
                        MessageBox(hWnd, L"Wybrales 1 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 1;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK4))
                    {
                        MessageBox(hWnd, L"Wybrales 2 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 2;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK5))
                    {
                        MessageBox(hWnd, L"Wybrales 4 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 4;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK6))
                    {
                        MessageBox(hWnd, L"Wybrales 8 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 8;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK7))
                    {
                        MessageBox(hWnd, L"Wybrales 16 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 16;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK8))
                    {
                        MessageBox(hWnd, L"Wybrales 32 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 32;
                    }
                    else if (IsDlgButtonChecked(hWnd, ID_PRZYCISK9))
                    {
                        MessageBox(hWnd, L"Wybrales 64 watki", L"Test", MB_ICONINFORMATION);
                        threadsNumber = 64;
                    }

                    int numberOfRows = img.getHeight();
                    int rowsForThread = numberOfRows / threadsNumber;
                    int restOfRows = numberOfRows % threadsNumber;
                    std::vector<std::thread> threads(threadsNumber);
                    int actualRow = 0;  
                    auto start = std::chrono::high_resolution_clock::now();
                    for (int i = 0; i < threadsNumber; i++)
                    {
                        //Jeżeli nie ma reszty wierszy przydzielaj po równo do każdego wątku, jezeli jest reszta to dodawaj po wierszu do kazdego watku az reszta sie skonczy
                        if (restOfRows != 0)
                        {
                            threads[i] = std::thread(lpfnDllFunc, img.colorsBeforeFilter, img.colorsAfterFilter, img.widthOfImg, actualRow, actualRow + rowsForThread + 1);
                            restOfRows--;
                            actualRow += rowsForThread + 1;
                        }
                        else
                        {
                            threads[i] = std::thread(lpfnDllFunc, img.colorsBeforeFilter, img.colorsAfterFilter, img.widthOfImg, actualRow, actualRow + rowsForThread);
                            actualRow += rowsForThread;
                        }
                    }
                    for (int i = 0; i < threadsNumber; i++)
                    {
                        threads[i].join();
                    }
                    auto end = std::chrono::high_resolution_clock::now();
                    std::chrono::duration<float>duration = end - start;
                    float timeDifference = duration.count();
                    std::string timeResult = "Czas filtrowania to: " + std::to_string(timeDifference) + " sekund";
                    MessageBoxA(hWnd, timeResult.c_str(), "Komunikat", MB_ICONINFORMATION);

                    img.save();

                    break;
                }
                //Wczytaj bitmape
                case ID_PRZYCISK10: 
                {
                    //if (IsDlgButtonChecked(hWnd, ID_PRZYCISK1))
                    
                    LPSTR filebuff = new char[256];
                    OPENFILENAME open = { 0 };

                    open.lStructSize = sizeof(OPENFILENAME);
                    open.hwndOwner = hWnd; //Handle to the parent window
                    open.lpstrFilter = L"Image Files(.jpg|.png|.bmp|.jpeg)\0*.jpg;*.png;*.bmp;*.jpeg\0\0";
                    open.lpstrCustomFilter = NULL;
                    open.lpstrFile = frname;
                    open.lpstrFile[0] = '\0';
                    open.nMaxFile = 256;
                    open.nFilterIndex = 1;
                    open.lpstrInitialDir = NULL;
                    open.lpstrTitle = L"Wybierz obraz\0";
                    open.nMaxFileTitle = strlen("Select an image file\0");
                    open.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_EXPLORER;

                    //Otiwera okno z wyborem pliku
                    if (GetOpenFileName(&open))
                    {
                        //MessageBox(hWnd, open.lpstrFile, L"Info", MB_ICONINFORMATION);
                        
                        img.setImagePath(frname);
                        img.read();
                    }
                    else 
                    {
                        MessageBox(hWnd, open.lpstrFile, L"Komunikat", MB_ICONINFORMATION);
                    }

                    break;
                }
            }

            // Analizuj zaznaczenia menu:
            int wmId = LOWORD(wParam);
            switch (wmId)
            {
            case IDM_ABOUT:
                DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
                break;
            case IDM_EXIT:
                DestroyWindow(hWnd);
                break;
            default:
                return DefWindowProc(hWnd, message, wParam, lParam);
            }
        }
        break;
    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            // TODO: Tutaj dodaj kod rysujący używający elementu hdc...
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// Procedura obsługi komunikatów dla okna informacji o programie.
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}


