package org.dspace.app.xmlui.aspect.discovery;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.apache.log4j.Logger;


/**
 *
 * @author Narges Tavakolpoursaleh
 */

public class LiLaInterleaver {

	 private static final Logger lilaLog = Logger.getLogger("lilaLogger");   
	 
	 public static Map<String,List<String>> getInterleavedResult(List<String> a,List<String> b, String team) { 
		 List<String>  result = new ArrayList<String>();
		 List<String>  teamA = new ArrayList<String>();
		 List<String>  teamB = new ArrayList<String>();
		 List<String>  rest = new ArrayList<String>();
		
		 // filtering
		 // remove all the items in b which are not in a
		 
		 Iterator<String> i = b.iterator();
		 while (i.hasNext()) {
		    String s = i.next(); // must be called before you can call i.remove()
		    if(!(a.contains(s))) {
		    		lilaLog.info("removing the items which are not availble anymore:");
		    		lilaLog.info(s);
		    		i.remove();
		    } 
		 }
		 // remove all the items in a which are not in b and add them in a new list. The list
		 // will be inserted at the end of interleaving process
		 Iterator<String> j = a.iterator();
		 while (j.hasNext()) {
		    String ss = j.next(); // must be called before you can call i.remove()
		    if(!(b.contains(ss))) {
		    		lilaLog.info("pushing the new documents of ssoar at the end of interleaved result:");
		    		lilaLog.info(ss);
		    		rest.add(ss); 
		    		j.remove();
		    } 
		 }
		 
		 //
		 Random rand = new Random(); 
		 if(b.isEmpty() || a.isEmpty()){
			 return null;
		 }
		 int randbit = rand.nextInt(2); 
		 while(!(b.isEmpty() || a.isEmpty()) && (a.get(0).equals(b.get(0)))){          // For common items
			 result.add(b.get(0)); 
			 a.remove(0);
			 b.remove(0); 
		 } 
		 while(!a.isEmpty() && !b.isEmpty()) {          			
			 // not at the end of A or B
             // in the case where all elements of a are also in b
			 // if a is empty, it means that all the element of a(also of b) are in l, so it should stop		
			 if((teamA.size()<teamB.size()) || ((teamA.size()==teamB.size())  && (randbit==1))){
				 while((!a.isEmpty()) && result.contains(a.get(0))){
					 a.remove(0);                    
				 } 

				 if(!a.isEmpty()){ 
					 result.add(a.get(0));           //append it to result
					 teamA.add(a.get(0));			 //clicks credited to A	
					 a.remove(0);
				 } 
			 } else {
				 while((!b.isEmpty()) && result.contains(b.get(0))){
					 b.remove(0);     
				 }

				 if(!b.isEmpty()){ 
					 result.add(b.get(0));           //append it to result
					 teamB.add(b.get(0));			 //clicks credited to A	
					 b.remove(0);
				} 

			 }
			randbit = rand.nextInt(2);
		 }
		 
		 // to add the new arrival document at the end of interleaved list
		    for(String doc:rest){
		    		result.add(doc);           //append it to result
					teamA.add(doc);			 //clicks credited to A	
		    }
		
		  List<String> teams = new ArrayList<String>();
		  teams.add(team);
		  Map<String,List<String>> map =new HashMap<String, List<String>>();
		  map.put("result",result);
		  map.put("teamA",teamA);
		  map.put("teamB",teamB);
		  map.put("teams", teams);
		  lilaLog.info("teamA (site)"+teamA.toString());
		  lilaLog.info("teamB "+teamB.toString());
		  return map;
                                            
	 } 

	
}
