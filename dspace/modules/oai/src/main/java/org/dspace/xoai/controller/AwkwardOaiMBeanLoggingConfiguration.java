package org.dspace.xoai.controller;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.servlet.ServletContext;

import org.apache.log4j.Logger;
import org.gesis.ssoar.mbean.Log4jConfiguratorMXBean;
import org.gesis.ssoar.mbean.impl.DefaultLog4jConfiguratorMXBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.jmx.support.MBeanServerFactoryBean;

/**
 * Spring @Configuration that sets up a properly named entry for changing log levels
 * Why awkward? Because it gets picked up by org.dspace.xoai.app.DSpaceWebappConfiguration via component scanning,
 * which in turn is picked up via oai's web.xml configuration. Workaround for similar configuration in files mbean-logging.xml
 * @author huebbegt
 *
 */
@Configuration
public class AwkwardOaiMBeanLoggingConfiguration {
    
    private final static Logger log = Logger.getLogger(AwkwardOaiMBeanLoggingConfiguration.class);
    
    @Bean
    public MBeanServerFactoryBean mBeanServerFactoryBean() {
        MBeanServerFactoryBean mBeanServerFactoryBean = new MBeanServerFactoryBean();
        mBeanServerFactoryBean.setLocateExistingServerIfPossible(true);
        return mBeanServerFactoryBean;
    }
    
    @Bean
    public Log4jConfiguratorMXBean lLog4jConfiguratorMXBean() {
        return new DefaultLog4jConfiguratorMXBean();
    }
    
    @Bean
    public MBeanExporter mBeanExporter(ServletContext servletContext, Log4jConfiguratorMXBean lLog4jConfiguratorMXBean) {
        String contextPath = servletContext.getContextPath();
        String logMBeanName = "logging:name=config-" + contextPath;
        
        MBeanExporter mBeanExporter = new MBeanExporter();
        Map<String, Object> mBeanNamesToMBeansMap = new HashMap<>();
        mBeanNamesToMBeansMap.put(logMBeanName, lLog4jConfiguratorMXBean);
        
        mBeanExporter.setBeans(mBeanNamesToMBeansMap);
        return mBeanExporter;
    }
    
    @PostConstruct
    public void postConstruct() {
        log.info("finalized AwkwardOaiMBeanLoggingConfiguration");
    }
  
}
