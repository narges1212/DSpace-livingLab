<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    TODO: Describe this XSL file
    Author: Alexey Maslov
    
-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xhtml="http://www.w3.org/1999/xhtml"
        xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:java="http://xml.apache.org/xslt/java" 
        xmlns:encoder="xalan://java.net.URLEncoder"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="mets xlink xsl dim xhtml mods dc java">
    <xsl:import href="CommunityOverview.xsl"/>
    <xsl:import href="citation/bibtex.xsl"/>
    <xsl:import href="citation/endnote.xsl"/>
    <xsl:output indent="yes"/>
    
    
    
    <!-- Global variables -->
    
    <!--
        Context path provides easy access to the context-path parameter. This is
        used when building urls back to the site, they all must include the
        context-path paramater.
    -->
    <xsl:variable name="context-path" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']/text()"/>
    
    <!--<xsl:variable name="languageiso"/>-->
    <!--
        Theme path represents the full path back to theme. This is usefull for
        accessing static resources such as images or javascript files. Simply
        prepend this variable and then add the file name, thus
        {$theme-path}/images/myimage.jpg will result in the full path from the
        HTTP root down to myimage.jpg. The theme path is composed of the
        "[context-path]/themes/[theme-dir]/".
    -->
    <xsl:variable name="theme-path" select="concat($context-path,'/themes/',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path'])"/>
    <xsl:variable name="protocol">
        <xsl:choose>
            <xsl:when test="starts-with(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='scheme']/text(), 'https')">
                <xsl:text>https://</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>http://</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="serverHostname" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='serverName']/text()" />
    <xsl:variable name="serverPort" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='serverPort']/text()" />
    <xsl:variable name="optionalSeparatorAndServerPort">
        <xsl:choose>
            <xsl:when test="$serverPort = 80">
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(':', $serverPort)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="contextPath" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='contextPath']/text()" /> <!-- e.g. "/xmlui", "/ssoar" -->
    
    <xsl:variable name="usermail" select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='email']/text()" />
    <xsl:variable name="ssoarEditor">
        <xsl:choose>
            <xsl:when test="$usermail='uta.richter@gesis.org' or
                $usermail='thomas.mueller@gesis.org' or
                $usermail='christian.czymara@gesis.org' or
                $usermail='diana.pacheco@gesis.org' or
                $usermail='esther.niewerth@gesis.org' or
                $usermail='rahel.ritter@gesis.org' or
                $usermail='admin@ssoar.info'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable> 
    
    <xsl:variable name="fileadmin"><xsl:value-of select="$protocol"/>www.ssoar.info/fileadmin</xsl:variable>
    
    <xsl:variable name="requestQueryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='queryString']"/>
    <xsl:variable name="requestURI" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI']"/>
    <xsl:variable name="workflow">
        <xsl:choose>
            <xsl:when test="/dri:document/dri:body/dri:div[@n='perform-task']">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="submissionFilter">
        <xsl:variable name="queryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='queryString']/text()"/>
        <xsl:choose>
            <xsl:when test="not(contains($queryString, 'submissionFilter='))">
                <xsl:text>all</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="querySubstring" select="substring-after($queryString, 'submissionFilter=')"/>
                <xsl:choose>
                    <xsl:when test="contains($querySubstring, '&amp;')">
                        <xsl:value-of select="substring-before($querySubstring,'&amp;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$querySubstring"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:variable>
    
    <xsl:variable name="userList"> 
        <xsl:choose>
            <xsl:when test="$submissionFilter='all'">
                
            </xsl:when>
            <xsl:when test="$submissionFilter='import'">
                Import User import@ssoar.info
            </xsl:when>
            <xsl:when test="$submissionFilter='usbkoeln'">
                USB Köln usbkoeln@ssoar.info
            </xsl:when>
            <xsl:when test="$submissionFilter='editors'">
                Uta Richter uta.richter@geis.org
                Thomas Mueller thomas.mueller@gesis.org
                Christian Czymara christian.czymara@gesis.org 	
                Diana Pacheco diana.pacheco@gesis.org 	
                Esther Niewerth esther.niewerth@gesis.org
                Rahel Ritter rahel.ritter@gesis.org
            </xsl:when>
            <xsl:when test="$submissionFilter='harvest'">
                Harvest User harvest@ssoar.info                   
            </xsl:when>
            <xsl:when test="$submissionFilter='DIFM'">
                Deutsches Institut für Menschenrechte bibliothek@institut-fuer-menschenrechte.de
            </xsl:when>
            <!-- The filtering for externals works inverted as a black list, so include user-account not to be included -->
            <xsl:when test="$submissionFilter='external'">                
                Admin GESIS admin@ssoar.info
                Import User import@ssoar.info
                Uta Richter uta.richter@geis.org
                Thomas Mueller thomas.mueller@gesis.org 
                Christian Czymara christian.czymara@gesis.org 	
                Diana Pacheco diana.pacheco@gesis.org 	
                Esther Niewerth esther.niewerth@gesis.org
                Rahel Ritter rahel.ritter@gesis.org
                USB Köln usbkoeln@ssoar.info
                Deutsches Institut für Menschenrechte bibliothek@institut-fuer-menschenrechte.de
            </xsl:when>
            <xsl:otherwise>
                
            </xsl:otherwise>
        </xsl:choose>   
    </xsl:variable>
    
    <!-- FIXME use ${solr.server} -->
    <xsl:variable name="solrpath">http://localhost:8080/solr/statistics/select/</xsl:variable>
    
    <xsl:variable name="curDay">
        <xsl:value-of select="java:format(java:java.text.SimpleDateFormat.new('dd'), java:java.util.Date.new())" />
    </xsl:variable>  
    <xsl:variable name="curMonth">
        <xsl:value-of select="java:format(java:java.text.SimpleDateFormat.new('MM'), java:java.util.Date.new())" />
    </xsl:variable>    
    <xsl:variable name="curYear">
        <xsl:value-of select="java:format(java:java.text.SimpleDateFormat.new('yyyy'), java:java.util.Date.new())" />
    </xsl:variable>
    <!--
    This style sheet will be written in several stages:
        1. Establish all the templates that catch all the elements
        2. Finish implementing the XHTML output within the templates
        3. Figure out the special case stuff as well as the small details
        4. Clean up the code
    
    Currently in stage 3...
        
    Last modified on: 3/15/2006
    -->
    
    <!--  -->
    
        <xsl:variable name="language">
            <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='language']/text()='de_DE'">
                    <xsl:text>de_DE</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>en_EN</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="languageiso">
        <xsl:choose>
            <xsl:when test="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='language']/text()='de_DE'">
                <xsl:text>de</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>en</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    
    
    
    <!-- This stylesheet's purpose is to translate a DRI document to an HTML one, a task which it accomplishes
        through interative application of templates to select elements. While effort has been made to
        annotate all templates to make this stylesheet self-documenting, not all elements are used (and
        therefore described) here, and those that are may not be used to their full capacity. For this reason,
        you should consult the DRI Schema Reference manual if you intend to customize this file for your needs.
    -->
        
    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).
        
        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "main". It is further subdivided into:
            "header"  - the header div containing title, subtitle, trail and other front matter
            "body"    - the div containing all the content of the page; built from the contents of dri:body
            "options" - the div with all the navigation and actions; built from the contents of dri:options
            "footer"  - optional footer div, containing misc information
        
        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">
        <xsl:comment><xsl:value-of select="$protocol"/></xsl:comment>        
        <xsl:choose>
            <xsl:when test="/dri:document/dri:body/dri:div[@n='item-view'] and
                contains(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='queryString']/text(), 'style=')">
                <xsl:variable name="queryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='queryString']/text()"/>
                <xsl:variable name="querySubstring" select="substring-after($queryString, 'style=')"/>                
                <xsl:variable name="style">
                    <xsl:choose>
                        <xsl:when test="contains($querySubstring, '&amp;')">
                            <xsl:value-of select="substring-before($querySubstring,'&amp;')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$querySubstring"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="generateStyle">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="/dri:document/dri:body/dri:div[@id='file.news.div.news']/dri:p/text()='startpage'
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.CollectionViewer.div.collection-home']
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.CommunityViewer.div.community-home']
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.SimpleSearch.div.search']                
                ">
                <html>
                    <head>
                        <meta http-equiv="refresh" content="0; URL={$context-path}/{$requestURI}/discover"/>
                    </head>
                    <body>
                        <h1>
                            <i18n:text>xmlui.ssoar.message.redirect</i18n:text>
                        </h1>
                        <div>
                            <a href="{$context-path}/{$requestURI}/discover">
                                <xsl:value-of select="concat($context-path, '/' , $requestURI, '/' ,discover)"/>
                            </a>
                        </div>
                        <xsl:call-template name="etracker"/>
                    </body>
                </html>
                
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <!-- First of all, build the HTML head element -->
                    <xsl:call-template name="buildHead"/>
                    <!-- Then proceed to the body -->
                    <xsl:choose>
                        <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                            <!-- add setup JS code if this is a choices lookup page -->
                            <xsl:if test="dri:body/dri:div[@n='lookup']">
                                <xsl:call-template name="choiceLookupPopUpSetup"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <body>               
                                <!--<a href="#" >
                                    <xsl:comment>rien</xsl:comment>
                                </a>-->
								<xsl:if test="/dri:document/dri:body/dri:div[@n='item-view']">
									<div id="glassPane" class="hidden glass-pane">&#160;</div>		
									<div id="InfolisPopup" class="hidden popup infolis-popup">&#160; 	
										<!--<iframe id="InfolisIframe" src="http://cms-pool/infolis/infolis_linkservice.php" frameborder="0">&#160;</iframe>-->
										<iframe id="InfolisIframe" src="" frameborder="0">&#160;</iframe>
										<button type="button" class="infolisCloseButton" id="InfolisClose" onclick="javascript:InfolisCloseFunction();">x</button> 
										</div>  
								</xsl:if>
								
                                <div id="page_margins" name="pageHead">               
                                    <div id="page">
                                        <!--
                                            The header div, complete with title, subtitle, trail and other junk. The trail is
                                            built by applying a template over pageMeta's trail children. -->
                                        <xsl:call-template name="buildHeader"/>
                                        
                                        <!--
                                            Goes over the document tag's children elements: body, options, meta. The body template
                                            generates the ds-body div that contains all the content. The options template generates
                                            the ds-options div that contains the navigation and action options available to the
                                            user. The meta element is ignored since its contents are not processed directly, but
                                            instead referenced from the different points in the document. -->
                                        <div id="main">
                                            <xsl:apply-templates select="dri:options"/>
                                            <xsl:apply-templates select="dri:body"/>					
                                            
                                        </div>
                                        
                                        <!--
                                            The footer div, dropping whatever extra information is needed on the page. It will
                                            most likely be something similar in structure to the currently given example. -->
                                        <xsl:call-template name="buildFooter"/>
                                        
                                    </div>
                                </div>
                                <xsl:call-template name="addJavascript"/>
                                <!--<xsl:if test="dri:body/dri:div[contains(@n, 'submit')]">
                                    <xsl:call-template name="addJavascript"/>
                                    <!-\-<script src="{$context-path}/themes/ssoar/lib/js/choice-support.js" type="text/javascript"/>-\->
                                </xsl:if>-->
                                <xsl:call-template name="etracker"/>
                            </body>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>	
    
    <xsl:template name="etracker">
        <xsl:comment>Copyright (c) 2000-2013 etracker GmbH. All rights reserved.</xsl:comment>
        <xsl:comment>This material may not be reproduced, displayed, modified or distributed</xsl:comment>
        <xsl:comment>without the express prior written permission of the copyright holder.</xsl:comment> 
        
        <xsl:comment>BEGIN etracker code ETRC 3.0</xsl:comment>   		
		<script type="text/javascript"><xsl:text disable-output-escaping="yes">document.write(String.fromCharCode(60)+"script type=\"text/javascript\" src=\"//www.etracker.com/t.js?et=qPKGYV\"&gt;"+String.fromCharCode(60)+"/script&gt;");</xsl:text></script>
       
        <xsl:comment>etracker PARAMETER 3.0</xsl:comment>
        <xsl:text>&#xA;</xsl:text>        
<script type="text/javascript">
            
<xsl:choose>
<xsl:when test="contains($requestURI,'discover')">
var et_pagename = "SSOAR%2F<xsl:value-of select="$requestURI"/>%2F";
var et_areas    = "SSOAR%2Fdiscover%2F";        
</xsl:when>
<xsl:when test="contains($requestURI,'advanced-search')">
var et_pagename = "SSOAR%2F<xsl:value-of select="$requestURI"/>%2F";
var et_areas    = "SSOAR%2Fadvanced-search%2F";
</xsl:when>
<xsl:otherwise>
var et_pagename = "SSOAR%2F<xsl:value-of select="$requestURI"/>%2F";
var et_areas    = "SSOAR%2F";
</xsl:otherwise>
                    
</xsl:choose>
</script>
        
        <xsl:comment>etracker PARAMETER END</xsl:comment>  
        <xsl:text>
        </xsl:text>
		<script type="text/javascript">_etc();</script>
		<noscript><p><a href="//www.etracker.com"><img class="trackimage" style="border:0px;" alt="" src="//www.etracker.com/nscnt.php?et=qPKGYV" /></a></p></noscript>
        <xsl:comment>etracker CODE END</xsl:comment>
    </xsl:template>
    
    <xsl:template name="addJavascript">
        <xsl:variable name="jqueryVersion">
            <xsl:text>1.6.2</xsl:text>
        </xsl:variable>
        
        
        <script type="text/javascript" src="{concat($theme-path,'/lib/js/jquery-1.6.2.min.js')}" >&#160;</script>
        
        <script type="text/javascript" src="{concat($theme-path,'/lib/js/jquery-ui-1.8.15.custom.min.js')}">&#160;</script>
        
        <!-- Add theme javascript  -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>
        
        <!-- add "shared" javascript from static, path is relative to webapp root-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
                out of our theme without modifying the administrative and submission sitemaps.
                This is obviously not ideal, but adding those scripts in those sitemaps is far
                from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/themes/</xsl:text>
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                            <xsl:text>/lib/js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>
        
        <!--PNG Fix for IE6-->
        <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7 ]&gt;</xsl:text>
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/themes/</xsl:text>
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                <xsl:text>/lib/js/DD_belatedPNG_0.0.8a.js?v=1</xsl:text>
            </xsl:attribute>&#160;</script>
        <script type="text/javascript">
            <xsl:text>DD_belatedPNG.fix('#ds-header-logo');DD_belatedPNG.fix('#ds-footer-logo');$.each($('img[src$=png]'), function() {DD_belatedPNG.fixPng(this);});</xsl:text>
        </script>
        <xsl:text disable-output-escaping="yes" >&lt;![endif]--&gt;</xsl:text>
        
        
        <script type="text/javascript">
            runAfterJSImports.execute();
        </script>
        
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script type="text/javascript"><xsl:text>
                   var _gaq = _gaq || [];
                   _gaq.push(['_setAccount', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>']);
                   _gaq.push(['_trackPageview']);

                   (function() {
                       var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                       ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                       var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                   })();
           </xsl:text></script>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="generateStyle">
        <xsl:param name="style"/>
        
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="/dri:document/dri:body/dri:div[@n='item-view']/dri:referenceSet[@type='summaryView']/dri:reference/@url"/>
            <xsl:text>?sections=dmdSec</xsl:text>
        </xsl:variable>        
        <xsl:variable name="metadata" select="document($externalMetadataURL)/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$style='bibtex'">
                <xsl:call-template name="generateBibtex">
                    <xsl:with-param name="metadata" select="$metadata"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$style='endnote'">
                <xsl:call-template name="generateEndnote">
                    <xsl:with-param name="metadata" select="$metadata"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
        information is either user-provided bits of post-processing (as in the case of the JavaScript), or
        references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <xsl:if test="/dri:document/dri:body/dri:div[@id='file.news.div.news']/dri:p/text()='startpage'
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.CollectionViewer.div.collection-home']
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.CommunityViewer.div.community-home']
                or /dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.SimpleSearch.div.search']                
                ">
                <meta http-equiv="refresh" content="0; URL={$context-path}/discover"/> 
            </xsl:if>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=9"/>
            <meta name="Generator">
              <xsl:attribute name="content">
                <xsl:text>SSOAR - Social Science Open Access Repository</xsl:text>
                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                </xsl:if>
              </xsl:attribute>
            </meta>

            <link  rel="stylesheet" type="text/css" href="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/css/style/dbclear-new.css')}" />
            <link  rel="stylesheet" type="text/css" href="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/css/layout_3col_standard.css')}" />
            <link  rel="stylesheet" type="text/css" href="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/css/screen/content_dbclear.css')}" />
            <link  rel="stylesheet" type="text/css" href="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/css/style/ssoar.css')}" />
             <!--Add stylsheets
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
             
            </xsl:for-each>
             -->
                
            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>
            
            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='context']"/>
                        <xsl:text>description.xml</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>
            
            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script type="text/javascript">
                    //Clear default text of emty text areas on focus
                    function tFocus(element)
                    {
                            if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                    }
                    //Clear default text of emty text areas on submit
                    function tSubmit(form)
                    {
                            var defaultedElements = document.getElementsByTagName("textarea");
                            for (var i=0; i != defaultedElements.length; i++){
                                    if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                                            defaultedElements[i].value='';}}
                    }
                    //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                    function disableEnterKey(e)
                    {
                         var key;
                    
                         if(window.event)
                              key = window.event.keyCode;     //Internet Explorer
                         else
                              key = e.which;     //Firefox and Netscape
                    
                         if(key == 13)  //if "Enter" pressed, then disable!
                              return false;
                         else
                              return true;
                    }
                    
                    function FnArray()
                    {
                        this.funcs = new Array;
                    }

                    FnArray.prototype.add = function(f)
                    {
                        if( typeof f!= "function" )
                        {
                            f = new Function(f);
                        }
                        this.funcs[this.funcs.length] = f;
                    };

                    FnArray.prototype.execute = function()
                    {
                        for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> this.funcs.length; i++ )
                        {
                            this.funcs[i]();
                        }
                    };

                    var runAfterJSImports = new FnArray();
            </script>
            
            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/lib/js/modernizr-1.7.min.js</xsl:text>
                </xsl:attribute>&#160;</script>
            
            <!--<xsl:comment>SSOAR Java Script import</xsl:comment>-->
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/lib/js/ssoar.js</xsl:text>
                </xsl:attribute>&#160;</script>
            
            
            
            <xsl:if test="not(/dri:document/dri:body/dri:div[contains(@n, 'submit')])">

                 <!-- Add theme javascipt  -->
                 <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
                     <script type="text/javascript">
                         <xsl:attribute name="src">
                             <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                             <xsl:text>/themes/</xsl:text>
                             <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                             <xsl:text>/</xsl:text>
                             <xsl:value-of select="."/>
                         </xsl:attribute>&#160;</script>
                 </xsl:for-each>
                 
                 <!-- add "shared" javascript from static, path is relative to webapp root-->
                 <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
                     <script type="text/javascript">
                         <xsl:attribute name="src">
                             <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                             <xsl:text>/</xsl:text>
                             <xsl:value-of select="."/>
                         </xsl:attribute>&#160;</script>
                 </xsl:for-each>
                 
                 
                 <!-- Add a google analytics script if the key is present -->
                 <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
                     <script type="text/javascript"><xsl:text>
                            var _gaq = _gaq || [];
                            _gaq.push(['_setAccount', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>']);
                            _gaq.push(['_trackPageview']);
     
                            (function() {
                                var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                                ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                                var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                            })();
                    </xsl:text></script>
                 </xsl:if>
                
                
                
                
            </xsl:if>
            
            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                    disable-output-escaping="yes"/>
            </xsl:if>
            
            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
            <title>
                <xsl:choose>
                        <xsl:when test="not($page_title) or (string-length($page_title) &lt; 1)">
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:copy-of select="$page_title/node()" />
                        </xsl:otherwise>
                </xsl:choose>
            </title>
            
            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = '_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>
            
        </head>
    </xsl:template>
    
    
    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildHeader">
	
        <div id="header">            
            <a href="http://www.ssoar.info">
                <img class="headImg1" height="90" width="628" title="Home" alt="" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/header_logo.png')}" />
            </a>
            
            
            <div>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">option-set</xsl:with-param>
                </xsl:call-template>
                <ul class="simple-list">
                    <xsl:apply-templates select="/dri:document/dri:options/dri:list[@n='account']/dri:item" mode="nested"/>
                </ul>
            </div>
        
        </div>
        
		<div id="nav">
		    <div id="nav_main">
				<ul>
					<li>
					    <a title="xmlui.ssoar.labels.home" target="_self" href="xmlui.ssoar.links.home" i18n:attr="href title">
					        <span>
					            <i18n:text>xmlui.ssoar.buttons.home</i18n:text>
					        </span>
					    </a>
					    <!--<a target="_self" href="{@contextPath}/home.html">
							<span>
								<i18n:text>xmlui.ssoar.buttons.home</i18n:text>
							</span>
						</a>-->
					</li>
					<li>
					    <xsl:if test="/dri:document/dri:body/dri:div/@n='search'">
					        <xsl:attribute name="id">current</xsl:attribute>
					    </xsl:if>
					    <a target="_self" href="{$context-path}/discover">
							<span>
								<i18n:text>xmlui.ssoar.buttons.browsesearch</i18n:text>
							</span>
						</a>
					</li>
				    <li>
				        <xsl:if test="/dri:document/dri:body/dri:div/@n='advanced-search'">
				            <xsl:attribute name="id">current</xsl:attribute>
				        </xsl:if>
				        <a target="_self" href="{$context-path}/advanced-search">
				            <span>
				                <i18n:text>xmlui.ssoar.buttons.expertsearch</i18n:text>
				            </span>
				        </a>
				    </li>
					<li>
					    <xsl:if test="contains(/dri:document/dri:body/dri:div/@n,'submit')">
					        <xsl:attribute name="id">current</xsl:attribute>
					    </xsl:if>
					    <a target="_self" href="{$context-path}/submit">
							<span>
								<i18n:text>xmlui.ssoar.buttons.newdoc</i18n:text>
							</span>
						</a>
					</li>
				</ul>
		    </div>
	    </div>
    </xsl:template>
    
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                      />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                      />
        <xsl:variable name="handleUri">
                    <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                </xsl:for-each>
        </xsl:variable>

     <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
        <div about="{$handleUri}">
            <xsl:attribute name="style">
                <xsl:text>margin:0em 2em 0em 2em; padding-bottom:0em;</xsl:text>
            </xsl:attribute>
            <a rel="license"
                href="{$ccLicenseUri}"
                alt="{$ccLicenseName}"
                title="{$ccLicenseName}"
                >
                <img>
                     <xsl:attribute name="src">
                        <xsl:value-of select="concat($theme-path,'/images/cc-ship.gif')"/>
                     </xsl:attribute>
                     <xsl:attribute name="alt">
                         <xsl:value-of select="$ccLicenseName"/>
                     </xsl:attribute>
                     <xsl:attribute name="style">
                         <xsl:text>float:left; margin:0em 1em 0em 0em; border:none;</xsl:text>
                     </xsl:attribute>
                </img>
            </a>
            <span>
                <xsl:attribute name="style">
                    <xsl:text>vertical-align:middle; text-indent:0 !important;</xsl:text>
                </xsl:attribute>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                <xsl:value-of select="$ccLicenseName"/>
            </span>
        </div>
        </xsl:if>
    </xsl:template>


    <!-- Like the header, the footer contains various miscellanious text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        
		<div id="footer">
			<div class="logos">
				<img>
                     <xsl:attribute name="src">
                        <xsl:value-of select="concat($theme-path,'/images/logo_gesis.png')"/>
                     </xsl:attribute>
                </img>
				<img>
                     <xsl:attribute name="src">
                        <xsl:value-of select="concat($theme-path,'/images/logo_dfg.png')"/>
                     </xsl:attribute>
				</img>
			    <img>
			        <xsl:attribute name="src">
			            <xsl:value-of select="concat($theme-path,'/images/logo_oa.png')"/>
			        </xsl:attribute>
			    </img>
			</div>
		    <a title="xmlui.ssoar.labels.home" target="_self" href="xmlui.ssoar.links.home" i18n:attr="href title">
		        <i18n:text>xmlui.ssoar.labels.home</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.contact" target="_self" href="xmlui.ssoar.links.contact" i18n:attr="href title">			
		        <i18n:text>xmlui.ssoar.labels.contact</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.team" target="_self" href="xmlui.ssoar.links.team" i18n:attr="href title">			
		        <i18n:text>xmlui.ssoar.labels.team</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.legal" target="_self" href="xmlui.ssoar.links.legal" i18n:attr="href title">			
		        <i18n:text>xmlui.ssoar.labels.legal</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.concept" target="_self" href="xmlui.ssoar.links.concept" i18n:attr="href title">			
		        <i18n:text>xmlui.ssoar.labels.concept</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.sitemap" target="_self" href="xmlui.ssoar.links.sitemap" i18n:attr="href title">			
		            <i18n:text>xmlui.ssoar.labels.sitemap</i18n:text>
			</a>
			&#160;|&#160;
		    <a title="xmlui.ssoar.labels.search" target="_self" href="xmlui.ssoar.links.search" i18n:attr="href title">			
		        <i18n:text>xmlui.ssoar.labels.search</i18n:text>
			</a>
			<div class="copyright">
			    &#169; 2007 - 2012 Social Science Open Access Repository (SSOAR), powered by DSpace<br/> The content of this website is made available under a
			        <i18n:text>xmlui.ssoar.dspace.licence</i18n:text>.

			</div>
			
			<!--Invisible link to HTML sitemap (for search engines) -->
		    <xsl:if test="not(/dri:document/dri:body/dri:div[@n='submit-describe'])">
		        <a>
		            <xsl:attribute name="href">
		                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
		                <xsl:text>/htmlmap</xsl:text>
		            </xsl:attribute>
		            <xsl:comment>rien</xsl:comment>
		        </a>
		    </xsl:if>
            
		</div>
		
		<!--
            <a href="http://di.tamu.edu">
                <div id="footer-logo"></div>
            </a>
            <p>
            This website is using Manakin, a new front end for DSpace created by Texas A&amp;M University
            Libraries. The interface can be extensively modified through Manakin Aspects and XSL based Themes.
            For more information visit
            <a href="http://di.tamu.edu">http://di.tamu.edu</a> and
            <a href="http://dspace.org">http://dspace.org</a>
            </p>-->
        
    </xsl:template>
    
    
    
    <!--
        The trail is built one link at a time. Each link is given the trail-link class, with the first and
        the last links given an additional descriptor.
    -->
    <xsl:template match="dri:trail">
        <li>
            <xsl:attribute name="class">
                <xsl:text>trail-link </xsl:text>
                <xsl:if test="position()=1">
                    <xsl:text>first-link </xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>last-link</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>


    
    
<!--
        The meta, body, options elements; the three top-level elements in the schema
-->
    
    
    
    
    <!--
        The template to handle the dri:body element. It simply creates the body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->   
    <xsl:template match="dri:body"> 
        <div id="col2">   
            <div id="col2_content" class="clearfix">
                <xsl:choose>
                    <!--  does this element have any children -->
                    <!--<xsl:when test="./dri:div[@id='aspect.discovery.SimpleSearch.div.search']/node()">
                        <!-\-<xsl:apply-templates select="./dri:div[@id='aspect.discovery.SimpleSearch.div.search']/dri:div[@id='aspect.discovery.SimpleSearch.div.search-filters' and @interactive='yes']"/>-\->
                        <!-\-<xsl:apply-templates select="./dri:div[@id='aspect.discovery.SimpleSearch.div.search']/dri:div[@id='aspect.discovery.SimpleSearch.div.search-controls' and @interactive='yes']"/>-\->
                        <xsl:text>&#160;</xsl:text>                    
                    </xsl:when>-->
                    <xsl:when test="./dri:div[@n='item-view']">
                        <div id="col2_content" class="clearfix">
                          <xsl:call-template name="generateRBox">
                              <xsl:with-param name="metadataurl" select="./dri:div[@n='item-view']/dri:referenceSet[@type='summaryView']/dri:reference"/>
                          </xsl:call-template>
                        </div>
                    </xsl:when>
                    <xsl:when test="./dri:div[@n='advanced-search'] or ./dri:div[@n='search']">
                        <xsl:variable name="destination">
                            <xsl:choose>
                                <xsl:when test="./dri:div[@n='advanced-search']">advanced</xsl:when>
                                <xsl:when test="./dri:div[@n='search']">discover</xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <span class="rRline1">&#160;</span>
                        <span class="rRline2">&#160;</span>
                        <span class="rRline3">&#160;</span>
                        <span class="rRline4">&#160;</span>
                        <div class="rBox">
                        <H4>
                            <i18n:text>xmlui.ssoar.search.tutorial.head</i18n:text>
                        </H4>
                        <table class="solr-tutorial">
                            <tr>
                                <td class="solr-example"><i18n:text>xmlui.ssoar.search.tutorial.example1</i18n:text></td>
                                <td class="solr-explanation"><i18n:text>xmlui.ssoar.search.tutorial.explanation1</i18n:text></td>                                
                            </tr>
                            <tr>
                                <td class="solr-example"><i18n:text>xmlui.ssoar.search.tutorial.example2</i18n:text></td>
                                <td class="solr-explanation"><i18n:text>xmlui.ssoar.search.tutorial.explanation2</i18n:text></td>                                
                            </tr>
                            <tr>
                                <td class="solr-example"><i18n:text>xmlui.ssoar.search.tutorial.example3</i18n:text></td>
                                <td class="solr-explanation"><i18n:text>xmlui.ssoar.search.tutorial.explanation3</i18n:text></td>                                
                            </tr>
                            <tr>
                                <td class="solr-example"><i18n:text>xmlui.ssoar.search.tutorial.example4</i18n:text></td>
                                <td class="solr-explanation"><i18n:text>xmlui.ssoar.search.tutorial.explanation4</i18n:text></td>                                
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <i18n:text>xmlui.ssoar.search.tutorial.operationorder</i18n:text>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <a href="/search-info.html#{$destination}" target="_blank">
                                        <i18n:text>xmlui.ssoar.search.info</i18n:text>
                                    </a>                                
                                </td>
                            </tr>
                            
                        </table>                            
                        </div>
                        <span class="rRline4b">&#160;</span>
                        <span class="rRline3b">&#160;</span>
                        <span class="rRline2b">&#160;</span>
                        <span class="rRline1b">&#160;</span>
                    </xsl:when>
                    <!-- show countdown timer during submission -->
                    <xsl:when test="//dri:body/dri:div[@rend='primary submission']">
                        <span class="rRline1">&#160;</span>
                        <span class="rRline2">&#160;</span>
                        <span class="rRline3">&#160;</span>
                        <span class="rRline4">&#160;</span>
                        <div class="rBox">
                            <h3 id="timerHead">
                                <i18n:text>xmlui.ssoar.labels.logout.timer</i18n:text>
                            </h3>
                            <span id="logoutTime">
                                <div id="SetIdleTime">&#160;</div>
                                <div id="timeMeasure">
                                    <i18n:text>xmlui.ssoar.labels.logout.time</i18n:text>
                                </div>
                            </span>
                        </div>     
                        <span class="rRline4b">&#160;</span>
                        <span class="rRline3b">&#160;</span>
                        <span class="rRline2b">&#160;</span>
                        <span class="rRline1b">&#160;</span>
                    </xsl:when>
                    <!-- if no children are found we add a space to eliminate self closing tags -->
                    <xsl:otherwise>
                        <xsl:comment>rien</xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
		<div id="col3">
		    <xsl:choose>
		        <xsl:when test="contains(/dri:document/dri:div/@n,'submit')">
		            <div id="editformdiv" class="editformDiv">
		                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
		                    <div id="system-wide-alert">
		                        <p>
		                            <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
		                        </p>
		                    </div>
		                </xsl:if>
		                <xsl:apply-templates />
		                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='sfx'][@qualifier='server']">
		                    <a>
		                        <xsl:attribute name="href">
		                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='sfx'][@qualifier='server']"/>
		                        </xsl:attribute>
		                        <xsl:text>Find Full text</xsl:text>
		                    </a>
		                </xsl:if>
	                </div>
		        </xsl:when>
		        <xsl:otherwise>
		            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
		                <div id="system-wide-alert">
		                    <p>
		                        <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
		                    </p>
		                </div>
		            </xsl:if>
					<div id="col3_content" class="clearfix">
						<xsl:apply-templates />
					</div>
		            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='sfx'][@qualifier='server']">
		                <a>
		                    <xsl:attribute name="href">
		                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='sfx'][@qualifier='server']"/>
		                    </xsl:attribute>
		                    <xsl:text>Find Full text</xsl:text>
		                </a>
		            </xsl:if>
		        </xsl:otherwise>
		    </xsl:choose>
		    
		</div>
    </xsl:template>
    
    <xsl:template name="generateRBox">
        <xsl:param name="metadataurl"/>        
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataurl/@url"/>
            <!--<xsl:text>?sections=dmdSec,fileSec</xsl:text>-->
        </xsl:variable>        
        <xsl:variable name="itemID" select="substring-after(document($externalMetadataURL)/mets:METS/@OBJEDIT,'itemID=')"/>
        <xsl:variable name="dimNode" select="document($externalMetadataURL)/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
        <xsl:variable name="urn">
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
        </xsl:variable>        
        <xsl:variable name="urnprefix">http://nbn-resolving.de/</xsl:variable> 
        <xsl:variable name="filepath">
            <xsl:value-of select="document($externalMetadataURL)/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
        </xsl:variable>
        
        <span class="rRline1">&#160;</span>
        <span class="rRline2">&#160;</span>
        <span class="rRline3">&#160;</span>
        <span class="rRline4">&#160;</span>
        <div class="rBox">
            <div class="news-latest-container">
                <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']/text()!='' or
                    $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()!=''">
                    <div class="news-latest-item">
                        <p>
                            <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']/text()!=''">
                                <i18n:text>xmlui.ssoar.labels.morefrom</i18n:text>												
                                <xsl:for-each select="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
                                    <xsl:variable name="curAuthor" select="./text()"/> 
                                    <xsl:variable name="authorLink">
                                        <xsl:value-of select="java:java.net.URLEncoder.encode($curAuthor, 'UTF-8')"/>
                                    </xsl:variable>
                                    <a href="{$context-path}/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={$authorLink}"> 
                                        <xsl:value-of select="$curAuthor"/>                                                     
                                    </a>
                                    <xsl:if test="position()!=last()">; </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='article'
                                and $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()!=''">
                                <xsl:variable name="journal">
                                    <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()"/>
                                </xsl:variable>
                                <xsl:variable name="journalLink">
                                    <xsl:value-of select="java:java.net.URLEncoder.encode($journal, 'UTF-8')"/>
                                </xsl:variable>                                
                                <br/>
                                <i18n:text>xmlui.ssoar.labels.morefrom</i18n:text>
                                <a href="{$context-path}/discover?filtertype=journal&amp;filter_relational_operator=equals&amp;filter={$journalLink}">  
                                    <xsl:value-of select="$journal"/>                                                     
                                </a>
                            </xsl:if>
                        </p>												
                    </div>
                </xsl:if>
                
                
                
                <div class="news-latest-item">
                    
                    <h3 style="color:#360">
                        <i18n:text>xmlui.ssoar.labels.exportlit</i18n:text>
                    </h3>
                    <p>
                        <i18n:text>xmlui.ssoar.labels.exporttext</i18n:text>                        
                        <br/>                        
                        <a target="_blank" href="{substring-after($requestURI, 'document/')}?style=bibtex">
                            <i18n:text>xmlui.ssoar.labels.bibtex</i18n:text>   
                        </a>
                        <br/>
                        <a target="_blank" href="{substring-after($requestURI, 'document/')}?style=endnote">
                            <i18n:text>xmlui.ssoar.labels.endnote</i18n:text>  
                        </a>                        
                    </p>
                    
                </div>
                <xsl:if test="not($dimNode[@withdrawn='y'])">
                    <xsl:call-template name="displaySatistics">
                        <xsl:with-param name="itemID" select="$itemID"/>
                    </xsl:call-template>
                </xsl:if>
            </div>
        </div>
        <span class="rRline4b">&#160;</span>
        <span class="rRline3b">&#160;</span>
        <span class="rRline2b">&#160;</span>
        <span class="rRline1b">&#160;</span>
		
		<div id="infolisButton" style="display: none;">
			<span class="rRline1">&#160;</span>
			<span class="rRline2">&#160;</span>
			<span class="rRline3">&#160;</span>
			<span class="rRline4">&#160;</span>
			<div class="rBox">
				<div class="news-latest-container">
					<div class="news-latest-item" >                    
						<h3 onclick="javascript:displayInfolisPopup('{$urn}');" style="color:#360; cursor: pointer;" >verknüpfte Forschungsdaten anzeigen</h3>
						<input type="hidden" id="urn" value="{$urn}"></input>					
					</div>
				</div>
			</div>
			<span class="rRline4b">&#160;</span>
			<span class="rRline3b">&#160;</span>
			<span class="rRline2b">&#160;</span>
			<span class="rRline1b">&#160;</span>
        </div>
        
        <!-- AddThis Button BEGIN -->
        <div class="news-latest-item">
            <br />
            <h3 style="color: rgb(51, 102, 0);"> Weiterempfehlen </h3>
            <script type="text/javascript">var addthis_pub="ssoar";</script>
            <p style="line-height: 1em;">
                <a href="//www.addthis.com/bookmark.php?v=20" onmouseover="return addthis_open(this, '', '[URL]', '[TITLE]')" onmouseout="addthis_close()" onclick="return addthis_sendto()"><img src="//s7.addthis.com/static/btn/lg-share-en.gif" width="125" height="16" alt="Bookmark and Share" style="border:0" /></a>
            </p>
            <script type="text/javascript" src="//s7.addthis.com/js/200/addthis_widget.js">sampleTextForScriptNotToBeEmpty</script> 
            <br />
        </div>
        <!-- AddThis Button END -->
        
    </xsl:template>
    
    <xsl:template name="displaySatistics">
        <xsl:param name="itemID"/>
        
        <!-- new statistics button. statistics are pulled through javascript. -->
        <div id="statistics" class="news-latest-item">
            <h3 style="color:#360">                
                <a href="javascript:getStatistics({$itemID},'{$languageiso}','{$protocol}')" style="color:#360">
                    <i18n:text>xmlui.ssoar.labels.statistics.display</i18n:text>
                </a>
            </h3>
        </div>
    </xsl:template>

    <!--
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the options div and applying
        the templates inside it.
        
        In fact, the only bit of real work this template does is add the search box, which has to be
        handled specially in that it is not actually included in the options div, and is instead built
        from metadata available under pageMeta.
    -->
    <!-- TODO: figure out why i18n tags break the go button -->
    <xsl:template match="dri:options">
        <div id="col1">
            <xsl:choose>
                <xsl:when test="//dri:document/dri:body/dri:div[contains(@n,'submit')]">
                    <div id="col1_content">
                        <xsl:choose>
                            <xsl:when test="//dri:document/dri:body/dri:div/dri:list[@n='submit-progress']">
                                <xsl:apply-templates select="//dri:document/dri:body/dri:div/dri:list[@n='submit-progress']"/>         
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>                                               
                    </div>
                </xsl:when>
                <xsl:when test="./dri:list[@n='browse'] 
                    and contains(../dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI']/text(), 'discover')">
                    <!--<xsl:value-of select="/dri:document/dri:body/dri:div[@n='search']/dri:div[@n='discovery-search-box']/dri:div[@n='search-filters' and @interactive='yes']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']"/>-->
                    <xsl:if test="contains(/dri:document/dri:body/dri:div[@n='search']/dri:div[@n='discovery-search-box']/dri:div[@n='search-filters' and @interactive='yes']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']/dri:row/@n,'used-filters')">                        
                        <!--<xsl:apply-templates select="/dri:document/dri:body/dri:div[@n='search']/dri:div[@n='discovery-search-box']/dri:div[@n='search-filters' and @interactive='yes']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']"/>-->
                        <!--<xsl:value-of select="/dri:document/dri:body/dri:div[@n='search']/dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:p[@n='hidden-fields']/@n"/>-->
                        <xsl:variable name="filter_node" select="/dri:document/dri:body/dri:div[@n='search']/dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:p[@n='hidden-fields']"/>                        
                        
                        <form action="discover"
                            method="get"
                            accept-charset="UTF-8"
                            onsubmit="javascript:tSubmit(this);">
                            <fieldset id="aspect_discovery_SimpleSearch_list_secondary-search" class="form-list">
                            <legend>selected Filters</legend>
                                <ol xmlns="http://di.tamu.edu/DRI/1.0/">
                                    <li id="aspect_discovery_SimpleSearch_item_used-filters" class="form-item used-filters-list">
                                        <div class="form-content">
                                             <xsl:for-each select="$filter_node/dri:field[starts-with(@n,'filter_') and not(starts-with(@n,'filter_relational_'))]">
                                                 <!-- due to no know reason the xml filter counting differs from the actual query parameter. Therefor we have to substract 1 from the counting, THX guys -->
                                                 <xsl:variable name="counter" select="number(substring-after(./@n,'filter_'))"/>
                                                 <xsl:variable name="value" select="./dri:value[@type='raw']/text()"/>
                                                 <xsl:variable name="counterString">
                                                     <xsl:call-template name="getFilterCount">
                                                         <xsl:with-param name="value" select="$value"/>
                                                     </xsl:call-template>
                                                 </xsl:variable>                                                 
                                                 <xsl:variable name="type" select="$filter_node/dri:field[@n=concat('filtertype_',$counter)]/dri:value[@type='raw']/text()"/>
                                                   
                                                 <xsl:comment>
                                                     <xsl:text>filtertype :</xsl:text> <xsl:value-of select="$type"/>
                                                     <xsl:text> - filtervalue : </xsl:text> <xsl:value-of select="$value"/>
                                                     <xsl:text> - counterString : </xsl:text> <xsl:value-of select="$counterString"/>                                                   
                                                 </xsl:comment>
                                                 
                                                 <fieldset id="filter{$counterString}" class="checkbox-field">
                                                     <label>
                                                         <!-- due to no know reason the xml filter counting differs from the actual query parameter, we have to modify the remove-link, THX guys -->
                                                         <xsl:choose>
                                                             <xsl:when test="$counterString = ''">
                                                                 <a href="javascript:void(0)" onclick="javascript:removeParameters(['filter','filtertype','filter_relational_operator']);">
                                                                     <img class="remove" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/edit-removevalue.png')}" />
                                                                     <xsl:text> </xsl:text>
                                                                     <i18n:text>xmlui.ArtifactBrowser.SimpleSearch.filter.<xsl:value-of select="$type"/></i18n:text>
                                                                     <xsl:text>: </xsl:text>
                                                                     <xsl:call-template name="filterValue">
                                                                         <xsl:with-param name="type" select="$type"/>
                                                                         <xsl:with-param name="value" select="$value"/>
                                                                     </xsl:call-template>
                                                                 </a>
                                                             </xsl:when>
                                                             <xsl:otherwise>                                                                 
                                                                 <a href="javascript:void(0)" onclick="javascript:removeParameters(['filter{$counterString}','filtertype{$counterString}','filter_relational_operator{$counterString}']);">
																	 <img class="remove" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/edit-removevalue.png')}" />
                                                                     <xsl:text> </xsl:text>
                                                                        <i18n:text>xmlui.ArtifactBrowser.SimpleSearch.filter.<xsl:value-of select="$type"/></i18n:text>
                                                                     <xsl:text>: </xsl:text>
                                                                     <xsl:call-template name="filterValue">
                                                                         <xsl:with-param name="type" select="$type"/>
                                                                         <xsl:with-param name="value" select="$value"/>
                                                                     </xsl:call-template>                                                                     
                                                                 </a>
                                                             </xsl:otherwise>
                                                         </xsl:choose>
                                                         
                                                     </label>
                                                 </fieldset>
                                             </xsl:for-each>                               
                                        </div>
                                    </li>
                                </ol>
                            </fieldset>
                           <!-- <p id="aspect_discovery_SimpleSearch_p_hidden-fields" class="paragraph hidden">
                                <input id="aspect_discovery_SimpleSearch_field_filtertype_0"
                                    class="hidden-field"
                                    name="filtertype_0"
                                    type="hidden"
                                    value="author"/>
                                
                                
                                
                            </p>-->
                            
                        </form>
                    </xsl:if>
                    <div id="col1_content">
                        <ul id="submenu">
                            <li>                                
                                <xsl:apply-templates select="./dri:list[@n='browse']/dri:list[@n='global']/dri:item/dri:xref"/> 
                            </li>                            
                            <xsl:apply-templates />   
                        </ul>
                    </div>
                </xsl:when>
                <xsl:otherwise>                    
                    <!-- Once the search box is built, the other parts of the options are added -->
                    <xsl:apply-templates />        
                </xsl:otherwise>
            </xsl:choose>
            
            

            <!-- 984 Add RSS Links to Options Box -->
            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']) != 0">
                <h3 id="feed-option-head" class="option-set-head">
                    <i18n:text>xmlui.feed.header</i18n:text>
                </h3>
                <div id="feed-option" class="option-set">
                    <ul>
                        <xsl:call-template name="addRSSLinks"/>
                    </ul>
                </div>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
        </div>
    </xsl:template>
    
    <xsl:template name="filterValue">
        <xsl:param name="type"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$type = 'documentType'">
                <i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="$value"/></i18n:text>
            </xsl:when>
            <xsl:when test="$type = 'pubstatus'">
                <i18n:text>xmlui.ssoar.convoc.pubstatus.<xsl:value-of select="$value"/></i18n:text>
            </xsl:when>
            <xsl:when test="$type = 'review'">
                <i18n:text>xmlui.ssoar.convoc.review.<xsl:value-of select="$value"/></i18n:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>    
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getFilterCount">
        <xsl:param name="value"/>
        <xsl:variable name="encodedValue">
            <xsl:value-of select="java:java.net.URLEncoder.encode($value, 'UTF-8')"/>            
        </xsl:variable>
        
        <xsl:variable name="query">
            <xsl:value-of select="substring-before($requestQueryString, concat('=',$encodedValue))"/>    
        </xsl:variable>
        <xsl:call-template name="extractCount">
            <xsl:with-param name="string" select="$query"/>
            <xsl:with-param name="element" select="'filter'"></xsl:with-param>
        </xsl:call-template>       
    </xsl:template>
    
    <xsl:template name="extractCount">
        <!--passed template parameter -->
        <xsl:param name="string"/>
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="contains($string, $element)">
                <xsl:call-template name="extractCount">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="string" select="substring-after($string,$element)"/>
                    <xsl:with-param name="element" select="$element"/>
                </xsl:call-template>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>
    
    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->
    
    
      
    
    
    
    
    
<!--
        Structural elements from here on out. These are the tags that contain static content under body, i.e.
        lists, tables and divs. They are also used in making forms and referencing metadata from the object
        store through the use of reference elements. The lists used by options also have templates here.
-->
    
    
    
    
    <!-- First and foremost come the div elements, which are the only elements directly under body. Every
        document has a body and every body has at least one div, which may in turn contain other divs and
        so on. Divs can be of two types: interactive and non-interactive, as signified by the attribute of
        the same name. The two types are handled separately.
    -->
    
    <!-- Non-interactive divs get turned into HTML div tags. The general process, which is found in many
        templates in this stylesheet, is to call the template for the head element (creating the HTML h tag),
        handle the attributes, and then apply the templates for the all children except the head. The id
        attribute is -->
    <xsl:template match="dri:div" priority="1">        
		<xsl:choose>
		    <xsl:when test="@rend='license-text' or (@n='completed-submissions' and $ssoarEditor='true')">
		        <!-- don't display the regular licence text-->
		    </xsl:when>
			<xsl:when test="@id='aspect.discovery.SimpleSearch.div.search-results'
				and $requestURI='discover'
				and ../dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value
				and not(string(../dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value/text()))
				and not(contains(../dri:div[@n='discovery-search-box']/dri:div[@n='search-filters']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']/dri:row/@rend,'used-filter'))">
                <!--<div name="test">
                    <xsl:value-of select="../dri:div[@n='discovery-search-box']/dri:div[@n='search-filters']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']/dri:row/@rend"/>
                </div>-->
				<xsl:call-template name="createCommunityOverview"/>
			</xsl:when>
		    <xsl:when test="./dri:div[@n='notice']/dri:p/i18n:text/text()='xmlui.ArtifactBrowser.ItemViewer.withdrawn'">
		        <xsl:variable name="handle">
		            <xsl:value-of select="substring-after(//dri:meta/dri:pageMeta/dri:metadata[@element='focus' and @qualifier='object']/text(),'hdl:')"/>
		        </xsl:variable>		        	        
		        <xsl:variable name="externalMetadataURL">
		            <xsl:text>cocoon://metadata/handle/</xsl:text>
		            <xsl:value-of select="$handle"/>
		            <xsl:text>/mets.xml</xsl:text>                    
		            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
		            <xsl:text>?sections=dmdSec</xsl:text>                    
		        </xsl:variable>
		        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
		        <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryView"/>
		    </xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="dri:head"/>
				<xsl:apply-templates select="@pagination">
					<xsl:with-param name="position">top</xsl:with-param>
				</xsl:apply-templates>
				<xsl:choose>
				    <xsl:when test="@n='search-results'">
						<table class="resultTable">                   
							<xsl:choose>
								<!--  does this element have any children -->
								<xsl:when test="child::node()">
									<xsl:apply-templates select="*[not(name()='head')]"/>
								</xsl:when>
								<!-- if no children are found we add a space to eliminate self closing tags -->
								<xsl:otherwise>
									&#160;
								</xsl:otherwise>
							</xsl:choose>                    
						</table>
					</xsl:when>
					<xsl:otherwise>            
						<xsl:choose>
							<!--  does this element have any children -->
							<xsl:when test="child::node()">
								<xsl:apply-templates select="*[not(name()='head' or
									(name()='div' and @id='aspect.discovery.SimpleSearch.div.search-filters')									
									)]"/>     
							    <!-- former filter:(name()='div' and @id='aspect.discovery.SimpleSearch.div.search-controls') -->
							</xsl:when>
							<!-- if no children are found we add a space to eliminate self closing tags -->
							<xsl:otherwise>
								&#160;
							</xsl:otherwise>
						</xsl:choose>
						
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="itemDivision">
					<xsl:value-of select="@n"/>
				</xsl:variable>
				<xsl:variable name="xrefTarget">
					<xsl:value-of select="./dri:p/dri:xref/@target"/>
				</xsl:variable>
				<xsl:if test="$itemDivision='item-view'">
					<xsl:call-template name="cc-license">
						<xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:apply-templates select="@pagination">
					<xsl:with-param name="position">bottom</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>        
       
    </xsl:template>
    
    <!-- Interactive divs get turned into forms. The priority attribute on the template itself
        signifies that this template should be executed if both it and the one above match the
        same element (namely, the div element).
        
        Strictly speaking, XSL should be smart enough to realize that since one template is general
        and other more specific (matching for a tag and an attribute), it should apply the more
        specific once is it encounters a div with the matching attribute. However, the way this
        decision is made depends on the implementation of the XSL parser is not always consistent.
        For that reason explicit priorities are a safer, if perhaps redundant, alternative. -->
    <xsl:template match="dri:div[@interactive='yes']" priority="2">
        <xsl:choose>
            <xsl:when test="contains(@n,'submit')">                
                <div class="editformText">
                    <h1>
                        <xsl:apply-templates select="./dri:head/i18n:text"/>
                    </h1>                    
                </div>
            </xsl:when>
            <xsl:otherwise>
					<xsl:apply-templates select="dri:head"/>
					<xsl:apply-templates select="@pagination">
						<xsl:with-param name="position">top</xsl:with-param>
					</xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
            <xsl:when test="@n='general-query'">
                <form class="queryForm" action="index.php" method="get" accept-charset="UTF-8">
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">interactive-div</xsl:with-param>
                    </xsl:call-template>
                    <xsl:attribute name="action"><xsl:value-of select="@action"/></xsl:attribute>
                    <xsl:attribute name="method"><xsl:value-of select="@method"/></xsl:attribute>
                    <!--            <xsl:attribute name="style"><xsl:text>border:none;</xsl:text></xsl:attribute>-->
                    <xsl:if test="@method='multipart'">
                        <xsl:attribute name="method">post</xsl:attribute>
                        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="onsubmit">javascript:tSubmit(this);</xsl:attribute>
                    <!--For Item Submission process, disable ability to submit a form by pressing 'Enter'-->
                    <xsl:if test="starts-with(@n,'submit')">
                        <xsl:attribute name="onkeydown">javascript:return disableEnterKey(event);</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="*[not(name()='head')]"/>
                
                <!-- EVIL-HACK: filter results for empty query and display CommunityOverview -->                
                <xsl:if test="not(@id='aspect.discovery.SimpleSearch.div.search-results'
                    and $requestURI='discover'
                    and ../dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value
                    and not(string(../dri:div[@n='discovery-search-box']/dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value/text()))
                    and not(contains(../dri:div[@n='discovery-search-box']/dri:div[@n='search-filters']/dri:div[@n='discovery-filters-wrapper']/dri:table[@n='discovery-filters']/dri:row/@rend,'used-filter')))">
                    <!--<form onsubmit="javascript:tSubmit(this);" method="get" action="discover">-->
                    
                    <!-- EVIL-HACK: the following lines are extremly dirty due to changes in DSpace 3.x the whole sort-options had to be hacked, to remain the same in discovery and advanced search -->
                    <xsl:variable name="rpp" select="./dri:p[@n='hidden-fields']/dri:field[@n='rpp']/dri:value/text()"/>
                    <xsl:variable name="sort_by" select="./dri:p[@n='hidden-fields']/dri:field[@n='sort_by']/dri:value/text()"/>
                    <xsl:variable name="order" select="./dri:p[@n='hidden-fields']/dri:field[@n='order']/dri:value/text()"/>
                    
                    <div class="form-content search-controls">
                        <i18n:text catalogue="default">xmlui.ArtifactBrowser.AbstractSearch.rpp</i18n:text>                       
                        
                        <select name="rpp" class="select-field" id="aspect_discovery_SimpleSearch_field_rpp" xmlns="http://www.w3.org/1999/xhtml">
                            <option value="5"><xsl:if test="$rpp='5'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>5</xsl:text></option>
                            <option value="10"><xsl:if test="$rpp='10' or not($rpp)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>10</xsl:text></option>
                            <option value="20"><xsl:if test="$rpp='20'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>20</xsl:text></option>
                            <option value="40"><xsl:if test="$rpp='40'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>40</xsl:text></option>
                            <option value="60"><xsl:if test="$rpp='60'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>60</xsl:text></option>
                            <option value="80"><xsl:if test="$rpp='80'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>80</xsl:text></option>
                            <option value="100"><xsl:if test="$rpp='100'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:text>100</xsl:text></option>
                        </select>
                        <i18n:text catalogue="default">xmlui.ArtifactBrowser.AbstractSearch.sort_by</i18n:text>
                        <select name="sort_by" class="select-field" id="aspect_discovery_SimpleSearch_field_sort_by" xmlns="http://www.w3.org/1999/xhtml">
                            <option value="score"  xmlns="http://di.tamu.edu/DRI/1.0/"><xsl:if test="$sort_by='score' or not($sort_by)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><i18n:text>xmlui.ArtifactBrowser.AbstractSearch.sort_by.relevance</i18n:text></option>
                            <option value="dc.title_sort" xmlns="http://di.tamu.edu/DRI/1.0/"><xsl:if test="$sort_by='dc.title_sort'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><i18n:text>xmlui.ArtifactBrowser.AbstractSearch.sort_by.dc.title_sort</i18n:text></option>
                            <option value="dc.date.issued_dt" xmlns="http://di.tamu.edu/DRI/1.0/"><xsl:if test="$sort_by='dc.date.issued_dt'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><i18n:text>xmlui.ArtifactBrowser.AbstractSearch.sort_by.dc.date.issued_sort</i18n:text></option>
                        </select>
                        <i18n:text catalogue="default">xmlui.ArtifactBrowser.AbstractSearch.order</i18n:text>
                        
                        <select name="order" class="select-field" id="aspect_discovery_SimpleSearch_field_order" xmlns="http://www.w3.org/1999/xhtml">
                            <option value="ASC"><xsl:if test="$order='ASC'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><i18n:text>xmlui.ArtifactBrowser.AbstractSearch.order.asc</i18n:text></option>
                            <option value="DESC" xmlns="http://di.tamu.edu/DRI/1.0/"><xsl:if test="$order='DESC' or not($order)"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><i18n:text>xmlui.ArtifactBrowser.AbstractSearch.order.desc</i18n:text></option>
                        </select>
                        <input type="submit" name="submit_sort" class="button-field" id="aspect_discovery_SimpleSearch_field_submit_sort" value="xmlui.Discovery.SimpleSearch.sort_apply" xmlns="http://di.tamu.edu/DRI/1.0/" i18n:attr="value"/>
                    </div>
                </xsl:if>    
                </form>
                
            </xsl:when>
            <xsl:when test="./@id='aspect.discovery.SimpleSearch.div.main-form'">
                <!--<xsl:text>&#160;</xsl:text>-->
            </xsl:when>
            <xsl:otherwise>
                <form>					
                    <xsl:if test="contains(@n,'submit')">
                        <xsl:attribute name="id">aspect_submission_StepTransformer_div_submit-describe</xsl:attribute>
                        <xsl:attribute name="class">ds-interactive-div primary submission</xsl:attribute>
                    </xsl:if>
                    <!--<xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">interactive-div</xsl:with-param>
                    </xsl:call-template>-->
                    <xsl:attribute name="action"><xsl:value-of select="@action"/></xsl:attribute>
                    <xsl:attribute name="method"><xsl:value-of select="@method"/></xsl:attribute>
                    <!--            <xsl:attribute name="style"><xsl:text>border:none;</xsl:text></xsl:attribute>-->
                    <xsl:if test="@method='multipart'">
                        <xsl:attribute name="method">post</xsl:attribute>
                        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="onsubmit">javascript:tSubmit(this);</xsl:attribute>
                    <!--For Item Submission process, disable ability to submit a form by pressing 'Enter'-->
                    <xsl:if test="starts-with(@n,'submit')">
                        <xsl:attribute name="onkeydown">javascript:return disableEnterKey(event);</xsl:attribute>
                    </xsl:if>
					<xsl:apply-templates select="*[not(name()='head' or
					(name()='list' and @n='submit-progress')
					)]"/>
                    
                </form>
            </xsl:otherwise>
        </xsl:choose>
       
        <!-- JS to scroll form to DIV parent of "Add" button if jump-to -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo']">
          <script type="text/javascript">
            <xsl:text>var button = document.getElementById('</xsl:text>
            <xsl:value-of select="translate(@id,'.','_')"/>
            <xsl:text>').elements['</xsl:text>
            <xsl:value-of select="concat('submit_',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo'],'_add')"/>
            <xsl:text>'];</xsl:text>
            <xsl:text>
                      if (button != null) {
                        var n = button.parentNode;
                        for (; n != null; n = n.parentNode) {
                            if (n.tagName == 'DIV') {
                              n.scrollIntoView(false);
                              break;
                           }
                        }
                      }
            </xsl:text>
          </script>
        </xsl:if>
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">bottom</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <!-- Special case for divs tagged as "notice" -->
    <xsl:template match="dri:div[@n='general-message']" priority="3">
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">notice-div</xsl:with-param>
            </xsl:call-template>
                <xsl:apply-templates />
        </div>
    </xsl:template>
    
    
    <!-- Next come the three structural elements that divs that contain: table, p, and list. These are
        responsible for display of static content, forms, and option lists. The fourth element under
        body, referenceSet, is used to reference blocks of metadata and will be discussed further down.
    -->
    
    
    <!-- First, the table element, used for rendering data in tabular format. In DRI tables consist of
        an optional head element followed by a set of row tags. Each row in turn contains a set of cells.
        Rows and cells can have different roles, the most common ones being header and data (with the
        attribute omitted in the latter case). -->
    <xsl:template match="dri:table">
        <xsl:apply-templates select="dri:head"/>
                <xsl:variable name="queryString">
            <xsl:value-of select="$context-path"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$requestURI"/>
            <xsl:text>?</xsl:text>
        </xsl:variable> 
        <xsl:if test="@n='workflow-tasks' and contains(dri:head/i18n:text/text(), 'head3')">
            <i18n:text>xmlui.ssoar.labels.filter.user</i18n:text>
            <a class="userfilter" href="{concat($queryString,'submissionFilter=external')}">external</a>
            <a class="userfilter" href="{concat($queryString,'submissionFilter=import')}">import</a>
            <a class="userfilter" href="{concat($queryString,'submissionFilter=usbkoeln')}">USB Köln</a>
            <a class="userfilter" href="{concat($queryString,'submissionFilter=harvest')}">harvest</a>   
            <a class="userfilter" href="{concat($queryString,'submissionFilter=editors')}">editors</a>
            <a class="userfilter" href="{concat($queryString,'submissionFilter=DIFM')}">DIFM</a>
            <a class="userfilter" href="{$queryString}">all</a>
        </xsl:if>
        <table>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">table</xsl:with-param>
            </xsl:call-template>
            <!-- rows and cols atributes are not allowed in strict
            <xsl:attribute name="rows"><xsl:value-of select="@rows"/></xsl:attribute>
            <xsl:attribute name="cols"><xsl:value-of select="@cols"/></xsl:attribute>

            <xsl:if test="count(dri:row[@role='header']) &gt; 0">
                    <thead>
                        <xsl:apply-templates select="dri:row[@role='header']"/>
                    </thead>
            </xsl:if>
            <tbody>
                <xsl:apply-templates select="dri:row[not(@role='header')]"/>
            </tbody>
            -->
            <xsl:apply-templates select="dri:row"/> 
         </table>
        <!--<xsl:choose>
            <xsl:when test="@n='search-query'">
                <div class="search-info">                    
                    <a href="/search-info.html#advanced">
                        <i18n:text>xmlui.ssoar.search.info</i18n:text>
                    </a>
                </div>
            </xsl:when>           
        </xsl:choose>-->
        
    </xsl:template>
    
    <!-- Header row, most likely filled with header cells -->
    <xsl:template match="dri:row[@role='header']" priority="2">
        <tr>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">table-header-row</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </tr>
    </xsl:template>
    
    <!-- Header cell, assumed to be one since it is contained in a header row -->
    <xsl:template match="dri:row[@role='header']/dri:cell | dri:cell[@role='header']" priority="2">
        <th>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">table-header-cell
                    <xsl:if test="(position() mod 2 = 0)">even</xsl:if>
                    <xsl:if test="(position() mod 2 = 1)">odd</xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="@rows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rows"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@cols"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </th>
    </xsl:template>
    
    
    <!-- Normal row, most likely filled with data cells -->
    <xsl:template match="dri:row" priority="1">
        <!-- EVIL-HACK: insert stock change selection -->
        <xsl:if test="./dri:cell/dri:field/@n='submit_leave' and ../../@n='perform-task'">
            <xsl:call-template name="stockSelection"/>   
        </xsl:if>
        <xsl:variable name="username">
            <xsl:for-each select="dri:cell">
                <xsl:if test="contains(./dri:xref/@target,'mailto:')">
                    <xsl:value-of select="./dri:xref/text()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="mailadress">
            <xsl:for-each select="dri:cell">
                <xsl:if test="contains(./dri:xref/@target,'mailto:')">
                    <xsl:value-of select="substring-after(./dri:xref/@target,'mailto:')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="filterUser">
            <xsl:choose>
                <xsl:when test="$submissionFilter = 'external'">
                    <xsl:choose>
                        <xsl:when test="contains($userList,$username) 
                            or contains($userList,$mailadress)">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$submissionFilter = 'all'">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="contains($userList,$username) 
                            or contains($userList,$mailadress)">
                            <xsl:value-of select="false()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="true()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--EVIL-HACK: filter submission list depending on users specified in submissionFilter parameter-->
        <xsl:if test="not(../@n='workflow-tasks' and contains(../dri:head/i18n:text/text(), 'head3')) 
            or $filterUser='false'">
            <tr>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">table-row
                        <xsl:if test="(position() mod 2 = 0)">even</xsl:if>
                        <xsl:if test="(position() mod 2 = 1)">odd</xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates />
            </tr>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="stockSelection">
        <!--<xsl:variable name="ChangeStock">http://localhost:8080/intern/groovy/ChangeStock.groovy?</xsl:variable>-->
        <xsl:variable name="ChangeStock">http://www.ssoar.info/intern/groovy/ChangeStock.groovy?</xsl:variable>
        <xsl:variable name="queryString" select="//dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='queryString']/text()"/>       
        <xsl:variable name="metsXML" select="//dri:document/dri:body/dri:div[@rend='primary workflow']/dri:referenceSet/dri:reference[@repositoryID='document']/@url"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metsXML"/>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <xsl:text>?sections=dmdSec</xsl:text>
            <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
                <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
                </xsl:if>-->
        </xsl:variable>
        <xsl:variable name="curStock" select="document($externalMetadataURL)/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='stock']/text()"/>
        <tr>
            <td class="table-cell odd">
                <i18n:text>xmlui.ssoar.labels.stock.info</i18n:text>
            </td>
            <td class="table-cell even" xmlns="http://di.tamu.edu/DRI/1.0/">
                <xsl:value-of select="$curStock"/>
            </td>
        </tr>        
        <tr>
            <td id="stockexchange" colspan="2">
                <i18n:text>xmlui.ssoar.labels.stock.change</i18n:text>
                <a href="{concat($ChangeStock,$queryString,'&amp;collectionID=1')}">article</a>
                <a href="{concat($ChangeStock,$queryString,'&amp;collectionID=2')}">monograph</a>                
                <a href="{concat($ChangeStock,$queryString,'&amp;collectionID=3')}">incollection</a>
                <a href="{concat($ChangeStock,$queryString,'&amp;collectionID=4')}">collection</a>
                <a href="{concat($ChangeStock,$queryString,'&amp;collectionID=5')}">recension</a>
            </td>
        </tr>  
    </xsl:template>
    
    <!-- Just a plain old table cell -->
    <xsl:template match="dri:cell" priority="1">        
        <td>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">table-cell
                    <xsl:if test="(position() mod 2 = 0)">even</xsl:if>
                    <xsl:if test="(position() mod 2 = 1)">odd</xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="@rows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rows"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@cols"/>
                </xsl:attribute>
            </xsl:if>            
            <!-- EVIL-HACK: use i18n values for controlled vocabularies -->
            <xsl:choose>
               <!-- <xsl:when test="contains(../../@n,'thesoz') 
                    or contains(../../@n,'classoz')
                    or contains(../../@n,'documentType')
                    or contains(../../@n,'review')
                    or contains(../../@n,'pubstatus')
                    or contains(../../@n,'methods')">-->
                <xsl:when test="contains(../../@n,'documentType')
                    or contains(../../@n,'review')
                    or contains(../../@n,'pubstatus')
                    or contains(../../@n,'methods')">
                    <xsl:call-template name="discovery-identifier">
                        <xsl:with-param name="item" select="."/>
                    </xsl:call-template>                                                
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose> 
            <!--<xsl:apply-templates />-->
        </td>
    
        <xsl:if test="../../@n='search-controls' and ./dri:field[@n='order']">
            <td id="go-button">                    
                <xsl:apply-templates select="../../../dri:p[@rend='button-list']/dri:field"/>    
            </td>                
        </xsl:if>
    </xsl:template>
    
    
    
      
    
    
    <!-- Second, the p element, used for display of text. The p element is a rich text container, meaning it
        can contain text mixed with inline elements like hi, xref, figure and field. The cell element above
        and the item element under list are also rich text containers.
    -->
    <xsl:template match="dri:p">
        <!--EVIL-HACK: don't display shoe full metadata and not display go-button in advanced-search-->	
        <xsl:if test="( not(contains(@rend, 'item-view-toggle') 
            or contains(dri:field/@n, 'showfull')) )
            and not(@rend='button-list' and ../@action='advanced-search')
            and not(../@n='withdrawn')">
            <p>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">paragraph</xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <!--EVIL-HACK get rid of starts-with for documentType -->
                    <xsl:when test="./dri:field[@n='starts_with'] and contains(../../@n, 'documentType')">
                        <!-- just don't do anything-->
                    </xsl:when>             
                    
                    <!--  does this element have any children -->
                    <xsl:when test="child::node()">
                            <xsl:apply-templates />
                            </xsl:when>
                            <!-- if no children are found we add a space to eliminate self closing tags -->
                            <xsl:otherwise>
                                    &#160;
                            </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="i18n:text/text()='xmlui.Submission.submit.LicenseStep.info1'">
                    <div style="margin-top:1em">
                        <a target="_blank" href="{$fileadmin}/license/ssoar_license.pdf">
                            <img src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/pdf-icon.png')}" alt="fulltextDownload" style="margin-right:2em; vertical-align: middle;"/>
                            <i18n:text>xmlui.ssoar.labels.submission.licence</i18n:text>
                        </a>
                    </div>
                </xsl:if>
            </p>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- Finally, we have the list element, which is used to display set of data. There are several different
        types of lists, as signified by the type attribute, and several different templates to handle them. -->
    
    <!-- First list type is the bulleted list, a list with no real labels and no ordering between elements. -->
    <xsl:template match="dri:list[@type='bulleted']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <ul>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">bulleted-list</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[not(name()='head')]" mode="nested"/>
        </ul>
    </xsl:template>
    
    <!-- The item template creates an HTML list item element and places the contents of the DRI item inside it.
        Additionally, it checks to see if the currently viewed item has a label element directly preceeding it,
        and if it does, applies the label's template before performing its own actions. This mechanism applies
        to the list item templates as well. -->
    <xsl:template match="dri:list[@type='bulleted']/dri:item" priority="2" mode="nested">
        <li>
            <xsl:if test="name(preceding-sibling::*[position()=1]) = 'dri:label'">
                <xsl:apply-templates select="preceding-sibling::*[position()=1]"/>
            </xsl:if>
            <xsl:apply-templates />
        </li>
    </xsl:template>
    
    <!-- The case of nested lists is handled in a similar way across all lists. You match the sub-list based on
        its parent, create a list item approtiate to the list type, fill its content from the sub-list's head
        element and apply the other templates normally. -->
    <xsl:template match="dri:list[@type='bulleted']/dri:list" priority="3" mode="nested">
        <li>
            <xsl:apply-templates select="."/>
        </li>
    </xsl:template>
    
       
    <!-- Second type is the ordered list, which is a list with either labels or names to designate an ordering
        of some kind. -->
    <xsl:template match="dri:list[@type='ordered']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <ol>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ordered-list</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[not(name()='head')]" mode="nested">
                <xsl:sort select="dri:item/@n"/>
            </xsl:apply-templates>
        </ol>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='ordered']/dri:item" priority="2" mode="nested">
        <li>
            <xsl:if test="name(preceding-sibling::*[position()=1]) = 'label'">
                <xsl:apply-templates select="preceding-sibling::*[position()=1]"/>
            </xsl:if>
            <xsl:apply-templates />
        </li>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='ordered']/dri:list" priority="3" mode="nested">
        <li>
            <xsl:apply-templates select="."/>
        </li>
    </xsl:template>
    
    
    <!-- Progress list used primarily in forms that span several pages. There isn't a template for the nested
        version of this list, mostly because there isn't a use case for it. -->
    <xsl:template match="dri:list[@type='progress']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <xsl:choose>
            <xsl:when test="contains(@n,'submiti')">
                <form>					
                    <xsl:if test="contains(@n,'submit')">
                        <xsl:attribute name="id">editform</xsl:attribute>
                    </xsl:if>
                    <!--<xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">interactive-div</xsl:with-param>
                        </xsl:call-template>-->
                    <xsl:attribute name="action"><xsl:value-of select="@action"/></xsl:attribute>
                    <xsl:attribute name="method"><xsl:value-of select="@method"/></xsl:attribute>
                    <!--            <xsl:attribute name="style"><xsl:text>border:none;</xsl:text></xsl:attribute>-->
                    <xsl:if test="@method='multipart'">
                        <xsl:attribute name="method">post</xsl:attribute>
                        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="onsubmit">javascript:tSubmit(this);</xsl:attribute>
                    <!--For Item Submission process, disable ability to submit a form by pressing 'Enter'-->
                    <xsl:if test="starts-with(@n,'submit')">
                        <xsl:attribute name="onkeydown">javascript:return disableEnterKey(event);</xsl:attribute>
                    </xsl:if>
                    <!-- <xsl:apply-templates select="*[not(name()='head' or
                        (name()='list' and @n='submit-progress')
                        )]"/>-->
                    
                    
                    <ul>
                        <xsl:call-template name="standardAttributes">
                            <xsl:with-param name="class">progress-list</xsl:with-param>
                        </xsl:call-template>
                        <xsl:apply-templates select="dri:item"/>
                    </ul>
                </form>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">progress-list</xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="dri:item"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="dri:list[@type='progress']/dri:item" priority="2">
        <li>
            <xsl:attribute name="class">
                <xsl:value-of select="@rend"/>
                <xsl:if test="position()=1">
                    <xsl:text> first</xsl:text>
                </xsl:if>
                <xsl:if test="descendant::dri:field[@type='button']">
                    <xsl:text> button</xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text> last</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates />
        </li>
        <xsl:if test="not(position()=last() ) and ../@n!='submit-progress'">
            <li class="arrow">
                <xsl:text>&#8594;</xsl:text>
            </li>
        </xsl:if>
    </xsl:template>
        
    
    <!-- The third type of list is the glossary (gloss) list. It is essentially a list of pairs, consisting of
        a set of labels, each followed by an item. Unlike the ordered and bulleted lists, gloss is implemented
        via HTML definition list (dd) element. It can also be changed to work as a two-column table. -->
    <xsl:template match="dri:list[@type='gloss']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <dl>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">gloss-list</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[not(name()='head')]" mode="nested"/>
        </dl>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='gloss']/dri:item" priority="2" mode="nested">
        <dd>
            <xsl:apply-templates />
        </dd>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='gloss']/dri:label" priority="2" mode="nested">
        <dt>
            <span>
                <xsl:attribute name="class">
                    <xsl:text>gloss-list-label </xsl:text>
                </xsl:attribute>
                <xsl:apply-templates />
                <xsl:text>:</xsl:text>
            </span>
        </dt>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='gloss']/dri:list" priority="3" mode="nested">
        <dd>
            <xsl:apply-templates select="."/>
        </dd>
    </xsl:template>
    
    
    <!-- The next list type is one without a type attribute. In this case XSL makes a decision: if the items
        of the list have labels the the list will be made into a table-like structure, otherwise it is considered
        to be a plain unordered list and handled generically. -->
    <!-- TODO: This should really be done with divs and spans instead of tables. Form lists have already been
        converted so the solution here would most likely mirror that one -->
    <xsl:template match="dri:list[not(@type)]" priority="2">
        <!--EVIL-HACK: don't display membership for not System-Users-->
        <xsl:choose>
            <xsl:when test="./@n='memberships' and not(./dri:item/text()='Administrator' or ./dri:item/text()='ssoar_editors')">
                <!-- don't display the List -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="dri:head"/>
                <xsl:if test="count(dri:label)>0">
                    <table>
                        <xsl:call-template name="standardAttributes">
                            <xsl:with-param name="class">gloss-list</xsl:with-param>
                        </xsl:call-template>
                        <xsl:apply-templates select="dri:item" mode="labeled"/>
                    </table>
                </xsl:if>
                <xsl:if test="count(dri:label)=0">
                    <ul>
                        <xsl:call-template name="standardAttributes">
                            <xsl:with-param name="class">submenu</xsl:with-param>
                        </xsl:call-template>
                        <xsl:apply-templates select="dri:item" mode="nested"/>
                    </ul>
                </xsl:if>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="dri:list[not(@type)]/dri:item" priority="2" mode="labeled">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
                <xsl:value-of select="@rend"/>
            </xsl:attribute>
            <xsl:if test="name(preceding-sibling::*[position()=1]) = 'label'">
                <xsl:apply-templates select="preceding-sibling::*[position()=1]" mode="labeled"/>
            </xsl:if>
            <td>
                <xsl:apply-templates />
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="dri:list[not(@type)]/dri:label" priority="2" mode="labeled">
        <td>
            <xsl:if test="count(./node())>0">
                <span>
                    <xsl:attribute name="class">
                        <xsl:text>gloss-list-label </xsl:text>
                        <xsl:value-of select="@rend"/>
                    </xsl:attribute>
                    <xsl:apply-templates />
                    <xsl:text>:</xsl:text>
                </span>
            </xsl:if>
        </td>
    </xsl:template>
    
    <xsl:template match="dri:list[not(@type)]/dri:item" priority="2" mode="nested">
        <li>
            <xsl:apply-templates />
            <!-- Wrap orphaned sub-lists into the preceding item -->
            <xsl:variable name="node-set1" select="./following-sibling::dri:list"/>
            <xsl:variable name="node-set2" select="./following-sibling::dri:item[1]/following-sibling::dri:list"/>
            <xsl:apply-templates select="$node-set1[count(.|$node-set2) != count($node-set2)]"/>
        </li>
    </xsl:template>
            
   
    
    <!-- Special treatment of a list type "form", which is used to encode simple forms and give them structure.
        This is done partly to ensure that the resulting HTML form follows accessibility guidelines. -->
    
    <xsl:template match="dri:list[@type='form']" priority="3">
        
        <xsl:choose>
            
            <xsl:when test="contains(@n,'submit-review')"> 
                <xsl:choose>
                    <xsl:when test="not(contains(@n,'.1'))">
                        <xsl:if test="./dri:head/i18n:text">
                            <h2 id="gFieldsetLegendPublikationsdetails">
                                <xsl:apply-templates select="./dri:head/i18n:text"/>
                            </h2>
                        </xsl:if>
                        <xsl:apply-templates select="dri:list[@type='form' and contains(@n,'.1')]"/>
                        <xsl:apply-templates select="dri:item/dri:field[@type='checkbox']"/>
                        <div class="submission-buttons">
                            <xsl:apply-templates select="./dri:item/dri:field[@type='button']"/>
                        </div>
                    </xsl:when>
                    
                    <xsl:when test="@n='submit-review-2.1'">
                        <!--<h2 id="gFieldsetLegendPublikationsdetails">
                            <xsl:apply-templates select="./dri:head/i18n:text"/>
                        </h2>-->
                        <div class="entryFields">
                            <table id="gFieldsetPublikationsdetails" class="gFieldset" style="">
                                <tbody>
                                    <xsl:call-template name="review-table"/>                                                           
                                </tbody>
                            </table>
                        </div>
                    </xsl:when>
                    
                    <xsl:when test="@n='submit-review-3.1' and dri:item/dri:xref">
                        <!--<h2 id="gFieldsetLegendPublikationsdetails">
                            <xsl:apply-templates select="./dri:head/i18n:text"/>
                        </h2>-->
                        <div class="entryFields">
                            <table id="gFieldsetPublikationsdetails" class="gFieldset" style="">
                                <tbody>
                                    <xsl:apply-templates select="*[not(name()='label' or name()='head')]" mode="submission" />                                                             
                                </tbody>
                            </table>
                        </div>
                    </xsl:when>
                    
                    
                    
                </xsl:choose>
                
            </xsl:when>
            
            <xsl:when test="contains(@n,'submit')"> 
                <h2 id="gFieldsetLegendPublikationsdetails">
                    <xsl:apply-templates select="./dri:head/i18n:text"/>
                </h2>
                <xsl:if test="@n='submit-describe'">
                    <span>                        
                        <img class="required" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/required.png')}" alt="required"/>
                        <i18n:text>xmlui.ssoar.labels.submission.required</i18n:text>
                        <img class="required" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/edit-addvalue.png')}" />
                        <i18n:text>xmlui.ssoar.labels.submission.addfield</i18n:text>
                        
                    </span>
                </xsl:if>
                <ol class="submission" xmlns="http://di.tamu.edu/DRI/1.0/">
                    <xsl:apply-templates select="*[not(name()='label' or name()='head')]" mode="submission" />
                    <li>
                         <div class="submission-buttons">                    
                             <xsl:choose>
                                 <xsl:when test="contains(//dri:document/dri:body/dri:div/@rend,'submission')">
                                     <xsl:apply-templates select="./dri:item/dri:field[@type='button' and (@n='submit_prev' or @n='submit_cancel' or @n='submit_next')]"/>        
                                 </xsl:when>                
                                 <xsl:otherwise>
                                     <xsl:apply-templates select="./dri:item/dri:field[@type='button']"/>
                                 </xsl:otherwise>
                             </xsl:choose>                    
                         </div>
                    </li>
                </ol>
                
            </xsl:when>
            
            
           <xsl:when test="ancestor::dri:list[@type='form']">
               <li>
                   <fieldset>
                       <xsl:call-template name="standardAttributes">
                           <xsl:with-param name="class">
                               <!-- Provision for the sub list -->
                               <xsl:text>form-</xsl:text>
                               <xsl:if test="ancestor::dri:list[@type='form']">
                                   <xsl:text>sub</xsl:text>
                               </xsl:if>
                               <xsl:text>list </xsl:text>
                               <xsl:if test="count(dri:item) > 3">
                                   <xsl:text>thick </xsl:text>
                               </xsl:if>
                           </xsl:with-param>
                       </xsl:call-template>
                       <xsl:apply-templates select="dri:head"/>
                       
                       <ol>
                           <xsl:apply-templates select="*[not(name()='label' or name()='head')]" />
                       </ol>
                   </fieldset>
               </li>
                
           </xsl:when>
            <xsl:when test="@n='primary-search'">
                <xsl:apply-templates select="*[not(name()='label' or name()='head')]" />
            </xsl:when>
            <!-- EVIL-HACK: remove fieldset and ol for Sorting-div -->
            <xsl:when test="@n='search-controls'">
                <xsl:apply-templates select="*[not(name()='label' or name()='head')]" />
            </xsl:when>
            <xsl:otherwise>
                <fieldset>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">
                        <!-- Provision for the sub list -->
                        <xsl:text>form-</xsl:text>
                        <xsl:if test="ancestor::dri:list[@type='form']">
                            <xsl:text>sub</xsl:text>
                        </xsl:if>
                        <xsl:text>list </xsl:text>
                        <xsl:if test="count(dri:item) > 3">
                            <xsl:text>thick </xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates select="dri:head"/>
                
                <ol>
                    <xsl:apply-templates select="*[not(name()='label' or name()='head')]" />
                </ol>
                </fieldset>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- EVIL-HACK: submission review step is transmitted in a stupid lbel-item list, that needs special handling :( -->
    <xsl:template name="review-table">
        <xsl:for-each select="./dri:label"> 
            <tr class="pFieldset">
                <th class="pFieldsetLegend" scope="row">
                    <xsl:apply-templates select="./text()"/>
                </th>
                <xsl:variable name="position" select="position()"/>
                <xsl:for-each select="../dri:item">
                    <xsl:if test="position() = $position">
                        <td class="pValuesList">
                            <xsl:apply-templates select="./text()"/>
                        </td>
                    </xsl:if>            
                </xsl:for-each>
            </tr>
        </xsl:for-each>
        <tr class="pFieldset">
            <th class="pFieldsetLegend" scope="row"/>
            <td class="pValuesList">
                <xsl:apply-templates select="dri:item[@n='step_2.1']/dri:field"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- TODO: Account for the dri:hi/dri:field kind of nesting here and everywhere else... -->
    <xsl:template match="dri:list[@type='form']/dri:item" priority="3"> 
        <xsl:choose>
            <xsl:when test="./dri:field/@id='aspect.discovery.SimpleSearch.field.scope'">
                <!-- don't display scope-selector -->
            </xsl:when>
            <xsl:when test="./dri:field/@id='aspect.discovery.SimpleSearch.field.query'">
                <div class="queryFieldContainer" style="text-align:center;">
                    <xsl:apply-templates />
                    <!-- special name used in submission UI review page -->
                    <xsl:if test="@n = 'submit-review-field-with-authority'">
                        <xsl:call-template name="authorityConfidenceIcon">
                            <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                        </xsl:call-template>
                    </xsl:if>
                </div>
                <!--<div class="search-info">
                    <a href="{$context-path}/search-info.html#discover">
                        <i18n:text>xmlui.ssoar.search.info</i18n:text>
                    </a>
                </div>-->
                
            </xsl:when>
            <!-- EVIL-HACK: don't do anything in case of empty search -->
            <xsl:when test="../@n='search-controls' 
                and $requestURI='discover' 
                and ../../../dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value
                and not(string(../../../dri:div[@n='general-query']/dri:list[@n='primary-search']/dri:item/dri:field[@n='query']/dri:value/text()))
                and not(../../../dri:div[@n='search-controls']/dri:p[@n='hidden-fields']/dri:field[@n='fq'])">
                <xsl:text>&#160;</xsl:text>
                <!-- rien -->
            </xsl:when>
            <!--EVIL-HACK: don't display select filter -->
            <xsl:when test="@n='search-filter-list' or ../@n='primary-search'">
                <!--<xsl:text>&#160;</xsl:text>-->
                <!-- rien -->
            </xsl:when>
            <!--EVIL-HACK: no li for search controls -->
            <xsl:when test="../@n='search-controls'">
                <div class="form-content search-controls">
                    <xsl:apply-templates />
                    <!-- special name used in submission UI review page -->
                    <xsl:if test="@n = 'submit-review-field-with-authority'">
                        <xsl:call-template name="authorityConfidenceIcon">
                            <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                        </xsl:call-template>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <li>                
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">
                            <xsl:text>form-item </xsl:text>
                            <xsl:choose>
                                <!-- Makes sure that the dark always falls on the last item -->
                                <xsl:when test="count(../dri:item) mod 2 = 0">
                                    <xsl:if test="count(../dri:item) > 3">
                                        <xsl:if test="(count(preceding-sibling::dri:item) mod 2 = 0)">even </xsl:if>
                                        <xsl:if test="(count(preceding-sibling::dri:item) mod 2 = 1)">odd </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="count(../dri:item) mod 2 = 1">
                                    <xsl:if test="count(../dri:item) > 3">
                                        <xsl:if test="(count(preceding-sibling::dri:item) mod 2 = 1)">even </xsl:if>
                                        <xsl:if test="(count(preceding-sibling::dri:item) mod 2 = 0)">odd </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                            <!-- The last row is special if it contains only buttons -->
                            <xsl:if test="position()=last() and dri:field[@type='button'] and not(dri:field[not(@type='button')])">last </xsl:if>
                            <!-- The row is also tagged specially if it contains another "form" list -->
                            <xsl:if test="dri:list[@type='form']">sublist </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:choose>
                        <xsl:when test="dri:field[@type='composite']">
                            <xsl:call-template name="pick-label"/>
                            <xsl:apply-templates mode="formComposite"/>
                        </xsl:when>
                        <xsl:when test="dri:list[@type='form']">
                            <xsl:apply-templates />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="pick-label"/>
                            <div class="form-content">
                                <xsl:apply-templates />
                                <!-- special name used in submission UI review page -->
                                <xsl:if test="@n = 'submit-review-field-with-authority'">
                                    <xsl:call-template name="authorityConfidenceIcon">
                                        <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- TODO: Account for the dri:hi/dri:field kind of nesting here and everywhere else... -->
    <xsl:template match="dri:list[@type='form']/dri:item" priority="3" mode="submission">
        <!-- EVIL-HACK: skip scope of discovery search and buttons of submission process -->        
        <xsl:if test="not(./dri:field/@id='aspect.discovery.SimpleSearch.field.scope'
            or ./dri:field[@n='submit_cancel'] 
            or ./dri:field[@n='submit_previous']
            or ./dri:field[@n='submit_next'])">
            <!-- Fill in Headlines for different sections -->
            <xsl:choose>
                <xsl:when test="./dri:field/@n='dc_description_version'">
                    <xsl:call-template name="sectionHeadline">
                        <xsl:with-param name="sectionname">details</xsl:with-param>
                    </xsl:call-template>                   
                </xsl:when>
                <xsl:when test="./dri:field/@n='dc_source_recensionauthor'">
                    <xsl:call-template name="sectionHeadline">
                        <xsl:with-param name="sectionname">recension</xsl:with-param>
                    </xsl:call-template>                   
                </xsl:when>
                <xsl:when test="./dri:field/@n='dc_description_abstract'">
                    <xsl:call-template name="sectionHeadline">
                        <xsl:with-param name="sectionname">content</xsl:with-param>
                    </xsl:call-template>                   
                </xsl:when>
                <!--<xsl:when test="./dri:field/@n='dc_rights_licence'">-->
                <xsl:when test="./dri:field/@n='internal_embargo_terms'">
                    <xsl:call-template name="sectionHeadline">
                        <xsl:with-param name="sectionname">misc</xsl:with-param>
                    </xsl:call-template>                   
                </xsl:when>
            </xsl:choose>            
            <li class="ds-form-item pFieldset" id="{./dri:field/@n}">                
                <xsl:choose>
                    <xsl:when test="dri:field[@type='composite']">
                        <div id="{./dri:field/@n}_head" class="head pFieldsetLegend">
                            <xsl:call-template name="pick-label"/>
                        </div>
                        <xsl:apply-templates mode="formComposite"/>
                    </xsl:when>
                    <xsl:when test="dri:list[@type='form']">
                        <xsl:apply-templates />
                    </xsl:when>
                    
                    <!-- EVIL-HACK: do nothing in submission form -->
                    <xsl:when test="./@rend='submit-text'">
                        <!-- rien -->
                    </xsl:when>                    
                    
                    <xsl:otherwise>
                        <div id="{./dri:field/@n}_head" class="head pFieldsetLegend">                        
                            <xsl:call-template name="pick-label"/>
                            <xsl:if test="./dri:xref and not(./@rend='submit-text' or ./dri:field/@rend='submit-text')">
                                <i18n:text>xmlui.ssoar.labels.uploadedfile</i18n:text>
                            </xsl:if>
                        </div>
                        <div id="{./dri:field/@n}_column" class="ds-form-content" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:xlink="http://www.w3.org/TR/xlink/">
                             <xsl:apply-templates />
                             <!-- special name used in submission UI review page -->
                             <xsl:if test="@n = 'submit-review-field-with-authority'">
                                 <xsl:call-template name="authorityConfidenceIcon">
                                     <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                                 </xsl:call-template>
                             </xsl:if>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </li>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="sectionHeadline">
        <xsl:param name="sectionname"/>
        <li class="SectionHeadline">
            <h3>
                <i18n:text>xmlui.ssoar.labels.submission.<xsl:value-of select="$sectionname"/></i18n:text>
            </h3>
        </li>
    </xsl:template>
    
    <!-- An item in a nested "form" list -->
    <xsl:template match="dri:list[@type='form']//dri:list[@type='form']/dri:item" priority="3">
        <li>
                <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <xsl:text>form-item </xsl:text>

                <!-- Row counting voodoo, meant to impart consistent row alternation colors to the form lists.
                    Should probably be chnaged to a system that is more straitforward. -->
                <xsl:choose>
                    <xsl:when test="(count(../../..//dri:item) - count(../../..//dri:list[@type='form'])) mod 2 = 0">
                        <!--<xsl:if test="count(../dri:item) > 3">-->
                            <xsl:if test="(count(preceding-sibling::dri:item | ../../preceding-sibling::dri:item/dri:list[@type='form']/dri:item) mod 2 = 0)">even </xsl:if>
                            <xsl:if test="(count(preceding-sibling::dri:item | ../../preceding-sibling::dri:item/dri:list[@type='form']/dri:item) mod 2 = 1)">odd </xsl:if>
                        
                    </xsl:when>
                    <xsl:when test="(count(../../..//dri:item) - count(../../..//dri:list[@type='form'])) mod 2 = 1">
                        <!--<xsl:if test="count(../dri:item) > 3">-->
                            <xsl:if test="(count(preceding-sibling::dri:item | ../../preceding-sibling::dri:item/dri:list[@type='form']/dri:item) mod 2 = 1)">even </xsl:if>
                            <xsl:if test="(count(preceding-sibling::dri:item | ../../preceding-sibling::dri:item/dri:list[@type='form']/dri:item) mod 2 = 0)">odd </xsl:if>
                        
                    </xsl:when>
                </xsl:choose>
                <!--
                <xsl:if test="position()=last() and dri:field[@type='button'] and not(dri:field[not(@type='button')])">last</xsl:if>
                    -->
               </xsl:with-param>
            </xsl:call-template>
            
            <xsl:call-template name="pick-label"/>

            <xsl:choose>
                <xsl:when test="dri:field[@type='composite']">
                    <xsl:apply-templates mode="formComposite"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="form-content">
                        <xsl:apply-templates />
                        <!-- special name used in submission UI review page -->
                        <xsl:if test="@n = 'submit-review-field-with-authority'">
                          <xsl:call-template name="authorityConfidenceIcon">
                            <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                          </xsl:call-template>
                        </xsl:if>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    
    <xsl:template name="pick-label">
        <xsl:choose>
            <!-- EVIL-HACK: set i18n-tags within submission process -->
            <xsl:when test="../@id = 'aspect.submission.StepTransformer.list.submit-describe'">
                <xsl:apply-templates select="dri:field/dri:label/text()"></xsl:apply-templates>
                
                <xsl:if test="dri:field/@required= 'yes'">                    
                    <img class="required" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/required.png')}" alt="required"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains(../@id, 'list.submit-review')">
                <xsl:apply-templates select="../dri:label/text()"></xsl:apply-templates>               
            </xsl:when>
            <!-- EVIL-HACK: and not to filter selected label -->
            <xsl:when test="dri:field/dri:label and not(dri:field[@id='aspect.discovery.SimpleSearch.field.fq'])">
                <label class="form-label">
                        <xsl:choose>                            
                                <xsl:when test="./dri:field/@id">
                                        <xsl:attribute name="for">
                                                <xsl:value-of select="translate(./dri:field/@id,'.','_')"/>
                                        </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise></xsl:otherwise>
                        </xsl:choose>
                    <xsl:apply-templates select="dri:field/dri:label" mode="formComposite"/>
                    <xsl:text>:</xsl:text>
                </label>
            </xsl:when>
            <xsl:when test="string-length(string(preceding-sibling::*[1][local-name()='label'])) > 0">
                <xsl:choose>
                        <xsl:when test="./dri:field/@id">
                                <label>
                                        <xsl:apply-templates select="preceding-sibling::*[1][local-name()='label']"/>
                                    <xsl:text>:</xsl:text>
                                </label>
                        </xsl:when>
                        <xsl:otherwise>
                                <span>
                                        <xsl:apply-templates select="preceding-sibling::*[1][local-name()='label']"/>
                                    <xsl:text>:</xsl:text>
                                </span>
                        </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <xsl:when test="dri:field">
                <xsl:choose>
                        <xsl:when test="preceding-sibling::*[1][local-name()='label']">
                                <label class="form-label">
                                        <xsl:choose>
                                                <xsl:when test="./dri:field/@id">
                                                        <xsl:attribute name="for">
                                                                <xsl:value-of select="translate(./dri:field/@id,'.','_')"/>
                                                        </xsl:attribute>
                                                </xsl:when>
                                                <xsl:otherwise></xsl:otherwise>
                                        </xsl:choose>
                                    <xsl:apply-templates select="preceding-sibling::*[1][local-name()='label']"/>&#160;
                                </label>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="preceding-sibling::*[1][local-name()='label']"/>&#160;
                            </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- If the label is empty and the item contains no field, omit the label. This is to
                    make the text inside the item (since what else but text can be there?) stretch across
                    both columns of the list. -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dri:list[@type='form']/dri:label" priority="3">
                <xsl:attribute name="class">
                <xsl:text>form-label</xsl:text>
               <xsl:if test="@rend">
                     <xsl:text> </xsl:text>
                     <xsl:value-of select="@rend"/>
                 </xsl:if>
        </xsl:attribute>
        <xsl:choose>
                <xsl:when test="following-sibling::dri:item[1]/dri:field/@id">
                        <xsl:attribute name="for">
                                <xsl:value-of select="translate(following-sibling::dri:item[1]/dri:field/@id,'.','_')" />
                        </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>
    
    
    <xsl:template match="dri:field/dri:label" mode="formComposite">
        <xsl:apply-templates />
    </xsl:template>
         
    <xsl:template match="dri:list[@type='form']/dri:head" priority="5">
        <!-- filter discovery Headlines -->
        
        <xsl:if test="not(starts-with(../@id,'aspect.discovery.SimpleSearch.list.primary-search') or
            ../@id='aspect.discovery.SimpleSearch.list.search-controls')">
            <legend>
                <xsl:apply-templates />
            </legend>    
        </xsl:if>
    </xsl:template>
    
    <!-- NON-instance composite fields (i.e. not repeatable) -->
    <xsl:template match="dri:field[@type='composite']" mode="formComposite">
        <div class="form-content">
            <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
            <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
            <xsl:choose>
              <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                <xsl:message terminate="yes">
                  <xsl:text>ERROR: Input field with "suggest" (autocomplete) choice behavior is not implemented for Composite (e.g. "name") fields.</xsl:text>
                </xsl:message>
              </xsl:when>
              <!-- lookup popup includes its own Add button if necessary. -->
              <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                <xsl:call-template name="addLookupButton">
                  <xsl:with-param name="isName" select="'true'"/>
                  <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                </xsl:call-template>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="dri:params/@authorityControlled">
              <xsl:variable name="confValue" select="dri:field/dri:value[@type='authority'][1]/@confidence"/>
              <xsl:call-template name="authorityConfidenceIcon">
                <xsl:with-param name="confidence" select="$confValue"/>
                <xsl:with-param name="id" select="$confidenceIndicatorID"/>
              </xsl:call-template>
              <xsl:call-template name="authorityInputFields">
                <xsl:with-param name="name" select="@n"/>
                <xsl:with-param name="authValue" select="dri:field/dri:value[@type='authority'][1]/text()"/>
                <xsl:with-param name="confValue" select="$confValue"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
            <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
            <xsl:apply-templates select="dri:help" mode="compositeComponent"/>
        </div>
    </xsl:template>
    
    
        
        
        
    <!-- Next, special handling is performed for lists under the options tag, making them into option sets to
        reflect groups of similar options (like browsing, for example). -->
    
    <!-- The template that applies to lists directly under the options tag that have other lists underneath
        them. Each list underneath the matched one becomes an option-set and is handled by the appropriate
        list templates. -->
    <xsl:template match="dri:options/dri:list[dri:list]" priority="4">
		<xsl:choose>
			<xsl:when test="../dri:list[@n='browse']">		
			    <xsl:apply-templates select="./*[not(name()='head')]" mode="nested"/>
					<!--<h4 class="option-set-head">
						<xsl:if test="not(contains(../../dri:meta/dri:pageMeta/dri:metadata[@qualifier='URI']/text(), 'discover'))">
							<xsl:attribute name="style">display: none;</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="dri:list[@n='global']/dri:item/dri:xref"/>					
					</h4>				
				<span/>-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="dri:head"/>
			    <xsl:if test="/dri:document/dri:body/dri:div[@id='aspect.discovery.SimpleSearch.div.search']/dri:div[@id='aspect.discovery.SimpleSearch.div.search-filters' and @interactive='yes']/dri:list/dri:item[@n='used-filters']">
			        <xsl:apply-templates select="/dri:document/dri:body/dri:div[@id='aspect.discovery.SimpleSearch.div.search']/dri:div[@id='aspect.discovery.SimpleSearch.div.search-filters' and @interactive='yes']"/>
			    </xsl:if>
				<div id="col1_content">
					<ul id="submenu">
						<xsl:apply-templates select="./*[not(name()='head')]" mode="nested"/>
					</ul>
				</div>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>
    
    <!-- Special case for nested options lists -->
    <xsl:template match="dri:options/dri:list/dri:list" priority="3" mode="nested">        
        <xsl:variable name="position" select="count(preceding-sibling::dri:list)"/>
        <xsl:variable name="filter" select="@n"/>
        <xsl:variable name="filterSelected">
            <xsl:for-each select="//dri:document/dri:body/dri:div/dri:div[@n='search-filters']/dri:list/dri:item[@n='used-filters']/dri:field/dri:value">
                <xsl:if test="starts-with(@option,  $filter)">
                    <xsl:value-of select="position()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- EVIL-HACK: skip head_of_all -->
        <xsl:if test="../@n!='browse'">
            <li>
                <!--<a onmouseover="javascript:toggle({$position},false)" href="javascript:toggle({$position},true)">-->
                <a href="javascript:toggle({$position})">				
                    <xsl:apply-templates select="dri:head" mode="nested"/>
                </a>
                <ul id="{$position}" class="submenu-entries">                
                    <xsl:if test="$filterSelected=''"><!--  and $position != 11 -->                    
                        <xsl:attribute name="style">display: none;</xsl:attribute>                    
                    </xsl:if>
                    <xsl:apply-templates select="dri:item" mode="nested"/>
                </ul>
            </li>
        </xsl:if>
        
    </xsl:template>
    
    
    <xsl:template match="dri:options/dri:list" priority="3">
		<!-- Code inserted to pass User-Login-Page -->        
		<xsl:if test="@n!='account'">
		    
			<xsl:apply-templates select="dri:head"/>
			<div>
				<xsl:call-template name="standardAttributes">
					<xsl:with-param name="class">option-set</xsl:with-param>
				</xsl:call-template>
				<ul class="simple-list">
					<xsl:apply-templates select="dri:item" mode="nested"/>
				</ul>
			</div>
		</xsl:if>
    </xsl:template>
    
    <!-- Quick patch to remove empty lists from options -->
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5" mode="nested">
    </xsl:template>
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5">
    </xsl:template>
    
    
    <xsl:template match="dri:options/dri:list/dri:head" priority="3">        
        <xsl:if test="substring-after(../@id, 'list.')!='discovery' and substring-after(../@id, 'list.')!='browse'">
            <h3>
                
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">option-set-head</xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates />
            </h3>
        </xsl:if>
        
			
    </xsl:template>    
    
    
    <!-- Finally, the following templates match list types not mentioned above. They work for lists of type
        'simple' as well as any unknown list types. -->
    <xsl:template match="dri:list" priority="1">
        <xsl:apply-templates select="dri:head"/>
        <!-- EVIL-HACK: modify alphabetical List on view more... (discovery-facets) -->        
        <xsl:choose>
            <xsl:when test="./@rend = 'alphabet' and contains(../../@n, 'documentType')">
                <!-- don't display the List -->
            </xsl:when>
            <!-- display Year-ranges -->
            <xsl:when test="./@rend = 'alphabet' and contains(../../@n, 'dateIssued')">
                <xsl:call-template name="displayYears">
                    <xsl:with-param name="list" select="."/>
                </xsl:call-template>
            </xsl:when>            
            <!-- display number selections -->
            <xsl:when test="./@rend = 'alphabet' and (contains(../../@n, 'volume') or contains(../../@n, 'issue'))">
                <xsl:call-template name="displayNumbers">
                    <xsl:with-param name="list" select="."/>
                </xsl:call-template>
            </xsl:when>
            <!-- EVIL-HACK: call reference to load from metadata instead of direct display of information -->
            <xsl:when test="@n='search-results-repository'">
                                  
                    <xsl:choose>
                        <!--  does this element have any children -->
                        <xsl:when test="child::node()">
                            <xsl:call-template name="item-results">
                                <xsl:with-param name="item-list" select="./dri:list[@n='item-result-list']"/>
                            </xsl:call-template>
                        </xsl:when>
                        <!-- if no children are found we add a space to eliminate self closing tags -->
                        <xsl:otherwise>
                            <!--<xsl:text>&#160;</xsl:text>-->
                        </xsl:otherwise>
                    </xsl:choose>                    
                
            </xsl:when>
            <!-- EVIL-HACK: insert operation-button for sort options -->
            <xsl:when test="./@n = 'sort-options'">
                <!--<a href="javascript:toggle('aspect_discovery_SimpleSearch_list_sort-options')">				
                    <xsl:text>sort options</xsl:text>
                </a>
                <ul>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">simple-list</xsl:with-param>
                    </xsl:call-template>
                    <xsl:attribute name="style">
                        <xsl:text>display: none;</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="*[not(name()='head')]" mode="nested"/>
                </ul>-->
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">simple-list</xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="*[not(name()='head')]" mode="nested"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="item-results">
        <xsl:param name="item-list"/>
        <xsl:for-each select="$item-list/dri:list">
            <xsl:variable name="handle" select="substring-before(./@n,':item')"></xsl:variable>
            <xsl:variable name="externalMetadataURL">                
                <xsl:text>cocoon:/</xsl:text>
                <xsl:value-of select="concat('/metadata/handle/',$handle,'/mets.xml')"/>
                <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
                <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL,ORIGINAL</xsl:text>
                <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
            <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
            </xsl:if>-->
            </xsl:variable>
            <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
            <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
            <!--<xsl:apply-templates /> -->           
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="displayNumbers">
        <xsl:param name="list"/>
        <xsl:variable name="url">
            <xsl:value-of select="substring-before(./dri:item/dri:xref/@target, 'starts_with=a')"/>
            <xsl:text>starts_with=</xsl:text>
        </xsl:variable>
        <ul class="viewmore_index_numbers">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">simple-list</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="loopNumbers">
                <xsl:with-param name="counter">0</xsl:with-param>
                <xsl:with-param name="step">1</xsl:with-param>
                <xsl:with-param name="end">9</xsl:with-param>
                <xsl:with-param name="url" select="$url"/>                
            </xsl:call-template>
        </ul>
        
    </xsl:template>
    
    <xsl:template name="displayYears">
        <xsl:param name="list"/>
        <xsl:variable name="url">
            <xsl:value-of select="substring-before(./dri:item/dri:xref/@target, 'starts_with=a')"/>
            <xsl:text>starts_with=</xsl:text>
        </xsl:variable>
        <ul class="viewmore_index_years">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">simple-list</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="loopYears">
                <xsl:with-param name="counter">192</xsl:with-param>
                <xsl:with-param name="step">1</xsl:with-param>
                <xsl:with-param name="end">201</xsl:with-param>
                <xsl:with-param name="url" select="$url"/>                
            </xsl:call-template>
        </ul>
        
    </xsl:template>
    
    <xsl:template name="loopNumbers">        
        <xsl:param name="counter"/>
        <xsl:param name="step"/>
        <xsl:param name="end"/>
        <xsl:param name="url"/>
        <xsl:if test="$counter &lt;= $end">       
            <li>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$url"/>
                        <xsl:value-of select="$counter"/>
                    </xsl:attribute>
                    <xsl:value-of select="$counter"/>
                </a>
            </li>
            
            <xsl:call-template name="loopNumbers">
                <xsl:with-param name="counter" select="$counter + $step"/>
                <xsl:with-param name="step" select="$step"/>
                <xsl:with-param name="end" select="$end"/>
                <xsl:with-param name="url" select="$url"/>                
            </xsl:call-template>
        </xsl:if>         
    </xsl:template>
    
    <xsl:template name="loopYears">        
        <xsl:param name="counter"/>
        <xsl:param name="step"/>
        <xsl:param name="end"/>
        <xsl:param name="url"/>
        <xsl:if test="$counter &lt;= $end">       
            <li>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$url"/>
                        <xsl:value-of select="$counter"/>
                    </xsl:attribute>
                    <xsl:value-of select="$counter * 10"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="(($counter + $step) * 10 )-1"/>
                </a>
            </li>
            
            <xsl:call-template name="loopYears">
                <xsl:with-param name="counter" select="$counter + $step"/>
                <xsl:with-param name="step" select="$step"/>
                <xsl:with-param name="end" select="$end"/>
                <xsl:with-param name="url" select="$url"/>                
            </xsl:call-template>
        </xsl:if>         
    </xsl:template>
    
    
    <!-- Generic label handling: simply place the text of the element followed by a period and space. -->
    <xsl:template match="dri:label" priority="1" mode="nested">
        <xsl:copy-of select="./node()"/>
    </xsl:template>
    
    <!-- Generic item handling for cases where nothing special needs to be done -->
    <xsl:template match="dri:item" mode="nested">
        <li>            
            <xsl:apply-templates />
        </li>
    </xsl:template>
    
    
    
    <xsl:template match="dri:list/dri:list" priority="1" mode="nested">
        <li>
            <span>                
                <xsl:apply-templates select="."/>                  
            </span>
        </li>
    </xsl:template>
    
    
    
    <!-- From here on out come the templates for supporting elements that are contained within structural
        ones. These include head (in all its myriad forms), rich text container elements (like hi and figure),
        as well as the field tag and its related elements. The head elements are done first. -->
    
    <!-- The first (and most complex) case of the header tag is the one used for divisions. Since divisions can
        nest freely, their headers should reflect that. Thus, the type of HTML h tag produced depends on how
        many divisions the header tag is nested inside of. -->
    <!-- The font-sizing variable is the result of a linear function applied to the character count of the heading text -->
    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <!-- with the help of the font-sizing variable, the font-size of our header text is made continuously variable based on the character count -->
        <!--<xsl:variable name="font-sizing" select="365 - $head_count * 80 - string-length(current())"></xsl:variable>-->
        <!--EVIL-HACK: filter-out the headline SEARCH -->
        <xsl:choose>
            <xsl:when test="../../@n='advanced-search' or ../@n='search'">
                <!-- do nothing -->
            </xsl:when>  
            <!-- display metadata for withdrawn items -->
            <xsl:when test="../@n='withdrawn'">
                <xsl:variable name="handle">
                    <xsl:value-of select="substring-after(../dri:p/i18n:translate/i18n:param/text(),'hdl:')"/>
                </xsl:variable>
                <xsl:variable name="externalMetadataURL">
                    <xsl:text>cocoon://metadata/handle/</xsl:text>
                    <xsl:value-of select="$handle"/>
                    <xsl:text>/mets.xml</xsl:text>                    
                    <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
                    <xsl:text>?sections=dmdSec</xsl:text>                    
                </xsl:variable>
                <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
                <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryView"/>                
            </xsl:when>  
            <xsl:otherwise>
                <xsl:element name="h{$head_count}">
                    <!-- in case the chosen size is less than 120%, don't let it go below. Shrinking stops at 120% -->
                    <!--
                        <xsl:choose>
                        
                        <xsl:when test="$font-sizing &lt; 120">
                        <xsl:attribute name="style">font-size: 120%;</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                        <xsl:attribute name="style">font-size: <xsl:value-of select="$font-sizing"/>%;</xsl:attribute>
                        </xsl:otherwise>
                        </xsl:choose>
                    -->       
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">div-head</xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:choose>
                        <xsl:when test="contains(./i18n:translate/i18n:text/text(), 'head1_collection') or 
                            contains(./i18n:translate/i18n:text/text(), 'head1_community')">
                            <xsl:variable name="id">
                                <xsl:value-of select="substring-after(../../dri:p[@n='hidden-fields']/dri:field[@n='discovery-json-scope']/dri:value/text(),'/')"/>    
                            </xsl:variable>
                            <xsl:copy-of select="./i18n:translate/i18n:text"/>
                            <i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="$id"/></i18n:text>
                        </xsl:when>
                        <xsl:when test="string-length(./node()) &lt; 1">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
   </xsl:template>
    
    <!-- The second case is the header on tables, which always creates an HTML h3 element -->
    <xsl:template match="dri:table/dri:head" priority="2">
        <h3>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">table-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    
    <!-- The third case is the header on lists, which creates an HTML h3 element for top level lists and
        and h4 elements for all sublists. -->
    <xsl:template match="dri:list/dri:head" priority="2" mode="nested">
        <h3>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">list-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    
    <xsl:template match="dri:list/dri:list/dri:head" priority="3" mode="nested">
        <h4>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">sublist-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </h4>
    </xsl:template>
    
    <!-- The fourth case is the header on referenceSets, to be discussed below, which creates an HTML h2 element
        for all cases. The reason for this simplistic approach has to do with referenceSets being handled
        differently in many cases, making it difficult to treat them as either divs (with scaling headers) or
        lists (with static ones). In this case, the simplest solution was chosen, although it is subject to
        change in the future. -->
    <xsl:template match="dri:referenceSet/dri:head" priority="2">
        <h3>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">list-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    
    <!-- Finally, the generic header element template, given the lowest priority, is there for cases not
        covered above. It assumes nothing about the parent element and simply generates an HTML h3 tag -->
    <xsl:template match="dri:head" priority="1">
        <h3>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    
    
    
    
    <!-- Next come the components of rich text containers, namely: hi, xref, figure and, in case of interactive
        divs, field. All these can mix freely with text as well as contain text of their own. The templates for
        the first three elements are fairly straightforward, as they simply create HTML span, a, and img tags,
        respectively. -->
    
    <xsl:template match="dri:hi">
        <span>
            <xsl:attribute name="class">emphasis</xsl:attribute>
            <xsl:if test="@rend">
                <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <xsl:template match="dri:xref">
        <!-- EVIL-HACK: filter-out vocabulary-links -->
        <xsl:if test="not(../../@n='submit-describe')">
            <a>
                <xsl:if test="@target">
                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                </xsl:if>
                
                <xsl:if test="@rend">
                    <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:if>
                
                <xsl:if test="@n">
                    <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
                </xsl:if>
                <!-- EVIL-HACK: put communities and collections in h4 inside anchor -->
                <xsl:choose>
                    <xsl:when test="../../../@n='browse'">
                        <h4 class="option-set-head">
                            <xsl:apply-templates />
                        </h4>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>  
                
            </a>
        </xsl:if>
    </xsl:template>
    
    <!-- Items inside option lists are excluded from the "orphan roundup" mechanism -->
    <xsl:template match="dri:options//dri:item" mode="nested" priority="3">
        <li>                        
            <span>
                    
                <!-- EVIL-HACK: use i18n values for controlled vocabularies -->
                <xsl:choose>
                    <!--<xsl:when test="contains(@id,'discovery.SidebarFacetsTransformer') 
                        and @rend='selected'">
                        <xsl:variable name="count">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="substring-after(./text(),' (')"/>
                            <!-\-<xsl:call-template name="lastIndexOf">
                                <xsl:with-param name="string" select="./text()"/>
                                <xsl:with-param name="sequence" select="' ('"/>
                            </xsl:call-template>-\->
                        </xsl:variable>
                        <xsl:variable name="filter">
                            <xsl:call-template name="getDiscoveryFilter">
                                <xsl:with-param name="queryString" select="substring-before(./text(),$count)"/>
                            </xsl:call-template>    
                        </xsl:variable>
                        <xsl:variable name="filterQuery">
                            <xsl:value-of select="concat('fq=',../@n, '_filter')"/>
                            <xsl:value-of select="$filter"/>
                        </xsl:variable>
                        <a class="deselect">
                            <xsl:attribute name="query">
                                <xsl:value-of select="$filterQuery"/>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$context-path"/>
                                <xsl:text>/discover?</xsl:text>
                                <xsl:value-of select="substring-before($requestQueryString,$filterQuery)"/>                                
                                <xsl:value-of select="substring-after($requestQueryString, $filterQuery)"/>
                            </xsl:attribute>
                            <xsl:value-of select="./text()"/>
                        </a>
                    </xsl:when>-->
                    <!-- <xsl:when test="../@n='thesoz' 
                        or ../@n='classoz'
                        or ../@n='documentType'
                        or ../@n='review'
                        or ../@n='pubstatus'
                        or ../@n='methods'"> -->
                    <xsl:when test="../@n='documentType'
                        or ../@n='review'
                        or ../@n='pubstatus'
                        or ../@n='methods'">
                        <xsl:call-template name="discovery-identifier">
                            <xsl:with-param name="item" select="."/>
                        </xsl:call-template>                                                
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>                
            </span>
        </li>
    </xsl:template>
    
    <xsl:template name="getDiscoveryFilter">
        <xsl:param name="queryString"/>        
        <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        <xsl:variable name="lowerCase">
            <xsl:value-of select="translate($queryString, $uppercase, $smallcase)" />    
        </xsl:variable>
        <xsl:variable name="encodedString">
            <xsl:value-of select="java:java.net.URLEncoder.encode(concat($lowerCase,'\|\|\|',$queryString), 'UTF-8')"/>            
        </xsl:variable>
        
        <xsl:variable name="replacements">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text">
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text">
                            <xsl:call-template name="string-replace-all">
                                <xsl:with-param name="text" select="$encodedString" />
                                <xsl:with-param name="replace" select="'%3A'" />
                                <xsl:with-param name="by" select="'\%3A'" />
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="replace" select="'-'" />
                        <xsl:with-param name="by" select="'\-'" />
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="replace" select="'+'" />
                <xsl:with-param name="by" select="'\+'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat(':',$replacements)"/>     
    </xsl:template>
    
    <xsl:template name="string-replace-all">
        <xsl:param name="text" />
        <xsl:param name="replace" />
        <xsl:param name="by" />
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)" />
                <xsl:value-of select="$by" />
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)" />
                    <xsl:with-param name="replace" select="$replace" />
                    <xsl:with-param name="by" select="$by" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- EVIL-HACK: this template is used to fill in correct Terms for Discovery-filters that are based on controlled vocabularies with multiple languages 
        used for cases in dri:xref (line 2162 ) and dri:options//dri:item (line 19..)-->
    <xsl:template name="discovery-identifier">
        <xsl:param name="item"/>
        <xsl:choose>
            <xsl:when test="not(./dri:xref)">                
                <xsl:variable name="count">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="substring-after(./text(),'(')"/>            
                </xsl:variable>
                
                <xsl:choose>
                    <!--<xsl:when test="../@n='thesoz' or contains(../../@n,'thesoz')">
                        <i18n:text>xmlui.ssoar.convoc.thesoz.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>
                    <xsl:when test="../@n='classoz' or contains(../../@n,'classoz')">
                        <i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>-->
                    <xsl:when test="../@n='documentType' or contains(../../@n,'documentType')">
                        <i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>
                    <xsl:when test="../@n='review' or contains(../../@n,'review')">
                        <i18n:text>xmlui.ssoar.convoc.review.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>
                    <xsl:when test="../@n='pubstatus' or contains(../../@n,'pubstatus')">
                        <i18n:text>xmlui.ssoar.convoc.pubstatus.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>
                    <xsl:when test="../@n='methods' or contains(../../@n,'methods')">
                        <i18n:text>xmlui.ssoar.convoc.methods.<xsl:value-of select="substring-before(./text(),' (')"/></i18n:text>
                        <xsl:value-of select="$count"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(./text(),' (')"/>
                        <xsl:value-of select="$count"/>
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:when>            
            <xsl:when test="./dri:xref and not(./dri:xref/i18n:text)">                
                <xsl:variable name="count">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="substring-after(./dri:xref/text(),'(')"/>            
                </xsl:variable>              
                
                <a>
                    <xsl:if test="./dri:xref/@target">
                        <xsl:attribute name="href"><xsl:value-of select="./dri:xref/@target"/></xsl:attribute>
                    </xsl:if>
                    
                    <xsl:if test="./dri:xref/@rend">
                        <xsl:attribute name="class"><xsl:value-of select="./dri:xref/@rend"/></xsl:attribute>
                    </xsl:if>
                    
                    <xsl:if test="./dri:xref/@n">
                        <xsl:attribute name="name"><xsl:value-of select="./dri:xref/@n"/></xsl:attribute>
                    </xsl:if>
                    
                    <xsl:choose>
                        <!--<xsl:when test="../@n='thesoz' or contains(../../@n,'thesoz')">
                            <i18n:text>xmlui.ssoar.convoc.thesoz.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>
                        <xsl:when test="../@n='classoz' or contains(../../@n,'classoz')">
                            <i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>-->
                        <xsl:when test="../@n='documentType' or contains(../../@n,'documentType')">
                            <i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>
                        <xsl:when test="../@n='pubstatus' or contains(../../@n,'pubstatus')">
                            <i18n:text>xmlui.ssoar.convoc.pubstatus.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>
                        <xsl:when test="../@n='review' or contains(../../@n,'review')">
                            <i18n:text>xmlui.ssoar.convoc.review.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>
                        <xsl:when test="../@n='methods' or contains(../../@n,'methods')">
                            <i18n:text>xmlui.ssoar.convoc.methods.<xsl:value-of select="substring-before(./dri:xref/text(),' (')"/></i18n:text>
                            <xsl:value-of select="$count"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./dri:xref/text()"/>
                        </xsl:otherwise>
                    </xsl:choose> 
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="."/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    
    <xsl:template name="lastIndexOf">
        <!-- declare that it takes two parameters - the string and the char -->
        <xsl:param name="string" />
        <xsl:param name="sequence"/>
        <xsl:choose>
            <!-- if the string contains the character... -->
            <xsl:when test="contains($string, $sequence)">
                <!-- call the template recursively... -->
                <xsl:call-template name="lastIndexOf">
                    <!-- with the string being the string after the character
                    -->
                    <xsl:with-param name="string"
                        select="substring-after($string, $sequence)" />
                    <!-- and the character being the same as before -->
                    <xsl:with-param name="char" select="$sequence" />
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise, return the value of the string -->
            <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dri:figure">
        <xsl:if test="@target">
            <a>
                <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                <xsl:if test="@title">
                	<xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@rend">
                	<xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
                </xsl:if>
                <img>
                    <xsl:attribute name="src"><xsl:value-of select="@source"/></xsl:attribute>
                    <xsl:attribute name="alt"><xsl:apply-templates /></xsl:attribute>
                <xsl:attribute name="border"><xsl:text>none</xsl:text></xsl:attribute>
                </img>
            </a>
        </xsl:if>
        <xsl:if test="not(@target)">
            <img>
                <xsl:attribute name="src"><xsl:value-of select="@source"/></xsl:attribute>
                <xsl:attribute name="alt"><xsl:apply-templates /></xsl:attribute>
            </img>
        </xsl:if>
    </xsl:template>


    <!-- The hadling of the special case of instanced composite fields under "form" lists -->
    <xsl:template match="dri:field[@type='composite'][dri:field/dri:instance | dri:params/@operations]" mode="formComposite" priority="2">
        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <div class="form-content">
            <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
            <xsl:if test="contains(dri:params/@operations,'add')">
                <!-- Add buttons should be named "submit_[field]_add" so that we can ignore errors from required fields when simply adding new values-->
                <!-- removed label from add-button 
                    input type="submit" value="Add" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
                -->
               <input type="submit" value="" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
                  <!-- Make invisible if we have choice-lookup operation that provides its own Add. -->
                  <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                    <xsl:attribute name="style">
                      <xsl:text>display:none;</xsl:text>
                    </xsl:attribute>
            </xsl:if>
               </input>
            </xsl:if>
            <!-- insert choice mechansim and/or Add button here -->
            <xsl:choose>
              <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                <xsl:message terminate="yes">
                  <xsl:text>ERROR: Input field with "suggest" (autocomplete) choice behavior is not implemented for Composite (e.g. "name") fields.</xsl:text>
                </xsl:message>
              </xsl:when>
              <!-- lookup popup includes its own Add button if necessary. -->
              <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                <xsl:call-template name="addLookupButton">
                  <xsl:with-param name="isName" select="'true'"/>
                  <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                </xsl:call-template>
              </xsl:when>
            </xsl:choose>
            <!-- place to store authority value -->
            <xsl:if test="dri:params/@authorityControlled">
              <xsl:call-template name="authorityConfidenceIcon">
                <xsl:with-param name="confidence" select="dri:value[@type='authority']/@confidence"/>
                <xsl:with-param name="id" select="$confidenceIndicatorID"/>
              </xsl:call-template>
              <xsl:call-template name="authorityInputFields">
                <xsl:with-param name="name" select="@n"/>
                <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
            <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
            <xsl:apply-templates select="dri:help" mode="compositeComponent"/>
            <xsl:if test="dri:instance or dri:field/dri:instance">
                <div class="previous-values">
                    <xsl:call-template name="fieldIterator">
                        <xsl:with-param name="position">1</xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="contains(dri:params/@operations,'delete') and (dri:instance or dri:field/dri:instance)">
                        <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                        <xsl:choose>
                            <xsl:when test="$languageiso = 'de'">
                                <input type="submit" value="Auswahl entfernen" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="submit" value="delete selected" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:for-each select="dri:field">
                        <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
                    </xsl:for-each>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    
    
    
    
    <!-- TODO: The field section works but needs a lot of scrubbing. I would say a third of the
        templates involved are either bloated or superfluous. -->
           
    
    <!-- Things I know:
        1. I can tell a field is multivalued if it has instances in it
        2. I can't really do that for composites, although I can check its
            component fields for condition 1 above.
        3. Fields can also be inside "form" lists, which is its own unique condition
    -->
        
    <!-- Fieldset (instanced) field stuff, in the case of non-composites -->
    <xsl:template match="dri:field[dri:field/dri:instance | dri:params/@operations]" priority="2">
        <!-- Create the first field normally -->
        <xsl:apply-templates select="." mode="normalField"/>
        <!-- Follow it up with an ADD button if the add operation is specified. This allows
            entering more than one value for this field. -->
        <xsl:if test="contains(dri:params/@operations,'add')">
            <!-- Add buttons should be named "submit_[field]_add" so that we can ignore errors from required fields when simply adding new values-->
            <!-- Removed Label from add-button 
                <input type="submit" value="Add" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
                -->
            <input type="submit" value="" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
              <!-- Make invisible if we have choice-lookup popup that provides its own Add. -->
              <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                <xsl:attribute name="style">
                  <xsl:text>display:none;</xsl:text>
                </xsl:attribute>
        </xsl:if>
           </input>
        </xsl:if>
        <br/>
        <xsl:apply-templates select="dri:help" mode="help"/>
        <xsl:apply-templates select="dri:error" mode="error"/>
        <xsl:if test="dri:instance">
            <div class="previous-values">
                <!-- Iterate over the dri:instance elements contained in this field. The instances contain
                    stored values as either "interpreted", "raw", or "default" values. -->
                <xsl:call-template name="simpleFieldIterator">
                    <xsl:with-param name="position">1</xsl:with-param>
                </xsl:call-template>
                <!-- Conclude with a DELETE button if the delete operation is specified. This allows
                    removing one or more values stored for this field. -->
                <xsl:if test="contains(dri:params/@operations,'delete') and dri:instance">
                    <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                    <xsl:choose>
                        <xsl:when test="$languageiso = 'de'">
                            <input type="submit" value="Auswahl entfernen" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <input type="submit" value="delete selected" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>
                        </xsl:otherwise>
                    </xsl:choose>                    
                </xsl:if>
                <!-- Behind the scenes, add hidden fields for every instance set. This is to make sure that
                    the form still submits the information in those instances, even though they are no
                    longer encoded as HTML fields. The DRI Reference should contain the exact attributes
                    the hidden fields should have in order for this to work properly. -->
                <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- The iterator is a recursive function that creates a checkbox (to be used in deletion) for
        each value instance and interprets the value inside. It also creates a hidden field from the
        raw value contained in the instance. -->
    <xsl:template name="simpleFieldIterator">
        <xsl:param name="position"/>
        <xsl:if test="dri:instance[position()=$position]">
            <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
            <xsl:apply-templates select="dri:instance[position()=$position]" mode="interpreted"/>

            <!-- look for authority value in instance. -->
            <xsl:if test="dri:instance[position()=$position]/dri:value[@type='authority']">
              <xsl:call-template name="authorityConfidenceIcon">
                <xsl:with-param name="confidence" select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
              </xsl:call-template>
            </xsl:if>
            <br/>
            <xsl:call-template name="simpleFieldIterator">
                <xsl:with-param name="position"><xsl:value-of select="$position + 1"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- Authority: added fields for auth values as well. -->
    <!-- Common case: use the raw value of the instance to create the hidden field -->
    <xsl:template match="dri:instance" mode="hiddenInterpreter">
        <input type="hidden">
            <xsl:attribute name="name"><xsl:value-of select="concat(../@n,'_',position())"/></xsl:attribute>
            <xsl:attribute name="value">
                <xsl:value-of select="dri:value[@type='raw']"/>
            </xsl:attribute>
        </input>
        <!-- XXX do we want confidence icon here?? -->
        <xsl:if test="dri:value[@type='authority']">
          <xsl:call-template name="authorityInputFields">
            <xsl:with-param name="name" select="../@n"/>
            <xsl:with-param name="position" select="position()"/>
            <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
            <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
          </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- Select box case: use the selected options contained in the instance to create the hidden fields -->
    <xsl:template match="dri:field[@type='select']/dri:instance" mode="hiddenInterpreter">
        <xsl:variable name="position" select="position()"/>
        <xsl:for-each select="dri:value[@type='option']">
            <input type="hidden">
                <xsl:attribute name="name">
                    <xsl:value-of select="concat(../../@n,'_',$position)"/>
                </xsl:attribute>
                <!-- Since the dri:option and dri:values inside a select field are related by the return
                    value, encoded in @returnValue and @option attributes respectively, the option
                    attribute can be used directly instead of being resolved to the the correct option -->
                <xsl:attribute name="value">
                    <!--<xsl:value-of select="../../dri:option[@returnValue = current()/@option]"/>-->
                    <xsl:value-of select="@option"/>
                </xsl:attribute>
            </input>
        </xsl:for-each>
    </xsl:template>
      
    
    
    <!-- Composite instanced field stuff -->
    <!-- It is also the one that receives the special error and help handling -->
    <xsl:template match="dri:field[@type='composite'][dri:field/dri:instance | dri:params/@operations]" priority="3">
        <!-- First is special, so first we grab all the values from the child fields.
            We do this by applying normal templates to the field, which should ignore instances. -->
        <span class="composite-field">
            <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
        </span>
        <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
        <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
        <xsl:apply-templates select="dri:help" mode="compositeComponent"/>
        <!-- Insert choice mechanism here.
             Follow it up with an ADD button if the add operation is specified. This allows
            entering more than one value for this field. -->

        <xsl:if test="contains(dri:params/@operations,'add')">
            <!-- Add buttons should be named "submit_[field]_add" so that we can ignore errors from required fields when simply adding new values-->
            <!-- removed Add from Add-button
                <input type="submit" value="Add" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
            -->
            <input type="submit" value="" name="{concat('submit_',@n,'_add')}" class="button-field ds-add-button">
              <!-- Make invisible if we have choice-lookup popup that provides its own Add. -->
              <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                <xsl:attribute name="style">
                  <xsl:text>display:none;</xsl:text>
                </xsl:attribute>
        </xsl:if>
           </input>
        </xsl:if>

        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <xsl:if test="dri:params/@authorityControlled">
          <!-- XXX note that this is wrong and won't get any authority values, but
             - for instanced inputs the entry box starts out empty anyway.
            -->
          <xsl:call-template name="authorityConfidenceIcon">
            <xsl:with-param name="confidence" select="dri:value[@type='authority']/@confidence"/>
            <xsl:with-param name="id" select="$confidenceIndicatorID"/>
          </xsl:call-template>
          <xsl:call-template name="authorityInputFields">
            <xsl:with-param name="name" select="@n"/>
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
            <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
            <xsl:call-template name="addAuthorityAutocomplete">
              <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
            </xsl:call-template>
          </xsl:when>
          <!-- lookup popup includes its own Add button if necessary. -->
          <!-- XXX does this need a Confidence Icon? -->
          <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
            <xsl:call-template name="addLookupButton">
              <xsl:with-param name="isName" select="'true'"/>
              <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <br/>
        <xsl:if test="dri:instance or dri:field/dri:instance">
            <div class="previous-values">
                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position">1</xsl:with-param>
                </xsl:call-template>
                <!-- Conclude with a DELETE button if the delete operation is specified. This allows
                    removing one or more values stored for this field. -->
                <xsl:if test="contains(dri:params/@operations,'delete') and (dri:instance or dri:field/dri:instance)">
                    <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                    <xsl:choose>
                        <xsl:when test="$languageiso = 'de'">
                            <input type="submit" value="Auswahl entfernen" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <input type="submit" value="delete selected" name="{concat('submit_',@n,'_delete')}" class="button-field delete-button"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:for-each select="dri:field">
                    <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
        
    <!-- The iterator is a recursive function that creates a checkbox (to be used in deletion) for
        each value instance and interprets the value inside. It also creates a hidden field from the
        raw value contained in the instance.
        
         What makes it different from the simpleFieldIterator is that it works with a composite field's
        components rather than a single field, which requires it to consider several sets of instances. -->
    <xsl:template name="fieldIterator">
        <xsl:param name="position"/>
        <!-- add authority value for this instance -->
        <xsl:if test="dri:instance[position()=$position]/dri:value[@type='authority']">
          <xsl:call-template name="authorityInputFields">
            <xsl:with-param name="name" select="@n"/>
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="authValue" select="dri:instance[position()=$position]/dri:value[@type='authority']/text()"/>
            <xsl:with-param name="confValue" select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <!-- First check to see if the composite itself has a non-empty instance value in that
                position. In that case there is no need to go into the individual fields. -->
            <xsl:when test="count(dri:instance[position()=$position]/dri:value[@type != 'authority'])">
                <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
                <xsl:apply-templates select="dri:instance[position()=$position]" mode="interpreted"/>
                <xsl:call-template name="authorityConfidenceIcon">
                  <xsl:with-param name="confidence" select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
                </xsl:call-template>
                <br/>
                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position"><xsl:value-of select="$position + 1"/></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!-- Otherwise, build the string from the component fields -->
            <xsl:when test="dri:field/dri:instance[position()=$position]">
                <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
                <xsl:apply-templates select="dri:field" mode="compositeField">
                    <xsl:with-param name="position" select="$position"/>
                </xsl:apply-templates>
                <br/>
                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position"><xsl:value-of select="$position + 1"/></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dri:field[@type='text' or @type='textarea']" mode="compositeField">
        <xsl:param name="position">1</xsl:param>
        <xsl:if test="not(position()=1)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <!--<input type="hidden" name="{concat(@n,'_',$position)}" value="{dri:instance[position()=$position]/dri:value[@type='raw']}"/>-->
        <xsl:choose>
            <xsl:when test="dri:instance[position()=$position]/dri:value[@type='interpreted']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:instance[position()=$position]/dri:value[@type='interpreted']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:when test="dri:instance[position()=$position]/dri:value[@type='raw']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:instance[position()=$position]/dri:value[@type='raw']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:when test="dri:instance[position()=$position]/dri:value[@type='default']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:instance[position()=$position]/dri:value[@type='default']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="interpreted-field">No value submitted.</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="dri:field[@type='select']" mode="compositeField">
        <xsl:param name="position">1</xsl:param>
        <xsl:if test="not(position()=1)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:for-each select="dri:instance[position()=$position]/dri:value[@type='option']">
            <input type="hidden" name="{concat(@n,'_',$position)}" value="{../../dri:option[@returnValue = current()/@option]}"/>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="dri:instance[position()=$position]/dri:value[@type='interpreted']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:instance[position()=$position]/dri:value[@type='interpreted']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:when test="dri:instance[position()=$position]/dri:value[@type='option']">
                <span class="interpreted-field">
                    <xsl:for-each select="dri:instance[position()=$position]/dri:value[@type='option']">
                        <xsl:if test="position()=1">
                            <xsl:text>(</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="../../dri:option[@returnValue = current()/@option]"/>
                        <xsl:if test="position()=last()">
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:if test="not(position()=last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="interpreted-field">No value submitted.</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- TODO: make this work? Maybe checkboxes and radio buttons should not be instanced... -->
    <xsl:template match="dri:field[@type='checkbox' or @type='radio']" mode="compositeField">
        <xsl:param name="position">1</xsl:param>
        <xsl:if test="not(position()=1)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="interpreted-field">Checkbox</span>
    </xsl:template>
    
    
    
    
    
    
    
    
    
    
    <xsl:template match="dri:field[@type='select']/dri:instance" mode="interpreted">
        <span class="interpreted-field">
            <xsl:for-each select="dri:value[@type='option']">
                <!--<input type="hidden" name="{concat(../@n,'_',position())}" value="{../../dri:option[@returnValue = current()/@option]}"/>-->
                <xsl:if test="position()=1">
                    <xsl:text>(</xsl:text>
                </xsl:if>
                <xsl:value-of select="../../dri:option[@returnValue = current()/@option]"/>
                <xsl:if test="position()=last()">
                    <xsl:text>)</xsl:text>
                </xsl:if>
                <xsl:if test="not(position()=last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>
    
    
    <xsl:template match="dri:instance" mode="interpreted">
        <!--<input type="hidden" name="{concat(../@n,'_',position())}" value="dri:value[@type='raw']"/>-->
        <xsl:choose>
            <xsl:when test="dri:value[@type='interpreted']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:value[@type='interpreted']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:when test="dri:value[@type='raw']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:value[@type='raw']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:when test="dri:value[@type='default']">
                <span class="interpreted-field"><xsl:apply-templates select="dri:value[@type='default']" mode="interpreted"/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="interpreted-field">No value submitted.</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
        
    
    
    
    <xsl:template match="dri:value" mode="interpreted">
        <xsl:apply-templates />
    </xsl:template>
    
    <!--
    <xsl:template match="dri:field">
    
        Possible child elements:
        params(one), help(zero or one), error(zero or one), value(any), field(one or more � only with the composite type)
        
        Possible attributes:
        @n, @id, @rend
        @disabled
        @required
        @type =
            button: A button input control that when activated by the user will submit the form, including all the fields, back to the server for processing.
            checkbox: A boolean input control which may be toggled by the user. A checkbox may have several fields which share the same name and each of those fields may be toggled independently. This is distinct from a radio button where only one field may be toggled.
            file: An input control that allows the user to select files to be submitted with the form. Note that a form which uses a file field must use the multipart method.
            hidden: An input control that is not rendered on the screen and hidden from the user.
            password: A single-line text input control where the input text is rendered in such a way as to hide the characters from the user.
            radio:  A boolean input control which may be toggled by the user. Multiple radio button fields may share the same name. When this occurs only one field may be selected to be true. This is distinct from a checkbox where multiple fields may be toggled.
            select: A menu input control which allows the user to select from a list of available options.
            text: A single-line text input control.
            textarea: A multi-line text input control.
            composite: A composite input control combines several input controls into a single field. The only fields that may be combined together are: checkbox, password, select, text, and textarea. When fields are combined together they can posses multiple combined values.
    </xsl:template>
        -->
    
    
    
    <!-- The handling of component fields, that is fields that are part of a composite field type -->
    <xsl:template match="dri:field" mode="compositeComponent">
        <xsl:choose>
                <xsl:when test="@type = 'checkbox'  or @type='radio'">
                    <xsl:apply-templates select="." mode="normalField"/>
                    <xsl:if test="dri:label">
                        <br/>
                        <xsl:apply-templates select="dri:label" mode="compositeComponent"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                        <label class="composite-component">
                            <xsl:if test="position()=last()">
                                <xsl:attribute name="class">composite-component last</xsl:attribute>
                            </xsl:if>
                            <xsl:apply-templates select="." mode="normalField"/>
                            <xsl:if test="dri:label">
                                <br/>
                                <xsl:apply-templates select="dri:label" mode="compositeComponent"/>
                            </xsl:if>
                        </label>
                </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dri:error" mode="compositeComponent">
        <xsl:apply-templates select="." mode="error"/>
    </xsl:template>
    
    <xsl:template match="dri:help" mode="compositeComponent">
        <!-- EVIL-HACK: filtering out the filter-help -->
        <xsl:if test="not(../@n='search-filter-controls')">
            <span class="composite-help"><xsl:apply-templates /></span>    
        </xsl:if>        
    </xsl:template>
    
    
        
    <!-- The handling of the field element is more complex. At the moment, the handling of input fields in the
        DRI schema is very similar to HTML, utilizing the same controlled vocabulary in most cases. This makes
        converting DRI fields to HTML inputs a straightforward, if a bit verbose, task. We are currently
        looking at other ways of encoding forms, so this may change in the future. -->
    <!-- The simple field case... not part of a complex field and does not contain instance values -->
    <xsl:template match="dri:field">
        <xsl:apply-templates select="." mode="normalField"/>
        <xsl:if test="not(@type='composite') and ancestor::dri:list[@type='form']">
            <!--
            <xsl:if test="not(@type='checkbox') and not(@type='radio') and not(@type='button')">
                <br/>
            </xsl:if>
            -->
            <xsl:apply-templates select="dri:help" mode="help"/>
            <xsl:apply-templates select="dri:error" mode="error"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dri:field" mode="normalField">
        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>        
        <xsl:choose>
            
            <!-- TODO: this has changed drammatically (see form3.xml) -->
                        <xsl:when test="@type= 'select'">
                            
                                <select>
                                    <xsl:call-template name="fieldAttributes"/>
                                    <xsl:apply-templates/>
                                </select>
                        </xsl:when>
            <xsl:when test="@type= 'textarea'">
                                <textarea>
                                    <xsl:call-template name="fieldAttributes"/>
                                    
                                    <!--
                                        if the cols and rows attributes are not defined we need to call
                                        the tempaltes for them since they are required attributes in strict xhtml
                                     -->
                                    <xsl:choose>
                                        <xsl:when test="not(./dri:params[@cols])">
                                                        <xsl:call-template name="textAreaCols"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="not(./dri:params[@rows])">
                                                <xsl:call-template name="textAreaRows"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    
                                    <xsl:apply-templates />
                                    <xsl:choose>
                                        <xsl:when test="./dri:value[@type='raw']">
                                            <xsl:copy-of select="./dri:value[@type='raw']/node()"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of select="./dri:value[@type='default']/node()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if  test="string-length(./dri:value) &lt; 1">
                                       <i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>
                                    </xsl:if>
                                </textarea>
                                    

              <!-- add place to store authority value -->
              <xsl:if test="dri:params/@authorityControlled">
                <xsl:variable name="confidence">
                  <xsl:if test="./dri:value[@type='authority']">
                   <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                  </xsl:if>
                </xsl:variable>
                <!-- add authority confidence widget -->
                <xsl:call-template name="authorityConfidenceIcon">
                  <xsl:with-param name="confidence" select="$confidence"/>
                  <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                </xsl:call-template>
                <xsl:call-template name="authorityInputFields">
                  <xsl:with-param name="name" select="@n"/>
                  <xsl:with-param name="id" select="@id"/>
                  <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                  <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                  <xsl:with-param name="confIndicatorID" select="$confidenceIndicatorID"/>
                  <xsl:with-param name="unlockButton" select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/@n"/>
                  <xsl:with-param name="unlockHelp" select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/dri:help"/>
                </xsl:call-template>
              </xsl:if>
              <!-- add choice mechanisms -->
              <xsl:choose>
                <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                  <xsl:call-template name="addAuthorityAutocomplete">
                    <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                    <xsl:with-param name="confidenceName">
                      <xsl:value-of select="concat(@n,'_confidence')"/>
                    </xsl:with-param>
                  </xsl:call-template>
            </xsl:when>
                <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                  <xsl:call-template name="addLookupButton">
                    <xsl:with-param name="isName" select="'false'"/>
                    <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                  </xsl:call-template>
                </xsl:when>
              </xsl:choose>
            </xsl:when>

            <!-- This is changing drammatically -->
            <xsl:when test="@type= 'checkbox' or @type= 'radio'">
                <fieldset>
                    
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">
                            <xsl:text></xsl:text><xsl:value-of select="@type"/><xsl:text>-field </xsl:text>
                            <xsl:if test="dri:error">
                                <xsl:text>error </xsl:text>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:attribute name="id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <!-- EVIL-HACK: if licence give additional class -->
                    <xsl:if test="starts-with(../../../@n, 'submit-license')">
                        <xsl:attribute name="class">
                            <xsl:text>checkbox-field license</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <!-- VERY EVIL-HACK: display hint of dfg-allianz differently -->
                        <xsl:when test="./dri:label/text()='xmlui.ssoar.metadata.ssoar.licence.dfg'
                            or ./dri:label/text()='xmlui.ssoar.metadata.ssoar.wgl.collection' 
                            or ./dri:label/text()='xmlui.ssoar.metadata.internal.check.visibility'
                            or ./dri:label/text()='xmlui.ssoar.metadata.internal.check.openaire'">
                            <legend><xsl:apply-templates select="dri:help" mode="compositeComponent" /></legend>
                        </xsl:when>
                        <!-- EVIL-HACK: and not to filter selected label -->
                        <xsl:when test="dri:label 
                            and not(dri:label/i18n:text/text()='xmlui.ArtifactBrowser.SimpleSearch.filter.selected')
                            and not(contains(dri:label/i18n:text/text(),'xmlui.Submission.submit'))">
                            <legend><xsl:apply-templates select="dri:label" mode="compositeComponent" /></legend>
                        </xsl:when>
                        
                    </xsl:choose>
                    <xsl:apply-templates />
                </fieldset>
            </xsl:when>
            <!--
                <input>
                            <xsl:call-template name="fieldAttributes"/>
                    <xsl:if test="dri:value[@checked='yes']">
                                <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </input>
                -->
            <xsl:when test="@type= 'composite'">
                <!-- TODO: add error and help stuff on top of the composite -->
                <span class="composite-field">
                    <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
                </span>
                <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:field/dri:help" mode="compositeComponent"/>
                <!--<xsl:apply-templates select="dri:help" mode="compositeComponent"/>-->
            </xsl:when>
                    <!-- text, password, file, and hidden types are handled the same.
                        Buttons: added the xsl:if check which will override the type attribute button
                            with the value 'submit'. No reset buttons for now...
                    -->
            <xsl:when test="@n='query'">
                   
                        <input id="qt1" name="qt1" style="width:300px;">
                            <xsl:call-template name="fieldAttributes"/>
                            <xsl:if test="@type='button'">
                                <xsl:attribute name="type">submit</xsl:attribute>
                            </xsl:if>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="./dri:value[@type='raw']">
                                        <xsl:value-of select="./dri:value[@type='raw']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="./dri:value[@type='default']"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            
                            <xsl:if test="dri:value/i18n:text">
                                <xsl:attribute name="i18n:attr">value</xsl:attribute>
                            </xsl:if>
                            <!-- EVIL-HACK manually changing size for gui -->
                            <xsl:if test="@id='aspect.discovery.SimpleSearch.field.filter'">
                                <xsl:attribute name="size">18
                                    <!--<xsl:value-of select="./dri:params/@size"/> 
                                    -->
                                </xsl:attribute>
                            </xsl:if>                            
                            <xsl:apply-templates />
                            
                        </input>
                        
                        <xsl:variable name="confIndicatorID" select="concat(@id,'_confidence_indicator')"/>
                        <xsl:if test="dri:params/@authorityControlled">
                            <xsl:variable name="confidence">
                                <xsl:if test="./dri:value[@type='authority']">
                                    <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                                </xsl:if>
                            </xsl:variable>
                            <!-- add authority confidence widget -->
                            <xsl:call-template name="authorityConfidenceIcon">
                                <xsl:with-param name="confidence" select="$confidence"/>
                                <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                            </xsl:call-template>
                            <xsl:call-template name="authorityInputFields">
                                <xsl:with-param name="name" select="@n"/>
                                <xsl:with-param name="id" select="@id"/>
                                <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                                <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                                <xsl:call-template name="addAuthorityAutocomplete">
                                    <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                                    <xsl:with-param name="confidenceName">
                                        <xsl:value-of select="concat(@n,'_confidence')"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                                <xsl:call-template name="addLookupButton">
                                    <xsl:with-param name="isName" select="'false'"/>
                                    <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
            </xsl:when>
            <xsl:when test="@id='aspect.submission.submit.CompletedStep.field.submit_again'">
                <a title="xmlui.Submission.submit.CompletedStep.submit_again" target="_self" href="{$context-path}/submit" i18n:attr="title">			
                    <i18n:text>xmlui.Submission.submit.CompletedStep.submit_again</i18n:text>
                </a>
            </xsl:when>
            <!-- EVIL-HACK: don't create hidden fields for sort options -->
            <xsl:when test="./@id='aspect.discovery.SimpleSearch.field.rpp'
                or @id='aspect.discovery.SimpleSearch.field.sort_by'
                or @id='aspect.discovery.SimpleSearch.field.order'">
                <!-- rien -->
            </xsl:when>
            <xsl:otherwise>
                <input>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:if test="@n='internal_embargo_terms'">
                        <xsl:attribute name="class">text-field submit-text hasDatepicker</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@type='button'">
                        <xsl:attribute name="type">submit</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="./dri:value[@type='raw']">
                                <xsl:value-of select="./dri:value[@type='raw']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./dri:value[@type='default']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                   
                    <xsl:if test="dri:value/i18n:text">
                        <xsl:attribute name="i18n:attr">value</xsl:attribute>
                    </xsl:if>
                    <!-- EVIL-HACK manually changing size for gui -->
                    <xsl:if test="@id='aspect.discovery.SimpleSearch.field.filter'">
                        <xsl:attribute name="size">18
                        <!--<xsl:value-of select="./dri:params/@size"/> 
                        -->
                        </xsl:attribute>
                    </xsl:if>     
                    
                        <xsl:if test="dri:params[@choicesPresentation='suggest']">
                            <xsl:attribute name="class">
                                <xsl:text>text-field submit-text ui-autocomplete-input </xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="autocomplete">
                                <xsl:text>off</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="aria-autocomplete">
                                <xsl:text>list</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="aria-haspopup">
                                <xsl:text>true</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                    
                    <xsl:apply-templates select="dri:help"/>
                    <xsl:apply-templates select="*[not(self::dri:help)]"/>
                    
                </input>

                <xsl:variable name="confIndicatorID" select="concat(@id,'_confidence_indicator')"/>
                <xsl:if test="dri:params/@authorityControlled">
                  <xsl:variable name="confidence">
                    <xsl:if test="./dri:value[@type='authority']">
                      <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                    </xsl:if>
                  </xsl:variable>
                  <!-- add authority confidence widget -->
                  <xsl:call-template name="authorityConfidenceIcon">
                    <xsl:with-param name="confidence" select="$confidence"/>
                    <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                  </xsl:call-template>
                  <xsl:call-template name="authorityInputFields">
                    <xsl:with-param name="name" select="@n"/>
                    <xsl:with-param name="id" select="@id"/>
                    <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                    <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                    <xsl:call-template name="addAuthorityAutocomplete">
                      <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                      <xsl:with-param name="confidenceName">
                        <xsl:value-of select="concat(@n,'_confidence')"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                    <xsl:call-template name="addLookupButton">
                      <xsl:with-param name="isName" select="'false'"/>
                      <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                  </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- A set of standard attributes common to all fields -->
    <xsl:template name="fieldAttributes">
        <xsl:call-template name="standardAttributes">
            <xsl:with-param name="class">
                <xsl:text></xsl:text><xsl:value-of select="@type"/><xsl:text>-field </xsl:text>
                <xsl:if test="dri:error">
                    <xsl:text>error </xsl:text>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="@disabled='yes'">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
        </xsl:if>
        <xsl:if test="@type != 'checkbox' and @type != 'radio' ">
                <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@type != 'select' and @type != 'textarea' and @type != 'checkbox' and @type != 'radio' ">
                <xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@type= 'textarea'">
                <xsl:attribute name="onfocus">javascript:tFocus(this);</xsl:attribute>
        </xsl:if>
    </xsl:template>
        
    <!-- Since the field element contains only the type attribute, all other attributes commonly associated
        with input fields are stored on the params element. Rather than parse the attributes directly, this
        template generates a call to attribute templates, something that is not done in XSL by default. The
        templates for the attributes can be found further down. -->
    <xsl:template match="dri:params">
        <xsl:apply-templates select="@*"/>
    </xsl:template>
    
    
    <xsl:template match="dri:field[@type='select']/dri:option">  
        <xsl:choose>
            <!-- EVIL-HACK: Filter out all scopes but SSOAR -->
            <xsl:when test="(contains(../@id,'AdvancedSearch') and ../@n='scope' and ../@type='select' and not(text()='SSOAR')) or @returnValue='ANY'">
                <!-- Ignore default index -->
            </xsl:when>
            <xsl:otherwise>
                <option>
                    <xsl:attribute name="value"><xsl:value-of select="@returnValue"/></xsl:attribute>
                    <xsl:if test="../dri:value[@type='option'][@option = current()/@returnValue]">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
                    <!-- EVIL-HACK: autolabeling for i18n -->
                    <xsl:apply-templates/> 
                </option>
            </xsl:otherwise>
        </xsl:choose>        
        
    </xsl:template>
    
    <xsl:template match="dri:field[@type='checkbox' or @type='radio']/dri:option">
        <label>
            <input>
                <xsl:attribute name="name"><xsl:value-of select="../@n"/></xsl:attribute>
                <xsl:attribute name="type"><xsl:value-of select="../@type"/></xsl:attribute>
                <xsl:attribute name="value"><xsl:value-of select="@returnValue"/></xsl:attribute>
                <xsl:if test="../dri:value[@type='option'][@option = current()/@returnValue]">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:if test="../@disabled='yes'">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </xsl:if>
            </input>
            <!-- EVIL-HACK: fill in controlled vocabulary terms -->                 
            <xsl:choose>                
                <xsl:when test="starts-with(@returnValue,'thesoz_filter')
                    or starts-with(@returnValue,'classoz_filter')
                    or starts-with(@returnValue,'documentType_filter')
                    or starts-with(@returnValue,'review_filter')
                    or starts-with(@returnValue,'pubstatus_filter')
                    or starts-with(@returnValue,'methods_filter')">
                    <xsl:call-template name="discovery-used-filters">
                        <xsl:with-param name="option" select="."/>
                    </xsl:call-template>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />        
                </xsl:otherwise>
            </xsl:choose>
            
        </label>
    </xsl:template>
    
    <xsl:template name="discovery-used-filters">
        <xsl:param name="option"/>
        
        <xsl:choose>                
            <!--<xsl:when test="starts-with($option/@returnValue,'thesoz_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.thesoz.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>
            <xsl:when test="starts-with($option/@returnValue,'classoz_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>-->
            <xsl:when test="starts-with($option/@returnValue,'documentType_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.document.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>
            <xsl:when test="starts-with($option/@returnValue,'review_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.review.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>
            <xsl:when test="starts-with($option/@returnValue,'pubstatus_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.pubstatus.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>
            
            <xsl:when test="starts-with($option/@returnValue,'methods_filter')">
                <xsl:apply-templates select="$option/i18n:text"/>
                <xsl:text>: </xsl:text>
                <i18n:text>xmlui.ssoar.convoc.methods.<xsl:value-of select="substring-after($option/text(),': ')"/></i18n:text>                  
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>        
            </xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template>
    
    
    <!-- A special case for the value element under field of type 'select'. Instead of being used to create
        the value attribute of an HTML input tag, these are used to create selection options.
    <xsl:template match="dri:field[@type='select']/dri:value" priority="2">
        <option>
            <xsl:attribute name="value"><xsl:value-of select="@optionValue"/></xsl:attribute>
            <xsl:if test="@optionSelected = 'yes'">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </option>
    </xsl:template>-->
    
    <!-- In general cases the value of this element is used directly, so the template does nothing. -->
    <xsl:template match="dri:value" priority="1">
    </xsl:template>
    
    <!-- The field label is usually invoked directly by a higher level tag, so this template does nothing. -->
    <xsl:template match="dri:field/dri:label" priority="2">
    </xsl:template>
    
    <xsl:template match="dri:field/dri:label" mode="compositeComponent">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- The error field handling -->
    <xsl:template match="dri:error">
        <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
        <xsl:if test="i18n:text">
            <xsl:attribute name="i18n:attr">title</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dri:error" mode="error">
        <span class="error">
            <xsl:text>* </xsl:text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    <!-- Help elementns are turning into tooltips. There might be a better way tot do this -->
    <xsl:template match="dri:help">
        <!-- EVIL-HACK: don't show muse over hints f�r submission -->
        <xsl:if test="not(contains(../@id,'submission'))">
            <xsl:attribute name="title">
                <xsl:value-of select="."/>
            </xsl:attribute>    
        </xsl:if>
        
        
        <xsl:if test="i18n:text">
            <xsl:attribute name="i18n:attr">
                <xsl:text>title</xsl:text>
                <xsl:if test="../dri:value/i18n:text">
                    <xsl:text> value</xsl:text>    
                </xsl:if>
            </xsl:attribute>
            
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="dri:help" mode="help">
        <!--Only create the <span> if there is content in the <dri:help> node-->
        <xsl:if test="(./text() or ./node()) and not(./text()='xmlui.ssoar.metadata.ssoar.licence.dfg.hint')
            and not(./text()='xmlui.ssoar.metadata.ssoar.wgl.collection.hint') 
            and not(./text()='xmlui.ssoar.metadata.internal.check.visibility.hint') 
            and not(./text()='xmlui.ssoar.metadata.internal.check.openaire.hint')">
            <span class="field-help">
                <!-- EVIL-HACK: use i18n labels for submission hints -->
                <xsl:apply-templates />
                
            </span>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- The last thing in the structural elements section are the templates to cover the attribute calls.
        Although, by default, XSL only parses elements and text, an explicit call to apply the attributes
        of children tags can still be made. This, in turn, requires templates that handle specific attributes,
        like the kind you see below. The chief amongst them is the pagination attribute contained by divs,
        which creates a new div element to display pagination information. -->
    
    <xsl:template match="@pagination">
        <xsl:param name="position"/>
        <xsl:choose>
            <xsl:when test=". = 'simple'">
                <table class="pagination {$position}">
                    <tr>
                        <th class="pagination">
                            <xsl:choose>
                                <xsl:when test="parent::node()/@previousPage">
                                    <a class="previous-page-link">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="parent::node()/@previousPage"/>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.dri2xhtml.structural.pagination-previous</i18n:text>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>                        
                        </th>
                        <th id="pagination-middle" class="pagination pagination-info">
                            <i18n:translate>
                                <xsl:choose>
                                    <xsl:when test="parent::node()/@itemsTotal = -1">
                                        <i18n:text>xmlui.dri2xhtml.structural.pagination-info.nototal</i18n:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i18n:text>xmlui.dri2xhtml.structural.pagination-info</i18n:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <i18n:param><xsl:value-of select="parent::node()/@firstItemIndex"/></i18n:param>
                                <i18n:param><xsl:value-of select="parent::node()/@lastItemIndex"/></i18n:param>
                                <i18n:param><xsl:value-of select="parent::node()/@itemsTotal"/></i18n:param>
                            </i18n:translate>
                            <!--
                            <xsl:text>Now showing items </xsl:text>
                            <xsl:value-of select="parent::node()/@firstItemIndex"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="parent::node()/@lastItemIndex"/>
                            <xsl:text> of </xsl:text>
                            <xsl:value-of select="parent::node()/@itemsTotal"/>
                                -->
                        </th>
                        <th class="pagination">
                            <xsl:choose>
                                <xsl:when test="parent::node()/@nextPage">
                                    <a class="next-page-link">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="parent::node()/@nextPage"/>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.dri2xhtml.structural.pagination-next</i18n:text>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>  
                        </th>
                    </tr>
                </table>
            </xsl:when>
            <xsl:when test=". = 'masked'">
                <table class="pagination {$position}">
                    <tr>
                        <th class="pagination">
                            <xsl:choose>
                                <xsl:when test="not(parent::node()/@firstItemIndex = 0 or parent::node()/@firstItemIndex = 1)">
                                
                                    <a class="previous-page-link">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                                            <xsl:value-of select="parent::node()/@currentPage - 1"/>
                                            <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.dri2xhtml.structural.pagination-previous</i18n:text>
                                    </a>
                                </xsl:when> 
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose> 
                        </th>    
                        <th id="pagination-middle" class="pagination">                       
                             <i18n:translate>
                                 <xsl:choose>
                                     <xsl:when test="parent::node()/@itemsTotal = -1">
                                         <i18n:text>xmlui.dri2xhtml.structural.pagination-info.nototal</i18n:text>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <i18n:text>xmlui.dri2xhtml.structural.pagination-info</i18n:text>
                                     </xsl:otherwise>
                                 </xsl:choose>
                                 <i18n:param><xsl:value-of select="parent::node()/@firstItemIndex"/></i18n:param>
                                 <i18n:param><xsl:value-of select="parent::node()/@lastItemIndex"/></i18n:param>
                                 <i18n:param><xsl:value-of select="parent::node()/@itemsTotal"/></i18n:param>
                             </i18n:translate>                 
                            <xsl:text>:</xsl:text>
                             <xsl:if test="(parent::node()/@currentPage - 4) &gt; 0">
                                 <span class="resultPageCounterItem">
                                     <a>
                                         <xsl:attribute name="href">
                                             <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                                             <xsl:text>1</xsl:text>
                                             <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                                         </xsl:attribute>
                                         <xsl:text>1</xsl:text>
                                     </a>
                                     <xsl:text> ... </xsl:text>
                                 </span>
                             </xsl:if>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">-3</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">-2</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">-1</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">0</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">1</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">2</xsl:with-param>
                             </xsl:call-template>
                             <xsl:call-template name="offset-link">
                                 <xsl:with-param name="pageOffset">3</xsl:with-param>
                             </xsl:call-template>                       
                             <xsl:if test="(parent::node()/@currentPage + 4) &lt;= (parent::node()/@pagesTotal)">
                                 <span class="resultPageCounterItem">
                                     <xsl:text> ... </xsl:text>
                                     <a>
                                         <xsl:attribute name="href">
                                             <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                                             <xsl:value-of select="parent::node()/@pagesTotal"/>
                                             <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                                         </xsl:attribute>
                                         <xsl:value-of select="parent::node()/@pagesTotal"/>
                                     </a>
                                 </span>
                             </xsl:if>
                        </th>
                        
                        <th class="pagination">
                            <xsl:choose>
                                <xsl:when test="not(parent::node()/@lastItemIndex = parent::node()/@itemsTotal)">
                                     <a class="next-page-link">
                                         <xsl:attribute name="href">
                                             <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                                             <xsl:value-of select="parent::node()/@currentPage + 1"/>
                                             <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                                         </xsl:attribute>
                                         <i18n:text>xmlui.dri2xhtml.structural.pagination-next</i18n:text>
                                     </a>
                                </xsl:when> 
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </th>
                    </tr>
                </table>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- A quick helper function used by the @pagination template for repetitive tasks -->
    <xsl:template name="offset-link">
        <xsl:param name="pageOffset"/>
        <xsl:if test="((parent::node()/@currentPage + $pageOffset) &gt; 0) and
            ((parent::node()/@currentPage + $pageOffset) &lt;= (parent::node()/@pagesTotal))">
            <span class="resultPageCounterItem">
                <xsl:choose>
                    <xsl:when test="$pageOffset = 0">
                        <xsl:attribute name="class">resultPageCounterSelectedItem</xsl:attribute>
                        <xsl:value-of select="parent::node()/@currentPage + $pageOffset"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                                <xsl:value-of select="parent::node()/@currentPage + $pageOffset"/>
                                <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                            </xsl:attribute>
                            <xsl:value-of select="parent::node()/@currentPage + $pageOffset"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
                <!--
                <xsl:if test="$pageOffset = 0">
                    <xsl:attribute name="class">resultPageCounterSelectedItem</xsl:attribute>
                </xsl:if>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="substring-before(parent::node()/@pageURLMask,'{pageNum}')"/>
                        <xsl:value-of select="parent::node()/@currentPage + $pageOffset"/>
                        <xsl:value-of select="substring-after(parent::node()/@pageURLMask,'{pageNum}')"/>
                    </xsl:attribute>
                    <xsl:value-of select="parent::node()/@currentPage + $pageOffset"/>
                </a>-->
            </span>
        </xsl:if>
    </xsl:template>
    
    
    <!-- checkbox and radio fields type uses this attribute -->
    <xsl:template match="@returnValue">
        <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <!-- used for image buttons -->
    <xsl:template match="@source">
        <xsl:attribute name="src"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <!-- size and maxlength used by text, password, and textarea inputs -->
    <xsl:template match="@size">
        <xsl:if test="../id!='aspect.discovery.SimpleSearch.field.filter'">
            <xsl:attribute name="size"><xsl:value-of select="."/></xsl:attribute>    
        </xsl:if>        
    </xsl:template>

     <!-- used by select element -->
    <xsl:template match="@evtbehavior">
        <xsl:param name="behavior" select="."/>
        <xsl:if test="normalize-space($behavior)='submitOnChange'">
            <xsl:attribute name="onchange">this.form.submit();</xsl:attribute>
                </xsl:if>
    </xsl:template>

    <xsl:template match="@maxlength">
        <xsl:attribute name="maxlength"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <!-- "multiple" attribute is used by the <select> input method -->
    <xsl:template match="@multiple[.='yes']">
        <xsl:attribute name="multiple">multiple</xsl:attribute>
    </xsl:template>
    
    <!-- rows and cols attributes are used by textarea input -->
    <xsl:template match="@rows">
        <xsl:attribute name="rows"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@cols">
        <xsl:attribute name="cols"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <!-- The general "catch-all" template for attributes matched, but not handled above -->
    <xsl:template match="@*"></xsl:template>
    
    
    
    
    
    
    
<!-- This is the end of the structural elements section. From here to the end of the document come
    templates devoted to handling the referenceSet and reference elements. Although they are considered
    structural elements, neither of the two contains actual content. Instead, references contain references
    to object metadata under objectMeta, while referenceSets group references together.
-->
    
          
    <!-- Starting off easy here, with a summaryList -->
    
    <!-- Current issues:
        
        1. There is no check for the repository identifier. Need to fix that by concatenating it with the
            object identifier and using the resulting string as the key on items and reps.
        2. The use of a key index across the object store is cryptic and counterintuitive and most likely
            could benefit from better documentation.
    -->
    
    <!-- When you come to an referenceSet you have to make a decision. Since it contains objects, and each
        object is its own entity (and handled in its own template) the decision of the overall structure
        would logically (and traditionally) lie with this template. However, to accomplish this we would
        have to look ahead and check what objects are included in the set, which involves resolving the
        references ahead of time and getting the information from their METS profiles directly.
    
        Since this approach creates strong coupling between the set and the objects it contains, and we
        have tried to avoid that, we use the "pioneer" method. -->
    
    <!-- Summarylist case. This template used to apply templates to the "pioneer" object (the first object
        in the set) and let it figure out what to do. This is no longer the case, as everything has been
        moved to the list model. A special theme, called TableTheme, has beeen created for the purpose of
        preserving the pioneer model. -->
    <xsl:template match="dri:referenceSet[@type = 'summaryList']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <!-- Here we decide whether we have a hierarchical list or a flat one -->
        <xsl:choose>
            <xsl:when test="$requestURI='community-list'">
                <xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
            </xsl:when>
            <xsl:when test="descendant-or-self::dri:referenceSet/@rend='hierarchy' or ancestor::dri:referenceSet/@rend='hierarchy'">
                <ul>
					<!--<xsl:attribute name="style">display: none;<xsl:attribute>-->
                    <xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <tbody>
                    <xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
                </tbody>
            </xsl:otherwise>
        </xsl:choose>
        
       
    </xsl:template>
        
    <!-- First, the detail list case -->
    <xsl:template match="dri:referenceSet[@type = 'detailList']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <ul class="referenceSet-list">
            <xsl:apply-templates select="*[not(name()='head')]" mode="detailList"/>
        </ul>
    </xsl:template>
    
    
    <!-- Next up is the summary view case that at this point applies only to items, since communities and
        collections do not have two separate views. -->
    <xsl:template match="dri:referenceSet[@type = 'summaryView']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="*[not(name()='head')]" mode="summaryView"/>
    </xsl:template>
            
    <!-- Finally, we have the detailed view case that is applicable to items, communities and collections.
        In DRI it constitutes a standard view of collections/communities and a complete metadata listing
        view of items. -->
    <xsl:template match="dri:referenceSet[@type = 'detailView']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="*[not(name()='head')]" mode="detailView"/>
    </xsl:template>
    
    
    
    
    
    <!-- The following options can be appended to the external metadata URL to request specific
        sections of the METS document:
        
        sections:
        
        A comma seperated list of METS sections to included. The possible values are: "metsHdr", "dmdSec",
        "amdSec", "fileSec", "structMap", "structLink", "behaviorSec", and "extraSec". If no list is provided then *ALL*
        sections are rendered.
        
        
        dmdTypes:
        
        A comma seperated list of metadata formats to provide as descriptive metadata. The list of avaialable metadata
        types is defined in the dspace.cfg, disseminationcrosswalks. If no formats are provided them DIM - DSpace
        Intermediate Format - is used.
        
        
        amdTypes:
        
        A comma seperated list of metadata formats to provide administative metadata. DSpace does not currently
        support this type of metadata.
        
        
        fileGrpTypes:
        
        A comma seperated list of file groups to render. For DSpace a bundle is translated into a METS fileGrp, so
        possible values are "THUMBNAIL","CONTENT", "METADATA", etc... If no list is provided then all groups are
        rendered.
        
        
        structTypes:
        
        A comma seperated list of structure types to render. For DSpace there is only one structType: LOGICAL. If this
        is provided then the logical structType will be rendered, otherwise none will. The default operation is to
        render all structure types.
    -->
    
    <!-- Then we resolve the reference tag to an external mets object -->
    <xsl:template match="dri:reference" mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL,ORIGINAL</xsl:text>
            <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
            <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
            </xsl:if>-->
        </xsl:variable>
        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
        
        <xsl:choose>
            <xsl:when test="$requestURI='community-list'">
                <xsl:choose>
                    <xsl:when test="@url='/metadata/handle/community/1/mets.xml'">
                        <ul class="community-list">
                            <xsl:apply-templates select="dri:referenceSet/dri:reference[@url='/metadata/handle/community/10000/mets.xml']" mode="summaryList"/>
                            <xsl:apply-templates select="dri:referenceSet/dri:reference[@url='/metadata/handle/community/20000/mets.xml']" mode="summaryList"/>
                            <xsl:apply-templates select="dri:referenceSet/dri:reference[@url='/metadata/handle/community/30000/mets.xml']" mode="summaryList"/>
                            <xsl:apply-templates select="dri:referenceSet/dri:reference[@url='/metadata/handle/community/40000/mets.xml']" mode="summaryList"/>
                            <!--<xsl:apply-templates select="dri:referenceSet/dri:reference[@type='DSpace Community']/.." mode="summaryList"/>-->
                            <ul>
                                <xsl:apply-templates select="dri:referenceSet/dri:reference[@type='DSpace Collection']/.." mode="summaryList"/>
                            </ul>
                        </ul>
                    </xsl:when>
                    <xsl:when test="@type='DSpace Community'">
                        <xsl:variable name="id">
                            <xsl:value-of select="substring-after(substring-before(@url,'/mets.xml'), 'community/')"/>
                        </xsl:variable>
                        <li class="summary-community">
                            <a href="javascript:toggle({$id})" class="toggle-button">				
                                <xsl:text>[+]</xsl:text>
                            </a>
                            <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
                            <ul id="{$id}"> 
                                <xsl:if test="($id mod 100 = 0) and ($id mod 10000 != 0)">
                                    <xsl:attribute name="style">
                                        <xsl:text>display:none;</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                
                                <xsl:apply-templates select="dri:referenceSet/dri:reference[@type='DSpace Community']/.." mode="summaryList"/>
                                <ul>
                                    <xsl:apply-templates select="dri:referenceSet/dri:reference[@type='DSpace Collection']/.." mode="summaryList"/>
                                </ul>                                
                                <!--<xsl:apply-templates/>-->            
                            </ul>
                        </li>
                    </xsl:when>
                    <xsl:when test="@type='DSpace Collection'">
                        <xsl:variable name="id">
                            <xsl:value-of select="substring-after(substring-before(@url,'/mets.xml'), 'collection/')"/>
                        </xsl:variable>
                            <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
                    </xsl:when>
                </xsl:choose>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="dri:reference" mode="detailList">
        <xsl:variable name="externalMetadataURL">
           <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- No options selected, render the full METS document -->
        </xsl:variable>
        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
        <li>
            <xsl:apply-templates select="document($externalMetadataURL)" mode="detailList"/>
            <xsl:apply-templates />
        </li>
    </xsl:template>
    
    <xsl:template match="dri:reference" mode="summaryView">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
<!--            <xsl:text>file:/C:/DSpace/webapps/ssoar/themes/dri2xhtml</xsl:text>-->
            <xsl:value-of select="@url"/>
            <!-- No options selected, render the full METS document -->
        </xsl:variable>
        
        
        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
        <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryView">
        </xsl:apply-templates>
                
       <!--<xsl:apply-templates/>-->
    </xsl:template>    
    
    
    <xsl:template match="dri:reference" mode="detailView">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- No options selected, render the full METS document -->
        </xsl:variable>
        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
        <xsl:apply-templates select="document($externalMetadataURL)" mode="detailView"/>
        <xsl:apply-templates />
    </xsl:template>
    
    
    
    
    
    <!-- The standard attributes template -->
    <!-- TODO: should probably be moved up some, since it is commonly called -->
    <xsl:template name="standardAttributes">
        <xsl:param name="class"/>
        <xsl:if test="@id">
            <xsl:attribute name="id"><xsl:value-of select="translate(@id,'.','_')"/></xsl:attribute>
        </xsl:if>
        <xsl:attribute name="class">
            <xsl:value-of select="normalize-space($class)"/>
            <xsl:if test="@rend">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@rend"/>
            </xsl:if>
        </xsl:attribute>

    </xsl:template>
    
    <!-- templates for required textarea attributes used if not found in DRI document -->
    <xsl:template name="textAreaCols">
      <xsl:attribute name="cols">20</xsl:attribute>
    </xsl:template>
    
    <xsl:template name="textAreaRows">
      <xsl:attribute name="rows">5</xsl:attribute>
    </xsl:template>
    
    
    
    <!-- This does it for all the DRI elements. The only thing left to do is to handle Cocoon's i18n
        transformer tags that are used for text translation. The templates below simply push through
        the i18n elements so that they can translated after the XSL step. -->   
    <xsl:template match="i18n:text">
       <xsl:param name="text" select="."/>
       <xsl:choose>
         <xsl:when test="contains($text, '&#xa;')">
           <xsl:value-of select="substring-before($text, '&#xa;')"/>
           <ul>
                <xsl:attribute name="style">float:left; list-style-type:none; text-align:left;</xsl:attribute>
                <xsl:call-template name="linebreak">
                  <xsl:with-param name="text" select="substring-after($text,'&#xa;')"/>
                </xsl:call-template>
           </ul>
         </xsl:when>
           <xsl:when test="starts-with($text, 'xmlui.Submission.submit.SelectCollection')">
               <xsl:variable name="suffix" select="substring-after($text, 'xmlui.Submission.submit.SelectCollection.')"/>               
               <xsl:choose>
                   <xsl:when test="$suffix ='head'">
                       <i18n:text>xmlui.ssoar.labels.stock.choose</i18n:text>
                   </xsl:when>
                   <xsl:when test="$suffix ='collection'">
                       <i18n:text>xmlui.ssoar.labels.stock</i18n:text>
                   </xsl:when>
                   <xsl:when test="$suffix ='collection_help'">
                       <i18n:text>xmlui.ssoar.labels.stock.help</i18n:text>
                   </xsl:when>
                   <xsl:when test="$suffix ='collection_default'">
                       <i18n:text>xmlui.ssoar.labels.stock.default</i18n:text>
                   </xsl:when>
               </xsl:choose>
           </xsl:when>
         <xsl:otherwise>
           <xsl:copy-of select="$text"/>
         </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

    <!-- Function to replace \n -->
    <xsl:template name="linebreak">
       <xsl:param name="text" select="."/>
       <xsl:choose>
         <xsl:when test="contains($text, '&#xa;')">
           <li>
           <xsl:value-of select="substring-before($text, '&#xa;')"/>
           </li>
           <xsl:call-template name="linebreak">
             <xsl:with-param name="text" select="substring-after($text,'&#xa;')"/>
           </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="$text"/>
         </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    <xsl:template match="i18n:translate">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="i18n:param">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- =============================================================== -->
    <!-- - - - - - New templates for Choice/Authority control - - - - -  -->
    
    <!-- choose 'hidden' for invisible auth, 'text' lets CSS control it. -->
    <xsl:variable name="authorityInputType" select="'text'"/>
    
    <!-- add button to invoke Choices lookup popup.. assume
      -  that the context is a dri:field, where dri:params/@choices is true.
     -->
    <xsl:template name="addLookupButton">
      <xsl:param name="isName" select="'missing value'"/>
      <!-- optional param if you want to send authority value to diff field -->
      <xsl:param name="authorityInput" select="concat(@n,'_authority')"/>
      <!-- optional param for confidence indicator ID -->
      <xsl:param name="confIndicator" select="''"/>
      <input type="button" name="{concat('lookup_',@n)}" class="button-field ds-add-button" >
        <xsl:attribute name="value">
          <xsl:text>Lookup</xsl:text>
          <xsl:if test="contains(dri:params/@operations,'add')">
              <!-- EVIL-HACK: add-button removed -->
            <!--<xsl:text> &amp; Add</xsl:text>-->
              <img class="required" src="{concat($theme-path,'/typo3export/fileadmin/styles/01_layouts_basics/img/ssoar/edit-addvalue.png')}" />
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="onClick">
          <xsl:text>javascript:DSpaceChoiceLookup('</xsl:text>
          <!-- URL -->
          <xsl:value-of select="concat($context-path,'/admin/lookup')"/>
          <xsl:text>', '</xsl:text>
          <!-- field -->
          <xsl:value-of select="dri:params/@choices"/>
          <xsl:text>', '</xsl:text>
          <!-- formID -->
          <xsl:value-of select="translate(ancestor::dri:div[@interactive='yes']/@id,'.','_')"/>
          <xsl:text>', '</xsl:text>
          <!-- valueInput -->
          <xsl:value-of select="@n"/>
          <xsl:text>', '</xsl:text>
          <!-- authorityInput, name of field to get authority -->
          <xsl:value-of select="$authorityInput"/>
          <xsl:text>', '</xsl:text>
          <!-- Confidence Indicator's ID so lookup can frob it -->
          <xsl:value-of select="$confIndicator"/>
          <xsl:text>', </xsl:text>
          <!-- Collection ID for context -->
          <xsl:choose>
            <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']">
              <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>-1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>, </xsl:text>
          <!-- isName -->
          <xsl:value-of select="$isName"/>
          <xsl:text>, </xsl:text>
          <!-- isRepating -->
          <xsl:value-of select="boolean(contains(dri:params/@operations,'add'))"/>
          <xsl:text>);</xsl:text>
        </xsl:attribute>
      </input>
    </xsl:template>

    <!-- Fragment to display an authority confidence icon.
       -  Insert an invisible 1x1 image which gets "covered" by background
       -  image as dictated by the CSS, so icons are easily adjusted in CSS.
       -  "confidence" param is confidence _value_, i.e. symbolic name
      -->
    <xsl:template name="authorityConfidenceIcon">
      <!-- default confidence value won't show any image. -->
      <xsl:param name="confidence" select="'blank'"/>
      <xsl:param name="id" select="''"/>
      <xsl:variable name="lcConfidence" select="translate($confidence,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
      <img>
        <xsl:if test="string-length($id) > 0">
          <xsl:attribute name="id">
             <xsl:value-of select="$id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="src">
           <xsl:value-of select="concat($theme-path,'/images/invisible.gif')"/>
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:text>authority-confidence </xsl:text>
          <xsl:choose>
            <xsl:when test="string-length($lcConfidence) > 0">
              <xsl:value-of select="concat('cf-',$lcConfidence,' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>cf-blank </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:text>xmlui.authority.confidence.description.cf_</xsl:text>
          <xsl:value-of select="$lcConfidence"/>
        </xsl:attribute>
      </img>
    </xsl:template>

    <!-- Fragment to include an authority confidence hidden input
       - assumes @n is the name of the field.
       -  param is confidence _value_, i.e. integer 0-6
      -->
    <xsl:template name="authorityConfidenceInput">
      <xsl:param name="confidence"/>
      <xsl:param name="name"/>
      <input class="authority-confidence-input" type="hidden">
        <xsl:attribute name="name">
          <xsl:value-of select="$name"/>
        </xsl:attribute>
        <xsl:attribute name="value">
          <xsl:value-of select="$confidence"/>
        </xsl:attribute>
      </input>
    </xsl:template>


    <!-- insert fields needed by Scriptaculous autocomplete -->
    <xsl:template name="addAuthorityAutocompleteWidgets">
      <!-- "spinner" indicator to signal "loading", managed by autocompleter -->
      <!--  put it next to input field -->
      <span style="display:none;">
        <xsl:attribute name="id">
         <xsl:value-of select="concat(translate(@id,'.','_'),'_indicator')"/>
        </xsl:attribute>
        <img alt="Loading...">
          <xsl:attribute name="src">
           <xsl:value-of select="concat($theme-path,'/images/suggest-indicator.gif')"/>
          </xsl:attribute>
        </img>
      </span>
      <!-- This is the anchor for autocomplete popup, div id="..._container" -->
      <!--  put it below input field, give ID to autocomplete below -->
      <div class="autocomplete">
        <xsl:attribute name="id">
         <xsl:value-of select="concat(translate(@id,'.','_'),'_container')"/>
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </div>
    </xsl:template>

    <!-- adds autocomplete fields and setup script to "normal" submit input -->
    <xsl:template name="addAuthorityAutocomplete">
      <xsl:param name="confidenceIndicatorID" select="''"/>
      <xsl:param name="confidenceName" select="''"/>
      <xsl:call-template name="addAuthorityAutocompleteWidgets"/>
      <xsl:call-template name="autocompleteSetup">
        <xsl:with-param name="formID"        select="translate(ancestor::dri:div[@interactive='yes']/@id,'.','_')"/>
        <xsl:with-param name="metadataField" select="@n"/>
        <xsl:with-param name="inputName"     select="@n"/>
        <xsl:with-param name="authorityName" select="concat(@n,'_authority')"/>
        <xsl:with-param name="containerID"   select="concat(translate(@id,'.','_'),'_container')"/>
        <xsl:with-param name="indicatorID"   select="concat(translate(@id,'.','_'),'_indicator')"/>
        <xsl:with-param name="isClosed"      select="contains(dri:params/@choicesClosed,'true')"/>
        <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
        <xsl:with-param name="confidenceName" select="$confidenceName"/>
        <xsl:with-param name="collectionID">
          <xsl:choose>
            <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']">
              <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>-1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>

    <!-- generate the script that sets up autocomplete feature on input field -->
    <!-- ..it has lots of params -->
    <xsl:template name="autocompleteSetup">
      <xsl:param name="formID" select="'missing value'"/>
      <xsl:param name="metadataField" select="'missing value'"/>
      <xsl:param name="inputName" select="'missing value'"/>
      <xsl:param name="authorityName" select="''"/>
      <xsl:param name="containerID" select="'missing value'"/>
      <xsl:param name="collectionID" select="'-1'"/>
      <xsl:param name="indicatorID" select="'missing value'"/>
      <xsl:param name="confidenceIndicatorID" select="''"/>
      <xsl:param name="confidenceName" select="''"/>
      <xsl:param name="isClosed" select="'false'"/>
      <script type="text/javascript">
        <xsl:text>runAfterJSImports.add(function() {</xsl:text>
            <xsl:text>$(document).ready(function() {</xsl:text>
                <xsl:text>var gigo = DSpaceSetupAutocomplete('</xsl:text>
                    <xsl:value-of select="$formID"/>
                    <xsl:text>', { metadataField: '</xsl:text>
                    <xsl:value-of select="$metadataField"/>
                    <xsl:text>', isClosed: '</xsl:text>
                    <xsl:value-of select="$isClosed"/>
                    <xsl:text>', inputName: '</xsl:text>
                    <xsl:value-of select="$inputName"/>
                    <xsl:text>', authorityName: '</xsl:text>
                    <xsl:value-of select="$authorityName"/>
                    <xsl:text>', containerID: '</xsl:text>
                    <xsl:value-of select="$containerID"/>
                    <xsl:text>', indicatorID: '</xsl:text>
                    <xsl:value-of select="$indicatorID"/>
                    <xsl:text>', confidenceIndicatorID: '</xsl:text>
                    <xsl:value-of select="$confidenceIndicatorID"/>
                    <xsl:text>', confidenceName: '</xsl:text>
                    <xsl:value-of select="$confidenceName"/>
                    <xsl:text>', collection: </xsl:text>
                    <xsl:value-of select="$collectionID"/>
                    <xsl:text>, contextPath: '</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>'});</xsl:text>
            <xsl:text>});</xsl:text>
        <xsl:text>});</xsl:text>
      </script>
      <!--<script type="text/javascript">
        <xsl:text>var gigo = DSpaceSetupAutocomplete('</xsl:text>
        <xsl:value-of select="$formID"/>
        <xsl:text>', { metadataField: '</xsl:text>
        <xsl:value-of select="$metadataField"/>
        <xsl:text>', isClosed: '</xsl:text>
        <xsl:value-of select="$isClosed"/>
        <xsl:text>', inputName: '</xsl:text>
        <xsl:value-of select="$inputName"/>
        <xsl:text>', authorityName: '</xsl:text>
        <xsl:value-of select="$authorityName"/>
        <xsl:text>', containerID: '</xsl:text>
        <xsl:value-of select="$containerID"/>
        <xsl:text>', indicatorID: '</xsl:text>
        <xsl:value-of select="$indicatorID"/>
        <xsl:text>', confidenceIndicatorID: '</xsl:text>
        <xsl:value-of select="$confidenceIndicatorID"/>
        <xsl:text>', confidenceName: '</xsl:text>
        <xsl:value-of select="$confidenceName"/>
        <xsl:text>', collection: </xsl:text>
        <xsl:value-of select="$collectionID"/>
        <xsl:text>, contextPath: '</xsl:text>
        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
        <xsl:text>'});</xsl:text>
      </script>-->
    </xsl:template>

    <!-- add the extra _authority{_n?} and _confidence input fields -->
    <xsl:template name="authorityInputFields">
      <xsl:param name="name" select="''"/>
      <xsl:param name="id" select="''"/>
      <xsl:param name="position" select="''"/>
      <xsl:param name="authValue" select="''"/>
      <xsl:param name="confValue" select="''"/>
      <xsl:param name="confIndicatorID" select="''"/>
      <xsl:param name="unlockButton" select="''"/>
      <xsl:param name="unlockHelp" select="''"/>
      <xsl:variable name="authFieldID" select="concat(translate(@id,'.','_'),'_authority')"/>
      <xsl:variable name="confFieldID" select="concat(translate(@id,'.','_'),'_confidence')"/>
      <!-- the authority key value -->
      <input>
        <xsl:attribute name="class">
          <xsl:text>authority-value </xsl:text>
          <xsl:if test="$unlockButton">
            <xsl:text>authority-visible </xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="type"><xsl:value-of select="$authorityInputType"/></xsl:attribute>
        <xsl:attribute name="readonly"><xsl:text>readonly</xsl:text></xsl:attribute>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($name,'_authority')"/>
          <xsl:if test="$position">
            <xsl:value-of select="concat('_', $position)"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:if test="$id">
          <xsl:attribute name="id">
            <xsl:value-of select="$authFieldID"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="value">
          <xsl:value-of select="$authValue"/>
        </xsl:attribute>
        <!-- this updates confidence after a manual change to authority value -->
        <xsl:attribute name="onChange">
          <xsl:text>javascript: return DSpaceAuthorityOnChange(this, '</xsl:text>
          <xsl:value-of select="$confFieldID"/>
          <xsl:text>','</xsl:text>
          <xsl:value-of select="$confIndicatorID"/>
          <xsl:text>');</xsl:text>
        </xsl:attribute>
      </input>
      <!-- optional "unlock" button on (visible) authority value field -->
      <xsl:if test="$unlockButton">
        <input type="image" class="authority-lock is-locked ">
          <xsl:attribute name="onClick">
            <xsl:text>javascript: return DSpaceToggleAuthorityLock(this, '</xsl:text>
            <xsl:value-of select="$authFieldID"/>
            <xsl:text>');</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="src">
             <xsl:value-of select="concat($theme-path,'/images/invisible.gif')"/>
          </xsl:attribute>
          <xsl:attribute name="i18n:attr">title</xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="$unlockHelp"/>
          </xsl:attribute>
        </input>
      </xsl:if>
      <input class="authority-confidence-input" type="hidden">
        <xsl:attribute name="name">
          <xsl:value-of select="concat($name,'_confidence')"/>
          <xsl:if test="$position">
            <xsl:value-of select="concat('_', $position)"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:if test="$id">
          <xsl:attribute name="id">
            <xsl:value-of select="$confFieldID"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="value">
          <xsl:value-of select="$confValue"/>
        </xsl:attribute>
      </input>
    </xsl:template>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
    <!-- Special Transformations for Choice Authority lookup popup page -->

    <!-- indicator spinner -->
    <xsl:template match="dri:item[@id='aspect.general.ChoiceLookupTransformer.item.select']/dri:figure">
      <img id="lookup_indicator_id" alt="Loading..." style="display:none;">
        <xsl:attribute name="src">
         <xsl:value-of select="concat($theme-path,'/images/lookup-indicator.gif')"/>
        </xsl:attribute>
      </img>
    </xsl:template>
    
    <!-- This inline JS must be added to the popup page for choice lookups -->
    <xsl:template name="choiceLookupPopUpSetup">
      <script type="text/javascript">
        var form = document.getElementById('aspect_general_ChoiceLookupTransformer_div_lookup');
        DSpaceChoicesSetup(form);
      </script>
    </xsl:template>

    <!-- Special select widget for lookup popup -->
    <xsl:template match="dri:field[@id='aspect.general.ChoiceLookupTransformer.field.chooser']">
      <div>
        <select onChange="javascript:DSpaceChoicesSelectOnChange();">
          <xsl:call-template name="fieldAttributes"/>
          <xsl:apply-templates/>
          <xsl:comment>space filler because "unclosed" select annoys browsers</xsl:comment>
        </select>
        <img class="choices-lookup" id="lookup_indicator_id" alt="Loading..." style="display:none;">
          <xsl:attribute name="src">
           <xsl:value-of select="concat($theme-path,'/images/lookup-indicator.gif')"/>
          </xsl:attribute>
        </img>
      </div>
    </xsl:template>

    <!-- Generate buttons with onClick attribute, since it is the easiest
       - way to set a single event handler in a browser-independent manner.
      -->

    <!-- choice popup "accept" button -->
    <xsl:template match="dri:field[@id='aspect.general.ChoiceLookupTransformer.field.accept']">
      <xsl:call-template name="choiceLookupButton">
        <xsl:with-param name="onClick" select="'javascript:DSpaceChoicesAcceptOnClick();'"/>
      </xsl:call-template>
    </xsl:template>

    <!-- choice popup "more" button -->
    <xsl:template match="dri:field[@id='aspect.general.ChoiceLookupTransformer.field.more']">
      <xsl:call-template name="choiceLookupButton">
        <xsl:with-param name="onClick" select="'javascript:DSpaceChoicesMoreOnClick();'"/>
      </xsl:call-template>
    </xsl:template>

    <!-- choice popup "cancel" button -->
    <xsl:template match="dri:field[@id='aspect.general.ChoiceLookupTransformer.field.cancel']">
      <xsl:call-template name="choiceLookupButton">
        <xsl:with-param name="onClick" select="'javascript:DSpaceChoicesCancelOnClick();'"/>
      </xsl:call-template>
    </xsl:template>

    <!-- button markup: special handling needed because these must not be <input type=submit> -->
    <xsl:template name="choiceLookupButton">
      <xsl:param name="onClick"/>
      <input type="button" onClick="{$onClick}">
        <xsl:call-template name="fieldAttributes"/>
        <xsl:attribute name="value">
            <xsl:choose>
                <xsl:when test="./dri:value[@type='raw']">
                    <xsl:value-of select="./dri:value[@type='raw']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./dri:value[@type='default']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="dri:value/i18n:text">
            <xsl:attribute name="i18n:attr">value</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
      </input>
    </xsl:template>

    <!-- - - - - - End templates for Choice/Authority control - - - - -  -->
    <!-- =============================================================== -->


    <!-- - - - - - template for harvesting - - - - -  -->
    <xsl:template match="dri:field[@id='aspect.administrative.collection.SetupCollectionHarvestingForm.field.oai-set-comp' and @type='composite']" mode="formComposite" priority="2">
        <xsl:for-each select="dri:field[@type='radio']">
            <div class="form-content">
                <xsl:for-each select="dri:option">
                    <input type="radio">
                        <xsl:attribute name="id"><xsl:value-of select="@returnValue"/></xsl:attribute>
                        <xsl:attribute name="name"><xsl:value-of select="../@n"/></xsl:attribute>
                        <xsl:attribute name="value"><xsl:value-of select="@returnValue"/></xsl:attribute>
                        <xsl:if test="../dri:value[@type='option'][@option = current()/@returnValue]">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                    </input>
                    <label>
                        <xsl:attribute name="for"><xsl:value-of select="@returnValue"/></xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </label>
                    <xsl:if test="@returnValue = 'specific'">
                        <xsl:apply-templates select="../../dri:field[@n='oai_setid']"/>
                    </xsl:if>
                    <br/>
                </xsl:for-each>
            </div>
        </xsl:for-each>
    </xsl:template>



    <!-- Add each RSS feed from meta to a list -->
    <xsl:template name="addRSSLinks">
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <li>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>

                     <xsl:attribute name="style">
                        <xsl:text>background: url(</xsl:text>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/static/icons/feed.png) no-repeat</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="contains(., 'rss_1.0')">
                            <xsl:text>RSS 1.0</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(., 'rss_2.0')">
                            <xsl:text>RSS 2.0</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(., 'atom_1.0')">
                            <xsl:text>Atom</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@qualifier"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </li>
        </xsl:for-each>
    </xsl:template>

    <!--Template for the bitstream reordering-->
    <xsl:template match="dri:cell[starts-with(@id, 'aspect.administrative.item.EditItemBitstreamsForm.cell.bitstream_order_')]" priority="2">
        <td>
            <xsl:call-template name="standardAttributes"/>
            <xsl:apply-templates select="*[not(@type='button')]" />
            <!--A div that will indicate the old & the new order-->
            <div>
                <span>
                    <!--Give this one an ID so that the javascript can change his value-->
                    <xsl:attribute name="id">
                        <xsl:value-of select="dri:field/@id"/>
                        <xsl:text>_new</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="dri:field/dri:value"/>
                </span>
                <xsl:text> (</xsl:text>
                <i18n:text>xmlui.administrative.item.EditItemBitstreamsForm.previous_order</i18n:text>
                <xsl:value-of select="dri:field/dri:value"/>
                <xsl:text>)</xsl:text>
            </div>
        </td>
        <td>
            <xsl:apply-templates select="dri:field[@type='button']"/>
        </td>
    </xsl:template>
    

</xsl:stylesheet>
