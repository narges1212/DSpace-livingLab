package org.gesis.ssoar.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.log4j.Logger;

public class DBConnection {
    
    private static Logger log = Logger.getLogger(DBConnection.class);
    
    private String host;
    private String database;
    private String user;
    private String password;
    private Connection connection = null;
    private Statement stmt = null;
    
    public DBConnection(String host, String database, String user, String password) {
        this.host = host;
        this.database = database;
        this.user = user;
        this.password = password;
        checkForDriver();
    }
    
    private boolean openConnection() {
        if(connection != null){
            closeConnection();
        }
        try {
            connection = DriverManager.getConnection( host + database, user, password); 
            return true;
        } catch (SQLException e) { 
            log.error("openConnection failed", e);
            return false;
        }
    }
    
    public void closeConnection() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
            log.error("closeConnection failed", e);
        }
        connection = null;
    }
    
    /**
    * Get connection. Returns previously opened connection or opens new
    * connection.
    */
    public Connection getConnection() throws SQLException {
        if (connection == null) {
            openConnection();
        }
        return connection;
    }
    
    public Statement getStatement() throws SQLException {
        closeStatement();
        getConnection();
        stmt = connection.createStatement();
        return stmt;
    }
    
    public void closeStatement() {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                log.error("closeStatement failed", e);
            }
        }
    }
    
    public void executeUpdate(String sqlStmt) throws SQLException {
        stmt = getStatement();
        try {
            stmt.executeUpdate(sqlStmt);
        } catch (SQLException e) {
            try {
                log.error("executeUpdate failed once", e);
                stmt.close();
            } catch (SQLException e2) {
                log.error("executeUpdate failed twice", e2);
            }
            throw e;
        }
    }
    
    public void executeCreate(String sqlStmt) throws SQLException {
        stmt = getStatement();
        try {
            stmt.execute(sqlStmt);
        } catch (SQLException e) {
            try {
                log.error("executeCreate failed once", e);
                stmt.close();
            } catch (SQLException e2) {
                log.error("executeCreate failed twice", e2);
            }
            throw e;
        }
    }
    
    /**
    * Returned result is closed automatically when the next statement is
    * executed or when closeStatement() is called
    */
    public ResultSet executeQuery(String sqlStmt) throws SQLException {
        stmt = getStatement();
        ResultSet res = null;
        try {
            res = stmt.executeQuery(sqlStmt);
        } catch (SQLException e) {
            log.error("executeQuery failed once", e);
            try {
                stmt.close();
            } catch (SQLException e2) {
                log.error("executeCreate failed twice", e2);
            }
                throw e;
        }
        return res;
    }

    public void executeUpdate(PreparedStatement stmt) throws SQLException {
        getConnection();
        closeStatement();
        stmt.executeUpdate();
    }

    public ResultSet executeQuery(PreparedStatement stmt) throws SQLException {
        getConnection();
        closeStatement();
        ResultSet res = null;
        res = stmt.executeQuery();
        return res;
    }
    
    final boolean tableExists(final String tableName) throws SQLException {
        getConnection();
        try {
            executeQuery("SELECT COUNT(*) FROM " + tableName + " WHERE 1 = 2;");
            return true;
        } catch (SQLException e) {
            log.error("tableExists failed", e);
            return false;
        }
    }
    
    public void setNewDatabase(String host, String database, String user, String password){
        this.host = host;
        this.database = database;
        this.user = user;
        this.password = password;
    }

    private void checkForDriver() {
        try {
            Class.forName("org.postgresql.Driver"); 
        } catch (ClassNotFoundException e) {
            log.error("Where is your PostgreSQL JDBC Driver? Include in your library path!", e);
        }
    }
}
