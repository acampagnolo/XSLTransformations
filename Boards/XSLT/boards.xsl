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
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenameLeft"
        select="concat('../../Transformations/Boards/SVGoutput/', $fileref[1], '_', 'leftBoard', '.svg')"/>
    <xsl:variable name="filenameRight"
        select="concat('../../Transformations/Boards/SVGoutput/', $fileref[1], '_', 'rightBoard', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="$Ox"/>

    <!-- X value of the upperleft corner of the above view of the inner surface of the board -->
    <xsl:variable name="Bx" select="$Ox + 100"/>
    <xsl:variable name="By" select="$Oy + 50"/>

    <!-- X value of the upperleft corner of the above view of the inner surface of the board -->
    <xsl:variable name="Ax" select="$Bx"/>
    <xsl:variable name="Ay" select="$By + 50"/>
    
    <!-- NB: no measurements are given for the width of the board. Only the whole width of the book is given, 
        which includes features such as foredge pins, raised bands, etc. 
        An estimate is necessary: Check if there are raised bands and protruding furniture; 
        check the shape of the spine and estimate the width-->
    <xsl:variable name="boardWidth">
        <xsl:variable name="raisedBands">
            <xsl:value-of select="if (/book/sewing/stations//type/supported) then 5 else 0"/>
        </xsl:variable>
        <xsl:variable name="protrudingFurniture">
            <xsl:value-of select="if (/book/furniture/yes[not(bosses | plates)]) then 3 else 0"/>
        </xsl:variable>
        <xsl:variable name="spineShape">
            <xsl:choose>
                <xsl:when test="/book/spine/profile/shape/flat">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="/book/spine/profile/shape/slightRound">
                    <xsl:value-of select="3"/>
                </xsl:when>
                <xsl:when test="/book/spine/profile/shape/round">
                    <xsl:value-of select="5"/>
                </xsl:when>
                <xsl:when test="/book/spine/profile/shape/heavyRound">
                    <xsl:value-of select="8"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="3"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="/book/dimensions/width - $raisedBands - $protrudingFurniture - $spineShape"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/boards/yes/boards/board/location/left">
            <xsl:result-document href="{$filenameLeft}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../GitHub/Transformations/Boards/CSS/style.css"&#32;</xsl:text>
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
                    <title>Left board of book: <xsl:value-of select="$shelfmark"/></title>
                    <xsl:copy-of
                        select="document('../SVGmaster/boardsSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">Left board</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <xsl:call-template name="crossSection"/>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
        <xsl:for-each select="book/boards/yes/boards/board/location/right">
            <xsl:result-document href="{$filenameRight}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../GitHub/Transformations/Boards/CSS/style.css"&#32;</xsl:text>
                    <xsl:text>type="text/css"</xsl:text>
                </xsl:processing-instruction>
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                    version="1.1" x="0" y="0" width="1189mm" height="841mm" viewBox="0 0 1189 841"
                    preserveAspectRatio="xMidYMid meet">
                    <title xmlns="http://www.w3.org/2000/svg">Right boards of book: <xsl:value-of
                            select="$shelfmark"/></title>
                    <xsl:copy-of
                        select="document('../SVGmaster/boardsSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1 1)">
                        <desc>Right board</desc>
                        <svg>
                            <!-- Check how much to substract from Ox to have a good right board visualization -->
                            <xsl:attribute name="x">
                                <xsl:value-of select="$Ox - 305"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="$Oy"/>
                            </xsl:attribute>
                            <xsl:call-template name="crossSection"/>
                        </svg>
                    </g>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="crossSection">
        <!-- Draw the upper edge of the cross section; the four edges should be drawn with separate paths
            in order to be able to set the uncertainty level only on the line where it is needed -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <!-- TO DO: add uncertainty for upper bevel line:  -->
            <!-- when NC: some uncertainty; when NK or other: uncertainty -->
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Bx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$By"/>
                <xsl:choose>
                    <xsl:when test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other]">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
    </xsl:template>




</xsl:stylesheet>
