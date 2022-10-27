;
;      title 'IEEE-754 Multiplication'
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
	
A_signe		res 1
A_exposant	res 1
A_fraction	res 1
B_signe		res 1
B_exposant	res 1
B_fraction	res 1
Temporaire_octet3	res 1
Temporaire_octet2	res 1
Temporaire_octet1	res 1
Temporaire_octet0	res 1
Resultat_octet3		res 1
Resultat_octet2		res 1
Resultat_octet1		res 1
Resultat_octet0		res 1

RST_CODE 	code 000h 	; La directive "code" définit l'adresse de la prochaine instruction qui suit cette directive.
				; Toutes les autres instructions seront positionnées à la suite.
				; Elles formeront une zone dont le nom sera "RST_CODE".
				; Ici, l'instruction "goto" sera donc stockée à l'adresse 000h dans la mémoire-programme. 
				
	goto Start		; Le micro-contrôleur saute à l'adresse-programme définie par l'étiquette "Start".

PRG_CODE 	code 020h	; Ici, la nouvelle directive "code" définit une nouvelle adresse (dans la mémoire-programme) pour 
				; la prochaine instruction. Cette dernière sera ainsi localisée à l'adresse 020h
				; Cette nouvelle zone de code est nommée "PRG_CODE".
    
Start				; Cette étiquette précède l'instruction "clrf". Elle sert d'adresse destination à l'instruction "goto" apparaissant plus haut.
; Initialization des deux nombres en format IEEE-754
    ;call Cas1 ; A = 18 et B = 9.5	
    ;call Cas2 ; A = 18 et B = -9.5	
    ;call Cas3 ; A = -18 et B = 9.5	
    ;call Cas4 ; A = -18 et B = -9.5
    call Cas5 ; A = 55.75 et B = 3.984375
    
; Obtenir le signe de A et de B
    call CopieA ; Copie A dans Temporaire
    call Signe ; Obtient le bit de signe et le place dans WREG
    movwf A_signe ; Place le bit de signe dans A_signe
    
    call CopieB ; Copie B dans Temporaire
    call Signe ; Obtient le bit de signe et le place dans WREG
    movwf B_signe ; Place le bit de signe dans B_signe

; Obtenir l'exposant de A et de B
    call CopieA ; Copie A dans Temporaire
    call Exposant ; Obtient l'octet de l'exposant et le place dans WREG
    movwf A_exposant ; Place l'octet de l'exposant dans A_exposant
    
    call CopieB ; Copie B dans Temporaire
    call Exposant ; Obtient l'octet de l'exposant et le place dans WREG
    movwf B_exposant ; Place l'octet de l'exposant dans B_exposant
    
; Obtenir la fraction de A et de B
    call CopieA ; Copie A dans Temporaire
    call Fraction ; Obtient l'octet de la fraction et le place dans WREG
    movwf A_fraction ; Place l'octet de la fraction dans A_exposant
    
    call CopieB ; Copie B dans Temporaire
    call Fraction ; Obtient l'octet de la fraction et le place dans WREG
    movwf B_fraction ; Place l'octet de la fraction dans B_exposant
    nop
    
; Additioner les exposants
    call AddExposant
    
; Multiplier les fractions
    call MultiFraction
    
; Résultat final
    call ResultatFinal
    
CopieA
    movff A_octet3, Temporaire_octet3 ; Copie A_octet3 dans Temporaire_octet3
    movff A_octet2, Temporaire_octet2 ; Copie A_octet2 dans Temporaire_octet2
    movff A_octet1, Temporaire_octet1 ; Copie A_octet1 dans Temporaire_octet1
    movff A_octet0, Temporaire_octet0 ; Copie A_octet0 dans Temporaire_octet0
    return
    
; Copie B dans Temporaire
CopieB
    movff B_octet3, Temporaire_octet3 ; Copie B_octet3 dans Temporaire_octet3
    movff B_octet2, Temporaire_octet2 ; Copie B_octet2 dans Temporaire_octet2
    movff B_octet1, Temporaire_octet1 ; Copie B_octet1 dans Temporaire_octet1
    movff B_octet0, Temporaire_octet0 ; Copie B_octet0 dans Temporaire_octet0
    return
    
Signe
    movlw B'1' ; on commence par mettre 1 dans WREG
    btfss Temporaire_octet3, 7 ; si le bit 7 (le bit de signe) est à 1, on saute la prochaine instruction (qui met 0 dans WREG)
    movlw B'0'
    return ; le bit de signe du nombre est donc maintenant dans WREG

Exposant
    ; On a besoin des bits de 6 à 0 de Temporaire_octet3 et du 7e bit de Temporaire_octet2
    bsf STATUS,C ; On commence par mettre le bit C à 1
    btfss Temporaire_octet2, 7  ; Si le bit 7 est à 1, on saute la prochaine instruction (qui met le bit C à 0)
    bcf STATUS,C
    
    rlcf Temporaire_octet3 ; On décale Temporaire_octet3 en incluant le bit C
    movf Temporaire_octet3, 0 ; On met Temporaire_octet3 dans WREG car il contient maintenant les bits qu'on recherchait au départ
    return ; L'exposant se trouve donc maintenant dans WREG

Fraction
    ; On a besoin des bits de 6 à 0 (7 chiffres significatif) de Temporaire_octet2 et on doit placer un 1 sous-entendue à la place du 7e bit
    rlncf Temporaire_octet2 ; On commence par se débarasser du 7e bit de Temporaire_octet2 à l'aide d'un décalage vers la gauche
    bsf STATUS,C ; Ensuite on met le bit C à 1
    rrcf Temporaire_octet2 ; On décale Temporaire_octet2 vers la droite en incluant le bit C
    movf Temporaire_octet2, 0 ; On met Temporaire_octet2 dans WREG car il contient maintenant les bits qu'on recherchait au départ  
    return ; La fraction se trouve donc maintenant dans WREG
    
AddExposant
    movlw 0x7f ; On place 127 dans WREG
    subwf A_exposant ; On soustrait WREG (127) de A_exposant pour enlever le biais
    subwf B_exposant ; On soustrait WREG (127) de B_exposant pour enlever le biais
    
    movff A_exposant, Resultat_octet3 ; On place A_exposant dans Resultat_octet3 pour se préparer pour l'addition
    movf B_exposant, 0 ; On place B_exposant dans WREG pour se préparer pour l'addition
    addwf Resultat_octet3 ; On addition WREG à Resultat_octet3 (On additionne les exposants)
    
    movlw 0x7f ; On replace 127 dans WREG pour le réadditionner
    addwf Resultat_octet3 ; On additionne WREG (le biais de 127) à Resultat_octet3 pour obtenir notre exposant
    
    rrcf Resultat_octet3 ; On décale Resultat_octet3 vers la droite pour que l'exposant prenne la place des bits 6 à 0
			 ; Le bit 7 de Resultat_octet3 (bit de signe) sera possiblement correcte, mais il sera changé plus tard
			 ; Le dernier bit de l'exposant est maintenant dans le bit C de STATUS
    rrcf Resultat_octet2 ; On décale Resultat_octet2 pour placer le dernier bit de l'exposant comme le bit le plus significatif de Resultat_octet2		 
    return ; Resultat_octet3 (Bits 6 à 0) et Resultat_octet2 (Bit 7) contiennent donc notre exposant final
    
MultiFraction
    movf A_fraction, 0 ; On place A_fraction dans WREG pour se préparer à la multiplié
    mulwf B_fraction ; On effectue la multiplication de WREG (A_fraction) avec B_fraction, le résultat se trouve dans PRODH et PRODL
    
    ; Nous allons devoir décaler PRODH (et PRODL) deux fois vers la gauche pour arriver au bout fractionnaire de la multiplication
    bcf STATUS,C ; On met le bit C à 0 afin de ne pas entrer des nouvelles valeurs au bout de PRODL (sauf des 0)
    rlcf PRODL ; On commence par décaler PRODL, l'ancien 7e bit de PRODL est maintenant dans le bit C
    rlcf PRODH ; On décale ensuite PRODH, le bit C s'insère au bout de PRODH
    ; On répète ensuite ces étapes pour redécaler
    bcf STATUS,C ; On met le bit C à 0 afin de ne pas entrer des nouvelles valeurs au bout de PRODL (sauf des 0)
    rlcf PRODL ; On commence par décaler PRODL, l'ancien 7e bit de PRODL est maintenant dans le bit C
    rlcf PRODH ; On décale ensuite PRODH, le bit C s'insère au bout de PRODH
    ; Notre partie fractionnaire se trouve donc dans PRODH et PRODL
    
    rlcf Resultat_octet2 ; On décale Resultat_octet2 vers la gauche afin de conservé le dernier bit de l'exposant
    movff PRODH, Resultat_octet2 ; On place PRODH (le début de la fraction) dans Resultat_octet2
    rrcf Resultat_octet2 ; On décale Resultat_octet2 vers la droite afin de réinsérer le dernier bit de l'exposant
			 ; L'ancien dernier bit de PRODH est conservé dans le bit C
    movff PRODL, Resultat_octet1 ; On place PRODL (le reste de la fraction) dans Resultat_octet1
    rrcf Resultat_octet1 ; On décale Resultat_octet1 vers la droite afin de réinsérer l'ancien dernier bit de PRODH
			 ; L'ancien dernier bit de PRODL est conservé dans le bit C
    rrcf Resultat_octet0 ; On décale Resultat_octet0 vers la droite afin de réinsérer l'ancien dernier bit de PRODL
    return ; Resultat_octet2 (bit 6 à 0), Resultat_octet1 et Resultat_octet0 contiennent donc la fraction final
    
Cas1
    ; A = 18 et B = 9.5				
    movlw 0x41
    movwf A_octet3
    movlw 0x90
    movwf A_octet2
    movlw 0x00
    movwf A_octet1
    movlw 0x00
    movwf A_octet0
    
    movlw 0x41
    movwf B_octet3
    movlw 0x18
    movwf B_octet2
    movlw 0x00
    movwf B_octet1
    movlw 0x00
    movwf B_octet0
    
    return
    
Cas2
    ; A = 18 et B = -9.5
    movlw 0x41
    movwf A_octet3
    movlw 0x90
    movwf A_octet2
    movlw 0x00
    movwf A_octet1
    movlw 0x00
    movwf A_octet0
    
    movlw 0xc1
    movwf B_octet3
    movlw 0x18
    movwf B_octet2
    movlw 0x00
    movwf B_octet1
    movlw 0x00
    movwf B_octet0
    
    return
    
Cas3
    ; A = -18 et B = 9.5
    movlw 0xc1
    movwf A_octet3
    movlw 0x90
    movwf A_octet2
    movlw 0x00
    movwf A_octet1
    movlw 0x00
    movwf A_octet0
    
    movlw 0x41
    movwf B_octet3
    movlw 0x18
    movwf B_octet2
    movlw 0x00
    movwf B_octet1
    movlw 0x00
    movwf B_octet0
    
    return
    
Cas4
    ; A = -18 et B = -9.5
    movlw 0xc1
    movwf A_octet3
    movlw 0x90
    movwf A_octet2
    movlw 0x00
    movwf A_octet1
    movlw 0x00
    movwf A_octet0
    
    movlw 0xc1
    movwf B_octet3
    movlw 0x18
    movwf B_octet2
    movlw 0x00
    movwf B_octet1
    movlw 0x00
    movwf B_octet0
    
    return

    
Cas5
    ; A = 55.75 et B = 3.984375
    movlw 0x42
    movwf A_octet3
    movlw 0x5f
    movwf A_octet2
    movlw 0x00
    movwf A_octet1
    movlw 0x00
    movwf A_octet0
    
    movlw 0x40
    movwf B_octet3
    movlw 0x7f
    movwf B_octet2
    movlw 0x00
    movwf B_octet1
    movlw 0x00
    movwf B_octet0
    
    return
    
ResultatFinal
    ; Pour finir, on doit ajuster le bit de signe
    movf A_signe, 0 ; On place d'abord A_signe dans WREG pour préparer la comparaison
    xorwf B_signe ; On fait un 'ou exclusif', ce qui nous donnera le bit de signe dans B_signe
    
    rlncf Resultat_octet3 ; On décale Resultat_octet3 vers la gauche pour se préparer à insérer le bit de signe
    rrcf B_signe ; On décale B_signe vers la gauche pour que le bit de signe soit maintenant rendu dans le bit C
    rrcf Resultat_octet3 ; On redécale Resultat_octet3 vers la droite pour insérer le bit C (qui est le bit de signe)
    nop ; Notre résultat en IEEE-754 se trouve dans Resultat_octet3, Resultat_octet2, Resultat_octet1 et Resultat_octet0
    end