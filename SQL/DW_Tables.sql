
CREATE TABLE DIM_Kunde (
    KundenID            char(5)             not NULL PRIMARY KEY,
    Vorname             varchar(50)         NULL,
    Nachname            varchar(50)         not NULL,
    Kundentyp           char(2)             not NULL
)

CREATE TABLE DIM_Kreditinstitut (
    BIC                 char(11)            not NULL PRIMARY KEY,
    Bankname            varchar(50)         not NULL,
    Kreditinstitutart   char(1)             not NULL
)

CREATE TABLE DIM_Konto (
    IBAN                char(27)            not NULL PRIMARY KEY,
    BIC                 char(11)            not NULL                    
            REFERENCES DIM_Kreditinstitut (BIC),
    KundenID            char(5)             not NULL                    
            REFERENCES DIM_Kunde (KundenID),
    Kontoart            varchar(2)          not NULL,
    Kontostand          money               NULL
)


CREATE TABLE DIM_Zeit (
    Datum               date                not NULL PRIMARY KEY,
    Jahr                int                 not NULL,
    Monat               int                 not NULL,
    Woche               int                 not NULL,
    Tag                 int                 not NULL
)

CREATE TABLE Fakt_Buchung (
    Buchungsnummer      int                 not NULL PRIMARY KEY,
    Datum               date                not NULL
                    REFERENCES DIM_Zeit (Datum),
    Sender              char(27)            NULL
                    REFERENCES DIM_Konto (IBAN),
    Empfaenger          char(27)            NULL
                    REFERENCES DIM_Konto (IBAN),
    Buchungsart         char(1)             not NULL,                   
    Betrag              MONEY               not NULL,
)

CREATE TABLE Fakt_Buchung_Weekly (
    Jahr                int                 NOT NULL,
    Woche               int                 NOT NULL,
    Anzahl_Buchungen    int                 NOT NULL,
    Gesamtbetrag        money               NOT NULL,
    PRIMARY KEY (Jahr, Woche)
)
