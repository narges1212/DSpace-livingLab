<?xml version="1.0" encoding="UTF-8"?>
<!-- 

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

	Developed by DSpace @ Lyncode <dspace@lyncode.com> 
	Following OpenAIRE Guidelines 1.1:
		- http://www.openaire.eu/component/content/article/207

 -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://www.lyncode.com/xoai">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>


    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field/text()">
        <!--  matches all qualified dates, including dc.date.accessioned and dc.date.issued-->
        <xsl:value-of select="." />
    </xsl:template>

    <!-- c.f. http://localhost:8080/OAIHandler/request?verb=GetRecord&metadataPrefix=xoai&identifier=oai:gesis.izsoz.de:document/45689 -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field/text()">
        <!--  matches all unqualified dates, including dc.date = "info:eu-repo/date/embargoEnd/YYYY-MM-DD" -->
        <xsl:value-of select="." />
    </xsl:template>

	<!-- Prefixing dc.type -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field/text()">
		<xsl:call-template name="addPrefix">
			<xsl:with-param name="value" select="." />
			<xsl:with-param name="prefix" select="'info:eu-repo/semantics/'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Prefixing and Modifying dc.rights -->
	<!-- Removing unwanted -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element" />
	<!-- Replacing -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="contains(., 'open access')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'openAccess')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'restrictedAccess')">
				<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'embargoedAccess')">
				<xsl:text>info:eu-repo/semantics/embargoedAccess</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- AUXILIARY TEMPLATES -->
	
	<!-- dc.type prefixing -->
	<xsl:template name="addPrefix">
		<xsl:param name="value" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="starts-with($value, $prefix)">
				<xsl:value-of select="$value" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($prefix, $value)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
