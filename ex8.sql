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