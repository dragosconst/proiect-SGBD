--Nu e permis sa fie schimbati membrii in timpul weekend-ului sau in afara orelor de program.
CREATE OR REPLACE TRIGGER T10 
BEFORE INSERT OR DELETE OR UPDATE ON Membru 
BEGIN
    IF (TO_CHAR(SYSDATE, 'D') = 1 OR TO_CHAR(SYSDATE, 'D') = 7)
        OR TO_CHAR(SYSDATE, 'HH24') NOT BETWEEN 8 AND 21 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se pot face modificari la tabelul membrilor in acest interval orar');
    END IF;
END;
/