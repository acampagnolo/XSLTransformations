<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs svg xlink lig xsi" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenamePath"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '_', 'sewingPath', '.svg')"/>
    <xsl:variable name="filenameMeasurements"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '_', 'sewingMeasurements', '.svg')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="xO" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="yO" select="$xO"/>

    <!-- Variable to indicate the X value of the gathering's fold-edge diagram -->
    <xsl:variable name="xG" select="$xO + 20"/>
    <!-- Variable to indicate the Y value of the gathering's fold-edge diagram -->
    <xsl:variable name="yG" select="$yO + ($xG * 2)"/>
    <!-- Variable to indicate the Y value of the gathering's head/tail edge portion of the diagram -->
    <xsl:variable name="yG2" select="$xG"/>
    <!-- Variable to indicate the Y value of the sewing station measurement in the diagram -->
    <xsl:variable name="yM" select="5"/>

    <!-- Value in mm of the width and height of an A4 sheet in landscape position -->
    <xsl:variable name="A4w_l" select="297"/>
    <xsl:variable name="A4h_l" select="210"/>

    <xsl:template match="/">
        <xsl:result-document href="{$filenamePath}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">
                <xsl:attribute name="x">
                    <xsl:value-of select="$xO"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$yO"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="concat($A4w_l,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="concat($A4h_l,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="viewBxO">
                    <xsl:value-of
                        select="concat($xO,' ',$yO,' ', $A4w_l,' ',$A4h_l)"/>
                </xsl:attribute>
                <xsl:attribute name="preserveAspectRatio">
                    <xsl:value-of select="concat('xMinYMin ','meet')"/>
                </xsl:attribute>
                <xsl:element name="desc">
                    <xsl:text>Sewing pattern of book: </xsl:text>
                    <xsl:value-of select="$shelfmark"/>
                </xsl:element>
                <xsl:copy-of select="document('../SVGmaster/sewingSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$xO"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$yO"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </svg>
            </svg>
        </xsl:result-document>
        <xsl:result-document href="{$filenameMeasurements}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">
                <xsl:attribute name="x">
                    <xsl:value-of select="$xO"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$yO"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="concat($A4w_l,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="concat($A4h_l,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="viewBxO">
                    <xsl:value-of
                        select="concat($xO,' ',$yO,' ', $A4w_l,' ',$A4h_l)"/>
                </xsl:attribute>
                <xsl:attribute name="preserveAspectRatio">
                    <xsl:value-of select="concat('xMinYMin ','meet')"/>
                </xsl:attribute>
                <xsl:element name="desc">
                    <xsl:text>Sewing pattern of book: </xsl:text>
                    <xsl:value-of select="$shelfmark"/>
                </xsl:element>
                <xsl:copy-of select="document('../SVGmaster/sewingSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$xO"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$yO"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template match="book/sewing/stations">
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="stroke">
                <xsl:text>#000000</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="stroke-width">
                <xsl:value-of select="1"/>
            </xsl:attribute>
            <xsl:attribute name="fill">
                <xsl:text>none</xsl:text>
            </xsl:attribute>
            <xsl:for-each select="station">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:call-template name="firstStation"/>
                    </xsl:when>
                    <xsl:when test="position() = last()">
                        <xsl:call-template name="lastStation"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="otherStations"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template name="firstStation">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$xO + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG + $yG2"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$xO + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG + $yM"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="lastStation">
        <xsl:call-template name="otherStations"/>
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="./measurement + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG + $yG2"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="otherStations">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="./measurement + $xG"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$yG"/>
            </xsl:attribute>
        </path>
    </xsl:template>

</xsl:stylesheet>
