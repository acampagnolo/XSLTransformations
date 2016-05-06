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

    <!-- delta between views -->
    <xsl:variable name="delta" select="50"/>

    <!-- Cross-section origin -->
    <xsl:variable name="Ax" select="$Ox + $boardWidth + ($bookblockThickness div 2) + $delta"/>
    <xsl:variable name="Ay" select="$Oy + $delta"/>

    <!-- Outer view origin -->
    <xsl:variable name="Bx" select="$Ax"/>
    <xsl:variable name="By" select="$Ay + $delta"/>

    <!-- Inner view origin -->
    <xsl:variable name="Cx" select="$Bx + $boardWidth + ($bookblockThickness div 2) + $delta"/>
    <xsl:variable name="Cy" select="$By + $coverHeight + $delta"/>

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
        <xsl:value-of
            select="/book/dimensions/width - $raisedBands - $protrudingFurniture - $spineShape"/>
    </xsl:variable>

    <!-- NB: no measurements are given for the height of the board. Only the whole height of the book is given. 
        An estimate is necessary if the board is undersize -->
    <xsl:variable name="coverHeight">
        <xsl:choose>
            <xsl:when test="/book/boards/yes/boards/board/formation/size[not(undersize)]">
                <xsl:value-of select="xs:integer(/book/dimensions/height)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- NB: no indication whether the undersize board is shorter than the book along the hight or width dimension; 
                In the three books with undersize boards (2829, 4598, 4687) these are either not as wide as the bookblock or do not belong to the book.
                Here we have shortned the board a little, but it might not be necessary-->
                <xsl:value-of select="xs:integer(/book/dimensions/height) - 5"/>
            </xsl:otherwise>
        </xsl:choose>
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

    <xsl:variable name="arc_tMin">
        <!-- Coordinates of the starting point of the spine arc -->
        <xtMin>
            <xsl:value-of select="$Ax - ($bookThicknessDatatypeChecker div 2)"/>
        </xtMin>
        <ytMin>
            <xsl:value-of select="$Ay"/>
        </ytMin>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/coverings/yes/cover">
            <xsl:variable name="number">
                <xsl:number/>
            </xsl:variable>
            <xsl:variable name="use">
                <xsl:value-of select="use/node()[2]/name()"/>
            </xsl:variable>
            <xsl:variable name="filename"
                select="concat('../../Transformations/coverings/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'cover', '-', $number, '_', $use, '.svg')"/>
            <xsl:result-document href="{$filename}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/coverings/CSS/style.css"&#32;</xsl:text>
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
                        <xsl:text>Cover (</xsl:text>
                        <xsl:value-of select="$use"/>
                        <xsl:text>) of book: </xsl:text>
                        <xsl:value-of select="$shelfmark"/>
                    </title>
                    <xsl:copy-of
                        select="document('../SVGmaster/coveringsSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Cover (</xsl:text>
                        <xsl:value-of select="$use"/>
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
                            <xsl:apply-templates select="type"/>
                            <!-- <xsl:call-template name="coresX"/>
                            <xsl:call-template name="primarySewing"/>-->
                        </g>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template name="jointWidth">
        <xsl:param name="side"/>
        <xsl:choose>
            <xsl:when
                test="ancestor-or-self::cover/type[overInboard/joints[groovedJoint | steppedJoint] | case/type[adhesive[threePiece | boardsCoverSpineInfill] | lacedAttached/boards]]">
                <!-- Thickness of the board -->
                <xsl:choose>
                    <xsl:when test="$side eq 'left'">
                        <xsl:value-of select="$leftBoardThickness"/>
                    </xsl:when>
                    <xsl:when test="$side eq 'right'">
                        <xsl:value-of select="$rightBoardThickness"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Virtually no joint space -->
                <xsl:choose>
                    <xsl:when test="$side eq 'left'">
                        <xsl:value-of select="2"/>
                    </xsl:when>
                    <xsl:when test="$side eq 'right'">
                        <xsl:value-of select="2"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="type" name="coverType">
        <xsl:call-template name="referenceFramework"/>
        <xsl:choose>
            <xsl:when test=".[NC | NK | other]">
                <!--  -->
            </xsl:when>
            <xsl:when test="case">
                <!--  -->
            </xsl:when>
            <xsl:when test="overInboard">
                <!--  -->
                <xsl:call-template name="overInboardX"/>
            </xsl:when>
            <xsl:when test="drawnOn">
                <!--  -->
            </xsl:when>
            <xsl:when test="guard">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="referenceFramework">
        <xsl:variable name="rightJoint">
            <xsl:call-template name="jointWidth">
                <xsl:with-param name="side" select="'right'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="leftJoint">
            <xsl:call-template name="jointWidth">
                <xsl:with-param name="side" select="'left'"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- Cross-section -->
        <g xmlns="http://www.w3.org/2000/svg" class="line5">
            <!-- <!-\- Half spine - right -\->
            <path xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax - ($bookblockThickness div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                </xsl:attribute>
            </path>
            <!-\- Half spine - left -\->
            <path xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($bookblockThickness div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                </xsl:attribute>
            </path>-->
            <!-- Right cover + joint -->
            <path xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax - ($bookblockThickness div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax - ($bookblockThickness div 2) - $rightJoint - $boardWidth"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:choose>
                        <!-- Check for presence of boards according to the binding style -->
                        <xsl:when
                            test=".[case/type/adhesive[threePiece | boardsCoverSpineInfill] | overInboard]">
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - ($bookblockThickness div 2) - $rightJoint - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + $rightBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax - ($bookblockThickness div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + $rightBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax - ($bookblockThickness div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- do nothing: only draw a reference line -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </path>
            <!-- Left cover + joint -->
            <path xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + ($bookblockThickness div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($bookblockThickness div 2) + $rightJoint + $boardWidth"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:choose>
                        <!-- Check for presence of boards according to the binding style -->
                        <xsl:when
                            test=".[case/type/adhesive[threePiece | boardsCoverSpineInfill] | overInboard]">
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax + ($bookblockThickness div 2) + $rightJoint + $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + $rightBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($bookblockThickness div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + $rightBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($bookblockThickness div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="spineArc">
        <xsl:variable name="arcShape">
            <xsl:choose>
                <xsl:when test="ancestor::book/spine/profile/shape/flat">
                    <!-- flat spine -->
                    <xRadius>
                        <xsl:value-of select="xs:double($bookblockThickness div 2)"/>
                    </xRadius>
                    <yRadius>
                        <xsl:value-of select="$bookblockThickness * .0001"/>
                    </yRadius>
                </xsl:when>
                <xsl:when test="ancestor::book/spine/profile/shape/slightRound">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of
                            select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                        />
                    </xRadius>
                    <yRadius>
                        <xsl:value-of
                            select="if (ancestor::book/spine/profile/joints/angled) then xs:double($bookblockThickness * .3) else xs:double($bookblockThickness * .15)"
                        />
                    </yRadius>
                </xsl:when>
                <xsl:when test="ancestor::book/spine/profile/shape/round">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of
                            select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                        />
                    </xRadius>
                    <yRadius>
                        <xsl:value-of select="xs:double($bookblockThickness * .4)"/>
                    </yRadius>
                </xsl:when>
                <xsl:when test="ancestor::book/spine/profile/shape/heavyRound">
                    <!-- slight round at the spine -->
                    <xRadius>
                        <xsl:value-of
                            select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                        />
                    </xRadius>
                    <yRadius>
                        <xsl:value-of select="xs:double($bookblockThickness * .45)"/>
                    </yRadius>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- half-arc -->
        <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arc_tMin/ytMin"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$Ax - ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay - $arcShape/yRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 1)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - $arcShape/yRadius"/>
                <!--<xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($bookThicknessDatatypeChecker div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - $arcShape/yRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 1)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$arc_tMin/xtMin + $bookThicknessDatatypeChecker"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$arc_tMin/ytMin"/>-->
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="overInboardX">
        <xsl:choose>
            <xsl:when test="overInboard/type[NC | NK | other]">
                <!-- do nothing: not possible to draw something significant or not misleading -->
            </xsl:when>
            <xsl:otherwise>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="overInboard/joints[tightJoint | NC | NK | other]">
                                <xsl:value-of select="-3"/>
                            </xsl:when>
                            <xsl:when test="overInboard/joints/steppedJoint">
                                <xsl:value-of select="-($rightBoardThickness div 2)"/>
                            </xsl:when>
                            <xsl:when test="overInboard/joints/groovedJoint">
                                <xsl:value-of select="-($rightBoardThickness div 3)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <!-- draw spine curvature -->
                    <xsl:call-template name="spineArc"/>
                </g>
                <!-- draw joint -->
                <xsl:choose>
                    <xsl:when test="overInboard/joints[tightJoint | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="overInboard/joints[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 3"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="overInboard/joints/steppedJoint">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="overInboard/joints[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - ($rightBoardThickness div 2)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin - ($rightBoardThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="overInboard/joints/groovedJoint">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="overInboard/joints[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'2'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - ($rightBoardThickness div 3)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin - ($rightBoardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 1"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <!-- draw side covering -->
            </xsl:otherwise>
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
