<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<xsl:stylesheet    
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" 
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:java="http://xml.apache.org/xslt/java"    
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan" 
    xmlns:encoder="xalan://java.net.URLEncoder"
	xmlns:statics="org.gesis.ssoar.services.SSOARJournalAcronymToFilenameService"
    exclude-result-prefixes="xalan encoder i18n dri mets dim  xlink xsl java statics">

	<!-- the above should be replaced with if Saxon is going to be used. -->
	<xsl:import href="../dri2xhtml/structural.xsl"/>

	<!--<xsl:import href="dri2xhtml/QDC-Handler.xsl"/>
        <xsl:import href="dri2xhtml/MODS-Handler.xsl"/>-->

	<xsl:output indent="yes"/>

	<!-- Some issues:
        - The named templates that are used to break up the monolithic top-level cases (like detailList, for
            example) could potentially conflict with named templates in other metadata handlers. So if, for
            example, I have a MODS and a DIM handler, they will match their respective object templates 
            correctly, since those check for the profile. However, if those templates then break the processing
            up between named templates, and those named templates happen to have the same name between the two
            handlers, a conflict will occur. You will have called a template that is expecting a different 
            profile, which will in turn lead to it not finding the metadata it is expecting. 
        
          The solution to this issue (which would be a pain to debug if it were to happen) is to make sure that
            if you do use named templates, you make their names unique. It would have been a clean and simple 
            solution to just place the name of the profile into the name template's mode, but alas XSL does not
            allow that. 
    -->

	<!-- The summaryList display type; used to generate simple surrogates for the item involved -->
	<xsl:template match="mets:METS[mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']]" mode="summaryList">
		<xsl:choose>
			<xsl:when test="@LABEL='DSpace Item'">
				<xsl:call-template name="itemSummaryList-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Collection'">
				<xsl:call-template name="collectionSummaryList-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Community'">
				<xsl:call-template name="communitySummaryList-DIM"/>
			</xsl:when>                
			<xsl:otherwise>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.non-conformant</i18n:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The templates that handle the respective cases of summaryList: item, collection, and community -->
	<!-- An item rendered in the summaryList pattern. Commonly encountered in various browse-by pages and search results. -->
	<xsl:template name="itemSummaryList-DIM">
		<tr class="resultTableRow">
			<td class="resultTableCellResourceContent">
				<!-- Generate the info about the item from the metadata section -->
				<xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                    mode="itemSummaryList-DIM"/>
				<!-- Generate the thunbnail, if present, from the file section -->
				<!--<xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"/>-->
				<xsl:apply-templates select="./mets:fileSec" mode="action-panel"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="mets:fileSec" mode="action-panel"> 
		<xsl:variable name="internalID" select="ancestor::mets:METS/@ID"/>
		<xsl:variable name="urnprefix">http://nbn-resolving.de/</xsl:variable>
		<xsl:variable name="itemWithdrawn" select="@withdrawn" />
		<xsl:variable name="resourceID">
			<xsl:choose>
				<xsl:when test="$itemWithdrawn">
					<xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ancestor::mets:METS/@OBJID" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 

		<xsl:variable name="urn">
			<xsl:value-of select="../mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
		</xsl:variable>
		<xsl:variable name="filepath">
			<xsl:value-of select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
		</xsl:variable>
		<xsl:variable name="filename">
			<xsl:value-of select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
		</xsl:variable>

		<xsl:variable name="fileuri">
			<xsl:value-of select="concat($protocol, 'www.ssoar.info', $filepath)"/>
		</xsl:variable>

		<xsl:variable name="embargoDate">
			<xsl:value-of select="../mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@mdschema='internal' and @element='embargo' and @qualifier='liftdate']/text()"/>
		</xsl:variable>
		<xsl:variable name="embargoYear" select="substring-before($embargoDate,'-')"/>
		<xsl:variable name="embargoMonth" select="substring-before(substring-after($embargoDate,'-'),'-')"/>
		<xsl:variable name="embargoDay" select="substring-after(substring-after($embargoDate,'-'),'-')"/>
		<xsl:variable name="embargoActive">
			<xsl:choose>
				<xsl:when test="number($curYear) &lt; number($embargoYear)">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:when test="number($curYear) = number($embargoYear)">
					<xsl:choose>
						<xsl:when test="number($curMonth) &lt; number($embargoMonth)">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:when test="number($curMonth) = number($embargoMonth)">
							<xsl:if test="number($curDay) &lt;= number($embargoDay)">
								<xsl:value-of select="true()"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<!-- debugging embargo-date
       <ul>
            <li><xsl:value-of select="$curYear"/></li>
            <li><xsl:value-of select="$curMonth"/></li>
            <li><xsl:value-of select="$curDay"/></li>
            <li><xsl:value-of select="$embargoYear"/></li>
            <li><xsl:value-of select="$embargoMonth"/></li>
            <li><xsl:value-of select="$embargoDay"/></li>
            <li><xsl:value-of select="$embargoActive"/></li>
        </ul>
         -->

		<!-- generate Link to pdf -->
		<div class="actionPanel">
			<xsl:choose>
				<xsl:when test="$embargoActive='true'">
					<div class="resourceDetailsLink">
						<i18n:text>xmlui.ssoar.labels.embargo.short</i18n:text>
						<xsl:call-template name="displayDate">
							<xsl:with-param name="date" select="$embargoDate"/>
						</xsl:call-template>
					</div>
				</xsl:when>
				<xsl:when test="mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file/mets:FLocat[@xlink:href!=''] and $embargoActive!='true'">
					<div class="resourceDetailsLink">
						<a target="_blank" href="http://www.etracker.de/lnkcnt.php?et=qPKGYV&amp;url={$fileuri}&amp;lnkname={$filename}">
							<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
						</a>
						<xsl:variable name="filesize">
							<xsl:value-of select="round(mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file/@SIZE div 1024)"/>	
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$filesize > 0">
								<xsl:text> (</xsl:text>
								<xsl:value-of select="$filesize"/>
								<xsl:text> KByte)</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<i18n:text>xmlui.ssoar.labels.noFileSizeInfo</i18n:text>
							</xsl:otherwise>
						</xsl:choose> 
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<!-- Wenn es eine PID gibt, diese bevorzugen -->
						<xsl:when test="$urn!=''">

							<div class="resourceDetailsLink">
								<a target="_blank">
									<xsl:attribute name="href">
										<xsl:if test="contains($urn,'urn:')">
											<xsl:if test="not(contains($urn,'http://nbn-resolving.de'))">
												<xsl:value-of select="$urnprefix"/>
											</xsl:if>
										</xsl:if>
										<xsl:value-of select="$urn"/>
									</xsl:attribute>
									<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
								</a>
								<xsl:text> (</xsl:text>
								<i18n:text>xmlui.ssoar.labels.externalSource</i18n:text>
								<xsl:text>)</xsl:text>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<!-- No Fulltext -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<div class="resourceDetailsLink">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$resourceID"/>  
					</xsl:attribute>
					<i18n:text>xmlui.ssoar.labels.printOverview</i18n:text>
				</a>
			</div>
		</div>
	</xsl:template>

	<!-- Kurzanzeige -->
	<!-- Generate the info about the item from the metadata section -->
	<xsl:template match="dim:dim" mode="itemSummaryList-DIM">
		<!-- gotoSiteLabel is the the label of the property which is rendered as a link to the resource -->
		<xsl:param name="gotoSiteLabel">title</xsl:param>
		<xsl:param name="state">s_qsimple</xsl:param>
		<xsl:variable name="itemWithdrawn" select="@withdrawn" />
		<xsl:variable name="resourceID">
			<xsl:choose>
				<xsl:when test="$itemWithdrawn">
					<xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ancestor::mets:METS/@OBJID" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="resultTableHeader">
			<a class="resultTableHeader">
				<xsl:attribute name="href">
					<xsl:value-of select="$resourceID"/>  
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="not(./dim:field[@mdschema='dc' and @element='title']/text()='')">
						<xsl:value-of select="./dim:field[@mdschema='dc' and @element='title']/text()"/>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.ssoar.labels.noTitle</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<xsl:if test="./dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']/text()!=''">
				<xsl:text> [</xsl:text>
				<em>
					<i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="./dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']/text()"/>
					</i18n:text>
				</em>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</div>
		<div>
			<xsl:choose>
				<xsl:when test="./dim:field[@element='type' and @qualifier='stock'] = 'collection'">
					<xsl:if  test="./dim:field[@element='contributor' and @qualifier='editor'] != ''">
						<em>
							<i18n:text>xmlui.ssoar.labels.editor</i18n:text>
							<xsl:text>: </xsl:text>
						</em>
						<xsl:for-each select="./dim:field[@element='contributor' and @qualifier='editor']">
							<xsl:value-of select="./text()"/>
							<xsl:if test="position()!=last()">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if  test="./dim:field[@element='contributor' and @qualifier='author'] != ''">
						<em>
							<i18n:text>xmlui.ssoar.labels.author</i18n:text>
							<xsl:text>: </xsl:text>
						</em>
						<xsl:for-each select="./dim:field[@element='contributor' and @qualifier='author']">
							<xsl:value-of select="./text()"/>
							<xsl:if test="position()!=last()">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<div>
			<xsl:apply-templates select="../dim:dim" mode="citationBlock"/>
		</div>
	</xsl:template>

	<!-- A collection rendered in the summaryList pattern. Encountered on the community-list page -->
	<xsl:template name="collectionSummaryList-DIM">
		<xsl:variable name="data" select="./mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
		<li class="summary-collection">
			<a href="{@OBJID}/discover">
				<xsl:choose>
					<xsl:when test="string-length($data/dim:field[@element='title'][1]) &gt; 0">
						<!--EVIL-HACK: display community undertitle if language is english-->
						<xsl:variable name="id">
							<xsl:value-of select="substring-after($data/dim:field[@element='identifier' and @qualifier='uri']/text(), 'collection/' )"/>
						</xsl:variable>
						<i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="$id"/>
						</i18n:text>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<!--Display collection strengths (item counts) if they exist-->
			<xsl:if test="string-length($data/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
				<xsl:text> [</xsl:text>
				<xsl:value-of select="$data/dim:field[@element='format'][@qualifier='extent'][1]"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</li>
	</xsl:template>

	<!-- A community rendered in the summaryList pattern. Encountered on the community-list and on the front page. -->
	<xsl:template name="communitySummaryList-DIM">
		<xsl:variable name="data" select="./mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
		<span class="bold">
			<a href="{@OBJID}/discover">
				<xsl:choose>
					<xsl:when test="string-length($data/dim:field[@element='title'][1]) &gt; 0">
						<!--EVIL-HACK: display community undertitle if language is english-->
						<xsl:variable name="id">
							<xsl:value-of select="substring-after($data/dim:field[@element='identifier' and @qualifier='uri']/text(), 'community/' )"/>
						</xsl:variable>
						<i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="$id"/>
						</i18n:text>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<!--Display community strengths (item counts) if they exist-->
			<xsl:if test="string-length($data/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
				<xsl:text> [</xsl:text>
				<xsl:value-of select="$data/dim:field[@element='format'][@qualifier='extent'][1]"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</span>
	</xsl:template>

	<!-- 
        The detailList display type; used to generate simple surrogates for the item involved, but with
        a slightly higher level of information provided. Not commonly used. 
    -->
	<xsl:template match="mets:METS[mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']]" mode="detailList">
		<xsl:choose>
			<xsl:when test="@LABEL='DSpace Item'">
				<xsl:call-template name="itemDetailList-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Collection'">
				<xsl:call-template name="collectionDetailList-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Community'">
				<xsl:call-template name="communityDetailList-DIM"/>
			</xsl:when>                
			<xsl:otherwise>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.non-conformant</i18n:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- An item rendered in the detailList pattern. Currently Manakin does not have a separate use for 
        detailList on items, so the logic of summaryList is used in its place. --> 
	<xsl:template name="itemDetailList-DIM">
		<!-- Generate the info about the item from the metadata section -->
		<xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim" mode="itemSummaryList-DIM"/>
		<!-- Generate the thunbnail, if present, from the file section -->
		<xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"/>
	</xsl:template>

	<!-- A collection rendered in the detailList pattern. Encountered on the item view page as the "this item is part of these collections" list -->
	<xsl:template name="collectionDetailList-DIM">
		<xsl:variable name="data" select="./mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
		<a href="{@OBJID}/discover">
			<xsl:choose>
				<xsl:when test="string-length($data/dim:field[@element='title'][1]) &gt; 0">
					<xsl:value-of select="$data/dim:field[@element='title'][1]"/>
				</xsl:when>
				<xsl:otherwise>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
				</xsl:otherwise>
			</xsl:choose>
		</a>
		<!--Display collection strengths (item counts) if they exist-->
		<xsl:if test="string-length($data/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
			<xsl:text> [</xsl:text>
			<xsl:value-of select="$data/dim:field[@element='format'][@qualifier='extent'][1]"/>
			<xsl:text>]</xsl:text>
		</xsl:if>
		<br/>
		<xsl:choose>
			<xsl:when test="$data/dim:field[@element='description' and @qualifier='abstract']">
				<xsl:copy-of select="$data/dim:field[@element='description' and @qualifier='abstract']/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$data/dim:field[@element='description'][1]/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- A community rendered in the detailList pattern. Not currently used. -->
	<xsl:template name="communityDetailList-DIM">
		<xsl:variable name="data" select="./mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
		<span class="bold">
			<a href="{@OBJID}/discover">
				<xsl:choose>
					<xsl:when test="string-length($data/dim:field[@element='title'][1]) &gt; 0">
						<xsl:value-of select="$data/dim:field[@element='title'][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<!--Display community strengths (item counts) if they exist-->
			<xsl:if test="string-length($data/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
				<xsl:text> [</xsl:text>
				<xsl:value-of select="$data/dim:field[@element='format'][@qualifier='extent'][1]"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
			<br/>
			<xsl:choose>
				<xsl:when test="$data/dim:field[@element='description' and @qualifier='abstract']">
					<xsl:copy-of select="$data/dim:field[@element='description' and @qualifier='abstract']/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$data/dim:field[@element='description'][1]/node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<!-- 
        The summaryView display type; used to generate a near-complete view of the item involved. It is currently
        not applicable to communities and collections. 
    -->
	<xsl:template match="mets:METS[mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']]" mode="summaryView">
		<xsl:choose>
			<xsl:when test="@LABEL='DSpace Item'">
				<xsl:call-template name="itemSummaryView-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Collection'">
				<xsl:call-template name="collectionSummaryView-DIM"/>
			</xsl:when>
			<xsl:when test="@LABEL='DSpace Community'">
				<xsl:call-template name="communitySummaryView-DIM"/>
			</xsl:when>                
			<xsl:otherwise>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.non-conformant</i18n:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- An item rendered in the summaryView pattern. This is the default way to view a DSpace item in Manakin. -->
	<xsl:template name="itemSummaryView-DIM">
		<xsl:variable name="dimPath" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"/>
		<xsl:variable name="fileSecPath" select="./mets:fileSec"/>
		<xsl:variable name="internalID" select="ancestor::mets:METS/@ID"/>
		<xsl:variable name="urnprefix">http://nbn-resolving.de/</xsl:variable>
		<xsl:variable name="itemWithdrawn" select="@withdrawn" /> 
		<xsl:variable name="resourceID">
			<xsl:choose>
				<xsl:when test="$itemWithdrawn">
					<xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ancestor::mets:METS/@OBJID" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		<xsl:variable name="urn">
			<xsl:value-of select="$dimPath/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
		</xsl:variable>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzaaaaaaaceeeeiiiidnoooooouuuuy_yzsoaouß'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒäöüß'" />
		<xsl:variable name="journal" select="//dim:field[@element='source' and @qualifier='journal']"/>
		<xsl:variable name="acronym" select="statics:getJournalTitleAcronym($journal)"/>

		<xsl:variable name="filepath">
			<!-- e.g. filepath == '/xmlui/bitstream/handle/document/39309/ssoar-2007-wittenberg_et_al-Lebensqualitat_Kommunalpolitik_und_Kommunalwahlen_in.pdf?sequence=1&isAllowed=y' -->
			<!--<xsl:value-of select="$fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>-->
			<xsl:if test="//dim:field[@element='identifier' and @qualifier='urn']">
				<xsl:if test="contains(//dim:field[@element='identifier' and @qualifier='urn'],'ssoar')">
					<xsl:value-of select="concat( substring-before(/mets:METS/@OBJID, 'handle'), 'bitstream/handle', substring-after(/mets:METS/@OBJID, 'handle'), '/ssoar' )"/>
					<xsl:if test="string-length($acronym) &gt; 0">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="$acronym"/>
					</xsl:if>
					<xsl:if test="string-length(//dim:field[@element='date' and @qualifier='issued']) &gt; 0">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="//dim:field[@element='date' and @qualifier='issued']"/>
					</xsl:if>
					<xsl:if test="string-length(//dim:field[@element='source' and @qualifier='issue']) &gt; 0">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="//dim:field[@element='source' and @qualifier='issue']"/>
					</xsl:if>
					<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='recension'">
						<xsl:text>-rez</xsl:text>
					</xsl:if>
					<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='collection')">
						<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='author'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
							<xsl:text>-</xsl:text>
							<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='author']">
								<xsl:if test="position()=1">
									<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
								</xsl:if>
								<xsl:if test="position()=2">
									<xsl:text>_et_al</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:if>
					</xsl:if>
					<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='collection'">
						<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='editor'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
							<xsl:text>-</xsl:text>
							<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='editor']">
								<xsl:if test="position()=1">
									<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
								</xsl:if>
								<xsl:if test="position()=2">
									<xsl:text>_et_al</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:if>
					</xsl:if>
					<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='recension')">
						<xsl:choose>
							<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),':')">
								<xsl:text>-</xsl:text>
								<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),':'),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
							</xsl:when>
							<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - ')">
								<xsl:text>-</xsl:text>
								<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - '),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>-</xsl:text>
								<xsl:value-of select="substring(translate(translate(//dim:field[@element='title'][not(@qualifier)][1]/node(),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:value-of select="substring-after($fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href,'pdf')"/>
				</xsl:if>
				<xsl:if test="not(contains(//dim:field[@element='identifier' and @qualifier='urn'],'ssoar'))">
					<xsl:value-of select="$dimPath/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
				</xsl:if>
			</xsl:if>
			<xsl:if test="not(//dim:field[@element='identifier' and @qualifier='urn'])">
				<xsl:if test="contains(//mets:FLocat[@LOCTYPE='URL']/@xlink:href,'ssoar')">
					<xsl:if test="//mets:METS/@OBJID">
						<xsl:value-of select="concat( substring-before(/mets:METS/@OBJID, 'handle'), 'bitstream/handle', substring-after(/mets:METS/@OBJID, 'handle'), '/ssoar' )"/>
						<xsl:if test="string-length($acronym) &gt; 0">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="$acronym"/>
						</xsl:if>
						<xsl:if test="string-length(//dim:field[@element='date' and @qualifier='issued']) &gt; 0">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="//dim:field[@element='date' and @qualifier='issued']"/>
						</xsl:if>
						<xsl:if test="string-length(//dim:field[@element='source' and @qualifier='issue']) &gt; 0">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="//dim:field[@element='source' and @qualifier='issue']"/>
						</xsl:if>
						<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='recension'">
							<xsl:text>-rez</xsl:text>
						</xsl:if>
						<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='collection')">
							<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='author'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
								<xsl:text>-</xsl:text>
								<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='author']">
									<xsl:if test="position()=1">
										<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
									</xsl:if>
									<xsl:if test="position()=2">
										<xsl:text>_et_al</xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:if>
						<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='collection'">
							<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='editor'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
								<xsl:text>-</xsl:text>
								<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='editor']">
									<xsl:if test="position()=1">
										<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
									</xsl:if>
									<xsl:if test="position()=2">
										<xsl:text>_et_al</xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:if>
						<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='recension')">
							<xsl:choose>
								<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),':')">
									<xsl:text>-</xsl:text>
									<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),':'),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
								</xsl:when>
								<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - ')">
									<xsl:text>-</xsl:text>
									<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - '),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>-</xsl:text>
									<xsl:value-of select="substring(translate(translate(//dim:field[@element='title'][not(@qualifier)][1]/node(),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:value-of select="substring-after($fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href,'pdf')"/>
					</xsl:if>
					<xsl:if test="not(//mets:METS/@OBJID)">
						<!--<xsl:value-of select="concat($protocol, 'www.ssoar.info')"/>-->
						<xsl:value-of select="//mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="not(contains(//mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href,'ssoar'))">
					<xsl:if test="string-length(//mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href) &lt;= 1">
						<xsl:text>keine Datei vorhanden</xsl:text>
					</xsl:if>
					<xsl:if test="string-length(//mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href) &gt; 1">
						<xsl:value-of select="//mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
					</xsl:if>
				</xsl:if>
</xsl:if>
	</xsl:variable>
	<!--  end filepath definition -->

	<xsl:variable name="filename">
		<!--<xsl:value-of select="$fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>-->
		<xsl:if test="not(//dim:field[@element='identifier' and @qualifier='url'])">
			<xsl:text>ssoar</xsl:text>
			<xsl:if test="string-length($acronym) &gt; 0">
				<xsl:text>-</xsl:text>
				<xsl:value-of select="$acronym"/>
			</xsl:if>
			<xsl:if test="string-length(//dim:field[@element='date' and @qualifier='issued']) &gt; 0">
				<xsl:text>-</xsl:text>
				<xsl:value-of select="//dim:field[@element='date' and @qualifier='issued']"/>
			</xsl:if>
			<xsl:if test="string-length(//dim:field[@element='source' and @qualifier='issue']) &gt; 0">
				<xsl:text>-</xsl:text>
				<xsl:value-of select="//dim:field[@element='source' and @qualifier='issue']"/>
			</xsl:if>
			<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='recension'">
				<xsl:text>-rez</xsl:text>
			</xsl:if>
			<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='collection')">
				<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='author'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
					<xsl:text>-</xsl:text>
					<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='author']">
						<xsl:if test="position()=1">
							<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
						</xsl:if>
						<xsl:if test="position()=2">
							<xsl:text>_et_al</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</xsl:if>
			<xsl:if test="//dim:field[@element='type' and @qualifier='stock']='collection'">
				<xsl:if test="string-length(substring(normalize-space(translate(substring-before(//dim:field[@element='contributor' and @qualifier='editor'],','),$uppercase,$smallcase)),1,29)) &gt; 0">
					<xsl:text>-</xsl:text>
					<xsl:for-each select="//dim:field[@element='contributor' and @qualifier='editor']">
						<xsl:if test="position()=1">
							<xsl:value-of select="substring(normalize-space(translate(substring-before(./node(),','),$uppercase,$smallcase)),1,29)"/>
						</xsl:if>
						<xsl:if test="position()=2">
							<xsl:text>_et_al</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</xsl:if>
			<xsl:if test="not(//dim:field[@element='type' and @qualifier='stock']='recension')">
				<xsl:choose>
					<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),':')">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),':'),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
					</xsl:when>
					<xsl:when test="contains(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - ')">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring(translate(translate(substring-before(//dim:field[@element='title'][not(@qualifier)][1]/node(),' - '),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring(translate(translate(//dim:field[@element='title'][not(@qualifier)][1]/node(),' ','_'),'&#x22;/\#%!@$()&amp;?',''),'1','100')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
		<xsl:if test="//dim:field[@element='identifier' and @qualifier='url']">
			<xsl:value-of select="$fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
		</xsl:if>
	</xsl:variable>
	<!-- end filename definition -->

	<xsl:variable name="fileuri">
		
		<xsl:choose>
			<xsl:when test="contains($filepath, 'http')"><xsl:value-of select="$filepath"/></xsl:when>
			<xsl:when test="not(contains($filepath, 'http')) and (contains($filepath, 'urn:nbn'))">
				<xsl:value-of select="concat($urnprefix, $filepath)"/>
			</xsl:when>
			<xsl:when test="not(contains($filepath, 'http')) and (contains($filepath, '10.'))">
				<xsl:value-of select="concat('http://dx.doi.org/', $filepath)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($protocol, 'www.ssoar.info', $filepath)"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:variable>

	<xsl:variable name="filesize">
		<xsl:value-of select="round($fileSecPath/mets:fileGrp[@USE='CONTENT']/mets:file/@SIZE div 1024)"/>
	</xsl:variable>

	<xsl:variable name="withdrawn">
		<xsl:if test="$dimPath[@withdrawn='y']">
			<xsl:value-of select="true()"/>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="embargoDate">
		<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='embargo' and @qualifier='liftdate']/text()"/>
	</xsl:variable>
	<xsl:variable name="embargoYear" select="substring-before($embargoDate,'-')"/>
	<xsl:variable name="embargoMonth" select="substring-before(substring-after($embargoDate,'-'),'-')"/>
	<xsl:variable name="embargoDay" select="substring-after(substring-after($embargoDate,'-'),'-')"/>

	<xsl:variable name="embargoActive">
		<xsl:choose>
			<xsl:when test="number($curYear) &lt; number($embargoYear)">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="number($curYear) = number($embargoYear)">
				<xsl:choose>
					<xsl:when test="number($curMonth) &lt; number($embargoMonth)">
						<xsl:value-of select="true()"/>        
					</xsl:when>
					<xsl:when test="number($curMonth) = number($embargoMonth)">
						<xsl:if test="number($curDay) &lt;= number($embargoDay)">
							<xsl:value-of select="true()"/>    
						</xsl:if>                            
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<!-- debugging embargo-date
       <ul>
            <li><xsl:value-of select="$curYear"/></li>
            <li><xsl:value-of select="$curMonth"/></li>
            <li><xsl:value-of select="$curDay"/></li>
            <li><xsl:value-of select="$embargoYear"/></li>
            <li><xsl:value-of select="$embargoMonth"/></li>
            <li><xsl:value-of select="$embargoDay"/></li>
            <li><xsl:value-of select="$embargoActive"/></li>
        </ul>
        -->
	<xsl:if test="$workflow = 'true' or $withdrawn = 'true'">
		<h1 class="div-head doc-title">
			<xsl:value-of select="$dimPath/dim:field[@element='title' and not(@qualifier)]"/>
		</h1>
	</xsl:if>

	<div class="tranlationDocument">
		<xsl:if test="$dimPath/dim:field[@mdschema='dc' and @element='title' and @qualifier='alternative']/text()!=''"> 
			<xsl:for-each select="$dimPath/dim:field[@mdschema='dc' and @element='title' and @qualifier='alternative']">
				<div class="altTitle">
					<em>
						<xsl:value-of select="./text()"/>
					</em>
				</div>
			</xsl:for-each>

			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']/text()!=''">
			<span class="documentType">
				<xsl:text> [</xsl:text>
				<i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']/text()"/>
				</i18n:text>
				<xsl:text>]</xsl:text>
			</span>
		</xsl:if>
	</div>   

	<h2>
		<div>
			<xsl:choose>
				<xsl:when test="$dimPath/dim:field[@element='type' and @qualifier='stock'] = 'collection'">
					<xsl:if test="$dimPath/dim:field[@element='contributor' and @qualifier='editor'] != ''">                   
						<xsl:for-each select="$dimPath/dim:field[@element='contributor' and @qualifier='editor']">
							<xsl:value-of select="./text()"/>
							<xsl:if test="position()!=last()">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<xsl:text> (</xsl:text>
						<i18n:text>xmlui.ssoar.labels.editorshort</i18n:text>
						<xsl:text>)</xsl:text>
					</xsl:if>     
				</xsl:when>
				<xsl:otherwise>

					<xsl:if test="$dimPath/dim:field[@element='contributor' and @qualifier='author'] != ''">
						<xsl:for-each select="$dimPath/dim:field[@element='contributor' and @qualifier='author']">
							<xsl:value-of select="./text()"/>
							<xsl:if test="position()!=last()">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</h2>
	<xsl:if test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='recension'">
		<div>
			<xsl:call-template name="recensionSource">
				<xsl:with-param name="dimNode" select="$dimPath"/>
			</xsl:call-template>
		</div>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="$embargoActive='true'">
			<xsl:call-template name="displayEmbargo">
				<xsl:with-param name="date" select="$embargoDate"/>
			</xsl:call-template>
		</xsl:when>
		<!-- don't display download for withdrawn items -->
		<xsl:when test="$withdrawn = 'true'">
			<div style="margin-top:1em">
				<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon-embargo.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
				<xsl:comment>withdrawn</xsl:comment>
				<p>
					<xsl:choose>
						<xsl:when
                                test="$dimPath/dim:field[@mdschema='internal' and @element='withdrawn' and @qualifier='date']/text()!=''">
							<i18n:text>xmlui.ssoar.labels.withdrawn.date.start</i18n:text>
							<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='withdrawn' and @qualifier='date']/text()"/>
							<i18n:text>xmlui.ssoar.labels.withdrawn.date.end</i18n:text>
						</xsl:when>
						<xsl:otherwise>
							<i18n:text>xmlui.ssoar.labels.withdrawn.nodate</i18n:text>
						</xsl:otherwise>
					</xsl:choose>

				</p>
			</div>
		</xsl:when>
		<xsl:when test="$filepath!='' and $embargoActive!='true'">
			<div style="margin-top:1em">
			<xsl:choose>
				<xsl:when test="contains($filepath,'keine Datei vorhanden')">
						<a >
							<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text>
						</a>
				</xsl:when>
				<xsl:when test="contains($filepath,'dx.doi.org')">
				<a target="_blank" href="http://www.etracker.de/lnkcnt.php?et=qPKGYV&amp;url={$filepath}&amp;lnkname={$filename}">
					<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
					<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
				</a>
				</xsl:when>
				<xsl:when test="contains($filepath,'urn:nbn')">
					<xsl:if test="contains($filepath,'http')">
						<a target="_blank" href="http://www.etracker.de/lnkcnt.php?et=qPKGYV&amp;url={$filepath}&amp;lnkname={$filename}">
						<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
						<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
						</a>
					</xsl:if>
					<xsl:if test="not(contains($filepath,'http'))">
						<a target="_blank" href="http://www.etracker.de/lnkcnt.php?et=qPKGYV&amp;url={$urnprefix}{$filepath}&amp;lnkname={$filename}">
						<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
						<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
						</a>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
				<a target="_blank" href="http://www.etracker.de/lnkcnt.php?et=qPKGYV&amp;url={$fileuri}&amp;lnkname={$filename}">
						<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
						<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
						</a>
				</xsl:otherwise>
				</xsl:choose>
				<!-- FileSize -->
				<p>
					<xsl:choose>
						<xsl:when test="$filesize > 0">
							<xsl:text> (</xsl:text>
							<xsl:value-of select="$filesize"/>
							<xsl:text> KByte)</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="contains($filepath, 'keine Datei vorhanden')">
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if test="not(contains($filepath, 'keine Datei vorhanden')) and not(contains($filepath, 'ssoar'))">
								<i18n:text>xmlui.ssoar.labels.externalSource</i18n:text>
							</xsl:if>
							<!--<i18n:text>xmlui.ssoar.labels.noFileSizeInfo</i18n:text>-->
						</xsl:otherwise>
					</xsl:choose>
				</p>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<!-- Wenn es eine PID gibt, diese bevorzugen -->
				<xsl:when test="not(./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()='')">

					<div style="margin-top:1em">
						<a target="_blank">
							<xsl:attribute name="href">
								<xsl:if test="contains($urn,'urn:')">
									<xsl:if test="not(contains($urn,'http://nbn-resolving.de'))">
										<xsl:value-of select="$urnprefix"/>
									</xsl:if>
								</xsl:if>
								<xsl:value-of select="$urn"/>
							</xsl:attribute>
							<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" align="left" style="margin-right:2em;"/>
							<i18n:text>xmlui.ssoar.labels.downloadFulltext</i18n:text>
						</a>
						<p>
							<xsl:text> (</xsl:text>
							<i18n:text>xmlui.ssoar.labels.externalSource</i18n:text>
							<xsl:text>)</xsl:text>
						</p>
					</div>
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>			
	</xsl:choose>

	<!-- display error table of pdf is not consistent in any way -->
	<xsl:if test="$workflow = 'true' and ($dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='valid']/text() != 'true'
            or $dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='wellformed']/text() != 'true'
            or $dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='ocr'] != ''
            or $dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='encrypted']/text() = 'true'
            or $dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='restrictions'] != '')">

		<table id="pdf_results">
			<tr>
				<th>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='ocr']/text()!=''">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:text>OCR</xsl:text>
				</th>
				<th>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='valid']/text() != 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:text>valid</xsl:text>
				</th>
				<th>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='wellformed']/text() != 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:text>well-formed</xsl:text>
				</th>

				<!-- ecncryption and security check -->
				<th>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='encrypted']/text() = 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:text>encrypted</xsl:text>
				</th>
				<th>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='restrictions']/text() != ''">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:text>restrictions</xsl:text>
				</th>
			</tr>
			<tr>
				<td>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='ocr']/text()!=''">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<ul>
						<xsl:call-template name="displayErrors">
							<xsl:with-param name="message">                                    
								<xsl:value-of
                                        select="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='ocr']/text()"/>
							</xsl:with-param>
							<xsl:with-param name="delimiter">page_</xsl:with-param>
						</xsl:call-template>
					</ul>
				</td>
				<td>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='valid']/text() != 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='valid']/text()"/>
				</td>
				<td>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='wellformed']/text() != 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='wellformed']/text()"/>                        
				</td>

				<!-- ecncryption and security check -->
				<td>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='encrypted']/text() = 'true'">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='encrypted']/text()"/>
				</td>

				<td>
					<xsl:if test="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='restrictions']/text()!=''">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<ul>
						<xsl:call-template name="displayErrors">
							<xsl:with-param name="message">
								<xsl:value-of
                                        select="$dimPath/dim:field[@mdschema='internal' and @element='pdf' and @qualifier='restrictions']/text()"/>
							</xsl:with-param>
							<xsl:with-param name="delimiter"> - </xsl:with-param>
						</xsl:call-template>
					</ul>
				</td>

			</tr>
		</table>

	</xsl:if>

	<xsl:if test="$withdrawn != 'true'">
		<!-- insertt citation reference -->
		<xsl:call-template name="citationInfo">
			<xsl:with-param name="urn" select="$urn"/>
		</xsl:call-template>   
	</xsl:if>		

	<h5 style="margin-top:2em;">
		<i18n:text>xmlui.ssoar.labels.furtherDetails</i18n:text>
	</h5>
	<table class="resultTableCellResourceContent">

		<!-- Restliche Tabellenzeilen an Schema F -->		   
		<xsl:call-template name="metadataTable">
			<xsl:with-param name="dimPath" select="$dimPath"/>
		</xsl:call-template>	
		<!-- insert reference to cooperation partners (USB/DFG)-->
		<xsl:call-template name="sourceReference">
			<xsl:with-param name="dimPath" select="$dimPath"/>
		</xsl:call-template>		    
	</table>        
	<div align="right">
		<a href="#header">top</a>
	</div>     

	<!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
	<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']"/>

</xsl:template>

<!-- display error message of pdf analyzation results -->
<xsl:template name="displayErrors">
	<xsl:param name="message"/>
	<xsl:param name="delimiter"/>
	<xsl:variable name="curError">
		<xsl:value-of select="substring-before($message,$delimiter)"/>
	</xsl:variable>
	<xsl:variable name="rest">
		<xsl:value-of select="substring-after($message,$delimiter)"/>
	</xsl:variable>
	<xsl:if test="$curError!=''">
		<li> 
			<xsl:value-of select="translate($curError,' ','')"/>
		</li>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="contains($rest,$delimiter)">
			<xsl:call-template name="displayErrors">
				<xsl:with-param name="message">
					<xsl:value-of select="substring-after($message,$delimiter)"/>
				</xsl:with-param>
				<xsl:with-param name="delimiter" select="$delimiter"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<li> 
				<xsl:value-of select="translate($rest,' ','')"/>
			</li>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="metadataTable">
	<xsl:param name="dimPath"/>
	<xsl:choose>
		<!-- Monografien -->
		<xsl:when test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='monograph'">
			<xsl:call-template name="generaterows">
				<xsl:with-param name="dimnode" select="$dimPath"/>
				<xsl:with-param name="metadatalist">
                        dc.contributor.corporateeditor;	
                        dc.description.abstract;
                        dc.subject.thesoz;
                        internal.identifier.classoz;
                        internal.identifier.methods;
                        dc.subject.other;
                        dc.source.conference;
                        dc.language;
                        dc.date.issued;
                        dc.source.edition;
                        dc.publisher;
                        dc.publisher.city;
                        dc.source.pageinfo;
                        dc.source.series;<!-- Volume is added automatically -->
                        dc.identifier.doi;
                        dc.identifier.issn;
                        dc.identifier.isbn;
                        internal.identifier.review;	<!-- pubstatus is added automatically -->
                        internal.identifier.licence;
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<!-- Sammelwerke -->
		<xsl:when test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='collection'">
			<xsl:call-template name="generaterows">
				<xsl:with-param name="dimnode" select="$dimPath"/>
				<xsl:with-param name="metadatalist">
                        dc.contributor.corporateeditor;
                        dc.description.abstract;
                        dc.subject.thesoz;
                        internal.identifier.classoz;
                        internal.identifier.methods;
                        dc.subject.other;
                        dc.source.conference;
                        dc.language;
                        dc.date.issued;
                        dc.source.edition;
                        dc.publisher;
                        dc.publisher.city;
                        dc.source.pageinfo;
                        dc.source.series;<!-- Volume is added automatically -->
                        dc.identifier.doi;
                        dc.identifier.issn;
                        dc.identifier.isbn;
                        internal.identifier.review;	<!-- pubstatus is added automatically -->
                        internal.identifier.licence;
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<!-- Beitrag in einem Sammelwerk -->
		<xsl:when test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='incollection'">
			<xsl:call-template name="generaterows">
				<xsl:with-param name="dimnode" select="$dimPath"/>
				<xsl:with-param name="metadatalist">
                        dc.contributor.corporateeditor;	
                        dc.description.abstract;
                        dc.subject.thesoz;
                        internal.identifier.classoz;
                        internal.identifier.methods;
                        dc.subject.other;
                        dc.source.collection;
                        dc.contributor.editor;
                        dc.source.conference;
                        dc.language;
                        dc.date.issued;
                        dc.publisher;
                        dc.publisher.city;
                        dc.source.pageinfo;
                        dc.source.series;
                        dc.identifier.doi;
                        dc.identifier.issn;
                        dc.identifier.isbn;
                        internal.identifier.review;	<!-- pubstatus is added automatically -->
                        internal.identifier.licence;
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<!-- Beitrag in einer Zeitschrift -->
		<xsl:when test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='article'">
			<xsl:call-template name="generaterows">
				<xsl:with-param name="dimnode" select="$dimPath"/>
				<xsl:with-param name="metadatalist">
                        dc.description.abstract;
                        dc.subject.thesoz;
                        internal.identifier.classoz;
                        internal.identifier.methods;
                        dc.subject.other;
                        dc.source.conference;
                        dc.language;
                        dc.date.issued;
                        dc.source.pageinfo;
                        dc.source.journal;<!-- issue and volume are added automatically -->
                        dc.source.issuetopic;
                        dc.identifier.doi;
                        dc.identifier.issn;
                        internal.identifier.review;	<!-- pubstatus is added automatically -->
                        internal.identifier.licence;
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<!-- Rezensionen -->
		<xsl:when test="$dimPath/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='recension'">
			<xsl:call-template name="generaterows">
				<xsl:with-param name="dimnode" select="$dimPath"/>
				<xsl:with-param name="metadatalist">
                        dc.description.abstract;
                        dc.subject.thesoz;
                        internal.identifier.classoz;
                        internal.identifier.methods;
                        dc.subject.other;
                        dc.language;
                        dc.date.issued;
                        dc.source.pageinfo;
                        dc.source.journal;<!-- issue and volume are added automatically -->
                        dc.identifier.doi;
                        dc.identifier.issn;
                        internal.identifier.review;	<!-- pubstatus is added automatically -->
                        internal.identifier.licence;
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="sourceReference">
	<xsl:param name="dimPath"/>
	<xsl:choose>
		<xsl:when test="contains($dimPath/dim:field[@mdschema='ssoar' and @element='contributor' and @qualifier='institution']/text(),'USB Köln')">
			<tr>
				<td class="resourceDetailTableCellLabel">
					<i18n:text>xmlui.ssoar.labels.data.source</i18n:text>
				</td>
				<td class="resourceDetailTableCellValue">
					<i18n:text>xmlui.ssoar.labels.data.source.usb</i18n:text>
				</td>
			</tr>
		</xsl:when>	
		<xsl:when test="$dimPath/dim:field[@mdschema='ssoar' and @element='licence' and @qualifier='dfg']='true'">
			<tr>
				<td class="resourceDetailTableCellLabel">
					<!--<i18n:text>xmlui.ssoar.labels.data.source</i18n:text>-->
				</td>
				<td class="resourceDetailTableCellValue">
					<i18n:text>xmlui.ssoar.labels.data.source.dfg</i18n:text>
				</td>
			</tr>
		</xsl:when>	
		<xsl:when test="contains($dimPath/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']/text(), 'Berichte für das Bundespresseamt')">
			<tr>
				<td class="resourceDetailTableCellLabel">
					<i18n:text>xmlui.ssoar.labels.data.principal</i18n:text>
				</td>
				<td class="resourceDetailTableCellValue">
                            Bundesregierung der Bundesrepublik Deutschland
				</td>
			</tr>
		</xsl:when> 
	</xsl:choose>
</xsl:template>

<xsl:template name="citationInfo">
	<xsl:param name="urn"/>
	<h5 style="margin-top:2em;">
		<i18n:text>xmlui.ssoar.labels.citationInfo</i18n:text>
	</h5>
	<p>
		<i18n:text>xmlui.ssoar.labels.citationText</i18n:text>
		<xsl:choose>
			<!--
				<xsl:variable name="urn">
					<xsl:value-of select="//Attribute[@label='urn']/AttributeValue/AttributeComponent/text()"/>
				</xsl:variable>-->
			<!-- Wenn es eine PID gibt, die KEINE URN ist, dann gebe diese einfach aus -->
			<xsl:when test="not(contains($urn,'urn:')) and $urn!=''">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$urn"/>
					</xsl:attribute>
					<xsl:value-of select="$urn"/>
				</a>
			</xsl:when>
			<!-- Wenn es eine URN ist, den Resolver davorschreiben! -->
			<xsl:otherwise>
				<a>	
					<xsl:attribute name="href">
						<xsl:if test="not(contains($urn,'http://nbn-resolving.de'))">
							<xsl:text>http://nbn-resolving.de/</xsl:text>
						</xsl:if>
						<xsl:value-of select="$urn"/>
					</xsl:attribute>
					<xsl:if test="not(contains($urn,'http://nbn-resolving.de'))">
						<xsl:text>http://nbn-resolving.de/</xsl:text>
					</xsl:if>
					<xsl:value-of select="$urn"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</p>
</xsl:template>

<xsl:template name="generaterows">
	<xsl:param name="dimnode"/>
	<xsl:param name="metadatalist"/>
	<xsl:variable name="metadatafield" select="translate(substring-before($metadatalist,';'), '&#x20;&#x9;&#xD;&#xA;', '')"/>

	<xsl:if test="not($metadatafield='')">            
		<xsl:variable name="elementqualifier" select="substring-after($metadatafield, '.')"/>
		<xsl:variable name="mdschema" select="substring-before($metadatafield,'.')"/>  

		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="contains($elementqualifier,'.')">
					<xsl:value-of select="substring-before($elementqualifier,'.')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$elementqualifier"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="qualifier" select="substring-after($elementqualifier,'.')"/>

		<xsl:call-template name="generaterow">
			<xsl:with-param name="dimnode" select="$dimnode"/>
			<xsl:with-param name="mdschema" select="$mdschema"/>
			<xsl:with-param name="element" select="$element"/>
			<xsl:with-param name="qualifier" select="$qualifier"/>
		</xsl:call-template>

		<xsl:call-template name="generaterows">
			<xsl:with-param name="dimnode" select="$dimnode"/>
			<xsl:with-param name="metadatalist">
				<xsl:value-of select="substring-after($metadatalist, ';')"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="generaterow">
	<xsl:param name="dimnode"/>
	<xsl:param name="mdschema"/>
	<xsl:param name="element"/>
	<xsl:param name="qualifier"/>

	<xsl:variable name="test">
		<xsl:choose>
			<xsl:when test="$qualifier!=''">
				<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]/text()!=''">
					<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]/text()"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$qualifier=''">
				<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element]/text()!=''">                        
					<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element]/text()"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'leer'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="nodeexists">
		<xsl:choose>
			<xsl:when test="$qualifier!=''">
				<xsl:choose>
					<xsl:when test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]/text()!=''">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>  
			</xsl:when>
			<xsl:when test="$qualifier=''">
				<xsl:choose>
					<xsl:when test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and not(@qualifier)]/text()!=''">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<!-- IF there is no status information status is skipped -->
	<xsl:variable name="noPubStatusInfo">
		<xsl:choose>
			<xsl:when test="$qualifier ='review' and $dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='pubstatus']/text()='4'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:variable>

	<!-- IF there is no status information status is skipped -->
	<xsl:variable name="noReviewInfo">
		<xsl:choose>
			<xsl:when test="$qualifier ='review' and $dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='review']/text()='4'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:variable>

	<xsl:if test="$nodeexists='true' and ($noPubStatusInfo='false' or $noReviewInfo='false')">
		<tr>
			<td class="resourceDetailTableCellLabel">
				<xsl:choose>
					<xsl:when test="$qualifier=''">
						<i18n:text>xmlui.ssoar.metadata.<xsl:value-of select="$mdschema"/>.<xsl:value-of select="$element"/>
						</i18n:text>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.ssoar.metadata.<xsl:value-of select="$mdschema"/>.<xsl:value-of select="$element"/>.<xsl:value-of select="$qualifier"/>
						</i18n:text>    
					</xsl:otherwise>
				</xsl:choose>
			</td>                
			<td class="resourceDetailTableCellValue">
				<xsl:choose>
					<!-- Abstracts -->
					<xsl:when test="$mdschema='dc' and $element='description' and $qualifier = 'abstract'">
						<xsl:for-each select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]">                                
							<!--<em>
                                    <xsl:value-of select="@language"/> <xsl:text>:</xsl:text><br/>
                                </em>  -->                              
							<xsl:value-of select="./text()"/>  
							<xsl:if test="position()!=last()">
								<br/>
								<br/>
							</xsl:if>                                
						</xsl:for-each>
					</xsl:when>
					<!-- Series and journal -->
					<xsl:when test="$mdschema='dc' and $element='source' and ( $qualifier = 'journal' or $qualifier = 'series' )">
						<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]"/>
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='volume']/text()!=''">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='volume']/text()"/>
						</xsl:if>
						<xsl:if test="$qualifier = 'journal'">
							<xsl:if test="$dimnode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
								<xsl:text> (</xsl:text>
								<xsl:value-of select="$dimnode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
								<xsl:text>) </xsl:text>
							</xsl:if>

							<xsl:if test="$dimnode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
								<xsl:value-of select="$dimnode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']/text()"/>
							</xsl:if>
						</xsl:if>
					</xsl:when>
					<!-- reviewing and publication status -->
					<xsl:when test="$mdschema='internal' and $element='identifier' and $qualifier = 'review'">       
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='pubstatus']/text()!='' and $noPubStatusInfo='false'">                                
							<i18n:text>xmlui.ssoar.convoc.<xsl:value-of select="'pubstatus'"/>.<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='pubstatus']/text()"/>
							</i18n:text>
							<xsl:if test="$noReviewInfo='false'">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:if>
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='review']/text()!='' and $noReviewInfo='false'">
							<i18n:text>xmlui.ssoar.convoc.<xsl:value-of select="$qualifier"/>.<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='review']/text()"/>
							</i18n:text>
						</xsl:if>
					</xsl:when>
					<!-- language -->
					<xsl:when test="$mdschema='dc' and $element='language' and not($qualifier)">       
						<i18n:text>xmlui.ssoar.convoc.<xsl:value-of select="$element"/>.<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element]/text()"/>
						</i18n:text>                            
					</xsl:when>
					<!-- Conference -->
					<xsl:when test="$mdschema='dc' and $element='source' and $qualifier = 'conference'"> 
						<!-- ConferenceNumber -->
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='conferencenumber']/text()!=''">                                
							<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier='conferencenumber']/text()"/>
							<xsl:text>. </xsl:text>
						</xsl:if>
						<!-- ConferenceName -->
						<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]"/>
						<!-- ConferenceCity -->
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element='event' and @qualifier='city']/text()!=''">                                
							<xsl:text>. </xsl:text>
							<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element='event' and @qualifier='city']/text()"/>
						</xsl:if>  
						<!-- ConferenceYear -->
						<xsl:if test="$dimnode/dim:field[@mdschema=$mdschema and @element='date' and @qualifier='conference']/text()!=''">                                
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element='date' and @qualifier='conference']/text()"/>
						</xsl:if>  
					</xsl:when>
					<!-- Pageinfo -->
					<xsl:when test="$mdschema='dc' and $element='source' and $qualifier='pageinfo'">
						<xsl:call-template name="pageinfo">
							<xsl:with-param name="pageinfo" select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]/text()"/>
						</xsl:call-template>                                                        
					</xsl:when>

					<xsl:when test="$mdschema='dc' and $element='identifier' and $qualifier='doi'">
						<xsl:variable name="doi">
							<xsl:value-of select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]/text()"/>
						</xsl:variable>
						<a href="{$doi}">
							<xsl:value-of select="$doi"/>
						</a>                                              
					</xsl:when>

					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$qualifier=''">
								<xsl:for-each select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and not(@qualifier)]">                
									<xsl:value-of select="./text()"/>
									<xsl:if test="not(position()=last())">
										<xsl:text>; </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="$mdschema='dc' and $element='subject' and $qualifier='thesoz'">
								<xsl:for-each select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier and (@language=$languageiso )]">                                        
									<xsl:variable name="filterLink">
										<xsl:value-of select="./text()"/>
										<!--<xsl:call-template name="getDiscoveryFilter">
                                                <xsl:with-param name="queryString" select="./text()"/>
                                            </xsl:call-template>-->
									</xsl:variable>
									<!--<a href="{$context-path}/discover?fq=thesoz_filter{$filterLink}">-->                                        
									<a href="{$context-path}/discover?filtertype=thesoz&amp;filter_relational_operator=equals&amp;filter={$filterLink}">
										<xsl:value-of select="./text()"/>                                                     
									</a>
									<xsl:if test="not(position()=last())">
										<xsl:text>; </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$dimnode/dim:field[@mdschema=$mdschema and @element=$element and @qualifier=$qualifier]">                
									<xsl:choose>
										<!--<xsl:when test="$mdschema='dc' and $element='subject' and $qualifier='thesoz'">
                                                <xsl:if test="@language=$language">                                                    
                                                    <xsl:variable name="filterLink">
                                                        <xsl:call-template name="getDiscoveryFilter">
                                                            <xsl:with-param name="queryString" select="./text()"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    <a href="{$context-path}/discover?fq=thesoz_filter{$filterLink}">  
                                                        <xsl:value-of select="./text()"/>                                                     
                                                    </a>
                                                </xsl:if>   
                                            </xsl:when>-->
										<xsl:when test="$mdschema='internal' and $element='identifier'">
											<i18n:text>xmlui.ssoar.convoc.<xsl:value-of select="$qualifier"/>.<xsl:value-of select="./text()"/>
											</i18n:text>
										</xsl:when>                                            
										<xsl:otherwise>
											<xsl:value-of select="./text()"/>
										</xsl:otherwise>
									</xsl:choose>                    
									<!--<xsl:if test="not(position()=last()) and not( $qualifier='thesoz' and @language!=$language)">-->
									<xsl:if test="not(position()=last())">
										<xsl:text>; </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>


			</td>
		</tr>
	</xsl:if>
</xsl:template>


<xsl:template name="displayEmbargo">
	<xsl:param name="date"/>

	<div style="margin-top:1em">
		<img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon-embargo.png')}" alt="fulltextDownload" style="margin-right:2em;" align="left"/>
		<p>
			<i18n:text>xmlui.ssoar.labels.embargo</i18n:text>
			<xsl:call-template name="displayDate">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
			<span/>                
		</p>
	</div>

</xsl:template>

<xsl:template name="displayDate">
	<xsl:param name="date"/>
	<xsl:variable name="year" select="substring-before($date,'-')"/>
	<xsl:variable name="month" select="substring-before(substring-after($date,'-'),'-')"/>
	<xsl:variable name="day" select="substring-after(substring-after($date,'-'),'-')"/>
	<xsl:choose>
		<xsl:when test="$languageiso = 'de'">
			<xsl:choose>
				<xsl:when test="starts-with($day,'0')">
					<xsl:value-of select="substring-after($day,'0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$day"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>.&#160;</xsl:text>
			<xsl:choose>
				<xsl:when test="$month='01'">Jan.</xsl:when>
				<xsl:when test="$month='02'">Feb.</xsl:when>
				<xsl:when test="$month='03'">M峺</xsl:when>
				<xsl:when test="$month='04'">Apr.</xsl:when>
				<xsl:when test="$month='05'">Mai</xsl:when>
				<xsl:when test="$month='06'">Juni</xsl:when>
				<xsl:when test="$month='07'">Juli</xsl:when>
				<xsl:when test="$month='08'">Aug.</xsl:when>
				<xsl:when test="$month='09'">Sept.</xsl:when>
				<xsl:when test="$month='10'">Okt.</xsl:when>
				<xsl:when test="$month='11'">Nov.</xsl:when>
				<xsl:when test="$month='12'">Dez.</xsl:when>
			</xsl:choose>
			<xsl:text>&#160;</xsl:text>
			<xsl:value-of select="$year"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="starts-with($day,'0')">
					<xsl:value-of select="substring-after($day,'0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$day"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&#160;</xsl:text>
			<xsl:choose>
				<xsl:when test="$month='01'">Jan.</xsl:when>
				<xsl:when test="$month='02'">Feb.</xsl:when>
				<xsl:when test="$month='03'">Mar.</xsl:when>
				<xsl:when test="$month='04'">Apr.</xsl:when>
				<xsl:when test="$month='05'">May</xsl:when>
				<xsl:when test="$month='06'">June</xsl:when>
				<xsl:when test="$month='07'">July</xsl:when>
				<xsl:when test="$month='08'">Aug.</xsl:when>
				<xsl:when test="$month='09'">Sept.</xsl:when>
				<xsl:when test="$month='10'">Oct.</xsl:when>
				<xsl:when test="$month='11'">Nov.</xsl:when>
				<xsl:when test="$month='12'">Dec.</xsl:when>
			</xsl:choose>
			<xsl:text>&#160;</xsl:text>
			<xsl:value-of select="$year"/> 
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>



<xsl:template match="dim:field[@mdschema='dc']" mode="itemSummaryView-DIM"> 
	<xsl:variable name="element"/>
	<xsl:for-each select="@element">
		<tr>
			<td class="resourceDetailTableCellLabel">
				<xsl:choose>
					<xsl:when test="not(../@qualifier)">
						<i18n:text>xmlui.ssoar.metadata.<xsl:value-of select="../@mdschema"/>.<xsl:value-of select="../@element"/>
						</i18n:text>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.ssoar.metadata.<xsl:value-of select="../@mdschema"/>.<xsl:value-of select="../@element"/>.<xsl:value-of select="../@qualifier"/>
						</i18n:text>    
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="resourceDetailTableCellValue">
				<xsl:apply-templates select="../@qualifier"/>
				<xsl:for-each select="../@element|@qualifier">



					<xsl:value-of select="../text()"/>

				</xsl:for-each>

			</td>
		</tr>
	</xsl:for-each>

</xsl:template>

<xsl:template match="@qualifier">
	<xsl:value-of select="../text()"/> 
</xsl:template>



<!-- Generate the info about the item from the metadata section -->
<xsl:template match="dim:dim" mode="itemSummaryView-DIM">
	<table class="includeSet-table">
		<xsl:call-template name="itemSummaryView-DIM-fields">
		</xsl:call-template>
	</table>
	<!--  Generate COinS  -->
	<span class="Z3988">
		<xsl:attribute name="title">
			<xsl:call-template name="renderCOinS"/>
		</xsl:attribute>
	    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
	</span>
</xsl:template>

<xsl:template match="dim:dim" mode="citationBlock">
	<xsl:param name="gotoSiteLabel"/>        
	<!--<xsl:choose>
            <xsl:when test="./dim:field[@element='type' and @qualifier='stock']/text()='recension'">
                <em><i18n:text>xmlui.ssoar.labels.recension</i18n:text><xsl:text>: </xsl:text></em>
            </xsl:when>
            <xsl:otherwise>
                <em><i18n:text>xmlui.ssoar.labels.source</i18n:text><xsl:text>: </xsl:text></em>
            </xsl:otherwise>
                
        </xsl:choose>-->

	<xsl:choose>            			
		<xsl:when test="./dim:field[@element='type' and @qualifier='stock']/text()='monograph'">
			<em>
				<i18n:text>xmlui.ssoar.labels.source</i18n:text>
				<xsl:text>: </xsl:text>
			</em>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
				<xsl:for-each select="./dim:field[@element='contributor' and @qualifier='corporateeditor']">
					<xsl:value-of select="./text()"/>
					<xsl:text>; </xsl:text>					
				</xsl:for-each>	
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
				<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
					<xsl:text>: </xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>                    
			</xsl:if>                
			<xsl:if test="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
				<xsl:choose>
					<xsl:when test="./dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor'] and
                            not(./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                            or ./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)])"/>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>      
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
				<xsl:text>. </xsl:text>      
			</xsl:if>  
			<xsl:call-template name="pageinfo">
				<xsl:with-param name="pageinfo" select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
			</xsl:call-template>  
		</xsl:when>

		<!-- Sammelwerke -->
		<xsl:when test="./dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='collection'"> 
			<em>
				<i18n:text>xmlui.ssoar.labels.source</i18n:text>
				<xsl:text>: </xsl:text>
			</em>
			<!-- corporate editor -->
			<xsl:if test="./dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
				<xsl:for-each select="./dim:field[@element='contributor' and @qualifier='corporateeditor']">
					<xsl:value-of select="./text()"/>
					<xsl:text>; </xsl:text>					
				</xsl:for-each>	
			</xsl:if>
			<!-- city -->
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
				<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
					<xsl:text>: </xsl:text>
				</xsl:if>
			</xsl:if>
			<!-- publisher -->
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>                    
			</xsl:if>      
			<!-- date issued -->
			<xsl:if test="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
				<xsl:choose>
					<xsl:when test="./dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor'] and
                            not(./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                            or ./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)])"/>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>      
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
				<xsl:text>. </xsl:text>      
			</xsl:if>   
			<xsl:call-template name="pageinfo">
				<xsl:with-param name="pageinfo" select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
			</xsl:call-template>  
		</xsl:when>

		<!-- Beitrag in einem Sammelwerke -->
		<xsl:when test="./dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='incollection'"> 
			<em>
				<i18n:text>xmlui.ssoar.labels.source</i18n:text>
				<xsl:text>: </xsl:text>
			</em>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']/text()"/>                    
				<xsl:text>. </xsl:text>
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
				<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
					<xsl:text>: </xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>                    
			</xsl:if>                
			<xsl:if test="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
				<xsl:choose>
					<xsl:when test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='collection'] and
                            not(./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                            or ./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)])"/>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>      
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
				<xsl:text>. </xsl:text>      
			</xsl:if>                  
			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="pageinfo">
					<xsl:with-param name="pageinfo" select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:when>

		<!-- Beitrag in einer Zeitschrift -->
		<xsl:when test="./dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='article'">
			<em>
				<i18n:text>xmlui.ssoar.labels.source</i18n:text>
				<xsl:text>: </xsl:text>
			</em>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()"/>                    
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
			</xsl:if>

			<xsl:if test="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
				<xsl:text>) </xsl:text>                          
			</xsl:if>  

			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">                    
				<xsl:value-of select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']/text()"/>                    
			</xsl:if>
			<xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="pageinfo">
					<xsl:with-param name="pageinfo" select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Old implementation
                <xsl:if test="./dim:field[@mdschema='dc' and @element='source' and @qualifier='journal'] or
                                ./dim:field[@mdschema='dc' and @element='source' and @qualifier='volume'] or
                                ./dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
                    <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
                    <xsl:value-of select="./dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
                    <xsl:if test="./dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                        <xsl:text>: </xsl:text>
                    </xsl:if>
                </xsl:if> -->              


		</xsl:when>

		<!-- Rezension -->
		<xsl:when test="./dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='recension'">
			<xsl:call-template name="recensionSource">
				<xsl:with-param name="dimNode" select="."/>
				<xsl:with-param name="withSource" select="true()"/>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template name="recensionSource">
	<xsl:param name="dimNode"/>
	<xsl:param name="withSource"/>
	<em>
		<i18n:text>xmlui.ssoar.labels.recension</i18n:text>
		<xsl:text>: </xsl:text>
	</em>
	<xsl:choose>
		<xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionauthor']">
			<xsl:for-each select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionauthor']">
				<xsl:value-of select="./text()"/>
				<xsl:choose>
					<xsl:when test="not(position()=last())">
						<xsl:text>; </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>: </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioneditor']">
			<xsl:for-each select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioneditor']">
				<xsl:value-of select="./text()"/>
				<xsl:choose>
					<xsl:when test="not(position()=last())">
						<xsl:text>; </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> (</xsl:text>
						<i18n:text>xmlui.ssoar.labels.editorshort</i18n:text>
						<xsl:text>): </xsl:text>
					</xsl:otherwise>
				</xsl:choose>                    
			</xsl:for-each>
		</xsl:when>
	</xsl:choose>

	<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiontitle']/text()"/>
	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiontitle']">. </xsl:if>

	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionseries']">
		<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionseries']/text()"/>
		<xsl:text>. </xsl:text>
	</xsl:if>        



	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionedition']">
		<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionedition']/text()"/>
		<xsl:choose>
			<xsl:when test="not(contains($dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionedition']/text(), '.'))">
				<xsl:text>. </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--<i18n:text>xmlui.ssoar.labels.edition</i18n:text>-->
	</xsl:if>

	<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioncity']/text()"/>
	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioncity']">: </xsl:if>
	<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionpublisher']/text()"/>
	<!-- Wichtig: Auch darauf achten, dass der letzte Wert (pubyear) exisitert,
            ansonsten hat man ein Komma ohne folgenden Inhalt -->
	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionpublisher'] and $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiondateissued']">, </xsl:if>
	<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiondateissued']/text()"/>
	<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionisbn']">
		<xsl:text>. </xsl:text>
		<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionisbn']/text()"/>
	</xsl:if>
	<xsl:if test="$withSource">
		<br/>
		<em>
			<i18n:text>xmlui.ssoar.labels.source</i18n:text>
			<xsl:text>: </xsl:text>
		</em>
		<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()"/>
		<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']">, </xsl:if>
		<!-- Wenn es Volume oder Issue gibt... -->
		<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume'] or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
			<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
			<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']/text()"/>
			<xsl:text>: </xsl:text>
		</xsl:if>

		<xsl:call-template name="pageinfo">
			<xsl:with-param name="pageinfo" select="./dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
		</xsl:call-template>
		<xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">, </xsl:if>
		<xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']"/>
	</xsl:if>
</xsl:template>


<!-- render each field on a row, alternating phase between odd and even -->
<!-- recursion needed since not every row appears for each Item. -->
<xsl:template name="itemSummaryView-DIM-fields">
	<xsl:param name="clause" select="'1'"/>
	<xsl:param name="phase" select="'even'"/>
	<xsl:variable name="otherPhase">
		<xsl:choose>
			<xsl:when test="$phase = 'even'">
				<xsl:text>odd</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>even</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:choose>

		<!--  artifact?
            <tr class="table-row odd">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-preview</i18n:text>:</span></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                            <a class="image-link">
                                <xsl:attribute name="href"><xsl:value-of select="@OBJID"/></xsl:attribute>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                            mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-preview</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>-->

		<!-- Title row -->
		<xsl:when test="$clause = 1">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>: </span>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
							<xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
								<xsl:value-of select="./node()"/>
								<xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
									<xsl:text>; </xsl:text>
									<br/>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
							<xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- Author(s) row -->
		<xsl:when test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor'])">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:</span>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
							<xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
								<span>
									<xsl:if test="@authority">
										<xsl:attribute name="class">
											<xsl:text>dc_contributor_author-authority</xsl:text>
										</xsl:attribute>
									</xsl:if>
									<xsl:copy-of select="node()"/>
								</span>
								<xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="dim:field[@element='creator']">
							<xsl:for-each select="dim:field[@element='creator']">
								<xsl:copy-of select="node()"/>
								<xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="dim:field[@element='contributor']">
							<xsl:for-each select="dim:field[@element='contributor']">
								<xsl:copy-of select="node()"/>
								<xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- Abstract row -->
		<xsl:when test="$clause = 3 and (dim:field[@element='description' and @qualifier='abstract'])">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</span>
				</td>
				<td>
					<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
						<hr class="metadata-seperator"/>
					</xsl:if>
					<xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
						<xsl:copy-of select="./node()"/>
						<xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
							<hr class="metadata-seperator"/>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
						<hr class="metadata-seperator"/>
					</xsl:if>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- Description row -->
		<xsl:when test="$clause = 4 and (dim:field[@element='description' and not(@qualifier)])">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</span>
				</td>
				<td>
					<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
						<hr class="metadata-seperator"/>
					</xsl:if>
					<xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
						<xsl:copy-of select="./node()"/>
						<xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
							<hr class="metadata-seperator"/>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
						<hr class="metadata-seperator"/>
					</xsl:if>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- identifier.uri row -->
		<xsl:when test="$clause = 5 and (dim:field[@element='identifier' and @qualifier='uri'])">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span>
				</td>
				<td>
					<xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
						<a>
							<xsl:attribute name="href">
								<xsl:copy-of select="./node()"/>
							</xsl:attribute>
							<xsl:copy-of select="./node()"/>
						</a>
						<xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- date.issued row -->
		<xsl:when test="$clause = 6 and (dim:field[@element='date' and @qualifier='issued'])">
			<tr class="table-row {$phase}">
				<td>
					<span class="bold">
						<i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span>
				</td>
				<td>
					<xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
						<xsl:copy-of select="substring(./node(),1,10)"/>
						<xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
				<xsl:with-param name="clause" select="($clause + 1)"/>
				<xsl:with-param name="phase" select="$otherPhase"/>
			</xsl:call-template>
		</xsl:when>

		<!-- recurse without changing phase if we didn't output anything -->
		<xsl:otherwise>
			<!-- IMPORTANT: This test should be updated if clauses are added! -->
			<xsl:if test="$clause &lt; 7">
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$phase"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- The summaryView of communities and collections is undefined. -->
<xsl:template name="collectionSummaryView-DIM">
	<i18n:text>xmlui.dri2xhtml.METS-1.0.collection-not-implemented</i18n:text>
</xsl:template>

<xsl:template name="communitySummaryView-DIM">
	<i18n:text>xmlui.dri2xhtml.METS-1.0.community-not-implemented</i18n:text>
</xsl:template>

<!-- 
        The detailView display type; used to generate a complete view of the object involved. It is currently
        used with the "full item record" view of items as well as the default views of communities and collections. 
    -->
<xsl:template match="mets:METS[mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']]" mode="detailView">
	<xsl:choose>
		<xsl:when test="@LABEL='DSpace Item'">
			<xsl:call-template name="itemDetailView-DIM"/>
		</xsl:when>
		<xsl:when test="@LABEL='DSpace Collection'">
			<xsl:call-template name="collectionDetailView-DIM"/>
		</xsl:when>
		<xsl:when test="@LABEL='DSpace Community'">
			<xsl:call-template name="communityDetailView-DIM"/>
		</xsl:when>                
		<xsl:otherwise>
			<i18n:text>xmlui.dri2xhtml.METS-1.0.non-conformant</i18n:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
<xsl:template name="itemDetailView-DIM">
	<xsl:if test="$ssoarEditor = 'true'">
		<!-- Output all of the metadata about the item from the metadata section -->
		<xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                mode="itemDetailView-DIM"/>

		<!-- Generate the bitstream information from the file section -->
		<xsl:choose>
			<xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
				<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
					<xsl:with-param name="context" select="."/>
					<xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
			<xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
				<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
			</xsl:when>
			<xsl:otherwise>
				<h2>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
				</h2> 
				<table class="table file-list">
					<tr class="table-header-row">
						<th>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text>
						</th>
						<th>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
						</th>
						<th>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
						</th>
						<th>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text>
						</th>
					</tr>
					<tr>
						<td colspan="4">
							<p>
								<i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text>
							</p>
						</td>
					</tr>
				</table>
			</xsl:otherwise>
		</xsl:choose>

		<!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default) -->
		<xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']"/>

	</xsl:if>
</xsl:template>

<!-- The block of templates used to render the complete DIM contents of a DRI object -->
<xsl:template match="dim:dim" mode="itemDetailView-DIM">
	<table class="includeSet-table">
		<xsl:apply-templates mode="itemDetailView-DIM"/>
	</table>
	<span class="Z3988">
		<xsl:attribute name="title">
			<xsl:call-template name="renderCOinS"/>
		</xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
	</span>
</xsl:template>

<xsl:template match="dim:field" mode="itemDetailView-DIM">
	<xsl:if test="not(@element='description' and @qualifier='provenance')">
		<tr>
			<xsl:attribute name="class">
				<xsl:text>table-row </xsl:text>
				<xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
				<xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
			</xsl:attribute>
			<td>
				<xsl:value-of select="./@mdschema"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="./@element"/>
				<xsl:if test="./@qualifier">
					<xsl:text>.</xsl:text>
					<xsl:value-of select="./@qualifier"/>
				</xsl:if>
			</td>
			<td>
				<xsl:copy-of select="./node()"/>
				<xsl:if test="./@authority and ./@confidence">
					<xsl:call-template name="authorityConfidenceIcon">
						<xsl:with-param name="confidence" select="./@confidence"/>
					</xsl:call-template>
				</xsl:if>
			</td>
			<td>
				<xsl:value-of select="./@language"/>
			</td>
		</tr>
	</xsl:if>
</xsl:template>

<!-- A collection rendered in the detailView pattern; default way of viewing a collection. -->
<xsl:template name="collectionDetailView-DIM">
	<div class="detail-view">&#160;
		<!-- Generate the logo, if present, from the file section -->
		<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='LOGO']"/>
		<!-- Generate the info about the collections from the metadata section -->
		<xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                mode="collectionDetailView-DIM"/>
	</div>
</xsl:template>

<!-- Generate the info about the collection from the metadata section -->
<xsl:template match="dim:dim" mode="collectionDetailView-DIM"> 
	<xsl:if test="string-length(dim:field[@element='description'][not(@qualifier)])&gt;0">
		<p class="intro-text">
			<xsl:copy-of select="dim:field[@element='description'][not(@qualifier)]/node()"/>
		</p>
	</xsl:if>
	<xsl:if test="string-length(dim:field[@element='description'][@qualifier='tableofcontents'])&gt;0">
		<div class="detail-view-news">
			<h3>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.news</i18n:text>
			</h3>
			<p class="news-text">
				<xsl:copy-of select="dim:field[@element='description'][@qualifier='tableofcontents']/node()"/>
			</p>
		</div>
	</xsl:if>
	<xsl:if test="string-length(dim:field[@element='rights'][not(@qualifier)])&gt;0 or string-length(dim:field[@element='rights'][@qualifier='license'])&gt;0">
		<div class="detail-view-rights-and-license">
			<xsl:if test="string-length(dim:field[@element='rights'][not(@qualifier)])&gt;0">
				<p class="copyright-text">
					<xsl:copy-of select="dim:field[@element='rights'][not(@qualifier)]/node()"/>
				</p>
			</xsl:if>
		</div>
	</xsl:if>
</xsl:template>

<!-- Rendering the file list from an Atom ReM bitstream stored in the ORE bundle -->
<xsl:template match="mets:fileGrp[@USE='ORE']">
	<xsl:variable name="AtomMapURL" select="concat('cocoon:/',substring-after(mets:file/mets:FLocat[@LOCTYPE='URL']//@*[local-name(.)='href'],$context-path))"/>
	<h2>
		<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
	</h2>
	<table class="table file-list">
		<thead>
			<tr class="table-header-row">
				<th>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text>
				</th>
				<th>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
				</th>
				<th>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
				</th>
				<th>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text>
				</th>
			</tr>
		</thead>
		<tbody>
			<xsl:apply-templates select="document($AtomMapURL)/atom:entry/atom:link[@rel='http://www.openarchives.org/ore/terms/aggregates']">
				<xsl:sort select="@title"/>
			</xsl:apply-templates>
		</tbody>
	</table>
</xsl:template>

<!-- Iterate over the links in the ORE resource maps and make them into bitstream references in the file section -->
<xsl:template match="atom:link[@rel='http://www.openarchives.org/ore/terms/aggregates']">
	<tr>
		<xsl:attribute name="class">
			<xsl:text>table-row </xsl:text>
			<xsl:if test="(position() mod 2 = 0)">even </xsl:if>
			<xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
		</xsl:attribute>
		<td>
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="@href"/>
				</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:choose>
						<xsl:when test="@title">
							<xsl:value-of select="@title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@href"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="string-length(@title) > 50">
						<xsl:variable name="title_length" select="string-length(@title)"/>
						<xsl:value-of select="substring(@title,1,15)"/>
						<xsl:text> ... </xsl:text>
						<xsl:value-of select="substring(@title,$title_length - 25,$title_length)"/>
					</xsl:when>
					<xsl:when test="@title">
						<xsl:value-of select="@title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@href"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</td>
		<!-- File size always comes in bytes and thus needs conversion --> 
		<td>
			<xsl:choose>
				<xsl:when test="@length &lt; 1000">
					<xsl:value-of select="@length"/>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
				</xsl:when>
				<xsl:when test="@length &lt; 1000000">
					<xsl:value-of select="substring(string(@length div 1000),1,5)"/>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
				</xsl:when>
				<xsl:when test="@length &lt; 1000000001">
					<xsl:value-of select="substring(string(@length div 1000000),1,5)"/>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
				</xsl:when>
				<xsl:when test="@length &gt; 1000000000">
					<xsl:value-of select="substring(string(@length div 1000000000),1,5)"/>
					<i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
				</xsl:when>
				<!-- When one isn't available -->
				<xsl:otherwise>
					<xsl:text>n/a</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		<!-- Currently format carries forward the mime type. In the original DSpace, this 
                would get resolved to an application via the Bitstream Registry, but we are
                constrained by the capabilities of METS and can't really pass that info through. -->
		<td>
			<xsl:value-of select="substring-before(@type,'/')"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="substring-after(@type,'/')"/>
		</td>
		<td>
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="@href"/>
				</xsl:attribute>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
			</a>
		</td>
	</tr>
</xsl:template>

<!-- A community rendered in the detailView pattern; default way of viewing a community. -->
<xsl:template name="communityDetailView-DIM">
	<div class="detail-view">&#160;
		<!-- Generate the logo, if present, from the file section -->
		<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='LOGO']"/>
		<!-- Generate the info about the collections from the metadata section -->
		<xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                mode="communityDetailView-DIM"/>
	</div>
</xsl:template>

<!-- Generate the info about the community from the metadata section -->
<xsl:template match="dim:dim" mode="communityDetailView-DIM"> 
	<xsl:if test="string-length(dim:field[@element='description'][not(@qualifier)])&gt;0">
		<p class="intro-text">
			<xsl:copy-of select="dim:field[@element='description'][not(@qualifier)]/node()"/>
		</p>
	</xsl:if>

	<xsl:if test="string-length(dim:field[@element='description'][@qualifier='tableofcontents'])&gt;0">
		<div class="detail-view-news">
			<h3>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.news</i18n:text>
			</h3>
			<p class="news-text">
				<xsl:copy-of select="dim:field[@element='description'][@qualifier='tableofcontents']/node()"/>
			</p>
		</div>
	</xsl:if>

	<xsl:if test="string-length(dim:field[@element='rights'][not(@qualifier)])&gt;0">
		<div class="detail-view-rights-and-license">
			<p class="copyright-text">
				<xsl:copy-of select="dim:field[@element='rights'][not(@qualifier)]/node()"/>
			</p>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template name="pageinfo">
	<xsl:param name="pageinfo"/>
	<xsl:if test="$pageinfo != ''">
		<xsl:choose>
			<xsl:when test="contains($pageinfo,'S') or contains($pageinfo,'s')
                        or contains($pageinfo,'p') or contains($pageinfo,'P')">
				<xsl:value-of select="$pageinfo"/>
			</xsl:when>
			<xsl:when test="contains($pageinfo, '-')">
				<i18n:text>xmlui.ssoar.labels.pages</i18n:text>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$pageinfo"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pageinfo"/>
				<xsl:text> </xsl:text>
				<i18n:text>xmlui.ssoar.labels.pages</i18n:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!--  
    *********************************************
    OpenURL COinS Rendering Template
    *********************************************
 
    COinS Example:
    
    <span class="Z3988" 
    title="ctx_ver=Z39.88-2004&amp;
    rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;
    rfr_id=info%3Asid%2Focoins.info%3Agenerator&amp;
    rft.title=Making+WordPress+Content+Available+to+Zotero&amp;
    rft.aulast=Kraus&amp;
    rft.aufirst=Kari&amp;
    rft.subject=News&amp;
    rft.source=Zotero%3A+The+Next-Generation+Research+Tool&amp;
    rft.date=2007-02-08&amp;
    rft.type=blogPost&amp;
    rft.format=text&amp;
    rft.identifier=http://www.zotero.org/blog/making-wordpress-content-available-to-zotero/&amp;
    rft.language=English"></span>

    This Code does not parse authors names, instead relying on dc.contributor to populate the
    coins
    -->

<!-- If you are using SFX, uncomment the template below
         and comment out the default renderCOinS template -->

<!-- SFX renderCOinS

	        <xsl:template name="renderCOinS">
	        <xsl:text>ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;</xsl:text>
	        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='sfx'][@qualifier='server']"/>
	        <xsl:text>&amp;</xsl:text>
	        <xsl:text>rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;</xsl:text>
	        </xsl:template>
        -->
<xsl:template name="renderCOinS">
	<xsl:text>ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;</xsl:text>
	<xsl:for-each select=".//dim:field[@element = 'identifier']">
		<xsl:text>rft_id=</xsl:text>
		<xsl:value-of select="encoder:encode(string(.))"/>
		<xsl:text>&amp;</xsl:text>
	</xsl:for-each>
	<xsl:text>rfr_id=info%3Asid%2Fdspace.org%3Arepository&amp;</xsl:text>
	<xsl:for-each select=".//dim:field[@mdschema='dc' and @element != 'description' and @element != 'embargo' and @qualifier != 'provenance']">

		<!-- We do need a simple DC crosswalk in place for this, but for now at least fix author
                 - most other fields will be ok -->

		<xsl:choose>
			<xsl:when test="@element = 'contributor' and @qualifier='author'">
				<xsl:value-of select="concat('rft.', 'creator','=',encoder:encode(string(.))) "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('rft.', @element,'=',encoder:encode(string(.))) "/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="position()!=last()">
			<xsl:text>&amp;</xsl:text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


</xsl:stylesheet>
