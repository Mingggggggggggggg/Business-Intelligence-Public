CREATE PROCEDURE DW_REPORT(
    @ReportType varchar(50) NULL,
    @StartDate date = NULL,
    @EndDate date = NULL
)
AS

--Tag, Gesamt, Woche, Kunde, Kreditinstitut
BEGIN
    DECLARE @ConvDate_Start date
    DECLARE @ConvDate_End date
    SET @ConvDate_Start = @StartDate
    SET @ConvDate_End = @EndDate

    print('_________________________________________________________________________________________________________________________________________')
    print('                                                 Reporttyp: ' + @ReportType)
    print('                                                 Anfangsdatum: ' + CONVERT(VARCHAR, @ConvDate_Start, 104))
    print('                                                 Enddatum: ' + CONVERT(VARCHAR, @ConvDate_End, 104))
    print('_________________________________________________________________________________________________________________________________________')
    BEGIN TRY


        IF @ReportType = 'Tag'
        BEGIN
        print ('Tagesbericht: Buchungen und Beträge pro Tag gesuchten Zeitraum ')
        print (CONVERT(VARCHAR, @ConvDate_Start, 104) + ' bis ' + CONVERT(VARCHAR, @ConvDate_End, 104))
        print ('_________________________________________________________________________________________________________________________________________')
        DECLARE @SUM_Buchungen INT
        DECLARE @SUM_Betrag money

        SELECT
            @SUM_Buchungen = COUNT(fb.Buchungsnummer),
            @SUM_Betrag = SUM(fb.Betrag)
        FROM Fakt_Buchung fb
            INNER JOIN DIM_Zeit dz ON fb.Datum = dz.Datum
        WHERE (@StartDate IS NULL OR fb.Datum >= @StartDate) AND (@EndDate IS NULL OR fb.Datum <= @EndDate)
        print ('     Gesamtanzahl Buchungen: ' + CONVERT(VARCHAR, @SUM_Buchungen))
        print ('     Gesamtbetrag: ' + CONVERT(VARCHAR, @SUM_Betrag) + ' Euro')
        print ('_________________________________________________________________________________________________________________________________________')
    END


        ELSE IF @ReportType = 'Gesamt'
        BEGIN
        print ('Gesamtbericht: Buchungen und Beträge im gesamten Zeitraum ')
        print ('_________________________________________________________________________________________________________________________________________')
        DECLARE @Gesamt_Buchung INT
        DECLARE @Gesamt_Betrag money
        DECLARE @NoDate date

        SELECT
            @SUM_Buchungen = COUNT(fb.Buchungsnummer),
            @SUM_Betrag = SUM(fb.Betrag)
        FROM Fakt_Buchung fb
            INNER JOIN DIM_Zeit dz ON fb.Datum = dz.Datum
        WHERE (@NoDate IS NULL OR fb.Datum >= @NoDate) AND (@NoDate IS NULL OR fb.Datum <= @NoDate)
        print ('     Gesamtanzahl Buchungen: ' + CONVERT(VARCHAR, @SUM_Buchungen))
        print ('     Gesamtbetrag: ' + CONVERT(VARCHAR, @SUM_Betrag) + ' Euro')
        print ('_________________________________________________________________________________________________________________________________________')
    END
            

        ELSE IF @ReportType = 'Woche'
        BEGIN
        print ('Wochenbericht: Buchungen und Beträge pro Woche im gesuchten Zeitraum ')
        print (CONVERT(VARCHAR, @ConvDate_Start, 104) + ' bis ' + CONVERT(VARCHAR, @ConvDate_End, 104))
        print ('_________________________________________________________________________________________________________________________________________')
        DECLARE @Woche_Buchung INT
        DECLARE @Woche_Betrag money

        SELECT
            @Woche_Buchung = SUM(fbw.Anzahl_Buchungen),
            @Woche_Betrag = SUM(fbw.Gesamtbetrag)
        FROM Fakt_Buchung_Weekly fbw
        WHERE (@StartDate IS NULL OR (fbw.Jahr * 100 + fbw.Woche) >= (DATEPART(YEAR, @StartDate) * 100 + DATEPART(WEEK, @StartDate)))
            AND (@EndDate IS NULL OR (fbw.Jahr * 100 + fbw.Woche) <= (DATEPART(YEAR, @EndDate) * 100 + DATEPART(WEEK, @EndDate)))
        print ('     Gesamtanzahl Buchungen: ' + CONVERT(VARCHAR, @Woche_Buchung))
        print ('     Gesamtbetrag: ' + CONVERT(VARCHAR, @Woche_Betrag) + ' Euro')
        print ('_________________________________________________________________________________________________________________________________________')
    END


        ELSE IF @ReportType = 'Kunde'
        BEGIN
        print ('Kundenbericht: Buchungen und Beträge von Privat- und Firmenkunden im gesuchten Zeitraum ')
        print (CONVERT(VARCHAR, @ConvDate_Start, 104) + ' bis ' + CONVERT(VARCHAR, @ConvDate_End, 104))
        print ('_________________________________________________________________________________________________________________________________________')
        DECLARE @PK_Buchung int
        DECLARE @PK_Betrag money
        DECLARE @FK_Buchung int
        DECLARE @FK_Betrag money
        DECLARE @DIFF_Buchung INT
        DECLARE @DIFF_Betrag money
        DECLARE @GESAMT_KBuchung int
        DECLARE @GESAMT_KBetrag int
        DECLARE @DIFF_Prozent_Buchung float
        DECLARE @DIFF_Prozent_Betrag float


        --Privatkunde
        SELECT 
            @PK_Buchung = COUNT(fb.Buchungsnummer),
            @PK_Betrag = SUM(fb.Betrag)
        FROM Fakt_Buchung fb
        LEFT JOIN DIM_Konto dkSender ON fb.Sender = dkSender.IBAN
        LEFT JOIN DIM_Konto dkEmpf ON fb.Empfaenger = dkEmpf.IBAN
        LEFT JOIN DIM_Kunde dkuSender ON dkSender.KundenID = dkuSender.KundenID
        LEFT JOIN DIM_Kunde dkuEmpf ON dkEmpf.KundenID = dkuEmpf.KundenID
        WHERE ((dkuSender.Kundentyp = 'PK') OR (dkuEmpf.Kundentyp = 'PK')) AND (@StartDate is NULL OR fb.Datum >= @StartDate) AND (@EndDate is NULL OR fb.Datum <= @EndDate)

        --Firmenkunde
        SELECT 
            @FK_Buchung = COUNT(fb.Buchungsnummer),
            @FK_Betrag = SUM(fb.Betrag)
        FROM Fakt_Buchung fb
        LEFT JOIN DIM_Konto dkSender ON fb.Sender = dkSender.IBAN
        LEFT JOIN DIM_Konto dkEmpf ON fb.Empfaenger = dkEmpf.IBAN
        LEFT JOIN DIM_Kunde dkuSender ON dkSender.KundenID = dkuSender.KundenID
        LEFT JOIN DIM_Kunde dkuEmpf ON dkEmpf.KundenID = dkuEmpf.KundenID
        WHERE ((dkuSender.Kundentyp = 'FK') OR (dkuEmpf.Kundentyp = 'FK')) AND (@StartDate is NULL OR fb.Datum >= @StartDate) AND (@EndDate is NULL OR fb.Datum <= @EndDate)

        print ('______________________________________________________________Privatkunde________________________________________________________________')
        print ('    Getätigte Buchungen: ' + ISNULL(CONVERT(varchar, @PK_Buchung), 0))
        print ('    Gesamtbetrag: ' + ISNULL(CONVERT(varchar, @PK_Betrag), 0) + ' Euro' + char(13))

        print ('______________________________________________________________Firmenkunde________________________________________________________________')
        print ('    Getätigte Buchungen: ' + ISNULL(CONVERT(varchar, @FK_Buchung), 0))
        print ('    Gesamtbetrag: ' + ISNULL(CONVERT(varchar, @FK_Betrag), 0) + ' Euro')
        print ('_________________________________________________________________________________________________________________________________________')

        --Analyse
        SELECT
            @DIFF_Buchung = @PK_Buchung - @FK_Buchung,
            @DIFF_Betrag = @PK_Betrag - @FK_Betrag,
            @GESAMT_KBuchung = @PK_Buchung + @FK_Buchung,
            @GESAMT_KBetrag = @PK_Betrag + @FK_Betrag



        IF @DIFF_Buchung >= 0
        BEGIN
            SET @DIFF_Prozent_Buchung = (CAST(@PK_Buchung AS FLOAT) / CAST(@GESAMT_KBuchung AS FLOAT)) * 100
            print ('Privatkunden haben im gesuchten Zeitraum ' + CONVERT(VARCHAR, @DIFF_Buchung) + ' mehr Buchungen durchgeführt als Firmenkunden.')
            print ('Dies entspricht ' + CONVERT(VARCHAR, @DIFF_Prozent_Buchung) + '% der Gesamtbuchungen.')
            print ('_________________________________________________________________________________________________________________________________________')
        END
        ELSE
        BEGIN 
            SET @DIFF_Prozent_Buchung = (CAST(@PK_Buchung AS FLOAT) / CAST(@GESAMT_KBuchung AS FLOAT)) * 100
            SET @DIFF_Buchung = @DIFF_Buchung * -1
            print ('FirmenKunden haben im gesuchten Zeitraum ' + CONVERT(VARCHAR, @DIFF_Buchung) + ' mehr Buchungen durchgeführt als Privatkunden.')
            print ('Dies entspricht ' + CONVERT(VARCHAR, @DIFF_Prozent_Buchung) + '% der Gesamtbuchungen.')
            print ('_________________________________________________________________________________________________________________________________________')
        END

        IF @DIFF_Betrag >= 0
        BEGIN
            SET @DIFF_Prozent_Betrag = (CAST(@PK_Betrag AS FLOAT) / CAST(@GESAMT_KBetrag AS FLOAT)) * 100
            print ('Privatkunden haben im gesuchten Zeitraum Beträge in Höhe von ' + CONVERT(VARCHAR, @DIFF_Betrag) + ' Euro bewegt.')
            print ('Dies entspricht ' + CONVERT(VARCHAR, @DIFF_Prozent_Betrag) + '% der Gesamtbeträge.')
            print ('_________________________________________________________________________________________________________________________________________')
        END
        ELSE
        BEGIN
            SET @DIFF_Betrag = @DIFF_Betrag * -1
            SET @DIFF_Prozent_Betrag = (CAST(@FK_Betrag AS FLOAT) / CAST(@GESAMT_KBetrag AS FLOAT)) * 100
            print ('Firmenkunden haben im gesuchten Zeitraum Beträge in Höhe von' + CONVERT(VARCHAR, @DIFF_Betrag) + ' Euro bewegt.')
            print ('Dies entspricht ' + CONVERT(VARCHAR, @DIFF_Prozent_Betrag) + '% der Gesamtbeträge.')
            print ('_________________________________________________________________________________________________________________________________________')        
        END  
    END


        ELSE IF @ReportType = 'Kreditinstitut'
        BEGIN
        print ('Kreditinstitutbericht: Buchungen und Beträge von Genossenschafts-, ')
        print (' oeffentlich rechtliche- und Privatkreditinstitute im gesuchten Zeitraum')
        print (CONVERT(VARCHAR, @ConvDate_Start, 104) + ' bis ' + CONVERT(VARCHAR, @ConvDate_End, 104))
        print ('_____________________________________________________________________________________________________________________________________________')
            DECLARE @Buchungen_G INT
            DECLARE @Betrag_G MONEY
            DECLARE @Buchungen_O INT
            DECLARE @Betrag_O MONEY
            DECLARE @Buchungen_P INT
            DECLARE @Betrag_P MONEY

            --Genossenschaftsbanken
            SELECT 
                @Buchungen_G = COUNT(fb.Buchungsnummer),
                @Betrag_G = SUM(fb.Betrag)
            FROM Fakt_Buchung fb
            LEFT JOIN DIM_Konto dkSender ON fb.Sender = dkSender.IBAN
            LEFT JOIN DIM_Konto dkEmpf ON fb.Empfaenger = dkEmpf.IBAN
            LEFT JOIN DIM_Kreditinstitut dkiSender ON dkSender.BIC = dkiSender.BIC
            LEFT JOIN DIM_Kreditinstitut dkiEmpf ON dkEmpf.BIC = dkiEmpf.BIC
            WHERE ((dkiSender.Kreditinstitutart = 'G') OR (dkiEmpf.Kreditinstitutart = 'G')) AND (@StartDate IS NULL OR fb.Datum >= @StartDate) AND (@EndDate IS NULL OR fb.Datum <= @EndDate)

            --Oeffentlich-rechtliche Kreditinstitute
            SELECT 
                @Buchungen_O = COUNT(fb.Buchungsnummer),
                @Betrag_O = SUM(fb.Betrag)
            FROM Fakt_Buchung fb
            LEFT JOIN DIM_Konto dkSender ON fb.Sender = dkSender.IBAN
            LEFT JOIN DIM_Konto dkEmpf ON fb.Empfaenger = dkEmpf.IBAN
            LEFT JOIN DIM_Kreditinstitut dkiSender ON dkSender.BIC = dkiSender.BIC
            LEFT JOIN DIM_Kreditinstitut dkiEmpf ON dkEmpf.BIC = dkiEmpf.BIC
            WHERE ((dkiSender.Kreditinstitutart = 'O') OR (dkiEmpf.Kreditinstitutart = 'O')) AND (@StartDate IS NULL OR fb.Datum >= @StartDate) AND (@EndDate IS NULL OR fb.Datum <= @EndDate)

            --Privatbanken
            SELECT 
                @Buchungen_P = COUNT(fb.Buchungsnummer),
                @Betrag_P = SUM(fb.Betrag)
            FROM Fakt_Buchung fb
            LEFT JOIN DIM_Konto dkSender ON fb.Sender = dkSender.IBAN
            LEFT JOIN DIM_Konto dkEmpf ON fb.Empfaenger = dkEmpf.IBAN
            LEFT JOIN DIM_Kreditinstitut dkiSender ON dkSender.BIC = dkiSender.BIC
            LEFT JOIN DIM_Kreditinstitut dkiEmpf ON dkEmpf.BIC = dkiEmpf.BIC
            WHERE ((dkiSender.Kreditinstitutart = 'P') OR (dkiEmpf.Kreditinstitutart = 'P')) AND (@StartDate IS NULL OR fb.Datum >= @StartDate) AND (@EndDate IS NULL OR fb.Datum <= @EndDate)


            print ('___________________________________________________Kreditinstitut Genossenschaftsbanken_______________________________________________________')
            print ('    Getätigte Buchungen: ' + ISNULL(CONVERT(VARCHAR, @Buchungen_G), '0'))
            print ('    Gesamtbetrag: ' + ISNULL(CONVERT(VARCHAR, @Betrag_G), '0') + ' Euro' + CHAR(13))

            print ('___________________________________________Kreditinstitut Oeffentlich-rechtliche Kreditinstitute______________________________________________')
            print ('    Getätigte Buchungen: ' + ISNULL(CONVERT(VARCHAR, @Buchungen_O), '0'))
            print ('    Gesamtbetrag: ' + ISNULL(CONVERT(VARCHAR, @Betrag_O), '0') + ' Euro' + CHAR(13))

            print ('_______________________________________________________Kreditinstitut Privatbanken____________________________________________________________')
            print ('    Getätigte Buchungen: ' + ISNULL(CONVERT(VARCHAR, @Buchungen_P), '0'))
            print ('    Gesamtbetrag: ' + ISNULL(CONVERT(VARCHAR, @Betrag_P), '0') + ' Euro')
            print ('______________________________________________________________________________________________________________________________________________')
        END
 

    END TRY
    BEGIN CATCH
        print ERROR_MESSAGE()
        return
    END CATCH
END