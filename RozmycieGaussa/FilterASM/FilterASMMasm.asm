;ecx - colorsBeforeFilter
;edx - colorsAfterFilter
;r8d - width
;r9d - startHeight
;r10d - endHeight


public MyProc1									;Nazwa procedury assemblerowej
.data											;Deklaracja zmiennych w programie
;TE DANE MOGA BYC GLOBALNE:
maskArray byte 1, 2, 1,							;} 
			   2, 4, 2,							;} ==> Tablica reprezentuj¹ca wartoœci maski dla rozmucia Gaussa
			   1, 2, 1							;}
arrayRowSize qword 3							;Przypisanie do zmiennej arrayRowSize liczby wierszy maski
minusOne dword -1								;Wartoœæ pomocnicza do rejestrów xmm
zero dword 0									;Wartoœæ pomocnicza do rejestrów xmm
one dword 1										;Wartoœæ pomocnicza do rejestrów xmm
two dword 2										;Wartoœæ pomocnicza do rejestrów xmm
three dword 3									;Wartoœæ pomocnicza do rejestrów xmm
colorsAfterFilterHolder qword 0					;Bufor trzymaj¹cy wartoœæ rejestru RDX aby pod koniec programu móc sci¹gn¹æ ze stosu pierwotn¹ wartoœæ

.code											;Rozpoczêcie kodu assemblera
MyProc1 proc									;Nazwa procedury assemblerowej
mov r10d,DWORD PTR[rsp+40]						;Przypisanie do rejestru r10d wartoœci pi¹tego argumentu przekazanego do funkcji assemblerowej czyli endHeight
push rbx										;Od³o¿enie na stos wartoœci spod rejestru rbx
push rsi										;Od³o¿enie na stos wartoœci spod rejestru rsi
push rdi										;Od³o¿enie na stos wartoœci spod rejestru rdi
push rbp										;Od³o¿enie na stos wartoœci spod rejestru rbp
push r12										;Od³o¿enie na stos wartoœci spod rejestru r12
push r13										;Od³o¿enie na stos wartoœci spod rejestru r13	
push r14										;Od³o¿enie na stos wartoœci spod rejestru r14
push r15										;Od³o¿enie na stos wartoœci spod rejestru r15
mov colorsAfterFilterHolder, rdx				;Przypisanie wartoœci rejestru rdx do zmiennej colorsAfterFilterHolder aby potem wróciæ do stanu rejestrów spprzed wywo³ania funcji

loopOverRows:									;for (int row = startHeight; row < endHeight; row++)							poczatek petli po wierszach				
cmp r9d, r10d									;Sprawdz czy row < endHeight 
je filteringDone								;Je¿eli warunek pêtli loopOverRows nie jest spe³niony wyjdŸ z niej
	
	movd xmm0, zero								;Pocz¹tkowo inicjalizuje rejestr xmm0 wartoœci¹ zero, nastêpnie xmm0 = col
	movd xmm1, r8d								;Inicjalizuje rejestr xmm1 wartoœci¹ r8d, wiêc xmm1 = width 
	loopOverColumns:							;for (int col = 0; col < width; col++)											poczatek wierszy po kolumnach
	comisd xmm0, xmm1							;SprawdŸ czy col < width
	je loopOverColumnsDone						;Je¿eli warunek pêtli loopOverColumns nie jest spe³niony wyjdŸ z niej

		movd xmm2, zero							;Inicjalizuje rejestr xmm2 wartoœci¹ zero
		movd xmm3, three						;Inicjalizuje rejestr xmm2 wartoœci¹ trzy
		loopWhichBlursPixels:					;for (int k = 0; k < 3; k++)													Brany ka¿dy piksel przez maske	
		comisd xmm2, xmm3						;SprawdŸ czy k < 3
		je loopWhichBlursPixelsDone				;Je¿eli warunek pêtli loopWhichBlursPixels nie jest spe³niony wyjdŸ z niej

		movd xmm5, zero							;Wpisujê do rejestru xmm5(sum) wartoœæ zero
		movd xmm6, zero							;Wpisujê do rejestru xmm6(sumMask) wartoœæ zero
		movd xmm7, minusOne						;Wpisujê do rejestru xmm7(maskRowIndex) wartoœæ -1
		movd xmm10, minusOne					;Wpisujê do rejestru xmm10(maskRowIndex) wartoœæ -1
		movd xmm9, minusOne						;Wartoœæ pomocnicza dla ujemnych wartoœci rejestrów
			
			movd xmm8, two						;Inicjalizuje rejestr xmm8 wartoœci¹ dwa
			loopOverMaskRows:					;for (int j = -1; j <= 1; j++)
			comisd xmm7, xmm8					;SprawdŸ czy j < 2
			je loopOverMaskRowsDone				;Je¿eli warunek pêtli loopOverMaskRows nie jest spe³niony wyjdŸ z niej
				
				movd xmm10, minusOne			;Wyzerowanie rejestru zawieraj¹cego indeks petli wewnetrznej
				loopOverMaskColumns:			;for (int i = -1; i <= 1; i++)
				comisd xmm10, xmm8				;SprawdŸ czy j < 2
				je loopOverMaskColumnsDone		;Je¿eli warunek pêtli loopOverMaskColumns nie jest spe³niony wyjdŸ z niej

				;Sprawdzenie poprawnoœci ifa	;if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
				mov r11d, r9d					;przypisanie do rejestru r11d aktualnego indeksu wiersza, gdy¿ row = r9d
				movd xmm4, r11					;Wykorzystanie rejestru xmm4 jako bufor na wartoœæ r11
				addsd xmm4, xmm7				;operacja dodania do rejestru xmm4 wartoœci xmm7 => row + j, gdy¿ xmm7 = j
				movd r11, xmm4					;przypisanie do rejestru r11 wartoœci xmm4, (row + j) -> r12
				movd r12, xmm0					;przypisanie do rejestru r12 aktualnego indeksu kolumny, gdy¿ col = r8d
				movd xmm4, r12					;Wykorzystanie rejestru xmm4 jako bufor na wartoœæ r12
				addsd xmm4, xmm10				;operacja dodania do rejestru xmm4 wartoœci xmm10 => col + i, gdy¿ xmm10 = i
				movd r12, xmm4					;przypisanie do rejestru r12 wartoœci xmm4, (col + i) -> r12
				cmp r11d, 0						;Porównanie wartoœci rejestru r11d z zerem, porównanie (row + j) z 0
				jl isFalse						;je¿eli (row + j) < 0 przejdŸ do etykiety isFalse
				cmp r11d, r10d					;Porównanie wartoœci rejestru r11d z r10d, porównanie (row + j) z endHight
				jge isFalse						;je¿eli (row + j) >= endHight przejdŸ do etykiety isFalse
				cmp r12d, 0						;Porównanie wartoœci rejestru r12d z zerem, porównanie (col + i) z 0
				jl isFalse						;je¿eli (col + i) < 0 przejdŸ do etykiety isFalse
				cmp r12d, r8d					;Porównanie wartoœci rejestru r12d z r8d, porównanie (col + i) z width
				jge isFalse						;je¿eli (col + i) >= width przejdŸ do etykiety isFalse
				 
				;Je¿eli if jest spe³niony
				;Lewa strona wyrazenia w tablicy colorsBeforeFilter
				movd xmm11, rax;				;Robie bufor z xmm11 na trzymanie rax, ¿eby wróciæ potem do poprzedniej wartoœci
				mov eax, r11d					;(row + j) -> eax
				mov r11d, 3						;Wpisuje 3 do rejestru r11d
				mul r11d						;(row + j) * 3 -> eax
				mul r8d							;(row + j) * 3 * width -> eax
				mov r11d, eax					;Wpisuje wynik lewe strona wyrazenia w tablicy colorsBeforeFilter do rejestru r11d
				movd rax, xmm11					;wracam rax do poprzedniej wartoœci

				;Prawa strona wyrazenia w tablicy colorsBeforeFilter
				movd xmm11, rax;				;Robie bufor z xmm11 na trzymanie rax, ¿eby wróciæ potem do poprzedniej wartoœci
				mov eax, r12d					;(column + i) -> eax
				mov r12d, 3						;Wpisuje 3 do rejestru r12d
				mul r12d						;(column + i) * 3 -> eax
				mov r12d, eax					;Wpisuje wynik prawa strona wyrazenia w tablicy colorsBeforeFilter do rejestru r12d
				movd rax, xmm11					;wracam eax do poprzedniej wartoœci

				add r11d, r12d					;(row + j) * 3 * width + (column + i) * 3 -> r11d
				movd xmm4, r11					;Wykorzystanie rejestru xmm4 jako bufor na wartoœæ r11
				addsd xmm4, xmm2				;(row + j) * 3 * width + (column + i) * 3 + k -> xmm4
				movd r11, xmm4					;przypisanie do rejestru r11 wartoœci xmm4, (row + j) * 3 * width + (column + i) * 3 + k -> r11
				mov r13b, byte ptr[rcx+r11]		;Zmienna r13b to colour, przypisuje do niej wynik z tablicy colorsBeforeFilter 

				movd r11d, xmm5					;r11d = sum
				mov r12d, r11d					;r12d = sum
				add r11d, r12d					;sum += 
				mov r12, OFFSET maskArray		;przypisanie do rejestu r12 adresu pocz¹tku tablicy maskArray, jest to tablica zawieraj¹ca wartoœci maski rozmywaj¹cej
				movd r15, xmm7					;Przypisanie wartoœci rejestru xmm7 do rejestru r15
				add r15d, 1						;Dodanie do rejestru r15d wartoœci 1
				mov eax, r15d					;}
				mul arrayRowSize				;}
				add r12, rax					;} ===> Odwo³anie do wartoœci tablicy dwuwymarowej, czyli (mask[i + 1][j + 1])	
				movd esi, xmm10					;}
				add esi, 1						;}
				mov al, [r12 + rsi]				;mask[i + 1][j + 1] -> al
				mov r14, rax					;mask[i + 1][j + 1] -> r14 (Wykorzystuje r14 jako bufor)
				mul r13b						;mask[i + 1][j + 1] * colour -> al
				add r11d, eax					;sum += colour * mask[i + 1][j + 1], bo r11 = SUM !!!!!
				movd xmm5, r11d					;(to co wy¿ej) -> sum
				movd r11d, xmm6					;przypisanie wartoœci rejestru xmm6 do rejestru r11d, wiêc r11d = sumMask
				mov r12d, r11d					;przypisanie wartoœci rejestru r11d do rejestru r12d, wiêc r12d = sumMask
				add r11d, r12d					;sumMask +=
				mov eax, r11d					;sumMask += -> eax
				add rax, r14					;sumMask += mask[i + 1][j + 1] -> rax
				movd xmm6, eax					;(to co wy¿ej) -> sumMask

				comisd xmm10, xmm9				;Porównanie wartoœci rejestrów xmm10 oraz xmm9
				je xmm10RegisterIsNegative		;Je¿eli xmm10 == xmm9 przeskocz do etykiety xmm10RegisterIsNegative
				addss xmm10, one				;Dodaj wartoœæ 1 do rejestru xmm10
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns

				;Je¿eli if nie jest spe³niony
				isFalse:						;Pocz¹tek etykiety isFalse
				comisd xmm10, xmm9				;Porównanie wartoœci rejestrów xmm10 oraz xmm9
				je xmm10RegisterIsNegative		;Je¿eli xmm10 == xmm9 przeskocz do etykiety xmm10RegisterIsNegative
				addss xmm10, one				;Dodaj wartoœæ 1 do rejestru xmm10
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns
				
				xmm10RegisterIsNegative:		;Pocz¹tek etykiety xmm10RegisterIsNegative
				movd xmm10, zero				;Wpisz do rejestru xmm10 wartoœæ 0
				jmp loopOverMaskColumns			;Skocz do etykiety loopOverMaskColumns

			loopOverMaskColumnsDone:			;Pocz¹tek etykiety loopOverMaskColumnsDone	
			comisd xmm7, xmm9					;Porównanie wartoœci rejestrów xmm7 oraz xmm9
			je xmm7RegisterIsNegative			;Je¿eli xmm7 == xmm9 przeskocz do etykiety xmm7RegisterIsNegative
			addss xmm7, one						;Dodaj wartoœæ 1 do rejestru xmm7
			jmp loopOverMaskRows				;Skocz do etykiety loopOverMaskRows
			
			xmm7RegisterIsNegative:				;Pocz¹tek etykiety xmm7RegisterIsNegative
			movd xmm7, zero						;Wpisz do rejestru xmm7 wartoœæ 0
			jmp loopOverMaskRows				;Skocz do etykiety loopOverMaskRows

		loopOverMaskRowsDone:					;Pocz¹tek etykiety loopOverMaskRowsDone
		movd eax, xmm5							;przypisanie wartoœci rejestru xmm5 do eax, wiêc sum -> eax
		movd xmm4, r11							;przypisuje wartoœæ r11 do xmm4, robie bufor na r11
		movd r11d, xmm6							;przypsiuje do rejestru r11d wartoœæ spod rejestru xmm6
		div r11d								;dzielê rejest eax przez r11d, wiêc sum / sumMask -> eax
		movd r11d, xmm4;						;Koniec bufora
		movd xmm12, rax							;sum / sumMask -> divisionResult
		mov eax, r9d							;startHeight -> eax
		mul three								;3 * startHeight -> eax
		mul r8d									;3 * startHeight * width -> eax
		mov r11d, eax							;3 * startHeight * width -> r11d
		movd eax, xmm0							;col -> eax
		mul three								;col * 3 -> eax
		mov r12d, eax							;col * 3 -> r12d
		add r11d, r12d							;3 * startHeight * width + col * 3 -> r11d
		movd xmm4, r11							;Przypisanie wartoœci rejestru r11 do xmm4 
		addsd xmm4, xmm2						;3 * startHeight * width + col * 3 + k-> r11d
		movd r11, xmm4							;Przypisanie wartoœci spod rejestru xmm4 do rejestru r11
		movd r15, xmm12							;Przypisanie wartoœci spod rejestru xmm12 do rejestru r15
		mov rdx, colorsAfterFilterHolder		;Wracam wartosc rejestru rdx
		mov byte ptr[rdx + r11], r15b;r15b		;Wpisuj do tablicy colorsAfterFilter piksele po rozmyciu

		addss xmm2, one							;Wpisz do rejestru xmm2 wartoœæ 1
		jmp loopWhichBlursPixels				;Skocz do etykiety loopWhichBlursPixels, czyli wróæ do pêtli loopWhichBlursPixels

	loopWhichBlursPixelsDone:					;Pocz¹tek etykiety loopWhichBlursPixelsDone
	addss xmm0, one								;Dodaje wartoœæ jeden do rejestru xmm0
	jmp loopOverColumns							;Skocz do etykiety loopOverColumns, czyli wróæ do pêtli loopOverColumns

loopOverColumnsDone:							;Pocz¹tek etykiety loopOverColumnsDone
inc r9d											;Zinkrementuj wartoœæ licznika pêtli, czyli rejestru r9d(startHeight)
jmp loopOverRows								;Skocz do etykiety, czyli wróæ do pêtli loopOverRows

filteringDone:									;Pocz¹tek etykiety filteringDone a zarazem koniec pêtli loopOverRows
pop r15											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru r15
pop r14											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru r14
pop r13											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru r13
pop r12											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru r12
pop rbp											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru rbp
pop rdi											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru rdi
pop rsi											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru rsi
pop rbx											;Wróæ ze stosu poprzedni¹ wartoœæ rejestru rbx
ret												;Powrót z procedury
MyProc1 endp									;Koniec procedury MyProc1
end												;Wyjœcie z DDL'ki assemblerowej, koniec assemblerowego maina
