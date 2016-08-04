<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xalan="http://xml.apache.org/xslt"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:oai_wgl="http://www.leibnizopen.de/fileadmin/default/documents/oai_wgl/" 
	xmlns:wgl="http://www.leibnizopen.de/fileadmin/default/documents/wgl_dc/"
	version="1.0">
	
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	<xsl:strip-space elements="*"/>
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
	<xsl:template match="/doc:metadata">		
		<oai_wgl:wgl  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.leibnizopen.de/fileadmin/default/documents/oai_wgl/ http://www.leibnizopen.de/fileadmin/default/documents/oai_wgl/oai_wgl.xsd">		
			
			<xsl:apply-templates select='doc:element[@name="dc"]'/>
			<xsl:apply-templates select='doc:element[@name="internal"]'/>
			<xsl:apply-templates select='doc:element[@name="ssoar"]'/>
			
			<!--<xsl:element name="wgl:contributor">SSOAR - Social Science Open Access Repository</xsl:element>-->		
			
			<xsl:call-template name="wglsubject">
				<xsl:with-param name="rootNode" select="doc:element[@name='internal']"/>
			</xsl:call-template>
			
			<!--<xsl:value-of select="node()"/>-->
			<xsl:call-template name="source">				
				<xsl:with-param name="rootNode" select="doc:element[@name='dc']"/>
			</xsl:call-template>
			
		</oai_wgl:wgl>
			
	</xsl:template>
	
	<xsl:template match="doc:element[@name='dc']">
		<!-- dc.identifier.urn -->
		<xsl:for-each select="doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:identifier">
				<xsl:if test="not(starts-with(text(),'http://nbn-resolving.de'))">
					<xsl:text>http://nbn-resolving.de/</xsl:text>        
				</xsl:if>			
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.identifier -->
		<xsl:for-each select="doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">				
			<xsl:element name="wgl:identifier"> 
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		
		<!-- dc.date.issued and dc.date.modified -->
		<!--<xsl:for-each select="doc:element[@name='date']/doc:element[@name='issud' or @name='modified']/doc:element/doc:field[@name='value']">-->
		<xsl:for-each select="doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">					
			<xsl:element name="wgl:date">   
				<xsl:value-of select="text()"/>
			</xsl:element>	
		</xsl:for-each>
		
		<!-- dc.title -->
		<xsl:for-each select="doc:element[@name='title']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:title">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.contributor.autho -->
		<xsl:for-each select="doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:creator">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.contributor.recensionauthor 
		
		<xsl:for-each select="doc:element[@name='source']/doc:element[@name='recensionauthor' ]/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:creator">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>-->
		
		<!-- dc.contributor.editor -->
		<xsl:for-each select="doc:element[@name='contributor']/doc:element[@name='editor' or @name='corporateeditor']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:contributor">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.contributor 
		
		<xsl:for-each select="doc:element[@name='source']/doc:element[@name='recensioneditor' ]/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:creator">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>-->
		
		
			
			<!-- dc.identifier -->
		<xsl:for-each select="doc:element[@name='subject']/doc:element[@name='other']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:subject">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.subject.{thesoz, classoz, methods} -->
		<xsl:for-each select="doc:element[@name='subject']/doc:element[@name='thesoz' or @name='classoz' or @name='method']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:subject">
				<xsl:value-of select="text()"/>
			</xsl:element>			
		</xsl:for-each>
		
		<!-- dc.publisher.country -->
		<xsl:for-each select="doc:element[@name='publisher']/doc:element[@name='country']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:publisher">
				<xsl:value-of select="text()"/>
			</xsl:element>			
		</xsl:for-each>
		
		<!-- dc.publisher.country -->
		<xsl:if test="doc:element[@name='publisher']/doc:element[@name='city'] or
			doc:element[@name='publisher']/doc:element/doc:field">
			<xsl:element name="wgl:publisher">
				<xsl:if test="doc:element[@name='publisher']/doc:element[@name='city']">
					<xsl:value-of select="doc:element[@name='publisher']/doc:element[@name='city']/doc:element/doc:field[@name='value']/text()"/>
					<xsl:if test="doc:element[@name='publisher']/doc:element/doc:field"><xsl:text>:</xsl:text></xsl:if>
				</xsl:if>
				<xsl:for-each select="doc:element[@name='publisher']/doc:element/doc:field[@name='value']">					
						<xsl:value-of select="text()"/>					
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		
		
		<!-- dc.source.recensionpublisher -->
		<xsl:for-each select="doc:element[@name='source']/doc:element[@name='recensionpublisher']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:publisher">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>	
		
		<!-- dc.type.document -->
		<xsl:for-each select="doc:element[@name='type']/doc:element[@name='document']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:type">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.description.abstract -->
		<xsl:for-each select="doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:description">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.description.{review, pubstatus} -->
		<xsl:for-each select="doc:element[@name='description']/doc:element[@name='review' or @name='pubstatus']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:if test="not(contains(text(),'unbekannt'))">
				<xsl:element name="wgl:description">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>
		
		<!-- dc.language -->
		<xsl:for-each select="doc:element[@name='identifier']/doc:element[@name='language']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:language">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
		<!-- dc.identifier -->
		<xsl:for-each select="doc:element[@name='rights']/doc:element[@name='licence']/doc:element[@name='de']/doc:field[@name='value']">
			<xsl:element name="wgl:rights">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="doc:element[@name='internal']">
		<xsl:apply-templates select="./doc:element[@name='identifier']/doc:element[@name='document']/doc:element/doc:field[@name='value']"/>
	</xsl:template>
	
	<xsl:template match="doc:element[@name='ssoar']">
		<!-- wglcontributorfield: ssoar.contributor.institution -->
		<xsl:for-each select="doc:element[@name='contributor']/doc:element[@name='institution']/doc:element/doc:field[@name='value']">
			<xsl:element name="wgl:wglcontributor">
				<xsl:value-of select="text()"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	
	
	<xsl:template name="wglsubject">
		<xsl:param name="rootNode"/>
		<xsl:variable name="ddcNode" select="$rootNode/doc:element[@name='identifier']/doc:element[@name='ddc']/doc:field[@name='value']"/>
		<xsl:choose>
			<xsl:when test="$ddcNode">
				<xsl:for-each select="$ddcNode">
					<xsl:choose>
						<xsl:when test="text()='150' or @text()='330' or text()='370' or text()='570' or text()='610' or text()='710'">							
							<xsl:element name="wgl:wglsubject" >					
								<!-- mapping SSOAR-type to WGLtype -->
								<xsl:choose>
									<xsl:when test="text()='150'">
										<xsl:text>Psychologie</xsl:text>
									</xsl:when>						
									<xsl:when test="text()='330'">
										<xsl:text>Wirtschaftswissenschaften</xsl:text>
									</xsl:when>
									<xsl:when test="text()='370'">
										<xsl:text>Erziehung, Schul- und Bildungswesen</xsl:text>
									</xsl:when>
									<xsl:when test="text()='570'">
										<xsl:text>Biowissenschaften/Biologie</xsl:text>
									</xsl:when>	
									<xsl:when test="text()='610'">
										<xsl:text>Medizin, Gesundheit</xsl:text>
									</xsl:when>
									<xsl:when test="text()='710'">
										<xsl:text>Raumwissenschaften</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="position()=1">
								<xsl:element name="wgl:wglsubject" >
									<xsl:text>Sozialwissenschaften</xsl:text>
								</xsl:element>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="wgl:wglsubject" >
					<xsl:text>Sozialwissenschaften</xsl:text>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>				
	</xsl:template>
	
	<xsl:template name="source">
		<xsl:param name="rootNode"/>
		<xsl:variable name="stock" select ="$rootNode/doc:element[@name='type']/doc:element[@name='stock']/doc:element/doc:field[@name='value']"/>		
		<xsl:variable name="city" select ="$rootNode/doc:element[@name='publisher']/doc:element[@name='city']/doc:element/doc:field[@name='value']"/>			
		<xsl:variable name="country" select ="$rootNode/doc:element[@name='publisher']/doc:element[@name='city']/doc:element/doc:field[@name='value']"/>
		<!--<xsl:variable name="corporateeditor" select ="$rootNode/doc:element[@name='contributor']/doc:element[@name='corporateeditor']"/>-->
		<xsl:variable name="issn" select ="$rootNode/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="isbn" select ="$rootNode/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="collectiontitle" select ="$rootNode/doc:element[@name='source']/doc:element[@name='collection']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="journal" select ="$rootNode/doc:element[@name='source']/doc:element[@name='journal']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="series" select ="$rootNode/doc:element[@name='source']/doc:element[@name='series']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="volume" select ="$rootNode/doc:element[@name='source']/doc:element[@name='volume']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="issue" select ="$rootNode/doc:element[@name='source']/doc:element[@name='issue']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="date_issued" select ="$rootNode/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="pages" select ="$rootNode/doc:element[@name='source']/doc:element[@name='pageinfo']/doc:element/doc:field[@name='value']"/>				
		<!--<xsl:element name="wgl:source">
			<xsl:value-of select="$stock"/>	
		</xsl:element>-->
		
		<xsl:choose>
			<xsl:when test="$stock='article'">				
				<xsl:element name="wgl:source" > 
					<xsl:if test="$journal != ''">
						<xsl:value-of select="$journal"/>							
					</xsl:if>
					
					<xsl:if test="$journal != '' and ($volume != '' or $date_issued != '' or $issue != '')">
						<xsl:text>, </xsl:text>
					</xsl:if>
					
					<xsl:if test="$volume != ''">		
						<xsl:value-of select="$volume"/>
					</xsl:if>					
					
					<xsl:if test="$date_issued != ''">		
						<xsl:text> (</xsl:text>	
						<xsl:value-of select="$date_issued"/>
						<xsl:text>)</xsl:text>
						<xsl:if test="$issue != ''">
							<xsl:text> </xsl:text>
						</xsl:if>						
					</xsl:if>					
					
					<xsl:if test="$issue != ''">						
						<xsl:value-of select="$issue"/>													
					</xsl:if>
					
					<xsl:if test="$volume != '' or $date_issued != '' or $issue != ''">
						<xsl:if test="$pages != ''">
							<xsl:text>, </xsl:text>	
						</xsl:if>																			
					</xsl:if>
					
					<xsl:if test="$pages != ''">	
						<xsl:choose>
							<xsl:when test="contains($pages,'-')">
								<xsl:text>S. </xsl:text>
								<xsl:value-of select="$pages"/>
							</xsl:when>
							<xsl:otherwise>						
								<xsl:value-of select="$pages"/>
								<xsl:text> S.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>	
					
					<xsl:if test="$journal != '' or $volume != '' or $date_issued != '' or $issue != '' or $pages != ''">
						<xsl:text>. </xsl:text>
					</xsl:if>
															
					<xsl:if test="$issn != ''">
						<xsl:text>ISSN </xsl:text>	
						<xsl:value-of select="$issn"/>		
					</xsl:if>										
				</xsl:element>				
			</xsl:when>
			<xsl:when test="$stock='monograph'">
				<xsl:element name="wgl:source" > 
					<xsl:if test="$series != ''">
						<xsl:value-of select="$series"/>	
					</xsl:if>	
					
					<xsl:if test="$series != '' and $volume != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					
					<xsl:if test="$volume != ''">		
						<xsl:value-of select="$volume"/>
					</xsl:if>
					
					<xsl:if test="$volume != '' or $series != ''">		
						<xsl:text>. </xsl:text>													
					</xsl:if>
					
					<xsl:if test="$pages != ''">	
						<xsl:choose>
							<xsl:when test="contains($pages,'-')">
								<xsl:text>S. </xsl:text>
								<xsl:value-of select="$pages"/>
							</xsl:when>
							<xsl:otherwise>						
								<xsl:value-of select="$pages"/>
								<xsl:text> S.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text>. </xsl:text>
					</xsl:if>	
					
					<xsl:if test="$isbn != ''">
						<xsl:text>ISBN </xsl:text>	
						<xsl:value-of select="$isbn"/>						
					</xsl:if>	
					
					<xsl:if test="$isbn != '' and $issn != ''">
						<xsl:text>; </xsl:text>
					</xsl:if>
					
					<xsl:if test="$issn != ''">
						<xsl:text>ISSN </xsl:text>	
						<xsl:value-of select="$issn"/>		
					</xsl:if>
				</xsl:element>				
			</xsl:when>
			<xsl:when test="$stock='collection'">
				<xsl:element name="wgl:source" > 
					<xsl:if test="$series != ''">
						<xsl:value-of select="$series"/>	
					</xsl:if>						
					
					<xsl:if test="$series != '' and $volume != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					
					<xsl:if test="$volume != ''">	
						<xsl:value-of select="$volume"/>
					</xsl:if>
					
					<xsl:if test="$volume != '' or $series">		
						<xsl:text>. </xsl:text>													
					</xsl:if>
					
					<xsl:if test="$pages != ''">	
						<xsl:choose>
							<xsl:when test="contains($pages,'-')">
								<xsl:text>S. </xsl:text>
								<xsl:value-of select="$pages"/>
							</xsl:when>
							<xsl:otherwise>						
								<xsl:value-of select="$pages"/>
								<xsl:text> S.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text>. </xsl:text>
					</xsl:if>
					
					<xsl:if test="$isbn != ''">
						<xsl:text>ISBN </xsl:text>	
						<xsl:value-of select="$isbn"/>						
					</xsl:if>	
					
					<xsl:if test="$isbn != '' and $issn != ''">
						<xsl:text>; </xsl:text>
					</xsl:if>
					
					<xsl:if test="$issn != ''">
						<xsl:text>ISSN </xsl:text>
						<xsl:value-of select="$issn"/>
					</xsl:if>
				</xsl:element>
				
			</xsl:when>
			<xsl:when test="$stock='incollection'">
				<xsl:element name="wgl:source" > 					
					<xsl:if test="$collectiontitle != ''">																						
						<xsl:value-of select="$collectiontitle"/>
						<xsl:text>. </xsl:text>								
					</xsl:if>
					
					<xsl:if test="$series != ''">
						<xsl:value-of select="$series"/>	
					</xsl:if>						
					
					<xsl:if test="$series != '' and $volume != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
						
					<xsl:if test="$volume != ''">	
						<xsl:value-of select="$volume"/>
					</xsl:if>
					
					<xsl:if test="$volume != '' or $series != ''">		
						<xsl:text>. </xsl:text>													
					</xsl:if>
										
					<xsl:if test="$pages != ''">	
						<xsl:choose>
							<xsl:when test="contains($pages,'-')">
								<xsl:text>S. </xsl:text>
								<xsl:value-of select="$pages"/>
							</xsl:when>
							<xsl:otherwise>						
								<xsl:value-of select="$pages"/>
								<xsl:text> S.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text>. </xsl:text>
					</xsl:if>			
				
					<xsl:if test="$isbn != ''">
						<xsl:text>ISBN </xsl:text>	
						<xsl:value-of select="$isbn"/>
						
					</xsl:if>	
					
					<xsl:if test="$isbn != '' and $issn != ''">
						<xsl:text>; </xsl:text>
					</xsl:if>
					
					<xsl:if test="$issn != ''">
						<xsl:text>ISSN </xsl:text>	
						<xsl:value-of select="$issn"/>		
					</xsl:if>
				</xsl:element>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:element name="wgl:source" > 			
					<xsl:if test="$city != ''">		
						<xsl:value-of select="$city"/>
						<xsl:if test="$country != ''">		
							<xsl:text> (</xsl:text>								
							<xsl:value-of select="$country"/>
							<xsl:text>)</xsl:text>								
						</xsl:if>
						<xsl:text>, </xsl:text>								
					</xsl:if>	
					
					<xsl:if test="$collectiontitle != ''">																						
						<xsl:value-of select="$collectiontitle"/>
						<xsl:text>, </xsl:text>								
					</xsl:if>
					
					<xsl:if test="$journal != ''">
						<xsl:value-of select="$journal"/>
						<xsl:text>, </xsl:text>								
					</xsl:if>
					
					<xsl:if test="$series != ''">
						<xsl:value-of select="$series"/>								
						<xsl:text>, </xsl:text>	
					</xsl:if>						
					
					<xsl:if test="$volume != ''">																						
						<xsl:text>Jg. </xsl:text>	
						<xsl:value-of select="$volume"/>
						<xsl:text>, </xsl:text>	
					</xsl:if>
					
					<xsl:if test="$issue != ''">																						
						<xsl:text>H. </xsl:text>	
						<xsl:value-of select="$issue"/>
						<xsl:text>, </xsl:text>								
					</xsl:if>
					
					<xsl:if test="$pages != ''">	
						<xsl:choose>
							<xsl:when test="contains($pages,'-')">
								<xsl:text>S. </xsl:text>
								<xsl:value-of select="$pages"/>
							</xsl:when>
							<xsl:otherwise>						
								<xsl:value-of select="$pages"/>
								<xsl:text> S.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>												
					</xsl:if>						
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!-- WGL-type doc:element[@name='internal']/doc:element[@name='identifier']/doc:element[@name='document']-->
	<xsl:template match="doc:element[@name='document']/doc:element/doc:field[@name='value']">
		<xsl:variable name="id" select="./text()"/>
		
		<xsl:element name="wgl:wgltype" >
			<!-- mapping SSOAR-type to WGLtype -->
			<xsl:choose>
				<xsl:when test="$id='25'">
					<xsl:text>Buchkapitel / Sammelwerksbeitrag</xsl:text>
				</xsl:when>						
				<xsl:when test="$id='16'">
					<xsl:text>Konferenzbeitrag</xsl:text>
				</xsl:when>						
				<xsl:when test="$id='32'">
					<xsl:text>Zeitschriftenartikel</xsl:text>
				</xsl:when>						
				<xsl:when test="$id='12' or $id='3' or $id='1' or $id='13'
					or $id='17' or $id='18' or $id='33'">
					<xsl:text>Report / Forschungsbericht / Arbeitspapier</xsl:text>
				</xsl:when>						
				<xsl:when test="$id='4' or $id='5' or $id='6' 
					or 	$id='8' or $id='21' or $id='22' or $id='23'
					or $id='26' or $id='27' or $id='28' or $id='30' 
					or $id='27'">
					<xsl:text>Sonstiges</xsl:text>
				</xsl:when>	
				<xsl:when test="$id='7' or $id='9' or $id='14' or $id='19'">
					<xsl:text>Hochschulschrift</xsl:text>
				</xsl:when>
				<xsl:when test="$id='20' or $id='24' or $id='10'">
					<xsl:text>Buch / Sammelwerk</xsl:text>
				</xsl:when>
				<xsl:when test="$id='29'">
					<xsl:text>Zeitschrift</xsl:text>
				</xsl:when>
				<xsl:when test="$id='15'">
					<xsl:text>Konferenzband</xsl:text>
				</xsl:when>						
				
				<xsl:otherwise>
					<xsl:text>Nicht definiert</xsl:text>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
