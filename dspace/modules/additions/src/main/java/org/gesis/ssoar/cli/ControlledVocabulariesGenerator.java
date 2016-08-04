package org.gesis.ssoar.cli;

import static java.lang.System.out;
import static java.lang.System.err;
import static org.dspace.core.ConfigurationManager.getProperty;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.gesis.ssoar.cli.convoc.AuthorXmlGenerator;
import org.gesis.ssoar.cli.convoc.JournalXmlGenerator;
import org.gesis.ssoar.cli.convoc.XmlGenerator;


public class ControlledVocabulariesGenerator {
    
    private final static Map<String, Class<? extends XmlGenerator>> xmlGeneratorMap = new HashMap<>();
    
    static {
        xmlGeneratorMap.put("author", AuthorXmlGenerator.class);
        xmlGeneratorMap.put("journal", JournalXmlGenerator.class);
    }
    
    public static void main(String[] args) throws SQLException, IOException {
        out.println("starting ControlledVocabulariesGenerator");
        
        if ( (null == args) || (0 == args.length) ) {
            err.println("No arguments given");
            System.exit(-1);
        }
        
        for (String argument : args) {
            
            Class<? extends XmlGenerator> xmlGeneratorClass = xmlGeneratorMap.get(argument);
            try {
                XmlGenerator xmlGenerator = xmlGeneratorClass.newInstance();
                template(xmlGenerator);
            } catch (InstantiationException | IllegalAccessException e) {
                err.println("Problem creating new generator instance for argument '" + argument + "'.");
            }
            
        }
        out.println("finishing ControlledVocabulariesGenerator");
    }
    
    private static void template(XmlGenerator xmlGenerator) throws SQLException, IOException {
        String category = xmlGenerator.getCategory();
        out.println("xml template method for " + category); 
        
        Connection connection = xmlGenerator.getConnection();
        String statement = xmlGenerator.getStatement();
        PreparedStatement preparedStatement = connection.prepareStatement(statement);
        ResultSet resultSet = preparedStatement.executeQuery();
        
        Document document = DocumentHelper.createDocument();
        Element rootNode = document.addElement( "node" );
        rootNode.addAttribute( "id", category ).addAttribute("label", "");
        
        Element isComposedBy = rootNode.addElement("isComposedBy");
        
        while ( resultSet.next() ) {
            String currentResult = resultSet.getString(1);
            Element currentElementNode = isComposedBy.addElement("node");
            currentElementNode.addAttribute("id", currentResult).addAttribute("label", currentResult);
        }
        
        String dspaceInstallationDirectoryPath = getProperty("dspace.dir");
        String xmlFileLocation = dspaceInstallationDirectoryPath + "/config/controlled-vocabularies/" + category + ".xml";
        Writer xmlOutputFile = new OutputStreamWriter( new FileOutputStream(xmlFileLocation), StandardCharsets.UTF_8 );
        
        document.write(xmlOutputFile);
        xmlOutputFile.close();
        
        out.println(xmlFileLocation + " updated");
    }
    
}
