import javax.xml.transform.Transformer
import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import groovy.xml.XmlUtil
import groovy.xml.MarkupBuilder
import groovy.util.logging.*
import groovy.sql.Sql
import java.sql.SQLException;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.impl.XMLResponseParser;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import java.text.Normalizer
import java.util.regex.Pattern
import java.util.regex.Pattern.First

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;

import org.apache.commons.fileupload.*
import org.apache.commons.fileupload.disk.DiskFileItemFactory
import org.apache.commons.fileupload.servlet.ServletFileUpload
import org.apache.commons.fileupload.servlet.ServletFileUpload

import org.dspace.eperson.EPerson;
import org.dspace.core.Context;
import org.dspace.core.ConfigurationManager;

def isMultipart = ServletFileUpload.isMultipartContent(request)
def solrURL = ConfigurationManager.getProperty("ssoar.sowiport.solr.search.url")
def newSolrURL = ConfigurationManager.getProperty("ssoar.sowiport.solr.search.url.vufind")
//def newSolrURL = "http://multiweb.gesis.org/vufind_solr_biblio/"
String solrFields = "title person_editor_txtP_mv person_author_txtP_mv doctype_lit_str doctype_lit_add_str_mv";
SolrDocument solrDoc
def sowiportID = ""
String email = ""
def accept = ""
def eperson
def lang
def review
def pubstatus
def licence
def fileSize
def fileLocation
def fileItem





//Split the multipart stuff
if (isMultipart) {	
	FileItemFactory fileFactory = new DiskFileItemFactory();
	ServletFileUpload upload = new ServletFileUpload(fileFactory);
	upload.setHeaderEncoding("UTF-8"); // Make sure filenames are
										// not screwed up
	List items = null;
	try {
		items = upload.parseRequest(request);
	} catch (FileUploadException e1) {
		e1.printStackTrace();
		return;
	}
	// Process the uploaded items
	Iterator iter = items.iterator();
	while (iter.hasNext()) {
		FileItem item = (FileItem) iter.next();

		// normalFormfield - Needs a special Handeling, since I
		// can't access
		// the data via request.getParameter
		if (item.isFormField()) {
			try {
//				log.debug "ItemName: " + item.getFieldName();
				if (item.getFieldName().equals("sowiportID"))
					sowiportID = item.getString("UTF-8")
				else if (item.getFieldName().equals("email"))
					email = item.getString("UTF-8")
				else if (item.getFieldName().equals("accept"))
					accept = item.getString("UTF-8")
				else if (item.getFieldName().equals("review"))
					review = item.getString("UTF-8")
				else if (item.getFieldName().equals("pubstatus"))
					pubstatus = item.getString("UTF-8")
				else if (item.getFieldName().equals("licence"))
					licence = item.getString("UTF-8")
				else if (item.getFieldName().equals("lang"))
					lang = item.getString("UTF-8")
			} catch (Exception e) {
//				log.debug e.getMessage();
			}
			// FileField
		} else {
			if (item.getName().trim() == "" || item.getName() == null) {
				fileLocation = "noFulltextUploaded";
			} else {
				fileItem = item
				FileUpload tempFile = new FileUpload();
				fileSize = new Long(item.getSize()).toString();
				// Here the upload is done !!!
				fileLocation = normalizeString(item.getName()).replace("pdf", ".pdf")
			}
//			log.debug "Filelocation: " + fileLocation;
		}
	}
}else{
	sowiportID = request.getParameter("sowiportID");
	email = request.getParameter("email");
	lang = request.getParameter("lang");
}


StringWriter writer = new StringWriter()
def html = new MarkupBuilder(writer)


def fileUploaded = fileItem == null?false:true
def emailEntered = (email.equals("") || email == null)?false:true
def reviewSelected = (review.equals("") || review == null)?false:true
def pubstatusSelected = (pubstatus.equals("") || pubstatus == null)?false:true
def licenceSelected = (licence.equals("") || licence == null)?false:true
def emailCorrect = emailEntered?checkMailAdress(email):false
def licenceAccepted = accept == "on"?true:false
def first = (!fileUploaded && !emailEntered && !licenceAccepted && !reviewSelected && !pubstatusSelected && !licenceSelected)?true:false
def sowiportIDExists = (sowiportID.equals("") || sowiportID == null)?false:true
def solisDocument = (sowiportIDExists && sowiportID.contains("solis"))?true:false


if(solisDocument){
	 sowiportID = changeIDToNewScheme(sowiportID)
	 solrDoc = getDoc(sowiportID, newSolrURL, solrFields)
}

if(!sowiportIDExists){
	html.html (encoding: "UTF-8"){
		head {
			meta('http-equiv':"Content-Type", content:"text/html; charset=UTF-8")
			 title('Keine Sowiport ID übertragen')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/style/dbclear-new.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/layout_3col_standard.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/screen/content_dbclear.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/script/thesaurus/greybox/gb_styles.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/script/thesaurus/greybox/mod_base.css', rel:'stylesheet', type:'text/css')
		}
		body {
				div(id:'header'){
					a(href:'http://www.ssoar.info'){
						img(src:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/img/ssoar/header_logo.png', alt:'', title:'Home', class:'headImg1')
					}
				}
			 
				div(id:'editformdiv', class:'editformDiv'){
				 div(class:'editformText'){
					 h1('Es wurde leider keine SowiportID übertragen!')
				}
			}
		}
	}	 
}

if( fileUploaded && emailCorrect && licenceAccepted && sowiportIDExists){	 
	 solisDocument?importFile(sowiportID, fileItem, review, pubstatus, licence, solrDoc, newSolrURL):oldImportFile(sowiportID, fileItem, review, pubstatus, licence)
	 html.html(encoding: "UTF-8") {
		 head {
			meta('http-equiv':"Content-Type", content:"text/html; charset=UTF-8")
			 title('Importvorgang erfolgreich')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/style/dbclear-new.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/layout_3col_standard.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/screen/content_dbclear.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/script/thesaurus/greybox/gb_styles.css', rel:'stylesheet', type:'text/css')
			 link(href:'http://www.ssoar.info/script/thesaurus/greybox/mod_base.css', rel:'stylesheet', type:'text/css')
		 }
		 body {
			 div(id:'header'){
				 a(href:'http://www.ssoar.info'){
					 img(src:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/img/ssoar/header_logo.png', alt:'', title:'Home', class:'headImg1')
				 }
			 }
			 
			 div(id:'editformdiv', class:'editformDiv'){
				 div(class:'editformText'){
					 h1('Abschluß')
					 br()
					 h2('Vielen Dank!')
					 br()
					 p('Wir werden Ihre Eingaben prüfen und ggf. bibliografische Angaben ergänzen.')
					 p{
						 i('Ihr SSOAR-Team')
					 }
					 div(class:'editFormButtonContainer'){
						 a(href:'http://www.ssoar.info/', class:'import-link', 'zurück zu SSOAR')
						 a(href:'http://www.sowiport.de', class:'import-link', 'zurück zu Sowiport')
					 }
				 }
			 }
		 }
	 }	 
 }
	


if((!fileUploaded || !emailCorrect || !emailEntered || !licenceAccepted || !reviewSelected || !pubstatusSelected || !licenceSelected) && sowiportIDExists){	
	def titleField = ""
	def authors = ""
	
	if(solisDocument){
		//getResponseInFile(newSolrURL + 'select/?q=id:' + sowiportID + '&wt=xslt&tr=ssoar-dspace.xsl', new File('d:/test.xml'))
		//solrDoc = getDoc(sowiportID, newSolrURL)		
		titleField = (solrDoc.getFirstValue('title')!=null)?solrDoc.getFirstValue("title"):""
		

		if(solrDoc.getFirstValue('person_author_txtP_mv') != null){
			def counter = solrDoc.getFieldValues('person_author_txtP_mv').size()

			for (Object curValue: solrDoc.getFieldValues('person_author_txtP_mv')) {
				counter--
				authors += counter>0?String.valueOf(curValue) + "; ":String.valueOf(curValue)
			}	
		}
		
		if(solrDoc.getFirstValue('person_editor_txtP_mv') != null){
			def counter = solrDoc.getFieldValues('person_editor_txtP_mv').size()
			for (Object curValue: solrDoc.getFieldValues('person_editor_txtP_mv')) {
				counter--
				authors += counter>0?String.valueOf(curValue) + "; ":String.valueOf(curValue)
			}	
		}
	}else{	
		def solr = new XmlSlurper().parseText(new URL(solrURL + sowiportID ).text)
		if(solr.result.doc.arr.find{it.@name == 'iztitle1'} || solr.result.doc.arr.find{it.@name == 'iztitle2'} ){
			titleField = solr.result.doc.arr.find{it.@name.equals('iztitle1')}.toString()
			def subtitle = solr.result.doc.arr.find{it.@name.equals('iztitle2')}.toString()
			titleField = titleField + " : " + subtitle
		}
					// dc.contributor.author
		if(solr.result.doc.arr.find{it.@name == 'izperson1'}){
			authors = ""
			def terms = solr.result.doc.arr.find{it.@name == 'izperson1'}.children()
			def counter = 0						
			for (String curterm in terms) {
				counter++
				authors += terms.size()>counter?curterm + "; ":curterm							
			}											
		}
	}
	
	
	html.html (encoding: "UTF-8"){
		head {
			meta('http-equiv':"Content-Type", content:"text/html; charset=UTF-8")
			title('Neues Dokument anlegen')
			link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/style/dbclear-new.css', rel:'stylesheet', type:'text/css')
			link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/layout_3col_standard.css', rel:'stylesheet', type:'text/css')
			link(href:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/css/screen/content_dbclear.css', rel:'stylesheet', type:'text/css')
			link(href:'http://www.ssoar.info/script/thesaurus/greybox/gb_styles.css', rel:'stylesheet', type:'text/css')
			link(href:'http://www.ssoar.info/script/thesaurus/greybox/mod_base.css', rel:'stylesheet', type:'text/css')
		}
		body {
			div(id:'header'){
				a(href:'http://www.ssoar.info'){
					img(src:'http://www.ssoar.info/fileadmin/styles/01_layouts_basics/img/ssoar/header_logo.png', alt:'', title:'Home', class:'headImg1')
				}
			}
			div(id:'editformdiv', class:'editformDiv'){
				br()
				div(class:'editformText'){
					h1('Neues Dokument aus Sowiport übernehmen')
				}
				br()
				div(class:'greenBorder'){
					if(!titleField.equals("")) h2(titleField)
					if(!authors.equals("")) h2(authors)	
				}
				br()
				p('Wenn Sie Besitzer / Rechteinhaber des genannten Textes sind, können Sie diesen hier zum Social Science Open Access Repository (SSOAR) hinzufügen. Alle uns bekannten Metadaten (Autor, Titel, Jahr, Verlag, Zeitschrift etc.) werden im Hintergrund übernommen.')
				h4('Es fehlen nur noch folgende Angaben von Ihnen:')
				form(id:'uploadForm', name:'uploadForm', method:'post', enctype:'multipart/form-data', 'accept-charset':'UTF-8'){
					input(value:'importIntoDBClear', name:'action', type:'hidden')
					input(name:'sowiportID', class:'validField', value:sowiportID,  type:'hidden')
					div{
						div(class:'entryFiels'){
							table(class:'gFieldset'){
								tbody(class:'tableBody'){
									tr(class:'pFieldset'){
										th(class:'pFieldsetLegend'){
											dfn(title:'Klicken Sie auf "Durchsuchen" und w&auml;hlen Sie die Datei auf Ihrer Festplatte aus.', 'Ihr Volltext')
										}
										td(class:'pValuesList'){
											input(onkeypress:'return false;', name:'val_1', type:'file', class:'validField', id:'uploadedfile', size:'44')
											input(type:'hidden', name:'param_1', value:'uploadedfile')
											div(id:'fileupErr')
										}
									}
									if(!fileUploaded && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Bitte laden Sie eine Datei hoch!')
										}
									}
									tr(class:'pFieldset'){
										th(class:'pFieldsetLegend'){
											dfn(title:'', 'Ihre E-Mail-Adresse')
										}
										td(class:'pValuesList'){
											input(name:'email', type:'text', class:'validField', value:email)
										}
									}
									if(!emailEntered && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList error', 'Bitte geben Sie eine E-Mailadresse an!')
									}else if(!emailCorrect && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Ihre Mailadresse ist nicht korrekt oder wurde noch nicht bei SSOAR registriert! Sollten Sie Ihre E-Mailadresse noch nicht bei SSOAR registriert haben, so können Sie dies unter folgendem Link nachholen: '){
												a(href:"https://www.ssoar.info/ssoar/register", 'Bei SSOAR registrieren')											
											}											
										}										
									}
									
									tr(class:'pFieldset'){
										th(class:'pFieldsetLegend'){										
											dfn(title:'', 'Begutachtung')
										}
										td(class:'pValuesList'){	
											select(class:"editFormSelect", name:"review", value:review){
												option()												
												def reviewValues = getConvocEntries("review")
												for(String[] curValue: reviewValues){
													review.equals(curValue[0])?option(value:curValue[0], curValue[1], selected:"selected"):option(value:curValue[0], curValue[1])												
												}												
											}										
										}
									}
									if(!reviewSelected && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Bitte geben Sie den Status der Begutachtung an!')
										}
									}
									
									
									tr(class:'pFieldset'){
										th(class:'pFieldsetLegend'){										
											dfn(title:'', 'Publikationsstatus')
										}
										td(class:'pValuesList'){	
											select(class:"editFormSelect", name:"pubstatus", value:pubstatus){
												option()
												def pubstatusValues = getConvocEntries("pubstatus")
												for(String[] curValue: pubstatusValues){
													pubstatus.equals(curValue[0])?option(value:curValue[0], curValue[1], selected:"selected"):option(value:curValue[0], curValue[1])												
												}																							
											}										
										}
									}
									if(!pubstatusSelected && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Bitte geben Sie den Status der Publikation an!')
										}
									}
									
									tr(class:'pFieldset'){
										th(class:'pFieldsetLegend'){										
											dfn(title:'', 'Lizenz')
										}
										td(class:'pValuesList'){	
											select(class:"editFormSelect", name:"licence", value:licence){
												option()
												def licenceValues = getConvocEntries("licence")
												for(String[] curValue: licenceValues){
													licence.equals(curValue[0])?option(value:curValue[0], curValue[1], selected:"selected"):option(value:curValue[0], curValue[1])												
												}
											}										
										}
									}
									if(!licenceSelected && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Bitte wählen Sie aus welcher Lizenz das Dokument unterliegt!')
										}
									}
									
									tr{
										th(class:'pFieldsetLegend'){
											dfn('Copyright-Hinweis', title:'W&auml;hlen Sie bitte eine passende Lizenzvereinbarung aus.')
										}
										td(class:'pValuesList'){
											p('Durch das Abschicken dieses Formular bestätige ich, dass ich Rechteinhaber/Rechteinhaberin dieses Textes bin bzw. die entsprechende Rechte des ursprünglichen Rechteinhabers/der ursprünglichen Rechteinhaberin besitze. Ich stimme der Archivierung und Bereitstellung des hier eingegebenen Textes in SSOAR zu.', style:'line-height:1.2em')
											p{
												label(for:'accept', id:'laccept'){
													input('Ja, ich stimme diesen Bestimmungen zu.', id:'accept', name:'accept', type:'checkbox')
												}
											}
										}
									}
									if(!licenceAccepted && !first){
										th(class:'pFieldsetLegend')
										td(class:'pValuesList'){
											span(class:'error', 'Bitte akzeptieren sie die Bestimmungen!')
										}										
									}
								}
							}
						}
					}
					div(class:'editFormButtonContainer'){
						input(value:'Weiter', class:'editFormInput', type:'submit')
					}
					p('Probleme? Melden Sie sich einfach bei unserem ', style:'clear:both;text-align:right;padding-top:3em;'){
						a(href:"mailto:team@ssoar.info", 'Team.')
					}
				}
			}
		}
	}
}

println writer.toString()   

private def checkMailAdress(String email) {
	Context context = new Context()
	EPerson checkPerson ;
	try{
		 checkPerson = EPerson.findByEmail(context, email);		
	}catch (SQLException exception){
		exception.printStackTrace();
	}	
	if(checkPerson != null){
		eperson = checkPerson		
		return true
	}		 
	else return false
}

private String changeIDToNewScheme(String solisID){
	String result = "";	
	result = solisID.replace("iz","gesis");		
	result = result.substring(0, result.lastIndexOf("-")+1) + "0" +result.substring(result.lastIndexOf("-")+2);
	return result;
}



private SolrDocument getDoc(String docID, String url, String fields) {	
	
	SolrDocument resultDoc = new SolrDocument();
	try{		
		SolrServer solrServer = new CommonsHttpSolrServer(url);
		SolrQuery solrQuery = new SolrQuery();		
		solrQuery.setQuery("id:" + docID);				
		solrQuery.setFields(fields);		
		QueryResponse response = solrServer.query(solrQuery);		
		resultDoc = response.getResults().get(0);		
	}catch (Exception e) {
		e.printStackTrace();
	}		
	return resultDoc;
}

private void importFile(def sowiportID, def fileItem, def review, def pubstatus, def licence, def doc, def solrURL){	
	def stock = 1
	if(doc.containsValue("Zeitschriftenaufsatz")) stock = 1 // Collection 1 für Zeitschriftenartikel
	else if(doc.containsValue("Sammelwerksbeitrag")) stock = 3 // Collection 3 für Sammelwerksbeiträge
	else if(doc.containsValue("Buch")) stock = 2 // Collection 2 für Monografien
	
	// create and prepare folders
	def importBuffer = ConfigurationManager.getProperty("ssoar.sowiport.import.buffer") + "/" + normalizeString(eperson.getFullName()) + "/collection_" + stock
	def importFolder = new File(importBuffer)
	def folderNumber = importFolder.exists()?importFolder.listFiles().length:"0"
	importFolder = new File(importFolder.getAbsolutePath() + "/" + folderNumber).exists()?new File(importFolder.getAbsolutePath() + "/" +  (folderNumber+1) ):new File(importFolder.getAbsolutePath() + "/" +  folderNumber);	
	importFolder.mkdirs()	
	
	// prepare filename and save it to hard disk
	def fileName = normalizeString(fileItem.getName()).replace("pdf", ".pdf")	
	def uploadedFile = new File(importFolder.getAbsolutePath() + "/" + fileName)
	fileItem.write(uploadedFile);
	
	// read dublin_core xml from sowiport solr and write it to hard disk
	def dcFile = new File(importFolder.getAbsolutePath() + "/dublin_core.xml")
	writeResponseToFile(solrURL + '/select/?q=id:' + sowiportID + '&wt=xslt&tr=ssoar-dspace.xsl',dcFile)
	
	// read solr result or dublin_core
	def dcXML = new XmlSlurper(false, false).parse(dcFile)
	// add review, pubstatus and licence node to xml
	dcXML.appendNode {
		dcvalue(review, md_schema:'dc', element:'description', qualifier:'review', lang:'de')
		dcvalue(pubstatus, md_schema:'dc', element:'description', qualifier:'pubstatus', lang:'de')		
		dcvalue(licence, md_schema:'dc', element:'rights', qualifier:'licence', lang:'de')
		dcvalue(sowiportID, md_schema:'dc', element:'description', qualifier:'misc', lang:'de')		
	}	
	// write the new xml back to the file
	OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(dcFile.getAbsolutePath()),"UTF-8");	
	groovy.xml.XmlUtil.serialize( dcXML,out )	
	out.close();	
	
	//create content file
	new File(importFolder.getAbsolutePath() + "/contents").append(fileName + "\tbundle:ORIGINAL")	
	
	//Do the actual importing	
	def map = (new File(importBuffer + "/map.txt")).exists()?"/map.txt --resume ":"/map.txt"	
	def importString = ConfigurationManager.getProperty("dspace.dir") + "/bin/dspace import -a -w -n -e " + eperson.getEmail() + " -c " + stock + " -s " + importBuffer + " -m " + importBuffer + map
	importString.execute() 
}
	
	
private ArrayList<String[]> getConvocEntries(def voc){
	ArrayList<String[]> results = new ArrayList<String[]>()
	def dbhost = ConfigurationManager.getProperty("ssoar.db.host")
	def database = ConfigurationManager.getProperty("ssoar.db.database")
	def username = ConfigurationManager.getProperty("ssoar.db.username")	
	def password = ConfigurationManager.getProperty("ssoar.db.password")	
	def sql = Sql.newInstance(dbhost + database, username, password, "org.postgresql.Driver")
	
	def vocvalues = []
    sql.eachRow('Select id,value_de from ' + voc ) {
        vocvalues << it.toRowResult()
    }
	for(int i=0; i<vocvalues.size(); i++){
		String[] entries = new String[2]
		entries[0] = vocvalues[i][0]
		entries[1] = vocvalues[i][1]
		results.add(entries)
	}
	sql.close()
    return results

}

public static String normalizeString(String input){
	String output = input;
	output = Normalizer.normalize(output, Normalizer.Form.NFD).replaceAll(" ", "_");
	Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
	output = pattern.matcher(output).replaceAll("");
	Pattern pattern2 = Pattern.compile("[^\\w\\-\\_]");
	output = pattern2.matcher(output).replaceAll("");
	return output;
}

private void writeResponseToFile(String address, File file) throws IOException {  
	def BUFFER_SIZE = 4096
	if (!file.exists()) {  
		file.createNewFile();  
	}  

	InputStream inputStream = null;  
	OutputStream outputStream = null;  
	try {  
		URL url = new URL(address);  
		URLConnection connection = url.openConnection();  

		inputStream = connection.getInputStream();  
		outputStream = new FileOutputStream(file);  

		byte[] data;  
		if (inputStream.available() > BUFFER_SIZE) {  
			data = new byte[BUFFER_SIZE];  
		} else {  
			data = new byte[inputStream.available()];  
		}  

		int dataCount;  
		while ((dataCount = inputStream.read(data)) > 0) {  
			outputStream.write(data, 0, dataCount);  
		}  

	} finally {  
		try {  
			inputStream.close();  
		} catch (Exception e) {  
		}  
		try {  
			outputStream.close();  
		} catch (Exception e) {  
		}  
	}  
} 

private void oldImportFile(def sowiportID, def fileItem, def review, def pubstatus, def licence){	
	def solr = new XmlSlurper().parseText(new URL(ConfigurationManager.getProperty("ssoar.sowiport.solr.search.url") + sowiportID ).text)
	
	// Mapping of sowiport doctypes to ssoar stocks
	def stock = solr.result.doc.arr.find{it.@name == 'iztype2'}? solr.result.doc.arr.find{it.@name == 'iztype2'}.children()[0]:10
	
	switch (stock) {
	   case 'journalarticle':
		   stock = 1
		   break
	   case 'article':
		   stock = 3
		   break
	   case ['book', 'monograph', 'researchreport']:
		   stock = 2
		   break
	   case 'review':
		   stock = 5
		   break
	   default:
		   stock = 10
	}
	
	def importBuffer = ConfigurationManager.getProperty("ssoar.sowiport.import.buffer") + "/" + normalizeString(eperson.getFullName()) + "/oldimport/" + stock
	def importFolder = new File(importBuffer)
	def folderNumber = importFolder.exists()?importFolder.listFiles().length-1:"0"
	importFolder = new File(importFolder.getAbsolutePath() + "/" +  folderNumber )
	importFolder.mkdirs()	
	def fileName = normalizeString(fileItem.getName()).replace("pdf", ".pdf")	
	def uploadedFile = new File(importFolder.getAbsolutePath() + "/" + fileName)
	fileItem.write(uploadedFile);
	
	OutputStreamWriter output = new OutputStreamWriter(new FileOutputStream(importFolder.getAbsolutePath() + "/dublin_core.xml" ), "UTF-8");
	def dublin_core = new MarkupBuilder(output)
	new File(importFolder.getAbsolutePath() + "/contents").append(fileName + "\tbundle:ORIGINAL")
	
	dublin_core.dublin_core{
		dcvalue(review, md_schema:'dc', element:'description', qualifier:'review', lang:'de')
		dcvalue(pubstatus, md_schema:'dc', element:'description', qualifier:'pubstatus', lang:'de')		
		dcvalue(licence, md_schema:'dc', element:'rights', qualifier:'licence', lang:'de')
		
		// dc.title
		if(solr.result.doc.arr.find{it.@name == 'iztitle1'} || solr.result.doc.arr.find{it.@name == 'iztitle2'} ){
			def title = solr.result.doc.arr.find{it.@name.equals('iztitle1')}.toString()
			def subtitle = solr.result.doc.arr.find{it.@name.equals('iztitle2')}.toString()
			dcvalue(title + " : " + subtitle, md_schema:'dc', element:'title', qualifier:'', lang:'')
		}
			
		// dc.language
		if(solr.result.doc.arr.find{it.@name == 'izlanguage'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izlanguage'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'language', qualifier:'', lang:'')
			}
		}
		
		// dc.date.issued
		if(solr.result.doc.arr.find{it.@name == 'izissuedint'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izissuedint'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'date', qualifier:'issued', lang:'')
			}
		}
			
		// dc.identifier.issn
		if(solr.result.doc.arr.find{it.@name == 'izissn'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izissn'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'identifier', qualifier:'issn', lang:'')
			}
		}
			
		// dc.identifier.isbn
		if(solr.result.doc.arr.find{it.@name == 'izisbn'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izisbn'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'identifier', qualifier:'isbn', lang:'')
			}
		}
			
		// dc.source.journal
		if(solr.result.doc.arr.find{it.@name == 'izsource1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izsource1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'source', qualifier:'journal', lang:'')
			}
		}
		
		// dc.contributor.author
		if(solr.result.doc.arr.find{it.@name == 'izperson1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izperson1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'contributor', qualifier:'author', lang:'')
			}
		}
		
		// dc.contributor.editor
		if(solr.result.doc.arr.find{it.@name == 'izperson2'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izperson2'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'contributor', qualifier:'editor', lang:'')
			}
		}
	
		// dc.contributor.corporateeditor
		if(solr.result.doc.arr.find{it.@name == 'izinstitution2'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izinstitution2'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'contributor', qualifier:'corporateeditor', lang:'')
			}
		}
		
		// dc.source.publisher
		if(solr.result.doc.arr.find{it.@name == 'izinstitution1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izinstitution1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'publisher', qualifier:'', lang:'')
			}
		}
		
		// dc.source.conference
		if(solr.result.doc.arr.find{it.@name == 'izconference1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izconference1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'source', qualifier:'conference', lang:'')
			}
		}
		
		// dc.publisher.country
		if(solr.result.doc.arr.find{it.@name == 'izlocation1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izlocation1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'publisher', qualifier:'country', lang:'')
			}
		}
		
		// dc.subject.thesoz
		if(solr.result.doc.arr.find{it.@name == 'izsubject1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izsubject1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'subject', qualifier:'thesoz', lang:'de')
			}
		}
		
		// // dc.subject.other
		if(solr.result.doc.arr.find{it.@name == 'izsubject2'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izsubject2'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'subject', qualifier:'other', lang:'')
			}
		}
		
		// dc.subject.methods
		if(solr.result.doc.arr.find{it.@name == 'izsubject3'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izsubject3'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'subject', qualifier:'methods', lang:'de')
			}
		}
		
		// dc.subject.classoz
		if(solr.result.doc.arr.find{it.@name == 'izclassifications'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izclassifications'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'subject', qualifier:'classoz', lang:'')
			}
		}
		
		/* dc.subject.classoz
		if(solr.result.doc.arr.find{it.@name == 'izclassification1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izclassification1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'subject', qualifier:'classoz', lang:'')
			}
		}
		*/
		
		// dc.description.abstract
		if(solr.result.doc.arr.find{it.@name == 'izabstract1'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izabstract1'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'description', qualifier:'abstract', lang:'')
			}
		}
		
		// dc.source.pageinfo
		if(solr.result.doc.arr.find{it.@name == 'izpages'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izpages'}.children()
			for (String curterm in terms) {
				def pageinfo = curterm.replaceAll("[^0-9\\-]+", "");
				dcvalue(pageinfo, md_schema:'dc', element:'source', qualifier:'pageinfo', lang:'')
			}
		}
		
		// dc.source.volume
		if(solr.result.doc.arr.find{it.@name == 'izvolume'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izvolume'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'source', qualifier:'volume', lang:'')
			}
		}
		
		// dc.source.issue
		if(solr.result.doc.arr.find{it.@name == 'izissue'}){
			def terms = solr.result.doc.arr.find{it.@name == 'izissue'}.children()
			for (curterm in terms) {
				dcvalue(curterm, md_schema:'dc', element:'source', qualifier:'issue', lang:'')
			}
		}
	}
	output.close()
	
	//Do the actual importing	
	def map = (new File(importBuffer + "/map.txt")).exists()?"/map.txt --resume ":"/map.txt"	
	def importString = ConfigurationManager.getProperty("dspace.dir") + "/bin/dspace import -a -w -n -e " + eperson.getEmail() + " -c " + stock + " -s " + importBuffer + " -m " + importBuffer + map	
	importString.execute() 
}
	
	
	
