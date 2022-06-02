    section .text
    global mystrlen
mystrlen:
push ebp
mov ebp, esp
mov eax, [ebp+8] ; argument – wskaźnik na łańcuch
lop1:
    mov dl, [eax] ; kolejny bajt łańcucha
    inc eax ; inkrementacja adresu
    test dl, dl ; test czy bajt = 0
    jnz lop1 ; nie – następny bajt
    dec eax ; cofnięcie wskaźnika o 1
    sub eax, [ebp+8] ; odjęcie adresu początku łańcucha
pop ebp
ret