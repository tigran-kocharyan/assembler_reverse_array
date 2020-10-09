; Кочарян Тигран Самвелович БПИ199 Вариант 10
; Разработать программу, которая вводит одномерный массив A[N],
; формирует из элементов массива A новый массив B по правилам,
; указанным в таблице, и выводит его. Память под массивы может
; выделяться как статически, так и динамически по выбору разработчика.
; Разбить решение задачи на функции следующим образом:
;   1)Ввод и вывод массивов оформить как подпрограммы.
;   2)Выполнение задания по варианту оформить как процедуру
;   3)Организовать вывод как исходного, так и сформированного массивов
; Массив B из элементов A в обратном порядке

format PE console
entry start

include 'include\win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strArraySize      db 'Size of Array A? ', 0
        strArrayOutputA   db 10, 'Array A: ', 10, 0
        strArrayOutputB   db 10, 'Array B: ', 10, 0
        strIncorrectSize  db 'Incorrect or exceeded size of array = %d', 10, 0
        strArrayElement   db '[%d]? ', 0
        strScanInt        db '%d', 0
        strArrElemOut     db '[%d] = %d', 10, 0
        strWrongInfo      db 'Symbols are unsupported', 10, 0
        strWrongFinish    db 'To finish, press any button...', 10, 0

        ;Переменные для итератора, временных объектов, длины массивов, самих массивов
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
; 1) Массив A. Генерация и ввод.
        call ArrayInput
; 2) Массив B. Генерация.
        call GenerateArrayB
; 3) Массив A. Вывод.
        push strArrayOutputA
        call [printf]
        call ArrayOutA
; 4) Массив B. Вывод.
        push strArrayOutputB
        call [printf]
        call ArrayOutB
finish:
        ;Вызов getch и завершение процесса.
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
        ;Провекра данных на валидность.
        cmp eax, 1
        jne WrongInput

;       Сохраняем значение размера массива и вызываем ввод массива.
        mov eax, [arraySize]
        cmp eax, 0
        jg  getArray
;       Проверяем массив на отрицательный размер. Если размер массива >0,
;       Вызываем ввод.

getArrayExit:
        push eax
        push strIncorrectSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

;       Чистим регистр ecx и переносим массив А в регистр ebx.
getArray:
        cmp eax, 100
        jg  getArrayExit
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

        ;Провекра данных на валидность.
        cmp eax, 1
        jne WrongInput

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
;Если происходит ошибка, выводим информацию.
;--------------------------------------------------------------------------
WrongInput:
        ;Вывод сообщения об ошибке.
        push strWrongInfo
        call [printf]
        ;Очистка мусора.
        add esp, 4
        ;Вызов завершения работы
        jmp Finish
;*************************************************завершение работы программы
Finish:
        ;Вывод сообщения о завершении работы.
        push strWrongFinish
        call [printf]
        ;Ожидание нажатия клавиши.
        add esp, 4
        call [getch]
        ;Завершение процесса.
        push 0
        call [ExitProcess]


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