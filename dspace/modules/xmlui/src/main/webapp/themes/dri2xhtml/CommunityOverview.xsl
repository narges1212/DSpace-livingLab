<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <xsl:variable name="ssoar-path" select="concat($context-path,'/handle/')"/>
    
    <xsl:template name="createCommunityOverview">
        <div class="top-community">            
            <h1>
                <a href="{$ssoar-path}/community/10000/discover" class="top-community">
                    <!-- Sozialwissenschaften -->
                    <i18n:text>xmlui.ssoar.convoc.classoz.10000</i18n:text>
                </a>
            </h1>        
            <table class="sub-communities">
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10100/discover" class="sub-community">
                            <!--Grundlagen, Geschichte, generelle Theorien und Methoden der Sozialwissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10100</i18n:text>                        
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10200/discover" class="sub-community">
                            <!-- Soziologie -->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10200</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10300/discover" class="sub-community">
                            <!--Demographie, Bevölkerungswissenschaft-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10300</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/10400/discover" class="sub-community">
                            <!--Ethnologie-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10400</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10500/discover" class="sub-community">
                            <!--Politikwissenschaft-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10500</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10600/discover" class="sub-community">
                            <!--Erziehungswissenschaft-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10600</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10700/discover" class="sub-community">
                            <!--Psychologie-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10700</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">							
                        <a href="{$ssoar-path}community/10800/discover" class="sub-community">
                            <!--Kommunikationswissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10800</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/10900/discover" class="sub-community">
                            <!--Wirtschaftswissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.10900</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/11000/discover" class="sub-community">
                            <!--Sozialpolitik-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.11000</i18n:text> 
                        </a>				
                    </td>
                </tr>	
            </table>
        </div>
        
        <div class="top-community">
            <h1>
                <a href="{$ssoar-path}community/20000/discover" class="top-community">
                    <!--Interdisziplinäre und angewandte Gebiete der Sozialwissenschaften-->
                    <i18n:text>xmlui.ssoar.convoc.classoz.20000</i18n:text> 
                </a>
            </h1>
        
            <table class="sub-communities">
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/20100/discover" class="sub-community">
                            <!--Arbeitsmarkt- und Berufsforschung-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20100</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20200/discover" class="sub-community">
                            <!--Frauen- und Geschlechterforschung-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20200</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20300/discover" class="sub-community">
                            <!--Gerontologie-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20300</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20400/discover" class="sub-community">
                            <!--Freizeitforschung-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20400</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20500/discover" class="sub-community">
                            <!--soziale Probleme-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20500</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/20600/discover" class="sub-community">
                            <!--Sozialarbeit und Sozialpädagogik-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20600</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20700/discover" class="sub-community">
                            <!--Raumplanung und Regionalforschung-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20700</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">							
                        <a href="{$ssoar-path}collection/20800/discover" class="sub-community">
                            <!--Technikfolgeabschätzung-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20800</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/20900/discover" class="sub-community">
                            <!--Ökologie und Umwelt-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.20900</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/29900/discover" class="sub-community">
                            <!--sonstige Bereiche der angewandten Sozialwissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.29900</i18n:text> 
                        </a>				
                    </td>
                </tr>	
            </table>
        </div>
        
        <div class="top-community">
            <h1>
                <a href="{$ssoar-path}community/30000/discover" class="top-community">
                    <!--Geisteswissenschaften-->
                    <i18n:text>xmlui.ssoar.convoc.classoz.30000</i18n:text> 
                </a>
            </h1>        
            <table class="sub-communities">
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/30100/discover" class="sub-community">
                            <!--Philosophie, Theologie-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.30100</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/30200/discover" class="sub-community">
                            <!--Literaturwissenschaft, Sprachwissenschaft, Linguistik-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.30200</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/30300/discover" class="sub-community">
                            <!--Geschichte (historische Sozialforschung, Sozialgeschichte)-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.30300</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/39900/discover" class="sub-community">
                            <!--sonstige Geisteswissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.39900</i18n:text> 
                        </a>				
                    </td>
                </tr>
                
            </table>
        </div>
        
        <div class="top-community">
            <h1>
                <a href="{$ssoar-path}community/40000/discover" class="top-community">
                    <!--Rechts-, Verwaltungs-, Naturwissenschaften, Technik, Medizin-->
                    <i18n:text>xmlui.ssoar.convoc.classoz.4and5</i18n:text> 
                </a>
            </h1>        
            <table class="sub-communities">
                <tr>		
                    <td class="sub-community">				
                        <a href="{$ssoar-path}community/40100/discover" class="sub-community">
                            <!--Rechtswissenschaft-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.40100</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/40200/discover" class="sub-community">
                            <!--Verwaltungswissenschaft-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.40200</i18n:text> 
                        </a>				
                    </td>
                </tr>
                <tr>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/50100/discover" class="sub-community">
                            <!--Medizin, Sozialmedizin-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.50100</i18n:text> 
                        </a>				
                    </td>
                    <td class="sub-community">				
                        <a href="{$ssoar-path}collection/50200/discover" class="sub-community">
                            <!--Naturwissenschaften, Technik(wissenschaften), angewandte Wissenschaften-->
                            <i18n:text>xmlui.ssoar.convoc.classoz.50200</i18n:text> 
                        </a>				
                    </td>
                </tr>                
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>