// Następujący blok ifdef jest standardowym sposobem tworzenia makr, które powodują, że eksportowanie
// z biblioteki DLL jest prostsze. Wszystkie pliki w obrębie biblioteki DLL są kompilowane z FILTERASM_EXPORTS
// symbol zdefiniowany w wierszu polecenia. Symbol nie powinien być zdefiniowany w żadnym projekcie
// które korzysta z tej biblioteki DLL. W ten sposób każdy inny projekt, którego pliki źródłowe dołączają ten plik, widzi
// funkcje FILTERASM_API w postaci zaimportowanej z biblioteki DLL, podczas gdy biblioteka DLL widzi symbole
// zdefiniowane za pomocą tego makra jako wyeksportowane.
#ifdef FILTERASM_EXPORTS
#define FILTERASM_API __declspec(dllexport)
#else
#define FILTERASM_API __declspec(dllimport)
#endif

// Ta klasa została wyeksportowana z pliku dll
class FILTERASM_API CFilterASM {
public:
	CFilterASM(void);
	// TODO: w tym miejscu dodaj metody.
};

extern FILTERASM_API int nFilterASM;

FILTERASM_API int fnFilterASM(void);
