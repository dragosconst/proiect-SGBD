CREATE TABLE Biblioteca (
    BibliotecaId NUMBER NOT NULL,
    Denumire VARCHAR2(50) NOT NULL,
    Adresa VARCHAR2(100) NOT NULL,
    PRIMARY KEY (BibliotecaId)
);

CREATE TABLE Carte (
    CarteId NUMBER NOT NULL,
    Denumire VARCHAR2(60) NOT NULL,
    Pret NUMBER NOT NULL,
    Categorie VARCHAR2(50) NOT NULL,
    PRIMARY KEY (CarteId)
);

CREATE TABLE Abonament(
    AbonamentId NUMBER NOT NULL,
    PlataLunara NUMBER NOT NULL,
    PRIMARY KEY (AbonamentId)
);

CREATE TABLE Membru (
    MembruId NUMBER NOT NULL,
    Nume VARCHAR2(50) NOT NULL,
    Prenume VARCHAR2(50) NOT NULL,
    DataInscrierii DATE NOT NULL,
    AbonamentId NUMBER NOT NULL,
    PRIMARY KEY (MembruId),
    CONSTRAINT fk_abon
    FOREIGN KEY (AbonamentId)
    REFERENCES Abonament(AbonamentId)
);

CREATE TABLE CarteInclusa(
    AbonamentId NUMBER NOT NULL,
    CarteId NUMBER NOT NULL,
    PRIMARY KEY (AbonamentId, CarteId),
    CONSTRAINT fk_col_ab
    FOREIGN KEY (AbonamentId)
    REFERENCES Abonament(AbonamentId),
    CONSTRAINT fk_col_car
    FOREIGN KEY (CarteId)
    REFERENCES Carte(CarteId)
);

CREATE TABLE SeAflaIn (
    BibliotecaId NUMBER NOT NULL,
    CarteId NUMBER NOT NULL,
    PRIMARY KEY (BibliotecaId, CarteId),
    CONSTRAINT fk_asoc_sb
    FOREIGN KEY (BibliotecaId)
    REFERENCES Biblioteca(BibliotecaId),
    CONSTRAINT fk_asoc_sc
    FOREIGN KEY (CarteId)
    REFERENCES Carte(CarteId)
);


CREATE TABLE Job (
    JobId NUMBER NOT NULL,
    Denumire VARCHAR2(50) NOT NULL,
    PRIMARY KEY (JobId)
);

CREATE TABLE Angajat (
	 AngajatId NUMBER NOT NULL,
	 ManagerId NUMBER DEFAULT NULL,
	 JobId NUMBER NOT NULL,
	 Salariu NUMBER NOT NULL,
	 Nume VARCHAR2(50) NOT NULL,
	 Prenume VARCHAR2(50) NOT NULL,
	 DataNasterii DATE DEFAULT NULL,
	 DataAnagajarii DATE NOT NULL,
	 PRIMARY KEY (AngajatId),
	 CONSTRAINT fk_col
	 FOREIGN KEY (JobId)
	 REFERENCES Job(JobId),
	 CONSTRAINT fk_man
	 FOREIGN KEY (ManagerId)
	 REFERENCES Angajat(AngajatId)
);

CREATE TABLE LucreazaIn (
    BibliotecaId NUMBER NOT NULL,
    AngajatId NUMBER NOT NULL,
    PRIMARY KEY(BibliotecaId, AngajatId),
    CONSTRAINT fk_asoc_b
    FOREIGN KEY (BibliotecaId)
    REFERENCES Biblioteca(BibliotecaId),
    CONSTRAINT fk_asoc_a
    FOREIGN KEY (AngajatId)
    REFERENCES Angajat(AngajatId)
);