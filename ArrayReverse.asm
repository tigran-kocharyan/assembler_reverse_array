
format PE console
entry start

include 'include\win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strArraySize      db 'Size of Array A? ', 0
        strArrayOutputA   db 10, 'Array A: ', 10, 0
        strArrayOutputB   db 10, 'Array B: ', 10, 0
        strIncorrectSize  db 'Incorrect size of array = %d', 10, 0
        strArrayElement   db '[%d]? ', 0
        strScanInt        db '%d', 0
        strArrElemOut     db '[%d] = %d', 10, 0

        arraySize    dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        arrayA       rd 100
        arrayB       rd 100


;--------------------------------------------------------------------------
;������ ��������� ����������� ��� ������.
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) Array A Generation and input.
        call ArrayInput
; 2) Array B Generation.
        call GenerateArrayB
; 3) Array A output
        push strArrayOutputA
        call [printf]
        call ArrayOutA
; 4) Array B output
        push strArrayOutputB
        call [printf]
        call ArrayOutB
finish:
        call [getch]
        push 0
        call [ExitProcess]


;--------------------------------------------------------------------------
;���� ������� � ��������� ������� �.
;--------------------------------------------------------------------------
ArrayInput:
;       ������ ������ ������� �.
        push strArraySize
        call [printf]
        add esp, 4
        push arraySize
        push strScanInt
        call [scanf]
        add esp, 8

;       ��������� �������� ������� ������� � �������� ���� �������.
        mov eax, [arraySize]
        cmp eax, 0
        jg  getArray
;       ��������� ������ �� ������������� ������. ���� ������ ������� >0,
;       �������� ����.

        push eax
        push strIncorrectSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

;       ������ ������� ecx � ��������� ������ � � ������� ebx.
getArray:
        xor ecx, ecx             ; ecx = 0
        mov ebx, arrayA          ; ebx = &vec

;       ������ ������������ ����������� ������ ������ �.
getArrayLoop:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        jge endInputArray

        ;������ ��������.
        mov [i], ecx
        push ecx
        push strArrayElement
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getArrayLoop

;       ������� �� ������������.
endInputArray:
        ret


;--------------------------------------------------------------------------
;��������� ������� B �������� �������.
;������� esi - ��� ��������� �� �.
;������� edi - ��� ��������� �� ����� A.
;������� eax - ��� ��������� �� B.
;--------------------------------------------------------------------------
GenerateArrayB:
        push esi
        push ebx
        push edi

        mov eax, arrayB
        mov edi, arrayA
        mov esi, [arraySize]
        sub esi, 1
        imul esi, 4
        add edi, esi
        mov esi, arrayA
        sub esi, 4

;       ��������� ������������ ���������� ������� B.
loopGeneration:
        mov ebx, [edi]
        mov [eax], ebx
        add eax, 4
        sub edi, 4
        cmp esi, edi
        jne loopGeneration
        ;���� ������� �� �����������,������� �� ������������.
        pop edi
        pop ebx
        pop esi
        ret

;--------------------------------------------------------------------------
;����� � ������� ������� �.
;--------------------------------------------------------------------------
ArrayOutA:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, arrayA         ; ebx = &vec

; ������ ���������.
putArrayLoop:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        ; ������� ���� ����� � endOutputArrayB, ���� �������� �����.
        je endOutputArray
        mov [i], ecx
        ; ��������� �������.
        push dword [ebx]
        push ecx
        push strArrElemOut
        call [printf]
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putArrayLoop

endOutputArray:
        mov esp, [tmpStack]
        ret


;--------------------------------------------------------------------------
;����� � ������� ������� B.
;--------------------------------------------------------------------------
ArrayOutB:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, arrayB         ; ebx = &vec

; ������ ���������.
putArrayLoopB:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        ; ������� ���� ����� � endOutputArrayB, ���� �������� �����.
        je endOutputArrayB
        mov [i], ecx
        ; ��������� �������.
        push dword [ebx]
        push ecx
        push strArrElemOut
        call [printf]
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putArrayLoopB
endOutputArrayB:
        mov esp, [tmpStack]
        ret


;--------------------------------------------------------------------------
;��������� ��� ����������� ��� ������ ����������.
;--------------------------------------------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'include\api\user32.inc'
include 'include\api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
include 'include\api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'