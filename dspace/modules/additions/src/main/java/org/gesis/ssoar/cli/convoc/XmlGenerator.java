package org.gesis.ssoar.cli.convoc;

import java.sql.Connection;

public interface XmlGenerator {
    
    public String getCategory();
    public Connection getConnection();
    public String getStatement();
    
}
