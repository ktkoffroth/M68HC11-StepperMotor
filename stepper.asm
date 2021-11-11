;Init Utility Subroutines
OUTSTRG EQU $FFC7 ; string output Utility Subroutine
OUTA    EQU $FFB8 ; char output Utility Subroutine
OUTCRL  EQU $FFC4 ; output carriage return
RHLF    EQU $FFB5 ; bin to ASCII from AA



; Main Program Entry
        ORG $D000
        LDS #$D800 ; Init SP

        