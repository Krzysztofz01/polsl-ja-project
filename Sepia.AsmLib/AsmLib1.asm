.data
zero real8 0.00				; Zmienna pomocnicza przechowuj?ca zerow? warto?? double
one  real8 1.00				; Zmienna pomocnicza przechowuj?ca znormalizowan? maksymalna warto?c bajtu jako double
max  real8 255.00			; Zmienna pomocnicza przechowuj?ca maksymalna warto?c bajtu jako double
r_r  real8 0.39				; Wspolczynnik kana?u czerwonego do obliczenia sepii kana?u czerwonego
r_g  real8 0.77				; Wspolczynnik kana?u zielonego do obliczenia sepii kana?u czerwonego
r_b  real8 0.19				; Wspolczynnik kana?u niebieskiego do obliczenia sepii kana?u czerwonego
g_r  real8 0.35				; Wspolczynnik kana?u czerwonego do obliczenia sepii kana?u zielonego
g_g  real8 0.69				; Wspolczynnik kana?u zielonego do obliczenia sepii kana?u zielonego
g_b  real8 0.17				; Wspolczynnik kana?u niebieskiego do obliczenia sepii kana?u zielonego
b_r  real8 0.27				; Wspolczynnik kana?u czerwonego do obliczenia sepii kana?u niebieskiego
b_g  real8 0.53				; Wspolczynnik kana?u zielonego do obliczenia sepii kana?u niebieskiego
b_b  real8 0.13				; Wspolczynnik kana?u niebieskiego do obliczenia sepii kana?u niebieskiego

.code
; Definicja wyexporotwanej funkcji, kt?ra przyjmuje fragment obrazu w formie jednowymiarowego bufora BGRA i nak?ada efekt sepii
;
; Parametry
; ECX - Wska?nik pocz?tku bufora
; EDX - Pocz?tkowy index do iteracji po buforze (offset)
; R8 - Ilo?? pikseli do iteracji
; XMM3 - Intensywno?? efektu sepii
;
ProcessPart proc		
push rax			; Zapisanie parametr?w na stosie, w celu mo?liwo?ci odtworzenia stanu rejestr?w po zako?czeniu procedury
push rcx			;
push rdx			;
push rsi			;
push r12			;
push r13			;
push r14			;
push r15			;

mov rax, 4			; Ustawienie akumulatora na 4, aby przemno?y? przez t? warto?? ilo?? pikseli do pomini?cia (jeden pixel = cztery bajty)
mul rdx				; Przemno?enie parametru ilo??i pikseli przez warto?? akumulatora
mov rdx, rax		; Przeniesienie iloczynu tj. ilosci bajt?w do RDX

;mov rsi, 0			; (???) Zerujemy rejestr w ktorym bedziemy prowadzic obliczenia bajtow

mov r15, 1			; R15 trzyma warto?? reprezentuj?ca liczb? porz?dkow? iteracji (domy?lnie 1)
cmp r15, r8			; Je?li warto?? licznika jest wieksza ni? ilo?? bajt?w do iteracji wychodzimy z p?tli
jge LoopFinished	;

LoopHead:			; Pocztatek petli iterujacej po bajtach obrazu
inc r15				; Inkrementacja licznika iteracji p?tli

xor r12, r12				; Wyzerowanie R12 w celu przechowywania kana?u niebieskiego
mov r12b, [rcx + rdx + 0]	; Ustawienei warto?ci kana?u niebieskiego w R12

xor r13, r13				; Wyzerowanie R13 w celu przechowywania kana?u zielonego
mov r13b, [rcx + rdx + 1]	; Ustawienie warto?ci kana?u zielonego w R13

xor r14, r14				; Wyzerowanie R14 w celu przechowywania kana?u czerwonego
mov r14b, [rcx + rdx + 2]	; Ustawienie warto?ci kana?u czerwonego w R14

;============================== Kana? niebieski ==============================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa warto?? kana?u niebieskiego

cvtsi2sd xmm1, r12			; Konwersja kana?u niebieskiego na double i zapis w XMM1
mulsd xmm1, b_b				; Mno?enie kana?u niebieskiego przez wsp?czynnik dla kana?u niebieskiego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kana?u niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana?u zielonego na double i zapis w XMM1
mulsd xmm1, b_g				; Mno?enie kana?u zielonego przez wsp?czynnik dla kana?u zielonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej warto?ci kana?u niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana?u czerownego na double i zapis w XMM1
mulsd xmm1, b_r				; Mno?enie kana?u czerownego przez wspo?czynnik dla kana?u czerwonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej warto?ci kana?u niebieskiego

ucomisd xmm0, max			; Sprawdzenie czty suma kana??w jest wi?ksza ni? 255.0				
jb blue_channel_d_in_range	; Je?li suma kana??w jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie warto?ci do 255.0
movsd xmm0, max				; Ustawienie sumy kana??w na 255.0
blue_channel_d_in_range:

cvtsi2sd xmm2, r12			; Konwersja kana?u niebieskiego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia r?nicy intensywno?ci efektu
subsd xmm1, xmm3			; Obliczenie r?nicy intensywno?ci efektu (proporcja nie zmienionego kana?u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj?cy wk?ad w wynik dla nie zmienionego kana?u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj?cy wk?ad w wynik dla zmienionego kana?u
addsd xmm0, xmm1			; Suma warto?ci kana?u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana?ow na liczb? ca?kowit? i zapis w RSI

;cmp rsi, 255				; Sprawdzenie czy suma kana?ow jest wieksza ni? 0xff (255)
;jle blue_channel_in_range	; Je?li suma kana?ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
;mov rsi, 255				; Ustawienie sumy kana?ow na 255
;blue_channel_in_range:

mov [rcx + rdx + 0], sil
;=============================================================================

;=============================== Kana? zielony ===============================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartosc kanalu zielonego

cvtsi2sd xmm1, r12			; Konwersja kana?u niebieskiego na double i zapis w XMM1
mulsd xmm1, g_b				; Mno?enie kana?u niebieskiego przez wspolczynnik dla kanalu niebieskiego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana?u zielonego na double i zapis w XMM1
mulsd xmm1, g_g				; Mno?enie kana?u zielonego przez wspolczynnik dla kanalu zielonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana?u czerownego na double i zapis w XMM1
mulsd xmm1, g_r				; Mno?enie kana?u czerownego przez wspolczynnik dla kanalu czerwonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

ucomisd xmm0, max			; Sprawdzenie czty suma kana??w jest wi?ksza ni? 255.0				
jb green_channel_d_in_range	; Je?li suma kana??w jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie warto?ci do 255.0
movsd xmm0, max				; Ustawienie sumy kana??w na 255.0
green_channel_d_in_range:

cvtsi2sd xmm2, r13			; Konwersja kana?u zielonego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia r?nicy intensywno?ci efektu
subsd xmm1, xmm3			; Obliczenie r?nicy intensywno?ci efektu (proporcja nie zmienionego kana?u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj?cy wk?ad w wynik dla nie zmienionego kana?u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj?cy wk?ad w wynik dla zmienionego kana?u
addsd xmm0, xmm1			; Suma warto?ci kana?u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana?ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana?ow jest wieksza ni? 0xff (255)
jle green_channel_in_range	; Je?li suma kana?ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana?ow na 255
green_channel_in_range:

mov [rcx + rdx + 1], sil
;=============================================================================

;=============================== Kana? czerwony ==============================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartosc kanalu czerwonego

cvtsi2sd xmm1, r12			; Konwersja kana?u niebieskiego na double i zapis w XMM1
mulsd xmm1, r_b				; Mno?enie kana?u niebieskiego przez wspolczynnik dla kanalu niebieskiego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana?u zielonego na double i zapis w XMM1
mulsd xmm1, r_g				; Mno?enie kana?u zielonego przez wspolczynnik dla kanalu zielonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana?u czerownego na double i zapis w XMM1
mulsd xmm1, r_r				; Mno?enie kana?u czerownego przez wspolczynnik dla kanalu czerwonego
addsd xmm0, xmm1			; Dodanie sk?adnika niebieskiego do zsumowanej wartosci kanalu niebieskiego

ucomisd xmm0, max			; Sprawdzenie czty suma kana??w jest wi?ksza ni? 255.0				
jb red_channel_d_in_range	; Je?li suma kana??w jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie warto?ci do 255.0
movsd xmm0, max				; Ustawienie sumy kana??w na 255.0
red_channel_d_in_range:

cvtsi2sd xmm2, r14			; Konwersja kana?u czerwonego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia r?nicy intensywno?ci efektu
subsd xmm1, xmm3			; Obliczenie r?nicy intensywno?ci efektu (proporcja nie zmienionego kana?u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj?cy wk?ad w wynik dla nie zmienionego kana?u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj?cy wk?ad w wynik dla zmienionego kana?u
addsd xmm0, xmm1			; Suma warto?ci kana?u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana?ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana?ow jest wieksza ni? 0xff (255)
jle red_channel_in_range	; Je?li suma kana?ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana?ow na 255
red_channel_in_range:

mov [rcx + rdx + 2], sil
;=============================================================================

add rcx, 4					; Przesuni?cie adresu bufora o 4 bajty w celu dost?pu do nast?pnego pixela BGRA
cmp r15, r8					; Sprawdzenie czy warto?? licznika jest mniejsza ni? ilo?? koniecznych iteracji, skok na pocz?tek p?tli je?li dalsza iteracja jest konieczna
jl LoopHead

LoopFinished:				; Koniec petli iterujacej po bajtach obrazu

pop r15						; Zdj?cie parametr?w ze stosu w celu przywr?cenia pocz?tkowyc stan?w rejestru
pop r14						;
pop r13						;
pop r12						;
pop rsi						;
pop rdx						;
pop rcx						;
pop rax						;

ret							; Zako?czenie procedury
ProcessPart endp
end