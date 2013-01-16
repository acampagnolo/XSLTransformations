<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dict="www.mydict.my"
    xmlns:math="http://exslt.org/math" exclude-result-prefixes="xs svg xlink lig dict math"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:for-each-group select="book/sewing/stations/station" group-by="name(group/child::node()[2])">
            <xsl:for-each select="current-group()">
                <xsl:sort select="measurement" data-type="number" order="ascending"/>
                <!--<xsl:value-of select="measurement"/>
            <xsl:text>;</xsl:text>-->
                <xsl:element name="stations">
                    <xsl:copy-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </xsl:for-each-group>
    </xsl:template>
    
</xsl:stylesheet>