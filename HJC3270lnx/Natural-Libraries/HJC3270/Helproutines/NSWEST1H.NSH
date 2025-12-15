* >Natural Source Header 000000
* :Mode S
* :CP
* :LineIncrement 10
* <Natural Source Header
* ---------------------------------------------------------------------*
* Member          NSWEST1H
* Component       EWVDEMO
* Created         April 2004
* Copyright       (c) Copyright Software AG 2004. All rights reserved.
* Remarks         Help for marital status
*
* ---------------------------------------------------------------------*
*
DEFINE DATA
       PARAMETER
1 P-KEY             (A1)
1 P-DSMARIT         (A15)
       LOCAL
1 T-CDMARIT         (A1/4)
1 T-DSMARIT         (A15/4)
1 MSG-PAR           (A20)
1 MESSAGE           (N4)
1 INDICATION        (I4)
1 M-KEY             (A3/4)
1 M-TABLE
  2 M-SELECTION     (A1/4)
  2 M-DSMARIT       (A15/4)
1 I                 (N2)
1 J                 (N2)
1 NUM-INDICATIONS   (N2)
END-DEFINE
*
SET KEY ALL
INCLUDE NSWPFK1C
*
INCLUDE NSWEST2C
*
PERFORM MAP-DATA
*
R1. REPEAT
*
  INPUT WITH TEXT *MESSAGE, MSG-PAR MARK INDICATION USING MAP 'NSWEST1&'
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
      IGNORE
  END-DECIDE
*
END-REPEAT
* ---------------------------------------
DEFINE SUBROUTINE VALIDATIONS
* ---------------------------------------
FOR I EQ 1 TO 4
  IF M-SELECTION (I)  NE ' ' AND M-SELECTION(I)  NE 'X'
    MOVE 4 TO MESSAGE
    MOVE '"X"' TO MSG-PAR
    COMPUTE INDICATION = POS(M-SELECTION(I))
    ESCAPE ROUTINE
  END-IF
END-FOR
EXAMINE M-SELECTION(*) FOR 'X' GIVING NUMBER NUM-INDICATIONS
DECIDE FOR FIRST CONDITION
  WHEN NUM-INDICATIONS GT 1
    MOVE 5 TO MESSAGE
    COMPUTE INDICATION = POS(M-SELECTION(1))
    ESCAPE ROUTINE
  WHEN NUM-INDICATIONS = 1
    FOR I EQ 1 TO 4
      IF M-SELECTION(I) EQ 'X'
        MOVE M-KEY(I) TO P-KEY
        MOVE M-DSMARIT(I)  TO P-DSMARIT
        ESCAPE ROUTINE
      END-IF
    END-FOR
  WHEN NONE
    IGNORE
END-DECIDE
END-SUBROUTINE
*
* ----------------------------------------------------------
DEFINE SUBROUTINE MAP-DATA
* ----------------------------------------------------------
FOR J EQ 1 TO 4
  MOVE T-CDMARIT(J) TO M-KEY(J)
  MOVE T-DSMARIT(J) TO M-DSMARIT(J)
END-FOR
END-SUBROUTINE
*
END
