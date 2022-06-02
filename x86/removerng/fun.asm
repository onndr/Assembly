; odpowiednik funkcji strlen z biblioteki standardowej C
; deklaracja na poziomie C: unsigned mystrlen(const char *s)
    section .text
    global removerng
removerng:
; prolog
    push ebp ; zapamiętanie wskaźnika ramki procedury wołającej
    mov ebp, esp ; ustanowienie własnego wskaźnika ramki
    ; procedura nie alokuje danych lokalnych na stosie
    ; ciało procedury
    push ebx
    mov eax, [ebp+8] ; char *s - początek łańcucha
    mov ebx, eax     ; też początek łańcucha
    mov dh, [ebp+12]  ; char a
    mov dl, [ebp+16] ; char b

loop1:
    mov cl, [eax] ; kolejny bajt łańcucha
    inc eax ; inkrementacja adresu
    test cl, cl ; test czy bajt = 0
    jz end_loop1 ; nie – następny bajt
    cmp cl, dl
    ja write
    cmp cl, dh
    jae loop1

write:
    mov [ebx], cl
    inc ebx
    jmp loop1

end_loop1:
    mov [ebx], byte 0
    mov eax, [ebp+8]

pop ebx
pop ebp ; odtworzenie wskaźnika ramki procedury wołającej
ret ; powrót
