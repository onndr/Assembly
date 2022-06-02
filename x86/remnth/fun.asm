; odpowiednik funkcji strlen z biblioteki standardowej C
; deklaracja na poziomie C: unsigned mystrlen(const char *s)
    section .text
    global remnth
remnth:
; prolog
    push ebp ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp ; ustanowienie własnego wskaźnika ramki
    ; procedura nie alokuje danych lokalnych na stosie
    ; ciało procedury
    push ebx
    mov eax, [ebp+8] ; char *s - początek łańcucha
    mov ebx, eax     ; też początek łańcucha
    mov dh, [ebp+12]  ; n
    mov dl, 1

loop1:
    mov cl, [eax]
    inc eax
    test cl, cl
    jz end_loop1
    cmp dh, dl
    je skip
    inc dl
    mov [ebx], cl
    inc ebx
    jmp loop1

skip:
    mov dl, 1
    jmp loop1

end_loop1:
    mov [ebx], byte 0
    mov eax, [ebp+8]

pop ebx
pop ebp ; odtworzenie wskaźnika ramki procedury wołającej
ret ; powrót
