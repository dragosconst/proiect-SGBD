-- Un subprogram care determina in care librarii se gaseste cartea introdusa de la tastatura si ce abonamente o includ.
CREATE OR REPLACE PROCEDURE ex6 (v_nume_carte carte.denumire%TYPE )IS
    TYPE string_tabel IS TABLE OF VARCHAR2(60) INDEX BY PLS_INTEGER;
    TYPE number_tabel IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_id_carte carte.carte_id%TYPE := NULL;
    v_librarii string_tabel;
    v_abonamente string_tabel;
    v_pret abonament.plata_lunara%TYPE;
BEGIN
    SELECT carte_id INTO v_id_carte
    FROM carte
    WHERE v_nume_carte = carte.denumire;
    
    SELECT l.denumire BULK COLLECT INTO v_librarii
    FROM librarie l, se_afla_in sai
    WHERE sai.carte_id = v_id_carte AND sai.librarie_id = l.librarie_id;
    
    DBMS_OUTPUT.put(v_nume_carte || ' se gaseste in librariile: ');
    FOR i IN 1..v_librarii.last LOOP
        DBMS_OUTPUT.put(v_librarii(i) || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
        
    SELECT a.abonament_id BULK COLLECT INTO v_abonamente
    FROM abonament a, carte_inclusa ci
    WHERE ci.carte_id = v_id_carte AND ci.abonament_id = a.abonament_id;
    
    IF v_abonamente.count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Cartea nu este inclusa in niciun abonament.');
    ELSE
            DBMS_OUTPUT.PUT(v_nume_carte || ' este inclusa in format digital in abonamentele: ');
        FOR i in 1..v_abonamente.last LOOP
            SELECT a.plata_lunara INTO v_pret
            FROM abonament a
            WHERE a.abonament_id = v_abonamente(i);
            DBMS_OUTPUT.PUT('abonamentul ' || v_abonamente(i) || ' cu pretul ' || v_pret || ', ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
    END IF;
    
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Cartea nu exista.');
END;
/

BEGIN
    ex6('Ion');
END;
/