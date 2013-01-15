<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dict="www.mydict.my"
    xmlns:math="http://exslt.org/math" exclude-result-prefixes="xs svg xlink lig dict math"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" standalone="no"
        xpath-default-namespace="http://www.w3.org/2000/svg" exclude-result-prefixes="xlink"
        include-content-type="no"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>
    <xsl:variable name="filename"
        select="concat('../../Transformations/SpineLining/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'spineLining', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="0"/>

    <!-- Only a portion of the book width is drawn: this parameter selects the length -->
    <xsl:param name="boardLength" select="50"/>

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
            <xsl:when test="/book/boards[no]">
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
            <xsl:when test="/book/boards[no]">
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

    <xsl:variable name="countInsideBoards">
        <xsl:value-of
            select="count(//book/spine/lining/yes/lining[liningJoints[insideBoards | pastedToFlyleaf]])"
        />
    </xsl:variable>

    <xsl:variable name="sectionThickness">
        <xsl:value-of select="1"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:result-document href="{$filename}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
            doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/SpineLining/CSS/style.css"&#32;</xsl:text>
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
                <title>Spine lining of book: <xsl:value-of select="$shelfmark"/></title>
                <xsl:copy-of
                    select="document('../SVGmaster/spineLiningSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                <desc xmlns="http://www.w3.org/2000/svg">Spine lining of book: <xsl:value-of
                        select="$shelfmark"/></desc>
                <svg>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy"/>
                    </xsl:attribute>
                    <g xmlns="http://www.w3.org/2000/svg"
                        transform="translate(40,50) rotate(-90,50,0)">
                        <xsl:apply-templates/>
                    </g>
                    <xsl:call-template name="aboveSilouette"/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <!-- Template that calls the spine arc pipeline of templates for both halves of the bookblock and the lining -->
    <xsl:template match="book/spine" name="spineArcCaller">
        <xsl:call-template name="spineArc">
            <xsl:with-param name="boardThickness" select="$rightBoardThickness"/>
        </xsl:call-template>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $leftBoardThickness"/>
                <xsl:text>) scale(1,-1)</xsl:text>
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="- $bookblockThickness - $rightBoardThickness"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="spineArc">
                <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
            </xsl:call-template>
        </g>
    </xsl:template>

    <xsl:template match="book/boards" name="boardLocation">
        <xsl:choose>
            <!-- This checks that both boards are present. To allow for dos-a-dos bindings and other bindings with more than 2 boards change test to 'ancestor::boards[1]/board[last() gt 1]' -->
            <xsl:when test="descendant::board[2]">
                <!--<xsl:variable name="boardThickness"
                    select="if (descendant::board/location/right) then $rightBoardThickness else $leftBoardThickness"/>-->
                <xsl:variable name="location">
                    <xsl:value-of select="descendant::board/location/node()/name()"/>
                </xsl:variable>
                <xsl:call-template name="boardCrossSection">
                    <xsl:with-param name="boardThickness" select="$rightBoardThickness"/>
                    <xsl:with-param name="location" select="$location"/>
                    <xsl:with-param name="certainty" select="100"/>
                </xsl:call-template>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + $rightBoardThickness"/>
                        <xsl:text>) scale(1,-1)</xsl:text>
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="- $bookblockThickness - $leftBoardThickness"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="boardCrossSection">
                        <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                        <xsl:with-param name="location" select="$location"/>
                        <xsl:with-param name="certainty" select="100"/>
                    </xsl:call-template>
                </g>
            </xsl:when>
            <xsl:when test="descendant::boards[not(board[2])]">
                <xsl:choose>
                    <xsl:when test="descendant::board/location[left | right]">
                        <xsl:variable name="boardThickness"
                            select="if (descendant::board/location/right) then $rightBoardThickness else $leftBoardThickness"/>
                        <xsl:variable name="location">
                            <xsl:value-of select="descendant::board/location/node()/name()"/>
                        </xsl:variable>
                        <xsl:variable name="locationCopied">
                            <xsl:value-of
                                select="concat('Board not pesent, diagram copied from', $location)"
                            />
                        </xsl:variable>
                        <xsl:call-template name="boardCrossSection">
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                            <xsl:with-param name="location"
                                select="if (descendant::board/location/right) then $location else $locationCopied"/>
                            <xsl:with-param name="certainty"
                                select="if (descendant::board/location/right) then xs:integer(100) else xs:integer(40)"
                            />
                        </xsl:call-template>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + $boardThickness"/>
                                <xsl:text>) scale(1,-1)</xsl:text>
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="- $bookblockThickness - $boardThickness"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:call-template name="boardCrossSection">
                                <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                <xsl:with-param name="location"
                                    select="if (descendant::board/location/left) then $location else $locationCopied"/>
                                <xsl:with-param name="certainty"
                                    select="if (descendant::board/location/left) then xs:integer(100) else xs:integer(40)"
                                />
                            </xsl:call-template>
                        </g>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::book/boards/no">
                <xsl:variable name="location">
                    <xsl:value-of select="'No boards present'"/>
                </xsl:variable>
                <xsl:call-template name="boardCrossSection">
                    <xsl:with-param name="boardThickness" select="$rightBoardThickness"/>
                    <xsl:with-param name="location" select="$location"/>
                    <xsl:with-param name="certainty" select="xs:integer(40)"/>
                </xsl:call-template>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + $rightBoardThickness"/>
                        <xsl:text>) scale(1,-1)</xsl:text>
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="- $bookblockThickness - $leftBoardThickness"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="boardCrossSection">
                        <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                        <xsl:with-param name="location" select="$location"/>
                        <xsl:with-param name="certainty" select="xs:integer(40)"/>
                    </xsl:call-template>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boardCrossSection">
        <xsl:param name="boardThickness"/>
        <xsl:param name="location"/>
        <xsl:param name="certainty" as="xs:integer"/>
        <xsl:variable name="explodeBoards">
            <xsl:choose>
                <!-- NB: check that NC, free, NK and other lining joints are actually to be drawn as if they were outsideBoards -->
                <xsl:when test="ancestor::book/spine/profile/shape/flat">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::book/spine/lining/yes/lining/liningJoints[outsideBoards | NC | free | NK | other]">
                            <xsl:value-of select="concat('translate(', 0, ',', -2, ')')"/>
                        </xsl:when>
                        <xsl:when
                            test="ancestor::book/spine/lining/yes/lining/liningJoints[insideBoards | pastedToFlyleaf]">
                            <xsl:value-of
                                select="concat('translate(', 0, ',', -5 * $countInsideBoards, ')')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::book/spine/lining/yes/lining/liningJoints[outsideBoards | NC | free | NK | other]">
                            <xsl:value-of select="concat('translate(', -2, ',', 0, ')')"/>
                        </xsl:when>
                        <xsl:when
                            test="ancestor::book/spine/lining/yes/lining/liningJoints[insideBoards | pastedToFlyleaf]">
                            <xsl:value-of
                                select="concat('translate(', -5 * $countInsideBoards, ',', 0, ')')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$location"/>
            <xsl:text>&#32;board</xsl:text>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:value-of select="$explodeBoards"/>
            </xsl:attribute>
            <mask xmlns="http://www.w3.org/2000/svg" id="fademaskBoards">
                <path xmlns="http://www.w3.org/2000/svg" fill="url(#fading2)">
                    <xsl:attribute name="d">
                        <xsl:call-template name="boardPath">
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </path>
            </mask>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
                stroke="url(#fading)" stroke-width="0.2" fill="url(#thicknessCutoutTile)"
                mask="url(#fademaskBoards)">
                <!--<xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>-->
                <!-- TO DO: add uncertainty for NC, NK, other  -->
                <!-- when NC: some uncertainty; when NK or other: uncertainty -->
                <!-- TO DO -->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'2'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:call-template name="boardPath">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>
                </xsl:attribute>
            </path>
        </g>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:value-of select="$explodeBoards"/>
            </xsl:attribute>
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
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                <!-- rounded corner at the spine -->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .85"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * .5"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/acute">
                <!-- angled spine edge -->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                        if (descendant::formation/bevels[cushion | peripheralCushion]) 
                        then $Oy + ($boardThickness *.375) 
                        else $Oy "/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/angled">
                <!-- angled spine edge (mirror of acute) -->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * .95"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .9"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- None, flat, and square have a squared board -->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="descendant::formation/bevels/cushion">
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$Ox - $boardLength * 0.1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness div 4"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>z</xsl:text>
            </xsl:when>
            <xsl:when test="descendant::formation/bevels/peripheralCushion">
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .7"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ox + $boardLength * .6"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>z</xsl:text>
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
        <xsl:param name="xRadius" select="$bookblockThickness * .1"/>
        <xsl:param name="yRadius" select="$bookblockThickness div 2 + ($boardThickness div 3)"/>
        <xsl:variable name="arc_tMin">
            <!-- Coordinates of the starting point of the spine arc -->
            <xsl:choose>
                <xsl:when test="profile/joints[slight | quadrant | acute]">
                    <!-- angled spine edge -->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of
                            select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness *.375) 
                            else $Oy"
                        />
                    </ytMin>
                </xsl:when>
                <xsl:when test="profile/joints/angled">
                    <!-- angled spine edge (mirror of acute) -->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength * .9"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of
                            select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness div 4) 
                            else $Oy"
                        />
                    </ytMin>
                </xsl:when>
                <xsl:when test="profile/joints/square">
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of
                            select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness div 4) 
                            else $Oy"
                        />
                    </ytMin>
                </xsl:when>
                <xsl:otherwise>
                    <!-- None, flat, NC, NK, and other have a squared board -->
                    <!-- NB. how to pass on the uncertainty of the shape? -->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of select="$Oy + $boardThickness"/>
                    </ytMin>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="arcShape">
            <xsl:choose>
                <xsl:when test="profile/shape/flat">
                    <!-- flat spine -->
                    <xRadius>
                        <xsl:value-of select="$bookblockThickness * .0001"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of select="xs:double($bookblockThickness div 2)"/>
                    </yRadius>
                </xsl:when>
                <xsl:when test="profile/shape/slightRound">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of
                            select="if (profile/joints/angled) then xs:double($bookblockThickness * .3) else xs:double($bookblockThickness * .15)"
                        />
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="xs:double($bookblockThickness div 2 + ($boardThickness - $arc_tMin/ytMin))"
                        />
                    </yRadius>
                </xsl:when>
                <xsl:when test="profile/shape/round">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of select="xs:double($bookblockThickness * .3)"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="xs:double($bookblockThickness div 2 + ($boardThickness - $arc_tMin/ytMin))"
                        />
                    </yRadius>
                </xsl:when>
                <xsl:when test="profile/shape/heavyRound">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of select="xs:double($bookblockThickness * .45)"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="xs:double($bookblockThickness div 2 + ($boardThickness - $arc_tMin/ytMin))"
                        />
                    </yRadius>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
            <xsl:attribute name="class">
                <xsl:text>line4</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arc_tMin/ytMin"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of
                    select="if (profile/joints/angled) then $Ox + $boardLength *.94 + $arcShape/xRadius else $Ox + $boardLength + $arcShape/xRadius"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="if (profile/joints/angled) then $Ox + $boardLength *.94 + $arcShape/xRadius else $Ox + $boardLength + $arcShape/xRadius"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="trigonometry">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="xRadius" select="$arcShape/xRadius" as="xs:double"/>
            <xsl:with-param name="yRadius" select="$arcShape/yRadius" as="xs:double"/>
            <xsl:with-param name="xtMin" select="$arc_tMin/xtMin"/>
            <xsl:with-param name="ytMin" select="$arc_tMin/ytMin"/>
        </xsl:call-template>
        <xsl:call-template name="lining">
            <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
            <xsl:with-param name="xRadius" select="$arcShape/xRadius" as="xs:double"/>
            <xsl:with-param name="yRadius" select="$arcShape/yRadius" as="xs:double"/>
            <xsl:with-param name="xtMin" select="$arc_tMin/xtMin"/>
            <xsl:with-param name="ytMin" select="$arc_tMin/ytMin"/>
        </xsl:call-template>
    </xsl:template>


    <!-- Template to make trigonometric calculations to subdivide the spine arc in a set of coordinates -->
    <xsl:template name="trigonometry">
        <xsl:param name="counter" select="1"/>
        <xsl:param name="boardThickness"/>
        <xsl:param name="sectionThickness" select="$sectionThickness"/>
        <xsl:param name="xRadius" as="xs:double"/>
        <xsl:param name="yRadius" as="xs:double"/>
        <xsl:param name="xtMin"/>
        <xsl:param name="ytMin"/>
        <xsl:variable name="h"
            select="if (profile/joints/angled) then $Ox + $boardLength *.94 else $Ox + $boardLength"/>
        <xsl:variable name="k" select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
        <!-- variable to calculate the number of sections to cover the spine arc -->
        <xsl:variable name="sections">
            <xsl:value-of
                select="xs:integer(($bookblockThickness div 2) div $sectionThickness * .5)"/>
        </xsl:variable>
        <!-- variable to calculate the angle in radians to cover the spine arc -->
        <xsl:variable name="angle" select="(math:constant('PI',16) div 2) div $sections"/>
        <!-- variable to assign the right x and y values for each point on the reference arc -->
        <xsl:variable name="i">
            <xsl:value-of
                select="
                for $i in 1 to $sections
                return concat($h + ($xRadius) * math:cos(math:constant('PI',16) div 2 - ($angle * $i)), ',', $k - $yRadius * math:cos($angle * $i), ';')"
            />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$counter lt 2">
                <!-- The trigonometry template is called again to calculate the coordinates for the curved page lines (for joints/slight) -->
                <xsl:call-template name="trigonometry">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    <xsl:with-param name="sectionThickness" select="$sectionThickness"/>
                    <xsl:with-param name="xRadius"
                        select="if (profile/shape/flat) then 0 else ($xRadius) div 2"/>
                    <xsl:with-param name="yRadius" select="$yRadius"/>
                </xsl:call-template>
                <xsl:call-template name="sectionLines">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    <xsl:with-param name="sectionThickness" select="$sectionThickness"/>
                    <xsl:with-param name="i" select="$i"/>
                    <xsl:with-param name="sections" select="$sections"/>
                    <xsl:with-param name="xRadius" select="$xRadius"/>
                    <xsl:with-param name="h" select="$h"/>
                    <xsl:with-param name="xtMin" select="$xtMin"/>
                    <xsl:with-param name="ytMin" select="$ytMin"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sectionLines">
        <xsl:param name="sections" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="boardThickness"/>
        <xsl:param name="sectionThickness"/>
        <xsl:param name="i"/>
        <xsl:param name="xRadius" as="xs:double"/>
        <xsl:param name="h"/>
        <xsl:param name="xtMin"/>
        <xsl:param name="ytMin"/>
        <xsl:variable name="sectionSeparation">
            <xsl:value-of select="($bookblockThickness div 2) div $sections"/>
        </xsl:variable>
        <xsl:variable name="implodeFlyleafLine">
            <xsl:choose>
                <xsl:when test="lining/yes/lining/liningJoints[insideBoards | pastedToFlyleaf]">
                    <xsl:value-of
                        select="$Oy + $boardThickness + (($sectionSeparation * 2) + 1) * $countInsideBoards"
                    />
                </xsl:when>
                <xsl:when
                    test="lining/yes/lining/liningJoints[outsideBoards | NC | free | NK | other]">
                    <xsl:value-of select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$counter lt $sections">
                <path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)" stroke-width="0.1"
                    fill="none">
                    <xsl:attribute name="stroke-opacity">
                        <xsl:value-of select=".6"/>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$xtMin"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="if (profile/shape/flat) then $ytMin - .5 else $ytMin"/>
                        <xsl:choose>
                            <xsl:when test="profile/joints[slight | quadrant]">
                                <xsl:choose>
                                    <xsl:when test="profile/shape/flat">
                                        <xsl:choose>
                                            <xsl:when test="$counter lt 2">
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of
                                                  select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$implodeFlyleafLine"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of
                                                  select="
                                                            if (profile/joints/slight) 
                                                            then $Ox + $boardLength * .95 - ($boardLength * .1) div $sections * $counter 
                                                            else $Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$implodeFlyleafLine"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="$implodeFlyleafLine"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[2]) + .001"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="
                                                    if (profile/joints/slight) 
                                                    then $Ox + $boardLength * .95 - ($boardLength * .1) div $sections * $counter 
                                                    else $Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="profile/joints/acute">
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength * .9 + ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength * .9 - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                            </xsl:when>
                            <xsl:when test="profile/joints/angled">
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength + 1.5*$sectionSeparation + ($bookblockThickness * .001)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                            </xsl:when>
                            <xsl:when test="profile/joints/square">
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength + $sectionSeparation + ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$implodeFlyleafLine"/>
                            </xsl:when>
                            <xsl:when test="profile/joints[none | flat]">
                                <xsl:choose>
                                    <xsl:when test="profile/shape/flat">
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$ytMin - .5 + .000001"/>
                                        <!--<xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[2]) + .000001"
                                        />-->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$implodeFlyleafLine"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="lining">
        <xsl:param name="boardThickness"/>
        <xsl:param name="xRadius" as="xs:double"/>
        <xsl:param name="yRadius" as="xs:double"/>
        <xsl:param name="xtMin"/>
        <xsl:param name="ytMin"/>
        <xsl:for-each select="lining/yes/lining">
            <xsl:variable name="boardLengthVariable">
                <xsl:value-of
                    select="if (ancestor::spine/profile/joints/angled) then $boardLength * .86 else $boardLength"
                />
            </xsl:variable>
            <xsl:variable name="arcParameters">
                <xsl:choose>
                    <xsl:when test="ancestor::spine/profile/shape/NC">
                        <!-- Do something -->
                    </xsl:when>
                    <xsl:when test="ancestor::spine/profile/shape/flat">
                        <value1>
                            <xsl:value-of select="-4 * position()"/>
                        </value1>
                        <value2>
                            <xsl:value-of select="2 * position()"/>
                        </value2>
                    </xsl:when>
                    <xsl:when test="ancestor::spine/profile/shape[slightRound | round | heavyRound]">
                        <value1>
                            <xsl:value-of select="-2 * position()"/>
                        </value1>
                        <value2>
                            <xsl:value-of select="-4 * position()"/>
                        </value2>
                    </xsl:when>
                    <xsl:when test="ancestor::spine/profile/shape/NK">
                        <!-- Do something? -->
                    </xsl:when>
                    <xsl:when test="ancestor::spine/profile/shape/other">
                        <!-- Do something? -->
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="certainty">
                <xsl:choose>
                    <xsl:when test="liningJoints[NC | NK]">
                        <xsl:value-of>
                            <xsl:value-of select="52"/>
                        </xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="100"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <!-- Certainty adjustment -->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="if (ancestor::spine/profile/shape/flat) then $Ox + $boardLengthVariable + $arcParameters/value2 else $Ox + $boardLengthVariable + $arcParameters/value1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::spine/profile/shape/flat and ./liningJoints[insideBoards | pastedToFlyleaf]">
                            <xsl:value-of select="$Oy + $boardThickness - $arcParameters/value2 -.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ox + $boardLengthVariable + $arcParameters/value2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$Oy + $arcParameters/value1"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="if (ancestor::spine/profile/joints/angled) then $Ox + $boardLength *.94 + $xRadius + 2 else $Ox + $boardLength + $xRadius + (2 * position())"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $arcParameters/value2"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="if (ancestor::spine/profile/joints/angled) then $Ox + $boardLength *.94 + $xRadius + 2 else $Ox + $boardLength + $xRadius + (2 * position())"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </path>
            <xsl:choose>
                <xsl:when test="liningJoints[insideBoards | pastedToFlyleaf]">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Lining:</xsl:text>
                        <xsl:value-of select="liningJoints/node()/name()"/>
                    </desc>
                    <xsl:choose>
                        <xsl:when test="ancestor::spine/profile/shape/flat">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>lineFading</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + $boardThickness - $arcParameters/value2 -.5 - 0.000001"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Ox + $boardLength + $arcParameters/value2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + $boardThickness - $arcParameters/value2 -.5"/>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>lineFading</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ox"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Oy + $boardThickness - $arcParameters/value1 +.5 - 0.000001"/>
                                    <xsl:choose>
                                        <xsl:when test="ancestor::book/spine/profile/joints/acute">
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength * .9 + $arcParameters/value2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + $boardThickness - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy  + $boardThickness - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + $arcParameters/value1"/>
                                        </xsl:when>
                                        <xsl:when test="ancestor::book/spine/profile/joints/angled">
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + $boardThickness - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value1 +1.5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy  + $boardThickness *.95 - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLengthVariable + $arcParameters/value1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + $arcParameters/value1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- None, flat, square have a squared board -->
                                            <!-- Also valid for quadrant and slight -->
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength * .85 + $arcParameters/value1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + $boardThickness - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + $boardThickness - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value1 -.5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Oy + $boardThickness * .5 - $arcParameters/value1 +.5"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Ox + $boardLength + $arcParameters/value1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + $arcParameters/value1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </path>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="liningJoints/pastedToFlyleaf">
                            <mask xmlns="http://www.w3.org/2000/svg" id="fademaskPastedToFlyleaf">
                                <path xmlns="http://www.w3.org/2000/svg" fill="url(#doubleFading)">
                                    <xsl:attribute name="d">
                                        <xsl:call-template name="pastedToFlyleafPath">
                                            <xsl:with-param name="boardThickness"
                                                select="$boardThickness"/>
                                            <xsl:with-param name="arcParametersValue1"
                                                select="$arcParameters/value1"/>
                                            <xsl:with-param name="arcParametersValue2"
                                                select="$arcParameters/value2"/>
                                            <xsl:with-param name="ytMin" select="$ytMin"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </path>
                            </mask>
                            <path xmlns="http://www.w3.org/2000/svg" stroke="#FFFFFF"
                                stroke-opacity="0" stroke-width="0.5"
                                fill="url(#thicknessCutoutTile)"
                                mask="url(#fademaskPastedToFlyleaf)">
                                <xsl:attribute name="d">
                                    <xsl:call-template name="pastedToFlyleafPath">
                                        <xsl:with-param name="boardThickness"
                                            select="$boardThickness"/>
                                        <xsl:with-param name="arcParametersValue1"
                                            select="$arcParameters/value1"/>
                                        <xsl:with-param name="arcParametersValue2"
                                            select="$arcParameters/value2"/>
                                        <xsl:with-param name="ytMin" select="$ytMin"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="liningJoints[outsideBoards | NC | NK]">
                    <!-- NC and NK: Draw most probable - outsideBoards: 51.74% - with high degree of uncertainty -->
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Lining:</xsl:text>
                        <xsl:value-of select="liningJoints/node()/name()"/>
                    </desc>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="class">
                            <!-- NB: the filter for certainty blurring does not work well with faded lines -->
                            <xsl:choose>
                                <xsl:when test="liningJoints/outsideBoards">
                                    <xsl:text>lineFading</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>line</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <!-- Certainty adjustment -->
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'3'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ox"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Oy + $arcParameters/value1 - (if (liningJoints/outsideBoards) then 0.000001 else 0)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (ancestor::spine/profile/shape/flat) then $Oy + $boardLengthVariable + $arcParameters/value2 else $Ox + $boardLengthVariable + $arcParameters/value1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $arcParameters/value1"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="liningJoints/free">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Lining:</xsl:text>
                        <xsl:value-of select="liningJoints/node()/name()"/>
                    </desc>
                    <!-- NB -->
                    <!-- NB: what to draw??? -->
                    <!-- NB -->
                </xsl:when>
                <xsl:when test="liningJoints/other">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Lining:</xsl:text>
                        <xsl:value-of select="liningJoints/node()/name()"/>
                    </desc>
                    <!-- NB -->
                    <!-- NB: indicate with label 'other'??? -->
                    <!-- NB -->
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="pastedToFlyleafPath">
        <xsl:param name="boardThickness"/>
        <xsl:param name="arcParametersValue1"/>
        <xsl:param name="arcParametersValue2"/>
        <xsl:param name="sectionThickness" select="$sectionThickness"/>
        <xsl:param name="ytMin"/>
        <xsl:variable name="sections">
            <xsl:value-of
                select="xs:integer(($bookblockThickness div 2) div $sectionThickness * .5)"/>
        </xsl:variable>
        <xsl:variable name="sectionSeparation">
            <xsl:value-of select="($bookblockThickness div 2) div $sections"/>
        </xsl:variable>
        <xsl:attribute name="d">
            <xsl:choose>
                <xsl:when test="ancestor::spine/profile/shape/flat">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + $boardThickness - $arcParametersValue2 -.5 - 0.000001"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + $boardLength"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + $boardThickness - $arcParametersValue2 -.5"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox + $boardLength"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$ytMin - .5 + .000001"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$ytMin - .5 + .000001"/>
                    <xsl:text>&#32;z</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ox"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + $boardThickness - $arcParametersValue1 +.5 - 0.000001"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="if (ancestor::book/spine/profile/joints/angled) then $Ox + $boardLength + $arcParametersValue1 else $Ox + $boardLength * .9 + $arcParametersValue1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Oy + $boardThickness - $arcParametersValue1 +.5"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="if (ancestor::book/spine/profile/joints/angled) then $Ox + $boardLength + $arcParametersValue1 else $Ox + $boardLength * .9 + $arcParametersValue1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + $boardThickness + (($sectionSeparation * 2) + 1) * $countInsideBoards"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ox"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + $boardThickness + (($sectionSeparation * 2) + 1) * $countInsideBoards"/>
                    <xsl:text>&#32;z</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="aboveSilouette">
        <mask xmlns="http://www.w3.org/2000/svg" id="fademaskAboveSilouette">
            <rect xmlns="http://www.w3.org/2000/svg" fill="url(#doubleFading2)">
                <xsl:attribute name="x">
                    <xsl:value-of select="$Ox + 8"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Oy + 120"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of
                        select="($Ox + 90) - ($Ox + 8) + $leftBoardThickness + $bookblockThickness + $rightBoardThickness + (($Ox + 90) - ($Ox + 8))"
                    />
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="/book/dimensions/height + 20"/>
                </xsl:attribute>
            </rect>
        </mask>
        <path xmlns="http://www.w3.org/2000/svg" mask="url(#fademaskAboveSilouette)">
            <xsl:attribute name="stroke-dasharray">
                <xsl:choose>
                    <xsl:when
                        test="boolean(/book/spine/lining/yes/lining/liningJoints[outsideBoards | NC | NK])">
                        <xsl:text>1&#32;1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0&#32;0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>line4</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 10"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 10"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
                <xsl:text>&#32;M</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness + (($Ox + 90) - ($Ox + 10))"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness + (($Ox + 90) - ($Ox + 10))"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" mask="url(#fademaskAboveSilouette)">
            <xsl:attribute name="stroke-dasharray">
                <xsl:choose>
                    <xsl:when
                        test="boolean(/book/spine/lining/yes/lining/types/type[overall | comb | panel | continuous | NC | NK])">
                        <xsl:text>1&#32;1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0&#32;0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>line4</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>&#32;M</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130"/>
                <xsl:text>&#32;M</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + 130 + /book/dimensions/height"/>
            </xsl:attribute>
        </path>
        <xsl:call-template name="liningAbove">
            <xsl:with-param name="bookHeight" select=" /book/dimensions/height"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="liningAbove">
        <xsl:param name="bookHeight"/>
        <xsl:for-each select="/book/spine/lining/yes/lining">
            <xsl:variable name="dashArray">
                <xsl:choose>
                    <xsl:when test="last()">
                        <xsl:text>0&#32;0</xsl:text>
                    </xsl:when>
                    <xsl:when test="position() eq last() - 1">
                        <xsl:text>1&#32;2</xsl:text>
                    </xsl:when>
                    <xsl:when test="position() eq last() - 2">
                        <xsl:text>3&#32;2&#32;1&#32;2</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>5&#32;2</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>Lining number:</xsl:text>
                <xsl:value-of select="position()"/>
            </desc>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                mask="url(#fademaskAboveSilouette)">
                <xsl:attribute name="stroke-dasharray">
                    <xsl:value-of select="$dashArray"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <!--<!-\- Certainty adjustment -\->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>-->
                <xsl:attribute name="d">
                    <xsl:call-template name="liningAbovePath">
                        <xsl:with-param name="bookHeight" select="$bookHeight"/>
                    </xsl:call-template>
                </xsl:attribute>
            </path>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="liningAbovePath">
        <xsl:param name="bookHeight"/>
        <xsl:choose>
            <xsl:when test="types/type/overall">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 90 - 70"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness + 70"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness + 70"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130 + $bookHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 90 - 70"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130 + $bookHeight"/>
                <xsl:text>&#32;z</xsl:text>
            </xsl:when>
            <xsl:when test="types/type/transverse">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/comb">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/panel">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/patch">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/continuous">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of
                    select="$Ox + 90 + $leftBoardThickness + $bookblockThickness + $rightBoardThickness"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130 + $bookHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + 90"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy +130 + $bookHeight"/>
                <xsl:text>&#32;z</xsl:text>
            </xsl:when>
            <xsl:when test="types/type/NC">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/NK">
                <!-- Do something -->
            </xsl:when>
            <xsl:when test="types/type/other">
                <!-- Do something -->
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
