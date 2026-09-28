* >Natural Source Header 000000
* :Mode S
* :CP
* :LineIncrement 10
* <Natural Source Header
* ---------------------------------------------------------------------*
* Member          NSWGEN1H
* Component       EWVDEMO
* Created         April 2004
* Copyright       (c) Copyright Software AG 2004. All rights reserved.
* Remarks         Help for gender
*
* ---------------------------------------------------------------------*
*
DEFINE DATA
PARAMETER
1 P-CDGEND          (A1)
LOCAL
1 MSG-PAR           (A20)
1 MESSAGE           (N4)
1 INDICATION        (I4)
1 M-CDGEND          (A1/6)
1 M-TABLE
  2 M-SELECTION     (A1/6)
  2 M-DSGEND        (A16/6)
1 I                 (N2)
1 NUM-INDICATIONS   (N2)
1 T-CDGEND          (A1/6)
1 T-DSGEND          (A16/6)
*
* DEBUG
01 #DATE     (A10) INIT <*DATE>
01 #TIME     (A10) INIT <*TIME>
01 #MESSAGE    (A) DYNAMIC
END-DEFINE
*
SET KEY ALL
INCLUDE NSWPFK1C
*
INCLUDE NSWGEN2C
PERFORM CARGAR-MAPA
*
*
R1. REPEAT
*
* DEBUG
*  DEFINE WORK FILE 5 '/opt/softwareag202510/Natural/logs/NSWGEN1H.log'  TYPE "ASCII" ATTRIBUTES 'APPEND' /* ATTRIBUTES 'NOBOM,APPEND,KEEP'
*  WRITE WORK 5 VARIABLE #DATE #TIME ' NSWGEN1H invoked by ' *USER ' using ' *BROWSER-IO
*  CLOSE WORK 5
*
*  DECIDE FOR FIRST CONDITION
*    WHEN *BROWSER-IO='RICHGUI'
*         PROCESS PAGE MODAL
*             CALLNAT 'NSWGEN1N'
*         END-PROCESS
*    WHEN NONE
          INPUT WITH TEXT *MESSAGE, MSG-PAR MARK INDICATION USING MAP 'NSWGEN1&'
*  END-DECIDE
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
        MOVE M-CDGEND(I) TO P-CDGEND
        ESCAPE ROUTINE
      END-IF
    END-FOR
  WHEN NONE
    IGNORE
END-DECIDE
END-SUBROUTINE
*
* ------------------------------------------------------
DEFINE SUBROUTINE CARGAR-MAPA
* ------------------------------------------------------
FOR I EQ 1 TO 6
  MOVE T-CDGEND(I) TO M-CDGEND(I)
  MOVE T-DSGEND(I) TO M-DSGEND(I)
END-FOR
END-SUBROUTINE
*
END
