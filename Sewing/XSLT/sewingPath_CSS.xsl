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

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <!-- Variable to indicate the X value of the gathering's fold-edge diagram -->
    <xsl:variable name="Gx" select="$Ox + 20"/>
    <!-- Variable to indicate the Y value of the gathering's fold-edge diagram -->
    <xsl:variable name="Gy" select="$Oy - 20"/>
    <!-- Variable to indicate the Y value of the gathering's head/tail edge portion of the diagram relative to the fold-edge -->
    <xsl:variable name="g2y" select="20"/>
    <!-- Variable to indicate the Y value of the sewing station measurement in the diagram relative to the fold-edge -->
    <xsl:variable name="ym" select="5"/>

    <!-- Variable to indicate the hight of the sections in front view -->
    <xsl:variable name="sH" select="6"/>
    <!-- Variable to indicate the number of sections to be drawn frontally for the spine view -->
    <xsl:variable name="sN" select="4" as="xs:integer"/>

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

    <xsl:template match="book/sewing">
        <xsl:call-template name="sewingType"/>
    </xsl:template>

    <xsl:template name="sewingType">
        <xsl:choose>
            <xsl:when test="type[allAlong]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Sewing type: all-along</xsl:text>
                </desc>
                <xsl:call-template name="sewingStations"/>
            </xsl:when>
            <xsl:when test="type[multipleSectionSewing]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Sewing type: multiple gathering sewing</xsl:text>
                </desc>
                <xsl:call-template name="sewingStations">
                    <!-- Since the schema does not describe this sewing in details, the diagram draws an allAlong sewing type with a high degree of uncertainty -->
                    <xsl:with-param name="certainty" select="40" as="xs:integer"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type[bypass]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Sewing type: bypass sewing</xsl:text>
                </desc>
                <xsl:call-template name="sewingStations">
                    <!-- Since the schema does not describe this sewing in details, the diagram draws an allAlong sewing type with a high degree of uncertainty -->
                    <xsl:with-param name="certainty" select="40" as="xs:integer"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type[NC | NK]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Sewing type: not checked or not known. High uncertainty value.</xsl:text>
                </desc>
                <xsl:call-template name="sewingStations">
                    <!-- What is the option with the highest probability? And what is its value?  -->
                    <!-- NB: We are assuming here that the most probable option is the allAlong sewing type, and we have assigned it a probability value of 40% -->
                    <xsl:with-param name="certainty" select="40" as="xs:integer"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Sewing type: other</xsl:text>
                </desc>
                <!-- do something -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewingStations">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:variable name="maxLength" select="stations/maxLength[1]"/>
        <!-- The template groups the stations according to the content of the element <group>: current, previous, earlier, NC, NK -->
        <xsl:for-each-group select="stations/station" group-by="name(group/child::node()[2])">
            <xsl:variable name="groupNumber" select="position()"/>
            <xsl:variable name="groupingKey" select="current-grouping-key()"/>
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>Sewing sequence: </xsl:text>
                <xsl:value-of select="$groupingKey"/>
            </desc>
            <xsl:variable name="stationsGrouped">
                <xsl:sequence select="current-group()"/>
            </xsl:variable>
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <!-- The code looks for each sewing station and draws them according to their position: first and last stations
                (usually the kettlestitch stations) also draw the head and tail of the gathering and the entrance and exit of the
                thread; the other stations draw the sewing supports, the sewing loops and the fold of the gathering. -->
                <!-- NB: the code checks and draws a diagram for each station in the current group. 
                In the case of NC and NK, a certainty value should be generated. At the moment this is not done and all options have the default value of 100% -->
                <xsl:for-each select="$stationsGrouped/station">
                    <!-- Variable to calculate the number of the corrent station -->
                    <xsl:variable name="stationNumber" select="position()"/>
                    <!-- Variable to offset each sewing sequence according to its group number -->
                    <xsl:variable name="GyDisplacement" as="xs:integer">
                        <xsl:value-of select="70 * $groupNumber"/>
                    </xsl:variable>
                    <!-- Variable to calculate the Y value to draw each sewing sequence - i.e. current, previous, earlier, NC, NK -->
                    <xsl:variable name="GyValue" select="$Gy + $GyDisplacement"/>
                    <xsl:variable name="GyValue_frontBaseline" select="($Gy - 18) + $GyDisplacement"/>
                    <xsl:call-template name="stationDescription">
                        <xsl:with-param name="p_stationN">
                            <xsl:value-of select="$stationNumber"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="type/unsupported/twoNeedle and position() mod 2 != 0">
                            <xsl:call-template name="innerSewing_front">
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                                <xsl:with-param name="certainty" select="100"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="innerSewing_front">
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                                <xsl:with-param name="certainty" select="100"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$stationNumber = 1">
                            <xsl:call-template name="firstStation">
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                            </xsl:call-template>
                            <xsl:call-template name="firstStation_front">
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                            <xsl:call-template name="sewingIn">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                            </xsl:call-template>
                            <xsl:call-template name="stationType">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$stationNumber = last()">
                            <xsl:call-template name="lastStation">
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                                <xsl:with-param name="maxLength" select="$maxLength"/>
                            </xsl:call-template>
                            <xsl:call-template name="lastStation_front">
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                            <xsl:call-template name="sewingOut">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                            </xsl:call-template>
                            <xsl:call-template name="stationType">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="otherStations">
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                            </xsl:call-template>
                            <xsl:call-template name="otherStations_front">
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                            <xsl:call-template name="stationType">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="GyValue" select="$GyValue"/>
                                <xsl:with-param name="GyValue_frontBaseline"
                                    select="$GyValue_frontBaseline"/>
                            </xsl:call-template>
                            <xsl:if test="$stationNumber != last() - 1">
                                <xsl:call-template name="sewingArc">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="GyValue" select="$GyValue"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </g>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="firstStation">
        <xsl:param name="GyValue" select="$Gy"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + $g2y"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="stationPreparation">
            <xsl:with-param name="GyValue" select="$GyValue"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template to draw the pattern for 4 sections in front view. -->
    <!-- N.B. it calls a recursive pattern to draw the pattern for an arbitrary number of 4 sections -->
    <xsl:template name="firstStation_front">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <desc xmlns="http://www.w3.org/2000/svg">Front view</desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:call-template name="firstStation_frontRecursive">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"
                        as="xs:integer"/>
                    <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                    <xsl:with-param name="counter" select="1"/>
                </xsl:call-template>
            </xsl:attribute>
        </path>
        <xsl:call-template name="stationPreparation_front">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template to draw the same pattern for 4 sections -->
    <xsl:template name="firstStation_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:text>&#32;M</xsl:text>
        <xsl:value-of select="./measurement + $Gx - 7"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:text>&#32;L</xsl:text>
        <xsl:value-of select="$Ox + $Gx"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:text>&#32;L</xsl:text>
        <xsl:value-of select="$Ox + $Gx"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="firstStation_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="sH" select="$sH"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="lastStation">
        <xsl:param name="maxLength"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:call-template name="otherStations">
            <xsl:with-param name="GyValue" select="$GyValue"/>
        </xsl:call-template>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$maxLength + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$maxLength + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + $g2y"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the pattern for 4 sections in front view. -->
    <!-- N.B. it calls a recursive pattern to draw the pattern for an arbitrary number of 4 sections -->
    <xsl:template name="lastStation_front">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:call-template name="otherStations_front">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"
                as="xs:integer"/>
        </xsl:call-template>
        <desc xmlns="http://www.w3.org/2000/svg">Front view</desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$maxLength + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:call-template name="lastStation_frontRecursive">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"
                        as="xs:integer"/>
                    <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                    <xsl:with-param name="counter" select="1"/>
                </xsl:call-template>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the same pattern for 4 sections -->
    <xsl:template name="lastStation_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:text>&#32;M</xsl:text>
        <xsl:value-of select="./measurement + $Gx + 7"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:text>&#32;L</xsl:text>
        <xsl:value-of select="$maxLength + $Gx"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:text>&#32;L</xsl:text>
        <xsl:value-of select="$maxLength + $Gx"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="lastStation_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="sH" select="$sH"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="otherStations">
        <xsl:param name="GyValue" select="$Gy"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="stationPreparation">
            <xsl:with-param name="GyValue" select="$GyValue"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template to draw the pattern for 4 sections in front view. -->
    <!-- N.B. it calls a recursive pattern to draw the pattern for an arbitrary number of 4 sections -->
    <xsl:template name="otherStations_front">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <desc xmlns="http://www.w3.org/2000/svg">Front view</desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline"/>
                <xsl:call-template name="otherStations_frontRecursive">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"
                        as="xs:integer"/>
                    <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                    <xsl:with-param name="counter" select="1"/>
                </xsl:call-template>
            </xsl:attribute>
        </path>
        <xsl:call-template name="stationPreparation_front">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template to draw the same pattern for 4 sections -->
    <xsl:template name="otherStations_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:text>&#32;M</xsl:text>
        <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 7"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:text>&#32;L</xsl:text>
        <xsl:value-of select="./measurement + $Gx - 7"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="otherStations_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="sH" select="$sH"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="stationPreparation">
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:choose>
            <xsl:when test="./preparation[piercedHole]">
                <!-- If the station preparation has been signalled as piercedHole, the diagram draws a straight line, the same as singleKnifeCut -->
                <xsl:call-template name="standardPreparationDiagram">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[singleKnifeCut]">
                <!-- If the station preparation has been signalled as singleKnifeCut, the diagram draws a straight line, the same as piercedHole -->
                <xsl:call-template name="standardPreparationDiagram">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[vNick]">
                <!-- If the station preparation has been signalled as vNick, the diagram draws a v shaped line -->
                <xsl:call-template name="vNickPreparationDiagram">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[NC | NK]">
                <!-- If the station preparation has been signalled as NC or NK, the diagram draws a straight line with High degree of uncertainty -->
                <xsl:call-template name="standardPreparationDiagram">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"/>
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[other]">
                <!-- If the station preparation has been signalled as a non standard typology, the diagram jumps leaving a gap in correspondence to the sewing station-->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:value-of
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </desc>
                <xsl:choose>
                    <xsl:when test="./type/supported/type/single[recessed]">
                        <xsl:call-template name="recessedSquare">
                            <!-- NB: Since this kind of station preparation was not properly classified, the certainty should be set to less than 100%? -->
                            <xsl:with-param name="certainty" select="100"/>
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="stationPreparation_front">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="./preparation[piercedHole]">
                <!-- If the station preparation has been signalled as piercedHole, the diagram draws a straight line, the same as singleKnifeCut -->
                <xsl:call-template name="stationPreparationDiagram_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[singleKnifeCut]">
                <!-- If the station preparation has been signalled as singleKnifeCut, the diagram draws a straight line, the same as piercedHole -->
                <xsl:call-template name="stationPreparationDiagram_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[vNick]">
                <!-- If the station preparation has been signalled as vNick, the diagram draws a v shaped line -->
                <xsl:call-template name="stationPreparationDiagram_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[NC | NK]">
                <!-- If the station preparation has been signalled as NC or NK, the diagram draws a straight line with High degree of uncertainty -->
                <xsl:call-template name="stationPreparationDiagram_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"/>
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./preparation[other]">
                <!-- If the station preparation has been signalled as a non standard typology, the diagram jumps leaving a gap in correspondence to the sewing station-->
                <xsl:call-template name="stationPreparationDiagram_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="desc"
                        select="concat('Station preparation type: ', ./preparation/child::*/name())"
                    />
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="./type/supported/type/single[recessed]">
                        <xsl:call-template name="stationPreparationDiagram_front">
                            <!-- NB: Since this kind of station preparation was not properly classified, the certainty should be set to less than 100%? -->
                            <xsl:with-param name="certainty" select="100"/>
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="recessedSquare">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <!-- This is not properly classified as a station preparation, however, in such cases of recessed bands, 
                    the drawing of the station necessarily needs to accommodate the different position of the sewing support -->
        <xsl:call-template name="recessedSewingSupport">
            <xsl:with-param name="GyValue" select="$GyValue"/>
            <xsl:with-param name="desc"
                select="concat('Station preparation type: ', ./type/supported/single/recessed/name())"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="standardPreparationDiagram">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="desc"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$desc"/>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3.6"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3.6"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the closing line for the standard diagram of sewing station preparation -->
    <xsl:template name="stationPreparationDiagram_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy -18"/>
        <xsl:param name="desc"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$desc"/>
        </desc>
        <xsl:choose>
            <xsl:when test="./preparation/other">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="$certainty"/>
                        <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                        <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx - 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx - 4"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx +4"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx + 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:call-template name="stationPreparationDiagram_frontRecursive">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline" as="xs:integer"/>
                            <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                            <xsl:with-param name="counter" select="1"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="./preparation/vNick | ./type/supported/type/single/recessed">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="$certainty"/>
                        <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                        <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx - 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx + 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:call-template name="stationPreparationDiagram_frontRecursive">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline" as="xs:integer"/>
                            <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                            <xsl:with-param name="counter" select="1"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="$certainty"/>
                        <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                        <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx - 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx + 7"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline"/>
                        <xsl:call-template name="stationPreparationDiagram_frontRecursive">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline" as="xs:integer"/>
                            <xsl:with-param name="sH" select="$sH" as="xs:integer"/>
                            <xsl:with-param name="counter" select="1"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </path>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template to draw the same pattern for 4 sections -->
    <xsl:template name="stationPreparationDiagram_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:choose>
            <xsl:when test="./preparation/other">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
            </xsl:when>
            <xsl:when test="./preparation/vNick | ./type/supported/type/single/recessed">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
                <xsl:choose>
                    <xsl:when test="./preparation/vNick">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                <xsl:choose>
                    <xsl:when test="./preparation/singleKnifeCut">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="./measurement + $Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="./measurement + $Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - ($sH * $counter) + $sH"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="stationPreparationDiagram_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="sH" select="$sH"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="vNickPreparationDiagram">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="desc"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$desc"/>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 4.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 4.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="recessedSewingSupport">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="desc"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$desc"/>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 2.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 2.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 2.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 2.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 2.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="stationType">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Sewing type: </xsl:text>
            <xsl:value-of select="type/child::*/name()"/>
        </desc>
        <xsl:choose>
            <xsl:when test="type[supported]">
                <xsl:call-template name="supportedSewing">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type[unsupported]">
                <xsl:call-template name="unsupportedSewing">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type[longStitch]">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="type[NC]">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="type[NK]">
                <!-- Do something -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="supportedSewing">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[3]/name()"/>
        </desc>
        <xsl:choose>
            <xsl:when test="type/supported/type/single">
                <xsl:call-template name="supportedSingle">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type/supported/type/double">
                <xsl:call-template name="supportedDouble">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="supportedDouble">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <xsl:call-template name="sewingSupportRound_double">
            <xsl:with-param name="GyValue" select="$GyValue"/>
        </xsl:call-template>
        <xsl:call-template name="sewingSupportRound_doubleFront">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
        </xsl:call-template>
        <xsl:call-template name="sewingLoop_double">
            <!-- Select the most probable thread route with an increased degree of uncertainty -->
            <xsl:with-param name="GyValue" select="$GyValue"/>
            <xsl:with-param name="certainty" select="$certainty"/>
        </xsl:call-template>
        <xsl:call-template name="sewingLoop_doubleFront">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="certainty" select="$certainty"/>
        </xsl:call-template>
    </xsl:template>

    <!-- The template calls two templates: one to draw the right kind of thread loop around the sewing support,
        and another one to draw the right kind of sewing support, both with the right degree of certainty -->
    <xsl:template name="supportedSingle">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[4]/name()"/>
        </desc>
        <xsl:choose>
            <xsl:when test="type/supported/type/single[raised]">
                <xsl:call-template name="sewingSupportRound_single">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                </xsl:call-template>
                <xsl:call-template name="sewingSupportRound_singleFront">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="xs:integer(./numberOfHoles) = 1">
                        <xsl:call-template name="sewingLoop">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                        <xsl:call-template name="sewingLoop_front">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:integer(./numberOfHoles) = 2">
                        <xsl:call-template name="sewingArch_raised">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                        <xsl:call-template name="sewingLoop_front">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NK'">
                        <!-- Select the most probable thread route with an increased degree of uncertainty -->
                        <xsl:call-template name="sewingLoop">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <!-- Calculate the increased degree of uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                        <!-- Select the most probable thread route with an increased degree of uncertainty -->
                        <xsl:call-template name="sewingLoop_front">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                            <!-- Calculate the increased degree of uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NA'">
                        <!-- NB -->
                        <!-- This should only have been used for recessed/vNick prepared stations -->
                        <!-- NB -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/supported/type/single[recessed]">
                <xsl:call-template name="sewingSupportRound_single">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                </xsl:call-template>
                <xsl:call-template name="sewingSupportRound_singleFront">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <!-- Select the most probable route, but with a high degree of uncertainty -->
                <xsl:call-template name="sewingArch_recessed">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                    <!-- Increase uncertainty -->
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
                <xsl:call-template name="sewingArch_recessedFront">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type/supported/type/single[flat]">
                <xsl:call-template name="sewingSupportFlat">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                </xsl:call-template>
                <xsl:call-template name="sewingSupportFlat_front">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <xsl:call-template name="sewingLoop_flatFront">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="xs:integer(./numberOfHoles) = 1">
                        <!-- Select the most probable route, but with an increased degree of uncertainty  -->
                        <xsl:call-template name="sewingLoop_flat">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <!-- Increase uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:integer(./numberOfHoles) = 2">
                        <xsl:call-template name="sewingArch_flat">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NK'">
                        <!-- Select the most probable thread route with an increased degree of uncertainty -->
                        <xsl:call-template name="sewingLoop_flat">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <!-- Calculate the increased degree of uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NA'">
                        <!-- NB -->
                        <!-- This should only have been used for recessed/vNick prepared stations -->
                        <!-- NB -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/supported/type/single[NC]">
                <xsl:call-template name="sewingSupportRound_single">
                    <xsl:with-param name="GyValue" select="$GyValue"/>
                </xsl:call-template>
                <xsl:call-template name="sewingSupportRound_singleFront">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <!-- Select the most probable thread route with a high degree of uncertainty -->
                <xsl:choose>
                    <xsl:when test="xs:integer(./numberOfHoles) = 1">
                        <xsl:call-template name="sewingLoop">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                        <xsl:call-template name="sewingSupportRound_singleFront">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:integer(./numberOfHoles) = 2">
                        <xsl:call-template name="sewingArch_raised">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NK'">
                        <!-- Select the most probable thread route with an increased degree of uncertainty -->
                        <xsl:call-template name="sewingLoop">
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                            <!-- Calculate the increased degree of uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                        <!-- Select the most probable thread route with an increased degree of uncertainty -->
                        <xsl:call-template name="sewingSupportRound_singleFront">
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                            <!-- Calculate the increased degree of uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="xs:string(./numberOfHoles) = 'NA'">
                        <!-- NB -->
                        <!-- This should only have been used for recessed/vNick prepared stations -->
                        <!-- NB -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewingSupportRound_single">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="type/supported/type/single[raised]">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#sewingSupportRound</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="./measurement + $Gx"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$GyValue - 5"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="type/supported/type/single[recessed]">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#sewingSupportRound_small</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="./measurement + $Gx"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$GyValue + 1"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <!-- Template to draw the diagram of a single sewing support viewed frontally (Spine view) -->
    <xsl:template name="sewingSupportRound_singleFront">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="type/supported/type/single[raised]">
                    <xsl:variable name="x" select="./measurement + $Gx - 3.1"/>
                    <xsl:variable name="supportType">
                        <xsl:text>#sewingSupportRound_front</xsl:text>
                    </xsl:variable>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$supportType"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y"/>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="sewingSupport_frontRecursive">
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="sH" select="$sH"/>
                        <xsl:with-param name="x" select="$x"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="supportType" select="$supportType"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="type/supported/type/single[recessed]">
                    <xsl:variable name="x" select="./measurement + $Gx - 2"/>
                    <xsl:variable name="supportType">
                        <xsl:text>#sewingSupportRound_smallFront</xsl:text>
                    </xsl:variable>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$supportType"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y"/>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="sewingSupport_frontRecursive">
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="sH" select="$sH"/>
                        <xsl:with-param name="x" select="$x"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="supportType" select="$supportType"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="sewingSupportRound_double">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#sewingSupportRound</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="./measurement + $Gx - 4.2"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$GyValue - 5"/>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#sewingSupportRound</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="./measurement + $Gx + 4.2"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$GyValue - 5"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="sewingSupportRound_doubleFront">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <xsl:variable name="supportType">
            <xsl:text>#sewingSupportRound_front2</xsl:text>
        </xsl:variable>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$supportType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="./measurement + $Gx - 7.3"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="sewingSupport_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="sH" select="$sH"/>
                <xsl:with-param name="x" select="./measurement + $Gx - 7.3"/>
                <xsl:with-param name="y" select="$y"/>
                <xsl:with-param name="supportType" select="$supportType"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$supportType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="./measurement + $Gx - 0.5"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="sewingSupport_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="sH" select="$sH"/>
                <xsl:with-param name="x" select="./measurement + $Gx - 0.5"/>
                <xsl:with-param name="y" select="$y"/>
                <xsl:with-param name="supportType" select="$supportType"/>
            </xsl:call-template>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="sewingSupportFlat">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupportFlat">
            <xsl:attribute name="x">
                <xsl:value-of select="./measurement + $Gx - 6"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 5"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingSupportFlat_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:variable name="x" select="./measurement + $Gx - 7"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <xsl:variable name="supportType">
            <xsl:text>#sewingSupportFlat_front</xsl:text>
        </xsl:variable>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$supportType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="sewingSupport_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="sH" select="$sH"/>
                <xsl:with-param name="x" select="$x"/>
                <xsl:with-param name="y" select="$y"/>
                <xsl:with-param name="supportType" select="$supportType"/>
            </xsl:call-template>
        </g>
    </xsl:template>

    <!-- Template to draw the whole length of the sewing support according to the number of sections (= 4) -->
    <xsl:template name="sewingSupport_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="sH" select="$sH" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:param name="supportType"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$supportType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="sewingSupport_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="sH" select="$sH"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="supportType" select="$supportType"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewingLoop">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#loop">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingLoop_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="x" select="./measurement + $Gx - 4.1"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <xsl:variable name="loopType">
            <xsl:text>#loop_front</xsl:text>
        </xsl:variable>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
        <xsl:call-template name="sewing_frontRecursive">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
        <xsl:call-template name="packedSewing_front">
            <xsl:with-param name="certainty" select="40"/>
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="sewingArch_raised">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingArch_raised">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingArch_recessed">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingArch_recessed">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingArch_recessedFront">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="x" select="./measurement + $Gx - 3"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <xsl:variable name="loopType">
            <xsl:text>#sewingArch_recessedFront</xsl:text>
        </xsl:variable>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
        <xsl:call-template name="sewing_frontRecursive">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
        <xsl:call-template name="packedSewing_front">
            <xsl:with-param name="certainty" select="40"/>
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="sewingLoop_flat">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#loop_flat">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingLoop_flatFront">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="x" select="./measurement + $Gx - 8"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <xsl:variable name="loopType">
            <xsl:text>#loop_flatFront</xsl:text>
        </xsl:variable>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
        <xsl:call-template name="sewing_frontRecursive">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
        <xsl:call-template name="packedSewing_front">
            <xsl:with-param name="certainty" select="40"/>
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="loopType" select="$loopType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="sewingArch_flat">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingArch_flat">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingLoop_double">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#doubleLoop">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="sewingLoop_doubleFront">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./type/supported/type/double/linking[notLinked]">
                    <xsl:variable name="loopType">
                        <xsl:text>#loop_front2</xsl:text>
                    </xsl:variable>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$loopType"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="./measurement + $Gx - 8.5"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y"/>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="sewing_frontRecursive">
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="x" select="./measurement + $Gx - 8.5"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="loopType" select="$loopType"/>
                    </xsl:call-template>
                    <xsl:call-template name="packedSewing_front">
                        <xsl:with-param name="certainty" select="40"/>
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="x" select="./measurement + $Gx - 8.5"/>
                        <xsl:with-param name="loopType" select="$loopType"/>
                    </xsl:call-template>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$loopType"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="./measurement + $Gx -1.5"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y"/>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="sewing_frontRecursive">
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="x" select="./measurement + $Gx - 1.5"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="loopType" select="$loopType"/>
                    </xsl:call-template>
                    <xsl:call-template name="packedSewing_front">
                        <xsl:with-param name="certainty" select="40"/>
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="x" select="./measurement + $Gx - 1.5"/>
                        <xsl:with-param name="loopType" select="$loopType"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="./type/supported/type/double/linking[linked]">
                    <xsl:variable name="loopType">
                        <xsl:text>#loop_frontLinked</xsl:text>
                    </xsl:variable>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$loopType"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="./measurement + $Gx - 8.5"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y"/>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="sewing_frontRecursive">
                        <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                        <xsl:with-param name="x" select="./measurement + $Gx - 8.5"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="loopType" select="$loopType"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </g>
    </xsl:template>

    <!-- Template to draw the whole length of the sewing support according to the number of sections (= 4) -->
    <xsl:template name="sewing_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:param name="loopType"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="$counter lt ($sN - 1)">
                <xsl:call-template name="sewing_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Template to draw the diagram of packed sewing. 
        NB: the schema does not indicate whether a sewing is packed or not,
        hence the diagram has to be drawn with a high degree of uncertainty -->
    <xsl:template name="packedSewing_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="loopType"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="$GyValue_frontBaseline - ($sH div 2) + 1.5"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'2'"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$loopType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="packedSewing_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="x" select="$x"/>
                <xsl:with-param name="y" select="$y"/>
                <xsl:with-param name="loopType" select="$loopType"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$loopType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y - 3"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="packedSewing_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="x" select="$x"/>
                <xsl:with-param name="y" select="$y - 3"/>
                <xsl:with-param name="loopType" select="$loopType"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$loopType"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y - 4.5"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="packedSewing_frontRecursive">
                <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                <xsl:with-param name="x" select="$x"/>
                <xsl:with-param name="y" select="$y - 4.5"/>
                <xsl:with-param name="loopType" select="$loopType"/>
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="packedSewing_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:param name="loopType"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="$counter lt ($sN - 1)">
                <xsl:call-template name="sewing_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unsupportedSewing">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[2]/name()"/>
        </desc>
        <xsl:choose>
            <xsl:when test="type/unsupported/kettleStitch">
                <xsl:call-template name="kettleStitch_front">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="preceding-sibling::station[1]/type/unsupported/doubleSequence">
                        <xsl:call-template name="doubleSequenceLink">
                            <xsl:with-param name="certainty" select="100"/>
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/unsupported[twoNeedle | singleSequence | doubleSequence]">
                <xsl:call-template name="unsupported_front">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="position() != 1 and position() != last()">
                        <xsl:call-template name="unsupportedLoop">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="type/unsupported[doubleSequence]">
                        <xsl:call-template name="doubleSequenceLink">
                            <xsl:with-param name="certainty" select="100"/>
                            <xsl:with-param name="GyValue_frontBaseline"
                                select="$GyValue_frontBaseline"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/unsupported[NC | NK]">
                <!-- Call the most probably sewing with an increased degree of uncertainty -->
                <xsl:call-template name="unsupported_front">
                    <!-- increase uncertainty -->
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="position() != 1 and position() != last()">
                        <xsl:call-template name="unsupportedLoop">
                            <!-- increase uncertainty -->
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="GyValue" select="$GyValue"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/unsupported/other">
                <!-- Nothing is drawn and a gap is left; the <desc> element in the SVG indicates that the sewing station is of an unsupported type -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="kettleStitch_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <xsl:variable name="x">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:value-of select="./measurement + $Gx - 11.5"/>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:value-of select="./measurement + $Gx - 9"/>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="./measurement + $Gx - 11.5"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="./measurement + $Gx - 9"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y">
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:value-of select="$GyValue_frontBaseline - 14"/>
                </xsl:when>
                <xsl:when test="position() = 1">
                    <xsl:value-of select="$GyValue_frontBaseline - 8"/>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="$GyValue_frontBaseline - 8"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="$GyValue_frontBaseline - 14"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="clipPath">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:text>url(#interlink2_first2)</xsl:text>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:text>url(#interlink2_first)</xsl:text>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>url(#interlink2_first2)</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>url(#interlink2_first)</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="loopType">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:text>#kettleStitch_front_vFlipped</xsl:text>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:text>#kettleStitch_front</xsl:text>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_vFlipped</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[2]/name()"/>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:value-of select="$clipPath"/>
            </xsl:attribute>
            <xsl:attribute name="x" select="$x"/>
            <xsl:attribute name="y" select="$y"/>
        </use>
        <xsl:choose>
            <xsl:when
                test="(position() eq 1 and following-sibling::station/type/unsupported/doubleSequence) or preceding-sibling::station/type/unsupported/doubleSequence">
                <xsl:call-template name="kettleStitch_frontReversed">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="kettleStitch_frontRecursive">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="kettleStitch_frontReversed">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:variable name="clipPath">
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:text>url(#interlink2_first2_180)</xsl:text>
                </xsl:when>
                <xsl:when test="position() = 1">
                    <xsl:text>url(#interlink2_first_180)</xsl:text>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>url(#interlink2_first_180)</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>url(#interlink2_first2_180)</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="loopType">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:text>#kettleStitch_front_180vFlipped</xsl:text>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:text>#kettleStitch_front_180</xsl:text>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_180vFlipped</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_180</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="$loopType"/>
                    </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:value-of select="$clipPath"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - (5 * $sH) - 1"/>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_doubleSequenceLink_vFlipped</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_doubleSequenceLink</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_doubleSequenceLink_vFlipped</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#kettleStitch_front_doubleSequenceLink</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - (2 * $sH)"/>
            </xsl:attribute>
        </use>
    </xsl:template>

    <xsl:template name="kettleStitch_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:param name="loopType"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$counter eq ($sN - 2) and position() != 1">
                    <xsl:attribute name="clip-path">
                        <xsl:text>url(#interlink2_last)</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="clip-path">
                        <xsl:text>url(#interlink2)</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - (2 * $sH * $counter)"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="$counter lt $sN - 2">
                <xsl:call-template name="kettleStitch_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unsupportedLoop">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#loop_unsupported">
            <xsl:attribute name="x">
                <xsl:value-of select="(./measurement + $Gx) - 10"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$GyValue - 11"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="unsupported_front">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <xsl:variable name="x" select="./measurement + $Gx - 10"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2) - 11"/>
        <xsl:variable name="clipPath">
            <xsl:text>url(#interlink1_first)</xsl:text>
        </xsl:variable>
        <xsl:variable name="loopType">
            <xsl:text>#link-stitch_front</xsl:text>
        </xsl:variable>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[2]/name()"/>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:value-of select="$clipPath"/>
            </xsl:attribute>
            <xsl:attribute name="x" select="$x"/>
            <xsl:attribute name="y" select="$y"/>
        </use>
        <xsl:choose>
            <xsl:when test="type/unsupported/doubleSequence">
                <xsl:call-template name="unsupported_frontReversed">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="unsupported_frontRecursive">
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unsupported_frontReversed">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="type/descendant::*[2]/name()"/>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#link-stitch_front</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:text>url(#interlink1)</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x" select="$x"/>
            <xsl:attribute name="y" select="$y - $sH"/>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#link-stitch_front_180</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:text>url(#interlink1_180)</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x" select="$x"/>
            <xsl:attribute name="y" select="$y - 3 * $sH - 1"/>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#link-stitch_front_180</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:text>url(#interlink1_first_180)</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x" select="$x"/>
            <xsl:attribute name="y" select="$y - 4 *$sH - 1"/>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#link-stitch_front_doubleSequenceLink</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - $sH - ($sH div 2)"/>
            </xsl:attribute>
        </use>
    </xsl:template>

    <xsl:template name="unsupported_frontRecursive">
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="x" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:param name="loopType"/>
        <xsl:param name="sN" select="$sN"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$loopType"/>
            </xsl:attribute>
            <xsl:attribute name="clip-path">
                <xsl:text>url(#interlink1)</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="$counter lt $sN">
                <xsl:call-template name="unsupported_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="loopType" select="$loopType"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="doubleSequenceLink">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:choose>
                    <xsl:when test="type/unsupported/kettleStitch">
                        <xsl:value-of select="./measurement + $Gx - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - (2 * $sH)  - ($sH div 2)"/>
                    </xsl:when>
                    <xsl:when test="type/unsupported[not(kettleStitch)]">
                        <xsl:value-of select="./measurement + $Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - (2 * $sH)"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:choose>
                    <xsl:when test="preceding-sibling::station[1]/type/unsupported/kettleStitch">
                        <xsl:value-of
                            select="measurement + $Gx - (((measurement + $Gx) - (preceding-sibling::station[1]/measurement + $Gx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - $sH - ($sH div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="preceding-sibling::station[1]/measurement +$Gx + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - $sH - ($sH div 2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="measurement + $Gx - (((measurement + $Gx) - (preceding-sibling::station[1]/measurement + $Gx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - (2 * $sH) - ($sH div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="preceding-sibling::station[1]/measurement +$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$GyValue_frontBaseline - (2 * $sH)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the entrance path of the thread -->
    <xsl:template name="sewingIn">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square"
            marker-start="url(#arrowSymbol)" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue - 3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue - 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" marker-start="url(#arrowSymbol)"
            marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 13"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the sewing arc between stations (not first or last stations) -->
    <xsl:template name="sewingArc">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square"
            marker-start="url(#arrowSymbol)" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="./measurement + (2 * $Gx) + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx - 10"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <!-- Template to draw the exit path of the thread -->
    <xsl:template name="sewingOut">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue" select="$Gy"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square"
            marker-start="url(#arrowSymbol)" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="preceding-sibling::station[1]/measurement + $Gx + 13"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="./measurement + $Gx - 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue + 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" marker-start="url(#arrowSymbol)"
            marker-end="url(#arrowSymbol)">
            <xsl:attribute name="class">
                <xsl:text>thread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="./measurement +$Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue - 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="./measurement + $Gx + 9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$GyValue - 3"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="innerSewing_front">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:variable name="y" select="$GyValue_frontBaseline - ($sH div 2)"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="marker-end">
                <xsl:text>url(#arrowSymbol)</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="measurement + $Gx + (((following-sibling::station[1]/measurement + $Gx) - (measurement + $Gx)) div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of
                    select="measurement + $Gx + (((following-sibling::station[1]/measurement + $Gx) - (measurement + $Gx)) div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="innerSewing_frontRecursive">
            <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="certainty"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="innerSewing_frontRecursive">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="GyValue_frontBaseline" select="$Gy - 18" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="y" select="1"/>
        <xsl:variable name="arrowSymbol">
            <xsl:choose>
                <xsl:when test="$counter mod 2">
                    <xsl:text>url(#arrowSymbol_180)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>url(#arrowSymbol)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="marker-end">
                <xsl:value-of select="$arrowSymbol"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="measurement + $Gx + (((following-sibling::station[1]/measurement + $Gx) - (measurement + $Gx)) div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>innerThread</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <!-- modify the template to the right kind of parameters to be passed on to represent the degree of certainty (i.e. the probability) -->
                <!--<xsl:with-param name="uncertaintyIncrement"/>
                <xsl:with-param name="type"/>-->
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of
                    select="measurement + $Gx + (((following-sibling::station[1]/measurement + $Gx) - (measurement + $Gx)) div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y - ($sH * $counter)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="following-sibling::station[1]/measurement + $Gx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$y - ($sH * $counter)"/>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="$counter lt ($sN - 1)">
                <xsl:call-template name="innerSewing_frontRecursive">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="GyValue_frontBaseline" select="$GyValue_frontBaseline"/>
                    <xsl:with-param name="y" select="$y"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- This template only adds a <desc></desc> element to the SVG code in order to make explicit which station is
        being generated and its type (unsupported/kettlestitch or supported) -->
    <!-- NB: the code only considers kettlestitches and supported stations for the moment, more information to be 
        gathered here as the drawing capabilities of the code are being expanded -->
    <xsl:template name="stationDescription">
        <xsl:param name="p_stationN"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Station N.</xsl:text>
            <xsl:value-of select="position()"/>
            <xsl:text>(</xsl:text>
            <xsl:value-of
                select="./type/descendant::*[position() lt 5][not(name() = 'type')][not(name() = 'route')]/name()"/>
            <xsl:value-of
                select="if (./type/supported/type/double/child::node()/name() = 'linkink') then concat(' ',./type/supported/type/double/linkink/*/name()) else ''"/>
            <xsl:text>; number of holes: </xsl:text>
            <xsl:value-of select="./numberOfHoles"/>
            <xsl:text>)</xsl:text>
        </desc>
    </xsl:template>

    <!-- Uncertainty template -->
    <xsl:template name="certainty">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="uncertaintyIncrement"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = '1'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f1)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$type = '2'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f2)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$type = '3'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f3)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
