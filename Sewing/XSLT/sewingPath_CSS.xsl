<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs svg xlink lig xsi" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>
    
    <!--<xsl:include href="sewingMeasurements_vCSS.xsl"/>-->

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenamePath"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '_', 'sewingPath', '.svg')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <!-- Variable to indicate the X value of the gathering's fold-edge diagram -->
    <xsl:variable name="Gx" select="$Ox + 20"/>
    <!-- Variable to indicate the Y value of the gathering's fold-edge diagram -->
    <xsl:variable name="Gy" select="$Oy + ($Gx * 2)"/>
    <!-- Variable to indicate the Y value of the gathering's head/tail edge portion of the diagram relative to the fold-edge -->
    <xsl:variable name="g2y" select="$Gx"/>
    <!-- Variable to indicate the Y value of the sewing station measurement in the diagram relative to the fold-edge -->
    <xsl:variable name="ym" select="5"/>

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
    <xsl:variable name="heigth" select="tokenize($pageDims, ',')[2]"/>
    <xsl:variable name="width" select="tokenize($pageDims, ',')[1]"/>
    <xsl:variable name="paperSize" select="tokenize($pageDims, ',')[3]"/>

    <xsl:template match="/">
        <xsl:result-document href="{$filenamePath}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
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
                    <xsl:value-of
                        select="concat($Ox,' ',$Oy,' ', $width,' ',$heigth)"/>
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
                    <xsl:text>Sewing pattern of book: </xsl:text>
                    <xsl:value-of select="$shelfmark"/>
                </xsl:element>
                <!-- The following copies the definitions from the Master SVG file for sewing paths -->
                <xsl:copy-of select="document('../SVGmaster/sewingSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
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
            <!-- The code looks for each sewing station and draws them according to their position: first and last stations
                (usually the kettlestitch stations) also draw the head and tail of the gathering and the entrance and exit of the
                thread; the other stations draw the sewing supports, the sewing loops and the fold of the gathering. -->
            <xsl:for-each select="station">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="firstStation"/>
                        <xsl:call-template name="sewingIn"/>
                    </xsl:when>
                    <xsl:when test="position() = last()">
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="lastStation"/>
                        <xsl:call-template name="sewingOut"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="stationDescription">
                            <xsl:with-param name="p_stationN">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="otherStations"/>
                        <xsl:if test="position() != last() - 1">
                            <xsl:call-template name="sewingArc"/>
                        </xsl:if>
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
                <xsl:value-of select="$Ox + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + $g2y"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Ox + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="sewingLoop"/>
    </xsl:template>

    <xsl:template name="lastStation">
        <xsl:call-template name="otherStations"/>
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::maxLength[1] + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + $g2y"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="sewingLoop"/>
    </xsl:template>

    <xsl:template name="otherStations">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="sewingLoop"/>
    </xsl:template>

    <!-- While the sewingLoop template (i.e. the template to draw the sewing support and the thread loop around it)
    is called for each station, the template checks whether the station is supported, and thus in need of the drawing
    or is instead an unsupported kettlestitch, in which case no sewing support is generated -->
    <xsl:template name="sewingLoop">
        <xsl:if test="./type[not (unsupported/kettleStitch)]">
            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupport-Loop">
                <xsl:attribute name="x">
                    <xsl:value-of select="(./measurement + $Gx) - 10"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$g2y - 1"/>
                </xsl:attribute>
            </use>
        </xsl:if>
    </xsl:template>

    <!-- Template to draw the entrance path of the thread -->
    <xsl:template name="sewingIn">
        <path xmlns="http://www.w3.org/2000/svg" marker-start="url(#arrowSymbol)" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy - 3"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy - 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 13"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the sewing arc between stations (not first or last stations) -->
    <xsl:template name="sewingArc">
        <path xmlns="http://www.w3.org/2000/svg"
            marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="./measurement + (2 * $Gx) + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the exit path of the thread -->
    <xsl:template name="sewingOut">
        <path xmlns="http://www.w3.org/2000/svg"
            marker-start="url(#arrowSymbol)" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 13"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 3"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy + 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy"/>
                <xsl:text>&#32;Q&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy - 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Gy - 3"/>
            </xsl:attribute>
        </path>
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
