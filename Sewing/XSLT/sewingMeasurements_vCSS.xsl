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
    <xsl:variable name="filenameMeasurements"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '_', 'sewingMeasurements_v', '.svg')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <!-- Variable to indicate the X value of the gathering's fold-edge diagram -->
    <xsl:variable name="Fx" select="$Ox + 20"/>
    <!-- Variable to indicate the Y value of the gathering's fold-edge diagram -->
    <xsl:variable name="Fy" select="$Oy + 20"/>
    <!-- Variable to indicate the X value of the gathering's head/tail edge portions of the diagram relative to the fold-edge -->
    <xsl:variable name="f2x" select="$Oy + 8"/>
    <!--    <!-\- Variable to indicate the Y value of the sewing station measurement in the diagram relative to the fold-edge -\->
    <xsl:variable name="my" select="5"/>-->

    <!-- Value in mm of the width and height of a paper sheet selected according to the height of the book -->
    <xsl:variable name="maxLength" as="xs:integer">
        <xsl:value-of select="/book/sewing/stations/maxLength"/>
    </xsl:variable>
    <xsl:variable name="pageDims">
        <xsl:choose>
            <xsl:when test="$maxLength le 287">
                <!-- A4 -->
                <xsl:value-of select="'297,210,A4'"/>
            </xsl:when>
            <xsl:when test="$maxLength gt 287 and $maxLength le 410">
                <!-- A3 -->
                <xsl:value-of select="'420,297,A3'"/>
            </xsl:when>
            <xsl:when test="$maxLength gt 410">
                <!-- A2 -->
                <xsl:value-of select="'594,420,A2'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- A0 -->
                <xsl:value-of select="'1189,841,A0'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="heigth" select="tokenize($pageDims, ',')[1]"/>
    <xsl:variable name="width" select="tokenize($pageDims, ',')[2]"/>
    <xsl:variable name="paperSize" select="tokenize($pageDims, ',')[3]"/>
    
    
    <!--<xsl:variable name="pageHeigth" select="if (/book/sewing/stations/maxLength < 297) then "></xsl:variable>
    <xsl:variable name="pageWidth"></xsl:variable>
-->
    <xsl:template match="/">
        <xsl:result-document href="{$filenameMeasurements}" method="xml" indent="yes"
            encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../GitHub/Transformations/Sewing/CSS/style.css"&#32;</xsl:text>
                <xsl:text>type="text/css"</xsl:text>
            </xsl:processing-instruction>
            <xsl:text>&#10;</xsl:text>
            <xsl:comment>
                    <xsl:text>SVG file generated on: </xsl:text>
                    <xsl:value-of select="format-dateTime(current-dateTime(), '[D] [MNn] [Y] at [H]:[m]:[s]')"/>
                    <xsl:text> using </xsl:text>
                    <xsl:value-of select="system-property('xsl:product-name')"/>
                    <xsl:text> version </xsl:text>
                    <xsl:value-of select="system-property('xsl:product-version')"/>
                </xsl:comment>
            <xsl:text>&#10;</xsl:text>
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.1">
                <xsl:attribute name="x">
                    <xsl:value-of select="$Ox"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Oy"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="concat($width,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="concat($heigth,'mm')"/>
                </xsl:attribute>
                <xsl:attribute name="viewBox">
                    <xsl:value-of select="concat($Ox,' ',$Oy,' ', $width,' ',$heigth)"/>
                </xsl:attribute>
                <xsl:attribute name="preserveAspectRatio">
                    <xsl:value-of select="concat('xMinYMin ','meet')"/>
                </xsl:attribute>
                <xsl:text>&#10;</xsl:text>
                <xsl:comment>
                    <xsl:text>To be printed on </xsl:text>
                    <xsl:value-of select="$paperSize"/>
                    <xsl:text> size paper</xsl:text>
                </xsl:comment>
                <xsl:text>&#10;</xsl:text>
                <xsl:element name="title">
                    <xsl:text>Sewing stations of book: </xsl:text>
                    <xsl:value-of select="$shelfmark"/>
                </xsl:element>
                <xsl:text>&#10;</xsl:text>
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy"/>
                    </xsl:attribute>
                     <xsl:apply-templates/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <!-- Main template to match the description of the sewing stations to the SVG output-->
    <xsl:template match="book/sewing/stations">
        <g xmlns="http://www.w3.org/2000/svg">
            <!-- The code looks for each sewing station and draws them according to their position: at first and last stations
                (usually the kettlestitch stations) it also draws the head and tail of the gathering; at each station it draws a portion 
                of the fold of the gathering. -->
            <xsl:for-each select="station">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="firstStation"/>
                    </xsl:when>
                    <xsl:when test="position() = last()">
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="lastStation"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="otherStations"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template name="firstStation">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Fx - $f2x"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Fy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Fx + $f2x"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Fy"/>
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Fy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="./measurement + $Fy"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="measurement"/>
    </xsl:template>

    <xsl:template name="lastStation">
        <xsl:call-template name="otherStations"/>
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="./measurement + $Fy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $Fy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Fx - $f2x"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $Fy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Fx + $f2x"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $Fy"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="otherStations">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Fy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Fx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="./measurement + $Fy"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="measurement"/>
    </xsl:template>

    <xsl:template name="measurement">
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>text_va</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="dx">
                <xsl:value-of select="$Fx + 3"/>
            </xsl:attribute>
            <xsl:attribute name="dy">
                <xsl:value-of select="./measurement + $Fy"/>
            </xsl:attribute>
            <xsl:value-of select="./measurement"/>
        </text>
        <circle xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>dot</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="r">
                <xsl:value-of select="1"/>
            </xsl:attribute>
            <xsl:attribute name="cx">
                <xsl:value-of select="$Fx"/>
            </xsl:attribute>
            <xsl:attribute name="cy">
                <xsl:value-of select="./measurement + $Fy"/>
            </xsl:attribute>
        </circle>
    </xsl:template>

    <!-- This template only adds a <desc></desc> element to the SVG code in order to make explicit which station is
        being generated and its type (unsupported/kettlestitch or supported) -->
    <!-- NB: the code only considers kettlestitches and supported stations for the moment, more information to be 
        gathered here as the drwaing capabilities of the code are being expanded -->
    <xsl:template name="stationDescription">
        <xsl:param name="p_stationN"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Station N.</xsl:text>
            <xsl:value-of select="position()"/>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <!-- NB: for the moment it only distinguishes between kettlestiches and supported stations -->
                <xsl:when test="./type[unsupported/kettleStitch]">kettlestitch</xsl:when>
                <xsl:when test="./type[supported]">supported</xsl:when>
            </xsl:choose>
            <xsl:text>)</xsl:text>
        </desc>
    </xsl:template>

</xsl:stylesheet>
