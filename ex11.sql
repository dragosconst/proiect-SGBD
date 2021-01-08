--Cand pretul unei carti este schimbat, vrem ca schimbarea sa fie reflectata si in abonament, in cazul in care scumpim cartea
--Daca scoatem o carte din stoc, vom ieftini abonamentul cu procentajul pe care pretul cartii il reprezenta din intregul pachet al abonamentului.
--Pt a evita trigger mutating, vom folosi o colectie intr-un pachet, care este intializata cu un trigger la nivel de comanda.
CREATE OR REPLACE PACKAGE trig_help 
AS
TYPE abo IS TABLE OF abonament%ROWTYPE INDEX BY PLS_INTEGER;
TYPE car IS TABLE OF carte%ROWTYPE INDEX BY PLS_INTEGER;
abonamente_c abo;
carte_c car;
end;
/
CREATE OR REPLACE TRIGGER T11_HELP
    BEFORE UPDATE OR DELETE ON carte
BEGIN
    SELECT * BULK COLLECT INTO trig_help.abonamente_c
    FROM abonament;
    SELECT * BULK COLLECT INTO trig_help.carte_c
    FROM carte;
END;
/

CREATE OR REPLACE TRIGGER T11
    BEFORE UPDATE OR DELETE ON carte
    FOR EACH ROW
DECLARE 
    TYPE abonament_tab IS TABLE OF abonament%ROWTYPE INDEX BY PLS_INTEGER;
    abonamente abonament_tab;
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
                    SELECT COUNT(*) INTO buffr
                    FROM carte_inclusa ci
                    WHERE ci.abonament_id = trig_help.abonamente_c(i).abonament_id AND ci.carte_id = trig_help.carte_c(j).carte_id;
                    
                    IF buffr > 0 THEN
                        v_pret_total := v_pret_total + trig_help.carte_c(j).pret; -- deoarece valorile sunt luate cu un trigger before, e ca si cum am apela :OLD pt valoarea schimbata
                    END IF;
                END LOOP;
                
                v_crestere_prop := :NEW.pret / :OLD.pret;
            
                UPDATE abonament -- crestem proportia
                SET plata_lunara = plata_lunara + (:NEW.pret / v_pret_total) * plata_lunara
                WHERE abonament_id = trig_help.abonamente_c(i).abonament_id;
            END IF;
        END LOOP;
    ELSE --DELETING
        FOR i in 1..trig_help.abonamente_c.last LOOP
            v_pret_total := 0;
            FOR j in 1..trig_help.carte_c.last LOOP
                SELECT COUNT(*) INTO buffr
                FROM carte_inclusa ci
                WHERE ci.abonament_id = trig_help.abonamente_c(i).abonament_id AND ci.carte_id = trig_help.carte_c(j).carte_id;
                
                IF buffr > 0 THEN
                    v_pret_total := v_pret_total + trig_help.carte_c(j).pret; -- deoarece valorile sunt luate cu un trigger before, e ca si cum am apela :OLD pt valoarea schimbata
                END IF;
            END LOOP;
            
            UPDATE abonament -- crestem proportia
            SET plata_lunara = plata_lunara - (:OLD.pret / v_pret_total) * plata_lunara
            WHERE abonament_id = trig_help.abonamente_c(i).abonament_id;
        END LOOP;
    END IF;
END;
/