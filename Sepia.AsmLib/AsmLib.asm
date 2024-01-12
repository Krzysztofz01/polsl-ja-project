.data
zero real8 0.00				; Zmienna pomocnicza przechowuj¹ca zerow¹ wartoœæ double
one  real8 1.00				; Zmienna pomocnicza przechowuj¹ca znormalizowan¹ maksymalna wartoœc bajtu jako double
max  real8 255.00			; Zmienna pomocnicza przechowuj¹ca maksymalna wartoœc bajtu jako double
r_r  real8 0.39				; Wspolczynnik kana³u czerwonego do obliczenia sepii kana³u czerwonego
r_g  real8 0.77				; Wspolczynnik kana³u zielonego do obliczenia sepii kana³u czerwonego
r_b  real8 0.19				; Wspolczynnik kana³u niebieskiego do obliczenia sepii kana³u czerwonego
g_r  real8 0.35				; Wspolczynnik kana³u czerwonego do obliczenia sepii kana³u zielonego
g_g  real8 0.69				; Wspolczynnik kana³u zielonego do obliczenia sepii kana³u zielonego
g_b  real8 0.17				; Wspolczynnik kana³u niebieskiego do obliczenia sepii kana³u zielonego
b_r  real8 0.27				; Wspolczynnik kana³u czerwonego do obliczenia sepii kana³u niebieskiego
b_g  real8 0.53				; Wspolczynnik kana³u zielonego do obliczenia sepii kana³u niebieskiego
b_b  real8 0.13				; Wspolczynnik kana³u niebieskiego do obliczenia sepii kana³u niebieskiego

.code
; Definicja wyexporotwanej funkcji, która przyjmuje fragment obrazu w formie jednowymiarowego bufora BGRA i nak³ada efekt sepii
;
; Parametry
; ECX - WskaŸnik pocz¹tku bufora
; EDX - Pocz¹tkowy index do iteracji po buforze (offset)
; R8 - Iloœæ pikseli do iteracji
; XMM3 - Intensywnoœæ efektu sepii
;
ProcessPart proc		
push rax			; Zapisanie parametrów na stosie, w celu mo¿liwoœci odtworzenia stanu rejestrów po zakoñczeniu procedury
push rcx			;
push rdx			;
push rsi			;
push r12			;
push r13			;
push r14			;
push r15			;

mov rax, 4			; Ustawienie akumulatora na 4, aby przemno¿yæ przez t¹ wartoœæ iloœæ pikseli do pominiêcia (jeden pixel = cztery bajty)
mul rdx				; Przemno¿enie parametru iloœæi pikseli przez wartoœæ akumulatora
mov rdx, rax		; Przeniesienie iloczynu tj. ilosci bajtów do RDX

mov r15, 1			; R15 trzyma wartoœæ reprezentuj¹ca liczbê porz¹dkow¹ iteracji (domyœlnie 1)
cmp r15, r8			; Jeœli wartoœæ licznika jest wieksza ni¿ iloœæ bajtów do iteracji wychodzimy z pêtli
jge LoopFinished	;

LoopHead:			; Pocztatek petli iterujacej po bajtach obrazu
inc r15				; Inkrementacja licznika iteracji pêtli

xor r12, r12				; Wyzerowanie R12 w celu przechowywania kana³u niebieskiego
mov r12b, [rcx + rdx + 0]	; Ustawienei wartoœci kana³u niebieskiego w R12

xor r13, r13				; Wyzerowanie R13 w celu przechowywania kana³u zielonego
mov r13b, [rcx + rdx + 1]	; Ustawienie wartoœci kana³u zielonego w R13

xor r14, r14				; Wyzerowanie R14 w celu przechowywania kana³u czerwonego
mov r14b, [rcx + rdx + 2]	; Ustawienie wartoœci kana³u czerwonego w R14

;============================== Kana³ niebieski ==============================	
movsd xmm0, zero			; Wyzerowanie XMM0 gdzie zostanie zsumowana nowa wartoœæ kana³u niebieskiego

cvtsi2sd xmm1, r12			; Konwersja kana³u niebieskiego na double i zapis w XMM1
mulsd xmm1, b_b				; Mno¿enie kana³u niebieskiego przez wspó³czynnik dla kana³u niebieskiego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartosci kana³u niebieskiego

cvtsi2sd xmm1, r13			; Konwersja kana³u zielonego na double i zapis w XMM1
mulsd xmm1, b_g				; Mno¿enie kana³u zielonego przez wspó³czynnik dla kana³u zielonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartoœci kana³u niebieskiego

cvtsi2sd xmm1, r14			; Konwersja kana³u czerownego na double i zapis w XMM1
mulsd xmm1, b_r				; Mno¿enie kana³u czerownego przez wspo³czynnik dla kana³u czerwonego
addsd xmm0, xmm1			; Dodanie sk³adnika niebieskiego do zsumowanej wartoœci kana³u niebieskiego

ucomisd xmm0, max			; Sprawdzenie czty suma kana³ów jest wiêksza ni¿ 255.0				
jb blue_channel_d_in_range	; Jeœli suma kana³ów jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie wartoœci do 255.0
movsd xmm0, max				; Ustawienie sumy kana³ów na 255.0
blue_channel_d_in_range:

cvtsi2sd xmm2, r12			; Konwersja kana³u niebieskiego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia ró¿nicy intensywnoœci efektu
subsd xmm1, xmm3			; Obliczenie ró¿nicy intensywnoœci efektu (proporcja nie zmienionego kana³u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla nie zmienionego kana³u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla zmienionego kana³u
addsd xmm0, xmm1			; Suma wartoœci kana³u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbê ca³kowit¹ i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle blue_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
blue_channel_in_range:

mov [rcx + rdx + 0], sil
;=============================================================================

;=============================== Kana³ zielony ===============================	
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

ucomisd xmm0, max			; Sprawdzenie czty suma kana³ów jest wiêksza ni¿ 255.0				
jb green_channel_d_in_range	; Jeœli suma kana³ów jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie wartoœci do 255.0
movsd xmm0, max				; Ustawienie sumy kana³ów na 255.0
green_channel_d_in_range:

cvtsi2sd xmm2, r13			; Konwersja kana³u zielonego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia ró¿nicy intensywnoœci efektu
subsd xmm1, xmm3			; Obliczenie ró¿nicy intensywnoœci efektu (proporcja nie zmienionego kana³u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla nie zmienionego kana³u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla zmienionego kana³u
addsd xmm0, xmm1			; Suma wartoœci kana³u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle green_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
green_channel_in_range:

mov [rcx + rdx + 1], sil
;=============================================================================

;=============================== Kana³ czerwony ==============================	
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

ucomisd xmm0, max			; Sprawdzenie czty suma kana³ów jest wiêksza ni¿ 255.0				
jb red_channel_d_in_range	; Jeœli suma kana³ów jest w zakresie <= 255.0 wykonujemy skok i pomijamy zmniejszenie wartoœci do 255.0
movsd xmm0, max				; Ustawienie sumy kana³ów na 255.0
red_channel_d_in_range:

cvtsi2sd xmm2, r14			; Konwersja kana³u czerwonego na double i zapis w XMM2
movsd xmm1, one				; Ustawienie wartosci jeden w XMM1 w celu obliczenia ró¿nicy intensywnoœci efektu
subsd xmm1, xmm3			; Obliczenie ró¿nicy intensywnoœci efektu (proporcja nie zmienionego kana³u)
mulsd xmm1, xmm2			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla nie zmienionego kana³u

mulsd xmm0, xmm3			; Iloczyn wyznaczaj¹cy wk³ad w wynik dla zmienionego kana³u
addsd xmm0, xmm1			; Suma wartoœci kana³u zmienionego oraz nie zmienionego. Zapis w XMM0

cvtsd2si rsi, xmm0			; Konwertowanie zmiennoprzecinkowej sumy kana³ow na liczbe calkowita i zapis w RSI

cmp rsi, 255				; Sprawdzenie czy suma kana³ow jest wieksza ni¿ 0xff (255)
jle red_channel_in_range	; Jeœli suma kana³ow jest w zakresie <= 255 wykonujemy skok i pomijamie zmniejszenie wartosci do 255
mov rsi, 255				; Ustawienie sumy kana³ow na 255
red_channel_in_range:

mov [rcx + rdx + 2], sil
;=============================================================================

add rcx, 4					; Przesuniêcie adresu bufora o 4 bajty w celu dostêpu do nastêpnego pixela BGRA
cmp r15, r8					; Sprawdzenie czy wartoœæ licznika jest mniejsza ni¿ iloœæ koniecznych iteracji, skok na pocz¹tek pêtli jeœli dalsza iteracja jest konieczna
jl LoopHead

LoopFinished:				; Koniec petli iterujacej po bajtach obrazu

pop r15						; Zdjêcie parametrów ze stosu w celu przywrócenia pocz¹tkowyc stanów rejestru
pop r14						;
pop r13						;
pop r12						;
pop rsi						;
pop rdx						;
pop rcx						;
pop rax						;

ret							; Zakoñczenie procedury
ProcessPart endp
end