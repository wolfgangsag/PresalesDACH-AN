* >Natural Source Header 000000
* :Mode S
* :CP
* :LineIncrement 10
* <Natural Source Header
* ---------------------------------------------------------------------*
* Member          NSWDIV1H
* Component       EWVDEMO
* Created         April 2004
* Copyright       (c) Copyright Software AG 2004. All rights reserved.
* Remarks         Help for currency
*
* ---------------------------------------------------------------------*
*
DEFINE DATA
       PARAMETER
1 P-CDCURR          (A3)
1 P-DSCURR          (A16)
       LOCAL
1 MSG-PAR           (A20)
1 MESSAGE           (N4)
1 INDICATION        (I4)
1 M-CDCURR          (A3/6)
1 M-TABLE
  2 M-SELECTION     (A1/6)
  2 M-DSCURR        (A16/6)
1 I                 (N2)
1 NUM-INDICATIONS   (N2)
1 T-CDCURR          (A3/6)
1 T-DSCURR          (A16/6)
END-DEFINE
*
SET KEY ALL
INCLUDE NSWPFK1C
*
INCLUDE NSWDIV2C
PERFORM MAP-DATA
*
R1. REPEAT
*
  INPUT WITH TEXT *MESSAGE, MSG-PAR MARK INDICATION USING MAP 'NSWDIV1&'
*
  DECIDE ON FIRST VALUE OF *PF-KEY
    VALUE 'ENTR'
      RESET MESSAGE
      PERFORM VALIDATIONS
      IF MESSAGE NE 0
        ESCAPE TOP
      ELSE
        ESCAPE ROUTINE
      END-IF
    VALUE 'PF3'
      ESCAPE BOTTOM
    NONE VALUE
      MOVE 6 TO MESSAGE
      ESCAPE TOP
  END-DECIDE
*
END-REPEAT
* ------------------------------------------------
DEFINE SUBROUTINE VALIDATIONS
* ------------------------------------------------
FOR I EQ 1 TO 6
  IF M-SELECTION (I)  NE ' ' AND M-SELECTION(I)  NE 'X'
    MOVE 4 TO MESSAGE
    MOVE '"X"' TO MSG-PAR
    COMPUTE INDICATION = POS(M-SELECTION(I))
    ESCAPE ROUTINE
  END-IF
END-FOR
*
EXAMINE M-SELECTION(*) FOR 'X' GIVING NUMBER NUM-INDICATIONS
  DECIDE FOR FIRST CONDITION
    WHEN NUM-INDICATIONS GT 1
      MOVE 5 TO MESSAGE
      COMPUTE INDICATION = POS(M-SELECTION(1))
      ESCAPE ROUTINE
    WHEN NUM-INDICATIONS = 1
      FOR I EQ 1 TO 6
        IF M-SELECTION(I) EQ 'X'
          MOVE M-CDCURR(I) TO P-CDCURR
          MOVE M-DSCURR(I) TO P-DSCURR
          ESCAPE ROUTINE
        END-IF
      END-FOR
    WHEN NONE
      IGNORE
  END-DECIDE
END-SUBROUTINE
*
* ------------------------------------------------------
DEFINE SUBROUTINE MAP-DATA
* ------------------------------------------------------
FOR I EQ 1 TO 6
  MOVE T-CDCURR(I) TO M-CDCURR(I)
  MOVE T-DSCURR(I) TO M-DSCURR(I)
END-FOR
END-SUBROUTINE
*
END
