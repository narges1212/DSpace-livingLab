

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim">
    
    
    
    <xsl:template name="generateEndnote">
        <xsl:param name="metadata"/> 
            <!-- Title -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                <xsl:with-param name="biblabel">%T </xsl:with-param>
            </xsl:call-template>
            <!-- Author -->
            <xsl:call-template name="FieldMultipleEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']"/>
                <xsl:with-param name="biblabel">%A </xsl:with-param>
            </xsl:call-template>
            <!-- Editor /Secondary Author -->
            <xsl:call-template name="FieldMultipleEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']"/>
                <xsl:with-param name="biblabel">%E </xsl:with-param>
            </xsl:call-template>                
            <!-- Journal Name -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']"/>
                <xsl:with-param name="biblabel">%J </xsl:with-param>
            </xsl:call-template>
            <!-- Number (Issue) -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']"/>
                <xsl:with-param name="biblabel">%N </xsl:with-param>
            </xsl:call-template>                
            <!-- Pages -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']"/>
                <xsl:with-param name="biblabel">%P </xsl:with-param>
            </xsl:call-template>                
            <!-- Volume -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']"/>
                <xsl:with-param name="biblabel">%V </xsl:with-param>
            </xsl:call-template>                      
            <!-- Place Published 
            <xsl:for-each select="$metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']"/>
                <xsl:if test="text() != '' ">
                    %C <xsl:value-of select="text()"/></xsl:if>
                -->
            
            <!-- Year -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']"/>
                <xsl:with-param name="biblabel">%D </xsl:with-param>
            </xsl:call-template>                
            <!-- Publisher -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]"/>
                <xsl:with-param name="biblabel">%I </xsl:with-param>
            </xsl:call-template>
            <!-- freekeyword -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='subject' and @qualifier='other']"/>
                <xsl:with-param name="biblabel">%K </xsl:with-param>
            </xsl:call-template>
            <!-- ISBN / ISSN -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='issn']"/>
                <xsl:with-param name="biblabel">%@ </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
                <xsl:with-param name="biblabel">%@ </xsl:with-param>
            </xsl:call-template>         
            <!-- Vmdate -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='date' and @qualifier='modified']"/>
                <xsl:with-param name="biblabel">%= </xsl:with-param>
            </xsl:call-template>         
            <!-- contribinst  "Name von Datenbank"  -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='ssoar' and @element='contributor' and @qualifier='institution']"/>
                <xsl:with-param name="biblabel">%~ </xsl:with-param>
            </xsl:call-template>         
            <!-- affiliation "Database Provider" 
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="label">affiliation</xsl:with-param>
                <xsl:with-param name="biblabel">%W </xsl:with-param>
            </xsl:call-template>    
             -->
            <!-- Hier sollte geprft werde, ob die "/" oder "\" bei der Pfad richtig ist.-->
            <!-- Link to PDF "URN" -->
            <xsl:call-template name="FieldURNEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']"/>
                <xsl:with-param name="biblabel">%> </xsl:with-param>
            </xsl:call-template>              
            <!-- URL -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='url']"/>
                <xsl:with-param name="biblabel">%U </xsl:with-param>
            </xsl:call-template>                
            <!-- Abstract -->
            <xsl:if test="$metadata/dim:field[@mdschema='dc' and @element='description' and @qualifier='abstract']/text()!=''">%X <xsl:for-each select="$metadata/dim:field[@mdschema='dc' and @element='description' and @qualifier='abstract']/text()">
                <xsl:value-of select="."/><br/></xsl:for-each>
            </xsl:if>      
            <!-- Titletranlation-->
            <xsl:if test="$metadata/dim:field[@mdschema='dc' and @element='title' and @qualifier='translation']/text()!=''">%Q <xsl:for-each select="$metadata/dim:field[@mdschema='dc' and @element='title' and @qualifier='translation']">
                <xsl:value-of select="./@language"/><xsl:text>: </xsl:text> 
                <xsl:value-of select="./text()"/><br/>          
            </xsl:for-each></xsl:if>
            <!-- Place Published -->
            <xsl:if test="$metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()!='' or 
                           $metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='country']/text()!=''">
                <xsl:text>%C </xsl:text>                 
                <xsl:value-of select="$metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
                <xsl:if test="$metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()!=''"><xsl:text>, </xsl:text></xsl:if>
                <xsl:value-of select="$metadata/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='country']/text()"/><br/>          
            </xsl:if>
            <!-- Language -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='language' and not(@qualifier)]"/>
                <xsl:with-param name="biblabel">%G </xsl:with-param>
            </xsl:call-template>
            <!-- ResourceType -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='type' and @qualifier='document']"/>
                <xsl:with-param name="biblabel">%9 </xsl:with-param>
            </xsl:call-template>
            <!-- PeerRewview -->
            <xsl:call-template name="FieldEndnote">
                <xsl:with-param name="node" select="$metadata/dim:field[@mdschema='dc' and @element='ddescription' and @qualifier='version']"/>
                <xsl:with-param name="biblabel">%* </xsl:with-param>
            </xsl:call-template>            
            <!-- GESIS Label -->            
                <xsl:text>%W GESIS - http://www.gesis.org</xsl:text><br/>
        
            <!-- SSOAR Label -->
                <xsl:text>%~ SSOAR - http://www.ssoar.info</xsl:text><br/>  
            
            <!-- Accessdate -->
            <!--<xsl:text>%[ </xsl:text><xsl:value-of select="java:de.izsoz.dbclear.utils.XSLFunctions.currentUTCTime()"/>                
            <xsl:text>                    
 </xsl:text> -->           
            <!-- Last Modified Date --> <!-- WARNING: Falsches Datumsformar -->
            <!--<xsl:call-template name="FieldEndnote">
                <xsl:with-param name="label">vctime</xsl:with-param>
                <xsl:with-param name="biblabel">%= </xsl:with-param>
            </xsl:call-template>-->
        
        

    </xsl:template>


        <!-- Facette : Language 
            <xsl:if test="Facette[@label=$label]/Category/Name/text()!=''"><xsl:text>                    
 </xsl:text>%Q <xsl:for-each
            select="Facette[@label=$titletranslation]/Category/Name">
            </xsl:for-each></xsl:if>-->
        

    <xsl:template name="FieldMultipleEndnote">
        <xsl:param name="node"/>
        <xsl:param name="biblabel"/>
        <xsl:if test="$node/text()!=''">
            <xsl:value-of select="$biblabel"/>
            <xsl:for-each select="$node/text()">
                <xsl:value-of select="."/><br/>
                <xsl:if test="position() != last()">
                    <xsl:text>%A </xsl:text>
                </xsl:if>                
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template name="FieldEndnote">
        <xsl:param name="node"/>
        <xsl:param name="biblabel"/>
        <xsl:if test="$node/text()!=''">
            <xsl:value-of select="$biblabel"/>
            <xsl:value-of select="normalize-space($node/text())"/><br/>         
        </xsl:if>
    </xsl:template>

    <xsl:template name="FieldURNEndnote">
        <xsl:param name="node"/>
        <xsl:param name="biblabel"/>
        <xsl:if test="$node/text()!=''">
            <xsl:value-of select="$biblabel"/>
            <xsl:text>http://nbn-resolving.de/</xsl:text>
            <xsl:value-of select="normalize-space($node/text())"/><br/>          
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
