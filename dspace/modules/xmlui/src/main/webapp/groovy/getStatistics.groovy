import groovy.json.StreamingJsonBuilder
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.impl.XMLResponseParser;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.dspace.core.ConfigurationManager;

response.setContentType('application/json')
response.contentType = 'application/json'
//def solrURL = ConfigurationManager.getProperty("solr.url.statistics")
def solrURL = "http://localhost:8080/solr/statistics"

String itemID = request.getParameter("itemID");
def jsonp = params.callback ?: params.jsonp

int curYear = Calendar.getInstance().get(Calendar.YEAR);
int curMonth = Calendar.getInstance().get(Calendar.MONTH)+1;

String curTime = String.format("%04d-%02d", curYear, curMonth);


StringWriter writer = new StringWriter()
def json = new StreamingJsonBuilder(writer)

json{
	pageViewsThisMonth(getStatistics(solrURL, itemID, curTime, false, true))
	pageViewsAll(getStatistics(solrURL, itemID, curTime, false, false))
	downloadsThisMonth(getStatistics(solrURL, itemID, curTime, true, true))
	downloadsAll(getStatistics(solrURL, itemID, curTime, true, false))
}
if (jsonp) print jsonp + '('
print writer.toString()   
if (jsonp) print ')'

int getStatistics(String solrURL, String itemID, String curTime, boolean downloads, boolean thisMonth){
	try{		
		SolrServer solrServer = new CommonsHttpSolrServer(solrURL);
		SolrQuery solrQuery = new SolrQuery();	
		solrQuery.addFilterQuery('isBot:false')
		solrQuery.setRows(0);			
		
		if(downloads){
			solrQuery.setQuery('owningItem:' + itemID)	
			solrQuery.addFilterQuery('type:0')
		}else{
			solrQuery.setQuery('id:' + itemID)
			solrQuery.addFilterQuery('type:2')
		}
		
		if(thisMonth) solrQuery.addFilterQuery('time:[' + curTime + '-01T00:00:00.000Z TO NOW]');				
		
		QueryResponse response = solrServer.query(solrQuery);						
		return response.getResults().getNumFound()
	}catch (Exception e) {
		print e;
		return 0
	}	
}

	





