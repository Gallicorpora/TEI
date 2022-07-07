<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:alto="http://www.loc.gov/standards/alto/ns-v4#" xmlns="http://www.loc.gov/standards/alto/ns-v4#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="xs tei alto"
    version="2.0">
    
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>  
    <!-- Rule to parse XML TEI from root and create for each element surface an XMl ALTO 4 file -->
    <xsl:template match="TEI">        
        <xsl:for-each select="descendant::surface">
       <xsl:variable name="nomFichierSource" select="tokenize(replace(base-uri(), '.xml', ''), '/')[last()]"/>
       <xsl:result-document href="{concat('teiToalto/', $nomFichierSource, ./@xml:id, '.xml')}">
        <alto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://www.loc.gov/standards/alto/ns-v4#"
            xsi:schemaLocation="http://www.loc.gov/standards/alto/ns-v4# http://www.loc.gov/standards/alto/v4/alto-4-2.xsd">
            <Description>
                <MeasurementUnit>pixel</MeasurementUnit>
                <sourceImageInformation>
                    <fileName><xsl:value-of select="concat(./@xml:id, '.jpg')"/></fileName>
                    </sourceImageInformation>
            </Description>
            <xsl:call-template name="tags"/>
            <Layout>
                <Page WIDTH="{@lrx}"
                    HEIGHT="{@lry}"
                    PHYSICAL_IMG_NR="1"
                    ID="eSc_dummypage_">
                    <PrintSpace HPOS="0"
                        VPOS="0"
                        WIDTH="{@lrx}" 
                        HEIGHT="{@lry}">
                        <!-- injection of coordinates from element surface -->
            <xsl:apply-templates select="./zone"/>
                    </PrintSpace>
                </Page>
            </Layout>
        </alto>
       </xsl:result-document>
        </xsl:for-each> 
    </xsl:template>  
    <!-- creation of the element tags with zone labels -->
    <xsl:template name="tags">
        <Tags>
            <!-- tags for zone group by label -->
            <xsl:for-each-group select="./zone" group-by="@type">
                <xsl:variable name="count" select="count(preceding-sibling::zone)+1"/>
                <OtherTag ID="BT{current-grouping-key()}" LABEL="{current-grouping-key()}" DESCRIPTION="block type {current-grouping-key()}"/>
            </xsl:for-each-group>
            <!-- tags for line group by label -->
            <xsl:for-each-group select="descendant::line/parent::zone" group-by="@type">
                <xsl:variable name="count" select="count(preceding-sibling::zone)+1"/>
                <OtherTag ID="LT{$count}" LABEL="{current-grouping-key()}" DESCRIPTION="line type {current-grouping-key()}"/>
            </xsl:for-each-group>      
        </Tags>
    </xsl:template>
    <!-- creation of the element blocks -->
   <xsl:template match="zone">
       <xsl:variable name="count" select="count(preceding-sibling::zone)"></xsl:variable>
       <!-- extraction of coordinates from iiif url in @source -->
       <xsl:variable name="extractionCoordFrom_att_Source">
           <xsl:value-of select="tokenize(replace(@source,'/full/0/native.jpg', ''), '/')[last()]"/>
       </xsl:variable>
       <xsl:variable name="HPOS">
           <xsl:value-of select="tokenize($extractionCoordFrom_att_Source, ',')[position()=1]"/>
       </xsl:variable>
       <xsl:variable name="VPOS">
           <xsl:value-of select="tokenize($extractionCoordFrom_att_Source, ',')[position()=2]"/>
       </xsl:variable>
       <xsl:variable name="width">
           <xsl:value-of select="tokenize($extractionCoordFrom_att_Source, ',')[position()=3]"/>
       </xsl:variable>
       <xsl:variable name="height">
           <xsl:value-of select="tokenize($extractionCoordFrom_att_Source, ',')[last()]"/>
       </xsl:variable>    
       <xsl:choose> 
           <xsl:when test="parent::surface"> <!-- creation of text block based on xml arborescence 
               - blocks are allways direct children of surface element -->
               <TextBlock HPOS="{$HPOS}"
                   VPOS="{$VPOS}"
                   WIDTH="{$width}"
                   HEIGHT="{$height}" 
                   ID="eSc_textblock_{$count}"
                   TAGREFS="BT{@type}">
                   <Shape><Polygon POINTS="{replace(@points, ',', ' ')}"/></Shape>
                   <xsl:apply-templates select="zone" />
               </TextBlock>
           </xsl:when>
           <xsl:otherwise> <!-- creation of textLine -->
               <TextLine ID="line_{$count}"
                   TAGREFS="LT{$count}"
                   BASELINE="{path/@points}" 
                   HPOS="{$HPOS}"
                   VPOS="{$VPOS}"
                   WIDTH="{$width}"
                   HEIGHT="{$height}">
                   <Shape><Polygon POINTS="{@points}"/></Shape>
                   <!--extraction of the text -->
                   <String CONTENT="{line/text()}"
                       HPOS="{$HPOS}"
                       VPOS="{$VPOS}"
                       WIDTH="1920"
                       HEIGHT="195"></String>
               </TextLine>
           </xsl:otherwise>
       </xsl:choose>    
   </xsl:template> 

</xsl:stylesheet>