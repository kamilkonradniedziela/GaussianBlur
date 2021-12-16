;ecx - colorsBeforeFilter
;edx - colorsAfterFilter
;r8d - width
;r9d - startHeight
;r10d - endHeight


public MyProc1
.data
sum dword 0
sumMask dword ?
maskRowIndex sdword 0
maskRowIndexTemporary sdword 0 ;Zmienna stworzona poniewa� program wpada� w nieskonczona pelte
maskColumnIndex sdword 0

firstColumnLoopVariable dword 0
bluringLoopVariable dword 0
raxBufor qword 0
maskArray byte 1, 2, 1, 
			   2, 4, 2,
			   1, 2, 1
rowIndex qword 1
columnIndex qword 1
arrayOffset qword 0
arrayRowSize qword 3
divisionResult byte 0
three dword 3
colorsAfterFilterHolder qword 0

.code
MyProc1 proc
mov r10d,DWORD PTR[rsp+40] ; r10d = endHeight
push rbx
push rsi
push rdi
push rbp
push r12
push r13
push r14
push r15
mov colorsAfterFilterHolder, rdx
;mov r15b, maskArray + 2*3
;mov r10, OFFSET maskArray
;add r10, 3							POMOCNICZE
;mov rsi, columnIndex
;mov al, [r10 + rsi]
;movd xmm0, 1
loopOverRows:							;for (int row = startHeight; row < endHeight; row++)				poczatek petli po wierszach				
cmp r9d, r10d
je filteringDone
	
	mov firstColumnLoopVariable, 0	;mov r11d, 0		;start width to loop		col = firstColumnLoopVariable
	loopOverColumns:	;poczatek wierszy po kolumnach								for (int col = 0; col < width; col++)
	cmp firstColumnLoopVariable, r8d	
	je loopOverColumnsDone

		mov bluringLoopVariable, 0;mov r12d, 0
		loopWhichBlursPixels:				;Brany ka�dy piksel przez maske				for (int k = 0; k < 3; k++)
		cmp bluringLoopVariable, 3
		je loopWhichBlursPixelsDone

		mov sum, 0
		mov sumMask, 0
		mov maskRowIndex, -1	
		mov maskColumnIndex, -1
			
			loopOverMaskRows:															;for (int j = -1; j <= 1; j++)
			cmp maskRowIndex, 2		;TU BYLO 2 ALE BYLO COS NIE TAK Z PETLA
			je loopOverMaskRowsDone
				
				mov maskColumnIndex, -1	;Trzbea wyzerowac rejestr petli wewnetrznej
				loopOverMaskColumns:													;for (int i = -1; i <= 1; i++)
				cmp maskColumnIndex, 2
				je loopOverMaskColumnsDone
				;movd xmm9, r10d
				;movd xmm0, r10d
				;PCMPEQD xmm9, xmm0

				;Sprawdzenie poprawno�ci ifa											;if ((row + j) >= 0 && (row + j) < height && (col + i) >= 0 && (col + i) < width)
				mov r11d, r9d															;row = r9d
				add r11d, maskRowIndex
				mov r12d, firstColumnLoopVariable															;col = r8d
				add r12d, maskColumnIndex
				cmp r11d, 0
				jl isFalse
				cmp r11d, r10d
				jge isFalse
				cmp r12d, 0
				jl isFalse
				cmp r12d, r8d
				jge isFalse
				 
				;Je�eli if jest spe�niony
				;Lewa strona wyrazenia w tabblicy colorsBeforeFilter
				mov raxBufor, rax;				; Robie bufor z raxBufor na trzymanie eax, �eby wr�ci� potem do poprzedniej warto�ci
				mov eax, r11d					; (row + j) -> eax
				mov r11d, 3						; Wpisuje 3 do rejestru r11d
				mul r11d						; (row + j) * 3 -> eax
				mul r8d							; (row +j) * 3 * width -> eax
				mov r11d, eax					; Wpisuje wynik lewe strona wyrazenia w tablicy colorsBeforeFilter do rejestru r11d
				mov rax, raxBufor				; wracam eax do poprzedniej warto�ci
				;r11d juz zaj�te !!!

				;Prawa strona wyrazenia w tablicy colorsBeforeFilter
				mov raxBufor, rax;				; Robie bufor z raxBufor na trzymanie eax, �eby wr�ci� potem do poprzedniej warto�ci
				mov eax, r12d					; (column + i) -> eax
				mov r12d, 3						; Wpisuje 3 do rejestru r12d
				mul r12d						; (column + i) * 3 -> eax
				mov r12d, eax					; Wpisuje wynik prawa strona wyrazenia w tablicy colorsBeforeFilter do rejestru r12d
				mov rax, raxBufor				; wracam eax do poprzedniej warto�ci
				;r12d juz zaj�te !!!				

				add r11d, r12d					; (row + j) * 3 * width + (column + i) * 3 -> r11d
				add r11d, bluringLoopVariable	; (row + j) * 3 * width + (column + i) * 3 * k -> r11d
				mov r13b, byte ptr[rcx+r11]		; Zmienna r13b to colour, przypisuje do niej wynik z tablicy colorsBeforeFilter                WCZESNIEJ BYLO: ecx+r11d    

				mov r11d, sum					; r11d = sum
				mov r12d, r11d					; r12d = sum
				add r11d, r12d					; sum += 
				mov r12, OFFSET maskArray		;
				mov r15d, maskRowIndex;;
				add r15d, 1;;
				mov eax, r15d					;;
				;add maskRowIndex, 1				;
				;mov eax, maskRowIndex			;
				mul arrayRowSize				;
				add r12, rax					; Przypisuje jak w internecie
				mov esi, maskColumnIndex		; -------------> spos�b na tablice z neta(mask[i + 1][j + 1])							WCZESNIEJ BYLO:   [r12d + esi]
				add esi, 1						;
				mov al, [r12 + rsi]				; mask[i + 1][j + 1] -> al
				mov r14, rax					; mask[i + 1][j + 1] -> r14 (Wykorzystuje r13 jako bufor)	r14?
				mul r13b						; mask[i + 1][j + 1] * colour -> al
				add r11d, eax					; sum += colour * mask[i + 1][j + 1]						R11 = SUM !!!!!
				mov sum, r11d					; (to co wy�ej) -> sum
				mov r11d, sumMask				; r11d = sumMask
				mov r12d, r11d					; r12d = sumMask
				add r11d, r12d					; sumMask +=
				mov eax, r11d					; sumMask += -> eax
				add rax, r14					; sumMask += mask[i + 1][j + 1] -> rax
				mov sumMask, eax				; (to co wy�ej) -> sumMask

				inc maskColumnIndex
				jmp loopOverMaskColumns

				;Je�eli if nie jest spe�niony
				isFalse:
				inc maskColumnIndex
				jmp loopOverMaskColumns

			loopOverMaskColumnsDone:	
			inc maskRowIndex
			jmp loopOverMaskRows
			
		loopOverMaskRowsDone:
		;tutaj return sum/sumMask i trzeba to przypisac
		mov eax, sum							; sum -> eax
		div sumMask								; sum / sumMask -> eax
		mov divisionResult, al					; sum / sumMask -> divisionResult
		mov eax, r9d							; startHeight -> eax
		mul three								; 3 * startHeight -> eax
		mul r8d									; 3 * startHeight * width -> eax
		mov r11d, eax							; 3 * startHeight * width -> r11d
		mov eax, firstColumnLoopVariable		; col -> eax
		mul three								; col * 3 -> eax
		mov r12d, eax							; col * 3 -> r12d
		add r11d, r12d							; 3 * startHeight * width + col * 3 -> r11d
		add r11d, bluringLoopVariable			; 3 * startHeight * width + col * 3 + k-> r11d
		mov r15b, divisionResult
		mov r14b, 1
		mov rdx, colorsAfterFilterHolder		; Wracam wartosc rejestru rdx wyzerowanego przez nule
		mov byte ptr[rdx + r11], r15b;r15b 
		;movd xmm0, r10d ;* r9d * r8d + 3 * r11d + r12d	;r13d index tablicy
		;mov byte ptr[rdx + 0], r10b				;edx to moja tablic, r14d bedzie now� tablic�  
		;mov r14b, byte ptr[rdx + 0]

		inc bluringLoopVariable
		jmp loopWhichBlursPixels

	loopWhichBlursPixelsDone:
	inc firstColumnLoopVariable
	jmp loopOverColumns

loopOverColumnsDone:
inc r9d
jmp loopOverRows

filteringDone:
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rdi
pop rsi
pop rbx
ret
MyProc1 endp
end
