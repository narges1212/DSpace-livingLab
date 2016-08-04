package org.gesis.ssoar.mbean.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.gesis.ssoar.mbean.Log4jConfiguratorMXBean;

public class DefaultLog4jConfiguratorMXBean implements Log4jConfiguratorMXBean {
    
    private final static Logger log = Logger.getLogger(DefaultLog4jConfiguratorMXBean.class);
    
    public DefaultLog4jConfiguratorMXBean() {
        log.info("Initializing DefaultLog4jConfiguratorMXBean");
    }
    
    public List<String> getLoggers() {
        
        @SuppressWarnings("unchecked")
        Enumeration<Logger> loggersEnumeration = LogManager.getCurrentLoggers();
        
        List<Logger> loggersList = Collections.list(loggersEnumeration);
        
        /*
        List<String> loggersNamesAndLevels = loggersList.stream().filter(l -> l.getLevel() != null)
                .map(l -> l.getName() + " = " + l.getLevel()).collect(Collectors.toList());
        */
        
        List<String> loggersNamesAndLevels = new ArrayList<>();
        for (Logger logger : loggersList) {
            if ( logger.getLevel() != null ) {
                String shownLoggerName = logger.getName() + " = " + logger.getLevel();
                loggersNamesAndLevels.add(shownLoggerName);
            }
        }
        
        return loggersNamesAndLevels;
    }
    
    public String getLogLevel(String logger) {
        String level = "unavailable";
        
        if (StringUtils.isNotBlank(logger)) {
            Logger log = Logger.getLogger(logger);
            
            if (log != null) {
                level = log.getLevel().toString();
            }
        }
        return level;
    }
    
    public void setLogLevel(String logger, String level) {
        if (StringUtils.isNotBlank(logger) && StringUtils.isNotBlank(level)) {
            Logger log = Logger.getLogger(logger);
            
            if (log != null) {
                log.setLevel(Level.toLevel(level.toUpperCase()));
            }
        }
    }
    
}