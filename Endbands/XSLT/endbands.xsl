<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dict="www.mydict.my" xmlns:my="www.my.my"
    xmlns:math="http://exslt.org/math" exclude-result-prefixes="xs svg xlink lig dict math"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" standalone="no"
        xpath-default-namespace="http://www.w3.org/2000/svg" exclude-result-prefixes="xlink"
        include-content-type="no"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="0"/>

    <xsl:param name="boardThickness" select="10"/>


    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>



    <!--<xsl:variable name="bookThicknessDatatypeChecker">
        <!-\- Some surveyors have types 'same' instead of giving the value in mm: 
            check for the numeric value in /book/dimensions/thickness/max instead-\->
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
                        <!-\- NB: in this case the measurement should be indicated as estimated for the sole purpose 
                            of the XSLT to be able to draw the diagram with the rest of the data available -\->
                        <!-\- How to pass on the information that the measurement has been guessed?? -\->
                        <xsl:value-of select="50"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="leftBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/location/left">
                <!-\- To avoid problems with erroneous inputs (e.g. two left boards), only the first board with a location/left child is considered -\->
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/left][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards/yes/boards/board/location[not(left)]">
                <xsl:value-of
                    select="/book/boards/yes/boards/board[location/right][1]/formation/boardThickness[not(NK)]"
                />
            </xsl:when>
            <xsl:when test="/book/boards[no | NK]">
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
            <xsl:when test="/book/boards[no | NK]">
                <xsl:value-of select="xs:double($bookThicknessDatatypeChecker *.07)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>-->
    <!--
    <xsl:variable name="bookblockThickness">
        <!-\- Some surveyors have types 'same' instead of giving the value in mm: 
            check for the numeric value in /book/dimensions/thickness/max instead-\->
        <xsl:choose>
            <xsl:when test="/book/dimensions/thickness/min castable as xs:integer">
                <xsl:value-of
                    select="/book/dimensions/thickness/min - xs:double($leftBoardThickness) - xs:double($rightBoardThickness)"
                />
            </xsl:when>
            <xsl:when test="xs:string(/book/dimensions/thickness/min)">
                <xsl:value-of
                    select="xs:integer(/book/dimensions/thickness/max) - xs:double($leftBoardThickness) - xs:double($rightBoardThickness)"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>-->

    <xsl:variable name="bookblockThickness">
        <!-- Not parametric as the rest of the of the dimensions used in the diagram are symbolic and not based real measurements -->
        <xsl:value-of select="50"/>
    </xsl:variable>

    <!-- Tiedown length and panel height are not parametric as either no measurement is given,
        or the majority of the dimensions used in the diagram are symbolic and not based real measurements -->
    <xsl:variable name="unitlength">
        <xsl:value-of select="24"/>
    </xsl:variable>

    <xsl:variable name="tiedownLengthX">
        <!-- Disregarded parametric tiedowns: (ancestor::book/sewing/stations/station[group/current][position() eq 1]/measurement * 3) -->
        <xsl:value-of select="$unitlength * 3"/>
    </xsl:variable>

    <xsl:variable name="tiedownLength">
        <xsl:value-of select="$unitlength * 2"/>
    </xsl:variable>

    <xsl:variable name="panelHeightX">
        <!-- Same as tiedown length Xk -->
        <xsl:value-of select="$unitlength * 3"/>
    </xsl:variable>

    <xsl:variable name="panelHeight">
        <!-- Same as tiedown length -->
        <xsl:value-of select="$unitlength * 2"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:choose>
            <xsl:when test="book/endbands/yes/endband">
                <xsl:for-each select="book/endbands/yes/endband">
                    <xsl:variable name="number">
                        <xsl:number/>
                    </xsl:variable>
                    <xsl:variable name="location">
                        <xsl:value-of select="location/node()[2]/name()"/>
                    </xsl:variable>
                    <xsl:variable name="filename"
                        select="concat('../../Transformations/endbands/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'endband', '-', $number, '_', $location, '.svg')"/>
                    <xsl:result-document href="{$filename}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/endbands/CSS/style.css"&#32;</xsl:text>
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
                        <svg xmlns="http://www.w3.org/2000/svg"
                            xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0" y="0"
                            width="1189mm" height="841mm" viewBox="0 0 1189 841"
                            preserveAspectRatio="xMidYMid meet">
                            <title>
                                <xsl:text>Endband (</xsl:text>
                                <xsl:value-of select="$location"/>
                                <xsl:text>) of book: </xsl:text>
                                <xsl:value-of select="$shelfmark"/>
                            </title>
                            <xsl:copy-of
                                select="document('../SVGmaster/endbandsSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg"
                                copy-namespaces="no"/>
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>Endband (</xsl:text>
                                <xsl:value-of select="$location"/>
                                <xsl:text>) of book: </xsl:text>
                                <xsl:value-of select="$shelfmark"/>
                            </desc>
                            <xsl:call-template name="title">
                                <xsl:with-param name="detected" select="1"/>
                                <xsl:with-param name="location" select="$location"/>
                            </xsl:call-template>
                            <xsl:call-template name="description"/>
                            <svg>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ox"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Oy + 45"/>
                                </xsl:attribute>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!--<!-\- add quire profiles -\->
                            <xsl:variable name="numberOfQuires" select="17"/>
                            <xsl:call-template name="recursiveQuireAbove">
                                <xsl:with-param name="counter" select="$numberOfQuires"/>
                            </xsl:call-template>-->
                                    <xsl:choose>
                                        <xsl:when test="stuckOn/yes">
                                            <!-- different pipeline -->
                                            <xsl:call-template name="coresX_stuckOn"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="coresX"/>
                                            <xsl:call-template name="primarySewing"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </g>
                            </svg>
                            <xsl:call-template name="notes"/>
                        </svg>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:call-template name="title">
                        <xsl:with-param name="detected" select="0"/>
                    </xsl:call-template>
                </svg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template name="panelHeight">
        <xsl:param name="scale" select="'2:1'"/>
        <path xmlns="http://www.w3.org/2000/svg" transform="rotate(90 40,80)" stroke="url(#fading2)"
            stroke-width="0.5" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 40"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80"/>
                <xsl:text>&#32;L</xsl:text>
                <!-- The panel height is calculated by 'scaling' the $unitLengththree times for the cross-section and twice for the general view -->
                <xsl:value-of
                    select="$Ox + 40 + ($unitlength * (if ($scale eq '2:1') then 2 else 3)) + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80.0001"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="coresX">
        <!-- Draw the bookblock reference lines -->
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(6,0)">
            <xsl:call-template name="panelHeight">
                <xsl:with-param name="scale" select="'3:1'"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#bookblockX"/>
        </g>
        <!-- Draw the cross sections of the cores -->
        <xsl:for-each select="cores/yes/cores/type">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:choose>
                    <xsl:when test="core">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="position() gt 1">
                                    <xsl:text>#coreX-2</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>#coreX</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 48"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="crowningCore">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:text>#crowningCoreX_secondary</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>#crowningCoreX</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::endband/primary/yes/construction/type/greekDoubleCore">
                                    <xsl:value-of select="$Ox + 50"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$Ox + 48"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="y">
                    <xsl:value-of
                        select="if (crowningCore) then $Oy + 86 - (20 * position()) + 5.5 else $Oy + 86 - (20 * position())"
                    />
                </xsl:attribute>
                <!-- The schema does not specify the general shape of the core cross section (round? square?): draw with uncertainty as to show uncertainty in the drawn typology -->
                <!-- The schema does not specify the spatial relations between the cores: draw with uncertainty as to show uncertainty in the drawn typology  -->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="50"/>
                    <xsl:with-param name="type" select="'3'"/>
                </xsl:call-template>
            </use>
            <!-- Detail view -->
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:choose>
                    <xsl:when test="core">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="position() gt 1">
                                    <xsl:text>#core_2_detail</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>#core_1_detail</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="crowningCore">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:text>#crowningCore_detail_secondary</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>#crowningCore_detail</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="y">
                    <xsl:value-of
                        select="if (crowningCore) then $Oy + 20 - (20 * position()) + 5.5 else $Oy + 20 - (20 * position())"
                    />
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="NK">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Core type not known</xsl:text>
                    </desc>
                </xsl:when>
                <xsl:when test="other">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Other core type: </xsl:text>
                        <xsl:value-of select="other"/>
                    </desc>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of
                    select="$Oy + 45 + 45 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0)"
                />
            </xsl:attribute>
            <xsl:text>front</xsl:text>
        </text>
        <g id="frontView_framework" xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:text>translate(50,</xsl:text>
                <xsl:choose>
                    <xsl:when test="cores/yes">
                        <xsl:value-of select="20"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="20"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="cores"/>
        </g>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of
                    select="$Oy + 45 + 45 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0) + $panelHeight + 80"
                />
            </xsl:attribute>
            <xsl:text>back</xsl:text>
        </text>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontView_framework">
            <xsl:attribute name="transform">
                <xsl:text>translate(0,</xsl:text>
                <xsl:value-of select="$Oy + $panelHeight + 80"/>
                <xsl:text>) scale(-1,1) translate(</xsl:text>
                <xsl:value-of select="-(550 + ($bookblockThickness * 2))"/>
                <xsl:text>,0)</xsl:text>
            </xsl:attribute>
        </use>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <!--<xsl:value-of
                    select="$Oy + 98 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0) - (8 * count(ancestor-or-self::endband/cores/yes/cores/type/core)) - (4 * count(ancestor-or-self::endband/cores/yes/cores/type/crowningCore))- 24"
                />-->
                <xsl:value-of select="$Oy + 45"/>
            </xsl:attribute>
            <xsl:text>above</xsl:text>
        </text>
        <!--
        <xsl:call-template name="stuckOnX"/>-->
        <xsl:call-template name="boards-cover_above"/>
        <!-- Spine fader -->
        <mask xmlns="http://www.w3.org/2000/svg" id="fademask">
            <rect xmlns="http://www.w3.org/2000/svg" fill="url(#doubleFading4)" stroke="none"
                width="40" height="400" x="305" y="0"/>
        </mask>
        <rect xmlns="http://www.w3.org/2000/svg" fill="#FFFFFF" stroke="none" width="40"
            height="400" x="305" y="0" mask="url(#fademask)"/>
    </xsl:template>

    <xsl:template name="cores">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Front and back cores</xsl:text>
        </desc>
        <xsl:call-template name="boards-cover"/>
        <!-- Bookblock lines -->
        <path xmlns="http://www.w3.org/2000/svg" transform="rotate(90 225,80)"
            stroke="url(#fading2)" stroke-width="0.2" stroke-linecap="round" stroke-linejoin="round"
            fill="none">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 82"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225 + $panelHeight + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 82.0001"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg"
            transform="rotate(90 225,80) translate(0,-{$bookblockThickness * 2 + 4})"
            stroke="url(#fading2)" stroke-width="0.2" stroke-linecap="round" stroke-linejoin="round"
            fill="none">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 82"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225 + $panelHeight + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 82.0001"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" class="line4" stroke-linejoin="round">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 223"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80"/>
            </xsl:attribute>
        </path>
        <xsl:for-each select="cores/yes/cores/type">
            <xsl:variable name="coreHeight">
                <xsl:choose>
                    <xsl:when test="ancestor::endband/stuckOn/yes">
                        <xsl:value-of
                            select="if (crowningCore) then $Oy + 82 - (8 * position()) + 0.5 else $Oy + 82 - (8 * position()) - 2"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="if (crowningCore) then $Oy + 82 - (8 * position()) + 2 - 1.5 else $Oy + 82 - (8 * position()) - 4"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="ancestor::endband/stuckOn/yes">
                    <!-- do not draw cores -->
                </xsl:when>
                <xsl:otherwise>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#BEBEBE</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>none</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#000000</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>none</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$coreHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$coreHeight"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (crowningCore) then $Oy + 82 - (8 * position()) + 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0) else $Oy + 82 - (8 * position()) + 4"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (crowningCore) then $Oy + 82 - (8 * position())+ 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0) else $Oy + 82 - (8 * position()) + 4"
                                />
                            </xsl:attribute>
                            <!--<!-\- The schema does not specify the spatial relations between the cores: draw with uncertainty as to show uncertainty in the drawn typology  -\->
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>-->
                        </path>
                        <!-- Second path to form a complete closed line that can be filled with the sewing pattern -->
                        <xsl:choose>
                            <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                <!-- Do not fill with the sewing pattern -->
                            </xsl:when>
                            <xsl:when test="ancestor::endband/stuckOn/yes">
                                <!-- Do not fill with the sewing pattern -->
                            </xsl:when>
                            <xsl:otherwise>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                    stroke-width="0.2">
                                    <xsl:attribute name="fill">
                                        <xsl:call-template name="primarySewing_pattern"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$coreHeight"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$coreHeight"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="if (crowningCore) then $Oy + 82 - (8 * position()) + 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0) else $Oy + 82 - (8 * position()) + 4"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="if (crowningCore) then $Oy + 82 - (8 * position())+ 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0) else $Oy + 82 - (8 * position()) + 4"/>
                                        <xsl:text>z</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- Add Greek single core beading -->
                        <xsl:choose>
                            <xsl:when
                                test="(position() eq 1) and (ancestor::endband/primary/yes/construction/type/greekSingleCore)">
                                <path xmlns="http://www.w3.org/2000/svg" class="line4">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;M</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>z</xsl:text>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                    stroke-width="0.2" fill="#FFFFFF">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>z</xsl:text>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                    stroke-width="0.2" fill="url(#endband_pattern4)">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                        <xsl:text>z</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                    </g>
                    <xsl:call-template name="cores_boardAttachment"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:choose>
            <!-- NB: NEED TO CALL UNSUPPORTED WARPS ONLY SEWING -->
            <xsl:when test="cores[not(yes)] and primary/yes/construction/type/warpsOnly">
                <xsl:call-template name="sewing_warpsOnly"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="sewing_warpsOnly">
        <!-- Draw area to be filled with pattern -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2">
            <xsl:attribute name="fill">
                <xsl:call-template name="primarySewing_pattern"/>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 79"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 79"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80"/>
                <xsl:text>z</xsl:text>
            </xsl:attribute>
        </path>
        <!-- NB: The schema does not provide information regarding the option of unsupported warps only endband primary sewing extending onto the boards (see Boudalis 2007, fig. 20 p.35). -->
        <!--<xsl:choose>
            <xsl:when test="cores/yes/core/boardAttachment/yes/attachment[sewn | sewnAndRecessed]">
                <!-\- Draw area to be filled with pattern -\->
                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="1" stroke="red"
                    stroke-width="0.2">
                    <xsl:attribute name="fill">
                        <xsl:call-template name="primarySewing_pattern"/>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 79"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 132"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 79"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 132"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="1" stroke="red"
                    stroke-width="0.2">
                    <xsl:attribute name="fill">
                        <xsl:call-template name="primarySewing_pattern"/>
                    </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 79"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 79"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80"/>
                </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>-->
    </xsl:template>

    <xsl:template name="cores_boardAttachment">
        <xsl:choose>
            <xsl:when test="core">
                <xsl:choose>
                    <xsl:when
                        test="core/boardAttachment[no | NC | NK | other] or core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg" class="line4">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="core/boardAttachment[NC | NK | other] or core/boardAttachment/yes/attachment[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment[sewn | sewnAndRecessed]">
                        <!-- Draw cores and sewing pattern -->
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="stroke">
                                    <xsl:text>#000000</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="stroke-width">
                                    <xsl:text>0.2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor-or-self::endband/primary/yes/construction/type/warpsOnly">
                                            <xsl:text>#FFFFFF</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="primarySewing_pattern"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="stroke">
                                    <xsl:text>#000000</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="stroke-width">
                                    <xsl:text>0.2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor-or-self::endband/primary/yes/construction/type/warpsOnly">
                                            <xsl:text>#FFFFFF</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="primarySewing_pattern"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                </xsl:attribute>
                            </path>
                            <!-- Draw sewing pattern for warps only -->
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor-or-self::endband/primary/yes/construction/type/warpsOnly">
                                    <g xmlns="http://www.w3.org/2000/svg"
                                        id="warpsOnly_boardAttachmentSewing">
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 132 + 5"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132 + 5"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 152.6"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 152.6"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 168.2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 168.2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 183.8"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 183.8"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 199.4"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 199.4"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 70"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#warpsOnly_boardAttachmentSewing"
                                        transform="scale(-1,1) translate(-200,0)">
                                        <xsl:attribute name="transform">
                                            <xsl:text>scale(-1,1) translate(</xsl:text>
                                            <xsl:value-of
                                                select="-269 - 93 - $bookblockThickness * 2 - 93 + 5"/>
                                            <xsl:text>,0)</xsl:text>
                                        </xsl:attribute>
                                    </use>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when
                                    test="(position() eq 1) and (ancestor::endband/primary/yes/construction/type/greekDoubleCore)">
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#endband_pattern2_endingLeft"
                                        transform="translate(92,-82)"/>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#endband_pattern2_endingRight">
                                        <xsl:attribute name="transform">
                                            <xsl:text>translate(</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + 225 + $bookblockThickness * 2 + 45"/>
                                            <xsl:text>,-82)</xsl:text>
                                        </xsl:attribute>
                                    </use>
                                </xsl:when>
                                <xsl:when
                                    test="(position() eq 1) and (ancestor::endband/primary/yes/construction/type/greekSingleCore)">
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-width="0.2" fill="#FFFFFF">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="0.2" fill="url(#endband_pattern4)">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-width="0.2" fill="#FFFFFF">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="0.2" fill="url(#endband_pattern4)">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 2"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5.5"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                </xsl:when>
                            </xsl:choose>
                        </g>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment[adhered | laced]">
                        <!-- draw core up to the boards -->
                        <path xmlns="http://www.w3.org/2000/svg" class="line4"
                            id="core_adhered-laced_attachment_1">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Ox + 223"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Ox + 220"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 3"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Ox + 220"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 4.8"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Ox + 220"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 5"/>
                            </xsl:attribute>
                        </path>
                        <use xmlns="http://www.w3.org/2000/svg"
                            xlink:href="#core_adhered-laced_attachment_1">
                            <xsl:attribute name="transform">
                                <xsl:text>scale(-1,1) translate(</xsl:text>
                                <xsl:value-of select="- ($Ox + 440 + $bookblockThickness * 2 + 10)"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                        </use>
                        <!-- The path for the adhered/laced (only if with boards) core needs to be different for front and back views it is therefore drawn with the core_above_boardAttachment view and lowered -->
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/boards/no and ancestor::book/coverings/yes/cover/type/case/type/laceAttached">
                                <!-- The laced core front and back view are drawn without lacing to avoid the problem of the cover? -->
                                <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2"
                                    fill="none" stroke="url(#fading5)" id="endbandSlip">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) - 3"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 190"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 2"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 160"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 25"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 160"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 25.5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 190"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 15"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 5"/>
                                    </xsl:attribute>
                                </path>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#endbandSlip">
                                    <xsl:attribute name="transform">
                                        <xsl:text>scale(-1,1) translate(</xsl:text>
                                        <xsl:value-of
                                            select="- ($Ox + 450 + $bookblockThickness * 2)"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                </use>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="crowningCore">
                <xsl:choose>
                    <xsl:when
                        test="preceding-sibling::type/core/boardAttachment[no | NC | NK | other] or preceding-sibling::type/core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#BEBEBE</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>none</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class">
                                        <xsl:text>line4</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 - 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 + 1.5"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::type/core/boardAttachment[NC | NK | other] or preceding-sibling::type/core/boardAttachment/yes/attachment[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::type/core/boardAttachment/yes/attachment[sewn | sewnAndRecessed]">
                        <!-- add adhered? -->
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:choose>
                                    <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                        <xsl:attribute name="stroke">
                                            <xsl:text>#BEBEBE</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-width">
                                            <xsl:text>0.2</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="fill">
                                            <xsl:text>none</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="stroke">
                                            <xsl:text>#000000</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-width">
                                            <xsl:text>0.2</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="fill">
                                            <xsl:call-template name="primarySewing_pattern"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 - 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 - 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 82 - (8 * position()) + 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 82 - (8 * position())+ 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                    />
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:choose>
                                    <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                        <xsl:attribute name="stroke">
                                            <xsl:text>#BEBEBE</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-width">
                                            <xsl:text>0.2</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="fill">
                                            <xsl:text>none</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="stroke">
                                            <xsl:text>#000000</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-width">
                                            <xsl:text>0.2</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="fill">
                                            <xsl:call-template name="primarySewing_pattern"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 - 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 - 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 82 - (8 * position()) + 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 82 - (8 * position())+ 2 + 1.5 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                    />
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::type/core/boardAttachment/yes/attachment/laced">
                        <!-- Draw laced core? -->
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::type/core/boardAttachment/yes/attachment/adhered">
                        <!-- Draw pasted core?  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boardSewing">
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,40)">
            <!--<xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="50"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>-->
            <g xmlns="http://www.w3.org/2000/svg" id="boardAttachment_sewn_left">
                <g xmlns="http://www.w3.org/2000/svg">
                    <!-- NB: uncertainty here is due to the fact that the schema does not provide enough information regarding the sewing pattern for a truthful diagram to be drawn,
            however, should we need to indicate uncertainty regarding the board attachment itself by part of the surveyor the two uncertainties would overlap 
            (i.e uncertainty due to schema lacking information, and uncertainty of the surveyor). It would be necessary to diversify the two uncertainties and to make them cumulable.
            Solution 1: turn uncertainty due to schema into blurring shifting colour towards blue (blue having being used already for imprecision due to schema lacking measurements)
            and render the diagram very blurred (less than 50% certainty) when the two uncertainties overlap
            Solution 2: use sketchy lines for uncertainty due to schema? Talk to Alejandro re sketchy line solution and possibility of scripting within XSLT to render as sketchy lines 
            parametric drawings
            Solution 3: (IMPLEMENTED) fade the sewing lines to nothing and blur should the surveyor not be sure about the sewing-->
                    <!-- draw holes blurred as no indication of sewing pattern is given -->
                    <!--<g xmlns="http://www.w3.org/2000/svg" id="sewingHoles">
                        <circle xmlns="http://www.w3.org/2000/svg" r="2" cx="{$Ox + 132 + 5}"
                            cy="{$Oy + 80 + $tiedownLength}" class="line4"/>
                        <circle xmlns="http://www.w3.org/2000/svg" r="2"
                            cx="{$Ox + 132 + 5 + (if (ancestor-or-self::endband/primary/yes/construction/type/warpsOnly) then 34 else 42)}"
                            cy="{$Oy + 80 + $tiedownLength}" class="line4"/>
                    </g>
                    <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1,1) translate(-200,0)">
                        <xsl:attribute name="transform">
                            <xsl:text>scale(-1,1) translate(</xsl:text>
                            <xsl:value-of select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                            <xsl:text>,0)</xsl:text>
                        </xsl:attribute>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingHoles"/>
                    </g>-->
                    <xsl:choose>
                        <xsl:when
                            test="ancestor-or-self::endband/primary/yes/construction/type/warpsOnly">
                            <!--<circle id="thirdHole" xmlns="http://www.w3.org/2000/svg" r="2"
                                cx="{$Ox + 132 + 5 + 42 + 25}" cy="{$Oy + 80 + $tiedownLength}"
                                class="line4"/>
                            <g xmlns="http://www.w3.org/2000/svg"
                                transform="scale(-1,1) translate(-200,0)">
                                <xsl:attribute name="transform">
                                    <xsl:text>scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of
                                        select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#thirdHole"/>
                            </g>-->
                            <!-- draw sewing pattern blurred as no indication of sewing pattern is given -->
                            <g xmlns="http://www.w3.org/2000/svg" stroke="url(#fadingDownGrey2)"
                                stroke-width="0.5">
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132.0001 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 171"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 152.6"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 171"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 168.2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 183.8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 199.4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 215"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <!-- onto the other board -->
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 346"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 335"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 346"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 350.6"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 379"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 366.2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 379"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 381.8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 413"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 397.4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 413"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 413"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                            </g>
                            <!-- Redraw the holes for the back view -->
                            <!-- Draw the sewing pattern for the back view -->
                            <g xmlns="http://www.w3.org/2000/svg" stroke="url(#fadingDownGrey2)"
                                stroke-width="0.5">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="$Oy + $panelHeight + 80"/>
                                    <xsl:text>) scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of select="-(450 + ($bookblockThickness * 2))"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <!--
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingHoles"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#thirdHole"/>-->
                                <g xmlns="http://www.w3.org/2000/svg"
                                    transform="scale(-1,1) translate(-200,0)">
                                    <xsl:attribute name="transform">
                                        <xsl:text>scale(-1,1) translate(</xsl:text>
                                        <xsl:value-of
                                            select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                    <!--
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#sewingHoles"/>
                                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#thirdHole"
                                    />-->
                                </g>
                                <!-- draw sewing pattern blurred as no indication of sewing pattern is given -->
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132.0001 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 137"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 152.6"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 171"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 168.2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 171"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 183.8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 199.4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 215"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 204"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 227"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <!-- onto the other board -->
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 323"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 335"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 346"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 350.6"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 346"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 366.2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 379"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 381.8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 379"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 397.4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 413"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 413"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 78"/>
                                    </xsl:attribute>
                                </path>
                            </g>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- draw sewing pattern blurred as no indication of sewing pattern is given -->
                            <g xmlns="http://www.w3.org/2000/svg" id="boardSewingPattern"
                                stroke="url(#fadingDownGrey2)" stroke-width="0.5">
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132.0001 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                        />
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 18"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                        />
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 18"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                        />
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132.0001 + 5 + 42"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                        />
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>L</xsl:text>
                                        <xsl:value-of select="$Ox + 132 + 5 + 66"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                        />
                                    </xsl:attribute>
                                </path>
                            </g>
                            <g xmlns="http://www.w3.org/2000/svg"
                                transform="scale(-1,1) translate(-200,0)">
                                <xsl:attribute name="transform">
                                    <xsl:text>scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of
                                        select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#boardSewingPattern"/>
                            </g>
                            <!-- other sewing in -->
                            <g xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="$Oy + $panelHeight + 80"/>
                                    <xsl:text>) scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of select="-(450 + ($bookblockThickness * 2))"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <!--
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingHoles"/>-->
                                <g xmlns="http://www.w3.org/2000/svg"
                                    transform="scale(-1,1) translate(-200,0)">
                                    <xsl:attribute name="transform">
                                        <xsl:text>scale(-1,1) translate(</xsl:text>
                                        <xsl:value-of
                                            select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                    <!--
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#sewingHoles"/>
                                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#thirdHole"
                                    />-->
                                </g>
                                <!-- draw sewing pattern blurred as no indication of sewing pattern is given -->
                                <g xmlns="http://www.w3.org/2000/svg" id="boardSewingPattern2"
                                    stroke="url(#fadingDownGrey2)" stroke-width="0.5">
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                            <xsl:text>L</xsl:text>
                                            <xsl:value-of select="$Ox + 132.0001 + 5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                            <xsl:text>L</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 18"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                            <xsl:text>L</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 18"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                            <xsl:text>L</xsl:text>
                                            <xsl:value-of select="$Ox + 132.0001 + 5 + 42"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 42"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                            <xsl:text>L</xsl:text>
                                            <xsl:value-of select="$Ox + 132 + 5 + 66"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + (if (ancestor-or-self::endband/primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                            />
                                        </xsl:attribute>
                                    </path>
                                </g>
                                <g xmlns="http://www.w3.org/2000/svg"
                                    transform="scale(-1,1) translate(-200,0)">
                                    <xsl:attribute name="transform">
                                        <xsl:text>scale(-1,1) translate(</xsl:text>
                                        <xsl:value-of
                                            select="-268 - 93 - $bookblockThickness * 2 - 93 + 4"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#boardSewingPattern2"/>
                                </g>
                            </g>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
            </g>
        </g>
    </xsl:template>

    <xsl:template name="boards-cover_above">
        <!-- add quire profiles -->
        <xsl:variable name="numberOfQuires" select="17"/>
        <xsl:call-template name="recursiveQuireAbove">
            <xsl:with-param name="counter" select="$numberOfQuires"/>
        </xsl:call-template>
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(0,-20)">
            <xsl:choose>
                <xsl:when
                    test="ancestor::book/boards/no and ancestor::book/coverings/yes/cover/type/case/type/laceAttached">
                    <!-- Draw the covering so to lace the endbands through  -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)"
                        stroke-width="0.5" stroke-linecap="round" stroke-linejoin="round"
                        fill="none" id="cover_above">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="130"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 30"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 83"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 136"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 83.0001"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Ox + 140"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ox + 141"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 75"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Ox + 141"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + (if (stuckOn/yes) then 67 else 69)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ox + 146"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + (if (stuckOn/yes) then 67 else 69)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 146 + $bookblockThickness"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + (if (stuckOn/yes) then 67 else 69)"/>
                        </xsl:attribute>
                    </path>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#cover_above">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Ox + 540 + $bookblockThickness * 2 + 10"/>
                            <xsl:text>,0) scale(-1,1)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:when>
                <xsl:otherwise>
                    <!-- draw the boards as references -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)"
                        stroke-width="0.5" stroke-linecap="round" stroke-linejoin="round"
                        fill="none" id="boards_above">
                        <xsl:attribute name="transform">
                            <!--<xsl:choose>
                                <xsl:when
                                    test="cores/yes/cores/type/core/boardAttachment/yes/attachment/laced/tunnel[no | NC | NK | other]">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="- $boardThickness"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>-->
                            <xsl:choose>
                                <xsl:when
                                    test="cores[no | NK | NC | other | yes/cores/type/core/boardAttachment[no | NC | NK | other | NA | yes[attachment[sewn | sewnAndRecessed | cutAtJoint]]]] or stuckOn[following-sibling::cores/yes/cores/type/core/boardAttachment[no | NC | NK | other | NA | yes[attachment[sewn | sewnAndRecessed | cutAtJoint]]]]/yes">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="- $boardThickness"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="cores/yes/cores/type/core/boardAttachment/yes/attachment/laced/tunnel/yes">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="- $boardThickness + 1.5"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="- ($boardThickness div 4)"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 30"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 140"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80.0001"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 140"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="if (ancestor::book/boards/no) then $Oy + 80.0001 + 5 else $Oy + 80.0001 + $boardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 30"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="if (ancestor::book/boards/no) then $Oy + 80.0001 + 5 else $Oy + 80.0001 + $boardThickness"/>
                            <xsl:choose>
                                <xsl:when
                                    test="cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 50"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 50"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="if (ancestor::book/boards/no) then $Oy + 80.0001 + 5 else $Oy + 80.0001 + $boardThickness"
                                    />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </path>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#boards_above">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Ox + 540 + $bookblockThickness * 2 + 10"/>
                            <xsl:text>,0) scale(-1,1)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="cores/yes and ancestor::endband/stuckOn/yes/folded/not(yes)">
                    <xsl:for-each select="cores/yes/cores/type">
                        <xsl:call-template name="cores_above">
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                        <xsl:call-template name="cores_above_boardAttachment"/>
                        <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)"
                            stroke="#FFFFFF" stroke-opacity="0" fill="red">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 6"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="cores/yes">
                    <xsl:for-each select="cores/yes/cores/type">
                        <xsl:call-template name="cores_above">
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                        <xsl:call-template name="cores_above_boardAttachment"/>
                    </xsl:for-each>
                </xsl:when>
                <!-- NB: NEED TO CALL UNSUPPORTED WARPS ONLY SEWING -->
                <xsl:when test="cores[not(yes)] and primary/yes/construction/type/warpsOnly">
                    <!-- draw areas to be filled -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2"
                        transform="translate(50,0)">
                        <xsl:attribute name="fill">
                            <xsl:call-template name="primarySewing_pattern"/>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 10"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 227 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 10"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 227  + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 7"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <!-- if sewn on boards draw -->
                </xsl:when>
            </xsl:choose>
            <!-- Tiedowns are called here and drawn on the front and back view as they need to be different according to the view -->
            <xsl:call-template name="numberOfTiedowns"/>
        </g>
    </xsl:template>

    <xsl:template name="recursiveQuireAbove">
        <xsl:param name="counter" select="17"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#quire_above"
            x="{$Ox + 224 + 50 + (6 * ($counter - 1))}" y="{$Oy + 80 - 26}"/>
        <xsl:choose>
            <xsl:when test="$counter gt 1">
                <xsl:call-template name="recursiveQuireAbove">
                    <xsl:with-param name="counter" select="$counter - 1"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template name="cores_above">
        <xsl:param name="boardThickness"/>
        <xsl:choose>
            <xsl:when test=".[core | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test=".[NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <!-\-<xsl:choose>
                        <xsl:when test="position() eq 1">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2"
                                stroke-opacity="0" fill="#FFFFFF" fill-opacity="1"
                                transform="translate(50,0)">
                                <xsl:choose>
                                    <xsl:when test="ancestor::endband/stuckOn/yes/folded/yes">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 1</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 223"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 227 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 227 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 223"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>-\->
                    <path xmlns="http://www.w3.org/2000/svg" stroke="#000000" stroke-width="0.2"
                        fill="#FFFFFF" fill-opacity="1" transform="translate(50,0)">
                        <xsl:choose>
                            <xsl:when test="ancestor::endband/stuckOn/yes/folded/yes">
                                <xsl:attribute name="stroke-dasharray">
                                    <xsl:text>1 1</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 9"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 9"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2"
                        transform="translate(50,0)">
                        <xsl:attribute name="fill">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                    <!-\-  -\->
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/numberOfTiedowns/every">
                                            <xsl:text>url(#endband_pattern3)</xsl:text>
                                        </xsl:when>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/numberOfTiedowns[frequent | NK | NC]">
                                            <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                                        </xsl:when>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/numberOfTiedowns/infrequent">
                                            <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="ancestor::endband/stuckOn/yes">
                                    <!-\- Do not fill with the sewing pattern -\->
                                    <xsl:text>none</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>url(#endband_pattern1)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 9"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 9"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 - 1"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test=".[crowningCore]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2" fill="#FFFFFF"
                    fill-opacity="0.5" stroke-opacity="0" transform="translate(50,0)">
                    <xsl:choose>
                        <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                            <xsl:attribute name="fill-opacity">
                                <xsl:value-of select="0.5"/>
                            </xsl:attribute>
                            <xsl:attribute name="fill">
                                <xsl:text>#FFFFFF</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="fill-opacity">
                                <xsl:value-of select="1"/>
                            </xsl:attribute>
                            <xsl:attribute name="fill">
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                        <xsl:text>url(#endband_pattern3)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>url(#endband_pattern1)</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 - 7"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 - 7"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2" fill="#FFFFFF"
                    fill-opacity="0.5" transform="translate(50,0)">
                    <xsl:choose>
                        <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                            <xsl:attribute name="stroke">
                                <xsl:text>#BEBEBE</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="stroke">
                                <xsl:text>#000000</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 - 7"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 - 7"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-\- Add the beads for the front view of the frontBead primary sewing.
            It's drawn here because these need to be drawn on top of the rest of the diagram and need to to be drawn in the spine view. -\->
        <xsl:choose>
            <xsl:when test="ancestor::endband/primary/yes/construction/type/frontBead">
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,40)">
                    <path xmlns="http://www.w3.org/2000/svg" class="line4">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2"
                        fill="#FFFFFF">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2"
                        fill="url(#endband_pattern5)">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 225"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>-->

    <xsl:template name="cores_above">
        <xsl:param name="boardThickness"/>
        <xsl:choose>
            <xsl:when test="ancestor::endband/stuckOn/yes"> </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test=".[core | NK | other]">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test=".[NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="position() eq 1">
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2"
                                        stroke-opacity="0" fill="#FFFFFF" fill-opacity="1"
                                        transform="translate(50,0)">
                                        <xsl:choose>
                                            <xsl:when
                                                test="ancestor::endband/stuckOn/yes/folded/yes">
                                                <xsl:attribute name="stroke-dasharray">
                                                  <xsl:text>1 1</xsl:text>
                                                </xsl:attribute>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 223"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 9"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + 227 + $bookblockThickness * 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 9"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + 227 + $bookblockThickness * 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 1"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 223"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 1"/>
                                            <xsl:text>z</xsl:text>
                                        </xsl:attribute>
                                    </path>
                                </xsl:when>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                stroke-width="0.2" fill="#FFFFFF" fill-opacity="1"
                                transform="translate(50,0)">
                                <xsl:choose>
                                    <xsl:when test="ancestor::endband/stuckOn/yes/folded/yes">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 1</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                stroke-width="0.2" transform="translate(50,0)">
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                            <!--  -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/every">
                                                  <xsl:text>url(#endband_pattern3)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns[frequent | NK | NC]">
                                                  <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/infrequent">
                                                  <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="ancestor::endband/stuckOn/yes">
                                            <!-- Do not fill with the sewing pattern -->
                                            <xsl:text>none</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#endband_pattern1)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test=".[crowningCore]">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2" fill="#FFFFFF"
                            fill-opacity="0.5" stroke-opacity="0" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="fill-opacity">
                                        <xsl:value-of select="0.5"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>#FFFFFF</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="fill-opacity">
                                        <xsl:value-of select="1"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:choose>
                                            <xsl:when
                                                test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                                <xsl:text>url(#endband_pattern3)</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>url(#endband_pattern1)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2" fill="#FFFFFF"
                            fill-opacity="0.5" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#BEBEBE</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#000000</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <!-- Add the beads for the front view of the frontBead primary sewing.
            It's drawn here because these need to be drawn on top of the rest of the diagram and need to to be drawn in the spine view. -->
                <xsl:choose>
                    <xsl:when test="ancestor::endband/primary/yes/construction/type/frontBead">
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,40)">
                            <path xmlns="http://www.w3.org/2000/svg" class="line4">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                stroke-width="0.2" fill="#FFFFFF">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                stroke-width="0.2" fill="url(#endband_pattern5)">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - 8 + 4"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cores_above_boardAttachment">
        <xsl:choose>
            <xsl:when test=".[core | NK | other]">
                <xsl:choose>
                    <xsl:when
                        test="core/boardAttachment[no | NC | NK | other] or cores/yes/cores/type/core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other] or .[NK | other]">
                        <xsl:choose>
                            <xsl:when test="ancestor::endband/stuckOn/yes">
                                <!-- nothing -->
                            </xsl:when>
                            <xsl:otherwise>
                                <path xmlns="http://www.w3.org/2000/svg" class="line4"
                                    transform="translate(50,0)">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 9"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1"/>
                                        <xsl:text>&#32;M</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 9"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1"/>
                                    </xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when
                                            test="core/boardAttachment[NC | NK | other] or cores/yes/cores/type/core/boardAttachment/yes/attachment[NC | NK | other] or .[NK | other]">
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="50"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                    </xsl:choose>
                                </path>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment[sewn | sewnAndRecessed]">
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                stroke-width="0.2" fill="#FFFFFF">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                stroke-width="0.2">
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                            <!--  -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/every">
                                                  <xsl:text>url(#endband_pattern3)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns[frequent | NK | NC]">
                                                  <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/infrequent">
                                                  <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#endband_pattern1)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" strok-opacity="0"
                                stroke-width="0.2" fill="#FFFFFF">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                stroke-width="0.2">
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                            <!--  -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/every">
                                                  <xsl:text>url(#endband_pattern3)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns[frequent | NK | NC]">
                                                  <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                                                </xsl:when>
                                                <xsl:when
                                                  test="ancestor::endband/primary/yes/numberOfTiedowns/infrequent">
                                                  <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:text>none</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#endband_pattern1)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <!-- Add sewing to boards pattern here for front and back views of warpsOnly endbands as these need to be different -->
                        <xsl:choose>
                            <xsl:when test="position() eq 1">
                                <!-- call template to draw board sewing -->
                                <xsl:call-template name="boardSewing"/>
                            </xsl:when>
                        </xsl:choose>
                        <!-- Add the beads for the front view of the frontBead primary sewing.
            It's drawn here because these need to be drawn on top of the rest of the diagram and need to to be drawn in the spine view. -->
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::endband/primary/yes/construction/type/frontBead">
                                <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,40)">
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-width="0.2" fill="#FFFFFF">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="0.2" fill="url(#endband_pattern5)">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-width="0.2" fill="#FFFFFF">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="0.2" fill="url(#endband_pattern5)">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 3"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Ox + 225 + $bookblockThickness * 2"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 82 - 8 + 5"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                </g>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment/laced">
                        <!-- mmm -->
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/boards/no and ancestor::book/coverings/yes/cover/type/case/type/laceAttached">
                                <!-- Draw the path for the lacing in through a limp cover -->
                                <xsl:choose>
                                    <xsl:when test="ancestor::endband/stuckOn/yes">
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke="url(#fading4)" stroke-width="0.2" fill="#FFFFFF"
                                            transform="translate(50,0)" id="lacedThroughCover">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 7.5"/>
                                                <!--<!-\-
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 224"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 2"/>-\->
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 3"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 3"/>-->
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 218"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 2"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 213"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 185"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 170"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 212"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 4"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 220"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 8"/>
                                                <!--
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 6"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 7.5"/>-->
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 224"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11"/>
                                            </xsl:attribute>
                                        </path>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke="url(#fading4)" stroke-width="0.2" fill="#FFFFFF"
                                            transform="translate(50,0)" id="lacedThroughCover">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 1"/>
                                                <!--<!-\-
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 224"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 2"/>-\->
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 3"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 3"/>-->
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 218"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 2"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 213"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 185"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 170"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83.5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 212"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 83"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 4"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 220"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 6"/>
                                                <!--
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 6"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 7.5"/>-->
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 224"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 9"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 9"/>
                                            </xsl:attribute>
                                        </path>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#lacedThroughCover">
                                    <xsl:attribute name="transform">
                                        <xsl:text>scale(-1,1) translate(</xsl:text>
                                        <xsl:value-of
                                            select="- ($Ox + 450 + $bookblockThickness * 4)"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                </use>
                            </xsl:when>
                            <xsl:when
                                test="core/boardAttachment/yes/attachment/laced/tunnel[no | yes | NC | NK | other | NA]">
                                <xsl:choose>
                                    <xsl:when
                                        test="core/boardAttachment/yes/attachment/laced/tunnel[no | NC | NK | other | NA]">
                                        <g xmlns="http://www.w3.org/2000/svg">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="core/boardAttachment/yes/attachment/laced/tunnel[NC | NK | other | NA]">
                                                  <xsl:call-template name="certainty">
                                                  <xsl:with-param name="certainty" select="50"/>
                                                  <xsl:with-param name="type" select="'3'"/>
                                                  </xsl:call-template>
                                                </xsl:when>
                                            </xsl:choose>
                                            <g xmlns="http://www.w3.org/2000/svg" id="lacedNoTunnel">
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  stroke="url(#fading4)" stroke-width="0.2"
                                                  fill="#FFFFFF" transform="translate(50,0)">
                                                  <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of select="$Ox + 225"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 1"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 224"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 1"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 223"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 222"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 220"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 88"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 90"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 208"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 90"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 185"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 88"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 180"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 88"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 88"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 87.5"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 6"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 225"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 9"/>
                                                  </xsl:attribute>
                                                </path>
                                            </g>
                                            <use xmlns="http://www.w3.org/2000/svg"
                                                xlink:href="#lacedNoTunnel">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>scale(-1,1) translate(</xsl:text>
                                                  <xsl:value-of
                                                  select="- ($Ox + 450 + $bookblockThickness * 4)"/>
                                                  <xsl:text>,0)</xsl:text>
                                                </xsl:attribute>
                                            </use>
                                        </g>
                                    </xsl:when>
                                    <xsl:when
                                        test="core/boardAttachment/yes/attachment/laced/tunnel[yes]">
                                        <g xmlns="http://www.w3.org/2000/svg" id="lacedNoTunnel">
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke="#FFFFFF" stroke-width="0.5" fill="#FFFFFF"
                                                transform="translate(50,0)">
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of select="$Ox + 223"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 9"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 9"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 223"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>z</xsl:text>
                                                </xsl:attribute>
                                            </path>
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke="#000000" stroke-width="0.5" fill="#FFFFFF"
                                                transform="translate(50,0)">
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 8.75"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 220.25"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                </xsl:attribute>
                                            </path>
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke="url(#fading4)" stroke-width="0.2"
                                                fill="#FFFFFF" transform="translate(50,0)">
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of select="$Ox + 225"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 1"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 224"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 1"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 223"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 222"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 220"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 3"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 2.5"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 82"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 210"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 84"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 208"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 84"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 185"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 82"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 170"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 82"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 206"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 82"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 82"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 4"/>
                                                  <xsl:text>&#32;Q</xsl:text>
                                                  <xsl:value-of select="$Ox + 207"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 9"/>
                                                  <xsl:text>&#32;</xsl:text>
                                                  <xsl:value-of select="$Ox + 225"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 9"/>
                                                </xsl:attribute>
                                            </path>
                                        </g>
                                        <use xmlns="http://www.w3.org/2000/svg"
                                            xlink:href="#lacedNoTunnel">
                                            <xsl:attribute name="transform">
                                                <xsl:text>scale(-1,1) translate(</xsl:text>
                                                <xsl:value-of
                                                  select="- ($Ox + 450 + $bookblockThickness * 4)"/>
                                                <xsl:text>,0)</xsl:text>
                                            </xsl:attribute>
                                        </use>
                                    </xsl:when>
                                </xsl:choose>
                                <!-- Since the front and back views need to be different the paths for those views are drawn here and lowered onto the right view -->
                                <g xmlns="http://www.w3.org/2000/svg" id="laced_part2_solidLine">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of select="50"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 40 + $panelHeight + 80"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                    <g xmlns="http://www.w3.org/2000/svg" id="laced_part2">
                                        <path xmlns="http://www.w3.org/2000/svg" class="line4">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 220"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) - 3"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 218"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) - 3"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 206"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) + 6"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>&#32;M</xsl:text>
                                                <xsl:value-of select="$Ox + 220"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) + 5"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 218"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) + 5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 215"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 81"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#laced_part2">
                                        <xsl:attribute name="transform">
                                            <xsl:text>scale(-1,1) translate(</xsl:text>
                                            <xsl:value-of
                                                select="- ($Ox + 440 + $bookblockThickness * 2 + 10)"/>
                                            <xsl:text>,0)</xsl:text>
                                        </xsl:attribute>
                                    </use>
                                </g>
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#laced_part2_solidLine" stroke-dasharray="2 2">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(0,</xsl:text>
                                        <xsl:value-of select="- ($Oy + $panelHeight + 80)"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </use>
                                <g xmlns="http://www.w3.org/2000/svg" id="laced_part3_solidLine">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of select="50"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 40"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                    <g xmlns="http://www.w3.org/2000/svg" id="laced_part3">
                                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2"
                                            stroke="url(#fading5)" fill="none">
                                            <xsl:attribute name="d">
                                                <xsl:text>&#32;M</xsl:text>
                                                <xsl:value-of select="$Ox + 206"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + 82 - (8 * position()) + 6"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 185"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 96"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 190"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 100"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 210"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 85"/>
                                                <xsl:text>z</xsl:text>
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#laced_part3">
                                        <xsl:attribute name="transform">
                                            <xsl:text>scale(-1,1) translate(</xsl:text>
                                            <xsl:value-of
                                                select="- ($Ox + 440 + $bookblockThickness * 2 + 10)"/>
                                            <xsl:text>,0)</xsl:text>
                                        </xsl:attribute>
                                    </use>
                                </g>
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#laced_part3_solidLine" stroke-dasharray="2 2">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(0,</xsl:text>
                                        <xsl:value-of select="$Oy + $panelHeight + 80"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </use>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment/adhered">
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)"
                            id="adhered_above">
                            <path xmlns="http://www.w3.org/2000/svg" class="line4">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 175"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 1"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Ox + 220"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$Ox + 215"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 175"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="none"
                                fill="url(#endband_pattern2)">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 215"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 175"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 175"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 3"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 215"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 3"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </g>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#adhered_above">
                            <xsl:attribute name="transform">
                                <xsl:text>scale(-1,1) translate(</xsl:text>
                                <xsl:value-of select="- ($Ox + 440 + $bookblockThickness * 4 + 10)"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                        </use>
                        <!-- Since the front and back views need to be different the paths for those views are drawn here and lowered onto the right view -->
                        <g xmlns="http://www.w3.org/2000/svg" id="adhered_fullLine">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="50"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 40 + $panelHeight + 80"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <g xmlns="http://www.w3.org/2000/svg" id="adhered">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="100"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                                <path xmlns="http://www.w3.org/2000/svg" class="line4">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) - 3"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 215"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) - 2"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 210"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position())"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 200"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 180"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82"/>
                                        <xsl:text>&#32;M</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 215"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82 - (8 * position()) + 5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 210"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 200"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 92"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 190"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 97"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 185"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 92"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 180"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 82"/>
                                    </xsl:attribute>
                                </path>
                                <!--<g xmlns="http://www.w3.org/2000/svg" id="frayingGroup">
                                    <path xmlns="http://www.w3.org/2000/svg"
                                        stroke="url(#doubleFading3)" stroke-width="0.1"
                                        id="frayingLine">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 200"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 85"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 185"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 97"/>
                                        </xsl:attribute>
                                    </path>
                                    <use xlink:href="#frayingLine" transform="rotate(5 200,85)"/>
                                    <use xlink:href="#frayingLine" transform="rotate(10 200,85)"/>
                                    <use xlink:href="#frayingLine" transform="rotate(15 200,85)"/>
                                    <use xlink:href="#frayingLine" transform="rotate(20 200,85)"/>
                                    <use xlink:href="#frayingLine" transform="rotate(25 200,85)"/>
                                </g>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="translate(-1,-1)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="translate(-2,-2)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="translate(-3,-3)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="translate(-4,-4)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="rotate(5 200,85)translate(-5,-5)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="rotate(-3 200,85)translate(1,1)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="rotate(-5 200,85)translate(2,2)"/>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frayingGroup"
                                    transform="rotate(-6 200,85)translate(3,3)"/>-->
                            </g>
                            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#adhered">
                                <xsl:attribute name="transform">
                                    <xsl:text>scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of
                                        select="- ($Ox + 440 + $bookblockThickness * 2 + 10)"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                            </use>
                        </g>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#adhered_fullLine"
                            stroke-dasharray="2 2">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="-($Oy + $panelHeight + 80)"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test=".[crowningCore]">
                <xsl:choose>
                    <xsl:when
                        test=".[crowningCore]/preceding-sibling::type/core/boardAttachment[no | NC | NK | other] or .[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#BEBEBE</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>none</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class">
                                        <xsl:text>line4</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                />
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test=".[crowningCore]/preceding-sibling::type/core/boardAttachment[NC | NK | other] or .[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when
                        test=".[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[sewn | sewnAndRecessed ]">
                        <!-- add adhered? -->
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when test="crowningCore/sewnType/sewnWithSecondary">
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#BEBEBE</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill-opacity">
                                        <xsl:value-of select="0.5"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:text>#FFFFFF</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="stroke">
                                        <xsl:text>#000000</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke-width">
                                        <xsl:text>0.2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill-opacity">
                                        <xsl:value-of select="1"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="fill">
                                        <xsl:choose>
                                            <xsl:when
                                                test="ancestor::endband/primary/yes/construction/type/warpsOnly">
                                                <xsl:text>url(#endband_pattern3)</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>url(#endband_pattern1)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                    />
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2 + 93"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 - 4 - (if (crowningCore/sewnType/sewnWithSecondary) then 1 else 0)"
                                    />
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                    <xsl:when
                        test=".[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment/laced">
                        <!-- Draw laced core:  -->
                    </xsl:when>
                    <xsl:when
                        test=".[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment/adhered">
                        <!-- Draw adhered core:  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boards-cover">
        <xsl:choose>
            <xsl:when test="ancestor::book/boards/no">
                <xsl:choose>
                    <xsl:when test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached">
                        <!-- Draw the covering so to lace the endbands throug? What of the back view through the cover? -->
                        <!--<g xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox + 260"/>
                                <xsl:text>,</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="stuckOn/yes">
                                        <xsl:value-of
                                            select="if (cores/yes) then - 11 * count(cores/yes/cores/type) + 3 * count(cores/yes/cores/type/crowningCore) else - 11"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="if (cores/yes) then - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>) scale(-1,1)</xsl:text>
                            </xsl:attribute>
                            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                            <xsl:call-template name="panelHeight">
                                <xsl:with-param name="scale" select="'2:1'"/>
                            </xsl:call-template>
                        </g>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox + 190 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="stuckOn/yes">
                                        <xsl:value-of
                                            select="if (cores/yes) then - 11 * count(cores/yes/cores/type) + 3 * count(cores/yes/cores/type/crowningCore) else - 11"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="if (cores/yes) then - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                            <xsl:call-template name="panelHeight">
                                <xsl:with-param name="scale" select="'2:1'"/>
                            </xsl:call-template>
                        </g>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Do not draw the reference boards -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::book/boards/yes/boards/board/formation/size[sameSize | undersize]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox + 260"/>
                        <xsl:text>,0) scale(-1,1)</xsl:text>
                    </xsl:attribute>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                    <xsl:call-template name="panelHeight">
                        <xsl:with-param name="scale" select="'2:1'"/>
                    </xsl:call-template>
                </g>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox + 190 + $bookblockThickness * 2"/>
                        <xsl:text>,0)</xsl:text>
                    </xsl:attribute>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                    <xsl:call-template name="panelHeight">
                        <xsl:with-param name="scale" select="'2:1'"/>
                    </xsl:call-template>
                </g>
            </xsl:when>
            <xsl:when
                test="ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::book/boards/yes/boards/board/formation/size[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when
                            test="cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed">
                            <g id="board_sewnAndRecessed" stroke="url(#fading)" stroke-width="0.5"
                                stroke-linecap="round" stroke-linejoin="round" fill="none"
                                transform="translate(80,0)">
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 30"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="if (cores/yes) then $Oy + 80 - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 50"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="if (cores/yes) then $Oy + 80 - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 50"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 140"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                    </xsl:attribute>
                                </path>
                                <g xmlns="http://www.w3.org/2000/svg" transform="translate(100,0)">
                                    <xsl:call-template name="panelHeight">
                                        <xsl:with-param name="scale" select="'2:1'"/>
                                    </xsl:call-template>
                                </g>
                            </g>
                            <use xmlns="http://www.w3.org/2000/svg"
                                xlink:href="#board_sewnAndRecessed">
                                <xsl:attribute name="transform">
                                    <xsl:text>scale(-1,1) translate(</xsl:text>
                                    <xsl:value-of select="$Ox - 450 - $bookblockThickness * 2"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                            </use>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Boards with squares -->
                            <g xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Ox + 260"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="stuckOn/yes">
                                            <xsl:value-of
                                                select="if (cores/yes) then - 5 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else - 5"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="if (cores/yes) then - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>) scale(-1,1)</xsl:text>
                                </xsl:attribute>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                                <xsl:call-template name="panelHeight">
                                    <xsl:with-param name="scale" select="'2:1'"/>
                                </xsl:call-template>
                            </g>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Ox + 190 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="stuckOn/yes">
                                            <xsl:value-of
                                                select="if (cores/yes) then - 5 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else - 5"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="if (cores/yes) then - 8 * count(cores/yes/cores/type) - 2 + 4 * count(cores/yes/cores/type/crowningCore) else - 9"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#board"/>
                                <xsl:call-template name="panelHeight">
                                    <xsl:with-param name="scale" select="'2:1'"/>
                                </xsl:call-template>
                            </g>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="primarySewing">
        <xsl:choose>
            <xsl:when test="primary[NC | NK]">
                <!-- A drawing cannot be done -->
                <desc xmlns="http://www.w3.org/2000/svg">Presence of primary sewing could not be
                    identified</desc>
            </xsl:when>
            <xsl:when test="primary/no">
                <!-- A drawing cannot be done -->
                <desc xmlns="http://www.w3.org/2000/svg">Primary sewing not present</desc>
            </xsl:when>
            <xsl:when test="primary/yes">
                <xsl:choose>
                    <xsl:when test="primary/yes/construction/type[NC | NK]">
                        <!-- A drawing cannot be done -->
                        <desc xmlns="http://www.w3.org/2000/svg">Primary sewing could not be
                            identified</desc>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/other">
                        <!-- A drawing cannot be done -->
                        <desc xmlns="http://www.w3.org/2000/svg">Primary sewing not covered by
                            schema</desc>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/noBead">
                        <!--  -->
                        <xsl:call-template name="sewing_noBeadX"/>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/frontBead">
                        <!--  -->
                        <xsl:call-template name="sewing_frontBeadX"/>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type[noFrontBead | reversingTwist]">
                        <!-- Same drawing, but in case of noFrontBead, the reversing twist part should be made uncertain -->
                        <xsl:call-template name="sewing_noFrontBeadX-reversingTwistX"/>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/greekSingleCore">
                        <!--  -->
                        <xsl:call-template name="sewing_greekSingleCoreX"/>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/greekDoubleCore">
                        <!--  -->
                        <xsl:call-template name="sewing_greekDoubleCoreX"/>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/warpsOnly">
                        <!--  -->
                        <xsl:call-template name="sewing_warpsOnlyX"/>
                    </xsl:when>
                </xsl:choose>
                <!-- Sewing through the bookblock common to all types apart from greekDoubleCore -->
                <xsl:choose>
                    <xsl:when test="primary/yes/construction/type[NC | NK | other]">
                        <!-- do not draw the thread path in the cross-section view: the path was not identified -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Draw the thread path inside the bookblock -->
                        <g xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <path xmlns="http://www.w3.org/2000/svg" class="line">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLengthX - ($tiedownLengthX div 4)"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Ox + 38"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + $tiedownLengthX"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$Ox + 46"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + $tiedownLengthX"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                marker-end="url(#arrowSymbol)">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLengthX - ($tiedownLengthX div 4)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + ($tiedownLengthX div 2)"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + ($tiedownLengthX div 2)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <!--<xsl:choose>
                            <xsl:when test="primary/yes/construction/type/warpsOnly">
                                <g xmlns="http://www.w3.org/2000/svg" stroke-dasharray="2 2.5"
                                    stroke-linecap="round">
                                    <path xmlns="http://www.w3.org/2000/svg" class="line"
                                        marker-mid="url(#arrowSymbol)">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 58"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 58"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + ($tiedownLengthX + 3) div 2"/><!-\-
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 40"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 + $tiedownLengthX + 3"/>-\->
                                        </xsl:attribute>
                                    </path>
                                </g>
                            </xsl:when>
                            <xsl:otherwise>-->
                        <g xmlns="http://www.w3.org/2000/svg" stroke-dasharray="2 2.5"
                            stroke-linecap="round">
                            <path xmlns="http://www.w3.org/2000/svg" class="line">
                                <xsl:attribute name="marker-end">
                                    <xsl:choose>
                                        <xsl:when test="primary/yes/construction/type/frontBead">
                                            <xsl:text>url(#arrowSymbol_-90)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#arrowSymbol)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 58"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 58"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + ($tiedownLengthX div 2)"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 58"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + ($tiedownLengthX div 2)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 58"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLengthX - ($tiedownLengthX div 4)"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Ox + 58"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + $tiedownLengthX"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$Ox + 46"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 + $tiedownLengthX"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <!--</xsl:otherwise>
                        </xsl:choose>-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewing_noBeadX">
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#noBeadX_1"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#noBead_1_detail"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#noBead_1_detail_back"
            transform="translate(35,0)"/>
        <xsl:for-each select="cores/yes/cores/type/core">
            <xsl:choose>
                <xsl:when test="position() gt 1">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="position() mod 2 eq 0">
                                    <xsl:text>#noBeadX_2_even</xsl:text>
                                </xsl:when>
                                <xsl:when test="position() mod 2 eq 1">
                                    <xsl:text>#noBeadX_2_odd</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(32,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 0">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_even</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 1">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_odd</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(35,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="sewing_noBead">
        <!--  -->
        <xsl:call-template name="sewing_noBead_above"/>
    </xsl:template>

    <xsl:template name="sewing_noBead_above">
        <!--  -->
    </xsl:template>

    <xsl:template name="sewing_frontBeadX">
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontBeadX_1"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontBead_1_detail"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontBead_1_detail_back"
            transform="translate(35,0)"/>
        <xsl:for-each select="cores/yes/cores/type/core">
            <xsl:choose>
                <xsl:when test="position() gt 1">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="position() mod 2 eq 0">
                                    <xsl:text>#noBeadX_2_odd</xsl:text>
                                </xsl:when>
                                <xsl:when test="position() mod 2 eq 1">
                                    <xsl:text>#noBeadX_2_even</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(32,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 0">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_odd</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 1">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_even</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(35,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="sewing_noFrontBeadX-reversingTwistX">
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="primary/yes/construction/type/noFrontBead">
                        <xsl:text>#noFrontBeadX_1</xsl:text>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/reversingTwist">
                        <xsl:text>#reversingTwistX_1</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#noBead_1_detail"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="primary/yes/construction/type/noFrontBead">
                        <xsl:text>#noFrontBead_1_detail_back</xsl:text>
                    </xsl:when>
                    <xsl:when test="primary/yes/construction/type/reversingTwist">
                        <xsl:text>#reversingTwist_1_detail_back</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="transform">
                <xsl:text>translate(35,0)</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:for-each select="cores/yes/cores/type/core">
            <xsl:choose>
                <xsl:when test="position() gt 1">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="position() mod 2 eq 0">
                                    <xsl:text>#noBeadX_2_odd</xsl:text>
                                </xsl:when>
                                <xsl:when test="position() mod 2 eq 1">
                                    <xsl:text>#noBeadX_2_even</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#noBead_2_detail</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(32,</xsl:text>
                            <xsl:value-of select="$Oy + 40 - (20 * position())"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 0">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_odd</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(cores/yes/cores/type/core) mod 2 eq 1">
                                <xsl:text>#crowningCoreX_sewnWithPrimary_even</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#crowningCoreX_sewnWithPrimary_detail</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(35,</xsl:text>
                        <xsl:value-of select="$Oy + 20 - (20 * count(cores/yes/cores/type/core))"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="sewing_greekSingleCoreX">
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekSingleCoreX"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekSingleCore_detail"/>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekSingleCore_detail_back"
            transform="translate(35,0)"/>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="sewing_greekDoubleCoreX">
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                        <xsl:text>#greekDoubleCoreX_1core1crowningCore</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#greekDoubleCoreX_2cores</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                        <xsl:text>#greekDoubleCore_1core1crowningCore_detail</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#greekDoubleCore_2cores_detail</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg" transform="translate(35,0)">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/crowningCore[sewnType/sewnWithPrimary]">
                        <xsl:text>#greekDoubleCore_1core1crowningCore_detail_back</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#greekDoubleCore_2cores_detail_back</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="sewing_warpsOnlyX">
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/core">
                        <xsl:text>#warpsOnlyX_core</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#warpsOnlyX_noCore</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/core">
                        <xsl:text>#warpsOnly_core_detail</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#warpsOnly_noCore_detail</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg" transform="translate(35,0)">
            <xsl:attribute name="xlink:href">
                <xsl:choose>
                    <xsl:when test="cores/yes/cores/type/core">
                        <xsl:text>#warpsOnly_core_detail_back</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>#warpsOnly_noCore_detail_back</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </use>
        <xsl:call-template name="sewing_noBead"/>
    </xsl:template>

    <xsl:template name="primarySewing_pattern">
        <xsl:choose>
            <!--<xsl:when test="ancestor-or-self::endband/primary[NC | NK]">
                <!-\- A drawing cannot be done -\->
                <desc xmlns="http://www.w3.org/2000/svg">Presence of primary sewing could not be
                    identified</desc>
            </xsl:when>
            <xsl:when test="ancestor-or-self::endband/primary/no">
                <!-\- A drawing cannot be done -\->
                <desc xmlns="http://www.w3.org/2000/svg">Primary sewing not present</desc>
            </xsl:when>-->
            <xsl:when test="ancestor-or-self::endband/primary/yes">
                <xsl:choose>
                    <!--<xsl:when test="ancestor-or-self::endband/primary/yes/construction/type[NC | NK]">
                        <!-\- A drawing cannot be done -\->
                        <desc xmlns="http://www.w3.org/2000/svg">Primary sewing could not be
                            identified</desc>
                    </xsl:when>
                    <xsl:when test="ancestor-or-self::endband/primary/yes/construction/type/other">
                        <!-\- A drawing cannot be done -\->
                        <desc xmlns="http://www.w3.org/2000/svg">Primary sewing not covered by
                            schema</desc>
                    </xsl:when>-->
                    <xsl:when
                        test="ancestor-or-self::endband/primary/yes/construction/type[noBead | frontBead | noFrontBead | reversingTwist | greekSingleCore]">
                        <!--  -->
                        <xsl:text>url(#endband_pattern1)</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="ancestor-or-self::endband/primary/yes/construction/type/greekDoubleCore">
                        <!--  -->
                        <xsl:choose>
                            <xsl:when test="position() eq 1">
                                <xsl:text>url(#endband_pattern2)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>url(#endband_pattern1)</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor-or-self::endband/primary/yes/construction/type/warpsOnly">
                        <!--  -->
                        <xsl:choose>
                            <xsl:when
                                test="ancestor-or-self::endband/primary/yes/numberOfTiedowns/every">
                                <xsl:text>url(#endband_pattern3)</xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::endband/primary/yes/numberOfTiedowns[frequent | NK | NC]">
                                <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::endband/primary/yes/numberOfTiedowns/infrequent">
                                <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>url(#endband_pattern1)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="numberOfTiedowns">
        <xsl:choose>
            <xsl:when test="primary/yes/numberOfTiedowns/other">
                <!-- do nothing -->
            </xsl:when>
            <xsl:when test="primary/yes/numberOfTiedowns[every | frequent | infrequent | NC | NK]">
                <!--  -->
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(50, 40)">
                    <xsl:choose>
                        <xsl:when test="primary/yes/numberOfTiedowns[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="cores[not(yes)]">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(50,</xsl:text>
                                <xsl:value-of select="42"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0" stroke-width="0.2">
                        <xsl:attribute name="fill">
                            <xsl:choose>
                                <xsl:when test="primary/yes/numberOfTiedowns/every">
                                    <xsl:text>url(#endband_pattern3_dashed)</xsl:text>
                                </xsl:when>
                                <xsl:when test="primary/yes/numberOfTiedowns[frequent | NC | NK]">
                                    <xsl:text>url(#endband_pattern3_frequent_dashed)</xsl:text>
                                </xsl:when>
                                <xsl:when test="primary/yes/numberOfTiedowns/infrequent">
                                    <xsl:text>url(#endband_pattern3_infrequent_dashed)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>none</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78) + (if (primary/yes/construction/type/frontBead) then 0.7 else 0)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78) + (if (primary/yes/construction/type/frontBead) then 0.7 else 0)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <g xmlns="http://www.w3.org/2000/svg"
                        transform="scale(-1,1) translate(-550,128)">
                        <xsl:choose>
                            <xsl:when test="primary/yes/construction/type/warpsOnly">
                                <xsl:choose>
                                    <xsl:when
                                        test="cores[no | NK | NC | other | yes/cores/type/core/boardAttachment[no | NC | NK | other]] or cores/yes/cores/type/core/boardAttachment/yes/attachment[laced | adhered | cutAtJoint | NC | NK | other]">
                                        <!-- draw entry and exit loops -->
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 227"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 + $tiedownLength "/>
                                                <xsl:text>L</xsl:text>
                                                <xsl:value-of select="$Ox + 227"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 323"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 + $tiedownLength "/>
                                                <xsl:text>L</xsl:text>
                                                <xsl:value-of select="$Ox + 323"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 78"/>
                                            </xsl:attribute>
                                        </path>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="primary/yes/numberOfTiedowns/every">
                                        <!-- draw -->
                                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                                            id="obliqueTiedown_every">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 227"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                                <xsl:text>L</xsl:text>
                                                <xsl:value-of select="$Ox + 233"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(6,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(12,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(18,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(24,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(30,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(36,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(42,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(48,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(54,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(60,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(66,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(72,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(78,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(84,0)"/>
                                        <use xlink:href="#obliqueTiedown_every"
                                            transform="translate(90,0)"/>
                                    </xsl:when>
                                    <xsl:when test="primary/yes/numberOfTiedowns/frequent">
                                        <!-- draw -->
                                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                                            id="obliqueTiedown_frequent">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 227"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                                <xsl:text>L</xsl:text>
                                                <xsl:value-of select="$Ox + 239"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(12,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(24,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(36,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(48,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(60,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(72,0)"/>
                                        <use xlink:href="#obliqueTiedown_frequent"
                                            transform="translate(84,0)"/>
                                    </xsl:when>
                                    <xsl:when test="primary/yes/numberOfTiedowns/infrequent">
                                        <!-- draw -->
                                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                                            id="obliqueTiedown_infrequent">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 227"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                                <xsl:text>L</xsl:text>
                                                <xsl:value-of select="$Ox + 251"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78)"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <use xlink:href="#obliqueTiedown_infrequent"
                                            transform="translate(24,0)"/>
                                        <use xlink:href="#obliqueTiedown_infrequent"
                                            transform="translate(48,0)"/>
                                        <use xlink:href="#obliqueTiedown_infrequent"
                                            transform="translate(72,0)"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                    stroke-width="0.2">
                                    <xsl:attribute name="fill">
                                        <xsl:choose>
                                            <xsl:when test="primary/yes/numberOfTiedowns/every">
                                                <xsl:text>url(#endband_pattern3)</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="primary/yes/numberOfTiedowns/frequent">
                                                <xsl:text>url(#endband_pattern3_frequent)</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="primary/yes/numberOfTiedowns/infrequent">
                                                <xsl:text>url(#endband_pattern3_infrequent)</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>none</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78)"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + (if (primary/yes/construction/type/greekSingleCore) then 80 else 78)"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 223"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 + $tiedownLength"/>
                                        <xsl:text>z</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:otherwise>
                        </xsl:choose>
                    </g>
                    <xsl:choose>
                        <xsl:when test="primary/yes/construction/type[reversingTwist | noFrontBead]">
                            <!-- draw backbeads -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-opacity="0"
                                stroke-width="0.2" transform="scale(-1,1) translate(-550,128)">
                                <xsl:choose>
                                    <xsl:when test="primary/yes/construction/type/noFrontBead">
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'2'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:attribute name="fill">
                                    <xsl:choose>
                                        <xsl:when test="primary/yes/numberOfTiedowns/every">
                                            <xsl:text>url(#endband_pattern3_backBead)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="primary/yes/numberOfTiedowns/frequent">
                                            <xsl:text>url(#endband_pattern3_frequent_backBead)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="primary/yes/numberOfTiedowns/infrequent">
                                            <xsl:text>url(#endband_pattern3_infrequent_backBead)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>none</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 223"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 78"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 78"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 223"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- STUCK-ON -->

    <xsl:template name="coresX_stuckOn">
        <!-- Draw the bookblock reference lines -->
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(6,0)">
            <xsl:call-template name="panelHeight">
                <xsl:with-param name="scale" select="'3:1'"/>
            </xsl:call-template>
            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#bookblockX"/>
        </g>
        <!-- Draw the cross sections of the cores -->
        <xsl:for-each select="cores/yes/cores/type">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:choose>
                    <xsl:when test="core">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#coreX_stuckOn</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 48"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="crowningCore">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#crowningCoreX_stuckOn</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 48"/>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="y">
                    <xsl:value-of
                        select="if (crowningCore) then $Oy + 86 - (20 * position()) + 5.5 else $Oy + 80 - (5 * position())"
                    />
                </xsl:attribute>
                <!-- The schema does not specify the general shape of the core cross section (round? square?): draw with uncertainty as to show uncertainty in the drawn typology -->
                <!-- The schema does not specify the spatial relations between the cores: draw with uncertainty as to show uncertainty in the drawn typology  -->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="50"/>
                    <xsl:with-param name="type" select="'3'"/>
                </xsl:call-template>
            </use>
            <xsl:choose>
                <xsl:when test="NK">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Core type not known</xsl:text>
                    </desc>
                </xsl:when>
                <xsl:when test="other">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Other core type: </xsl:text>
                        <xsl:value-of select="other"/>
                    </desc>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of
                    select="$Oy + 100 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0)"
                />
            </xsl:attribute>
            <xsl:text>front</xsl:text>
        </text>
        <g id="frontView_framework" xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:text>translate(50,</xsl:text>
                <xsl:choose>
                    <xsl:when test="cores/yes">
                        <xsl:value-of select="20"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="20"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="cores"/>
        </g>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of
                    select="$Oy + 100 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0) + $panelHeight + 80"
                />
            </xsl:attribute>
            <xsl:text>back</xsl:text>
        </text>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontView_framework">
            <xsl:attribute name="transform">
                <xsl:text>translate(0,</xsl:text>
                <xsl:value-of select="$Oy + $panelHeight + 80"/>
                <xsl:text>) scale(-1,1) translate(</xsl:text>
                <xsl:value-of select="-(550 + ($bookblockThickness * 2))"/>
                <xsl:text>,0)</xsl:text>
            </xsl:attribute>
        </use>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of
                    select="$Oy + 100 - (if (ancestor::book/boards/yes/boards/board/formation/size[squares | NC | NK | other]) then 10 else 0) - (8 * count(ancestor-or-self::endband/cores/yes/cores/type/core)) - (4 * count(ancestor-or-self::endband/cores/yes/cores/type/crowningCore))- 44"
                />
            </xsl:attribute>
            <xsl:text>above</xsl:text>
        </text>
        <xsl:call-template name="stuckOnX"/>
        <!--<xsl:call-template name="boards-cover_above"/>-->
        <!-- Spine divider -->
        <mask xmlns="http://www.w3.org/2000/svg" id="fademask">
            <rect xmlns="http://www.w3.org/2000/svg" fill="url(#doubleFading4)" stroke="none"
                width="40" height="400" x="305" y="0"/>
        </mask>
        <rect xmlns="http://www.w3.org/2000/svg" fill="#FFFFFF" stroke="none" width="40"
            height="400" x="305" y="0" mask="url(#fademask)"/>
    </xsl:template>

    <xsl:template name="stuckOnX">
        <xsl:variable name="stuckOn_coverage">
            <xsl:choose>
                <xsl:when test="stuckOn/yes/coverage castable as xs:integer">
                    <xsl:value-of select="stuckOn/yes/coverage"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="100"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="stuckOn[no | NC | NK | other]">
                <!-- Do nothing -->
            </xsl:when>
            <xsl:when test="stuckOn/yes">
                <xsl:choose>
                    <xsl:when test="stuckOn/yes/folded/no">
                        <!-- NB: if the coverage value was not given, the stuckOn endband is drawn as if it covered the whole panel, but the fact that the measure is an estimate has to be indicated -->
                        <xsl:variable name="imprecisePath_01">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 43"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + $panelHeightX * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 43"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="not(stuckOn/yes/coverage castable as xs:integer)">
                                <path xmlns="http://www.w3.org/2000/svg" class="line"
                                    d="{$imprecisePath_01}">
                                    <!-- ADD: imprecision halo to indicate height is estimated -->
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#imprecisionHalo)</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            d="{$imprecisePath_01}"/>
                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 43"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 43"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 3 - (if (cores/yes) then(for $i in count(cores/yes/cores/type[core]) return $i * 4 + (2 * ($i - 1))) else 4)"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/folded[yes | NC | NK]">
                        <!-- NB: if the coverage value was not given, the stuckOn endband is drawn as if it covered the whole panel, but the fact that the measure is an estimate has to be indicated -->
                        <xsl:variable name="imprecisePath_01">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 43"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + $panelHeightX * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 43"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:variable>
                        <xsl:variable name="imprecisePath_02">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of select="$Ox + 44.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + $panelHeightX * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 44.50001"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="not(stuckOn/yes/coverage castable as xs:integer)">
                                <path xmlns="http://www.w3.org/2000/svg" class="line"
                                    d="{$imprecisePath_01}">
                                    <!-- ADD: imprecision halo to indicate height is estimated -->
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#imprecisionHalo)</xsl:text>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-width="1"
                                    fill="none" stroke="url(#fadingDownGrey)"
                                    d="{$imprecisePath_02}">
                                    <!-- ADD: imprecision halo to indicate height is estimated -->
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#imprecisionHalo)</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            d="{$imprecisePath_01}"/>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="1" fill="none"
                            stroke="url(#fadingDownGrey)" d="{$imprecisePath_02}"/>
                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                            <!-- NB: uncertainty can be resolved with small multiples page -->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 43"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80"/>
                                <xsl:choose>
                                    <xsl:when test="cores/yes">
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 44"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 3 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 46"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 5 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 50"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 5 - (for $i in count(cores/yes/cores/type[core]) return $i * 5 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 51.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 3 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of select="4"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="4"/>
                                        <xsl:text>&#32;0,0&#32;1&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 48"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1.5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 44"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 1"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 44.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                    </xsl:when>
                                    <xsl:when test="cores[no | NK | NC]">
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 43"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 5"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of select="0.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="0.5"/>
                                        <xsl:text>&#32;1,1&#32;1&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 44.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 44.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/folded[NC | NK]">
                                    <xsl:choose>
                                        <xsl:when test="cores[NK | NC]">
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="25"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="50"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="cores[NK | NC]">
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="50"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="100"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/folded[other | NA]">
                        <!-- Do nothing -->
                    </xsl:when>
                </xsl:choose>
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(0,-30)">
                    <xsl:call-template name="stuckOn">
                        <xsl:with-param name="stuckOn_coverage" select="$stuckOn_coverage"/>
                    </xsl:call-template>
                </g>
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(0,-20)">
                    <xsl:call-template name="stuckOn_above"/>
                </g>
                <xsl:call-template name="boards-cover_above"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="stuckOn">
        <xsl:param name="stuckOn_coverage"/>
        <g xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"
                    />
                </xsl:attribute>
            </path>
            <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)"
                stroke-dasharray="2 1.5">
                <xsl:attribute name="d">
                    <xsl:text>&#32;M</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                </xsl:attribute>
            </path>
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="transform">
                    <xsl:text>translate(0,</xsl:text>
                    <xsl:value-of select="$Oy + $panelHeight + 80"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                    </xsl:attribute>
                </path>
                <!-- redraws the boockblockLine as dashed -->
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-width="1" stroke="#FFFFFF"
                        fill="none">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $panelHeight"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $panelHeight"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" class="line4" stroke-dasharray="2 1.5"
                        fill="none">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $panelHeight"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80 + $panelHeight"/>
                        </xsl:attribute>
                    </path>
                    <!-- <path xmlns="http://www.w3.org/2000/svg" stroke-width="1" stroke="#FFFFFF">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" class="line4" stroke-dasharray="2 1.5">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 223"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2 + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:attribute>
                    </path>-->
                </g>
            </g>
            <xsl:call-template name="stuckOn_pastedOnBoard">
                <xsl:with-param name="stuckOn_coverage" select="$stuckOn_coverage"/>
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template name="stuckOn_above">
        <xsl:choose>
            <xsl:when test="stuckOn[no | NC | NK | other]">
                <!-- Do nothing -->
            </xsl:when>
            <xsl:when test="stuckOn/yes">
                <xsl:choose>
                    <xsl:when test="stuckOn/yes/folded/no">
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            transform="translate(50,0)">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/folded[yes | NC | NK]">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/folded[NC | NK]">
                                    <xsl:choose>
                                        <xsl:when test="cores[NK | NC]">
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="25"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="50"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="cores[NK | NC]">
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="50"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="certainty">
                                                <xsl:with-param name="certainty" select="100"/>
                                                <xsl:with-param name="type" select="'2'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:variable name="stuckOn_above_notFolded">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="if (stuckOn/yes/pastedonBoards/yes) then $Ox + 230 else $Ox + 225"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="if (stuckOn/yes/pastedonBoards/yes) then $Ox + 220 + $bookblockThickness * 2 else $Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                            </xsl:variable>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                stroke-width="{if (cores[no | NK | NC]) then 2.2 else 1}"
                                transform="translate(50,0)" id="stuckOn_above_notFolded"
                                stroke-linecap="butt">
                                <xsl:attribute name="d">
                                    <xsl:copy-of select="$stuckOn_above_notFolded"/>
                                </xsl:attribute>
                            </path>
                            <xsl:choose>
                                <xsl:when test="cores/yes">
                                    <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                        stroke-width="2.2" fill="#FFFFFF" stroke-dasharray="1 1"
                                        transform="translate(50,0)">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 225"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 9"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + 225 + ($bookblockThickness * 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 80 - 9"/>
                                        </xsl:attribute>
                                    </path>
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#stuckOn_above_notFolded"
                                        transform="translate(0,5)"/>
                                </xsl:when>
                                <xsl:when test="cores[no | NK | NC]">
                                    <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                        stroke-width="1" transform="translate(50,0)"
                                        id="stuckOn_above_notFolded" stroke-linecap="butt">
                                        <xsl:attribute name="d">
                                            <xsl:copy-of select="$stuckOn_above_notFolded"/>
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                        stroke-width="0.2" transform="translate(50,0)"
                                        id="stuckOn_above_notFolded" stroke-linecap="butt"
                                        stroke-dasharray="1 1">
                                        <xsl:attribute name="d">
                                            <xsl:copy-of select="$stuckOn_above_notFolded"/>
                                        </xsl:attribute>
                                    </path>
                                </xsl:when>
                            </xsl:choose>
                        </g>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/folded[other | NA]">
                        <!-- Do nothing: there are no examples in the dataset -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="stuckOn_above_pastedOnBoards"/>
    </xsl:template>

    <xsl:template name="stuckOn_above_pastedOnBoards">
        <!-- NB: ADD INCREMETAL UNCERTAINTY TO COVER BOTH PASTEDONBOARDS AND PRESENCE OF CORES -->
        <xsl:choose>
            <xsl:when test="stuckOn/yes/pastedOnBoards/yes">
                <xsl:choose>
                    <xsl:when test="stuckOn/yes/pastedOnBoards/yes[outsideBoards | NK | NC | other]">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/pastedOnBoards/yes[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="cores/yes">
                                    <g xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" id="PastedOutsideBoard_noCores">
                                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                                            id="PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 230"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 6.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 223"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 6.5"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 221"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 6.5"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 221"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 10"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 221"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 218"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                                            </xsl:attribute>
                                        </path>
                                        <use xmlns="http://www.w3.org/2000/svg"
                                            xlink:href="#PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="transform">
                                                <xsl:text>translate(</xsl:text>
                                                <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 225"/>
                                                <xsl:text>,0) scale(-1,1)</xsl:text>
                                            </xsl:attribute>
                                        </use>
                                    </g>
                                </xsl:when>
                                <xsl:when test="cores[no | NK | NC]">
                                    <xsl:choose>
                                        <xsl:when test="stuckOn/yes/folded/no">
                                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                                transform="translate(50,0)"
                                                id="PastedOutsideBoard_noCores_noFolded_path">
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of select="$Ox + 225"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 11"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of select="$Ox + 132"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy + 80 - 11"/>
                                                </xsl:attribute>
                                            </path>
                                            <use xmlns="http://www.w3.org/2000/svg"
                                                xlink:href="#PastedOutsideBoard_noCores_noFolded_path">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 325"/>
                                                  <xsl:text>,0) scale(-1,1)</xsl:text>
                                                </xsl:attribute>
                                            </use>
                                        </xsl:when>
                                        <xsl:when test="stuckOn/yes/folded[yes | NC | NK]">
                                            <xsl:variable name="PastedOutsideBoard_noCores_path">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of select="$Ox + 225"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 132"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 11.5"/>
                                            </xsl:variable>
                                            <g xmlns="http://www.w3.org/2000/svg"
                                                transform="translate(50,0)"
                                                id="PastedOutsideBoard_noCores">
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  stroke="#000000" stroke-width="2.2"
                                                  stroke-linecap="butt"
                                                  id="PastedOutsideBoard_noCores_path">
                                                  <xsl:attribute name="d">
                                                  <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                                  </xsl:attribute>
                                                </path>
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#PastedOutsideBoard_noCores_path">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 225"/>
                                                  <xsl:text>,0) scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <g xmlns="http://www.w3.org/2000/svg"
                                                id="PastedOutsideBoard_noCores_folded">
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  transform="translate(50,0)" stroke="#FFFFFF"
                                                  stroke-width="1" stroke-linecap="butt">
                                                  <xsl:attribute name="d">
                                                  <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                                  </xsl:attribute>
                                                </path>
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  transform="translate(50,0)" stroke="#000000"
                                                  stroke-width="0.1" stroke-linecap="butt"
                                                  stroke-dasharray="1 1">
                                                  <xsl:attribute name="d">
                                                  <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                                  </xsl:attribute>
                                                </path>
                                            </g>
                                            <use xmlns="http://www.w3.org/2000/svg"
                                                xlink:href="#PastedOutsideBoard_noCores_folded">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 325"/>
                                                  <xsl:text>,0) scale(-1,1)</xsl:text>
                                                </xsl:attribute>
                                            </use>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </g>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/pastedOnBoards/yes/insideBoards">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="cores/yes">
                                    <xsl:variable name="PastedOutsideBoard_Cores_path">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 11.5 + ($boardThickness div 2) + 5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 132"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 132"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 11.5 + $boardThickness + 5.5"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 11.5 + $boardThickness + 5.5"/>
                                        <!--<xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 3"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + ($boardThickness div 2)"/>-->
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 11.5 + $boardThickness + 5.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + 5"/>
                                    </xsl:variable>
                                    <g xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" id="PastedOutsideBoard_noCores">
                                        <xsl:attribute name="transform">
                                            <xsl:text>translate(50,</xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="stuckOn/yes/folded/no">
                                                  <xsl:text>0.5</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>0</xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>)</xsl:text>
                                        </xsl:attribute>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="1" stroke-linecap="butt" fill="none"
                                            id="PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="d">
                                                <xsl:copy-of select="$PastedOutsideBoard_Cores_path"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <use xmlns="http://www.w3.org/2000/svg"
                                            xlink:href="#PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="transform">
                                                <xsl:text>translate(</xsl:text>
                                                <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 225"/>
                                                <xsl:text>,0) scale(-1,1)</xsl:text>
                                            </xsl:attribute>
                                        </use>
                                    </g>
                                    <!--
                                    <g xmlns="http://www.w3.org/2000/svg"
                                    id="PastedOutsideBoard_noCores_folded">
                                    <path xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" stroke="#FFFFFF"
                                        fill="none" stroke-width="1" stroke-linecap="butt">
                                        <xsl:attribute name="d">
                                            <xsl:copy-of
                                                select="$PastedOutsideBoard_Cores_path"/>
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" stroke="#000000"
                                        stroke-width="0.1" stroke-linecap="butt"
                                        stroke-dasharray="1 1" fill="none">
                                        <xsl:attribute name="d">
                                            <xsl:copy-of
                                                select="$PastedOutsideBoard_Cores_path"/>
                                        </xsl:attribute>
                                    </path>
                                </g>-->
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#PastedOutsideBoard_noCores_folded">
                                        <xsl:attribute name="transform">
                                            <xsl:text>translate(</xsl:text>
                                            <xsl:value-of
                                                select="($Ox + 225 + $bookblockThickness * 2) + 325"/>
                                            <xsl:text>,0) scale(-1,1)</xsl:text>
                                        </xsl:attribute>
                                    </use>
                                </xsl:when>
                                <xsl:when test="cores[no | NK | NC]">
                                    <xsl:variable name="PastedOutsideBoard_noCores_path">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ox + 225"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 11.5 + ($boardThickness div 2) + 3"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 222"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 3"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 220"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 3"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 132"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11.5 + $boardThickness + 3"
                                        />
                                    </xsl:variable>
                                    <g xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" id="PastedOutsideBoard_noCores">
                                        <xsl:attribute name="transform">
                                            <xsl:text>translate(50,</xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="stuckOn/yes/folded/no">
                                                  <xsl:text>0.5</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>0</xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>)</xsl:text>
                                        </xsl:attribute>
                                        <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
                                            stroke-width="{if (stuckOn/yes/folded/no) then 1 else 2.2}"
                                            stroke-linecap="butt" fill="none"
                                            id="PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="d">
                                                <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                            </xsl:attribute>
                                        </path>
                                        <use xmlns="http://www.w3.org/2000/svg"
                                            xlink:href="#PastedOutsideBoard_noCores_path">
                                            <xsl:attribute name="transform">
                                                <xsl:text>translate(</xsl:text>
                                                <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 225"/>
                                                <xsl:text>,0) scale(-1,1)</xsl:text>
                                            </xsl:attribute>
                                        </use>
                                    </g>
                                    <xsl:choose>
                                        <xsl:when test="stuckOn/yes/folded/yes">
                                            <g xmlns="http://www.w3.org/2000/svg"
                                                id="PastedOutsideBoard_noCores_folded">
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  transform="translate(50,0)" stroke="#FFFFFF"
                                                  fill="none" stroke-width="1" stroke-linecap="butt">
                                                  <xsl:attribute name="d">
                                                  <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                                  </xsl:attribute>
                                                </path>
                                                <path xmlns="http://www.w3.org/2000/svg"
                                                  transform="translate(50,0)" stroke="#000000"
                                                  stroke-width="0.1" stroke-linecap="butt"
                                                  stroke-dasharray="1 1" fill="none">
                                                  <xsl:attribute name="d">
                                                  <xsl:copy-of
                                                  select="$PastedOutsideBoard_noCores_path"/>
                                                  </xsl:attribute>
                                                </path>
                                            </g>
                                            <use xmlns="http://www.w3.org/2000/svg"
                                                xlink:href="#PastedOutsideBoard_noCores_folded">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of
                                                  select="($Ox + 225 + $bookblockThickness * 2) + 325"/>
                                                  <xsl:text>,0) scale(-1,1)</xsl:text>
                                                </xsl:attribute>
                                            </use>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </g>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="stuckOn/yes/pastedOnBoards[no | NC | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="stuckOn/yes/pastedOnBoards[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="cores/yes">
                            <g xmlns="http://www.w3.org/2000/svg" id="notPastedOnBoard_noCores"
                                transform="translate(50,0)">
                                <xsl:variable name="path">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 2"/>
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 2"/>
                                </xsl:variable>
                                <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                    stroke-width="1" d="{$path}"/>
                                <path xmlns="http://www.w3.org/2000/svg" class="line" d="{$path}"/>
                            </g>
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/folded/yes">
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#notPastedOnBoard_noCores"
                                        transform="translate(0,-1)"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="cores[no | NK | NC]">
                            <g xmlns="http://www.w3.org/2000/svg" id="notPastedOnBoard_noCores"
                                transform="translate(50,0)">
                                <xsl:variable name="path">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 224"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 227"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of select="$Ox + 223 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 226 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 10"/>
                                </xsl:variable>
                                <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                    stroke-width="1" d="{$path}"/>
                                <path xmlns="http://www.w3.org/2000/svg" class="line" d="{$path}"/>
                            </g>
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/folded/yes">
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#notPastedOnBoard_noCores"
                                        transform="translate(0,-1)"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="stuckOn_pastedOnBoard">
        <xsl:param name="stuckOn_coverage"/>
        <xsl:choose>
            <xsl:when test="stuckOn/yes/pastedOnBoards/yes">
                <xsl:variable name="imprecisePath_01">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="(if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ox + 225 - (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="(if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4) + (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"/>

                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="$Ox + 225 - (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="(if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4) + (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="(if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4) + (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"
                    />
                </xsl:variable>
                <xsl:variable name="imprecisePath_02">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                </xsl:variable>
                <xsl:variable name="imprecisePath_03">
                    <xsl:text>&#32;M</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="(if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4) + (if (ancestor::book/boards/yes/boards/board/formation/size/sameSize) then 5 else 0)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when
                            test="stuckOn/yes/pastedOnBoards/yes[outsideBoards | NK | NC | other]">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="$Ox + $panelHeight + 80"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <!-- Dash board/cover line -->
                    <g xmlns="http://www.w3.org/2000/svg" id="dashedLine_01"
                        transform="translate(138,50)">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="2" stroke="#FFFFFF"
                            d="{$imprecisePath_03}"/>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.5" stroke="#000000"
                            stroke-dasharray="2 1.5" d="{$imprecisePath_03}"/>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#dashedLine_01">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$bookblockThickness * 2 + 10"/>
                            <xsl:text>,0)</xsl:text>
                        </xsl:attribute>
                    </use>
                </g>
                <xsl:variable name="pastedOnBoards_upperPath">
                    <g xmlns="http://www.w3.org/2000/svg" id="pastedOnBoards_1">
                        <!--<path xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)"
                            d="{$imprecisePath_01}">
                            <!-\- ADD: imprecision halo to indicate length is estimated -\->
                            <xsl:attribute name="filter">
                                <xsl:text>url(#imprecisionHalo)</xsl:text>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)"
                            d="{$imprecisePath_02}">
                            <!-\- ADD: imprecision halo to indicate length is estimated -\->
                            <xsl:attribute name="filter">
                                <xsl:text>url(#imprecisionHalo)</xsl:text>
                            </xsl:attribute>
                        </path>-->
                        <xsl:choose>
                            <xsl:when test="not(stuckOn/yes/coverage castable as xs:integer)">
                                <path xmlns="http://www.w3.org/2000/svg"
                                    transform="translate(50,50)" d="{$imprecisePath_03}">
                                    <!-- ADD: imprecision halo to indicate height is estimated -->
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#imprecisionHalo)</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/pastedOnBoards/yes[NK | NC | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)"
                                d="{$imprecisePath_01}"/>
                            <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)"
                                d="{$imprecisePath_02}"/>
                            <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)"
                                d="{$imprecisePath_03}"/>
                        </g>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#pastedOnBoards_1">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="($Ox + 225 + $bookblockThickness * 2) + 325"/>
                            <xsl:text>,0) scale(-1,1)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="stuckOn/yes/pastedOnBoards/yes/insideBoards">
                        <g xmlns="http://www.w3.org/2000/svg" class="line">
                            <xsl:copy-of select="$pastedOnBoards_upperPath"/>
                        </g>
                        <g xmlns="http://www.w3.org/2000/svg" stroke="#000000" stroke-width="1"
                            stroke-dasharray="2 1.5">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="$Ox + $panelHeight + 80"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:copy-of select="$pastedOnBoards_upperPath"/>
                        </g>
                    </xsl:when>
                    <xsl:otherwise>
                        <g xmlns="http://www.w3.org/2000/svg" stroke="#000000" stroke-width="1"
                            stroke-dasharray="2 1.5">
                            <xsl:copy-of select="$pastedOnBoards_upperPath"/>
                        </g>
                        <g xmlns="http://www.w3.org/2000/svg" class="line">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="$Ox + $panelHeight + 80"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:copy-of select="$pastedOnBoards_upperPath"/>
                        </g>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="stuckOn/yes/pastedOnBoards[no | NC | NK | other]">
                <!-- NB: if the coverage value was not given, the stuckOn endband is drawn as if it covered the whole panel, but the fact that the measure is an estimate has to be indicated -->
                <xsl:variable name="imprecisePath_01">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80"/>
                </xsl:variable>
                <xsl:variable name="imprecisePath_02">
                    <xsl:text>&#32;M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg" id="pastedOnBoards_no">
                    <xsl:choose>
                        <xsl:when test="not(stuckOn/yes/coverage castable as xs:integer)">
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                transform="translate(50,50)" d="{$imprecisePath_01}">
                                <!-- ADD: imprecision halo to indicate height is estimated -->
                                <xsl:attribute name="filter">
                                    <xsl:text>url(#imprecisionHalo)</xsl:text>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                transform="translate(50,50)" stroke-dasharray="2 1.5"
                                d="{$imprecisePath_02}">
                                <!-- ADD: imprecision halo to indicate height is estimated -->
                                <xsl:attribute name="filter">
                                    <xsl:text>url(#imprecisionHalo)</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:choose>
                            <xsl:when test="stuckOn/yes/pastedOnBoards[NC | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            transform="translate(50,50)" d="{$imprecisePath_01}"/>
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            transform="translate(50,50)" stroke-dasharray="2 1.5"
                            d="{$imprecisePath_02}"/>
                    </g>
                </g>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#pastedOnBoards_no">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$bookblockThickness * 2"/>
                        <xsl:text>,0)</xsl:text>
                    </xsl:attribute>
                </use>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$Ox + $panelHeight + 80"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:variable name="imprecisePath_03">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (cores/yes) then $Oy + 80 - 4 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 4"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 + $panelHeight * $stuckOn_coverage div 100"/>
                    </xsl:variable>
                    <g xmlns="http://www.w3.org/2000/svg" id="pastedOnBoards_no_2">
                        <xsl:choose>
                            <xsl:when test="not(stuckOn/yes/coverage castable as xs:integer)">
                                <path xmlns="http://www.w3.org/2000/svg" class="line"
                                    transform="translate(50,50)" d="{$imprecisePath_03}">
                                    <!-- ADD: imprecision halo to indicate height is estimated -->
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#imprecisionHalo)</xsl:text>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="stuckOn/yes/pastedOnBoards[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                transform="translate(50,50)" d="{$imprecisePath_03}"/>
                        </g>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#pastedOnBoards_no_2">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$bookblockThickness * 2"/>
                            <xsl:text>,0)</xsl:text>
                        </xsl:attribute>
                    </use>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Titling -->
    <xsl:template name="title">
        <xsl:param name="detected"/>
        <xsl:param name="location"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 200"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 20"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:text>endband (</xsl:text>
            <xsl:value-of select="$location"/>
            <xsl:text>)</xsl:text>
            <xsl:choose>
                <xsl:when test="$detected eq 0">
                    <xsl:text> not detected</xsl:text>
                </xsl:when>
            </xsl:choose>
        </text>
    </xsl:template>

    <!-- Description -->
    <xsl:template name="description">
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>descText</xsl:text>
            </xsl:attribute>
            <text xmlns="http://www.w3.org/2000/svg" x="{$Ox + 35}" y="{$Oy + 40}">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::endband/stuckOn/yes">
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Stuck-on: </xsl:text>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 73}">
                                <xsl:text>folded (</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor-or-self::endband/stuckOn/yes/folded/other) then concat(ancestor-or-self::endband/stuckOn/yes/folded/node()[2]/name(), ': ', ancestor-or-self::endband/stuckOn/yes/folded/other/text()) else ancestor-or-self::endband/stuckOn/yes/folded/node()[2]/name()"/>
                                <xsl:text>), coverage %: </xsl:text>
                                <xsl:value-of
                                    select="ancestor-or-self::endband/stuckOn/yes/coverage"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::endband/stuckOn/yes/coverage castable as xs:double">
                                        <xsl:text>%</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>, pasted on boards (</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/other) then concat(ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/node()[2]/name(), ': ', ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/other/text()) else ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/node()[2]/name()"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/yes">
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of
                                            select="if (ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/yes/other) then concat(ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/yes/node()[2]/name(), ': ', ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/yes/other/text()) else ancestor-or-self::endband/stuckOn/yes/pastedOnBoards/yes/node()[2]/name()"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>)</xsl:text>
                            </tspan>
                        </tspan>
                    </xsl:when>
                    <xsl:otherwise>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Sewing type: </xsl:text>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 73}">
                                <xsl:value-of
                                    select="if (primary/yes/construction/type/other) then concat(primary/yes/construction/type/node()[2]/name(), ': ', primary/yes/construction/type/other/text()) else primary/yes/construction/type/node()[2]/name()"/>
                                <xsl:text> (tiedowns: </xsl:text>
                                <xsl:value-of
                                    select="if (primary/yes/numberOfTiedowns/other) then concat(primary/yes/numberOfTiedowns/type/node()[2]/name(), ': ', primary/yes/numberOfTiedowns/other/text()) else primary/yes/numberOfTiedowns/node()[2]/name()"/>
                                <xsl:text>)</xsl:text>
                            </tspan>
                        </tspan>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="cores/yes">
                        <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 35}">
                            <xsl:text>Cores: </xsl:text>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 73}">
                                <xsl:for-each select="cores/yes/cores/type[core | crowningCore]">
                                    <tspan>
                                        <xsl:value-of
                                            select="if (core) then concat('core', ' (', position(), ')') else concat('crowning core', ' (', position(), ')')"/>
                                        <xsl:choose>
                                            <xsl:when test="core">
                                                <xsl:text>, board attachment: </xsl:text>
                                                <xsl:value-of
                                                  select="if (core/boardAttachment/yes) 
                                                    then (if (core/boardAttachment/yes/attachment/other) 
                                                    then concat(core/boardAttachment/yes/attachment/node()[2]/name(), ': ', core/boardAttachment/yes/attachment/other/text()) 
                                                    else core/boardAttachment/yes/attachment/node()[2]/name()) 
                                                    else (if (core/boardAttachment/other) 
                                                    then concat(core/boardAttachment/node()[2]/name(), ': ', core/boardAttachment/other/text()) 
                                                    else core/boardAttachment/node()[2]/name())"/>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="core/boardAttachment/yes/attachment/laced">
                                                  <xsl:text> - tunnel: </xsl:text>
                                                  <xsl:value-of
                                                  select="if (core/boardAttachment/yes/attachment/laced/tunnel/other) 
                                                            then concat(core/boardAttachment/yes/attachment/laced/tunnel/node()[2]/name(), ': ', core/boardAttachment/yes/attachment/laced/tunnel/other/text()) 
                                                            else core/boardAttachment/yes/attachment/laced/tunnel/node()[2]/name()"
                                                  />
                                                  </xsl:when>
                                                </xsl:choose>
                                                <xsl:choose>
                                                  <xsl:when test="position() != last()">
                                                  <xsl:text>; </xsl:text>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when test="crowningCore">
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="crowningCore/sewnType/sewnWithPrimary">
                                                  <xsl:text> sewn with primary</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:text> sewn with secondary</xsl:text>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:choose>
                                                  <xsl:when test="position() != last()">
                                                  <xsl:text>; </xsl:text>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:when>
                                        </xsl:choose>
                                    </tspan>
                                </xsl:for-each>
                            </tspan>
                        </tspan>
                    </xsl:when>
                </xsl:choose>
            </text>
        </g>
    </xsl:template>

    <xsl:template name="notes">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::endband/stuckOn/not(yes)">
                <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 84"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Oy + 120 - (20 * count(cores/yes/cores/type/core) + 11.5 * count(cores/yes/cores/type/crowningCore))"
                        />
                    </xsl:attribute>
                    <xsl:text>front</xsl:text>
                </text>
                <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 119"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Oy + 120 - (20 * count(cores/yes/cores/type/core) + 11.5 * count(cores/yes/cores/type/crowningCore))"
                        />
                    </xsl:attribute>
                    <xsl:text>back</xsl:text>
                </text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- Uncertainty template -->
    <xsl:template name="certainty">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
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
            <xsl:when test="$type = '4'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f4)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
