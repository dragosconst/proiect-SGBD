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