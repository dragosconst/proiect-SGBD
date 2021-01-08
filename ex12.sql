--Voi face un audit, pentru a avea un istoric al comenzilor facute pe baza de date.
CREATE TABLE audit_lib
    (utilizator VARCHAR2(50),
    nume_bd VARCHAR2(50),
    eveniment VARCHAR2(50),
    nume_obiect VARCHAR2(50),
    data DATE);

CREATE OR REPLACE TRIGGER T12
    AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    INSERT INTO audit_lib
    VALUES (SYS.LOGIN_USER, SYS.DATABASE_NAME, SYS.SYSEVENT,
        SYS.DICTIONARY_OBJ_NAME, SYSDATE);
END;
/