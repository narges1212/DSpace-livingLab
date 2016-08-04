<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd

 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:template match="/">
		<dcterms:qualifieddc>
			
			<!--dc.identifier.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">				
				<xsl:element name="dc:identifier_urn">
					<xsl:if test="not(starts-with(./text(),'http://nbn-resolving.de'))">
						<xsl:text>http://nbn-resolving.de/</xsl:text>        
					</xsl:if>			
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">				
				<xsl:element name="dc:identifier_issn">		
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">				
				<xsl:element name="dc:identifier_isbn">		
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.date.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">				
				<xsl:element name="dc:date_issued">                      		
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='conference']/doc:element/doc:field[@name='value']">				
				<xsl:element name="dc:date_conference">                      		
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			
			<!--dc.contributor.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:contributor_author">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:contributor_editor">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='corporateeditor']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:contributor_corporateeditor">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.subject.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:subject_other">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='thesoz']/doc:element[@name='de']/doc:field[@name='value']">
				<xsl:element name="dc:subject_thesoz">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='classoz']/doc:element[@name='de']/doc:field[@name='value']">
				<xsl:element name="dc:subject_classoz">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='ddc']/doc:element[@name='de']/doc:field[@name='value']">
				<xsl:element name="dc:subject_ddc">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='method']/doc:element[@name='de']/doc:field[@name='value']">
				<xsl:element name="dc:subject_method">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.source.*-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='journal']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_journal">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='conference']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_conference">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='series']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_series">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='collection']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_collection">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_volume">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='issue']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_issue">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>		
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='conferencenumber']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_conferencenumber">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='pageinfo']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_pageinfo">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensionauthor']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensionauthor">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensioneditor']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensioneditor">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensionseries']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensionseries">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensionedition']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensionedition">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensionpublisher']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensionpublisher">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensioncity']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensioncity">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensionisbn']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensionisbn">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element[@name='recensioncity']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:source_recensioncity">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='event']/doc:element[@name='city']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:event_city">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.publisher.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:publisher">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='city']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:publisher_city">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='country']/doc:element[@name!='en']/doc:field[@name='value']">
				<xsl:element name="dc:publisher_country">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.type.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='document']/doc:element[@name!='en']/doc:field[@name='value']">
				<xsl:element name="dc:type_document">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<!--dc.description.*-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:description_abstract">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='review']/doc:element[@name!='en']/doc:field[@name='value']">
				<xsl:element name="dc:description_review">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='pubstatus']/doc:element[@name!='en']/doc:field[@name='value']">
				<xsl:element name="dc:description_pubstatus">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>

			<!--dc.language and dc.rights.licence-->
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<xsl:element name="dc:language">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='licence']/doc:element[@name!='en']/doc:field[@name='value']">
				<xsl:element name="dc:rights_licence">
					<xsl:value-of select="./text()"/>
				</xsl:element>
			</xsl:for-each>


		</dcterms:qualifieddc>
	</xsl:template>
</xsl:stylesheet>
