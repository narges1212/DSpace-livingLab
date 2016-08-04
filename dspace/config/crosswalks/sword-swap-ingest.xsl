<?xml version="1.0" encoding="utf-8"?>
<!-- sord-swap-ingest.xsl
 * 
 * Copyright (c) 2007, Aberystwyth University
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  - Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 *  - Neither the name of the Centre for Advanced Software and
 *    Intelligent Systems (CASIS) nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 -->

<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:epdcx="http://purl.org/eprint/epdcx/2006-11-16/"
        version="1.0">

<!-- NOTE: This stylesheet is a work in progress, and does not
     cover all aspects of the SWAP and EPDCX specification/schema.
     It is used principally to demonstrate the SWORD ingest
     process -->

<!-- This stylesheet converts incoming DC metadata in a SWAP
     profile into the DSpace Interal Metadata format (DIM) -->

	<!-- Catch all.  This template will ensure that nothing
	     other than explicitly what we want to xwalk will be dealt
	     with -->
	<xsl:template match="text()"></xsl:template>
    
    <!-- match the top level descriptionSet element and kick off the
         template matching process -->
    <xsl:template match="/epdcx:descriptionSet">
    	<dim:dim>
    		<xsl:apply-templates/>
    	</dim:dim>
    </xsl:template>
    
    <!-- general matcher for all "statement" elements -->
    <xsl:template match="/epdcx:descriptionSet/epdcx:description/epdcx:statement">
    
    	<!-- title element: dc.title -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/elements/1.1/title'">
    		<dim:field mdschema="dc" element="title">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>
    	
    	<!-- abstract element: dc.description.abstract -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/terms/abstract'">
    		<dim:field mdschema="dc" element="description" qualifier="abstract">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>
    	
    	<!-- creator element: dc.contributor.author -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/elements/1.1/creator'">
    		<dim:field mdschema="dc" element="contributor" qualifier="author">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>
    	
    	<!-- identifier element: dc.identifier.* -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/elements/1.1/identifier'">
    		<xsl:element name="dim:field">
    			<xsl:attribute name="mdschema">dc</xsl:attribute>
    			<xsl:attribute name="element">identifier</xsl:attribute>
    			<xsl:if test="epdcx:valueString[@epdcx:sesURI='http://purl.org/dc/terms/URI']">
    				<xsl:attribute name="qualifier">uri</xsl:attribute>
    			</xsl:if>
    			<xsl:value-of select="epdcx:valueString"/>
    		</xsl:element>
    	</xsl:if>
    	
    	<!-- language element: dc.language.iso -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/elements/1.1/language' and ./@epdcx:vesURI='http://purl.org/dc/terms/RFC3066'">
    		<!--<dim:field mdschema="dc" element="language" qualifier="rfc3066">-->
    		<dim:field mdschema="dc" element="language">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>
    	
    	<!-- item type element: dc.type -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/elements/1.1/type' and ./@epdcx:vesURI='http://purl.org/eprint/terms/Type'">
    		<xsl:if test="./@epdcx:valueURI='http://purl.org/eprint/type/JournalArticle'">
    			<dim:field mdschema="dc" element="type">
    				Journal Article
    			</dim:field>
    		</xsl:if>
    	</xsl:if>
    	
    	<!-- date available element: dc.date.issued -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/dc/terms/available'">
    		<dim:field mdschema="dc" element="date" qualifier="issued">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>
    	
    	<!-- publication status element: dc.description.version -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/eprint/terms/status' and ./@epdcx:vesURI='http://purl.org/eprint/terms/Status'">
    		<xsl:if test="./@epdcx:valueURI='http://purl.org/eprint/status/PeerReviewed'">
	    		<dim:field mdschema="dc" element="description" qualifier="version">
	    			Peer Reviewed
	    		</dim:field>
    		</xsl:if>
    	</xsl:if>
    	
    	<!-- copyright holder element: dc.rights.holder -->
    	<xsl:if test="./@epdcx:propertyURI='http://purl.org/eprint/terms/copyrightHolder'">
    		<dim:field mdschema="dc" element="rights" qualifier="holder">
    			<xsl:value-of select="epdcx:valueString"/>
    		</dim:field>
    	</xsl:if>

        <!-- bibliographic citation element: dc.identifier.citation -->
        <xsl:if test="./@epdcx:propertyURI='http://purl.org/eprint/terms/bibliographicCitation'">
            <dim:field mdschema="dc" element="identifier" qualifier="citation">
                <xsl:value-of select="epdcx:valueString"/>
            </dim:field>
        	
        	<!-- create fields out of the citation field -->
        	<xsl:if test="contains(epdcx:valueString, 'article{')">
        		<xsl:call-template name="bibtex">
        			<xsl:with-param name="content" select="epdcx:valueString"/>
        		</xsl:call-template>        
        	</xsl:if>
        </xsl:if>
    	
    </xsl:template>
<xsl:template name="bibtex">
		<xsl:param name="content"/>
		
		<!-- dc.contributor.author -->
		<xsl:call-template name="dimvalue">
			<xsl:with-param name="element">contributor</xsl:with-param>
			<xsl:with-param name="qualifier">author</xsl:with-param>
			<xsl:with-param name="language"/>
			<xsl:with-param name="content">
				<xsl:value-of select="substring-after(substring-before(substring-after($content, 'author'), '}'), '{')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- dc.date.issued -->
		<xsl:call-template name="dimvalue">
			<xsl:with-param name="element">date</xsl:with-param>
			<xsl:with-param name="qualifier">issued</xsl:with-param>
			<xsl:with-param name="language"/>
			<xsl:with-param name="content">
				<xsl:value-of select="substring-after(substring-before(substring-after($content, 'year'), '}'), '{')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- dc.source.journal -->
		<xsl:call-template name="dimvalue">
			<xsl:with-param name="element">source</xsl:with-param>
			<xsl:with-param name="qualifier">journal</xsl:with-param>
			<xsl:with-param name="language"/>
			<xsl:with-param name="content">
				<xsl:value-of select="substring-after(substring-before(substring-after($content, 'journal'), '}'), '{')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- dc.identifier.issn -->
		<xsl:call-template name="dimvalue">
			<xsl:with-param name="element">identifier</xsl:with-param>
			<xsl:with-param name="qualifier">issn</xsl:with-param>
			<xsl:with-param name="language"/>
			<xsl:with-param name="content">
				<xsl:value-of select="substring-after(substring-before(substring-after($content, 'issn'), '}'), '{')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- dc.identifier.url -->
		<xsl:call-template name="dimvalue">
			<xsl:with-param name="element">identifier</xsl:with-param>
			<xsl:with-param name="qualifier">url</xsl:with-param>
			<xsl:with-param name="language"/>
			<xsl:with-param name="content">
				<xsl:value-of select="substring-after(substring-before(substring-after($content, 'url'), '}'), '{')"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="dimvalue">		
		<xsl:param name="element"/>
		<xsl:param name="qualifier"/>
		<xsl:param name="langugage"/>
		<xsl:param name="content"/>
		
		<xsl:variable name="entry">
			<xsl:choose>
				<xsl:when test="contains($content, ';')">
					<xsl:value-of select="substring-before($content, ';')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="dim:field">
			<xsl:attribute name="mdschema">dc</xsl:attribute>
			<xsl:attribute name="element">
				<xsl:value-of select="$element"/>
			</xsl:attribute>
			<xsl:if test="$qualifier != ''">
				<xsl:attribute name="qualifier">
					<xsl:value-of select="$qualifier"/>
				</xsl:attribute>    
			</xsl:if>
			
			<xsl:if test="$langugage != ''">
				<xsl:attribute name="language">
					<xsl:value-of select="$langugage"/>
				</xsl:attribute>    
			</xsl:if>
			
			<xsl:value-of select="$entry"/>
		</xsl:element>
		
		<xsl:if test="contains($content, ';')">
			<xsl:call-template name="dimvalue">
				<xsl:with-param name="element" select="$element"/>
				<xsl:with-param name="qualifier" select="$qualifier"/>
				<xsl:with-param name="langugage" select="$langugage"/>
				<xsl:with-param name="content" select="substring-after($content, ';')"/>
			</xsl:call-template>
		</xsl:if>        
	</xsl:template>
    
</xsl:stylesheet>