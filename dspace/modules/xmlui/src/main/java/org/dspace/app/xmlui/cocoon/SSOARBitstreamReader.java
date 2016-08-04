package org.dspace.app.xmlui.cocoon;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Map;

import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.log4j.Logger;
import org.xml.sax.SAXException;

import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.handle.HandleManager;
import org.dspace.app.xmlui.utils.ContextUtil;
import org.gesis.wts.ssoar.tools.FrontPageGenerator;

public class SSOARBitstreamReader extends BitstreamReader {

    private static Logger log = Logger.getLogger(SSOARBitstreamReader.class);
    
    private Item SSOARitem = null;
    private boolean reloadXSLT = false;
    
    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par)
            throws ProcessingException, SAXException, IOException {
        
        // get item for later accession of handleID and itemID
        try {
            Context context = ContextUtil.obtainContext(objectModel);
            int itemID = par.getParameterAsInteger("itemID", -1);
            String handle = par.getParameter("handle", null);
            
            String reload = par.getParameter("reloadXSLT", "not Set");
            if (reload.equals("true"))
                reloadXSLT = true;
            log.debug("XSLT reload is set to: " + reloadXSLT);
            
            log.debug("handle: " + handle);
            DSpaceObject dso = null;
            
            if (itemID > -1) {
                // Referenced by internal itemID
                SSOARitem = Item.find(context, itemID);
            } else if (handle != null) {
                // Reference by an item's handle.
                dso = HandleManager.resolveToObject(context, handle);
                
                if (dso instanceof Item) {
                    SSOARitem = (Item) dso;
                }
            }
            log.info("ItemID: " + SSOARitem.getID() + " - Handle: " + SSOARitem.getHandle());
        } catch (SQLException sqle) {
            throw new ProcessingException("Unable to read bitstream.", sqle);
        }
        super.setup(resolver, objectModel, src, par);
    }
    
    public void generate() throws IOException, SAXException, ProcessingException {
        if (SSOARitem.getHandle() != null) {
            log.info("generating frontpage");
            String metadataURLPrefix = ConfigurationManager.getProperty("ssoar.frontpage.metadataURLPrefix");
            String fileStorage = ConfigurationManager.getProperty("ssoar.frontpage.fileStorage");
            String xsltPath = ConfigurationManager.getProperty("ssoar.frontpage.xslt");
            log.debug("DSpace-config details: " + metadataURLPrefix + " - " + fileStorage + " - " + xsltPath);
            
            FrontPageGenerator generator = FrontPageGenerator.getInstance(metadataURLPrefix, fileStorage, xsltPath);
            if (reloadXSLT)
                generator.reloadXSLT();
            
            File newPDF = generator.xmlToPdfPerXsl(SSOARitem.getID(), SSOARitem.getHandle(),
                    SSOARitem.getLastModified(), super.bitstreamInputStream);
            
            if (newPDF != null && newPDF.exists()) {
                InputStream newBitstreamInputStream = new FileInputStream(newPDF);
                if (newBitstreamInputStream != null) {
                    log.debug("New InputStream: " + newBitstreamInputStream.available());
                    super.bitstreamSize = newPDF.length();
                    log.debug("Size: " + bitstreamSize);
                    super.bitstreamInputStream = newBitstreamInputStream;
                }
            } else {
                log.error("File does not exist: " + newPDF.getAbsolutePath() + " - for item: " + SSOARitem.getID()
                        + " - handle: " + SSOARitem.getHandle());
            }
        }
        super.generate();
        
    }
    
}
