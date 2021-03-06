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
        select="concat('../../Transformations/Spine/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'spine', '.svg')"/>

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

    <!--<xsl:variable name="leftBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board[2]">
                <xsl:value-of
                    select="xs:integer(/book/boards/yes/boards/board[location/left]/formation/boardThickness)"
                />
            <!-\-<xsl:choose>
                <xsl:when test="/book/boards/yes/boards/board[location/left]/formation/boardThickness[not(NK)]">
                    <xsl:value-of
                        select="/book/boards/yes/boards/board[location/left]/formation/boardThickness"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="
                        if (/book/boards/yes/boards/board[location/right]/formation/boardThickness[not(NK)]) 
                        then /book/boards/yes/boards/board[location/right]/formation/boardThickness 
                        else $bookThicknessDatatypeChecker *.07"/>
                </xsl:otherwise>
            </xsl:choose>-\->
        </xsl:when>
        <xsl:when test="/book/boards/yes/boards[not(board[2])]">
            <xsl:choose>
                <xsl:when test="/book/boards/yes/boards/board[not(left)]">
                    
                        <xsl:value-of select="xs:integer(/book/boards/yes/boards/board[location/right]/formation/boardThickness)"/>
                    
                </xsl:when>              
            </xsl:choose>
        </xsl:when>
            <xsl:otherwise>
                <!-\-<xsl:value-of select="$bookThicknessDatatypeChecker *.07"/>-\->
                <xsl:value-of select="20"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>-->

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


    <!--<xsl:variable name="rightBoardThickness">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board[2]">
                <xsl:choose>
                    <xsl:when test="/book/boards/yes/boards/board[location/right]/formation/boardThickness[not(NK)]">
                        <xsl:value-of
                            select="/book/boards/yes/boards/board[location/right]/formation/boardThickness"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="
                            if (/book/boards/yes/boards/board[location/left]/formation/boardThickness[not(NK)]) 
                            then /book/boards/yes/boards/board[location/left]/formation/boardThickness 
                            else $bookThicknessDatatypeChecker *.07"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="/book/boards/yes/boards[not(board[2])]">
                <xsl:choose>
                    <xsl:when test="/book/boards/yes/boards/board[not(right)]">
                        <xsl:value-of select="
                            if (/book/boards/yes/boards/board[location/left]/formation/boardThickness[not(NK)]) 
                            then /book/boards/yes/boards/board[location/left]/formation/boardThickness 
                            else $bookThicknessDatatypeChecker *.07"/>
                    </xsl:when>              
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$bookThicknessDatatypeChecker *.07"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>-->

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
                    <xsl:call-template name="title"/>
                    <xsl:call-template name="description"/>
                    <g xmlns="http://www.w3.org/2000/svg"
                        transform="scale(2)">
                        <g xmlns="http://www.w3.org/2000/svg"
                            transform="translate(10,50) rotate(-90,50,0)">
                            <xsl:apply-templates/>
                        </g>
                    </g>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <!-- Template that calls the spine arc pipeline of templates for both halves of the bookblock -->
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
            <!-- check for presence of boards and kind of binding -->
            <xsl:when
                test="ancestor::book/coverings/yes/cover/type[case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached/boards] | overInboard]">
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
                        <xsl:call-template name="bookblockOutline">
                            <xsl:with-param name="boardThickness" select="$rightBoardThickness"/>
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
                            <xsl:call-template name="bookblockOutline">
                                <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                            </xsl:call-template>
                        </g>
                    </xsl:when>
                    <xsl:when test="descendant::boards[not(board[2])]">
                        <xsl:choose>
                            <xsl:when test="descendant::board/location[left | right]">
                                <xsl:variable name="boardThickness"
                                    select="if (descendant::board/location/right) then $rightBoardThickness else $leftBoardThickness"/>
                                <xsl:variable name="location">
                                    <xsl:value-of select="descendant::board/location/node()/name()"
                                    />
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
                                <xsl:call-template name="bookblockOutline">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
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
                                        <xsl:value-of
                                            select="- $bookblockThickness - $boardThickness"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                    <xsl:call-template name="boardCrossSection">
                                        <xsl:with-param name="boardThickness"
                                            select="$boardThickness"/>
                                        <xsl:with-param name="location"
                                            select="if (descendant::board/location/left) then $location else $locationCopied"/>
                                        <xsl:with-param name="certainty"
                                            select="if (descendant::board/location/left) then xs:integer(100) else xs:integer(40)"
                                        />
                                    </xsl:call-template>
                                    <xsl:call-template name="bookblockOutline">
                                        <xsl:with-param name="boardThickness"
                                            select="$boardThickness"/>
                                    </xsl:call-template>
                                </g>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::book/boards/no">
                        <!-- do not draw boards but do draw the bookblock outline-->
                        <xsl:call-template name="bookblockOutline">
                            <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                        </xsl:call-template>
                        <!--<xsl:variable name="location">
                            <xsl:value-of select="'No boards present'"/>
                        </xsl:variable>-->
                        <!--<xsl:call-template name="boardCrossSection">
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
                </g>-->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- do not draw boards but do draw the bookblock outline-->
                <xsl:variable name="boardThickness" select="$leftBoardThickness"/>
                <xsl:call-template name="bookblockOutline">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
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
                    <xsl:call-template name="bookblockOutline">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>
                </g>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boardCrossSection">
        <!-- NB: check for presence of boards! otherwise draw without -->
        <xsl:param name="boardThickness"/>
        <xsl:param name="location"/>
        <xsl:param name="certainty" as="xs:integer"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:value-of select="$location"/>
            <xsl:text>&#32;board</xsl:text>
        </desc>
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
            stroke="none" stroke-width="0.2" fill="#DCDCDC" mask="url(#fademaskBoards)">
            <!--<xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>-->
            <!-- TO DO: add uncertainty for NC, NK, other  -->
            <!-- when NC: some uncertainty; when NK or other: uncertainty -->
            <!-- TO DO -->
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'4'"/>
            </xsl:call-template>
            <xsl:attribute name="d">
                <xsl:call-template name="boardPath">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
            stroke="url(#fading)" stroke-opacity="0.1" fill-opacity="0" fill="url(#fading)"
            stroke-width="0.3">
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
    </xsl:template>

    <xsl:template name="bookblockOutline">
        <xsl:param name="boardThickness"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <!--
        <mask xmlns="http://www.w3.org/2000/svg" id="fademaskBoards">
            <path xmlns="http://www.w3.org/2000/svg" fill="url(#fading2)">
                <xsl:attribute name="d">
                    <xsl:call-template name="bookblockOutlinePath">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>
                </xsl:attribute>
            </path>
        </mask>-->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke="url(#fading)"
            stroke-width="0.3" stroke-linejoin="round" stroke-opacity="1" fill-opacity="0.1"
            fill="none">
            <!--<xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>-->
            <!-- TO DO: add uncertainty  -->
            <!-- when NC: some uncertainty; when NK or other: uncertainty -->
            <!-- TO DO -->
            <xsl:attribute name="d">
                <xsl:call-template name="bookblockOutlinePath">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="bookblockOutlinePath">
        <xsl:param name="boardThickness"/>
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$Ox"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$Oy + $boardThickness"/>
        <xsl:choose>
            <!--<xsl:when test="ancestor::book/spine/profile/joints/slight">
                <!-\- slight round at the spine -\->
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
                <xsl:value-of select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"/>
            </xsl:when>-->
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
                <!--
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * .5"/>
                <xsl:text>&#32;L</xsl:text>-->
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
                <xsl:value-of select="$Oy + $boardThickness + 0.01"/>
                <xsl:choose>
                    <xsl:when test="ancestor::book/spine/profile/joints/square">                        
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy"/>
                    </xsl:when>
                </xsl:choose>
                <!--<xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"/>-->
            </xsl:otherwise>
        </xsl:choose>
        <!--<!-\- <xsl:choose>
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
            <xsl:otherwise>-\->
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>z</xsl:text>-->
        <!-- </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>

    <xsl:template name="boardPath">
        <xsl:param name="boardThickness"/>
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$Ox"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$Oy + $boardThickness"/>
        <xsl:choose>
            <!--<xsl:when test="ancestor::book/spine/profile/joints/slight">
                <!-\- slight round at the spine -\->
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
                <xsl:value-of select="
                    if (descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"/>
            </xsl:when>-->
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
                <!-- <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness * .5"/>
                <xsl:text>&#32;L</xsl:text>-->
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
                <xsl:when test="profile/joints[quadrant | acute]">
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
                        <xsl:value-of select="xs:double($boardThickness + $bookblockThickness * 0.5)"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="xs:double($bookblockThickness div 2 + ($boardThickness - $arc_tMin/ytMin))"
                        />
                    </yRadius>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="path">
            <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
                <xsl:attribute name="class">
                    <xsl:text>line4</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <!--
                    <xsl:choose>
                        <xsl:when test="profile/joints[none | flat]">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$arc_tMin/ytMin"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $boardThickness + ($bookblockThickness div 2)"/>
                        </xsl:when>
                        <xsl:otherwise>-->
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$arc_tMin/xtMin"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$arc_tMin/ytMin"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="if (profile/joints/angled) then $Ox + $boardLength *.94 + $arcShape/xRadius else $Ox + $boardLength + $arcShape/xRadius"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="if (profile/joints[none | flat | slight]) then $Oy + 3 - (if (profile/joints/slight) then 5 else 0)  else $Oy"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="if (profile/joints/angled) then $Ox + $boardLength *.94 + $arcShape/xRadius else $Ox + $boardLength + $arcShape/xRadius"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Oy + $boardThickness + (if (profile/shape/slightRound) then $bookblockThickness div 3 else $bookblockThickness div 2)"/>
                    <xsl:choose>
                        <xsl:when test="profile/shape/slightRound">
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (profile/joints/angled) then $Ox + $boardLength *.94 + $arcShape/xRadius else $Ox + $boardLength + $arcShape/xRadius"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $boardThickness + $bookblockThickness div 2"
                            />
                        </xsl:when>
                    </xsl:choose>
                    <!--</xsl:otherwise>
                    </xsl:choose> -->
                </xsl:attribute>
            </path>
        </xsl:variable>
        <xsl:copy-of select="$path"/>
        <xsl:call-template name="trigonometry">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="xRadius" select="$arcShape/xRadius" as="xs:double"/>
            <xsl:with-param name="yRadius" select="$arcShape/yRadius" as="xs:double"/>
            <xsl:with-param name="xtMin" select="$arc_tMin/xtMin"/>
            <xsl:with-param name="ytMin" select="$arc_tMin/ytMin"/>
        </xsl:call-template>
        <!--
        <xsl:call-template name="liningCrossSection">
            <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
            <xsl:with-param name="xRadius" select="$arcShape/xRadius" as="xs:double"/>
            <xsl:with-param name="yRadius" select="$arcShape/yRadius" as="xs:double"/>
            <xsl:with-param name="xtMin" select="$arc_tMin/xtMin"/>
            <xsl:with-param name="ytMin" select="$arc_tMin/ytMin"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="lining/yes/lining/types/type/comb">
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
                    <xsl:copy-of select="$path"/>
                </g>
            </xsl:when>
        </xsl:choose>-->
    </xsl:template>

    <!--<xsl:template name="spineArc">
        <xsl:param name="boardThickness"/>
        <xsl:param name="xRadius" select="$bookblockThickness * .1"/>
        <xsl:param name="yRadius" select="$bookblockThickness div 2 + ($boardThickness div 3)"/>
        <xsl:variable name="arc_tMin">
            <!-\- Coordinates of the starting point of the spine arc -\->
            <xsl:choose>
                <!-\-<xsl:when test="profile/joints/slight">
                    <!-\\- slight round at the spine -\\->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of select="$Oy + $boardThickness * 2 div 3"/>
                    </ytMin>
                </xsl:when>
                <xsl:when test="profile/joints/quadrant">
                    <!-\\- rounded corner at the spine -\\->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of select="$Oy + $boardThickness * .5"/>
                    </ytMin>
                </xsl:when>-\->
                <xsl:when test="profile/joints[slight | quadrant | acute]">
                    <!-\- angled spine edge -\->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness *.375) 
                            else $Oy"/>
                    </ytMin>
                </xsl:when>
                <xsl:when test="profile/joints/angled">
                    <!-\- angled spine edge (mirror of acute) -\->
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength * .9"/>
                    </xtMin>
                    <ytMin>
                                <xsl:value-of select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness div 4) 
                            else $Oy"/>
                    </ytMin>
                </xsl:when>
                <xsl:when test="profile/joints/square">
                    <xtMin>
                        <xsl:value-of select="$Ox + $boardLength"/>
                    </xtMin>
                    <ytMin>
                        <xsl:value-of select="
                            if (ancestor::book/boards//formation/bevels[cushion | peripheralCushion]) 
                            then $Oy + ($boardThickness div 4) 
                            else $Oy"/>
                    </ytMin>
                </xsl:when>
                <xsl:otherwise>
                    <!-\- None, flat, NC, NK, and other have a squared board -\->
                    <!-\- NB. how to pass on the uncertainty of the shape? -\->
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
                <xsl:when test="profile/shape[flat | NK]">
                    <!-\- flat spine -\->
                    <xRadius>
                        <xsl:value-of select="$bookblockThickness * .0001"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="xs:double($bookblockThickness div 2)"
                        />
                    </yRadius>
                </xsl:when>
                <xsl:when test="profile/shape/slightRound">
                    <!-\- slight round at the spine -\->
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
                    <!-\- slight round at the spine -\->
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
                    <!-\- slight round at the spine -\->
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
        <!-\-<path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arc_tMin/ytMin"/>
                <xsl:text>&#32;A</xsl:text>
                <xsl:value-of select="$arcShape/xRadius"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arcShape/yRadius"/>
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
        </path>-\->
        <xsl:call-template name="trigonometry">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="xRadius" select="$arcShape/xRadius" as="xs:double"/>
            <xsl:with-param name="yRadius" select="$arcShape/yRadius" as="xs:double"/>
            <xsl:with-param name="xtMin" select="$arc_tMin/xtMin"/>
            <xsl:with-param name="ytMin" select="$arc_tMin/ytMin"/>
        </xsl:call-template>
    </xsl:template>-->


    <!-- Template to make trigonometric calculations to subdivide the spine arc in a set of coordinates -->
    <xsl:template name="trigonometry">
        <xsl:param name="counter" select="1"/>
        <xsl:param name="boardThickness"/>
        <xsl:param name="sectionThickness" select="1"/>
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
            <!--<xsl:choose>
                <xsl:when test="($bookblockThickness div 2) mod $sectionThickness = 0">
                    <xsl:value-of select="xs:integer(($bookblockThickness div 2) div $sectionThickness)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="xs:integer($bookblockThickness div (($bookblockThickness div 2) - (($bookblockThickness div 2) - (($bookblockThickness div 2) mod $sectionThickness))) div ((($bookblockThickness div 2) - (($bookblockThickness div 2) mod $sectionThickness)) div $sectionThickness) + $sectionThickness)"
                     />
                </xsl:otherwise>
            </xsl:choose>-->
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
                <xsl:choose>
                    <xsl:when test="$counter eq 1">
                        <xsl:call-template name="sectionSpineArcs">
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                            <xsl:with-param name="sectionThickness" select="$sectionThickness"/>
                            <xsl:with-param name="i" select="$i"/>
                            <xsl:with-param name="sections" select="$sections"/>
                            <xsl:with-param name="xtMin" select="$xtMin"/>
                            <xsl:with-param name="ytMin" select="$ytMin"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
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
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sectionSpineArcs">
        <xsl:param name="counter" select="1"/>
        <xsl:param name="boardThickness"/>
        <xsl:param name="sectionThickness"/>
        <xsl:param name="i"/>
        <xsl:param name="sections" as="xs:integer"/>
        <xsl:param name="xtMin"/>
        <xsl:param name="ytMin"/>
        <!-- <path xmlns="http://www.w3.org/2000/svg" stroke="#000000" stroke-width="0.5" fill="none">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:choose>
                    <xsl:when test="$counter eq 1">
                        <xsl:value-of select="$xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$ytMin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="tokenize($i, '; ')[$counter - 1]"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#32;A</xsl:text>
                <!-\-<xsl:value-of
                    select="if (xs:double($bookblockThickness) lt 20) then $sectionThickness * 3 else $sectionThickness * 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="if (xs:double($bookblockThickness) lt 20) then $sectionThickness * 3 else $sectionThickness * 3"/>-\->                
                <!-\- NB: for flat spine the algorithm might work better with equal values for both x and y radii -\->
                <!-\- NB: need to adjust algorithm for thin books: arcs need to be very shallow -\->
                <xsl:value-of
                    select="if ($counter eq 1) then $sectionThickness * 4 else $sectionThickness * 3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="if ($counter eq 1) then $sectionThickness * 2 else $sectionThickness * 3"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="0"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="0"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="1"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="$counter lt $sections">
                <xsl:call-template name="sectionSpineArcs">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    <xsl:with-param name="sectionThickness" select="$sectionThickness"/>
                    <xsl:with-param name="i" select="$i"/>
                    <xsl:with-param name="sections" select="$sections"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>-->
    </xsl:template>

    <xsl:template name="sectionLines">
        <xsl:param name="sections" as="xs:integer"/>
        <xsl:param name="counter" select="1"/>
        <xsl:param name="boardThickness"/>
        <xsl:param name="sectionThickness"/>
        <xsl:param name="i"/>
        <xsl:param name="xRadius" as="xs:double"/>
        <xsl:param name="h"/>
       <!-- <xsl:variable name="sectionSeparation">
            <xsl:value-of select="($bookblockThickness div 2) div $sections"/>
        </xsl:variable>-->
        <!--<path xmlns="http://www.w3.org/2000/svg" stroke="url(#fading)" stroke-width="0.1"
            fill="none">
            <xsl:attribute name="stroke-opacity">
                <xsl:choose>
                    <xsl:when test="$counter eq $sections">
                        <xsl:value-of
                            select="if (ancestor::book/sewing/stations/station/type/unsupported/doubleSequence) then .6 else .3"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select=".6"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:choose>
                    <xsl:when test="$counter eq $sections">
                        <xsl:value-of select="$h + $xRadius"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + $boardThickness + $bookblockThickness div 2"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox + $boardLength * .95"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + $boardThickness + $bookblockThickness div 2"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Oy + $boardThickness + $bookblockThickness div 2 + .001"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="profile/joints[slight | quadrant]">
                                <xsl:choose>
                                    <xsl:when test="profile/shape/flat">
                                        <xsl:choose>
                                            <xsl:when test="$counter lt 2">
                                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                                <xsl:text>&#32;Q</xsl:text>
                                                <xsl:value-of
                                                    select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                                <xsl:text>&#32;</xsl:text>
                                                <xsl:value-of
                                                    select="
                                                    if (profile/joints/slight) 
                                                    then $Ox + $boardLength * .95 - ($boardLength * .1) div $sections * $counter 
                                                    else $Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of select="$Ox"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
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
                                        <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="
                                            if (profile/joints/slight) 
                                            then $Ox + $boardLength * .95 - ($boardLength * .1) div $sections * $counter 
                                            else $Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>              
                            </xsl:when>
                            <xsl:when test="profile/joints/acute">
                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength * .9 + ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength * .9 - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                />
                            </xsl:when>
                            <xsl:when test="profile/joints/angled">
                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength + 1.5*$sectionSeparation + ($bookblockThickness * .001)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                />
                            </xsl:when>
                            <xsl:when test="profile/joints/square">
                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength + $sectionSeparation + ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ox + $boardLength - ($bookblockThickness * .01)  * ($counter)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                />
                            </xsl:when>
                            <xsl:when test="profile/joints[none | flat]">
                                <xsl:value-of select="tokenize($i, '; ')[$counter]"/>
                                <xsl:choose>
                                    <xsl:when test="profile/shape/flat">
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[2]) + .001"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="xs:double(tokenize(tokenize($i, '; ')[$counter], ',')[1])"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Ox + $boardLength * .85 - ($boardLength * .1) div $sections * $counter"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ox"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Oy + $boardThickness + ($sectionSeparation * $counter)"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>-->
        <!--<xsl:choose>
            <xsl:when test="$counter lt $sections">
                <xsl:call-template name="sectionLines">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    <xsl:with-param name="sectionThickness" select="$sectionThickness"/>
                    <xsl:with-param name="i" select="$i"/>
                    <xsl:with-param name="sections" select="$sections"/>
                    <xsl:with-param name="xRadius" select="$xRadius"/>
                    <xsl:with-param name="h" select="$h"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>-->
    </xsl:template>

    <!-- Titling -->
    <xsl:template name="title">
        <xsl:param name="detected" select="0"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Oy + 2 * ($leftBoardThickness + 60)"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 20"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:text>spine profile</xsl:text>
        </text>
    </xsl:template>
    
    <!-- Description -->
    <xsl:template name="description">
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>descText</xsl:text>
            </xsl:attribute>
            <text xmlns="http://www.w3.org/2000/svg" x="{$Ox + 20}" y="{$Oy + 100}">
                <tspan xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Shape: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 45}">
                        <xsl:value-of
                            select="if (book/spine/profile/shape/other) then concat(book/spine/profile/shape/node()[2]/name(), ': ', book/spine/profile/shape/other/text()) else book/spine/profile/shape/node()[2]/name()"
                        />
                    </tspan>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 20}">
                    <xsl:text>Joints: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 45}">
                        <xsl:value-of
                            select="if (book/spine/profile/joints/other) then concat(book/spine/profile/joints/node()[2]/name(), ': ', book/spine/profile/joints/other/text()) else book/spine/profile/joints/node()[2]/name()"
                        />
                    </tspan>
                </tspan>               
            </text>
        </g>
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
