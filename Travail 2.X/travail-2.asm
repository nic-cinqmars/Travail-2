;
;      title 'Counting Program'
;****************************************************************************
; MCU TYPE
;****************************************************************************
	LIST	p=18F4680     ; d�finit le num�ro du PIC pour lequel ce programme sera assembl�
;
;****************************************************************************
; MCU DIRECTIVES   (d�finit l'�tat de certains bits de configuration qui seront charg�s lorsque le PIC d�butera l'ex�cution)
;****************************************************************************
    CONFIG	OSC = ECIO   
    CONFIG	FCMEN = OFF        
    CONFIG	IESO = OFF       
    CONFIG	PWRT = ON           
    CONFIG	BOREN = OFF        
    CONFIG	BORV = 2          
    CONFIG	WDT = OFF          
    CONFIG	WDTPS = 256       
    CONFIG	MCLRE = ON          
    CONFIG	LPT1OSC = OFF      
    CONFIG	PBADEN = OFF        
    CONFIG	STVREN = ON     
    CONFIG	LVP = OFF         
    CONFIG	XINST = OFF       
    CONFIG	DEBUG = OFF       

#include	 <p18f4680.inc>	;  La directive "include" permet d'ins�rer la librairie "p18f4680.inc" dans le pr�sent programme.
				; Cette librairie contient l'adresse de chacun des SFR ainsi que l'identit� (nombre) de chaque bit 
				; de configuration portant un nom pr�d�fini.

ZERO_EQU	equ	0x00	; La directive "equ" permet d'associer une valeur � une �tiquette.
				; Ainsi, la valeur 0x00 remplacera l'�tiquette ZERO_EQU � chaque
				; endroit o� elle apparait dans le programme suivant.
				;   Notes: ZERO_EQU ne repr�sente pas un espace-m�moire. 
				;          ZERO_EQU peut �tre utilis� pour d�finir une constante ou une adresse. 

ZONE1_UDATA	udata 0x60 	; La directive "udata" (unsigned data) permet de d�finir l'adresse du d�but d'une zone-m�moire
				; de la m�moire-donn�e (ici 0x60).
				; Les directives "res" qui suivront, d�finiront des espaces-m�moire � partir de cette adresse.
				; La zone doit porter un nom unique (ici "ZONE1_UDATA") car on peut en d�finir plusieurs.
Var1		res 1
Var2		res 1
COUNT	 	res 1 		; La directive "res" r�serve un seul octet qui pourra �tre r�f�renc� � l'aide du mot "COUNT".
				; L'octet sera localis� � l'adresse 0x60 (dans la banque 0).

RST_CODE 	code 000h 	; La directive "code" d�finit l'adresse de la prochaine instruction qui suit cette directive.
				; Toutes les autres instructions seront positionn�es � la suite.
				; Elles formeront une zone dont le nom sera "RST_CODE".
				; Ici, l'instruction "goto" sera donc stock�e � l'adresse 000h dans la m�moire-programme. 
				
	goto Start		; Le micro-contr�leur saute � l'adresse-programme d�finie par l'�tiquette "Start".

PRG_CODE 	code 020h	; Ici, la nouvelle directive "code" d�finit une nouvelle adresse (dans la m�moire-programme) pour 
				; la prochaine instruction. Cette derni�re sera ainsi localis�e � l'adresse 020h
				; Cette nouvelle zone de code est nomm�e "PRG_CODE".

Start				; Cette �tiquette pr�c�de l'instruction "clrf". Elle sert d'adresse destination � l'instruction "goto" apparaissant plus haut.

				
; sequence #1  Observez le contenu (en binaire) des registres WREG et STATUS lors de l'ex�cution de cette s�quence.

    movlw B'10000001'
    movwf Var1
    movlw B'10000010'
    
    mulwf Var1  ; on notera que le bit le plus significatif de PRODH est '0'
    
    nop

    movlw B'11110001'
    movwf Var1
    movlw B'11110010'
    
    mulwf Var1   ; on notera que le bit le plus significatif de PRODH est '1'
    
    nop
    end

 
