;ecx - colorsBeforeFilter
;edx - colorsAfterFilter
;r8d - width
;r9d - startHeight
;r10d - endHeight


public MyProc1									;Nazwa procedury assemblerowej
.data											;Deklaracja zmiennych w programie
;TE DANE MOGA BYC GLOBALNE:
maskArray byte 1, 2, 1,							;} 
			   2, 4, 2,							;} ==> Tablica reprezentuj�ca warto�ci maski dla rozmucia Gaussa
			   1, 2, 1							;}
arrayRowSize qword 3							;Przypisanie do zmiennej arrayRowSize liczby wierszy maski
minusOne dword -1								;Warto�� pomocnicza do rejestr�w xmm
zero dword 0									;Warto�� pomocnicza do rejestr�w xmm
one dword 1										;Warto�� pomocnicza do rejestr�w xmm
two dword 2										;Warto�� pomocnicza do rejestr�w xmm
three dword 3									;Warto�� pomocnicza do rejestr�w xmm
colorsAfterFilterHolder qword 0					;Bufor trzymaj�cy warto�� rejestru RDX aby pod koniec programu m�c sci�gn�� ze stosu pierwotn� warto��

.code											;Rozpocz�cie kodu assemblera
MyProc1 proc									;Nazwa procedury assemblerowej
mov r10d,DWORD PTR[rsp+40]						;Przypisanie do rejestru r10d warto�ci pi�tego argumentu przekazanego do funkcji assemblerowej czyli endHeight
push rbx										;Od�o�enie na stos warto�ci spod rejestru rbx
push rsi										;Od�o�enie na stos warto�ci spod rejestru rsi
push rdi										;Od�o�enie na stos warto�ci spod rejestru rdi
push rbp										;Od�o�enie na stos warto�ci spod rejestru rbp
push r12										;Od�o�enie na stos warto�ci spod rejestru r12
push r13										;Od�o�enie na stos warto�ci spod rejestru r13	
push r14										;Od�o�enie na stos warto�ci spod rejestru r14
push r15										;Od�o�enie na stos warto�ci spod rejestru r15
mov colorsAfterFilterHolder, rdx				;Przypisanie warto�ci rejestru rdx do zmiennej colorsAfterFilterHolder aby potem wr�ci� do stanu rejestr�w spprzed wywo�ania funcji

loopOverRows:									;for (int row = startHeight; row < endHeight; row++)							poczatek petli po wierszach				
cmp r9d, r10d									;Sprawdz czy row < endHeight 
je filteringDone								;Je�eli warunek p�tli loopOverRows nie jest spe�niony wyjd� z niej
	
	movd xmm0, zero								;Pocz�tkowo inicjalizuje rejestr xmm0 warto�ci� zero, nast�pnie xmm0 = col
	movd xmm1, r8d								;Inicjalizuje rejestr xmm1 warto�ci� r8d, wi�c xmm1 = width 
	loopOverColumns:							;for (int col = 0; col < width; col++)											poczatek wierszy po kolumnach
	comisd xmm0, xmm1							;Sprawd� czy col < width
	je loopOverColumnsDone						;Je�eli warunek p�tli loopOverColumns nie jest spe�niony wyjd� z niej

		mov r11, 0								;
		pinsrd xmm5, r11d, 0					;Wpisuj� do rejestru xmm5[0](redSum) warto�� zero
		mov r11, 0								;
		pinsrd xmm5, r11d, 1					;Wpisuj� do rejestru xmm5[1](greenSum) warto�� zero
		mov r11, 0								;
		pinsrd xmm5, r11d, 2					;Wpisuj� do rejestru xmm5[2](blueSum) warto�� zero
		pinsrd xmm6, zero, 0					;Wpisuj� do rejestru xmm6(sumMask) warto�� zero


		movd xmm7, minusOne						;Wpisuj� do rejestru xmm7(maskRowIndex) warto�� -1
		movd xmm10, minusOne					;Wpisuj� do rejestru xmm10(maskRowIndex) warto�� -1
		movd xmm9, minusOne						;Warto�� pomocnicza dla ujemnych warto�ci rejestr�w
			
			movd xmm8, two						;Inicjalizuje rejestr xmm8 warto�ci� dwa
			loopOverMaskRows:					;for (int j = -1; j <= 1; j++)
			comisd xmm7, xmm8					;Sprawd� czy j < 2
			je loopOverMaskRowsDone				;Je�eli warunek p�tli loopOverMaskRows nie jest spe�niony wyjd� z niej
				
				movd xmm10, minusOne			;Wyzerowanie rejestru zawieraj�cego indeks petli wewnetrznej
				loopOverMaskColumns:			;for (int i = -1; i <= 1; i++)
				comisd xmm10, xmm8				;Sprawd� czy j < 2
				je loopOverMaskColumnsDone		;Je�eli warunek p�tli loopOverMaskColumns nie jest spe�niony wyjd� z niej

				;Sprawdzenie poprawno�ci ifa	;if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
				mov r11d, r9d					;przypisanie do rejestru r11d aktualnego indeksu wiersza, gdy� row = r9d
				movd xmm4, r11					;Wykorzystanie rejestru xmm4 jako bufor na warto�� r11
				addsd xmm4, xmm7				;operacja dodania do rejestru xmm4 warto�ci xmm7 => row + j, gdy� xmm7 = j
				movd r11, xmm4					;przypisanie do rejestru r11 warto�ci xmm4, (row + j) -> r12
				movd r12, xmm0					;przypisanie do rejestru r12 aktualnego indeksu kolumny, gdy� col = r8d
				movd xmm4, r12					;Wykorzystanie rejestru xmm4 jako bufor na warto�� r12
				addsd xmm4, xmm10				;operacja dodania do rejestru xmm4 warto�ci xmm10 => col + i, gdy� xmm10 = i
				movd r12, xmm4					;przypisanie do rejestru r12 warto�ci xmm4, (col + i) -> r12
				cmp r11d, 0						;Por�wnanie warto�ci rejestru r11d z zerem, por�wnanie (row + j) z 0
				jl isFalse						;je�eli (row + j) < 0 przejd� do etykiety isFalse
				cmp r11d, r10d					;Por�wnanie warto�ci rejestru r11d z r10d, por�wnanie (row + j) z endHight
				jge isFalse						;je�eli (row + j) >= endHight przejd� do etykiety isFalse
				cmp r12d, 0						;Por�wnanie warto�ci rejestru r12d z zerem, por�wnanie (col + i) z 0
				jl isFalse						;je�eli (col + i) < 0 przejd� do etykiety isFalse
				cmp r12d, r8d					;Por�wnanie warto�ci rejestru r12d z r8d, por�wnanie (col + i) z width
				jge isFalse						;je�eli (col + i) >= width przejd� do etykiety isFalse
				 
				;Je�eli if jest spe�niony
				;Lewa strona wyrazenia w tablicy colorsBeforeFilter
				movd xmm11, rax;				;Robie bufor z xmm11 na trzymanie rax, �eby wr�ci� potem do poprzedniej warto�ci
				mov eax, r11d					;(row + j) -> eax
				mov r11d, 3						;Wpisuje 3 do rejestru r11d
				mul r11d						;(row + j) * 3 -> eax
				mul r8d							;(row + j) * 3 * width -> eax
				mov r11d, eax					;Wpisuje wynik lewe strona wyrazenia w tablicy colorsBeforeFilter do rejestru r11d
				movd rax, xmm11					;wracam rax do poprzedniej warto�ci

				;Prawa strona wyrazenia w tablicy colorsBeforeFilter
				movd xmm11, rax;				;Robie bufor z xmm11 na trzymanie rax, �eby wr�ci� potem do poprzedniej warto�ci
				mov eax, r12d					;(column + i) -> eax
				mov r12d, 3						;Wpisuje 3 do rejestru r12d
				mul r12d						;(column + i) * 3 -> eax
				mov r12d, eax					;Wpisuje wynik prawa strona wyrazenia w tablicy colorsBeforeFilter do rejestru r12d
				movd rax, xmm11					;wracam eax do poprzedniej warto�ci

				;Sk�adowa RED
				add r11d, r12d					;(row + j) * 3 * width + (column + i) * 3 -> r11d
				movd xmm4, r11					;Wykorzystanie rejestru xmm4 jako bufor na warto�� r11
				addss xmm4, zero				;(row + j) * 3 * width + (column + i) * 3 + 0 -> xmm4
				movd r11, xmm4					;przypisanie do rejestru r11 warto�ci xmm4, (row + j) * 3 * width + (column + i) * 3 + 0 -> r11
				mov r13b, byte ptr[rcx+r11]		;Zmienna r13b to redColour, przypisuje do niej wynik z tablicy colorsBeforeFilter 
				pextrd r11d, xmm5, 0			;r11d = redSum
				mov r12, OFFSET maskArray		;przypisanie do rejestu r12 adresu pocz�tku tablicy maskArray, jest to tablica zawieraj�ca warto�ci maski rozmywaj�cej
				movd r15, xmm7					;Przypisanie warto�ci rejestru xmm7 do rejestru r15
				add r15d, 1						;Dodanie do rejestru r15d warto�ci 1
				mov eax, r15d					;}
				mul arrayRowSize				;}
				add r12, rax					;} ===> Odwo�anie do warto�ci tablicy dwuwymarowej, czyli (mask[i + 1][j + 1])	
				movd esi, xmm10					;}
				add esi, 1						;}
				mov al, [r12 + rsi]				;mask[i + 1][j + 1] -> al
				mov r14, rax					;mask[i + 1][j + 1] -> r14 (Wykorzystuje r14 jako bufor)
				mul r13b						;mask[i + 1][j + 1] * redColour -> al
				add r11d, eax					;redSum += colour * mask[i + 1][j + 1], bo r11 = SUM !!!!!
				pinsrd xmm5, r11d, 0					;(to co wy�ej) -> xmm5[0](redSum)

				;Sk�adowa GREEN
				addss xmm4, one					;(row + j) * 3 * width + (column + i) * 3 + 1 -> xmm4
				movd r11, xmm4					;przypisanie do rejestru r11 warto�ci xmm4, (row + j) * 3 * width + (column + i) * 3 + 1 -> r11
				mov r13b, byte ptr[rcx+r11]		;Zmienna r13b to greenColour, przypisuje do niej wynik z tablicy colorsBeforeFilter 
				pextrd r11d, xmm5, 1			;r11d = greenSum
				mov rax, r14					;mask[i + 1][j + 1] -> rax
				mul r13b						;mask[i + 1][j + 1] * greenColour -> al
				add r11d, eax					;greenSum += greenColour * mask[i + 1][j + 1], bo r11 = SUM !!!!!
				pinsrd xmm5, r11d, 1			;(to co wy�ej) -> xmm5[1](greenSum)

				;Sk�adowa BLUE
				addss xmm4, one					;(row + j) * 3 * width + (column + i) * 3 + 2 -> xmm4
				movd r11, xmm4					;przypisanie do rejestru r11 warto�ci xmm4, (row + j) * 3 * width + (column + i) * 3 + 2 -> r11
				mov r13b, byte ptr[rcx+r11]		;Zmienna r13b to greenColour, przypisuje do niej wynik z tablicy colorsBeforeFilter 
				pextrd r11d, xmm5, 2			;r11d = blueSum
				mov rax, r14					;mask[i + 1][j + 1] -> rax
				mul r13b						;mask[i + 1][j + 1] * blueColour -> al
				add r11d, eax					;blueSum += blueColour * mask[i + 1][j + 1], bo r11 = SUM !!!!!
				pinsrd xmm5, r11d, 2			;(to co wy�ej) -> xmm5[2](blueSum)


				pextrd r11d, xmm6, 0			;przypisanie warto�ci rejestru xmm6 do rejestru r11d, wi�c r11d = sumMask
				mov r12d, r11d					;przypisanie warto�ci rejestru r11d do rejestru r12d, wi�c r12d = sumMask
				mov eax, r11d					;sumMask += -> eax
				add rax, r14					;sumMask += mask[i + 1][j + 1] -> rax
				pinsrd xmm6, eax, 0				;xmm6[0] -> sumMask
				pinsrd xmm6, eax, 1				;xmm6[1] -> sumMask
				pinsrd xmm6, eax, 2				;xmm6[2] -> sumMask

				comisd xmm10, xmm9				;Por�wnanie warto�ci rejestr�w xmm10 oraz xmm9
				je xmm10RegisterIsNegative		;Je�eli xmm10 == xmm9 przeskocz do etykiety xmm10RegisterIsNegative
				addss xmm10, one				;Dodaj warto�� 1 do rejestru xmm10
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns

				;Je�eli if nie jest spe�niony
				isFalse:						;Pocz�tek etykiety isFalse
				comisd xmm10, xmm9				;Por�wnanie warto�ci rejestr�w xmm10 oraz xmm9
				je xmm10RegisterIsNegative		;Je�eli xmm10 == xmm9 przeskocz do etykiety xmm10RegisterIsNegative
				addss xmm10, one				;Dodaj warto�� 1 do rejestru xmm10
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns
				
				xmm10RegisterIsNegative:		;Pocz�tek etykiety xmm10RegisterIsNegative
				movd xmm10, zero				;Wpisz do rejestru xmm10 warto�� 0
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns

			loopOverMaskColumnsDone:			;Pocz�tek etykiety loopOverMaskColumnsDone	
			comisd xmm7, xmm9					;Por�wnanie warto�ci rejestr�w xmm7 oraz xmm9
			je xmm7RegisterIsNegative			;Je�eli xmm7 == xmm9 przeskocz do etykiety xmm7RegisterIsNegative
			addss xmm7, one						;Dodaj warto�� 1 do rejestru xmm7
			jmp loopOverMaskRows				;Skocz do etykiety loopOverMaskRows
			
			xmm7RegisterIsNegative:				;Pocz�tek etykiety xmm7RegisterIsNegative
			movd xmm7, zero						;Wpisz do rejestru xmm7 warto�� 0
			jmp loopOverMaskRows				;Skocz do etykiety loopOverMaskRows

		loopOverMaskRowsDone:					;Pocz�tek etykiety loopOverMaskRowsDone

		divps xmm5, xmm6						;Instrukcja wektorowa, dziele xmm5[0](redSum), xmm5[1](greenSum), xmm5[2](blueSum) przez sumMask
		CVTPS2DQ xmm12, xmm5					;Rzutuje wynik dzielenia z float�w na inty i wpisuje wynik do rejestru xmm12
		mov eax, r9d							;startHeight -> eax
		mul three								;3 * startHeight -> eax
		mul r8d									;3 * startHeight * width -> eax
		mov r11d, eax							;3 * startHeight * width -> r11d
		movd eax, xmm0							;col -> eax
		mul three								;col * 3 -> eax
		mov r12d, eax							;col * 3 -> r12d
		add r11d, r12d							;3 * startHeight * width + col * 3 -> r11d
		movd xmm4, r11							;Przypisanie warto�ci rejestru r11 do xmm4 
		addss xmm4, zero						;3 * startHeight * width + col * 3 + 0-> r11d
		movd r11, xmm4							;Przypisanie warto�ci spod rejestru xmm4 do rejestru r11
		pextrd r15d, xmm12, 0					;Przypisanie warto�ci spod rejestru xmm5 do rejestru r15
		mov rdx, colorsAfterFilterHolder		;Wracam wartosc rejestru rdx
		mov byte ptr[rdx + r11], r15b;r15b		;Wpisuj do tablicy colorsAfterFilter piksele po rozmyciu

		addss xmm4, one							;3 * startHeight * width + col * 3 + 1-> r11d
		movd r11, xmm4							;Przypisanie warto�ci spod rejestru xmm4 do rejestru r11
		pextrd r15d, xmm12, 1					;Przypisanie warto�ci spod rejestru xmm12 do rejestru r15
		mov rdx, colorsAfterFilterHolder		;Wracam wartosc rejestru rdx
		mov byte ptr[rdx + r11], r15b;r15b		;Wpisuj do tablicy colorsAfterFilter piksele po rozmyciu

		addss xmm4, one							;3 * startHeight * width + col * 3 + 2-> r11d
		movd r11, xmm4							;Przypisanie warto�ci spod rejestru xmm4 do rejestru r11
		pextrd r15d, xmm12, 2					;Przypisanie warto�ci spod rejestru xmm5 do rejestru r15
		mov rdx, colorsAfterFilterHolder		;Wracam wartosc rejestru rdx
		mov byte ptr[rdx + r11], r15b;r15b		;Wpisuj do tablicy colorsAfterFilter piksele po rozmyciu

	addss xmm0, one								;Dodaje warto�� jeden do rejestru xmm0
	jmp loopOverColumns							;Skocz do etykiety loopOverColumns, czyli wr�� do p�tli loopOverColumns

loopOverColumnsDone:							;Pocz�tek etykiety loopOverColumnsDone
inc r9d											;Zinkrementuj warto�� licznika p�tli, czyli rejestru r9d(startHeight)
jmp loopOverRows								;Skocz do etykiety, czyli wr�� do p�tli loopOverRows

filteringDone:									;Pocz�tek etykiety filteringDone a zarazem koniec p�tli loopOverRows
pop r15											;Wr�� ze stosu poprzedni� warto�� rejestru r15
pop r14											;Wr�� ze stosu poprzedni� warto�� rejestru r14
pop r13											;Wr�� ze stosu poprzedni� warto�� rejestru r13
pop r12											;Wr�� ze stosu poprzedni� warto�� rejestru r12
pop rbp											;Wr�� ze stosu poprzedni� warto�� rejestru rbp
pop rdi											;Wr�� ze stosu poprzedni� warto�� rejestru rdi
pop rsi											;Wr�� ze stosu poprzedni� warto�� rejestru rsi
pop rbx											;Wr�� ze stosu poprzedni� warto�� rejestru rbx
ret												;Powr�t z procedury
MyProc1 endp									;Koniec procedury MyProc1
end												;Wyj�cie z DDL'ki assemblerowej, koniec assemblerowego maina
