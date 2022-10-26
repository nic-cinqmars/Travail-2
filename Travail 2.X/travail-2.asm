;
;      title 'Counting Program'
;****************************************************************************
; MCU TYPE
;****************************************************************************
	LIST	p=18F4680     ; définit le numéro du PIC pour lequel ce programme sera assemblé
;
;****************************************************************************
; MCU DIRECTIVES   (définit l'état de certains bits de configuration qui seront chargés lorsque le PIC débutera l'exécution)
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

#include	 <p18f4680.inc>	;  La directive "include" permet d'insérer la librairie "p18f4680.inc" dans le présent programme.
				; Cette librairie contient l'adresse de chacun des SFR ainsi que l'identité (nombre) de chaque bit 
				; de configuration portant un nom prédéfini.

ZERO_EQU	equ	0x00	; La directive "equ" permet d'associer une valeur à une étiquette.
				; Ainsi, la valeur 0x00 remplacera l'étiquette ZERO_EQU à chaque
				; endroit où elle apparait dans le programme suivant.
				;   Notes: ZERO_EQU ne représente pas un espace-mémoire. 
				;          ZERO_EQU peut être utilisé pour définir une constante ou une adresse. 

Zone_udata1	udata 0x60 	; La directive "udata" (unsigned data) permet de définir l'adresse du début d'une zone-mémoire
				; de la mémoire-donnée (ici 0x60).
				; Les directives "res" qui suivront, définiront des espaces-mémoire à partir de cette adresse.
				; La zone doit porter un nom unique (ici "ZONE1_UDATA") car on peut en définir plusieurs.
A_octet3	res 1
A_octet2	res 1		; La directive "res" réserve un seul octet qui pourra être référencé à l'aide du mot "COUNT".
A_octet1	res 1		; L'octet sera localisé à l'adresse 0x60 (dans la banque 0).
A_octet0	res 1
B_octet3	res 1
B_octet2	res 1
B_octet1	res 1
B_octet0	res 1
	
Zone_udata2	udata 0x80
	
RST_CODE 	code 000h 	; La directive "code" définit l'adresse de la prochaine instruction qui suit cette directive.
				; Toutes les autres instructions seront positionnées à la suite.
				; Elles formeront une zone dont le nom sera "RST_CODE".
				; Ici, l'instruction "goto" sera donc stockée à l'adresse 000h dans la mémoire-programme. 
				
	goto Start		; Le micro-contrôleur saute à l'adresse-programme définie par l'étiquette "Start".

PRG_CODE 	code 020h	; Ici, la nouvelle directive "code" définit une nouvelle adresse (dans la mémoire-programme) pour 
				; la prochaine instruction. Cette dernière sera ainsi localisée à l'adresse 020h
				; Cette nouvelle zone de code est nommée "PRG_CODE".

Start				; Cette étiquette précède l'instruction "clrf". Elle sert d'adresse destination à l'instruction "goto" apparaissant plus haut.

				
; sequence #1  Observez le contenu (en binaire) des registres WREG et STATUS lors de l'exécution de cette séquence.

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

 
