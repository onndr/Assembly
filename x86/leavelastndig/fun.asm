; odpowiednik funkcji strlen z biblioteki standardowej C
; deklaracja na poziomie C: unsigned mystrlen(const char *s)
    section .text
    global leavelastndig
leavelastndig:
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
    cmp dh, "9"
    ja loop1
    cmp dh, "0"
    ja write
    jmp loop1

write:
    mov [ebx], cl
    jmp loop1

correct:
    mov eax, [ebp+8]
    jmp end

end_loop1:
    mov [ebx], byte 0
    sub ebx, [ebp+12]
    mov eax, ebx
    cmp ebx, [ebp+8]
    jl correct

end:
    pop ebx
    pop ebp
    ret
