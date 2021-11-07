.data
sum qword 0
sumMask qword 0
row qword 0
col qword 0

.code
MyProc1 proc
	
	mov row, R8

	loopOverRows:
	cmp row, R9
	je filteringDone
;	jae loopOverColumns
;	jmp loopOverRows
		
		loopOverColumns:
		cmp col, RDX
		je loopOverColumnsDone
		inc col
		jmp loopOverColumns
	
	loopOverColumnsDone:
	inc row
	jmp loopOverRows

filteringDone:
mov RAX, RDX
ret
MyProc1 endp
end




;add RCX, RDX
;add RCX, R8
;add RCX, R9
;mov RAX, RCX