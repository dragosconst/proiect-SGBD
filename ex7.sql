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