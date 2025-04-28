package business_intelligence;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Scanner;

public class start {
    public static void main(String[] args) {
        // Login Daten
        //String url = "jdbc:sqlserver://localhost:1433;databaseName=ENTFERNT;integratedSecurity=true;trustServerCertificate=true;"; //Lokaler Server
        String url = "jdbc:sqlserver://ENTFERNT.ENTFERNT.de:1433; databaseName=ENTFERNT";
        String login = "ENTFERNT";
        String password = "ENTFERNT";

        String filepath = "data\\K2.txt"; 
        String insert = "INSERT INTO ED_KONTO (IBAN, BIC, Kontoart, Kontoinhaber, Kontostand, Sollzins, Habenszins) VALUES (?, ?, ?, ?, ?, ?, ?)";  
        
        // Loginfunktion
        try (Scanner input = new Scanner(System.in)) {
            System.out.println("Bitte Anmeldenamen eingeben: ");
            login = input.nextLine();
            
            System.out.println("Bitte Password zu Anmeldenamen "+ login + " eingeben:");
            password = input.nextLine();
        }

        CsvProcessor csvProcessor = new CsvProcessor();
        String[][] csvData = csvProcessor.toProcessCsv(filepath);

        Connection connection = null;
        try {    
            connection = DriverManager.getConnection(url, login, password);
            if (connection != null) {
                System.out.println("Mit Datenbank verbunden.");
                PreparedStatement st = connection.prepareStatement(insert);

                for (String[] row : csvData) { // Schreibe solange es Werte in csvData gibt
                    if (row != null) {
                        st.setString(1, row[0]);
                        st.setString(2, row[1]);
                        st.setString(3, row[2]);
                        st.setString(4, row[3]);
                        st.setString(5, row[4]);
                        st.setString(6, row[5]);
                        st.setString(7, row[6]);

                        st.executeUpdate();
                    }
                }

            } else {
                System.out.println("Verbindung fehlgeschlagen.");
            }
        } catch (SQLException e) {
            System.err.println("Fehler bei Verbindung: " + e.getMessage());
        } finally {
            if (connection != null) {
               try {
                  connection.close();
                  System.out.println("Verbindung geschlossen.");
               } catch (SQLException var17) {
                  var17.printStackTrace();
               }
            }
         }
    }
}
