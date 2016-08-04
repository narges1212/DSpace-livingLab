<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xslt" xmlns:doc="http://www.lyncode.com/xoai" xmlns="http://www.ssoar.info/OAI/oai_ddb/"
    version="1.0">

    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
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
        <dublin_core xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ssoar.info/OAI/oai_ddb/ http://www.ssoar.info/OAI/oai_ddb.xsd">
            <xsl:apply-templates select='doc:element[@name="dc"]'/>
            <xsl:apply-templates select='doc:element[@name="bundles"]'/>
            <xsl:if test="contains(//*/doc:element[@name='urn'],'dx.doi.org')">
                <xsl:element name="filepath">
                    <xsl:value-of select="//*/doc:element[@name='urn']"/>
                </xsl:element>
            </xsl:if>
        </dublin_core>

    </xsl:template>

    <xsl:template match="doc:element[@name='dc']">
        <xsl:for-each select=".">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="doc:element">
        <xsl:for-each select="./doc:element[@name!='provenance']">
            <xsl:choose>
                <xsl:when test="doc:element">
                    <xsl:for-each select="doc:element">
                        <xsl:for-each select="./doc:field[@name='value']">
                            <xsl:element name="dcvalue">
                                <xsl:attribute name="element">
                                    <xsl:value-of select="../../../@name"/>
                                </xsl:attribute>
                                <xsl:attribute name="qualifier">
                                    <xsl:value-of select="../../@name"/>
                                </xsl:attribute>
                                <xsl:if test="../@name!='none'">
                                    <xsl:attribute name="language">
                                        <xsl:value-of select="../@name"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="./text()"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:for-each>

                </xsl:when>
                <xsl:when test="doc:field">
                    <xsl:for-each select="./doc:field[@name='value']">
                        <xsl:element name="dcvalue">
                            <xsl:attribute name="element">
                                <xsl:value-of select="../../@name"/>
                            </xsl:attribute>
                            <xsl:if test="../@name!='none'">
                                <xsl:attribute name="language">
                                    <xsl:value-of select="../@name"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="doc:element[@name='bundles']">

        <xsl:for-each select="./doc:element[@name='bundle']">
            <xsl:if test="./doc:field[@name='name']/text() = 'ORIGINAL'">
                <xsl:variable name="sequence" select="./doc:element[@name='bitstreams']/doc:element[1]/doc:field[@name='sid']/text()"/>

                <xsl:variable name="urlprefix">
                    <xsl:text>http://www.ssoar.info/ssoar/bitstream/handle/</xsl:text>
                </xsl:variable>
                <xsl:variable name="name" select="./doc:element[@name='bitstreams']/doc:element[1]/doc:field[@name='name']/text()"/>

                <xsl:variable name="handle" select="//doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text()"/>
                <xsl:element name="filepath">
                    <xsl:value-of select="$urlprefix"/>
                    <xsl:value-of select="$handle"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$name"/>
                    <xsl:text>?sequence=</xsl:text>
                    <xsl:value-of select="$sequence"/>
                </xsl:element>
            </xsl:if>


        </xsl:for-each>
    </xsl:template>







</xsl:stylesheet>
