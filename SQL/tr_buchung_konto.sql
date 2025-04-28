CREATE TRIGGER [dbo].[tr_buchung_konto] 
ON ED_BUCHUNG FOR INSERT 
AS

BEGIN

    --Bei Einzahlung Betrag auf Kontostand hinzuaddieren
    UPDATE ED_KONTO
    SET Kontostand = Kontostand + i.Betrag
    FROM ED_KONTO k
    INNER JOIN inserted i
        ON k.IBAN = i.Empfaenger
    WHERE i.Buchungsart = 'E'

    --Bei Auszahlung Betrag aus Kontostand subtrahieren
    UPDATE ED_KONTO
    SET Kontostand = Kontostand - i.Betrag
    FROM ED_KONTO k
    INNER JOIN inserted i
        ON k.IBAN = i.Sender
    WHERE i.Buchungsart = 'A'

    --Bei Überweisung subtrahiere Betrag vom Sender und erhöhe denselben Betrag auf Empfaenger
    UPDATE ED_KONTO
    SET Kontostand = Kontostand - i.Betrag
    FROM ED_KONTO k
    INNER JOIN inserted i
        ON k.IBAN = i.Sender
    WHERE i.Buchungsart = 'U'

    UPDATE ED_KONTO
    SET Kontostand = Kontostand + i.Betrag
    FROM ED_KONTO k
    INNER JOIN inserted i
        ON k.IBAN = i.Empfaenger
    WHERE i.Buchungsart = 'U'
END