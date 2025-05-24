.386
.model flat, stdcall
.stack 4096

.data
    inputBuffer     db 128 dup(0)
    outputBuffer    db 128 dup(0)
    bytesRead       dd 0
    bytesWritten    dd 0
    promptMsg       db "Enter text: ", 0
    shiftVal        db 3
    xorKey          db 5Ah
    newline         db 13, 10

.code

start:

    ; Get handle to stdout (STD_OUTPUT_HANDLE = -11)
    push -11
    call GetStdHandle
    mov ebx, eax    ; store stdout handle in EBX

    ; Get handle to stdin (STD_INPUT_HANDLE = -10)
    push -10
    call GetStdHandle
    mov esi, eax    ; store stdin handle in ESI

    ; Write "Enter text: "
    push 0
    lea eax, bytesWritten
    push eax
    push 12                     ; length of promptMsg
    lea eax, promptMsg
    push eax
    push ebx
    call WriteConsoleA

    ; Read user input
    push 0
    lea eax, bytesRead
    push eax
    push 128
    lea eax, inputBuffer
    push eax
    push esi
    call ReadConsoleA

    ; Encrypt input (Caesar + XOR)
    xor ecx, ecx

encrypt_loop:
    mov al, inputBuffer[ecx]
    cmp al, 13         ; stop at carriage return
    je done_encrypt
    add al, shiftVal
    xor al, xorKey
    mov outputBuffer[ecx], al
    inc ecx
    jmp encrypt_loop

done_encrypt:
    ; Add newline
    mov outputBuffer[ecx], 13
    inc ecx
    mov outputBuffer[ecx], 10
    inc ecx

    ; Write encrypted output
    push 0
    lea eax, bytesWritten
    push eax
    push ecx
    lea eax, outputBuffer
    push eax
    push ebx
    call WriteConsoleA

    ; Exit
    push 0
    call ExitProcess

; ================================
; Windows API Declarations (stdcall)
; ================================

GetStdHandle    proto :dword
ReadConsoleA    proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA   proto :dword, :dword, :dword, :dword, :dword
ExitProcess     proto :dword

END start
