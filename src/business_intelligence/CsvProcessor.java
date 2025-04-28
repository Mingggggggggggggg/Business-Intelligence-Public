package business_intelligence;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

// IBAN, BIC, Kontoart, Kontoinhaber, Kontostand, Sollzins, Habenszins
public class CsvProcessor {

    public String[][] toProcessCsv(String filePath) {

        String[][] data = new String[100][7]; // Setze Dimension auf 100 Zeilen und 7 Spalten, kann andernfalls in den Methodenkopf
        int index = 0;

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) { // durchlaufe diese Schleife solange aus der Zeile Werte existieren
                if (line.startsWith("#") || line.trim().isEmpty()) {
                    continue;
                }

                String[] values = line.split(";"); // Setze Semikolon als Splitter
                if (isValid(values) && !isDuplicate(data, index, values)) {
                    if (index < data.length) {
                        data[index++] = values; // Daten hinzufügen
                    } else {
                        System.out.println("Maximale Anzahl von Zeilen erreicht.");
                        break;
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Daten können nicht eingelesen werden " + e.getMessage());
        }

        // Passe Array auf die tatsächliche Größe an
        String[][] result = new String[index][];
        System.arraycopy(data, 0, result, 0, index);
        return result;
    }

    // Überprüfe, ob die korrekte Anzahl an Spalten vorhanden sind, ob Kontoart null, String = "null" oder leer ist,
    // und ob die Datentypen der Spalten Kontostand, Sollzins und Habenzins korrekt sind
    private boolean isValid(String[] values) {

        // Überprüfe, ob korrekte Anzahl an Spalten vorhanden sind
        if (values.length < 7) { 
            System.out.println("Zu wenige Spalten bei IBAN: " + values[0] + "\n");
            return false;
        }

        // Überprüfe ob Kontoart null, String = "null" oder leer ist
        if (values[2] == null || values[2].trim().isEmpty() || values[2].equalsIgnoreCase("null")) { 
            System.out.println("Fehlerhafte Kontoart bei IBAN: " + values[0] + "\n");
            return false;
        }
        
        // Überprüfe Korrektheit der Datentypen Kontostand, Sollzins und Habenszins
        try {
            Double.valueOf(values[4]);
            Double.valueOf(values[5]);
            Double.valueOf(values[6]);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // Metehode zur Überprüfung von Duplikate IBANS, hierbei werden alle neuen Daten mit den vorherigen verglichen
    // Diese Methode ist nicht sonderlich ressourenschonend.
    private boolean isDuplicate(String[][] data, int index, String[] values) {
        for (int i = 0; i < index; i++) {
            if (data[i][0].equals(values[0])) {
                System.out.println("Duplikat bei IBAN: " + values[0] + "\n");
                return true;
            }
        }
        return false;
    }
}