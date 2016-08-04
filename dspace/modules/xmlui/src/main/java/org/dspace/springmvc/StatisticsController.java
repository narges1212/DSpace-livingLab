package org.dspace.springmvc;

import java.net.MalformedURLException;
import java.util.Calendar;

import javax.annotation.PostConstruct;

import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.dspace.core.ConfigurationManager;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class StatisticsController {
    
    private final Logger log = Logger.getLogger(StatisticsController.class);
    
    @ResponseBody
    @RequestMapping(value = "api/items/{itemId}/statistics", produces = "application/json")
    public String handleStatistics(@PathVariable("itemId") String itemId) {
        log.info("handleStatistics for itemId " + itemId);
        
        String jsonDownloadNumbersString;
        
        try {
            JSONObject jsonDownloadNumbers = new JSONObject();
            
            long pageViewsThisMonth = getStatistics(itemId, false, true);
            jsonDownloadNumbers.put("pageViewsThisMonth", pageViewsThisMonth);
            
            long pageViewsAll = getStatistics(itemId, false, false);
            jsonDownloadNumbers.put("pageViewsAll", pageViewsAll);
            
            long downloadsThisMonth = getStatistics(itemId, true, true);
            jsonDownloadNumbers.put("downloadsThisMonth", downloadsThisMonth);
            
            long downloadsAll = getStatistics(itemId, true, false);
            jsonDownloadNumbers.put("downloadsAll", downloadsAll);
            
            jsonDownloadNumbersString = jsonDownloadNumbers.toString();
        } catch (Exception e) {
            log.error("Could not retrieve statistics for item " + itemId, e);
            jsonDownloadNumbersString = "{ \"error\": \"exception\" }";
        }
        
        log.debug("jsonResult is " + jsonDownloadNumbersString);
        
        return jsonDownloadNumbersString;
    }
    
    private long getStatistics(String itemId, boolean isDownloads, boolean isThisMonth)
            throws SolrServerException, MalformedURLException {
        
        log.info("inside getStatistics");
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        int currentMonth = Calendar.getInstance().get(Calendar.MONTH) + 1;
        
        String currentTime = String.format("%04d-%02d", currentYear, currentMonth);
        
        String solrStatisticsUrl = ConfigurationManager.getProperty("solr.server") + "/statistics";
        
        SolrServer solrStatisticsServer = new HttpSolrServer(solrStatisticsUrl);
        
        SolrQuery solrQuery = new SolrQuery();
        
        solrQuery.set("fq", "isBot:false");
        // solrQuery.addFilterQuery("isBot:false");
        solrQuery.setRows(0);
        
        if (isDownloads) {
            solrQuery.set("q", "owningItem:" + itemId);
            solrQuery.add("fq", "type:0");
        } else {
            solrQuery.set("q", "id:" + itemId);
            solrQuery.add("fq", "type:2");
        }
        
        if (isThisMonth) {
            solrQuery.add("fq", "time:[" + currentTime + "-01T00:00:00.000Z TO NOW]");
        }
        
        QueryResponse response = solrStatisticsServer.query(solrQuery);
        
        return response.getResults().getNumFound();
    }
    
    @PostConstruct
    public void postContruct() {
        log.info("StatisticsController constructed");
    }
    
}
