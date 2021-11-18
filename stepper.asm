     ;Init Utility Subroutines
OUTSTRG EQU $FFC7 ; string output Utility Subroutine
OUTA    EQU $FFB8 ; char output Utility Subroutine
OUTCRL  EQU $FFC4 ; output carriage return
RHLF    EQU $FFB5 ; bin to ASCII from AA

;Interrupt Timer Control Registers
TOC1    EQU $1016 ; Timer Output Compare Register
OC1M    EQU $100C ; Output Compare 1 Mask Register
OC1D    EQU $100D ; Output Compare 1 Data Register (Stepper Control Pattern)
TMSK1   EQU $1022 ; Timer Mask Register
TFLG1   EQU $1023 ; Timer Interrupt Flag Register
PORTB   EQU $1004 ; Port B
FULLSTEP EQU 4 ; Sequence Size (in bytes) for Full Step
HALFSTEP EQU 8 ; Sequence Size (in bytes) for Half Step

        ORG $D500 ; Constants and Variables

; Variables
DELTA RMB 2 ; 2 Bytes for Pulse Width of Stepper
STEPPTR RMB 2 ; Pointer variable for the step sequence
SEQSIZE RMB 1 ; Variable for Sequence Size in bytes (4 for Full Step, 8 for Half Step)
COUNT RMB 1 ; Counter Variable

; Constants
FCW FCB $50,$48,$28,$30 ; Full Step Clockwise Sequence
FCCW FCB $60,$50,$90,$A0 ; Full Step Counter Clockwise Sequence
HCW FCB $A0,$80,$90,$10,$50,$40,$60,$20 ; Half Step Clockwise Sequence
HCCW FCB $20,$60,$40,$50,$10,$90,$80,$A0 ; Half Step Counter Clockwise Sequence

; Pseudovector Setup
        ORG $00DF
        JMP SETOC1

; Main Program Entry
        ORG $D000
        LDS #$D800 ; Init SP

; Init Interrupt Timer
OC1INIT:
        CLI ; Enable Interrupts System-Wide
        LDAA #$78
        STAA OC1M ; Enable OC1
        LDAA #$80
        STAA TMSK1 ; Enable OC1 Interrupts
        STAA TFLG1 ; Clear OC1 Interrupt Flag

; Additional Init
INIT:
        LDD #FCW ; Load the address of FCW
        STD STEPPTR ; Store address to STEPPTR
        LDD #$FFFF ; Set DELTA for testing (RPM 30)
        STD DELTA
        LDAA #5 ; Set Count to 4
        STAA COUNT

MAIN:
        BRA MAIN ; While(1)


; Set TOC1 and OC1D (Interrupt Service Routine)
SETOC1:
; Set TOC1 Register
        LDD TOC1 ; Load the current Output Compare value
        ADDD DELTA ; Add the desired DELTA
        STD TOC1 ; And store to Timer Output Compare 1

; Set OC1D Register
        LDX STEPPTR
        DEC COUNT ; Decrement Counter
        BNE SETOC1D ; if((*FCW + sizeof(FCW)) > STEPPTR)
        LDX #FCW ; else, reset X to FCW
        LDAA #4 ; Set Count back to 4
        STAA COUNT
SETOC1D:
        LDAA 0,X ; Update OC1D to next Step Sequence
        STAA OC1D
        STAA PORTB
        INX ; Increment Pointer
        STX STEPPTR

        LDAB #$80
        STAB TFLG1 ; Clear OC1 Interrupt Flag

        RTI ; Return