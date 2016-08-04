package org.gesis.ssoar.cli.convoc;

import static java.lang.System.err;
import static org.dspace.core.ConfigurationManager.getProperty;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class JournalXmlGenerator implements XmlGenerator {
    
    @Override
    public String getCategory() {
        return "journal";
    }
    
    @Override
    public Connection getConnection() {
        try {
            Class.forName( getProperty("db.driver") );
        } catch (ClassNotFoundException e) {
            err.println("could not prepare database driver " + getProperty("db.driver") );
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        
        String dbHost = getProperty("ssoar.db.host");
        String ssoarDbName = getProperty("ssoar.db.database");
        String ssoarDbConnectionUrl = dbHost + ssoarDbName;
        
        String ssoarDbUsername = getProperty("ssoar.db.username");
        String ssoarDbPassword = getProperty("ssoar.db.password");
        
        try {
            Connection connection = DriverManager.getConnection(
                    ssoarDbConnectionUrl,
                    ssoarDbUsername,
                    ssoarDbPassword);
            
            return connection;
        } catch (SQLException e) {
            err.println("could not create database connection"); 
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        
    }

    @Override
    public String getStatement() {
        return "SELECT DISTINCT value FROM journal WHERE id IS NOT NULL ORDER BY value";
    }
    
}
