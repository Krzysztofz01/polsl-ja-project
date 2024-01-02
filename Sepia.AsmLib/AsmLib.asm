.data
zero real8 0.00;
r_r  real8 0.39;
r_g  real8 0.77;
r_b  real8 0.19;
g_r  real8 0.35;
g_g  real8 0.69;
g_b  real8 0.17;
b_r  real8 0.27;
b_g  real8 0.53;
b_b  real8 0.13;

.code

ProcessPart proc
;push rax
;push rcx
;push rdx
;push r8
;push xmm0

push rax
push rcx
push rdx
push rsi
push r12
push r13
push r14
push r15

;sub rsp, 32
;movaps [rsp], xmm0
;movaps [rsp + 16], xmm1


; int RCX, RDX, R8, R9,
; float XMM0, XMM1, XMM2, XMM3

mov rax, 4			; Akumulator ustawiamy na 4 aby przemno¿yæ przez ilosc pikseli do pominiecia
mul rdx				; Mno¿ymy iloœc pikseli raz 4 aby uzyskaæ iloœæ bajtów (do pominecia)
mov rdx, rax		; Iloœc bajtów do pominiecia przenosimy z akumulatora do rdx

; == TAK BYLO ==
;mov rax, 0			; Akumulator, od teraz licznik petli iterujacej po bajtach obrazu, ustawiamy na 0
; == TAK JEST ==
mov r15, 1

;mov rsi, 0			; Zerujemy rejestr w ktorym bedziemy prowadzic obliczenia bajtow

; == TAK BYLO ==
;cmp eax, r8d		; Jeœli wartoœæ licznika jest wieksza niz ilosc bajtow do iteracji wychodzimy z petli
;jge LoopFinished	;
; == TAK JEST ==
cmp r15, r8		; Jeœli wartoœæ licznika jest wieksza niz ilosc bajtow do iteracji wychodzimy z petli
jge LoopFinished	;

LoopHead:			; Pocztatek petli iterujacej po bajtach obrazu
; == TAK BYLO ==
;inc rax				; Inkrementujemy licznik
; == TAK JESt ==
inc r15

;push rax			; Przenosimy licznik petli na stos by moc uzywac go do operacji arytmetycznych

xor r12, r12				; Wyzerowanie R12 w celu przechowywania kana³u niebieskiego
mov r12b, [rcx + rdx + 0]	; Ustawienei wartosci kanalu niebieskiego w R12

xor r13, r13				; Wyzerowanie R13 w celu przechoywanai kanalu zielonego
mov r13b, [rcx + rdx + 1]	; Ustawienie wartosci kanalu zielonego w R13

xor r14, r14				; Wyzerowanie R14 w celu przechowywania kanalu czerwonego
mov r14b, [rcx + rdx + 2]	; Ustawienie wartosci kanalu zielonego w R14

;===================================================================================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartosc kanalu niebieskiego

cvtsi2sd xmm1, r12			; Konwersja kana³u niebieskiego na double i zapis w XMM1
mulsd xmm1, b_b				; Mno¿enie kana³u niebieskiego przez wspolczynnik dla kanalu niebieskiego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana³u zielonego na double i zapis w XMM1
mulsd xmm1, b_g				; Mno¿enie kana³u zielonego przez wspolczynnik dla kanalu zielonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana³u czerownego na double i zapis w XMM1
mulsd xmm1, b_r				; Mno¿enie kana³u czerownego przez wspolczynnik dla kanalu czerwonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle blue_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
blue_channel_in_range:

mov [rcx + rdx + 0], sil
;===================================================================================

;===================================================================================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartosc kanalu zielonego

cvtsi2sd xmm1, r12			; Konwersja kana³u niebieskiego na double i zapis w XMM1
mulsd xmm1, g_b				; Mno¿enie kana³u niebieskiego przez wspolczynnik dla kanalu niebieskiego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana³u zielonego na double i zapis w XMM1
mulsd xmm1, g_g				; Mno¿enie kana³u zielonego przez wspolczynnik dla kanalu zielonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana³u czerownego na double i zapis w XMM1
mulsd xmm1, g_r				; Mno¿enie kana³u czerownego przez wspolczynnik dla kanalu czerwonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle green_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
green_channel_in_range:

mov [rcx + rdx + 1], sil
;===================================================================================

;===================================================================================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartosc kanalu czerwonego

cvtsi2sd xmm1, r12			; Konwersja kana³u niebieskiego na double i zapis w XMM1
mulsd xmm1, r_b				; Mno¿enie kana³u niebieskiego przez wspolczynnik dla kanalu niebieskiego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana³u zielonego na double i zapis w XMM1
mulsd xmm1, r_g				; Mno¿enie kana³u zielonego przez wspolczynnik dla kanalu zielonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana³u czerownego na double i zapis w XMM1
mulsd xmm1, r_r				; Mno¿enie kana³u czerownego przez wspolczynnik dla kanalu czerwonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle red_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
red_channel_in_range:

mov [rcx + rdx + 2], sil
;===================================================================================



;mov sil, [rcx + rdx + 1] ; Zapisanie kana³u zielonego w SIL
;mov sil, 255
;mov [rcx + rdx + 1], sil


;mov sil, [rcx + rdx + 2] ; Zapisanie kana³u czerwonego w SIL
;mov sil, 255
;mov [rcx + rdx + 2], sil

;pop rax				; Zdejmujemy wartosc licznika petli ze stosu
add rcx, 4			; Przesuwamy adres tablicy bajtów o 4 aby przejsc do nastpenych 4 batjów RGBA

; == TAK BYLO ==
;cmp rax, r8			; Jeœli wartoœæ licznika jest mniejsza niz ilosc bajtow do iteracji wracamy na poczatek petli
;jl LoopHead			;
; == TAK JEST ==
cmp r15, r8
jl LoopHead

LoopFinished:		; Koniec petli iterujacej po bajtach obrazu

;movaps xmm0, [rsp]
;movaps xmm1, [rsp+16]
;add rsp, 32


pop r15
pop r14
pop r13
pop r12
pop rsi
pop rdx
pop rcx
pop rax

;push xmm0
;push r8
;push rdx
;push rcx
;push rax

ret
ProcessPart endp

end