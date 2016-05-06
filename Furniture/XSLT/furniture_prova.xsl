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

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:variable name="Px" select="$Ox + 20"/>
    <xsl:variable name="Py" select="$Oy + 20"/>

    <!-- Only a portion of the book width is drawn: this parameter selects the length -->
    <xsl:param name="boardLength" select="50"/>

    <!-- Gap between furniture frames -->
    <xsl:variable name="gap">
        <xsl:value-of select="20"/>
    </xsl:variable>

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

    <xsl:template name="main" match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template match="book/furniture">
        <xsl:choose>
            <xsl:when test="NC | no | NK | other">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="NC">
                            <xsl:text>Presence of furniture not checked</xsl:text>
                        </xsl:when>
                        <xsl:when test="no">
                            <xsl:text>No furniture present</xsl:text>
                        </xsl:when>
                        <xsl:when test="NK">
                            <xsl:text>Presence of furniture not known</xsl:text>
                        </xsl:when>
                        <xsl:when test="other">
                            <xsl:text>The presence of furniture was not described because: </xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:when>
                    </xsl:choose>
                </desc>
            </xsl:when>
            <xsl:when test="yes">
                <xsl:choose>
                    <xsl:when
                        test="yes/furniture[type[clasp[type[stirrupRing | NK]] | pin | straps[type[tripleBraidedStrap | NK | doubleBraidedStrap | flat | other]]]]">
                        <xsl:variable name="group" select="1"/>
                        <xsl:choose>
                            <xsl:when
                                test="(yes/furniture/type/clasp/type[NK] and yes/furniture[type[pin | straps[type[tripleBraidedStrap | doubleBraidedStrap]]]]) or (yes/furniture/type/straps[type[NK | flat | other]] and yes/furniture[type[pin | clasp[type[stirrupRing]]  | pin ]]) or (yes/furniture[type[clasp[type[stirrupRing]] | pin | straps[type[tripleBraidedStrap | doubleBraidedStrap]]]])">
                                <!-- Each group of furniture is drawn on a different file -->
                                <xsl:variable name="filename"
                                    select="concat('../../Transformations/Furniture/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'furniture', '_', $group, '.svg')"/>
                                <xsl:result-document href="{$filename}" method="xml" indent="yes"
                                    encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                                    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                                    <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Furniture/CSS/style.css"&#32;</xsl:text>
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
                                        xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"
                                        x="0" y="0" width="1189mm" height="841mm"
                                        viewBox="0 0 1189 841" preserveAspectRatio="xMidYMid meet">
                                        <title>Furniture of book: <xsl:value-of select="$shelfmark"
                                            /></title>
                                        <xsl:copy-of
                                            select="document('../SVGmaster/furnitureSVGmaster.svg')/svg:svg/svg:defs"
                                            xpath-default-namespace="http://www.w3.org/2000/svg"
                                            copy-namespaces="no"/>
                                        <desc xmlns="http://www.w3.org/2000/svg">Furniture of book:
                                                <xsl:value-of select="$shelfmark"/></desc>
                                        <svg>
                                            <xsl:attribute name="x">
                                                <xsl:value-of select="$Ox"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="y">
                                                <xsl:value-of select="$Oy"/>
                                            </xsl:attribute>
                                                <g xmlns="http://www.w3.org/2000/svg">
                                                    <pippo999>
                                                        <xsl:copy-of select=""></xsl:copy-of>
                                                    </pippo999>
                                                  <!-- call furniture template -->
                                                  <xsl:call-template name="boardLocation"/>
                                                    <xsl:call-template name="types">
                                                        <xsl:with-param name="boardThickness1" select="$rightBoardThickness"/>
                                                        <xsl:with-param name="boardThickness2" select="$leftBoardThickness"/>
                                                    </xsl:call-template>
                                                </g>
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="yes/furniture[type[clasp[type[NK | simpleHook | foldedHook]] | catchplate[type[rollerRoundBar | raisedLip | bentAndSlotted | other | NK]] | straps[type[NK | flat | other]] | strapPlates | strapCollars]]">
                        <xsl:variable name="group" select="2"/>
                        <xsl:choose>
                            <xsl:when
                                test="(yes/furniture/type/clasp/type[NK] and yes/furniture[type[catchplate | strapPlates | strapCollars]]) or (yes/furniture/type/straps[type[NK | flat | other]] and yes/furniture[type[catchplate | clasp[type[simpleHook | foldedHook]] | strapPlates | strapCollars]]) or (yes/furniture[type[clasp[type[simpleHook | foldedHook]] | catchplate[type[rollerRoundBar | raisedLip | bentAndSlotted | other | NK]] | straps[type[flat | NK]] | strapPlates | strapCollars]])">
                                <!-- Each group of furniture is drawn on a different file -->
                                <xsl:variable name="filename"
                                    select="concat('../../Transformations/Furniture/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'furniture', '_', $group, '.svg')"/>
                                <xsl:result-document href="{$filename}" method="xml" indent="yes"
                                    encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                                    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                                    <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Furniture/CSS/style.css"&#32;</xsl:text>
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
                                        xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"
                                        x="0" y="0" width="1189mm" height="841mm"
                                        viewBox="0 0 1189 841" preserveAspectRatio="xMidYMid meet">
                                        <title>Furniture of book: <xsl:value-of select="$shelfmark"
                                            /></title>
                                        <xsl:copy-of
                                            select="document('../SVGmaster/furnitureSVGmaster.svg')/svg:svg/svg:defs"
                                            xpath-default-namespace="http://www.w3.org/2000/svg"
                                            copy-namespaces="no"/>
                                        <desc xmlns="http://www.w3.org/2000/svg">Furniture of book:
                                                <xsl:value-of select="$shelfmark"/></desc>
                                        <svg>
                                            <xsl:attribute name="x">
                                                <xsl:value-of select="$Ox"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="y">
                                                <xsl:value-of select="$Oy"/>
                                            </xsl:attribute>
                                                <g xmlns="http://www.w3.org/2000/svg">
                                                  <!-- call furniture template -->
                                                  <xsl:call-template name="boardLocation"/>
                                                    <xsl:call-template name="types">
                                                        <xsl:with-param name="boardThickness1" select="$rightBoardThickness"/>
                                                        <xsl:with-param name="boardThickness2" select="$leftBoardThickness"/>
                                                    </xsl:call-template>
                                                </g>                                            
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="yes/furniture[type[bosses | corners | plates | ties]]">
                        <xsl:variable name="group" select="3"/>
                        <!-- NB: check how many times things are drawn -->
                        <xsl:for-each-group
                            select="yes/furniture[type[bosses | corners | plates | ties]]"
                            group-by="type">
                            <xsl:for-each select="type">
                                <!-- Each group of furniture is drawn on a different file -->
                                <xsl:variable name="filename"
                                    select="concat('../../Transformations/Furniture/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'furniture', '_', $group, '.svg')"/>
                                <xsl:result-document href="{$filename}" method="xml" indent="yes"
                                    encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                                    doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                                    <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Furniture/CSS/style.css"&#32;</xsl:text>
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
                                        xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"
                                        x="0" y="0" width="1189mm" height="841mm"
                                        viewBox="0 0 1189 841" preserveAspectRatio="xMidYMid meet">
                                        <title>Furniture of book: <xsl:value-of select="$shelfmark"
                                            /></title>
                                        <xsl:copy-of
                                            select="document('../SVGmaster/furnitureSVGmaster.svg')/svg:svg/svg:defs"
                                            xpath-default-namespace="http://www.w3.org/2000/svg"
                                            copy-namespaces="no"/>
                                        <desc xmlns="http://www.w3.org/2000/svg">Furniture of book:
                                                <xsl:value-of select="$shelfmark"/></desc>
                                        <svg>
                                            <xsl:attribute name="x">
                                                <xsl:value-of select="$Ox"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="y">
                                                <xsl:value-of select="$Oy"/>
                                            </xsl:attribute>
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <!-- call furniture template -->
                                                <xsl:call-template name="boardLocation"/>
                                                <xsl:call-template name="types">
                                                    <xsl:with-param name="boardThickness1" select="$rightBoardThickness"/>
                                                    <xsl:with-param name="boardThickness2" select="$leftBoardThickness"/>
                                                </xsl:call-template>
                                            </g>
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:for-each>
                        </xsl:for-each-group>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boardLocation">
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="30"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="30"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <!-- This checks that both boards are present. To allow for dos-a-dos bindings and other bindings with more than 2 boards change test to 'ancestor::boards[1]/board[last() gt 1]' -->
                <xsl:when test="ancestor::book/boards/descendant::board[2]">
                    <!--<xsl:variable name="boardThickness"
                    select="if (descendant::board/location/right) then $rightBoardThickness else $leftBoardThickness"/>-->
                    <xsl:variable name="location">
                        <xsl:value-of
                            select="ancestor::book/boards/descendant::board/location/node()/name()"
                        />
                    </xsl:variable>
                    <xsl:call-template name="boardCrossSection">
                        <xsl:with-param name="boardThickness" select="$rightBoardThickness"/>
                        <xsl:with-param name="location" select="$location"/>
                        <xsl:with-param name="certainty" select="100"/>
                    </xsl:call-template>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Ox + $boardLength * 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>) scale(-1,1)</xsl:text>
                        </xsl:attribute>
                        <xsl:call-template name="boardCrossSection">
                            <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                            <xsl:with-param name="location" select="$location"/>
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                    </g>
                    <!--<xsl:call-template name="types">
                        <xsl:with-param name="boardThickness1" select="$rightBoardThickness"/>
                        <xsl:with-param name="boardThickness2" select="$leftBoardThickness"/>
                    </xsl:call-template>-->
                </xsl:when>
                <xsl:when test="ancestor::book/boards/descendant::boards[not(board[2])]">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::book/boards/descendant::board/location[left | right]">
                            <xsl:variable name="boardThickness"
                                select="if (ancestor::book/boards/descendant::board/location/right) then $rightBoardThickness else $leftBoardThickness"/>
                            <xsl:variable name="location">
                                <xsl:value-of
                                    select="ancestor::book/boards/descendant::board/location/node()/name()"/>
                            </xsl:variable>
                            <xsl:variable name="locationCopied">
                                <xsl:value-of
                                    select="concat('Board not pesent, diagram copied from', $location)"
                                />
                            </xsl:variable>
                            <xsl:call-template name="boardCrossSection">
                                <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                <xsl:with-param name="location"
                                    select="if (ancestor::book/boards/descendant::board/location/right) then $location else $locationCopied"/>
                                <xsl:with-param name="certainty"
                                    select="if (ancestor::book/boards/descendant::board/location/right) then xs:integer(100) else xs:integer(40)"
                                />
                            </xsl:call-template>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Ox + $boardLength * 4"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy"/>
                                    <xsl:text>) scale(-1,1)</xsl:text>
                                </xsl:attribute>
                                <xsl:call-template name="boardCrossSection">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    <xsl:with-param name="location"
                                        select="if (ancestor::book/boards/descendant::board/location/left) then $location else $locationCopied"/>
                                    <xsl:with-param name="certainty"
                                        select="if (ancestor::book/boards/descendant::board/location/left) then xs:integer(100) else xs:integer(40)"
                                    />
                                </xsl:call-template>
                            </g><!--
                            <xsl:call-template name="types">
                                <xsl:with-param name="boardThickness1" select="$boardThickness"/>
                                <xsl:with-param name="boardThickness2" select="$boardThickness"/>
                            </xsl:call-template>-->
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
                            <xsl:value-of select="$Ox + $boardLength * 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>) scale(-1,1)</xsl:text>
                        </xsl:attribute>
                        <xsl:call-template name="boardCrossSection">
                            <xsl:with-param name="boardThickness" select="$leftBoardThickness"/>
                            <xsl:with-param name="location" select="$location"/>
                            <xsl:with-param name="certainty" select="xs:integer(40)"/>
                        </xsl:call-template>
                    </g><!--
                    <xsl:call-template name="types">
                        <xsl:with-param name="boardThickness1" select="$rightBoardThickness"/>
                        <xsl:with-param name="boardThickness2" select="$leftBoardThickness"/>
                    </xsl:call-template>-->
                </xsl:when>
            </xsl:choose>
        </g>
    </xsl:template>

    <xsl:template name="boardCrossSection">
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
            stroke="url(#fading)" stroke-width="2" fill="url(#thicknessCutoutTile)"
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
    </xsl:template>

    <xsl:template name="boardPath">
        <xsl:param name="boardThickness"/>
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$Ox"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy + $boardThickness"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ox + $boardLength"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="
                    if (ancestor::book/boards/descendant::formation/bevels[cushion | peripheralCushion]) 
                    then $Oy + ($boardThickness div 4) 
                    else $Oy"
                />
        <xsl:choose>
            <xsl:when test="ancestor::book/boards/descendant::formation/bevels/cushion">
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
            <xsl:when test="ancestor::book/boards/descendant::formation/bevels/peripheralCushion">
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

    <xsl:template name="types">
        <xsl:param name="boardThickness1"/>
        <xsl:param name="boardThickness2"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Furniture:</xsl:text>
            <xsl:value-of select="type/node()/name()"/>
            <xsl:choose>
                <xsl:when test="type/node()/type">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="type/node()/type/node()/name()"/>
                </xsl:when>
            </xsl:choose>
        </desc>
        <pippo2>
            <xsl:copy-of select="current()"/>
        </pippo2>
        <xsl:choose>
            <xsl:when test="yes/furniture/type/NC">
                <!-- It makes little sense to draw something here just for the sake of it. 
                        Add a note that furniture was detected but the type was not recorded -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Furniture was detected but the type was not recorded</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp">
                <xsl:call-template name="claps"/>
            </xsl:when>
            <xsl:when test="yes/furniture/type/catchplate">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/pin">                
                <xsl:call-template name="pin">
                    <xsl:with-param name="boardThickness1" select="$boardThickness1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="yes/furniture/type/bosses">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/corners">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/plates">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/fullCover">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/straps">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/strapPlates">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/strapCollars">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/ties">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/articulatedMetalSpines">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="claps">
        <xsl:param name="P_coordinates"/>
        <pippo4></pippo4>
        <xsl:choose>
            <xsl:when test="yes/furniture/type/clasp/type/stirrupRing">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp/type/simpleHook">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp/type/foldedHook">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp/type/piercedStrap">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp/type[NC | NK]">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/clasp/type/other">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="pin">        
        <xsl:param name="boardThickness1"/>
        <pippo3></pippo3>
        <xsl:choose>
            <xsl:when test="yes/furniture/type/pin/type/simplePin">
                <pippo></pippo>
                <path xmlns="http://www.w3.org/2000/svg" stroke-width="1" stroke="#000000">
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Py + $boardThickness1 div 2"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Py + $boardThickness1 div 2"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="yes/furniture/type/pin/type/fastenedPin">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/pin/type[NC | NK]">
                <!--  -->
            </xsl:when>
            <xsl:when test="yes/furniture/type/pin/type/other">
                <!--  -->
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
