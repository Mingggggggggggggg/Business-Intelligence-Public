# Business Intelligence WiSe24/25
## 1. Aufgabenstellung

1. Einrichtung der eigenen Datenbank durch bereitgestellte SQL-Skripte.
2. Erstellung eines Triggers, die beim Einfügen eines neuen Datensatzes in
ED_Buchung automatisch je nach Buchungsart die entsprechende Kontostände
anpasst und speichert.
3. Erstellung eines SQL-Skriptes INSERT_EXTRA für die Erweiterung des
Grunddatenbestandes um mindestens 10 Konto-, 5 Kreditinstitut- und 100
Buchungseinträge. Das Skript soll in einem „sql“ Ordner gespeichert werden.
4. Entwicklung eines Java Programmes, das zusätzliche Daten in einer „K2.txt“ Datei
ausliest und in ED_Konto lädt. Das Programm soll Fehlerhafte Daten erkennen und
entsprechend behandeln.
5. Entwerfen eines Star- oder Snowflake Schemas für ein Data Warehouses, welches
die Analyse und Auswertung von Buchungen ermöglicht. Als Faktenattribute sollen
mindestens Anzahl an Buchungen und Beträge berücksichtigt werden.
Auswertungen sollen auf Kunden, Konten, Kreditinstitute und Zeiträume möglich
sein. Eine aggregierte Faktenwerte auf Wochenbasis soll zusätzlich verfügbar sein.
6. Erstellung von ETL-SQL-Skripten, um Daten aus der operativen Datenbank in das
Data Warehouse zu laden
7. Entwicklung einer Datenbank Prozedur „DW_Report“, die zu allen oder
ausgewählten Merkmalen der vorhandenen Dimensionen verfügbare Kennzahlen
berechnet und anzeigt. Aggregattabellen sollen berücksichtigt werden. Zeitabschnitt
sowie Parameter der Dimension sollen weitgehend variabel sein. Die Prozedur soll
eine komfortable Auswertung des Data Warehouse ermöglichen und soll daher
entsprechend, für die Konsole, formatiert werden. Aufrufbeispiel mit beispielhaften
Parameter ist der Dokumentation hinzuzufügen!
8. Erstellung einer Visualisierung der Auswertungen mittels Power-BI. Mindestens fünf
Auswertungsszenarien sollen dafür entworfen werden und entsprechend dargestellt
werden.

## 2. Lösungswegbeschreibung
Die Tabellen wurden mit den bereitgestellten SQL Skripten eingerichtet.

### 2.1 Trigger erstellen
Der Trigger „tr_buchung_konto“ aktualisiert bei neu eingehenden Buchungen (INSERTs)
in der Tabelle ED_Buchung die Kontostände in ED_Konto. Dabei unterscheidet dieser,
ob es sich bei der Buchung um eine Auszahlung, Überweisung oder Einzahlung handelt.
Bei einer Auszahlung wird der Kontobestand des Senders um den ausgezahlten Betrag
reduziert. Bei einer Überweisung wird der überwiesene Betrag auf Seiten des Senders
reduziert und auf dem Konto des Empfängers erhöht. Bei einer Einzahlung erhöht sich
der Kontobestand auf Seitens des Empfängers um den eingezahlten Betrag. Der SQL
Skript zur Erstellung eines Triggers ist im Anhang unter „tr_buchung_konto“ zu
entnehmen.
### 2.2 Grundbestand erweitern
Der Grundbestand muss nach Aufgabenstellung um 5 Kreditinstitute, 10 Konten und 100
Buchungen erweitert werden. Hierbei habe ich die Grundbestände entsprechend erweitert
und sich gegenseitig referenzieren lassen, um verwaiste Datensätze vorzubeugen. Der
SQL Skript zur Erweiterung des Grundbestandes ist im Anhang unter „INSERT_EXTRA“
zu entnehmen.
### 2.3 Java Programm
Das Java Programm soll eine CSV bzw. TXT Datei mit neuen Konten einlesen und diese
Daten in ED_Konto laden. Das Programm soll fehlerhafte Daten erkennen und
entsprechend behandeln.
Das Java Programm besteht aus zwei Klassen, einer start.java und CsvProcessor.java
Klasse. Der Code zum Java Programm ist im Anhang unter „Java Code“ zu entnehmen.
#### 2.3.1 start.java Klasse
Die start Klasse dient als Hauptklasse der Anwendung. Diese enthält eine Loginfunktion
zum Verbindungsaufbau mit der Zieladresse der SQL Datenbank, Dateipfad zur
CSV Datei und SQL Insert Statements. Der Code zum Verbindungsaufbau und Insert SQL
Statements wurden jeweils aus dem Beispielcode „J01“ und „J10“ von Herrn Wulff
inspiriert und Teile zum Verbindungsaufbau wurden übernommen. Die start Klasse
koordiniert den gesamten Prozess von Verarbeitung bis hin zum Einfügen in die
Datenbank.
#### 2.3.2 CsvProcessor.java Klasse
Die CsvProcessor Klasse enthält die Logik zur Verarbeitung der CSV Daten. Sie liest
eine Datei ein, überprüft diese auf Gültigkeit und speichert diese in ein zweidimensionales String Array. Ungültige und doppelte Einträge werden ignoriert. Maximale Zeilengröße
wird auf 100 Zeilen statisch beschränkt und kann durch ersetzen der 100 geändert
werden:
##### 2.3.2.1 toProcessCsv Methode
![Abbildung 1: Statische Arraygröße auf 100](https://github.com/user-attachments/assets/4db89a28-19ed-49ae-ba39-9f1ee923b21c)

Die toProcessCsv Methode öffnet mithilfe des filePath Parameters und des
BufferedReaders die CSV Datei und durchläuft jede Zeile und überspringt
Kommentarzeilen und Leerzeichen. Die relevanten Daten werden mit einem Semikolon in
Spalten segmentiert. Jede durchlaufende Zeile wird mit der isValid und isDuplicate
Methode auf Gültigkeit und Einzigartigkeit geprüft.
##### 2.3.2.2 isValid Methode
Die isValid Methode prüft, ob jede Zeile sieben Spalten hat, Kontoart nicht null,
```String=“null“ oder leer``` ist, und die Spalten Kontostand, Soll- und Habenzins korrekt als
Double durchgehen können.
##### 2.3.2.3 isDuplicate Methode
Die isDuplicate Methode vergleicht jede neue Zeile mit bereits gespeicherten Zeilen, um
Duplikate IBANs zu vermeiden. Die IBANe werden sequentiell verglichen, was bei großen
Datensätzen sehr ineffizient ist.

### 2.4 Data Warehouse Snowflake Schema
Die Fakten und Dimensionen zur Erstellung des Data Warehouses werden aus den
Vorgaben des Pflichtenheftes und eigenen Auswertungsszenarien entnommen.
| Dimensionen | Fakten |
|------------|----------|
| Konto | Buchungsnummer |
| Kreditinstitut | Buchungsart |
| Kunde | Betrag |
| Zeit |  |


Aus den ermittelten Dimensionen und Fakten ergeben sich folgendes Snowflake Schema.
Die Fakten „Buchungsnummer“, „Buchungsart“ und „Betrag“ werden in der
Faktentabelle „Buchung“ festgelegt, wobei diese Tabelle durch Fremdschlüssel mit den
Dimensionstabellen „Zeit“ und „Konto“ verknüpft sind, zusätzlich sind zu der
Dimensionstabelle „Konto“ die Dimensionen „Kreditinstitut“ und „Kunde“ verknüpft.
Zusätzlich wird eine aggregierte Faktentabelle auf Wochenbasis erstellt, die jedoch in
Abbildung 2 nicht gezeigt wird. Die SQL Skripte zur Erstellung des Data Warehouses sind
im Anhang unter „DW_Tables“ zu entnehmen.
![Abbildung 2: Snowflake Modell](https://github.com/user-attachments/assets/221ea0b9-c3cc-468b-8957-270849e352e3)

### 2.5 SQL Skripte
#### 2.2.1 ETL Skript
Der ETL Skript befüllt das zuvor erstellte Data Warehouses, indem diese Daten aus der
operativen Datenbank lädt und in die Data Warehouse transformiert. Zusätzlich wird eine
seperate Aggregationstabelle auf Wochenbasis befüllt. Der ETL-Skript ist im Anhang
„DW_INSERT“ zu entnehmen.
#### 2.2.2 DW_Report
Die Prozedur DW_Report ermöglicht eine komfortable Auswertung des Data Warehouses,
indem sie aggregierte Daten aus den Faktentabellen, Dimensionen und gewünschten
Zeiträumen basierend auf ausgewählten Merkmalen bereitstellt.
Derzeit erlaubt die Prozedur folgende variablen Parameter:

```ReportType = ‚Gesamt‘```
Zeigt Buchungen und Beträge pro Tag im gesamten Zeitraum an.

```ReportType = ‚Tag’```
Zeigt Buchungen und Beträge pro Tag im optional gesuchten Zeitraum an

```ReportType = ‚Woche’```
Zeigt Buchungen und Betröge pro Woche im optional gesuchten Zeitraum an

```ReportType = ‚Kunde’```
Zeigt Buchungen und Beträge von Privat- und Firmenkunden im optional
gesuchten Zeitraum an

ReportType = ‚Kreditinstitut’
Zeigt Kreditinstitutbericht zu Buchungen und Beträge von Genossenschafts-,
öffentlich rechtlich- und Privatkreditinstitute im gesuchten Zeitraum an
sowie folgende optionalen Parameter:

StartDate

EndDate

Die Start- und Enddatum sind optional. Wenn kein Datum gegeben wird, dann wird der
gesamte Zeitraum berechnet, ansonsten muss das Datum im YYYY-MM-DD Format
geschrieben werden. In Abbildung 3 sind drei mögliche Schreibweisen zum Aufruf der
„DW_Report“ zu entnehmen:

![Abbildung 3: Beispielschreibweisen zum Aufruf der DW_Report](https://github.com/user-attachments/assets/b78efa0d-4800-4aeb-9098-116594ddd126)

Die Output sehen wie folgt aus:

![Abbildung 4: Output für den ersten Aufrufbeispiel](https://github.com/user-attachments/assets/84dc25e5-f195-4a1c-88d8-540f09729eec)
![Abbildung 5: Output für den zweiten Aufrufbeispiel](https://github.com/user-attachments/assets/ae94d0fb-9258-499c-8e9b-a5f9631f3a19)
![Abbildung 6: Output für den dritten Aufrufbeispiel](https://github.com/user-attachments/assets/d32c2615-4ab3-4ea1-bf83-0c6ccc08491b)

## 3. Benutzerhandbuch Java-Programm
Das Java Programm „Business_Intelligence.jar“ ist eine Anwendung, die das Einlesen von
Kontendaten in einer .txt im .csv Format behandelt, ungültige und Duplikate verwirft und
den behandelnden Datensatz in eine voreingestellte SQL Datenbank lädt.
Datensätze gelten als gültig, wenn jede Zeile über sieben Spalten verfügt, Kontoart nicht
leer, ```String = „null“ oder null ```ist, und Kontostand, Sollzins und Habenzins als Double
„geparsed“ werden können.
Datensätze gelten als Duplikat, wenn IBAN mehr als einmal im einzulesenden Datensatz
vorkommt.
Ungültige und Duplikate Datensätze werden verworfen.
Das Rootverzeichnis beschreibt den Ordner indem die „Business_Intelligence.jar“ liegt.
Die Voraussetzung zur Verwendung der Anwendung sind wie folgt (siehe Abbildung 7):
1. start.bat, Business_Intelligence.jar, „data“ Ordner und „lib“ Ordner im Rootverzeichnis.
2. Im „data“ Ordner existiert eine „K2.txt“ mit den Zusatzkonten im csv Format
3. Im „lib“ Ordner existiert ein Treiber „sqljdbc4.jar“
Es ist zu beachten, dass die .txt nicht mehr als 100 Zeilen enthalten darf. Entweder teilt
man die .txt auf oder erweitert die Standardhöchstgröße im Sourcecode (siehe Kapitel
2.3.2.1). Dies war ein Versuch die Effizienz zu erhöhen.
   
![Abbildung 7: Voraussetzung des Rootverzeichnisses zur Verwendung des Java Programms](https://github.com/user-attachments/assets/6ad65f02-12af-48d0-bb5b-1df460e7c141)

Zum Starten öffnet der Nutzende die .bat Datei und gibt deren Anmeldedaten ein. Die
Anwendung öffnet dann das Terminal und gibt folgenden Output aus bevor es sich sofort
wieder schließt (siehe Abbildung 8):

![Abbildung 8: Output der Java Anwendung](https://github.com/user-attachments/assets/024bd8e2-c073-4471-aa42-c9b2647077f3)

Solle es zu einer Fehlermeldung kommen z.B. falsche Anmeldedaten oder bereits befüllt,
so steht diese zwischen „Mit Datenbank verbunden“ und „Verbindung geschlossen“, wie in
Abbildung 9 zu sehen. Für gewöhnlich schließt sich die Konsole zu schnell, bevor man
den Output verarbeiten kann, also wird zur Fehlerbehandlung empfohlen das Programm in
der Konsole zu starten. Hierfür öffnet man im Rootverzeichnis die Konsole bzw. navigiert
in der Konsole bis zum Rootverzeichnis und gibt folgende Zeile ein: ```java -jar
"Business_Intelligence.jar".```

![Abbildung 9: Output der Java Anwendung mit Fehlermeldung](https://github.com/user-attachments/assets/11288521-1a1e-46f5-964a-2d5e386c2f9b)

Anmeldedaten können im Sourcecode unter der start.java Klasse geändert werden.
Hierfür sollen die „login“ und „password“ Strings entsprechend angepasst werden.

## Power BI Auswertungsszenarien
Im Folgenden werden Power BI Visualisierungen basierend auf den entworfenden
Auswertungsszenarien vorgestellt.
Die ersten drei Szenarien, Abbildung 10 bis 12, zeigen die Anzahl der Buchungen und den
Geldfluss pro Kundentyp, Buchungsart und Kreditinstitut. Dies könnte relevant sein, um
Zielgruppen zu bestimmen, Werbemaßnahmen zu planen und Transaktionsverhalten der
Kunden festzustellen.

![Abbildung 10: Auswertungsszenario 1; Buchungen und Geldfluss pro Kundentyp](https://github.com/user-attachments/assets/8210c084-aff2-4288-b7a6-328c33700d1d)
![Abbildung 11: Auswertungsszenario 2; Buchungen und Geldfluss nach Buchungsart](https://github.com/user-attachments/assets/98762cdc-e611-4b6b-96cf-e445d8f597cb)
![Abbildung 12: Auswertungsszenario 3; Buchungen und Geldfluss nach Kreditinstitut](https://github.com/user-attachments/assets/8ac87ea3-86ac-4a6e-a7d0-053f00088781)

Das vierte Szenario, Abbildung 13, zeigt Anzahl der Buchungen und Menge des
Geldflusses im gesamten Zeitraum an. Höhepunkte an bestimmten Daten (plural Datum)
könnten Spitzenzeiträume verdeutlichen, um Engpässe und Ausfallzeiten vorherzusehen
und entsprechend vorzubereiten bzw. zu minimieren.

![Abbildung 13: Auswertungsszenario 4; Anzahl Buchungen und Menge Geldfluss im gesamten Zeitraum](https://github.com/user-attachments/assets/3069fdc8-09c8-4ae1-88cd-b12834f56789)

Das fünfte Szenario, Abbildung 14, zeigt die Anzahl der Buchungen nach Wochentag.
Ähnlich wie in Szenario 4 könnte dies Spitzenwochentage verdeutlichen und dabei helfen,
sich entsprechend vorzubereiten.

![Abbildung 14: Anzahl der Buchungen nach Wochentag](https://github.com/user-attachments/assets/f5e7c87b-67d5-4f50-9c93-86a84e860082)




