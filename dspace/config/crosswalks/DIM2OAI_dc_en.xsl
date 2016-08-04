<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                version="1.0">
<!--
        Incomplete proof-of-concept Example of
        XSLT crosswalk from DIM (DSpace Intermediate Metadata) to
        Qualified Dublin Core.
         by William Reilly, aug. 05; mutilated by Larry Stone.

        This is only fit for a simple smoke test of the XSLT-based
        crosswalk plugin, do not use it for anthing more serious.

 Revision: $Revision: 3705 $
 Date:     $Date: 2009-04-11 20:02:24 +0300 (Sat, 11 Apr 2009) $

-->

        <xsl:template match="@* | node()">
        <!--  XXX don't copy everything by default.
                <xsl:copy>
                        <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
         -->
        </xsl:template>

        <!-- http://wiki.dspace.org/DspaceIntermediateMetadata -->
        
	<xsl:template match="dspace:dim">
        	<!-- http://dublincore.org/schemas/xmls/qdc/2003/04/02/qualifieddc.xsd -->
        	<xsl:element name="dcterms:qualifieddc">
        		<xsl:apply-templates/>
        	</xsl:element>
	</xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element ='identifier' and @qualifier='urn']">			
                <xsl:element name="dc:identifier">
                        <xsl:if test="not(starts-with(text(),'http://nbn-resolving.de'))">
                                <xsl:text>http://nbn-resolving.de/</xsl:text>        
                        </xsl:if>			
			<xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element ='identifier' and @qualifier!='urn']">			
                <xsl:element name="dc:identifier">                      		
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element ='date' and (@qualifier='issued' or @qualifier='modified')]">			
                <xsl:element name="dc:date">                      		
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        
        <xsl:template match="dspace:field[@element ='title']">
		<!--  http://dublincore.org/schemas/xmls/qdc/2003/04/02/dcterms.xsd  -->
		<xsl:element name="dc:title">
			<xsl:value-of select="text()"/>
		</xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and (@element ='contributor' or (@element='source' and (@qualifier='recensionauthor' or @qualifier='recensioneditor')))]">
		<xsl:element name="dc:creator">
		      <xsl:value-of select="text()"/>
		</xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element ='subject' and @qualifier='other']">
		<xsl:element name="dc:subject">
			<xsl:value-of select="text()"/>
		</xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[(not(@lang) or @lang='en') and @mdschema='dc' and @element ='subject' and 
                (@qualifier='ddc' or @qualifier='thesoz' or @qualifier='classoz' or @qualifier='method')]  ">
                <xsl:element name="dc:subject">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element ='source' and 
                (@qualifier='journal' or @qualifier='collection' or @qualifier='volume' or @qualifier='issue' or
                 @qualifier='city' or @qualifier='series' or @qualifier='recensionseries' or
                 @qualifier='recensionedition' or @qualifier='recensioncity' or @qualifier='pageinfo')]  ">
                <xsl:element name="dc:source">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @qualifier!='country' and (@element='publisher' or (@element ='source' and @qualifier='recensionpublisher'))]  ">
                <xsl:element name="dc:publisher">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[(not(@lang) or @lang='en') and @mdschema='dc' and @element ='publisher' and @qualifier='country']  ">
                <xsl:element name="dc:publisher">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[(not(@lang) or @lang='en') and @mdschema='dc' and @element ='type' and @qualifier='document']  ">
                <xsl:element name="dc:type">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element='description' and @qualifier='abstract']">
                <xsl:element name="dc:description">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[(not(@lang) or @lang='en') and @mdschema='dc' and @element='description' and 
                (@qualifier='review' or @qualifier='pubstatus')]">
                <xsl:element name="dc:description">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[@mdschema='dc' and @element='language']">
                <xsl:element name="dc:language">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        <xsl:template match="dspace:field[(not(@lang) or @lang='en') and @mdschema='dc' and @element='rights' and @qualifier='licence']">
                <xsl:element name="dc:rights">
                        <xsl:value-of select="text()"/>
                </xsl:element>
        </xsl:template>
        
        
</xsl:stylesheet>
