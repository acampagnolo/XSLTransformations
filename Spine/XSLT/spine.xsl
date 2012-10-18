<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dict="www.mydict.my"
    exclude-result-prefixes="xs svg xlink lig dict" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" standalone="no"
        xpath-default-namespace="http://www.w3.org/2000/svg" exclude-result-prefixes="xlink"
        include-content-type="no"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>
    <xsl:variable name="filename"
        select="concat('../../Transformations/Spine/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'spine', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="$Ox"/>
    
    <!-- Only a portion of the book width is drawn: this parameter selects the length -->
    <xsl:param name="boardLength" select="50"/>

    <!-- X value of the upperleft corner of the above view of the inner surface of the board -->
    <xsl:variable name="Ax" select="$Ox + 20"/>
    <xsl:variable name="Ay" select="$Oy + 20"/>
    
    <xsl:variable name="leftBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/location[left]">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/left]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="10"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="rightBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/location[right]">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/right]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="10"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="bookblockThickness">
        <xsl:value-of select="/book/dimensions/thickness/min - $leftBoardThickness - $rightBoardThickness"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:result-document href="{$filename}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Spine/CSS/style.css"&#32;</xsl:text>
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
                <title>Spine shape of book: <xsl:value-of select="$shelfmark"/></title>
                <xsl:copy-of select="document('../SVGmaster/spineSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                <desc xmlns="http://www.w3.org/2000/svg">Spine shape of book: <xsl:value-of
                        select="$shelfmark"/></desc>
                <svg>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="book/boards/yes/boards"/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template match="board/location" name="boardLocation">
        <xsl:for-each select="left">
            <xsl:variable name="boardThickness" select="$leftBoardThickness"/>
            <xsl:variable name="location">
                <xsl:value-of select="./name()"/>
            </xsl:variable>
            <xsl:call-template name="boardCrossSection">
                <xsl:with-param name="boardThickness" select="$boardThickness"/>
                <xsl:with-param name="location" select="$location"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="right">
            <xsl:variable name="boardThickness" select="$rightBoardThickness"/>
            <xsl:variable name="location">
                <xsl:value-of select="./name()"/>
            </xsl:variable>
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="transform">
                    <xsl:text>translate(</xsl:text>
                    <xsl:value-of select="80 + $boardThickness"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy"/>
                    <xsl:text>) scale(-1,1)</xsl:text>
                    <xsl:text>translate(</xsl:text>
                    <xsl:value-of select="- $bookblockThickness - $boardThickness"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="boardCrossSection">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    <xsl:with-param name="location" select="$location"/>
                </xsl:call-template>
            </g>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="boardCrossSection">
        <xsl:param name="boardThickness"/>
        <xsl:param name="location"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$location"/>
            <xsl:text>&#32;board</xsl:text>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(-10,30) rotate(-90,50,0)">
            <pippo>
                <xsl:value-of select="$boardThickness"/>
            </pippo>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
                stroke="url(#fading)" stroke-width="0.5" fill="url(#thicknessCutoutTile)">
                <!--<xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>-->
                <!-- TO DO: add uncertainty  -->
                <!-- when NC: some uncertainty; when NK or other: uncertainty -->
                <!-- TO DO -->
                <xsl:attribute name="d">
                    <xsl:call-template name="boardPath">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>
                </xsl:attribute>
            </path>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
                stroke-opacity="0" fill-opacity="0.1" fill="url(#fading)">
                <!--<xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>-->
                <!-- TO DO: add uncertainty  -->
                <!-- when NC: some uncertainty; when NK or other: uncertainty -->
                <!-- TO DO -->
                <xsl:attribute name="d">
                    <xsl:call-template name="boardPath">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>
                </xsl:attribute>
            </path>
            <xsl:call-template name="spineArc">
                <xsl:with-param name="boardThickness" select="$boardThickness"/>
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="boardPath">
        <xsl:param name="boardThickness"/>
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$Ox"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$Oy + $boardThickness"/>
        <xsl:choose>
            <xsl:when test="ancestor::book/spine/profile/joints/slight">
                <!-- slight round at the spine -->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .95"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * 2 div 3"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                <!-- rounded corner at the spine -->
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/acute">
                <!-- angled spine edge -->
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/angled">
                <!-- angled spine edge (mirror of acute) -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                <!-- Cushion -->
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                <!-- Peripheral cushion -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>z</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="spineArc">
        <xsl:param name="boardThickness"/>
        <path xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * 2 div 3"/>
                <xsl:text>&#32;A</xsl:text>
                <xsl:value-of select="$bookblockThickness * .1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$bookblockThickness div 2"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="0"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="0"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="1"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * 1.1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
            </xsl:attribute>
        </path>
    </xsl:template>

</xsl:stylesheet>
