<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs svg xlink lig xsi" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>
    <xsl:variable name="filenameMeasurements"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'sewingMeasurements_v', '.svg')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <!-- Variable to indicate the X value of the gathering's fold-edge diagram -->
    <xsl:variable name="Fx" select="$Ox + 50"/>
    <!-- Variable to indicate the Y value of the gathering's fold-edge diagram -->
    <xsl:variable name="Fy" select="$Oy + 50"/>
    <!-- Variable to indicate the X value of the gathering's head/tail edge portions of the diagram relative to the fold-edge -->
    <xsl:variable name="f2x" select="$Oy + 8"/>
    
    <!-- Variables of point of origin for full spine view -->
    <xsl:variable name="Sx" select="$Ox + 100"/>
    <xsl:variable name="Sy" select="$Fy"/>
    
    <xsl:variable name="bookThicknessDatatypeChecker">
        <!-- Some surveyors have types 'same' instead of giving the value in mm: 
            check for the numeric value in /book/dimensions/thickness/max instead-->
        <xsl:choose>
            <xsl:when test="/book/dimensions/thickness/min castable as xs:integer">
                <xsl:value-of select="/book/dimensions/thickness/min"/>
            </xsl:when>
            <xsl:when
                test="/book/dimensions/thickness/min castable as xs:string or /book/dimensions/thickness/min eq ' '">
                <xsl:choose>
                    <xsl:when test="/book/dimensions/thickness/max castable as xs:integer">
                        <xsl:value-of select="/book/dimensions/thickness/max"/>
                    </xsl:when>
                    <xsl:when
                        test="/book/dimensions/thickness/max castable as xs:string or /book/dimensions/thickness/max eq ' '">
                        <!-- NB: in this case the measurement should be indicated as estimated for the sole purpose 
                            of the XSLT to be able to draw the diagram with the rest of the data available -->
                        <!-- How to pass on the information that the measurement has been guessed?? -->
                        <xsl:value-of select="50"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="leftBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/location/left">
                <!-- To avoid problems with erroneous inputs (e.g. two left boards), only the first board with a location/left child is considered -->
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/left][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards/yes/boards/board/location[not(left)]">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/right][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards[no | NK | NC]">
                <xsl:value-of select="xs:double($bookThicknessDatatypeChecker *.07)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="rightBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/location/right">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/right][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards/yes/boards/board/location[not(right)]">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/left][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards[no | NK | NC]">
                <xsl:value-of select="xs:double($bookThicknessDatatypeChecker *.07)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="bookblockThickness">
        <!-- Some surveyors have types 'same' instead of giving the value in mm: 
            check for the numeric value in /book/dimensions/thickness/max instead-->
        <xsl:choose>
            <xsl:when test="/book/dimensions/thickness/min castable as xs:integer">
                <xsl:value-of
                    select="/book/dimensions/thickness/min - (if (/book/board[not(no | NK | NC)]) then  xs:double($leftBoardThickness) - xs:double($rightBoardThickness) else 0)"
                />
            </xsl:when>
            <xsl:when test="xs:string(/book/dimensions/thickness/min)">
                <xsl:value-of
                    select="xs:integer(/book/dimensions/thickness/max) - (if (/book/board[not(no | NK | NC)]) then  xs:double($leftBoardThickness) - xs:double($rightBoardThickness) else 0)"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:result-document href="{$filenameMeasurements}" method="xml" indent="yes"
            encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../../GitHub/XSLTransformations/Sewing/CSS/style.css"&#32;</xsl:text>
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
            <!-- Printed on A0 -->
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.1" x="0" y="0" width="1189mm" height="841mm" viewBox="0 0 1189 841"
                preserveAspectRatio="xMidYMid meet">
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy"/>
                    </xsl:attribute>
                    <xsl:call-template name="title"/>
                     <xsl:apply-templates/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <!-- Main template to match the description of the sewing stations to the SVG output-->
    <xsl:template match="book/sewing/stations">
        <xsl:call-template name="fullSpine"/>
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
                <xsl:choose>
                    <xsl:when test="./group[current]">
                        <xsl:text>text_va</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[previous]">
                        <xsl:text>text_va_previous</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[earlier]">
                        <xsl:text>text_va_earlier</xsl:text>
                    </xsl:when>
                </xsl:choose>
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
                <xsl:choose>
                    <xsl:when test="./group[current]">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:when test="./group[previous]">
                        <xsl:value-of select="0.5"/>
                    </xsl:when>
                    <xsl:when test="./group[earlier]">
                        <xsl:value-of select="0.3"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="cx">
                <xsl:value-of select="$Fx"/>
            </xsl:attribute>
            <xsl:attribute name="cy">
                <xsl:value-of select="./measurement + $Fy"/>
            </xsl:attribute>
        </circle>
    </xsl:template>
    
    <xsl:template name="fullSpine">
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Sx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Sy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Sx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="maxLength + $Sy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Sx + $bookblockThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="maxLength + $Sy"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Sx + $bookblockThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Sy"/>
                <xsl:text>z</xsl:text>
            </xsl:attribute>
        </path>
        <xsl:for-each select="station">
            <xsl:call-template name="fullSpine_measurement"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="fullSpine_measurement">
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="./group[current]">
                        <xsl:text>text_va</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[previous]">
                        <xsl:text>text_va_previous</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[earlier]">
                        <xsl:text>text_va_earlier</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="dx">
                <xsl:value-of select="$Sx + $bookblockThickness + 3"/>
            </xsl:attribute>
            <xsl:attribute name="dy">
                <xsl:value-of select="./measurement + $Sy"/>
            </xsl:attribute>            
            <xsl:value-of select="./measurement"/>
            <!--<xsl:value-of select="concat(./measurement, ' mm')"/>-->
        </text>
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="./group[current]">
                        <xsl:text>line2</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[previous]">
                        <xsl:text>line4</xsl:text>
                    </xsl:when>
                    <xsl:when test="./group[earlier]">
                        <xsl:text>line3</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute> 
            <xsl:attribute name="d">
                <xsl:text>M&#32;</xsl:text>
                <xsl:value-of select="$Sx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Sy + measurement"/>
                <xsl:text>&#32;L&#32;</xsl:text>
                <xsl:value-of select="$Sx + $bookblockThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Sy + measurement"/>
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
    
    <!-- Titling -->
    <xsl:template name="title">
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + $Fx + ($Sx - $Fx)"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + ($Fy div 2)"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>            
            <xsl:text>sewing</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>noteText5</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + $Fx + ($Sx - $Fx)"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + ($Fy div 1.5)"/>
            </xsl:attribute>        
            <xsl:text>(measurements in mm)</xsl:text>
        </text>
    </xsl:template>

</xsl:stylesheet>
