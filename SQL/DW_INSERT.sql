
BEGIN TRANSACTION ADD_DIM_ZEIT
insert INTO DIM_ZEIT(Datum, Jahr, Monat, Woche, Tag)
    SELECT DISTINCT
    Buchungsdatum AS Datum,
    YEAR(Buchungsdatum) AS Jahr,
    MONTH(Buchungsdatum) AS Monat,
    DATEPART(Week, Buchungsdatum) AS Woche,
    Day(Buchungsdatum) AS Tag
    FROM ED_Buchung
COMMIT TRANSACTION ADD_DIM_ZEIT


BEGIN TRANSACTION ADD_DIM_Kunde
insert INTO DIM_Kunde(KundenID, Vorname, Nachname, Kundentyp)
    SELECT
    Kundennummer AS KundenID,
    Vorname,
    Name AS Nachname,
    Kundentyp
    FROM ED_Kunde
COMMIT TRANSACTION ADD_DIM_Kunde

BEGIN TRANSACTION ADD_DIM_Kreditinstitut
insert INTO DIM_Kreditinstitut(BIC, Bankname, Kreditinstitutart)
    SELECT
    BIC,
    Bankname,
    KIA_Art
    FROM ED_KREDITINSTITUT
COMMIT TRANSACTION ADD_DIM_Kreditinstitut

BEGIN TRANSACTION ADD_DIM_Konto
insert INTO DIM_Konto(IBAN, BIC, KundenID, Kontoart, Kontostand)
    SELECT
    k.IBAN,
    k.BIC,
    ku.Kundennummer AS KundenID,
    k.Kontoart,
    k.Kontostand
    FROM ED_Konto k 
    JOIN ED_Kunde ku ON  k.Kontoinhaber = ku.Kundennummer
COMMIT TRANSACTION ADD_DIM_Konto

BEGIN TRANSACTION ADD_Fakt_Buchung
insert INTO Fakt_Buchung(Buchungsnummer, Datum, Sender, Empfaenger, Buchungsart, Betrag)
    SELECT 
    b.Buchungsnummer,
    z.Datum,
    b.Sender,
    b.Empfaenger,
    b.Buchungsart,
    b.Betrag
    FROM ED_Buchung b

    LEFT JOIN DIM_Zeit z ON b.Buchungsdatum = z.Datum
    WHERE z.Datum IS NOT NULL
COMMIT TRANSACTION ADD_Fakt_Buchung


BEGIN TRANSACTION ADD_Fakt_Buchung_Weekly
INSERT INTO Fakt_Buchung_Weekly (Jahr, Woche, Anzahl_Buchungen, Gesamtbetrag)
    SELECT 
    YEAR(Datum) AS Jahr, 
    DATEPART(WEEK, Datum) AS Woche,       
    COUNT(*) AS Anzahl_Buchungen,         
    SUM(Betrag) AS Gesamtbetrag           
    FROM Fakt_Buchung
    GROUP BY YEAR(Datum), DATEPART(WEEK, Datum)
COMMIT TRANSACTION ADD_Fakt_Buchung_Weekly