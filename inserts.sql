INSERT INTO Librarie
VALUES (1, 'Librarie 1', 'Strada Unirii nr. 23');
INSERT INTO Librarie
VALUES (2, 'Librarie 2', 'Strada Octavian Goga nr. 26');
INSERT INTO Librarie
VALUES (3, 'Librarie 3', 'Bulevardul Mare nr. 1');

INSERT INTO Job
VALUES(1, 'Manager'); 
INSERT INTO Job
VALUES(2, 'Librarier');
INSERT INTO Job
VALUES(3, 'IT-ist');
INSERT INTO Job
VALUES(4, 'Contabil');

INSERT INTO Angajat
VALUES(1, NULL, 1, 10000, 'Sefescu', 'Ion', TO_DATE('1972-10-11', 'YYYY-MM-DD'), TO_DATE('1996-07-23', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(2, 1, 2, 3000, 'Pop', 'Andrei', TO_DATE('1975-07-02', 'YYYY-MM-DD'), TO_DATE('1998-02-03', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(3, 1, 2, 3000, 'Bob', 'Alex', TO_DATE('1981-04-23', 'YYYY-MM-DD'), TO_DATE('1999-06-10', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(4, 1, 4, 2500, 'Ionescu', 'Radu', TO_DATE('1983-02-07', 'YYYY-MM-DD'), TO_DATE('2001-10-30', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(5, 1, 3, 5000, 'Petrescu', 'Alex', TO_DATE('1987-05-11', 'YYYY-MM-DD'), TO_DATE('2007-01-17', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(6, 1, 2, 4000, 'Marcu', 'Carl', TO_DATE('1979-06-13', 'YYYY-MM-DD'), TO_DATE('1998-03-01', 'YYYY-MM-DD'));
INSERT INTO Angajat
VALUES(7, 1, 2, 4100, 'Andreescu', 'Andrei', TO_DATE('1969-10-10', 'YYYY-MM-DD'), TO_DATE('1998-02-07', 'YYYY-MM-DD'));

INSERT INTO Lucreaza_In
VALUES (1, 1);
INSERT INTO Lucreaza_In
VALUES (2, 1);
INSERT INTO Lucreaza_In
VALUES (3, 1);
INSERT INTO Lucreaza_In
VALUES (1, 2);
INSERT INTO Lucreaza_In
VALUES (1, 3);
INSERT INTO Lucreaza_In
VALUES (1, 4);
INSERT INTO Lucreaza_In
VALUES (2, 4);
INSERT INTO Lucreaza_In
VALUES (3, 4);
INSERT INTO Lucreaza_In
VALUES (1, 5);
INSERT INTO Lucreaza_In
VALUES (2, 5);
INSERT INTO Lucreaza_In
VALUES (3, 5);
INSERT INTO Lucreaza_In
VALUES (2, 6);
INSERT INTO Lucreaza_In
VALUES (3, 7);

INSERT INTO Carte
VALUES (1, 'Stapanul Inelelor 1', 'J.R.R. Tolkien', 60, 'Fantezie');
INSERT INTO Carte
VALUES (2, 'Stapanul Inelelor 2', 'J.R.R. Tolkien', 60, 'Fantezie');
INSERT INTO Carte
VALUES (3, 'Stapanul Inelelor 3', 'J.R.R. Tolkien', 60, 'Fantezie');
INSERT INTO Carte
VALUES (4, '2001: O odisee spatiala', 'Arthur C. Clarke', 83, 'SF');
INSERT INTO Carte
VALUES (5, 'O mie noua sute optzeci si patru', 'George Orwell', 72, 'Politic');
INSERT INTO Carte
VALUES (6, 'Ion', 'Liviu Rebreanu', 25, 'Roman social');
INSERT INTO Carte
VALUES (7, 'Fundatia', 'Isaac Asimov', 65, 'SF');

INSERT INTO Se_Afla_In
VALUES(1,1);
INSERT INTO Se_Afla_In
VALUES(1,2);
INSERT INTO Se_Afla_In
VALUES(1,3);
INSERT INTO Se_Afla_In
VALUES(1,4);
INSERT INTO Se_Afla_In
VALUES(1,6);
INSERT INTO Se_Afla_In
VALUES(1,7);
INSERT INTO Se_Afla_In
VALUES(2,1);
INSERT INTO Se_Afla_In
VALUES(2,2);
INSERT INTO Se_Afla_In
VALUES(2,3);
INSERT INTO Se_Afla_In
VALUES(2,4);
INSERT INTO Se_Afla_In
VALUES(3,1);
INSERT INTO Se_Afla_In
VALUES(3,2);
INSERT INTO Se_Afla_In
VALUES(3,3);
INSERT INTO Se_Afla_In
VALUES(3,5);
INSERT INTO Se_Afla_In
VALUES(3,6);

INSERT INTO Abonament
VALUES (1, 10);
INSERT INTO Abonament
VALUES (2, 15);
INSERT INTO Abonament
VALUES (3, 25);

INSERT INTO Membru
VALUES (1, 'Andrei', 'Andrei', TO_DATE(1999-04-04, 'YYYY-MM-DD'), 1);
INSERT INTO Membru
VALUES (2, 'Popescu', 'Marina', TO_DATE(2001-03-22, 'YYYY-MM-DD'), 1);
INSERT INTO Membru
VALUES (3, 'Ionila', 'Ioana', TO_DATE(2002-10-10, 'YYYY-MM-DD'), NULL);
INSERT INTO Membru
VALUES (4, 'Paun', 'Silviu', TO_DATE(2000-10-01, 'YYYY-MM-DD'), 2);
INSERT INTO Membru
VALUES (5, 'Stefanescu', 'Stefan', TO_DATE(2003-05-10, 'YYYY-MM-DD'), 3);
INSERT INTO Membru
VALUES (6, 'Stancu', 'Loredana', TO_DATE(2001-11-02, 'YYYY-MM-DD'), 2);

INSERT INTO Carte_Inclusa
VALUES (1,1):
INSERT INTO Carte_Inclusa
VALUES (1,2):
INSERT INTO Carte_Inclusa
VALUES (1,3):
INSERT INTO Carte_Inclusa
VALUES (2,1):
INSERT INTO Carte_Inclusa
VALUES (2,2):
INSERT INTO Carte_Inclusa
VALUES (2,3):
INSERT INTO Carte_Inclusa
VALUES (2,4):
INSERT INTO Carte_Inclusa
VALUES (2,7):
INSERT INTO Carte_Inclusa
VALUES (3,1):
INSERT INTO Carte_Inclusa
VALUES (3,2):
INSERT INTO Carte_Inclusa
VALUES (3,3):
INSERT INTO Carte_Inclusa
VALUES (3,4):
INSERT INTO Carte_Inclusa
VALUES (3,5):
INSERT INTO Carte_Inclusa
VALUES (3,7):