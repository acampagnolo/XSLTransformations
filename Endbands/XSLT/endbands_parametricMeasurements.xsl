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

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="0"/>

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
    </xsl:variable>

    <xsl:variable name="bookblockThickness">
        <!-- Some surveyors have types 'same' instead of giving the value in mm: 
            check for the numeric value in /book/dimensions/thickness/max instead-->
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
    </xsl:variable>
    
    <xsl:variable name="tiedownLength">
        <!-- Disregarded parametric tiedowns: (ancestor::book/sewing/stations/station[group/current][position() eq 1]/measurement * 3) -->
        <xsl:value-of select="70"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/endbands/yes/endband">
            <xsl:variable name="number">
                <xsl:number/>
            </xsl:variable>
            <xsl:variable name="location">
                <xsl:value-of select="location/node()[2]/name()"/>
            </xsl:variable>
            <xsl:variable name="filename"
                select="concat('../../Transformations/endbands/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'endband', '-', $number, '_', $location, '.svg')"/>
            <xsl:result-document href="{$filename}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
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
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                    version="1.1" x="0" y="0" width="1189mm" height="841mm" viewBox="0 0 1189 841"
                    preserveAspectRatio="xMidYMid meet">
                    <title>
                        <xsl:text>Endband (</xsl:text>
                        <xsl:value-of select="$location"/>
                        <xsl:text>) of book: </xsl:text>
                        <xsl:value-of select="$shelfmark"/>
                    </title>
                    <xsl:copy-of
                        select="document('../SVGmaster/endbandsSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Endband (</xsl:text>
                        <xsl:value-of select="$location"/>
                        <xsl:text>) of book: </xsl:text>
                        <xsl:value-of select="$shelfmark"/>
                    </desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:call-template name="coresX"/>
                            <xsl:call-template name="primarySewing"/>
                        </g>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
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
                <xsl:value-of
                    select="$Ox + 40 + ((if (stuckOn/yes) then ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement else ancestor::book/sewing/stations/station[descendant::kettleStitch and group/current][position() eq 1]/measurement) * (if ($scale eq '2:1') then 2 else 3)) + 50"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 80.0001"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="coresX">
        <!-- Draw the bookblock reference lines -->
        <xsl:call-template name="panelHeight">
            <xsl:with-param name="scale" select="'3:1'"/>
        </xsl:call-template>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#bookblockX"/>
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
        <g id="frontView_framework" xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)">
            <xsl:call-template name="cores"/>
        </g>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#frontView_framework">
            <xsl:attribute name="transform">
                <xsl:text>translate(0,</xsl:text>
                <xsl:value-of
                    select="$Ox + ((if (stuckOn/yes) then ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2 else ancestor::book/sewing/stations/station[descendant::kettleStitch and group/current][position() eq 1]/measurement * 2)) + 80"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:call-template name="stuckOnX"/>
        <xsl:call-template name="boards-cover_above"/>
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
                <xsl:value-of
                    select="$Ox + 225 + (if (stuckOn/yes) then ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2 else ancestor::book/sewing/stations/station[descendant::kettleStitch and group/current][position() eq 1]/measurement * 2) + 50"/>
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
                <xsl:value-of
                    select="$Ox + 225 + (if (stuckOn/yes) then ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2 else ancestor::book/sewing/stations/station[descendant::kettleStitch and group/current][position() eq 1]/measurement * 2) + 50"/>
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
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:choose>
                    <xsl:when test="ancestor::endband/stuckOn/yes">
                        <xsl:attribute name="stroke-dasharray">
                            <xsl:text>1 1</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
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
                            select="if (crowningCore) then $Oy + 82 - (8 * position()) + 2 + 1.5 else $Oy + 82 - (8 * position()) + 4"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (crowningCore) then $Oy + 82 - (8 * position())+ 2 + 1.5 else $Oy + 82 - (8 * position()) + 4"
                        />
                    </xsl:attribute>
                    <!--<!-\- The schema does not specify the spatial relations between the cores: draw with uncertainty as to show uncertainty in the drawn typology  -\->
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>-->
                </path>
            </g>
            <xsl:call-template name="cores_boardAttachment"/>
        </xsl:for-each>
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
                                <xsl:value-of select="$Oy + 82 - (8 * position()) - 4"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 82 - (8 * position()) + 4"/>
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
                        <!-- add adhered? -->
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg" class="line4">
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
                            <path xmlns="http://www.w3.org/2000/svg" class="line4">
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
                        </g>
                    </xsl:when>
                    <xsl:when test="core/boardAttachment/yes/attachment/laced">
                        <!-- mmm -->
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
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 - 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 132"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 + 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 + 1.5"/>
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
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
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
                                    <xsl:value-of select="$Oy + 82 - (8 * position()) + 2 + 1.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 82 - (8 * position())+ 2 + 1.5"/>
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::type/core/boardAttachment/yes/attachment/laced">
                        <!-- Draw laced core:  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boards-cover_above">
        <xsl:variable name="boardThickness">
            <xsl:value-of select="10"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="ancestor::book/boards/no and ancestor::book/coverings/yes/cover/type/case/type/laceAttached">
                <!-- Draw the covering so to lace the endbands through  -->
                <path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)" stroke-width="0.5"
                    stroke-linecap="round" stroke-linejoin="round" fill="none" id="cover_above">
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
                        <xsl:value-of select="$Oy + 70"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ox + 146"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 70"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 146 + $bookblockThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 70"/>
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
                <path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)" stroke-width="0.5"
                    stroke-linecap="round" stroke-linejoin="round" fill="none" id="boards_above">
                    <xsl:attribute name="transform">
                        <xsl:choose>
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
            <xsl:when test="cores/yes">
                <xsl:call-template name="cores_above">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
                <xsl:call-template name="cores_above_boardAttachment"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cores_above">
        <xsl:param name="boardThickness"/>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type[core | NK | other]">
                <path xmlns="http://www.w3.org/2000/svg" stroke="#000000" stroke-width="0.2"
                    fill="#FFFFFF" fill-opacity="1" transform="translate(50,0)">
                    <xsl:choose>
                        <xsl:when test="stuckOn/yes/folded/yes">
                            <xsl:attribute name="pippo"/>
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
                    <xsl:choose>
                        <xsl:when test="cores/yes/cores/type[NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type[crowningCore]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-width="0.2" fill="#FFFFFF"
                    fill-opacity="1" transform="translate(50,0)">
                    <xsl:choose>
                        <xsl:when
                            test="cores/yes/cores/type/crowningCore/sewnType/sewnWithSecondary">
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
                        <xsl:value-of select="$Oy + 80 - 4"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 80 - 4"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cores_above_boardAttachment">
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type[core | NK | other]">
                <xsl:choose>
                    <xsl:when
                        test="cores/yes/cores/type/core/boardAttachment[no | NC | NK | other] or cores/yes/cores/type/core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other] or cores/yes/cores/type[NK | other]">
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
                                    test="cores/yes/cores/type/core/boardAttachment[NC | NK | other] or cores/yes/cores/type/core/boardAttachment/yes/attachment[NC | NK | other] or cores/yes/cores/type[NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when
                        test="cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | sewnAndRecessed]">
                        <!-- add adhered? -->
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#000000"
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
                        </g>
                    </xsl:when>
                    <xsl:when test="cores/yes/cores/type/core/boardAttachment/yes/attachment/laced">
                        <!-- mmm -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="cores/yes/cores/type[crowningCore]">
                <pippo2/>
                <xsl:choose>
                    <xsl:when
                        test="cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment[no | NC | NK | other] or cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[cutAtJoint | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when
                                    test="cores/yes/cores/type/crowningCore/sewnType/sewnWithSecondary">
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
                                <xsl:value-of select="$Oy + 80 - 4"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80 - 4"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment[NC | NK | other] or cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </path>
                    </xsl:when>
                    <xsl:when
                        test="cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment[sewn | sewnAndRecessed ]">
                        <!-- add adhered? -->
                        <pippo/>
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,0)">
                            <xsl:choose>
                                <xsl:when
                                    test="cores/yes/cores/type/crowningCore/sewnType/sewnWithSecondary">
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
                                    <xsl:value-of select="$Oy + 80 - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 4"/>
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
                                    <xsl:value-of select="$Oy + 80 - 4"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 4"/>
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                    <xsl:when
                        test="cores/yes/cores/type[crowningCore]/preceding-sibling::type/core/boardAttachment/yes/attachment/laced">
                        <!-- Draw laced core:  -->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boards-cover">
        <xsl:choose>
            <xsl:when test="ancestor::book/boards/no">
                <!-- Do not draw the reference boards -->
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
                            <g xmlns="http://www.w3.org/2000/svg">
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
                            </g>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
            </xsl:when>
        </xsl:choose>
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
                            <xsl:value-of select="$Ox + 37"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 3) * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 37"/>
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
                                <xsl:value-of select="$Ox + 37"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox + 37"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + 80 - 3 - (if (cores/yes) then(for $i in count(cores/yes/cores/type[core]) return $i * 20 + (2 * ($i - 1))) else 18)"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/folded[yes | NC | NK]">
                        <!-- NB: if the coverage value was not given, the stuckOn endband is drawn as if it covered the whole panel, but the fact that the measure is an estimate has to be indicated -->
                        <xsl:variable name="imprecisePath_01">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox + 37"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 3) * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 37"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 80"/>
                        </xsl:variable>
                        <xsl:variable name="imprecisePath_02">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of select="$Ox + 38.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 3) * $stuckOn_coverage div 100"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + 38.5"/>
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
                                <path xmlns="http://www.w3.org/2000/svg" class="line"
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
                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                            d="{$imprecisePath_02}"/>
                        <path xmlns="http://www.w3.org/2000/svg" class="line">
                            <!-- NB: uncertainty can be resolved with small multiples page -->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ox + 37"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 80"/>
                                <xsl:choose>
                                    <xsl:when test="cores/yes">
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 38"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 8 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 39"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 11 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of select="8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="8"/>
                                        <xsl:text>&#32;1,1&#32;1&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 56.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + 80 - 3 - (for $i in count(cores/yes/cores/type[core]) return $i * 11 + (2 * ($i - 1)))"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 56.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 3 - 11"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of select="8"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="8"/>
                                        <xsl:text>&#32;0,0&#32;1&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 48"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 6"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Ox + 39"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 38.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80"/>
                                    </xsl:when>
                                    <xsl:when test="cores[no | NK | NC]">
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 37"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of select="0.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="0.5"/>
                                        <xsl:text>&#32;1,1&#32;1&#32;</xsl:text>
                                        <xsl:value-of select="$Ox + 38.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 80 - 11"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox + 38.5"/>
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
                <xsl:call-template name="stuckOn">
                    <xsl:with-param name="stuckOn_coverage" select="$stuckOn_coverage"/>
                </xsl:call-template>
                <xsl:call-template name="stuckOn_above"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="stuckOn">
        <xsl:param name="stuckOn_coverage"/>
        <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"
                />
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)"
            stroke-dasharray="2 1.5">
            <xsl:attribute name="d">
                <xsl:text>&#32;M</xsl:text>
                <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 225"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                />
            </xsl:attribute>
        </path>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:text>translate(0,</xsl:text>
                <xsl:value-of
                    select="$Ox + ((if (stuckOn/yes) then ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2 else ancestor::book/sewing/stations/station[descendant::kettleStitch and group/current][position() eq 1]/measurement * 2)) + 80"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"
                    />
                </xsl:attribute>
            </path>
            <path xmlns="http://www.w3.org/2000/svg" class="line" transform="translate(50,50)">
                <xsl:attribute name="d">
                    <xsl:text>&#32;M</xsl:text>
                    <xsl:value-of select="$Ox + 225 + $bookblockThickness * 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                    />
                </xsl:attribute>
            </path>
            <!-- redraws the boockblockLine as dashed -->
            <g xmlns="http://www.w3.org/2000/svg" transform="translate(50,50)">
                <path xmlns="http://www.w3.org/2000/svg" stroke-width="1" stroke="#FFFFFF">
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
                </path>
            </g>
        </g>
        <xsl:call-template name="stuckOn_pastedOnBoard">
            <xsl:with-param name="stuckOn_coverage" select="$stuckOn_coverage"/>
        </xsl:call-template>
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
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                transform="translate(50,0)" id="stuckOn_above_notFolded">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="if (stuckOn/yes/pastedonBoards/yes) then $Ox + 230 else $Ox + 225"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 11"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="if (stuckOn/yes/pastedonBoards/yes) then $Ox + 220 + $bookblockThickness * 2 else $Ox + 225 + $bookblockThickness * 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80 - 11"/>
                                </xsl:attribute>
                            </path>
                            <xsl:choose>
                                <xsl:when test="cores/yes">
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#stuckOn_above_notFolded"
                                        transform="translate(0,11)"/>
                                </xsl:when>
                                <xsl:when test="cores[no | NK | NC]">
                                    <use xmlns="http://www.w3.org/2000/svg"
                                        xlink:href="#stuckOn_above_notFolded"
                                        transform="translate(0,-1)"/>
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
                            <!--<xsl:choose>
                                <xsl:when test="stuckOn/yes/pastedOnBoards/yes[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>-->
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
                                                <xsl:value-of select="$Oy + 80"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox + 223"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of select="$Ox + 221"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of select="$Ox + 221"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$Oy + 80 - 6"/>
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
                                    <g xmlns="http://www.w3.org/2000/svg"
                                        transform="translate(50,0)" id="PastedOutsideBoard_noCores">
                                        <path xmlns="http://www.w3.org/2000/svg" class="line"
                                            id="PastedOutsideBoard_noCores_path">
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
                                            <use xmlns="http://www.w3.org/2000/svg"
                                                xlink:href="#PastedOutsideBoard_noCores"
                                                transform="translate(0,-1)"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </g>
                    </xsl:when>
                    <xsl:when test="stuckOn/yes/pastedOnBoards/yes/insideBoards">
                        <!-- mmmm -->
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
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"
                    />
                </xsl:variable>
                <xsl:variable name="imprecisePath_02">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox + 225"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                    />
                </xsl:variable>
                <xsl:variable name="imprecisePath_03">
                    <xsl:text>&#32;M</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + 132"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                    />
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when
                            test="stuckOn/yes/pastedOnBoards/yes[outsideBoards | NK | NC | other]">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of
                                    select="$Ox + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) + 80"/>
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
                                <xsl:value-of
                                    select="$Ox + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) + 80"/>
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
                                <xsl:value-of
                                    select="$Ox + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) + 80"/>
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
                        select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
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
                    <xsl:value-of
                        select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                    />
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
                        <xsl:value-of
                            select="$Ox + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) + 80"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:variable name="imprecisePath_03">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (cores/yes) then $Oy + 80 - 9 * count(cores/yes/cores/type) + 2 * count(cores/yes/cores/type/crowningCore) else $Oy + 80 - 9"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + 225"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + 80 + (ancestor::book/sewing/stations/station[not(descendant::kettleStitch) and group/current][position() eq 1]/measurement * 2) * $stuckOn_coverage div 100"
                        />
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
                                        select="$Oy + 80 + $tiedownLength"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Ox + 38"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLength + 3"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$Ox + 40"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLength + 3"
                                    />
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line"
                                marker-end="url(#arrowSymbol)">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + $tiedownLength"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + ($tiedownLength div 2)"
                                    />
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" class="line">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + 80 + ($tiedownLength div 2)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ox + 37"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 80"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <xsl:choose>
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
                                            <xsl:value-of select="$Ox + 40 + (58 - 40) div 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + ($tiedownLength + 3) div 2"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 40"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + $tiedownLength + 3"
                                            />
                                        </xsl:attribute>
                                    </path>
                                </g>
                            </xsl:when>
                            <xsl:otherwise>
                                <g xmlns="http://www.w3.org/2000/svg" stroke-dasharray="2 2.5"
                                    stroke-linecap="round">
                                    <path xmlns="http://www.w3.org/2000/svg" class="line">
                                        <xsl:attribute name="marker-end">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="primary/yes/construction/type/frontBead">
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
                                            <xsl:value-of
                                                select="$Oy + 80 + ($tiedownLength div 2)"/>
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg" class="line">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ox + 58"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + ($tiedownLength div 2)"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ox + 58"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + $tiedownLength - 15"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$Ox + 58"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + $tiedownLength + 3"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$Ox + 40"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + 80 + $tiedownLength + 3"
                                            />
                                        </xsl:attribute>
                                    </path>
                                </g>
                            </xsl:otherwise>
                        </xsl:choose>
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
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekSingleCore_detail_back" transform="translate(35,0)"/>
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
