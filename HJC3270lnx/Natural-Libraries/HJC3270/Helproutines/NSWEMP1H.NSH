* >Natural Source Header 000000
* :Mode S
* :CP
* :LineIncrement 10
* <Natural Source Header
* ---------------------------------------------------------------------*
* Member          NSWEMP1H
* Component       EWVDEMO
* Created         April 2004
* Copyright       (c) Copyright Software AG 2004. All rights reserved.
* Remarks         Help for employee code
*
* ---------------------------------------------------------------------*
*
DEFINE DATA
       PARAMETER
1 P-KEY             (A8)
1 P-TNAME           (A30)
       LOCAL USING NSWEMPLO
       LOCAL
1 CONTROL           (C/10)
1 M-TITLE           (A50)
1 MSG-PAR           (A20)
1 MESSAGE           (N4)
1 INDICATION        (I4)
1 MAP-TABLE
  2 M-LAST_NAME     (A20/10)
  2 M-CITY          (A10/10)
  2 M-KEY           (A8/10)
  2 M-DATE-OF-BIRTH (N6/10)
  2 M-SURNAME       (A20/10)
  2 M-SELECTION     (A1/10)
1 M-KEY-INI         (A8)
1 M-PAGE            (N3)
1 T-PAGING          (A8/21)
1 INDX-PAGING       (N2)
1 I                 (N2)
1 CL-KEY            (A20)
1 CL-AUX            (A20)
1 KEY-AUX           (A8)
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
MOVE P-KEY TO CL-AUX
PERFORM FILL-PAGE
*
R1. REPEAT
*
  RESET CONTROL(*)
  PERFORM PROTECT-INDICATIONS
*
  INPUT WITH TEXT *MESSAGE, MSG-PAR MARK INDICATION USING MAP 'NSWEMPH&'
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
          MOVE M-KEY(J) TO P-KEY
          COMPRESS M-LAST_NAME(J)     M-SURNAME (J) INTO P-TNAME
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
* ------------------------------------------------------
DEFINE SUBROUTINE FILL-PAGE
* ------------------------------------------------------
RESET MAP-TABLE CL-KEY I
MOVE CL-AUX TO  CL-KEY
RESET CL-AUX
READ NSWEMPLO BY NSWEMPLO.PERSONNEL-ID EQ CL-KEY
  ADD 1 TO I
  IF I LE 10
    MOVE NSWEMPLO.PERSONNEL-ID TO M-KEY(I)
    MOVE BIRTH TO M-DATE-OF-BIRTH(I)
    MOVE FIRST-NAME TO M-LAST_NAME(I)
    MOVE CITY TO M-CITY(I)
    MOVE NAME TO M-SURNAME(I)
  ELSE
    MOVE NSWEMPLO.PERSONNEL-ID TO CL-AUX
    ESCAPE ROUTINE
  END-IF
  IF I EQ 1
    MOVE NSWEMPLO.PERSONNEL-ID TO T-PAGING(INDX-PAGING)
  END-IF
END-READ
IF M-KEY(1) EQ ' '
  MOVE 8 TO MESSAGE
END-IF
END-SUBROUTINE
*
* ------------------------------------------------------
DEFINE SUBROUTINE VALIDATIONS
* ------------------------------------------------------
IF M-KEY-INI NE KEY-AUX
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
* ------------------------------------------------
DEFINE SUBROUTINE PROTECT-INDICATIONS
* ------------------------------------------------
FOR J EQ 1 TO 10
  IF M-KEY(J) EQ ' '
    MOVE (AD=NP) TO CONTROL(J)
  END-IF
END-FOR
END-SUBROUTINE
*
* ----------------------------------------------------
DEFINE SUBROUTINE REPOSITION
* ----------------------------------------------------
RESET INITIAL CHANGE
MOVE M-KEY-INI TO CL-AUX KEY-AUX
MOVE 1 TO M-PAGE INDX-PAGING
PERFORM FILL-PAGE
END-SUBROUTINE
*
END
