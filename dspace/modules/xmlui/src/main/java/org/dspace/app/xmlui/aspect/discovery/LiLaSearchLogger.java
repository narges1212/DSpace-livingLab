package org.dspace.app.xmlui.aspect.discovery;


import java.util.List;

import org.apache.log4j.Logger;
import org.dspace.content.DSpaceObject;
import org.dspace.utils.DSpace;

import com.google.api.client.repackaged.com.google.common.base.Joiner;

/**
 *
 * @author Narges Tavakolpoursaleh
 */
class LiLaSearchLogger implements LiLaSearchListener {

	private static final Logger debugLog = Logger.getLogger("debugLogger");  ///
	
	
 @Override
 public void livinglabLog(String srt, DSpaceObject scope, String sort, int cpage, int ppage, String order, List<String> resultsHandleList) {
	
     String doclist = Joiner.on(", ").join(resultsHandleList);

	 String livingLabslog = srt;
	 DSpace dspace = new DSpace();
	 livingLabslog +="SessionID("+ dspace.getSessionService().getCurrentSession().getId()+"),"; ///
     livingLabslog +="UserID("+dspace.getSessionService().getCurrentUserId()+"),";  ///
     livingLabslog +="HostIP("+dspace.getSessionService().getCurrentSession().getOriginatingHostIP()+"),"; ///
     if(scope!=null){
    	 livingLabslog += "Handle(" + scope.getHandle()+") ";
     } else {
    	 livingLabslog += "Handle(null) ";
     }
     livingLabslog += ", Sort(" + sort + ")";   ///
     livingLabslog += ", Currentpage(" +  cpage + ")";   ///
     livingLabslog += ", Ppage(" +  ppage + ")";   ///
     livingLabslog += ", Order(" +  order + ")";   ///
     livingLabslog += ", result("+ doclist+")"; 


	 debugLog.info(livingLabslog);

 }
 
}