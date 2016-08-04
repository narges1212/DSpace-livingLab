<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output encoding="UTF-8" method="html"/>
    <!--<xsl:include href="labels.xsl"/>-->

    <xsl:template match="DBClear">
        <html>
            <head/>
            <body>
                <h1>Chicago Zitationsstil</h1>
                <p>
                    <xsl:apply-templates select="//Resource" mode="chicago"/>
                </p>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="Resource" mode="chicago">
        <xsl:choose>
            <!-- Monographie -->
            <xsl:when test="Stock[@label='monograph']">
                <xsl:for-each select="Attribute[@label='creator']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text>. </xsl:text>
                <xsl:value-of select="Attribute[@label='title']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>. </xsl:text>
                <xsl:value-of select="Attribute[@label='city']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='city']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:value-of select="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
            </xsl:when>
            <!-- Sammelwerk -->
            <xsl:when test="Stock[@label='collection']">
                <xsl:for-each select="Attribute[@label='editor']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <!--<xsl:value-of select="$label_editor"/>-->
                <xsl:text>. </xsl:text>
                <xsl:value-of select="Attribute[@label='title']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:value-of select="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>. </xsl:text>
                <xsl:value-of select="Attribute[@label='city']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='city']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:value-of select="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
            </xsl:when>
            <!-- Beitrag in einem Sammelwerk -->
            <xsl:when test="Stock[@label='incollection']">
                <xsl:for-each select="Attribute[@label='creator']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="Attribute[@label='title']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>." In </xsl:text>
                <em>
                    <xsl:value-of select="Attribute[@label='collectiontitle']/AttributeValue/AttributeComponent/text()"/>
                </em>
                <xsl:if test="Attribute[@label='collectiontitle']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <xsl:text>hrsg. v. </xsl:text>
                <xsl:for-each select="Attribute[@label='editor']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="Attribute[@label='pagescollection']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='pagescollection']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='city']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='city']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:value-of select="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
            </xsl:when>
            <!-- Beitrag in einer Zeitschrift -->
            <xsl:when test="Stock[@label='article']">
                <xsl:for-each select="Attribute[@label='creator']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="Attribute[@label='title']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>." </xsl:text>
                <em>
                    <xsl:value-of select="Attribute[@label='seriestitle']/AttributeValue/AttributeComponent/text()"/>
                </em>
                <xsl:text> </xsl:text>
                <!-- Wenn es Volume oder Issue gibt... -->
                <xsl:if test="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()!='' or Attribute[@label='volume']/AttributeValue/AttributeComponent/text()!=''">
                    <xsl:value-of select="Attribute[@label='volume']/AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()!=''">
                        <xsl:text>, Nr. </xsl:text>
                        <xsl:value-of select="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()"/>
                    </xsl:if>
                </xsl:if>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:choose>
                    <xsl:when test="starts-with(Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text(),'S. ')">
                        <xsl:value-of select="substring-after(Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text(),'S. ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>.</xsl:text>
            </xsl:when>
            <!-- Rezension -->
            <xsl:when test="Stock[@label='recension']">
                <xsl:for-each select="Attribute[@label='creator']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="Attribute[@label='title']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='subtitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>." Rezension zu </xsl:text>
                <xsl:for-each select="Attribute[@label='recensioncreator']">
                    <xsl:value-of select="AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="not(position()=last())">; </xsl:if>
                </xsl:for-each>
                <xsl:text>. </xsl:text>
                <xsl:value-of select="Attribute[@label='recensiontitle']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='recensiontitle']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='recensionedition']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='recensionedition']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <xsl:value-of select="Attribute[@label='recensioncity']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='recensioncity']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:value-of select="Attribute[@label='recensionpublisher']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='recensionpublisher']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <xsl:value-of select="Attribute[@label='recensionpubyear']/AttributeValue/AttributeComponent/text()"/>
                <xsl:if test="Attribute[@label='recensionpubyear']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>
                <!--<xsl:value-of select="Attribute[@label='city']/AttributeValue/AttributeComponent/text()"/>
                            <xsl:if test="Attribute[@label='city']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                            <xsl:value-of select="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()"/>
                            <xsl:if test="Attribute[@label='publisher']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                            <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
                            <xsl:if test="Attribute[@label='recensionpubyear']/AttributeValue/AttributeComponent/text()!=''">. </xsl:if>-->
                <em>
                    <xsl:value-of select="Attribute[@label='seriestitle']/AttributeValue/AttributeComponent/text()"/>
                </em>
                <xsl:if test="Attribute[@label='seriestitle']/AttributeValue/AttributeComponent/text()!=''">, </xsl:if>
                <!-- Wenn es Volume oder Issue gibt... -->
                <xsl:if test="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()!='' or Attribute[@label='volume']/AttributeValue/AttributeComponent/text()!=''">
                    <xsl:value-of select="Attribute[@label='volume']/AttributeValue/AttributeComponent/text()"/>
                    <xsl:if test="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()!=''">
                        <xsl:text>, Nr. </xsl:text>
                        <xsl:value-of select="Attribute[@label='issue']/AttributeValue/AttributeComponent/text()"/>
                    </xsl:if>
                </xsl:if>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="Attribute[@label='pubyear']/AttributeValue/AttributeComponent/text()"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text()!=''">: </xsl:if>
                <xsl:choose>
                    <xsl:when test="starts-with(Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text(),'S. ')">
                        <xsl:value-of select="substring-after(Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text(),'S. ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="Attribute[@label='pagerange']/AttributeValue/AttributeComponent/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>.</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
