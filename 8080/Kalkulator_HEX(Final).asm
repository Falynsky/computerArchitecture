	 ORG 800H  
	 LXI H,ZACH1 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 CALL PIERW  
ZLYZNAK  
	 CALL ZNAK  
	 JMP LICZ  
	 JMP WYNIK  
PIERW  
	 LXI H,ZACH2 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 RST 5 ;z klawy do D E  
	 MOV B,D ; D -> B  
	 MOV C,E ; E -> C  
	 RET  
ZNAK  
	 LXI H,ZACH3 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 RST 2 ; znak do A  
	 RET  
DRUG  
	 LXI H,ZACH4 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 RST 5 ;z klawy do D E  
	 LXI H,ZACH5 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 XCHG ;zamiana D E z H L  
	 RET  
LICZ  
	 CPI 'n' ; A - 'n'  
	 JZ NEG ; if Flaga Z = 1  
	 CPI '+' ;Odjecie od A wart chara  
	 JZ DODAJ ;if Z = 1 then do  
	 CPI '-' ;Odjecie od A wart chara  
	 JZ ODEJMIJ ;if Z = 1 then do  
	 JMP ZLYZNAK  
NEG  
	 LXI H,ZACH5 ; przesyl danych z 2 i 3 bajtu do pary rej  
	 RST 3 ; wydruk lancucha az '@'  
	 MOV A,B ; B ->A  
	 CMA ; dopelnienie zawartosci akumulatora A <- ~A  
	 RST 4 ; wydruk pary hex z A na monitro  
	 MOV A,C ; B ->A  
	 CMA ; dopelnienie zawartosci akumulatora A <- ~A  
	 RST 4 ; wydruk pary hex z A na monitro  
	 HLT  
DODAJ  
	 CALL DRUG  
	 DAD B ; dodaj do H L pare B = B C  
	 JC PRZEPDOD ; if CY = 1 to skok  
	 JMP WYNIK  
ODEJMIJ  
	 CALL DRUG  
	 MOV A,C ; C -> A  
	 CMC ; CY <- 0  
	 SUB L ; A - L  
	 JC ODEJMIJPORZMLOD ; if CY = 1  
	 MOV E,A ; A - > E  
	 MOV A,B ; B -> A  
	 SUB H ; A - H  
	 JC ODEJMIJPORZSTAR ; if CY = 1  
	 MOV H,A ; A - > H  
	 MOV L,E ; E - > L  
	 JMP WYNIK ; skok do wynik  
ODEJMIJPORZMLOD  
	 CMC ; CY <- 0  
	 MOV E,A ; A -> E  
	 MOV A,B ;B -> A  
	 SUB H ;A - H  
	 JZ ZZMW ;jesli wynik 0 to negacja  
	 DCR A ; A <- (A) - 1  
	 JC ODEJMIJPORZSTAR ; if CY = 1 to skok  
	 MOV H,A ; A -> H  
	 MOV L,E ; E - > L  
	 JMP WYNIK  
ODEJMIJPORZSTAR  
	 CMC ; CY <- 0  
	 MOV A,L ; L -> A  
	 SUB C ; A - C  
	 MOV L,A ; A -> L  
	 MOV A,H ; H -> A  
	 SBB B ; A - B  
	 MOV H,A ; A -> H  
	 JMP MINUS ; if S = 1 to skok  
WYNIK  
	 MOV A,H ; H - > A  
	 RST 4 ; wydruk pary hex z A na monitro  
	 MOV A,L ; L - > A  
	 RST 4 ; wydruk pary hex z A na monitro  
	 HLT  
MINUS  
	 MVI A,'-' ; '-' - > A  
	 RST 1 ; wydruk znaku z A na monitor  
	 JMP WYNIK  
PRZEPDOD  
	 MVI A,'1' ; A <- '1'  
	 RST 1 ; wydruk znaku z A na monitor  
	 RET  
ZZMW  
	 MOV H,A ; A -> H  
	 MOV A,E ; E -> A  
	 CMA ; A <- ~A  
	 INR A ; konieczne zwiekszenie A o 1  
	 MOV L,A ; A -> L  
	 JMP MINUS  
ZACH1 	 DB 'kalkulator liczb hex',10,13,'@'  
ZACH2 	 DB 'podaj pierwsza liczbe',10,13,'@'  
ZACH3 	 DB 10,13,'podaj operator (+,-,n)',10,13,'@'  
ZACH4 	 DB 10,13,'podaj druga liczbe'10,13,'@'  
ZACH5 	 DB 10,13,'wynik wynosi:',10,13,'@'  
