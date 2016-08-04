package org.dspace.app.xmlui.aspect.discovery;

import java.util.ArrayList;
import java.util.List;

import org.dspace.content.DSpaceObject;
/**
 *
 * @author Narges Tavakolpoursaleh
 */

public class LiLaSearch {

	 private List<LiLaSearchListener> listeners = new ArrayList<LiLaSearchListener>();  ///

	 public void addListener(LiLaSearchListener toAdd) {                         
	     listeners.add(toAdd);                                              
	 }                                                                       

	 public void lilaLogAction(String srt, DSpaceObject scope,String sort,int cpage, int ppage, String order, List<String> rankers) {

	     for (LiLaSearchListener hl : listeners)
	         hl.livinglabLog(srt, scope, sort, cpage, ppage, order, rankers);
	 }
	 
	
}
