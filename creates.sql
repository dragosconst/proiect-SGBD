CREATE TABLE Librarii (
    Librarie_Id NUMBER NOT NULL,
    Denumire VARCHAR2(50) NOT NULL,
    Adresa VARCHAR2(100) NOT NULL,
    PRIMARY KEY (Librarie_Id)
);

CREATE TABLE Carti (
    Carte_Id NUMBER NOT NULL,
    Denumire VARCHAR2(60) NOT NULL,
    Autor VARCHAR(50) NOT NULL,
    Pret NUMBER NOT NULL,
    Categorie VARCHAR2(50) NOT NULL,
    PRIMARY KEY (Carte_Id)
);

CREATE TABLE Abonamente(
    Abonament_Id NUMBER NOT NULL,
    Plata_Lunara NUMBER NOT NULL,
    PRIMARY KEY (Abonament_Id)
);

CREATE TABLE Membri (
    Membru_Id NUMBER NOT NULL,
    Nume VARCHAR2(50) NOT NULL,
    Prenume VARCHAR2(50) NOT NULL,
    Data_Inscrierii DATE NOT NULL,
    Abonament_Id NUMBER,
    PRIMARY KEY (Membru_Id),
    CONSTRAINT fk_abon
    FOREIGN KEY (Abonament_Id)
    REFERENCES Abonamente(Abonament_Id)
);

CREATE TABLE Carte_Inclusa(
    Abonament_Id NUMBER NOT NULL,
    Carte_Id NUMBER NOT NULL,
    PRIMARY KEY (Abonament_Id, Carte_Id),
    CONSTRAINT fk_col_ab
    FOREIGN KEY (Abonament_Id)
    REFERENCES Abonamente(Abonament_Id),
    CONSTRAINT fk_col_car
    FOREIGN KEY (Carte_Id)
    REFERENCES Carti(Carte_Id)
);

CREATE TABLE Se_Afla_In (
    Librarie_Id NUMBER NOT NULL,
    Carte_Id NUMBER NOT NULL,
    PRIMARY KEY (Librarie_Id, Carte_Id),
    CONSTRAINT fk_asoc_sb
    FOREIGN KEY (Librarie_Id)
    REFERENCES Librarii(Librarie_Id),
    CONSTRAINT fk_asoc_sc
    FOREIGN KEY (Carte_Id)
    REFERENCES Carti(Carte_Id)
);


CREATE TABLE Jobs (
    Job_Id NUMBER NOT NULL,
    Denumire VARCHAR2(50) NOT NULL,
    PRIMARY KEY (Job_Id)
);

CREATE TABLE Angajati (
	 Angajat_Id NUMBER NOT NULL,
	 Manager_Id NUMBER DEFAULT NULL,
	 Job_Id NUMBER NOT NULL,
	 Salariu NUMBER NOT NULL,
	 Nume VARCHAR2(50) NOT NULL,
	 Prenume VARCHAR2(50) NOT NULL,
	 Data_Nasterii DATE DEFAULT NULL,
	 Data_Angajarii DATE NOT NULL,
	 PRIMARY KEY (Angajat_Id),
	 CONSTRAINT fk_col
	 FOREIGN KEY (Job_Id)
	 REFERENCES Jobs(Job_Id),
	 CONSTRAINT fk_man
	 FOREIGN KEY (Manager_Id)
	 REFERENCES Angajati(Angajat_Id)
);

CREATE TABLE Lucreaza_In (
    Librarie_Id NUMBER NOT NULL,
    Angajat_Id NUMBER NOT NULL,
    PRIMARY KEY(Librarie_Id, Angajat_Id),
    CONSTRAINT fk_asoc_b
    FOREIGN KEY (Librarie_Id)
    REFERENCES Librarii(Librarie_Id),
    CONSTRAINT fk_asoc_a
    FOREIGN KEY (Angajat_Id)
    REFERENCES Angajati(Angajat_Id)
);
