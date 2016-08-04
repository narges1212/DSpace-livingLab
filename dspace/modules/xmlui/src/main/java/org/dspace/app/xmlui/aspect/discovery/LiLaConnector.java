package org.dspace.app.xmlui.aspect.discovery;

import org.dspace.content.DSpaceObject;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.discovery.DiscoverQuery;
import org.dspace.discovery.DiscoverResult;
import org.dspace.discovery.SearchServiceException;
import org.dspace.discovery.SearchUtils;
import org.dspace.utils.DSpace;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.sql.SQLException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import com.google.gson.Gson;
import java.util.*;
import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.Logger;


/**
 *
 * @author Narges Tavakolpoursaleh
 */

public class LiLaConnector {

	 protected DiscoverResult queryResultsall;
     public List<String> llSiteRun;
	 private JSONObject data;
	 
	 private static final Logger lilaLog = Logger.getLogger("lilaLogger");
	private Map<String,String> properties; 
  
	 public Map<String, List<String>> startLivingLabs( DiscoverQuery queryArgs, DSpaceObject scope, Context context ) throws FileNotFoundException, IOException, ParseException, SQLException 
	 {
		 /* TODO  
		  * 1- check if query is head query  done
		  * 2- if the sort type (by) is relevance  done
		  * 3- if the query call is for the fist 100 docments done
		  * 4- call the ranking
		  * 5- check if the ranking has same documents as site ranking: has to be done by api
		  * 6- save interleaved result in some better location: done in database
		  * 7- check the interleave algorithm again: in progress
		  * 8- if the experimental is not found return the site result: working on it
		  */
		 
		 DSpace dspace = new DSpace();
	     String sid = dspace.getSessionService().getCurrentSession().getId(); 
         String llquery = "null";
         String hndl = "null",qstr;
         String queryid = "";
         LiLaDB lldb = new LiLaDB();

     	if(scope!=null) 
       	  hndl = scope.getHandle();
	  		qstr   =  queryArgs.getQuery();

        
	        
        if (qstr!=null) {
        	llquery = qstr;
        	String decoded=Base64.encodeBase64String(llquery.getBytes()); 
        	queryid = "SSS"+ decoded;
        }
    	else if (hndl!=null){
    		llquery = hndl;
    		String decoded=Base64.encodeBase64String(llquery.getBytes()); 
    		queryid = "SSB"+ decoded;
    	}

        this.queryResultsall =  this.getLLQueryResults(queryArgs, scope, context, 100);

        
        data = lldb.getInterleavedRankingFromDB(llquery,sid);

        if(data!=null){

        	return data;
        	 
        } else {
        	
        	List<String> teamRun = new ArrayList<String>();
        	List<String> siteRun = new ArrayList<String>(); 
        	
            for (DSpaceObject dsr : this.queryResultsall.getDspaceObjects()) {   
            	siteRun.add(dsr.getHandle()); 
            } 
            
        	String rankingstr = lldb.getRankingFromAPI(queryid);
        	JSONArray expRank = null;
        	String team = "unkonwn";
        	if(rankingstr!=null) {
        		 JSONParser parser = new JSONParser();
				 Object obj = parser.parse(rankingstr);
	             JSONObject ranking = (JSONObject) obj;
        		 team = (String) ranking.get("sid");
        		 expRank = (JSONArray) ranking.get("doclist");
        	} else {
        		return null;
        	}

        	if(expRank!=null){

		        for (Object result1 : expRank) {
		            	JSONObject doc = (JSONObject) result1;
		            	String code = ((String) doc.get("site_docid")).substring(8);
		            	if (siteRun.contains("document/"+code)){
		            		teamRun.add("document/"+code);
		            	}
		        } 
        	} else {
        		lilaLog.info("experimental ranking is null");
    			return null;
        	}
        	
        	

            lilaLog.info("experimental ranking: "+ teamRun);
            lilaLog.info("site ranking: "+ siteRun);
  	
        	

        	Map<String,List<String>> interleaved = LiLaInterleaver.getInterleavedResult(siteRun, teamRun, team);
        	
        	if(interleaved==null){
        		return null;
        	}

           String json = new Gson().toJson(interleaved);
           lldb.setInterleavedRanking(llquery, json ,sid);
     
           /*
           try (FileWriter file = new FileWriter(this.path+"LivingLabs/"+filename+".json")) {
   			file.write(json);
   			
   		   }
   		   */
           
           return interleaved;

        }
	        
	 }
	 
	 public DiscoverResult getLLQueryResults(DiscoverQuery queryArgs, DSpaceObject scope, Context context, int range){
		 DiscoverResult resultsall = null;
		 queryArgs.setMaxResults(range);
	     queryArgs.setStart(0);
	        try {
				resultsall = SearchUtils.getSearchService().search(context, scope, queryArgs);
			} catch (SearchServiceException e) {
				lilaLog.info("lilaConnector: getLLQueryResults error!");
			}

			return resultsall;    
	 }
	 

	 /*
	  * check if the query is a livinglabs query:
	  * the sort should be by relevance
	  * the query shod be head query
	  */
	public boolean isLiLaQuery(DiscoverQuery queryArgs, DSpaceObject scope)	{
		 String llquery = "";
         String hndl = "",qstr,sortt;
         LiLaDB lldb = new LiLaDB();
         
     	if(scope!=null) 
       	  hndl = scope.getHandle();
	  		qstr   =  queryArgs.getQuery();
	  		sortt  =  queryArgs.getSortField();
	  	
	  	if ((qstr!=null) && ((hndl==null) ||(hndl.equals("")))){
	  		llquery = qstr;
	  	} else if ((hndl!=null) && (qstr==null)) {
	  		llquery = hndl;	
	  	}
	  	else {
	  		
	  		return false;
	  	}
	  	if((queryArgs.getStart()+queryArgs.getMaxResults())>100){  //QUERY OF FIRST 100 DOCUMENTS
	  		return false;
	  	}
	  	
	  	if (llquery.equals("")) return false;
	  	
	  	Map<String, String> lilaProp =  null;
	  	try {
	  		 lilaProp = this.getLiLaConfigProp();
	  	} catch(Exception e){
	  		 lilaLog.info("lilaConnector: config.properties error!");
	  		 return false;
	  	}
       
        String lilainterleave = "site";
        if(lilaProp!=null){
        	try{
        		 lilainterleave = lilaProp.get("lilaQuerySource");
        	} catch(Exception e){
	        	lilaLog.info("lilaConnector: config.properties error!");
	        }
        }
	  	
	    if (sortt==null || sortt.equals("score")) {       // is sorted by relevance
	    	if(lilainterleave.equals("site")){
	    		try{
	    			return lldb.isHeadQueries(llquery,"api"); // find llquery in api, json file
	    		} catch(Exception e){
	    			lilaLog.info("isHeadQueries Error api!");
	    			lilaLog.error(e.getMessage());
	    			return false;
	    		}
	    		
	    	} else {
	    		try{
	    			return lldb.isHeadQueries(llquery,"file");  // find llquery in database  db
	    		} catch(Exception e){
	    			lilaLog.info("isHeadQueries Error file!");
	    			lilaLog.error(e.getMessage());
	    			return false;
	    		}
	    	}
	    	
	    } else {
	    	return false;
	    }

		
	}      
	/*
	public HashMap<String, String>  getLiLaProp() throws IOException {
   	 
		  HashMap<String, String> properties = new HashMap<String, String>();
		  JSONParser parser = new JSONParser();
		  
		  String propFileName="/srv/living-labs/webapps/xmlui/WEB-INF/classes/aspects/LivingLabs/livinglabsConfig.json";
		  //String propFileName="/home/narges/Documents/ssoar/dspace/modules/xmlui/src/main/resources/aspects/LivingLabs/livinglabsConfig.json";
	        try {
	 
	            Object obj = parser.parse(new FileReader(propFileName));
	            JSONObject jsonObject = (JSONObject) obj;
	            
	            properties.put("livinglabs",(String) jsonObject.get("livinglabs"));
				properties.put("interleave", (String) jsonObject.get("interleave"));
				properties.put("lilaQuerySource",(String) jsonObject.get("lilaQuerySource"));
	 
	        }  catch (Exception e) {
	        	lilaLog.info(e.getMessage());
				return null;
	        }
	        
		return properties;
	
	}
	*/
	
	public HashMap<String, String> getLiLaConfigProp() throws IOException {
		
		  //String prop = ConfigurationManager.getProperty("livinglabs", "lila.livinglabs.active");	
		  HashMap<String, String> properties = new HashMap<String, String>();
		  Properties props = new Properties();

		  try {
			    /*InputStream in = LiLaConnector.class.getResourceAsStream("livinglabs.properties"); */
			    // for dda server
			    //FileInputStream in = new FileInputStream("/srv/living-labs/config/modules/livinglabs.properties");
			    FileInputStream in = new FileInputStream("/dspace/ssoar-prod/ssoar-prod/config/modules/livinglabs.properties");
			    props.load(in);
	            properties.put("livinglabsisset",(String) props.get("lila.livinglabs.active"));
				properties.put("interleaveisset", (String) props.get("lila.interleave"));
				properties.put("lilaQuerySource",(String) props.get("lila.headQuery.source"));
				properties.put("lilaQrelMax",(String) props.get("lila.qrel.max"));
				properties.put("lilaApi",(String) props.get("lila.api"));
				properties.put("lilaApiKey",(String) props.get("lila.api.key"));
				/*
			    properties.put("livinglabsisset", ConfigurationManager.getProperty("livinglabs", "lila.livinglabs.active"));
				properties.put("interleaveisset", ConfigurationManager.getProperty("livinglabs", "lila.interleave"));
				properties.put("lilaQuerySource",ConfigurationManager.getProperty("livinglabs", "lila.headQuery.source"));
				properties.put("lilaQrelMax",ConfigurationManager.getProperty("livinglabs", "lila.qrel.max"));
				properties.put("lilaApi",ConfigurationManager.getProperty("livinglabs", "lila.api"));
				properties.put("lilaApiKey",ConfigurationManager.getProperty("livinglabs", "lila.api.key"));
				*/
				//lilaLog.info("living-labs config: Reading livinglabs.properties" + properties.toString());
	        }  catch (Exception e) {
	        	lilaLog.info("error: Reading livinglabs.cfg");
				return null;
	        }
		  //System.out.println(properties.toString());
		  return properties;
	
	}

		
    /*
	 public static void main(String[] args) throws SQLException, IOException, ParseException
	  {
		 //new HashMap<String, String>();
		LiLaConnector ll = new LiLaConnector();
		HashMap<String, String> lilaProp = ll.getLiLaConfigProp();
		System.out.println(lilaProp.get("lilaApiKey"));
		  //System.out.println(LiLaConnector.class.getProtectionDomain().getCodeSource().getLocation().getPath());
		 //System.out.println(Base64.encodeBase64String(("collection/50200").getBytes()));
	  }
	 */
	
	
	
}