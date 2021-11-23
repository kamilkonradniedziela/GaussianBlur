;ecx - colorsBeforeFilter
;edx - colorsAfterFilter
;r8d - width
;r9d - startHeight
;r10d - endHeight


public MyProc1

.code
MyProc1 proc
mov r10d,DWORD PTR[rsp+40] ; r10d = endHeight

mov r11d, 0		;start width to loop
loopOverRows:
cmp r9d, r10d
je filteringDone
	
	loopOverColumns:
	cmp r11d, r8d	
	je loopOverColumnsDone
	inc r11d
	jmp loopOverColumns

loopOverColumnsDone:
inc r9d
jmp loopOverRows

filteringDone:

ret
MyProc1 endp
end
