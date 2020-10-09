
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
;Запуск отдельных подпрограмм для работы.
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
;Ввод размера и элементов массива А.
;--------------------------------------------------------------------------
ArrayInput:
;       Вводим размер массива А.
        push strArraySize
        call [printf]
        add esp, 4
        push arraySize
        push strScanInt
        call [scanf]
        add esp, 8

;       Сохраняем значение размера массива и вызываем ввод массива.
        mov eax, [arraySize]
        cmp eax, 0
        jg  getArray
;       Проверяем массив на отрицательный размер. Если размер массива >0,
;       Вызываем ввод.

        push eax
        push strIncorrectSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

;       Чистим регистр ecx и переносим массив А в регистр ebx.
getArray:
        xor ecx, ecx             ; ecx = 0
        mov ebx, arrayA          ; ebx = &vec

;       Просим пользователя поэлементно ввести массив А.
getArrayLoop:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        jge endInputArray

        ;Вводим элементы.
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

;       Выходим из подпрограммы.
endInputArray:
        ret


;--------------------------------------------------------------------------
;Генерация массива B согласно условию.
;Регистр esi - это указатель на А.
;Регистр edi - это указатель на конец A.
;Регистр eax - это указатель на B.
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

;       Запускаем поэлементное заполнение массива B.
loopGeneration:
        mov ebx, [edi]
        mov [eax], ebx
        add eax, 4
        sub edi, 4
        cmp esi, edi
        jne loopGeneration
        ;Если условие не выполняется,выходим из подпрограммы.
        pop edi
        pop ebx
        pop esi
        ret

;--------------------------------------------------------------------------
;Вывод в консоль массива А.
;--------------------------------------------------------------------------
ArrayOutA:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, arrayA         ; ebx = &vec

; Вывода элементов.
putArrayLoop:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        ; Переход если равно в endOutputArrayB, если величины равны.
        je endOutputArray
        mov [i], ecx
        ; Выводимый элемент.
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
;Вывод в консоль массива B.
;--------------------------------------------------------------------------
ArrayOutB:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, arrayB         ; ebx = &vec

; Вывода элементов.
putArrayLoopB:
        mov [tmp], ebx
        cmp ecx, [arraySize]
        ; Переход если равно в endOutputArrayB, если величины равны.
        je endOutputArrayB
        mov [i], ecx
        ; Выводимый элемент.
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
;Добавляем все необходимые для работы библиотеки.
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