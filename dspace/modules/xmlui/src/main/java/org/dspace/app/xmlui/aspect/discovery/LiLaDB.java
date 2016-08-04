package org.dspace.app.xmlui.aspect.discovery;


import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;



import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import org.dspace.storage.rdbms.DatabaseManager;

import org.dspace.core.Context;
import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.Logger;


public class LiLaDB {
	
	private static final Logger lilaLog = Logger.getLogger("lilaLogger");   ///
	
	public void createTables() throws SQLException{
		Connection c = DatabaseManager.getConnection();
		//PreparedStatement pq = c.prepareStatement("CREATE TABLE IF NOT EXISTS query(site_qid SERIAL NOT NULL PRIMARY KEY,qstr varchar(256) NOT NULL UNIQUE, type varchar(10))");
		//PreparedStatement pe = c.prepareStatement("CREATE TABLE IF NOT EXISTS experimental_ranking (id SERIAL NOT NULL PRIMARY KEY,qid varchar(256), data json )");
		PreparedStatement pi = c.prepareStatement("CREATE TABLE IF NOT EXISTS interleaved_ranking (id SERIAL,sid_qstr varchar(256) NOT NULL PRIMARY KEY, data json )");
		pi.executeUpdate();
		pi.close();
	}
  	
   public boolean isHeadQueries_DB( String querystr) throws SQLException, IOException{

	    boolean queryFound;
		Connection c = DatabaseManager.getConnection();
		Statement stmt = c.createStatement();
		String sql = "SELECT * FROM query WHERE qstr=\'"+querystr+"\'";
		ResultSet rs = stmt.executeQuery(sql);
		if(rs.next()==true){
			queryFound =  true;
		}
		else {
			queryFound = false;
		}
		stmt.close();
		c.close();
		return queryFound;
	}

   
    public String getHeadQueriesFromApi(){

    	 Map<String, String> lilaApi =  null;
		 try {
			lilaApi = this.getApi();
		} catch (IOException e) {
			lilaLog.info("get Api error reading from config file");
			e.printStackTrace();
		}
		 String api = "http://api.trec-open-search.org/api";    // default values
		 String key = "3D6D13350D9BC23C-BJWKXG3SHSGF4V0S";      // default values
		 
		 if(lilaApi!=null)	{
			 api = lilaApi.get("api");
			 key = lilaApi.get("apiKey");
		 }
		 
      
	     String url= api+"/site/query/"+key;
		 String json = readJsonFromUrl(url);
		 
		  
		 return json;
	}
    
    public String getHeadQueriesFromFile() throws SQLException, IOException{

		  JSONParser parser = new JSONParser();
		  String propFileName="queries.json";
	        try {
	        	
	            Object obj = parser.parse(new FileReader(propFileName));
	            JSONObject jsonObject = (JSONObject) obj;
	            return jsonObject.toString();
	        }  catch (Exception e) {
	        	lilaLog.info(e.getMessage());
				return null;
	        }

	}
  
    public boolean isHeadQueries( String querystr, String src) {

    	//String qstr = querystr.replace("/", "");
    	String queries="";
    	if(src.equals("file")){
    		try {
				queries = this.getHeadQueriesFromFile();
			} catch (SQLException e) {
				lilaLog.error("SQLException reading HQ from file:"+e.getMessage());
			} catch (IOException e) {
				lilaLog.error("IOException reading HQ from file:"+e.getMessage());
			}
    	} else {
    		queries = this.getHeadQueriesFromApi();
    	}
    	try {
    		JSONObject jsonQueries = (JSONObject)new JSONParser().parse(queries);
        	JSONArray hqueries = (JSONArray) jsonQueries.get("queries");
        	for (int i = 0 ; i < hqueries.size(); i++) {
        		
                JSONObject query = (JSONObject) hqueries.get(i);
                String sqid = (String) query.get("site_qid");
                //String queryType = sqid.substring(0, 3);     "SSB"  and SSS  //SSOAR Brows search and simple search
                if(sqid.length()< 4) continue;
            	byte[] decoded=Base64.decodeBase64(sqid.substring(3, sqid.length())); 
            	String ssq = new String(decoded);
            	if (ssq.equals(querystr)) {
            		lilaLog.info("Head query:"+querystr);
            		return true;
            	}
        	}
    	} catch (Exception e) {
    		lilaLog.info("error comparing the json head queries:"+querystr);
    		lilaLog.error(e.getMessage());
    		return false;
    	}
    	return false;
	}
   
	/*
	// do i need this?
	public void setExperimentalRanking(String qid) throws SQLException, IOException, ParseException{
		
		Connection c = DatabaseManager.getConnection();
		Statement stmt = c.createStatement();
	    int id = 6;
	    JSONObject run = this.getRankingFromAPI(qid);
		String sql = "INSERT INTO experimental_ranking VALUES ("+id+",\'"+qid+"\',\'"+run+"\');";
		stmt.executeUpdate(sql);
		stmt.close();
		c.commit();
		c.close();
	}
	*/
	/*
	// should always be asked from api
	public Map<String, JSONArray>  getExperimentalRanking(String siteqid) throws SQLException, IOException, ParseException{
			
			Connection c = DatabaseManager.getConnection();
			Statement stmt = c.createStatement();
			Map<String, JSONArray> res = null;
			//this.setExperimentalRanking(siteqid);
			
			String sql = "SELECT data->>'doclist' as doclist, data->>'sid' as teamName FROM experimental_ranking WHERE qid='"+siteqid+"'";
			sql = sql +"";;
			ResultSet rs = stmt.executeQuery(sql);
		    Object data=null;
		    String teamName="";
  
			while ( rs.next() ) {
		           //int id = rs.getInt("id");
		           //String  qid = rs.getString("qid");
		           data = rs.getObject("doclist"); 
		           teamName = rs.getString("teamName");
		    }
		   stmt.close();
		   c.close();
		   if(data!=null){
			     JSONArray doclist = (JSONArray) new JSONParser().parse((String) data);
				 res.put(teamName,doclist);
	        	 return res;
	        } 

		   return null;
			
		}
		*/
	
	public void setInterleavedRanking(String qid, String interleavedResult, String sessionID) throws SQLException, IOException{
        
		String sid_qstr = sessionID+"_"+qid ;
		
		Connection c = DatabaseManager.getConnection();
		Statement stmt = c.createStatement();
	    String sql1 = "SELECT max(id) FROM interleaver_ranking WHERE qid='"+qid+"'";
	    int id =1;
		String sql = "INSERT INTO interleaved_ranking VALUES ("+id+",\'"+sid_qstr+"\',\'"+interleavedResult+"\');";
		//String r = sql.replaceAll("","");
		stmt.executeUpdate(sql);
		stmt.close();
		c.commit();
		c.close();
		//System.out.println("interleaved Result from db:"+this.getInterleavedRanking(qid,sessionID));
	}
	
	
	
	public JSONObject getInterleavedRankingFromDB(String qstr,String sessionID) throws SQLException, IOException, ParseException{
		
		Connection c = DatabaseManager.getConnection();
		Statement stmt = c.createStatement();
		String sid_qstr = sessionID+"_"+qstr ;
		Object teamA = null;
		Object teamB = null;
		Object team = null;
		Object result = null;
		
		String sql = "SELECT data->>'result' as result, data->>'teamA' as teamA, data->>'teamB' as teamB,  data->>'teams' as teams FROM interleaved_ranking WHERE sid_qstr=\'"+sid_qstr+"\'";
		ResultSet rs = stmt.executeQuery(sql);
		while ( rs.next() ) {
	           result = rs.getObject("result"); 
	           teamA = rs.getObject("teamA"); 
	           teamB = rs.getObject("teamB"); 
	           team = rs.getObject("teams");
	    }
	   stmt.close();
	   c.close();

	   if(result!=null){
		   String s = ((String) result).replace("[", "").replace("]", "");
		   s = s.replace("\"", "");
		   String[] split = s.split(",");
		   List<String> resultlist = Arrays.asList(split);
		   
		   String ta = ((String) teamA).replace("[", "").replace("]", "");
		   ta = ta.replace("\"", "");
		   String[] split2 = ta.split(",");
		   List<String> teamAlist = Arrays.asList(split2);
		   
		   String tb = ((String) teamB).replace("[", "").replace("]", "");
		   tb = tb.replace("\"", "");
		   String[] split3 = tb.split(",");
		   List<String> teamBlist = Arrays.asList(split3);
		   
		   String teamname = ((String) team).replace("[", "").replace("]", "");
		   teamname = teamname.replace("\"", "");
		   String[] split4 = teamname.split(",");
		   List<String> teamnamelist = Arrays.asList(split4);

		   JSONObject json = new JSONObject();   
		   json.put("result",resultlist);
		   json.put("teamA",teamAlist);
		   json.put("teamB",teamBlist);
		   json.put("teams",teamnamelist);
		   return json;
       } 
	   return null;
	}

	 public String getRankingFromAPI(String qid) throws SQLException, IOException{

		 /*for test while we have no ranking in api yet
		 if(qid.equals("SSSYnJvZXNrYW1w"))
			 return "{\"sid\":\"s1\",\"doclist\":[{\"site_docid\":\"document6675\"},{\"site_docid\":\"document31134\"},{\"site_docid\":\"document6679\"},{\"site_docid\":\"document13482\"},{\"site_docid\":\"document31170\"},{\"site_docid\":\"document13462\"},{\"site_docid\":\"document13480\"},{\"site_docid\":\"document6673\"},{\"site_docid\":\"document6716\"},{\"site_docid\":\"document6672\"},{\"site_docid\":\"document6685\"},{\"site_docid\":\"document6715\"},{\"site_docid\":\"document13479\"}]}";
		 */
		 
		 Map<String, String> lilaApi =  null;
		 lilaApi = this.getApi();
		 String api = "http://api.trec-open-search.org/api";    // default values
		 String key = "3D6D13350D9BC23C-BJWKXG3SHSGF4V0S";      // default values
		 if(lilaApi!=null)	{
			 api = lilaApi.get("api");
			 key = lilaApi.get("apiKey");
		 }

	      String url= api+"/site/ranking/"+key+"/"+qid;
	      
	      try {
		      	String json = readJsonFromUrl(url);
		      	return json;
	      	 }	catch(Exception e)	{
	      		lilaLog.info("api returns no ranking for " + qid);
	      		lilaLog.error(e.getMessage());
	      		return null;
	      	 }

		}
	 
	private static String readAll(Reader rd) throws IOException {
	    StringBuilder sb = new StringBuilder();
	    int cp;
	    while ((cp = rd.read()) != -1) {
	      sb.append((char) cp);
	    }
	    return sb.toString();
	  }

	  public static String readJsonFromUrl(String url)   {
		 InputStream is = null;

	    try {
	    	 URL apiURL = new URL(url) ;
		     URLConnection c = apiURL.openConnection();
		     c.setConnectTimeout(999);
		     c.setReadTimeout(999);
		     
		     is = c.getInputStream();
		     //is = apiURL.openStream();
		     BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));	
		     //is = new URL(url).openStream();
		     //BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
		     String jsonText = readAll(rd);
		     return jsonText;
	    } catch (MalformedURLException e) {
	    	lilaLog.error(e.getMessage(), e);
	    	lilaLog.info(url);
		    return null;
		} catch (IOException e) {
			 lilaLog.error(e.getMessage(), e);
			 lilaLog.info(url);
			 return null;
		} catch(Exception e)  {
			lilaLog.error(e.getMessage(), e);
			lilaLog.info(url);
			return null;
		}finally {
			  try{
				  is.close();
			  }catch(Exception e){
			      lilaLog.error("double exception", e);
				  return null;
			  }
		} 
	  }
	  
	  public HashMap<String, String> getApi() throws IOException {
		  
		  HashMap<String, String> apiProperties = new HashMap<String, String>();
		  LiLaConnector lc = new LiLaConnector();
		  HashMap<String, String> lilaProp = lc.getLiLaConfigProp();
		 
	        if(lilaProp!=null){
	        	try{
	        		apiProperties.put("api", lilaProp.get("lilaApi"));
	        		apiProperties.put("apiKey", lilaProp.get("lilaApiKey"));
	        	} catch(Exception e){
		        	lilaLog.info("lilaConnector: config.properties error!");
		        	
		        	return null;
		        }
	        } else {
	        	return null;
	        }
			
			return apiProperties;
	  }
	  
	  //  for test
	 /*
	  public static void main(String[] args) throws SQLException, IOException, ParseException
	  {
		  LiLaDB ll = new LiLaDB();
		  System.out.print(ll.getHeadQueriesFromApi().toString());
		  
		 // InputStream in = LiLaDB.class.getResourceAsStream("livinglabs.properties");
	     // System.out.print(in.available());

	  }
	  */


}