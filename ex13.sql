CREATE OR REPLACE PACKAGE proiect AS
    TYPE int_table IS VARRAY(3) OF NUMBER;
    
    PROCEDURE ex6 (v_nume_carte carti.denumire%TYPE);
    PROCEDURE ex7 (vechime NUMBER,
                  cod_librarie librarii.librarie_id%TYPE);
    FUNCTION f8 (job_name jobs.denumire%TYPE)
                RETURN int_table;
    PROCEDURE p9 (lib_name librarii.denumire%TYPE);
END proiect;
/

CREATE OR REPLACE PACKAGE BODY proiect AS
    PROCEDURE ex6 (v_nume_carte carti.denumire%TYPE )IS
        TYPE string_tabel IS TABLE OF VARCHAR2(60) INDEX BY PLS_INTEGER;
        TYPE number_tabel IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
        v_id_carte carti.carte_id%TYPE := NULL;
        v_librarii string_tabel;
        v_abonamente string_tabel;
        v_pret abonamente.plata_lunara%TYPE;
    BEGIN
        SELECT carte_id INTO v_id_carte
        FROM carti
        WHERE v_nume_carte = carti.denumire;
        
        SELECT l.denumire BULK COLLECT INTO v_librarii
        FROM librarii l, se_afla_in sai
        WHERE sai.carte_id = v_id_carte AND sai.librarie_id = l.librarie_id;
        
        DBMS_OUTPUT.put(v_nume_carte || ' se gaseste in librariile: ');
        FOR i IN 1..v_librarii.last LOOP
            DBMS_OUTPUT.put(v_librarii(i) || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE();
            
        SELECT a.abonament_id BULK COLLECT INTO v_abonamente
        FROM abonamente a, carte_inclusa ci
        WHERE ci.carte_id = v_id_carte AND ci.abonament_id = a.abonament_id;
        
        IF v_abonamente.count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Cartea nu este inclusa in niciun abonament.');
        ELSE
                DBMS_OUTPUT.PUT(v_nume_carte || ' este inclusa in format digital in abonamentele: ');
            FOR i in 1..v_abonamente.last LOOP
                SELECT a.plata_lunara INTO v_pret
                FROM abonamente a
                WHERE a.abonament_id = v_abonamente(i);
                DBMS_OUTPUT.PUT('abonamentul ' || v_abonamente(i) || ' cu pretul ' || v_pret || ', ');
            END LOOP;
            DBMS_OUTPUT.NEW_LINE();
        END IF;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Cartea nu exista.');
    END ex6;

    PROCEDURE ex7 (vechime NUMBER,
                  cod_librarie librarii.librarie_id%TYPE)
    IS
        CURSOR c (pvec NUMBER, pcod librarii.librarie_id%TYPE) IS
            SELECT a.angajat_id, a.nume, a.prenume, a.manager_id
            FROM angajati a, lucreaza_in li
            WHERE TRUNC ((SYSDATE) - a.data_angajarii) / 365.5 >= pvec AND li.angajat_id = a.angajat_id AND li.librarie_id = pcod;
    BEGIN
        FOR i in c(vechime, cod_librarie) LOOP
            IF i.manager_id IS NOT NULL THEN
                UPDATE angajati
                SET salariu = salariu + salariu * 15 / 100
                WHERE angajat_id = i.angajat_id;
                DBMS_OUTPUT.PUT_LINE('A fost marit salariul anagajtului\ei ' || i.nume || ' ' || i.prenume || ' .');
            END IF;
        END LOOP;
    END ex7;
    
    FUNCTION f8 (job_name jobs.denumire%TYPE)
                        RETURN int_table
    IS
        v_job_id angajati.job_id%TYPE;
        v_check NUMBER;
        v_old_lib_val NUMBER := -1;
        v_counter NUMBER := 1;
        v_found_job NUMBER := 0;
        retval int_table := int_table(0,0,0);
    BEGIN
        SELECT job_id INTO v_job_id
        FROM jobs
        WHERE denumire = job_name;
        
        SELECT COUNT(*) INTO v_check -- verific daca exista angajati cu job-ul dat
        FROM angajati a
        WHERE a.job_id = v_job_id;
        IF v_check = 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu job-ul dat.');
        END IF;
            
        FOR i IN (SELECT l.librarie_id, a.job_id, COUNT(*) c
                FROM angajati a, lucreaza_in li, librarii l
                WHERE a.angajat_id = li.angajat_id AND li.librarie_id = l.librarie_id
                GROUP BY l.librarie_id, a.job_id
                ORDER BY l.librarie_id) LOOP
            IF v_old_lib_val = -1 THEN -- prima intrare in for
                v_old_lib_val := i.librarie_id;
            END IF;
            IF i.librarie_id != v_old_lib_val THEN -- am ajuns in gruparea pentru urmatoarea librarie
                v_counter := v_counter + 1;
                v_old_lib_val := i.librarie_id;
                IF v_found_job = 0 THEN
                    retval(v_counter - 1) := 0;
                END IF;
                v_found_job := 0;
            END IF;
            
            IF i.job_id = v_job_id THEN
                v_found_job := 1;
                retval(v_counter) := i.c;
            END IF;
        END LOOP;    
        RETURN retval;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Nu exista jobul dat');
    END f8;   
    
    PROCEDURE p9 (lib_name librarii.denumire%TYPE)
    IS
    TYPE nume IS RECORD (abonament_id abonamente.abonament_id%TYPE,
    nume membri.nume%TYPE,
    prenume membri.prenume%TYPE);
    TYPE name_table IS TABLE OF nume INDEX BY PLS_INTEGER;
    v_lib_id librarii.librarie_id%TYPE;
    flag NUMBER := 0;
    v_data name_table;
    BEGIN
        SELECT librarie_id INTO v_lib_id
        FROM librarii
        WHERE denumire = lib_name;
        
        SELECT a.abonament_id, m.nume, m.prenume BULK COLLECT INTO v_data
        FROM membri m, abonamente a, carte_inclusa ci, carti c, se_afla_in sai
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
                RAISE_APPLICATION_ERROR(-20000, 'Nu exista libraria ceruta.');
    END p9;      
END proiect;
/