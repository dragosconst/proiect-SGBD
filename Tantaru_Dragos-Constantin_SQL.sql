-- Un subprogram care determina in care librarii se gaseste cartea introdusa ca parametru si ce abonamente o includ.
CREATE OR REPLACE PROCEDURE ex6 (v_nume_carte carti.denumire%TYPE )IS
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
END;
/
--O procedura care cauta angajatii cu vechime data ca parametru dintr-o librarie data de asemenea ca parametru si le mareste 
--salariul cu 15%.
CREATE OR REPLACE PROCEDURE ex7 (vechime NUMBER,
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
END;
/

CREATE OR REPLACE TYPE int_table IS VARRAY(3) OF NUMBER;
/
--Dandu-se denumirea unui job, vrem un sir de numere ce reprezinta
--cati angajati au job-ul respectiv in fiecare librarie.
CREATE OR REPLACE FUNCTION f8 (job_name jobs.denumire%TYPE)
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
END;
/

--Vreau sa obtin o lista cu toti membrii care au abonamente cu carti din libraria data in procedura.
--Lista contine si numele abonamentului despre care este vorba.
CREATE OR REPLACE PROCEDURE p9 (lib_name librarii.denumire%TYPE)
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
END;
/

--Nu e permis sa fie schimbati membrii in timpul weekend-ului sau in afara orelor de program.
CREATE OR REPLACE TRIGGER T10 
BEFORE INSERT OR DELETE OR UPDATE ON Membri
BEGIN
    IF (TO_CHAR(SYSDATE, 'D') = 1 OR TO_CHAR(SYSDATE, 'D') = 7)
        OR TO_CHAR(SYSDATE, 'HH24') NOT BETWEEN 8 AND 21 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se pot face modificari la tabelul membrilor in acest interval orar');
    END IF;
END;
/

--Cand pretul unei carti este schimbat, vrem ca schimbarea sa fie reflectata si in abonament, in cazul in care scumpim cartea
--Daca scoatem o carte din stoc, vom ieftini abonamentul cu procentajul pe care pretul cartii il reprezenta din intregul pachet al abonamentului.
--Pt a evita trigger mutating, vom folosi o colectie intr-un pachet, care este intializata cu un trigger la nivel de comanda.
CREATE OR REPLACE PACKAGE trig_help 
AS
TYPE abo IS TABLE OF abonamente%ROWTYPE INDEX BY PLS_INTEGER;
TYPE car IS TABLE OF carti%ROWTYPE INDEX BY PLS_INTEGER;
TYPE ci  IS TABLE OF carte_inclusa%ROWTYPE INDEX BY PLS_INTEGER;
abonamente_c abo;
carte_c car;
carte_inclusa_c ci;
end;
/
CREATE OR REPLACE TRIGGER T11_HELP
    BEFORE UPDATE OR DELETE ON carti
BEGIN
    SELECT * BULK COLLECT INTO trig_help.abonamente_c
    FROM abonamente;
    SELECT * BULK COLLECT INTO trig_help.carte_c
    FROM carti;
    SELECT * BULK COLLECT INTO trig_help.carte_inclusa_c
    FROM carte_inclusa;
END;
/

CREATE OR REPLACE TRIGGER T11
    BEFORE UPDATE OR DELETE ON carti
    FOR EACH ROW
DECLARE 
    buffr number;
    v_pret_total NUMBER(4);
    v_pret_carte NUMBER(4);
    v_crestere_prop NUMBER(4);
BEGIN
    IF UPDATING THEN
        IF :NEW.carte_id != :OLD.carte_id THEN
            RAISE_APPLICATION_ERROR(-20001,'Nu este permisa schimbarea cheiilor primare din tabelul Carte');
        END IF;
        
        FOR i in 1..trig_help.abonamente_c.last LOOP
            v_pret_total := 0;
            IF :NEW.pret > :OLD.pret THEN -- ne intereseaza sa modificam doar daca pretul cartii e crescut
                FOR j in 1..trig_help.carte_c.last LOOP
                    buffr := 0;
                    SELECT COUNT(*) INTO buffr --nu o sa avem mutating, pt ca id-ul cartii nu se schimba
                    FROM carte_inclusa ci
                    WHERE ci.abonament_id = trig_help.abonamente_c(i).abonament_id AND ci.carte_id = trig_help.carte_c(j).carte_id;
                    
                    IF buffr > 0 THEN
                        v_pret_total := v_pret_total + trig_help.carte_c(j).pret; -- deoarece valorile sunt luate cu un trigger before, e ca si cum am apela :OLD pt valoarea schimbata
                    END IF;
                END LOOP;
                
                v_crestere_prop := :NEW.pret / :OLD.pret;
            
                UPDATE abonamente -- crestem proportia
                SET plata_lunara = plata_lunara + (:NEW.pret / v_pret_total) * plata_lunara
                WHERE abonament_id = trig_help.abonamente_c(i).abonament_id;
            END IF;
        END LOOP;
    ELSE --DELETING
        FOR i in 1..trig_help.abonamente_c.last LOOP
            v_pret_total := 0;
            FOR j in 1..trig_help.carte_c.last LOOP
                buffr := 0;
                -- trebuie sa folosim colectia din pachet, deoarece id-ul cartii este scos si din carte_inclusa
                FOR k in 1..trig_help.carte_inclusa_c.last LOOP
                    IF trig_help.carte_inclusa_c(k).abonament_id = trig_help.abonamente_c(i).abonament_id
                    AND trig_help.carte_inclusa_c(k).carte_id = trig_help.carte_c(j).carte_id THEN
                        buffr := 1;
                    END IF;
                END LOOP;
                
                IF buffr > 0 THEN
                    v_pret_total := v_pret_total + trig_help.carte_c(j).pret; -- deoarece valorile sunt luate cu un trigger before, e ca si cum am apela :OLD pt valoarea schimbata
                END IF;
            END LOOP;
            
            UPDATE abonamente -- crestem proportia
            SET plata_lunara = plata_lunara - (:OLD.pret / v_pret_total) * plata_lunara
            WHERE abonament_id = trig_help.abonamente_c(i).abonament_id;
        END LOOP;
    END IF;
END;
/

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