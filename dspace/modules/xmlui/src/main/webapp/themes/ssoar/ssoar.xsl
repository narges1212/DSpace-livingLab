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
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:import href="../dri2xhtml.xsl"/>
    <xsl:output indent="yes"/>
    
	
    <xsl:variable name="language">
        <xsl:choose>
            <xsl:when test="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='language']/text()='de'">
                <xsl:text>de</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>en</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="starts-with(.,'xmlui.')">
                <i18n:text>
                    <xsl:value-of select="."/>
                </i18n:text>
            </xsl:when>
            <xsl:when test="../../@n='subscriptions' and ../@returnValue!='-1'">
                <i18n:text>xmlui.ssoar.convoc.classoz.<xsl:value-of select="../@returnValue"/></i18n:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:template>
         
         
            
</xsl:stylesheet>
