package org.gesis.ssoar.cli;

import java.util.Properties;
import org.dspace.core.ConfigurationManager;

public class DSpacePropertiesLister {
    
    public static void main(String[] args) {
        Properties dspaceProperties = ConfigurationManager.getProperties();
        for (String key : dspaceProperties.stringPropertyNames() ) {
            System.out.println( key + "=" + dspaceProperties.getProperty(key) );
        }
    }
    
}
