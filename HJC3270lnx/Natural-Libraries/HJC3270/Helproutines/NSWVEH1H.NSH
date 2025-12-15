* >Natural Source Header 000000
* :Mode S
* :CP
* :LineIncrement 10
* <Natural Source Header
* ---------------------------------------------------------------------*
* Member          NSWVEH1H
* Component       EWVDEMO
* Created         April 2004
* Copyright       (c) Copyright Software AG 2004. All rights reserved.
* Remarks         Help for vehicles
*
* ---------------------------------------------------------------------*
*
DEFINE DATA
       PARAMETER
1 P-VEHNUMBER       (A15)
*
       LOCAL USING NSWVEHIC
       LOCAL
1 CONTROL           (C/10)
1 MSG-PAR           (A20)
1 MESSAGE           (N4)
1 INDICATION        (I4)
1 MAP-TABLE
  2 M-VEHNUMBER     (A15/10)
  2 M-DESCRIPTION   (A20/10)
  2 M-MODELYEAR     (N4/10)
  2 M-SELECTION     (A1/10)
1 M-VEHNUMBER-INI   (A15)
1 M-PAGE            (N3)
1 T-PAGING          (A15/21)
1 INDX-PAGING       (N2)
1 I                 (N2)
1 CL-VEHNUMBER      (A15)
1 CL-AUX            (A15)
1 VEHNUMBER-AUX     (A15)
1 CHANGE            (L)
1 J                 (N2)
1 NUM-INDICATIONS   (N2)
1 M-PRG-ERROR       (A8)
END-DEFINE
*
ON ERROR
  INCLUDE NSWERR1C
  ESCAPE ROUTINE
END-ERROR
*
SET KEY ALL
INCLUDE NSWPFK1C
INCLUDE NSWPFK2C
*
MOVE 1 TO M-PAGE
MOVE 1 TO INDX-PAGING
MOVE P-VEHNUMBER TO CL-AUX
PERFORM FILL-PAGE
*
R1. REPEAT
*
  RESET CONTROL(*)
  PERFORM PROTECT-INDICATIONS
*
  INPUT WITH TEXT *MESSAGE, MSG-PAR MARK INDICATION USING MAP 'NSWVEHH&'
*
  DECIDE ON FIRST VALUE OF *PF-KEY
    VALUE 'PF3'
      ESCAPE BOTTOM
    VALUE 'PF7'
      RESET MESSAGE
      PERFORM VALIDATIONS
      IF MESSAGE NE 0
        ESCAPE TOP
      END-IF
      IF CHANGE
        MOVE 12 TO MESSAGE
        ESCAPE TOP
      END-IF
      IF INDX-PAGING EQ 1
       MOVE 7 TO MESSAGE
       ESCAPE TOP
      END-IF
      M-PAGE := M-PAGE - 1
      INDX-PAGING := INDX-PAGING - 1
      MOVE T-PAGING(INDX-PAGING) TO CL-AUX
      PERFORM FILL-PAGE
      IF INDX-PAGING EQ 1
        MOVE 7 TO  MESSAGE
        ESCAPE TOP
      END-IF
    VALUE 'PF8'
      RESET MESSAGE
      PERFORM VALIDATIONS
      IF MESSAGE NE 0
        ESCAPE TOP
      END-IF
      IF CHANGE
        MOVE 12 TO MESSAGE
        ESCAPE TOP
      END-IF
      IF CL-AUX EQ ' '
        MOVE 8 TO MESSAGE
        ESCAPE TOP
      ELSE
        IF INDX-PAGING EQ 21
          MOVE T-PAGING(2:21) TO T-PAGING(1:20)
        ELSE
          ADD 1 TO INDX-PAGING
        END-IF
        ADD 1 TO M-PAGE
        PERFORM FILL-PAGE
        IF CL-AUX EQ ' '
          MOVE 8 TO MESSAGE
          ESCAPE  TOP
        END-IF
      END-IF
    VALUE 'ENTR'
      RESET MESSAGE
      PERFORM VALIDATIONS
      IF MESSAGE NE 0
        ESCAPE TOP
      END-IF
      IF CHANGE
        PERFORM REPOSITION
      END-IF
      FOR J EQ 1 TO 10
        IF M-SELECTION(J) EQ 'X'
          MOVE M-VEHNUMBER(J) TO P-VEHNUMBER
          ESCAPE ROUTINE
        END-IF
      END-FOR
    NONE VALUE
      MOVE 6 TO MESSAGE
      ESCAPE TOP
  END-DECIDE
*
END-REPEAT
*
* ---------------------------------------------------------
DEFINE SUBROUTINE FILL-PAGE
* ---------------------------------------------------------
RESET MAP-TABLE CL-VEHNUMBER I
MOVE CL-AUX TO  CL-VEHNUMBER
RESET CL-AUX
READ NSWVEHIC BY REG-NUM EQ CL-VEHNUMBER
  ADD 1 TO I
  IF I LE 10
    MOVE REG-NUM TO M-VEHNUMBER(I)
    MOVE YEAR      TO M-MODELYEAR     (I)
    COMPRESS NSWVEHIC.MAKE MODEL INTO M-DESCRIPTION(I)
  ELSE
    MOVE REG-NUM TO CL-AUX
    ESCAPE ROUTINE
  END-IF
  IF I EQ 1
    MOVE REG-NUM TO T-PAGING(INDX-PAGING)
  END-IF
END-READ
IF M-VEHNUMBER(1) EQ ' '
  MOVE 8 TO MESSAGE       /* END OF DATA
END-IF
END-SUBROUTINE
*
* -------------------------------------------------------
DEFINE SUBROUTINE VALIDATIONS
* -------------------------------------------------------
IF M-VEHNUMBER-INI NE VEHNUMBER-AUX
  MOVE TRUE TO CHANGE
END-IF
RESET NUM-INDICATIONS
EXAMINE M-SELECTION(*) FOR 'X' GIVING NUMBER NUM-INDICATIONS
IF NUM-INDICATIONS GT 1
  MOVE 5 TO MESSAGE
  DECIDE ON FIRST VALUE OF *LANGUAGE
   VALUE 1
    MOVE 'one employee'      TO MSG-PAR
   VALUE 2
    MOVE 'einen Mitarbeiter' TO MSG-PAR
   VALUE 4
    MOVE 'un empleado'       TO MSG-PAR
   NONE VALUE
    IGNORE
  END-DECIDE
  COMPUTE INDICATION = POS(M-SELECTION(1))
  ESCAPE ROUTINE
END-IF
FOR J EQ 1 TO 10
  IF M-SELECTION(J) NE ' ' AND M-SELECTION(J) NE 'X'
    MOVE 4 TO MESSAGE
    MOVE '"X"'       TO MSG-PAR
    COMPUTE INDICATION = POS(M-SELECTION(J))
    ESCAPE ROUTINE
  END-IF
END-FOR
END-SUBROUTINE
*
* ------------------------------------------------------
DEFINE SUBROUTINE PROTECT-INDICATIONS
* ------------------------------------------------------
FOR J EQ 1 TO 10
  IF M-VEHNUMBER(J) EQ ' '
    MOVE (AD=NP) TO CONTROL(J)
  END-IF
END-FOR
END-SUBROUTINE
*
* ---------------------------------------------------------
DEFINE SUBROUTINE REPOSITION
* ---------------------------------------------------------
RESET INITIAL CHANGE
MOVE M-VEHNUMBER-INI TO CL-AUX VEHNUMBER-AUX
MOVE 1 TO M-PAGE INDX-PAGING
PERFORM FILL-PAGE
END-SUBROUTINE
*
END
