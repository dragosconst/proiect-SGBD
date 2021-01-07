CREATE OR REPLACE FUNCTION f8(nume carte.denumire%TYPE)
                           RETURN NUMBER
IS
TYPE str_arr IS TABLE OF librarie.librarie_id%TYPE INDEX BY PLS_INTEGER;
v_carte_id carte.carte_id%TYPE;
v_librarii str_arr;
BEGIN
    SELECT carte_id INTO v_carte_id
    FROM carte
    WHERE denumire = nume;
    
    SELECT sai.librarie_id BULK COLLECT INTO v_librarii
    FROM se_afla_in sai
    WHERE v_carte_id = sai.carte_id;
    
    RETURN v_librarii.last;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Cartea introdusa nu exista in baza de date sau in vreo biblioteca.');
END;
/

SELECT * FROM SE_AFLA_IN;

DECLARE
nr NUMBER;
BEGIN
    nr := f8('Stapanul Inelelor 1');
    DBMS_OUTPUT.PUT_LINE(nr);
END;
/
