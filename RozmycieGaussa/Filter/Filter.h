// Następujący blok ifdef jest standardowym sposobem tworzenia makr, które powodują, że eksportowanie
// z biblioteki DLL jest prostsze. Wszystkie pliki w obrębie biblioteki DLL są kompilowane z FILTER_EXPORTS
// symbol zdefiniowany w wierszu polecenia. Symbol nie powinien być zdefiniowany w żadnym projekcie
// które korzysta z tej biblioteki DLL. W ten sposób każdy inny projekt, którego pliki źródłowe dołączają ten plik, widzi
// funkcje FILTER_API w postaci zaimportowanej z biblioteki DLL, podczas gdy biblioteka DLL widzi symbole
// zdefiniowane za pomocą tego makra jako wyeksportowane.
#ifdef FILTER_EXPORTS
#define FILTER_API __declspec(dllexport)
#else
#define FILTER_API __declspec(dllimport)
#endif

// Ta klasa została wyeksportowana z pliku dll
class FILTER_API CFilter {
public:
	CFilter(void);
	// TODO: w tym miejscu dodaj metody.
};

extern FILTER_API int nFilter;

FILTER_API int fnFilter(void);
