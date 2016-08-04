package org.gesis.ssoar.mbean;

import java.util.List;

public interface Log4jConfiguratorMXBean {
    /**
     * list of all the logger names and their levels
     */
    List<String> getLoggers();
    
    /**
     * Get the log level for a given logger
     */
    String getLogLevel(String logger);
    
    /**
     * Set the log level for a given logger
     */
    void setLogLevel(String logger, String level);
}
