<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"> 
    
    
    <xsl:template name="generateBibtex">
        <xsl:param name="metadata"/>  
        
        
        <html>
            <head></head>
            <body>
                <pre>
                    <!-- bibtexkey Variable -->
                    <xsl:variable name="bibtexkey">
                        <xsl:choose>
                            <xsl:when
                                test="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author'] != ''">
                                <xsl:value-of
                                    select="substring-before($metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']/text(),',')"
                                />
                            </xsl:when>
                            <xsl:when
                                test="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor'] != ''">
                                <xsl:value-of
                                    select="substring-before($metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']/text(),',')"
                                />
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of
                            select="$metadata/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"
                        />
                    </xsl:variable>
                    <!-- Reference Type -->
                    <xsl:choose>
                        <xsl:when test="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='article'">@article { <xsl:value-of
                            select="$bibtexkey"/>,<xsl:text>&#xD;</xsl:text></xsl:when>
                        <xsl:when test="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='monograph'">@book { <xsl:value-of
                            select="$bibtexkey"/>,<xsl:text>&#xD;</xsl:text></xsl:when>
                        <xsl:when test="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='collection'">@book { <xsl:value-of
                            select="$bibtexkey"/>,<xsl:text>&#xD;</xsl:text></xsl:when>
                        <xsl:when test="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='recension'">@article { <xsl:value-of
                            select="$bibtexkey"/>,<xsl:text>&#xD;</xsl:text></xsl:when>
                        <xsl:when test="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='incollection'">@incollection { <xsl:value-of
                            select="$bibtexkey"/>,<xsl:text>&#xD;</xsl:text></xsl:when>
                        <!--<xsl:when test="Type[@text='researchreport'] "> @book { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='book'] "> @book { <xsl:value-of select="$bibtexkey"
                            />,</xsl:when>
                            <xsl:when test="Type[@text='journal'] "> @incollection { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='serial'] "> @incollection { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='website']"> @misc { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='proceedings'] "> @proceedings { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='phdthesis'] "> @phdthesis { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>
                            <xsl:when test="Type[@text='masterthesis'] "> @masterthesis { <xsl:value-of
                            select="$bibtexkey"/>,</xsl:when>-->
                        <xsl:otherwise> @misc { <xsl:value-of select="$bibtexkey"
                        />,<xsl:text>&#xD;</xsl:text></xsl:otherwise>
                    </xsl:choose>
                    <!-- Title -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                        <xsl:with-param name="biblabel">title</xsl:with-param>
                    </xsl:call-template>
                    <!-- Author -->
                    <!--<xsl:if test="Attribute[@label='creator']/AttributeValue/AttributeComponent/text()!=''"> author = {<xsl:for-each
                        select="Attribute[@label='creator']/AttributeValue">
                        <xsl:value-of select="AttributeComponent/text()"/>
                        <xsl:if test="position() != last()"> and </xsl:if>
                        </xsl:for-each>},</xsl:if>-->
                    <xsl:call-template name="FieldMultiple">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']"/>
                        <xsl:with-param name="biblabel">author</xsl:with-param>
                    </xsl:call-template>
                    <!-- Editor /Secondary Author -->
                    <xsl:call-template name="FieldMultiple">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']"/>
                        <xsl:with-param name="biblabel">editor</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Journal Name -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']"/>
                        <xsl:with-param name="biblabel">journal</xsl:with-param>
                    </xsl:call-template>
                    <!-- Number (Issue) -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']"/>
                        <xsl:with-param name="biblabel">number</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Pages -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']"/>
                        <xsl:with-param name="biblabel">pages</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Volume -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']"/>
                        <xsl:with-param name="biblabel">volume</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Place Published -->
                    <!--
                        <xsl:for-each select="Location[@role='issued']">
                        <xsl:if test="@text != '' ">
                        %C <xsl:value-of select="@text"/></xsl:if>
                        </xsl:for-each>
                    -->
                    <!-- Year -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']"/>
                        <xsl:with-param name="biblabel">year</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Publisher -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]"/>
                        <xsl:with-param name="biblabel">publisher</xsl:with-param>
                    </xsl:call-template>
                    <!-- Keywords  -->
                    <!--         <xsl:for-each select="Subject">
                        %K <xsl:value-of select="@text"/>
                        </xsl:for-each> -->
                    <!-- ISBN / ISSN -->
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='issn']"/>
                        <xsl:with-param name="biblabel">issn</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="Field">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
                        <xsl:with-param name="biblabel">isbn</xsl:with-param>
                    </xsl:call-template>                
                    <!-- URL -->
                    <xsl:call-template name="FieldURN">
                        <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']"/>
                        <xsl:with-param name="biblabel">url</xsl:with-param>
                    </xsl:call-template>                
                    <!-- Abstract -->
                    <xsl:if test="$metadata/dim:field[@mdschema='dc' and @element='description' and @qualifier='abstract']/text()!=''"><xsl:text> abstract = {</xsl:text><xsl:for-each
                        select="$metadata/dim:field[@mdschema='dc' and @element='description' and @qualifier='abstract']/text()">
                        <xsl:value-of select="."/>                   
                    </xsl:for-each><xsl:text>},&#xD;</xsl:text></xsl:if>                                                                           
                    <xsl:text>}</xsl:text>
                                
                </pre>
            </body>
        </html>                    
    </xsl:template>

<xsl:template name="FieldMultiple">
    <xsl:param name="node"/>
    <xsl:param name="biblabel"></xsl:param>
    <xsl:if test="$node/text()!=''">
        <xsl:text> </xsl:text><xsl:value-of select="$biblabel"/><xsl:text> = {</xsl:text><xsl:for-each select="$node/text()">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()"> and </xsl:if>
        </xsl:for-each>
        <xsl:text>},&#xD;</xsl:text>
    </xsl:if>                        
</xsl:template>

    <xsl:template name="Field">
        <xsl:param name="node"/>
        <xsl:param name="biblabel"/>
        <xsl:if test="$node/text()!=''">
            <xsl:text> </xsl:text><xsl:value-of select="$biblabel"/><xsl:text> = {</xsl:text> 
            <xsl:value-of select="$node/text()"/>            
            <xsl:text>},&#xD;</xsl:text>
        </xsl:if>                        
    </xsl:template>


    <xsl:template name="FieldURN">
        <xsl:param name="node"/>
        <xsl:param name="biblabel"/>
        <xsl:if test="$node/text()!=''">
            <xsl:text> </xsl:text><xsl:value-of select="$biblabel"/><xsl:text> = {</xsl:text>        
            <xsl:text>http://nbn-resolving.de/</xsl:text>
            <xsl:value-of select="$node/text()"/>            
            <xsl:text>},&#xD;</xsl:text></xsl:if>                        
    </xsl:template>

</xsl:stylesheet>
