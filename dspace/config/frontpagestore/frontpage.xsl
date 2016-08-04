<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:mets="http://www.loc.gov/METS/" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" version="1.0">
    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
    
    <xsl:variable name="workingDirectory">
        <xsl:text>${ssoar.frontpage.xslt}</xsl:text>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:apply-templates select="mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
    </xsl:template>    
    <xsl:variable name="ssoar-green">
        <xsl:text>#E0F0B2</xsl:text>        
    </xsl:variable>
    <xsl:variable name="urnprefix">
        <xsl:text>http://nbn-resolving.de/</xsl:text>
    </xsl:variable>
    <xsl:variable name="font-style">
        <xsl:text>Arial,sans-serif</xsl:text>
    </xsl:variable>

    <xsl:template match="dim:dim">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="DIN-A4" page-height="29.7cm" page-width="21cm" margin-left="2.1cm" margin-right="2.2cm">
                    <fo:region-body/>
                    <fo:region-before region-name="header" extent="0cm"/>
                    <fo:region-after region-name="footer" extent="20mm"/>
                    <fo:region-start region-name="left" extent="0cm"/>
                    <fo:region-end region-name="right" extent="0cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="DIN-A4">
                                
                <!-- insert footer -->
                <xsl:call-template name="footer">
                    <xsl:with-param name="dimNode" select="."/>
                </xsl:call-template>
                
                <!-- body -->
                <fo:flow flow-name="xsl-region-body" font-family="{$font-style}" font-size="9pt">
                    <!-- insert SSOAR-Logo and link -->
                    <xsl:call-template name="insertHeader"/>

                    <!-- insert main metadata-blcok -->
                    <xsl:call-template name="metadataBlock">
                        <xsl:with-param name="dimNode" select="."/>
                    </xsl:call-template>

                    <!-- Insert dfg block -->
                    <xsl:if test="./dim:field[@mdschema='ssoar' and @element='licence' and @qualifier='dfg']/text()='true'">
                        <fo:block-container width="100%" display-align="after" padding-before="5mm">
                            <fo:block font-size="9" font-style="italic">
                                <fo:inline>Dieser Beitrag ist mit Zustimmung des Rechteinhabers aufgrund einer (DFG </fo:inline>
                                <fo:inline>geförderten) Allianz- bzw. Nationallizenz frei zugänglich. / This publication is with permission
                                    of the rights owner freely </fo:inline>
                                <fo:inline>accessible due to an Alliance licence and a national licence (funded by the DFG, German Research
                                    Foundation) respectively.</fo:inline>
                            </fo:block>
                        </fo:block-container>
                    </xsl:if>

                    <!-- Insert citationinfo -->
                    <fo:block-container width="100%" display-align="after" padding-before="7mm">
                        <fo:block>
                            <xsl:call-template name="citationBlock">
                                <xsl:with-param name="dimNode" select="."/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:block-container>

                    <!-- Insert licence terms -->
                    <xsl:call-template name="licenceBlock">
                        <xsl:with-param name="dimNode" select="."/>
                    </xsl:call-template>


                    <!-- Insert images -->
                    <xsl:call-template name="insertImages"/>

                </fo:flow>

            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    
    <xsl:template name="insertHeader">
        
        <fo:block-container position="absolute" top="19mm">
            <fo:block>
                <fo:external-graphic src="url('{$workingDirectory}/img/ssoar_logo_without_colorspace.bmp')" content-height="scale-to-fit" width="47mm" height="18.2mm" scaling="non-uniform"/>
            </fo:block>
        </fo:block-container>
        <fo:block-container position="absolute" top="29.5mm" left="74mm">
            <fo:block>
                <fo:external-graphic src="url('{$workingDirectory}/img/ssoar_claim_without_colorspace.bmp')" content-height="scale-to-fit" width="93mm" height="10mm" scaling="non-uniform"/>
            </fo:block>
        </fo:block-container>
        
        <fo:block-container width="100%" padding-before="40mm">
            <fo:block text-align="right" font-size="18pt" font-weight="bold" color="#FF9100">                
                    <fo:basic-link external-destination="url('http://www.ssoar.info')">
                        <xsl:text>www.ssoar.info</xsl:text>
                    </fo:basic-link>                
            </fo:block>
        </fo:block-container>
    </xsl:template>
    
    <xsl:template name="footer">
        <xsl:param name="dimNode"/>
        <!-- Footer, inserted if document has another pid (not only an URN)-->
        <xsl:if
            test="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']
            or ./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='pid']">
            <xsl:variable name="urn">
                <xsl:if test="contains($dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text(),'urn:')">
                    <xsl:if test="not(contains($dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text(),'http://nbn-resolving.de'))">
                        <xsl:value-of select="$urnprefix"/>
                    </xsl:if>
                </xsl:if>
                <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
            </xsl:variable>
            <fo:static-content flow-name="footer" font-family="{$font-style}" >               
                <fo:block font-size="10pt"  border-top="solid" border-width="1px" padding-before="2mm">
                    <fo:inline>Diese Version ist zitierbar unter / This version is citable under: </fo:inline>
                    
                    <!--<fo:inline> / </fo:inline>
                    <fo:inline></fo:inline>
                    <fo:basic-link external-destination="url('{$urn}')" color="blue" text-decoration="underline">
                        <xsl:value-of select="$urn"/>
                    </fo:basic-link>-->
                </fo:block>
                <fo:block font-size="10pt">
                    <fo:basic-link external-destination="url('{$urn}')" color="blue" text-decoration="underline">
                        <xsl:value-of select="$urn"/>
                    </fo:basic-link>
                </fo:block>
                <!--<fo:block font-size="10pt"  border-top="solid" border-width="1px" padding-before="2mm">
                    <fo:block>
                        <fo:inline>Diese Version ist verfügbar unter: </fo:inline>
                        <fo:basic-link external-destination="url('{$urn}')" color="blue" text-decoration="underline">
                            <xsl:value-of select="$urn"/>
                        </fo:basic-link>
                    </fo:block>
                    <!-\-<fo:inline> / </fo:inline>-\->
                    <fo:block>
                        <fo:inline>This version is available under: </fo:inline>
                        <fo:basic-link external-destination="url('{$urn}')" color="blue" text-decoration="underline">
                            <xsl:value-of select="$urn"/>
                        </fo:basic-link>
                    </fo:block>                    
                </fo:block>-->
            </fo:static-content>
        </xsl:if>
    </xsl:template>


    <xsl:template name="insertImages">        
        <fo:block-container position="absolute" top="255.1mm">
            <fo:block>
                <fo:external-graphic src="url('{$workingDirectory}/img/gesis_logol_without_colorspace.bmp')" content-height="scale-to-fit" width="26.5mm" height="13.8mm" scaling="non-uniform"/>
            </fo:block>
        </fo:block-container>
        <fo:block-container position="absolute" top="253.7mm" left="135.5mm">
            <fo:block>
                <fo:external-graphic src="url('{$workingDirectory}/img/leibniz_logo_without_colorspace.bmp')" content-height="scale-to-fit" width="24.5mm" height="16.8mm" scaling="non-uniform"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>


    <xsl:template name="metadataBlock">        
        <xsl:param name="dimNode"/>
        <!--<xsl:variable name="ssoar-green">#E0F0B2</xsl:variable>-->
        
         <!--Insert top rounded corners-->       
        <fo:block-container position="relative" padding-top="20mm" >
            <fo:block line-height="0.5mm">                 
                 <fo:instream-foreign-object>
                     <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" height="5.5mm"  width="473.695px">
                         <rect x="0" y="0" rx="5mm" ry="5mm" width="100%" height="10mm" style="fill:{$ssoar-green};"/>
                     </svg>
                 </fo:instream-foreign-object>
             </fo:block>
        </fo:block-container> 
        
        <xsl:choose>
            <!-- insert cooperation notification when entry in ssoar.contributor.institution -->
            <xsl:when test="$dimNode/dim:field[@mdschema='ssoar' and @element='contributor' and @qualifier='institution']">
                <fo:block-container background-color="{$ssoar-green}">
                    <xsl:call-template name="displayMetadata">
                        <xsl:with-param name="dimNode" select="$dimNode"/>
                    </xsl:call-template>
                </fo:block-container>
                <xsl:call-template name="cooperationBlock">
                    <xsl:with-param name="institution">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='ssoar' and @element='contributor' and @qualifier='institution']/text()"/>
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            
            <!-- insert regular metadatablock -->
            <xsl:otherwise>
                <fo:block-container background-color="{$ssoar-green}">
                    <xsl:call-template name="displayMetadata">
                        <xsl:with-param name="dimNode" select="$dimNode"/>
                    </xsl:call-template>
                </fo:block-container>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Insert bottom rounded corners -->
        <fo:block line-height="0" padding-before="4px" >
            <fo:instream-foreign-object>
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" height="5mm" width="473.695px">
                    <rect x="0" y="-5mm" rx="5mm" ry="5mm" width="100%" height="10mm" style="fill:{$ssoar-green};"/>
                </svg>
            </fo:instream-foreign-object>
        </fo:block>
    </xsl:template>

    <xsl:template name="displayMetadata">
        <xsl:param name="dimNode"/>
               
        <fo:block font-size="18pt" font-weight="bold"  start-indent="5mm" end-indent="5mm">
            <xsl:value-of select="$dimNode/dim:field[@element='title' and not(@qualifier)]"/>
        </fo:block>
        <xsl:choose>
            <xsl:when test="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                <fo:block font-size="13pt" start-indent="5mm" end-indent="5mm">
                    <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                        <xsl:value-of select="./text()"/>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </fo:block>
            </xsl:when>
            <xsl:when test="not($dimNode/dim:field[@element='contributor' and @qualifier='author']) and
                $dimNode/dim:field[@element='contributor' and @qualifier='editor']">
                <fo:block font-size="13pt" start-indent="5mm" end-indent="5mm">
                    <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='editor']">
                        <xsl:value-of select="./text()"/>
                        <xsl:text> (Ed.)</xsl:text>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>                        
                    </xsl:for-each>
                </fo:block>
            </xsl:when>
        </xsl:choose>
        

        <xsl:if
            test="($dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='pubstatus']
            and $dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='pubstatus']/text() != '4')
            or $dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']">
            <fo:block font-size="10pt" padding-before="0.5cm" start-indent="5mm" end-indent="5mm">
                <xsl:if
                    test="$dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='pubstatus']
                and $dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='pubstatus']/text() != '4'">
                    <fo:block>
                        <xsl:value-of
                            select="$dimNode/dim:field[@mdschema='dc' and @element='description' and @qualifier='pubstatus' and @language='de']/text()"/>
                        <xsl:text> / </xsl:text>
                        <xsl:value-of
                            select="$dimNode/dim:field[@mdschema='dc' and @element='description' and @qualifier='pubstatus' and @language='en']/text()"
                        />
                    </fo:block>
                </xsl:if>

                <xsl:if test="$dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='document']">
                    <fo:block padding-before="0.1cm" start-indent="5mm" end-indent="5mm">
                        <xsl:value-of
                            select="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='document' and @language='de']/text()"/>
                        <xsl:text> / </xsl:text>
                        <xsl:value-of
                            select="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='document' and @language='en']/text()"
                        />
                    </fo:block>
                </xsl:if>
            </fo:block>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="cooperationBlock">
        <xsl:param name="institution"/>
        
        <xsl:choose>
            
            <!-- publisher -->
            <xsl:when test="$institution = 'Bertelsmann'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Bertelsmann</xsl:text>        
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            <xsl:when test="$institution = 'Centaurus-Verlag'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Centaurus-Verlag</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Rainer Hampp Verlag'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Rainer Hampp Verlag</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Verlag Barbara Budrich'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Verlag Barbara Budrich</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            
            <!-- projects -->
            <xsl:when test="$institution = 'OAPEN'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>OAPEN (Open Access Publishing in European Networks)</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'http://www.peerproject.eu/'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>www.peerproject.eu</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'pairfam'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>pairfam - Das Beziehungs- und Familienpanel</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            
            <!-- institutions --> 
            <xsl:when test="$institution = 'GESIS'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>GESIS - Leibniz-Institut für Sozialwissenschaften</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'USB Köln'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>SSG Sozialwissenschaften, USB Köln</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'GIGA'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>GIGA German Institute of Global and Area Studies</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'WZB'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Wissenschaftszentrum Berlin für Sozialforschung (WZB)</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'SWP'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Stiftung Wissenschaft und Politik (SWP)</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'ARL'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Akademie für Raumforschung und Landesplanung (ARL)</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'ISF München'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Institut für Sozialwissenschaftliche Forschung e.V. - ISF München</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Hannah-Arendt-Institut'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Hannah-Arendt-Institut für Totalitarismusforschung e.V. an der TU Dresden</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>                        
            <xsl:when test="$institution = 'HSFK'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Hessische Stiftung Friedens- und Konfliktforschung (HSFK)</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Deutsches Institut für Menschenrechte'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Deutsches Institut für Menschenrechte</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Institut für Schulqualität der Länder Berlin und Brandenburg e.V.'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Institut für Schulqualität der Länder Berlin und Brandenburg e.V.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'iFQ - Institut für Forschungsinformation und Qualitätssicherung'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>iFQ - Institut für Forschungsinformation und Qualitätssicherung</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Helmholtz-Zentrum für Umweltforschung - UFZ'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Helmholtz-Zentrum für Umweltforschung - UFZ</xsl:text>
                    </xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="$institution = 'Bundespresseamt'">
                <xsl:call-template name="displayCooperation">
                    <xsl:with-param name="name">
                        <xsl:text>Institut für Demoskopie Allensbach (IfD) im Auftrag der Bundesregierung der Bundesrepublik Deutschland</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="displayCooperation">
        <xsl:param name="name"/>
        <fo:block-container background-color="{$ssoar-green}"  position="relative" display-align="after">
            <fo:block font-size="10pt" font-weight="bold" start-indent="5mm" end-indent="5mm" padding-before="5mm">
                <xsl:text>Zur Verfügung gestellt in Kooperation mit / provided in cooperation with:</xsl:text>
            </fo:block>
            <fo:block font-size="10pt" padding-before="1mm" start-indent="5mm" end-indent="5mm">
                <xsl:value-of select="$name"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="citationBlock">
        <xsl:param name="dimNode"/>
        <fo:block font-size="9pt" font-weight="bold"> Empfohlene Zitierung / Suggested Citation: </fo:block>
        <fo:block font-size="9pt">
            <xsl:choose>
                <!-- Monographie -->
                <xsl:when test="$dimNode/dim:field[@element='type' and @qualifier='stock']/text()='monograph'">
                    
                    <!-- author -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                            <xsl:value-of select="./text()"/>
                            <xsl:if test="position() != last()">
                                <xsl:text> ; </xsl:text>    
                            </xsl:if>
                        </xsl:for-each>  
                        <xsl:choose>
                            <xsl:when test="not($dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor'])">
                                <xsl:text> : </xsl:text>    
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> ; </xsl:text> 
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    
                    <!-- editor -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='corporateeditor']">
                            <xsl:value-of select="./text()"/>
                            <xsl:if test="position()!=last()">
                                <xsl:text> ; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text> (Ed.): </xsl:text>
                    </xsl:if>
                    
                    <!-- dc.title -->
                    <fo:inline font-style="italic">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                    </fo:inline>
                    <xsl:text>. </xsl:text>

                    <!-- dc.publisher.* -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                            <xsl:text> : </xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                                or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>                        
                    </xsl:if>
                    <xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']/text()"/>
                        <xsl:if
                            test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                            and $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]
                        or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']">
                        <xsl:text> - ISBN </xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:when>

                <!-- Sammelwerke -->
                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='collection'">
                    <!-- editor -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='editor']">
                            <xsl:value-of select="./text()"/>                            
                            <xsl:if test="position()!=last()">
                                <xsl:text> (Ed.) ; </xsl:text>
                            </xsl:if>                            
                        </xsl:for-each>
                        <!-- corporateeditor -->
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@element='contributor' and @qualifier='corporateeditor']">
                                <xsl:text> (Ed.) ; </xsl:text>
                                <xsl:value-of select="$dimNode/dim:field[@element='contributor' and @qualifier='corporateeditor']"/>
                                <xsl:text> (Ed.): </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> (Ed.): </xsl:text>        
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:if>

                    <!-- dc.title -->
                    <fo:inline font-style="italic">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                    </fo:inline>
                    <xsl:text>. </xsl:text>

                    <!-- dc.publisher.* -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                            <xsl:text> : </xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                                or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>                        
                    </xsl:if>
                    <xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']/text()"/>
                        <xsl:if
                            test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                            and $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]
                        or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']">
                        <xsl:text> - ISBN </xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
                        <xsl:text>.</xsl:text>
                    </xsl:if>                    
                </xsl:when>

                <!-- Beitrag in einem Sammelwerke -->
                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='incollection'">
                    <!-- author -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                            <xsl:value-of select="./text()"/>
                            <xsl:if test="position()!=last()">
                                <xsl:text> ; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>: </xsl:text>
                    </xsl:if>

                    <!-- dc.title -->
                    <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                    <xsl:text>. </xsl:text>

                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
                        <xsl:text>In: </xsl:text>
                    </xsl:if>
                    
                    <!-- editor -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
                        <!-- editor -->
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='editor']">
                            <xsl:value-of select="./text()"/>                            
                            <xsl:if test="position()!=last()">
                                <xsl:text> (Ed.) ; </xsl:text>
                            </xsl:if>                            
                        </xsl:for-each>
                        <!-- corporateeditor -->
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@element='contributor' and @qualifier='corporateeditor']">
                                <xsl:text> (Ed.) ; </xsl:text>
                                <xsl:value-of select="$dimNode/dim:field[@element='contributor' and @qualifier='corporateeditor']"/>
                                <xsl:text> (Ed.)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>(Ed.)</xsl:text>        
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']">
                            <xsl:text>: </xsl:text>
                        </xsl:if>
                    </xsl:if>                    
                            
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']">
                        <fo:inline font-style="italic">
                            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']/text()"/>
                        </fo:inline>    
                    </xsl:if>
                    
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='collection']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='editor']
                        or $dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='corporateeditor']">
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                             
                                                          
                    <!-- dc.publisher.* -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']">                        
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city']/text()"/>
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                            <xsl:text> : </xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]/text()"/>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                                or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>                        
                    </xsl:if>
                    <xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series']/text()"/>
                        <xsl:if
                            test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                            and $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='publisher' and @qualifier='city'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='publisher' and not(@qualifier)]
                        or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='series'] 
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']">
                        <xsl:text> - ISBN </xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
                        <xsl:choose>
                            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>. </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
                        <xsl:call-template name="pageinfo">
                            <xsl:with-param name="pageinfo"
                                select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
                        </xsl:call-template>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:when>

                <!-- Beitrag in einer Zeitschrift -->
                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='article'">
                    <!-- author -->
                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
                        <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                            <xsl:value-of select="./text()"/>
                            <xsl:if test="position()!=last()">
                                <xsl:text> ; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>: </xsl:text>
                    </xsl:if>

                    <!-- dc.title -->
                    <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='title' and not(@qualifier)]"/>
                    <xsl:text>. </xsl:text>

                    <!--<xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']
                        or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:text>, </xsl:text>
                    </xsl:if>-->

                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']">
                        <xsl:text>In: </xsl:text>
                        <fo:inline font-style="italic">
                            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()"/>
                        </fo:inline>
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
                        </xsl:if>
                    </xsl:if>

                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>

                    <xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']
                        or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                        <xsl:choose>
                            <xsl:when
                                test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>. </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:if>

                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']/text()"/>
                    </xsl:if>

                    <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
                        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
                            <xsl:text>, </xsl:text>
                        </xsl:if>

                        <xsl:call-template name="pageinfo">
                            <xsl:with-param name="pageinfo"
                                select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if
                        test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']
                        or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:when>

                <!-- Rezension -->
                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='type' and @qualifier='stock']/text()='recension'">
                    <xsl:call-template name="recensionSource">
                        <xsl:with-param name="dimNode" select="."/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>

            
            
            <xsl:choose>
                <xsl:when test="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']
                    or ./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='pid']">
                    <xsl:variable name="link">
                        <xsl:choose>
                            <xsl:when test="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']">
                                <xsl:value-of select="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']/text()"
                                />
                            </xsl:when>
                            <xsl:when test="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='pid']">
                                <xsl:value-of select="./dim:field[@mdschema='dc' and @element='identifier' and @qualifier='pid']/text()"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:text> DOI: </xsl:text>
                    <fo:basic-link external-destination="url('{$link}')" color="blue" text-decoration="underline">
                        <xsl:value-of select="$link"/>
                    </fo:basic-link>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="urn">    
                        <xsl:if test="contains($dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text(),'urn')">
                            <xsl:if test="not(contains($dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text(),'http://nbn-resolving.de'))">
                                <xsl:value-of select="$urnprefix"/>
                            </xsl:if>
                        </xsl:if> 
                        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='urn']/text()"/>
                    </xsl:variable>
                    <xsl:text> URN: </xsl:text>
                    <fo:basic-link external-destination="url('{$urn}')" color="blue" text-decoration="underline">
                        <xsl:value-of select="$urn"/>
                    </fo:basic-link>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:template name="pageinfo">
        <xsl:param name="pageinfo"/>
        <xsl:if test="$pageinfo != ''">
            <xsl:choose>
                <xsl:when
                    test="contains($pageinfo,'S') or contains($pageinfo,'s')
                    or contains($pageinfo,'p') or contains($pageinfo,'P')">
                    <xsl:value-of select="$pageinfo"/>
                </xsl:when>
                <xsl:when test="contains($pageinfo, '-')">
                    <xsl:text>pp. </xsl:text>
                    <xsl:value-of select="$pageinfo"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pageinfo"/>
                    <xsl:text> pages</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="recensionSource">
        <xsl:param name="dimNode"/>
        <!-- author -->
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
            <xsl:for-each select="$dimNode/dim:field[@element='contributor' and @qualifier='author']">
                <xsl:value-of select="./text()"/>
                <xsl:if test="position()!=last()">
                    <xsl:text> ; </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text> (Rev.): </xsl:text>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionauthor']">
                <xsl:for-each select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionauthor']">
                    <xsl:value-of select="./text()"/>
                    <xsl:choose>
                        <xsl:when test="not(position()=last())">
                            <xsl:text> ; </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioneditor']">
                                    <xsl:text> ; </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>: </xsl:text>        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioneditor']">
                <xsl:for-each select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioneditor']">
                    <xsl:value-of select="./text()"/>
                    <xsl:choose>
                        <xsl:when test="not(position()=last())">
                            <xsl:text> (Ed.) ; </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> (Ed.): </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiontitle']">
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiontitle']/text()"/>
            <xsl:text>. </xsl:text>
        </xsl:if>

        <!-- pub city date -->
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioncity']">
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioncity']/text()"/>
            <xsl:text>: </xsl:text>
        </xsl:if>
        
        <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionpublisher']/text()"/>
        
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiondateissued']">
            <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionpublisher']">
                <xsl:text>, </xsl:text>    
            </xsl:if>
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiondateissued']/text()"/>
        </xsl:if>
        
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensioncity']
            or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensionpublisher']
            or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='recensiondateissued']">
            <xsl:text>. </xsl:text>
        </xsl:if>
        
        
        <!-- ISBN -->
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']">
            <xsl:text>ISBN </xsl:text>
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='identifier' and @qualifier='isbn']"/>
            <xsl:text>. </xsl:text>
        </xsl:if>
        
        

        <!-- In-block -->
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']">
            <xsl:text>In: </xsl:text>
            <fo:inline font-style="italic">
                <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']/text()"/>
            </fo:inline>
            <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
                <xsl:text> </xsl:text>
                <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']/text()"/>
            </xsl:if>
        </xsl:if>
        
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']/text()"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
        
        <xsl:if
            test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='journal']
            or $dimNode/dim:field[@mdschema='dc' and @element='date' and @qualifier='issued']
            or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='volume']">
            <xsl:choose>
                <xsl:when test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']
                    or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>
        
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
            <xsl:value-of select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']/text()"/>            
        </xsl:if>
        
        <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
            <xsl:if test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']">
                <xsl:text>, </xsl:text>
            </xsl:if>
            
            <xsl:call-template name="pageinfo">
                <xsl:with-param name="pageinfo"
                    select="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']/text()"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if
            test="$dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='issue']
            or $dimNode/dim:field[@mdschema='dc' and @element='source' and @qualifier='pageinfo']">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="licenceBlock">
        <xsl:param name="dimNode"/>
        <xsl:variable name="licence">
            <xsl:value-of select="$dimNode/dim:field[@mdschema='internal' and @element='identifier' and @qualifier='licence']/text()"/>
        </xsl:variable>
        
        <xsl:variable name="topPadding">
            <xsl:choose>
                <!-- top padding for CC-licences -->
                <xsl:when test="(number($licence) = 1) or (number($licence) = 2) or 
                    (number($licence) = 8) or (number($licence) = 9) or (number($licence) = 10) or (number($licence) = 11)">
                    <xsl:text>225mm</xsl:text>
                </xsl:when>
                
                <!-- top padding for deposit licence -->
                <xsl:when test="(number($licence) = 3)">
                    <xsl:text>200mm</xsl:text>
                </xsl:when>
                
                <!-- top padding for digital peer licence -->
                <xsl:when test="(number($licence) = 4) or (number($licence) = 5) or (number($licence) = 6)">
                    <xsl:text>225mm</xsl:text>
                </xsl:when>
                
                <!-- top padding for peer project licence -->
                <xsl:when test="(number($licence) = 7)">
                    <xsl:text>200mm</xsl:text>
                </xsl:when>
                
                <!-- default -->
                <xsl:otherwise>
                    <xsl:text>212mm</xsl:text>
                </xsl:otherwise>
                                
            </xsl:choose>
        </xsl:variable>
        
        <fo:block-container position="absolute" width="100%" top="{$topPadding}" font-family="{$font-style}">
            <fo:block>
                <fo:table font-size="8pt">
                    <fo:table-column column-number="1"/>
                    <fo:table-column column-number="2"/>
                    <fo:table-body>
                        <fo:table-row >
                            <xsl:choose>
                                <xsl:when test="number($licence) = 1">
                                    <!-- CC BY -->
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY Lizenz (Namensnennung) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')"
                                                    color="blue" text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY Licence (Attribution). For more Information see: </fo:inline>
                                            <fo:block>
                                                 <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                     text-decoration="underline">
                                                     <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                 </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- CC BY-NC-ND -->
                                <xsl:when test="number($licence) = 2">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY-NC-ND Lizenz (Namensnennung-Nicht-kommerziell-Keine Bearbeitung) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY-NC-ND Licence (Attribution Non Comercial-NoDerivatives). For more Information see: </fo:inline>
                                            <fo:block>
                                                 <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                     text-decoration="underline">
                                                     <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                 </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Deposit -->                               
                                <xsl:when test="number($licence) = 3">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>
                                                Dieser Text wird unter einer Deposit-Lizenz (Keine Weiterverbreitung - keine Bearbeitung) zur Verfügung gestellt. 
                                                Gewährt wird ein nicht exklusives, nicht übertragbares, persönliches und beschränktes Recht auf Nutzung dieses Dokuments. Dieses
                                                Dokument ist ausschließlich für den persönlichen, nicht-kommerziellen Gebrauch bestimmt. Auf sämtlichen Kopien dieses
                                                Dokuments müssen alle Urheberrechtshinweise und sonstigen Hinweise auf gesetzlichen Schutz beibehalten werden. Sie dürfen
                                                dieses Dokument nicht in irgendeiner Weise abändern, noch dürfen Sie dieses Dokument für öffentliche oder kommerzielle Zwecke
                                                vervielfältigen, öffentlich ausstellen, aufführen, vertreiben oder anderweitig nutzen.
                                            </fo:inline>
                                            <fo:block>
                                                Mit der Verwendung dieses Dokuments erkennen Sie die Nutzungsbedingungen an.
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>
                                                This document is made available under Deposit Licence (No Redistribution - no modifications). We grant a non-exclusive, non-transferable, individual and limited right to using this document.
                                                This document is solely intended for your personal, non-commercial use. All of the copies of this documents must retain all copyright information
                                                and other information regarding legal protection. You are not allowed to alter this document in any way, to copy it for public or
                                                commercial purposes, to exhibit the document in public, to perform, distribute or otherwise use the document in public.                                                                                                
                                            </fo:inline>
                                            <fo:block>By using this particular document, you accept the above-stated conditions of use.</fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Basic Digital Peer -->
                                <xsl:when test="number($licence) = 4">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer Basic Digital Peer Publishing-Lizenz zur Verfügung gestellt. Nähere Auskünfte zu den DiPP-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a Basic Digital Peer Publishing Licence. For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Free Digital Peer Publishing Licence -->
                                <xsl:when test="number($licence) = 5">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer Free Digital Peer Publishing Licence zur Verfügung gestellt. Nähere Auskünfte zu den DiPP-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a Free Digital Peer Publishing Licence. For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Modular Digital Peer Publishing Licence -->
                                <xsl:when test="number($licence) = 6">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer Modular Digital Peer Publishing-Lizenz zur Verfügung gestellt. Nähere Auskünfte zu den DiPP-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a Modular Digital Peer Publishing Licence. For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.dipp.nrw.de/lizenzen/dppl/service/dppl/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- PEER Licence Agreement (applicable only to documents from PEER project) -->
                                <xsl:when test="number($licence) = 7">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter dem "PEER Licence Agreement zur Verfügung" gestellt. Nähere Auskünfte zum PEER-Projekt finden Sie hier: 
                                                <fo:basic-link external-destination="url('http://www.peerproject.eu')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://www.peerproject.eu</xsl:text>
                                                </fo:basic-link>
                                                Gewährt wird ein nicht exklusives, nicht übertragbares, persönliches und beschränktes Recht auf Nutzung dieses Dokuments. Dieses
                                                Dokument ist ausschließlich für den persönlichen, nicht-kommerziellen Gebrauch bestimmt. Auf sämtlichen Kopien dieses
                                                Dokuments müssen alle Urheberrechtshinweise und sonstigen Hinweise auf gesetzlichen Schutz beibehalten werden. Sie dürfen
                                                dieses Dokument nicht in irgendeiner Weise abändern, noch dürfen Sie dieses Dokument für öffentliche oder kommerzielle Zwecke
                                                vervielfältigen, öffentlich ausstellen, aufführen, vertreiben oder anderweitig nutzen.                                                
                                            </fo:inline>
                                            <fo:block>
                                                Mit der Verwendung dieses Dokuments erkennen Sie die Nutzungsbedingungen an.                                                
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under the "PEER Licence Agreement ". For more Information regarding the PEER-project see: 
                                                <fo:basic-link external-destination="url('http://www.peerproject.eu')" color="blue" text-decoration="underline">
                                                    <xsl:text>http://www.peerproject.eu</xsl:text>
                                                </fo:basic-link>
                                                This document is solely intended for your personal, non-commercial use.All of the copies of this documents must retain all copyright information
                                                and other information regarding legal protection. You are not allowed to alter this document in any way, to copy it for public or
                                                commercial purposes, to exhibit the document in public, to perform, distribute or otherwise use the document in public.                                                                                                
                                            </fo:inline>
                                            <fo:block>
                                                By using this particular document, you accept the above-stated conditions of use.                                                
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Creative Commons - Attribution-ShareAlike -->
                                <xsl:when test="number($licence) = 8">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY-SA Lizenz (Namensnennung-Weitergabe unter gleichen Bedingungen) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY-SA Licence (Attribution-ShareAlike). For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                
                                <!-- Creative Commons - Attribution-NoDerivs -->
                                <xsl:when test="number($licence) = 9">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY-ND Lizenz (Namensnennung-Keine Bearbeitung) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY-ND Licence (Attribution-NoDerivatives). For more Information see:  </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>                                    
                                </xsl:when>
                                
                                <!-- Creative Commons - Attribution-NonCommercial -->
                                <xsl:when test="number($licence) = 10">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY-NC Lizenz (Namensnennung-Nicht-kommerziell) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY-NC Licence (Attribution-NonCommercial). For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>  
                                </xsl:when>
                                
                                <!-- Creative Commons - Attribution-NonCommercial-ShareAlike -->
                                <xsl:when test="number($licence) = 11">
                                    <fo:table-cell padding-right="3mm" text-align="justify">
                                        <fo:block font-weight="bold">                                    
                                            <xsl:text>Nutzungsbedingungen:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>Dieser Text wird unter einer CC BY-NC-SA Lizenz (Namensnennung-Nicht-kommerziell-Weitergebe unter gleichen Bedingungen) zur Verfügung gestellt. Nähere Auskünfte zu den CC-Lizenzen finden Sie hier: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell padding-left="3mm" text-align="justify">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Terms of use:</xsl:text>
                                        </fo:block>
                                        <fo:block font-style="italic"> 
                                            <fo:inline>This document is made available under a CC BY-NC-SA Licence (Attribution-Attribution-NonCommercial-ShareAlike). For more Information see: </fo:inline>
                                            <fo:block>
                                                <fo:basic-link external-destination="url('http://creativecommons.org/licenses/')" color="blue"
                                                    text-decoration="underline">
                                                    <xsl:text>http://creativecommons.org/licenses/</xsl:text>
                                                </fo:basic-link>
                                            </fo:block>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                            </xsl:choose>
                            
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>            
        </fo:block-container>
         
    </xsl:template>




</xsl:stylesheet>