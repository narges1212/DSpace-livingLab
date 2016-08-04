package org.gesis.ssoar.cli.convoc;

import static java.lang.System.err;
import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.dspace.storage.rdbms.DatabaseManager;

public class AuthorXmlGenerator implements XmlGenerator {
    
    @Override
    public String getCategory() {
        return "author";
    }
    
    @Override
    public Connection getConnection() {
        DataSource dataSource = DatabaseManager.getDataSource();
        try {
            Connection connection = dataSource.getConnection();
            return connection;
        } catch (SQLException e) {
            err.println("could not get connection from data source");
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
    
    @Override
    public String getStatement() {
        return "SELECT DISTINCT text_value AS value FROM metadatavalue WHERE metadata_field_id = 3 ORDER BY value";
    }
    
}
