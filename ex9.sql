--Vreau sa obtin o lista cu toti membrii care au abonamente cu carti din libraria data in procedura.
--Lista contine si numele abonamentului despre care este vorba.
CREATE OR REPLACE PROCEDURE p9 (lib_name librarie.denumire%TYPE)
IS
TYPE nume IS RECORD (abonament_id abonament.abonament_id%TYPE,
                    nume membru.nume%TYPE,
                    prenume membru.prenume%TYPE);
TYPE name_table IS TABLE OF nume INDEX BY PLS_INTEGER;
v_lib_id librarie.librarie_id%TYPE;
flag NUMBER := 0;
v_data name_table;
BEGIN
    SELECT librarie_id INTO v_lib_id
    FROM librarie
    WHERE denumire = lib_name;
    flag := 1;
    
    SELECT a.abonament_id, m.nume, m.prenume BULK COLLECT INTO v_data
    FROM membru m, abonament a, carte_inclusa ci, carte c, se_afla_in sai
    WHERE sai.librarie_id = v_lib_id AND sai.carte_id = c.carte_id AND c.carte_id = ci.carte_id AND ci.abonament_id = a.abonament_id AND m.abonament_id = a.abonament_id
    GROUP BY a.abonament_id, m.nume, m.prenume;
    
    IF v_data.count = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista membrii cu abonamente care includ carti in libraria ceruta.');
    END IF;
    
    FOR i in 1..v_data.last LOOP
        DBMS_OUTPUT.PUT_LINE('Abonamentul ' || v_data(i).abonament_id || ', detinut de membrul ' || v_data(i).nume || ' ' || v_data(i).prenume || '.');
    END LOOP;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF flag = 0 THEN
                RAISE_APPLICATION_ERROR(-20000, 'Nu exista libraria ceruta.');
            END IF;
END;
/