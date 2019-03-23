Progr segment

assume  cs:Progr,ds:dane,ss:stosik

readln proc;
mov ah,0ah ;funkcja wczytujaca z klawiatury
int 21h 
ret
endp

writeln proc
mov ah,09h ;funkcja wypisujaca na ekran
int 21h
ret
endp

isNull proc
lea dx,msg1
call writeln
jmp koniec
ret 
endp

wrongNumber proc
lea dx,msg2
call writeln
jmp koniec
ret 
endp

toBigNumber proc
lea dx,msg3
call writeln
jmp koniec
ret 
endp

Start:	
	mov ax,dane
    mov ds,ax
    mov ax,stosik
	mov ss,ax
	lea sp,szczyt

	lea dx,msg
	call writeln

	lea dx,dlBufora
	call readln
;Wczytywanie liczby----------------------------------------------------------------------
;sprawdzenie czy ciag znakow nie jest pusty, nastepnie kolejne znaki przenosimy do bl
;w sumie na poczatku jest 0 , ale potem beda tam liczby i mnozymy je razy 10 , nastepnie sprawdzamy
;czy doszlo do przepelnienia potem odejmujemy od znaku znak 0 i sprawdzamy wynik czy jest on w zakresie 0-9
;jesli jest to znaczy ze to byla cyfra i dodajemy ja do sumy, zwiekszamy si , a nastepnie wykonujemy kolejna iteracje
;----------------------------------------------------------------------------------------------------
	
	CMP ile,0; sprawdzenie czy podany ciag znakow nie jest pusty, jesli tak to wywolac procedure isNull, jezeli nie skocz do etykiety dalej
	jnz  dalej 
	call isNull
dalej:
	mov si,0; index 0
czyliczba: 
	mov bl,znaki(si); przenies pierwszy znak do rejestru bl
	cmp bl,13; prownuje znak znak z kodem 13 klawisza enter jesli enter to skacz do etykiety koniecLiczby
	jz koniecLiczby
	mov ax,suma ; kopiuj sume do rejestru ax => ax:=suma
	mul dycha; ax:=ax*dycha, czyli * 10 => ax:=ax*10
	jno notOverflow; jezeli brak przepelnienia do skocz do etykiety notOverflow
	call toBigNumber; wywolaj procedure za duza liczba
notOverflow:
	mov suma,ax ; suma:=ax
	sub bl,'0'; bl:=bl-'0'
	mov cyfra,bl; cyfra:=bl
	cmp cyfra,10; jezeli cyfra = lub >10 to wywolaj procedure wrongNumber, jezli 10> to jest liczba i skocz do etykiety isNumber
	jc isNumber
	call wrongNumber
isNumber:
	mov bl,cyfra; bl:=cyfra
	add suma,bx ; suma:=suma+bx
	jnc notOverflow1; jezeli brak przepelnienia to skocz do etykiety notOverflow1
	call toBigNumber; wywolaj procedure toBigNumber
notOverflow1:
	inc si; zwieksz rejestr indeksowy o 1 -> si:=si+1
	cmp si,6; jezli index rowny 6 to idz do etykiety koniecLiczby, jezeli jest mniejszy to skocz do etykiety czyliczba i sprawdzaj kolejne znaki
	jnz czyliczba	
koniecLiczby:

; zamiana z 10 na 2 --------------------------------------------------------------------
;Zamiana liczby w systemie 10 (wynik) na system 2
;Aby wypisac liczbe w postaci binarnej przesuwamy ja o jedno miejsce
;i sprawdzamy znacznik przeniesienia CF.
;Liczba znajduje sie w rejestrze AX, SI jest to pozycja znaku 
;w lancuchu ktora nalezy zmodyfikowac i jednoczesnie licznikiem petli.
;Liczba moze byc zapisana maksymalnie na 16 bitach (0-15) wiec wykonujemy 16 iteracji
;petli.
;========================================================================================

	mov ax,suma ;
	mov si,0
binary: 
	rol ax,1; przesun wartosc AX w lewo => AX*2 
	jc jedynka; jesli nastapilo przeniesienie skocz do etykiety
	jnc zero; jesli nie bylo przeniesienia skocz do etykiety
dalejBinary: 
	mov liczba2(si),dl
	cmp si,15; porownaj si z 15 (maksymalny numer bitu w rejestrze 16-bitowym )
	je koniecBinary; jesli SI=15 to skocz do etykiety
	inc si; zwieksz SI o 1
	jmp binary;
jedynka: 
	mov dl,31h; kod znaku "1"
	jmp dalejBinary;
zero: 
	mov dl,30h; kod znaku "0"
	jmp dalejBinary;
koniecBinary:
	mov liczba2(16),'$'
			
; zamiana z 10 na 16 ------------------------------------------------------------------
;zamiana z systemu 10 na 16
; w tym bloku kodu programu rejestr CL pelni role licznika przesuniecia 
;logicznego wartosci liczby, rejestr CH jest ogolnym licznikiem petli 
;natomiast si jest wskazaniem pozycji w lancuchu tekstu ktory ma byc zmieniony
;przygotowanie rejestrow 
;=======================================================================================

	xor cl,cl; zerowanie przesuniecia logicznego
	mov ch,3; ustaw licznik na 3
	mov si,3; ustaw index na 3
hexa: 
	mov ax,suma;
	ror ax,cl; przesuniecie rejestru ax o cl miejsc w prawo =>AX:=AX/(2^CL)
	and ax,1111b; maska 4 bitów
	cmp al,9; porownanie liczby z 9
	ja litery; jesli liczba > 9 to skocz do etykiety litery 
	add al,30h; w przeciwnym wypadku do liczby dodaj kod ASCII znaku '0' 
dalejHexa: 
	mov liczba16(si),al; przekazanie znaku do zmiennej lancuchowej
	cmp ch,0; porownaj licznik z 0
	je koniecHexa; jesli licznik = 0 to wyjdz z petli
	dec si; si:=si-1;
	dec ch; zmniejsz licznik o 1;
	add cl,4; zwieksz wartosc przesuniecia 0 4 
	jmp hexa; nastepna iteracja
litery:
	sub al,10; od liczby odejmnij 10;
	add al,'A'; do liczby dodaj kod ASCII znaku 'A'
	jmp dalejHexa; skocz do etykiety
koniecHexa:
	mov liczba16(4),'H' ; przekazanie znaku do zmiennej lancuchowej
	mov liczba16(5),'$' ; przekazanie znaku do zmiennej lancuchowej

; wypiswanie liczby 10, 2, 16 ---------------------------------------------------------
	mov al,dlBufora
	mov ah,0
	mov si,ax
	mov znaki(5),'$'
	lea dx,msg4	
	call writeln
	lea dx,znaki(0)
	call writeln	
	lea dx,msg5
	call writeln
	lea dx,liczba2(0)
	call writeln	
	lea dx,msg6
	call writeln
	lea dx,liczba16(0)
	call writeln
	
koniec: 
	lea dx, msg7
	call writeln
	lea dx,dlBufora
	call readln
	mov ah,4Ch
	mov al,0h
	int 21h

Progr ends


dane segment

dlBufora db 6 ;ile znakow wczytca
ile db 0	;ile zostalo wczytanych
znaki db 6 dup (0) ;miejsce na znaki
dycha dw 10 
cyfra db 0 
suma dw 0 
liczba2 db 17 dup(0)
liczba16 db 6 dup(0)

msg db 'Prosze podac liczbe z zakresu od 0 do 65535',10,13,'$'
msg1 db 10,13,'Nic nie zostalo wpisane','$'
msg2 db 'Zle wpisana liczba',10,13,'$'
msg3 db 10,13,'Liczba jest z poza zakresu','$'
msg4 db 10,13,'   Liczba dziesietnie: $'
msg5 db 10,13,'   Liczba binarnie: $'
msg6 db 10,13,'   Liczba hexadecymalnie: $'
msg7 db 10,13,'Aby zakonczyc program wcisnij enter $'

dane ends


stosik segment

		dw 100h dup(0)
szczyt 	label word

stosik ends
end start