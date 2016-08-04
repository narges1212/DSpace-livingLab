package org.gesis.ssoar.services;

import java.sql.*;
import java.text.Normalizer;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;

import org.gesis.ssoar.database.DBConnection;
/**
 * @author JST
 * For having the journal acronym in the frontend this specific information has to be fetched out of SSOAR database.
 * Class is called via xsl (item-view.xsl).
 */
public class SSOARJournalAcronymToFilenameService {
    
    private static Logger log = Logger.getLogger(SSOARJournalAcronymToFilenameService.class);
    
    public String getJournalTitleAcronym(String journal) throws SQLException {
        log.debug("querying for acronym to journal " + journal);
        String journalTitleAcronym = null;
        String sqlEscapedJournal = journal.replace("'","''");
        String query = "select acronym from journal where value ='" + sqlEscapedJournal +"'";
        
        DBConnection dbConnection = new DBConnection(
            ConfigurationManager.getProperty("ssoar.db.host"),
            ConfigurationManager.getProperty("ssoar.db.database"),
            ConfigurationManager.getProperty("ssoar.db.username"),
            ConfigurationManager.getProperty("ssoar.db.password") ); 
        
        PreparedStatement statement = dbConnection.getConnection().prepareStatement(query);
        ResultSet journalAcronym = dbConnection.executeQuery(statement);
        if ( journalAcronym.next() ) {
            journalTitleAcronym = normalizeString(journalAcronym.getString("acronym").toLowerCase());			 
        }
        log.debug(journal + " -> " + journalTitleAcronym);
        
        dbConnection.closeConnection();
        return journalTitleAcronym;
    }
    
    public static String normalizeString(String input) {
        String output = input;
        output = Normalizer.normalize(output, Normalizer.Form.NFD).replaceAll(" ", "_");
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        output = pattern.matcher(output).replaceAll("");
        Pattern pattern2 = Pattern.compile("[^\\w\\-\\_]");
        output = pattern2.matcher(output).replaceAll("");
        return output;
    }
    
}