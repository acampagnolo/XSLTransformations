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

    <!-- Section titles delta -->
    <xsl:variable name="text_delta" select="20"/>

    <!-- Cross-section origin -->
    <xsl:variable name="Ax" select="$Ox + $boardWidth + ($bookblockThickness div 2) + $delta"/>
    <xsl:variable name="Ay" select="$Oy + 2*$delta + ($bookblockThickness div 2)"/>

    <!-- Outer view origin -->
    <xsl:variable name="Bx" select="$Ax"/>
    <xsl:variable name="By" select="$Ay + ($bookblockThickness div 2) + $delta"/>

    <!-- Inner view origin -->
    <xsl:variable name="Cx"
        select="$Bx + 2 * ($boardWidth + $jointWidth + ($bookblockThickness div 2)) + $delta"/>
    <xsl:variable name="Cy" select="$By"/>

    <!-- Caps cross-section particular origin -->
    <xsl:variable name="Dx" select="$Ax - 100"/>
    <xsl:variable name="Dy" select="$Ay"/>

    <!-- Turnins width -->
    <xsl:variable name="turninWidth">
        <xsl:value-of select="20"/>
    </xsl:variable>

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
            <!-- checks for greek endbands for protruding endbands -->
            <xsl:when
                test="/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]">
                <xsl:value-of select="xs:integer(/book/dimensions/height) - 10"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xs:integer(/book/dimensions/height)"/>
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

    <xsl:variable name="boardThicknessAverage">
        <xsl:value-of select="($leftBoardThickness + $rightBoardThickness) div 2"/>
    </xsl:variable>


    <!-- Coordinates of the starting point of the spine arc -->
    <xsl:variable name="arc_tMin">
        <xtMin>
            <xsl:value-of select="$Ax"/>
        </xtMin>
        <ytMin>
            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
        </ytMin>
    </xsl:variable>

    <xsl:variable name="jointWidth" as="xs:double">
        <xsl:choose>
            <xsl:when
                test="/book/coverings/yes/cover/type[overInboard/joints[groovedJoint | steppedJoint] | case/type[adhesive[threePiece | boardsCoverSpineInfill] | lacedAttached/boards]]">
                <!-- Thickness of the board -->
                <xsl:value-of select="3 + $boardThicknessAverage"/>
            </xsl:when>
            <xsl:when
                test="/book/coverings/yes/cover/type[case/joints[spineCrease[jointCrease[yes | NC | NK | other]] | groovedJoint]]">
                <xsl:value-of select="5"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Virtually no joint space -->
                <xsl:value-of select="0.5"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Spine shape arc radius -->
    <xsl:variable name="arcShape">
        <xsl:choose>
            <xsl:when test="/book/spine/profile/shape[flat | NK]">
                <!-- flat spine -->
                <xRadius>
                    <xsl:value-of select="$bookThicknessDatatypeChecker * .0001"/>
                </xRadius>
                <yRadius>
                    <xsl:value-of select="xs:double($bookThicknessDatatypeChecker div 2)"/>
                </yRadius>
            </xsl:when>
            <xsl:when test="/book/spine/profile/shape/slightRound">
                <!-- slight round at the spine -->
                <xRadius>
                    <xsl:value-of
                        select="if (/book/spine/profile/joints/angled) then xs:double($bookThicknessDatatypeChecker * .3) else xs:double($bookThicknessDatatypeChecker * .15)"
                    />
                </xRadius>
                <yRadius>
                    <xsl:value-of
                        select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                    />
                </yRadius>
            </xsl:when>
            <xsl:when test="/book/spine/profile/shape/round">
                <xRadius>
                    <xsl:value-of select="xs:double($bookThicknessDatatypeChecker * .4)"/>
                </xRadius>
                <yRadius>
                    <xsl:value-of
                        select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                    />
                </yRadius>
            </xsl:when>
            <xsl:when test="/book/spine/profile/shape/heavyRound">
                <xRadius>
                    <xsl:value-of select="xs:double(($bookThicknessDatatypeChecker div 2))"/>
                </xRadius>
                <yRadius>
                    <xsl:value-of
                        select="xs:double(($bookThicknessDatatypeChecker div 2) + $arc_tMin/xtMin)"
                    />
                </yRadius>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:choose>
            <xsl:when test="book/coverings/yes/cover">
                <xsl:for-each select="book/coverings/yes/cover">
                    <xsl:variable name="number">
                        <xsl:number/>
                    </xsl:variable>
                    <xsl:variable name="use">
                        <xsl:value-of select="use/node()[2]/name()"/>
                    </xsl:variable>
                    <xsl:variable name="filename"
                        select="concat('../../Transformations/coverings/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'cover', '-', $number, '_', $use, '.svg')"/>
                    <xsl:result-document href="{$filename}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
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
                        <svg xmlns="http://www.w3.org/2000/svg"
                            xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0" y="0"
                            width="10000mm" height="10000mm" viewBox="0 0 10000 10000"
                            preserveAspectRatio="xMidYMid meet">
                            <title>
                                <xsl:text>Cover (</xsl:text>
                                <xsl:value-of select="$use"/>
                                <xsl:text>) of book: </xsl:text>
                                <xsl:value-of select="$shelfmark"/>
                            </title>
                            <xsl:copy-of
                                select="document('../SVGmaster/coveringsSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg"
                                copy-namespaces="no"/>
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>Cover (</xsl:text>
                                <xsl:value-of select="$use"/>
                                <xsl:text>) of book: </xsl:text>
                                <xsl:value-of select="$shelfmark"/>
                            </desc>
                            <xsl:call-template name="title">
                                <xsl:with-param name="detected" select="1"/>
                                <xsl:with-param name="use" select="$use"/>
                            </xsl:call-template>
                            <xsl:call-template name="description"/>
                            <svg>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ox"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Oy"/>
                                </xsl:attribute>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!--<xsl:choose>
                                <xsl:when
                                    test="type/case/type/adhesive/threePiece or preceding-sibling::cover/type/case/type/adhesive/threePiece">
                                    <xsl:for-each select="ancestor::coverings/yes/cover">
                                        <xsl:apply-templates select="type"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="type"/>
                                </xsl:otherwise>
                            </xsl:choose>-->
                                    <!-- Section titles -->
                                    <xsl:call-template name="sectionTitle">
                                        <xsl:with-param name="class" select="'noteText'"/>
                                        <xsl:with-param name="x" select="$Ax"/>
                                        <xsl:with-param name="y"
                                            select="$Ay - ($bookblockThickness div 2) - (if (/book/coverings/yes/cover/type/case/type/laceAttached/coverLining) then $text_delta else $text_delta div 3)"/>
                                        <xsl:with-param name="text" select="'cross section'"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="sectionTitle">
                                        <xsl:with-param name="class" select="'noteText'"/>
                                        <xsl:with-param name="x"
                                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                                        <xsl:with-param name="y" select="$By - $text_delta div 3"/>
                                        <xsl:with-param name="text" select="'outer view'"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="sectionTitle">
                                        <xsl:with-param name="class" select="'noteText'"/>
                                        <xsl:with-param name="x"
                                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                                        <xsl:with-param name="y" select="$Cy - $text_delta div 3"/>
                                        <xsl:with-param name="text" select="'inner view'"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="type"/>
                                </g>
                            </svg>
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

    <xsl:template match="type" name="coverType">
        <xsl:call-template name="boards"/>
        <xsl:choose>
            <xsl:when test=".[NC | NK | other]"> </xsl:when>
            <xsl:when test="case">
                <xsl:choose>
                    <xsl:when test="case/type/adhesive[onePiece | NC | NK | other]">
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty">
                                <xsl:choose>
                                    <xsl:when test="case/type/adhesive[NC | NK | other]">
                                        <xsl:value-of select="50"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="100"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                    </xsl:when>
                    <xsl:when test="case/type/adhesive/threePiece">
                        <xsl:call-template name="caseX_threePiece"/>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                    </xsl:when>
                    <xsl:when test="case/type/adhesive/boardsCoverSpineInfill">
                        <xsl:call-template name="caseX_boardsCoverSpineInfill">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                    </xsl:when>
                    <xsl:when
                        test="case/type[laceAttached[limpLaced | NC | NK | other] | NC | NK | other]">
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty">
                                <xsl:choose>
                                    <xsl:when
                                        test="case/type[laceAttached[NC | NK | other] | NC | NK | other]">
                                        <xsl:value-of select="50"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="100"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="lacingX"/>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                        <xsl:call-template name="lacing"/>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/tacketed">
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="tacketingX"/>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                        <xsl:call-template name="tacketing"/>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/lacedAndTacketed">
                        <!-- NB: not enough info to actually draw lacing and tacketing -->
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                        <xsl:call-template name="lacing"/>
                        <xsl:call-template name="tacketing"/>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/coverLining">
                        <xsl:call-template name="caseX_coverLining">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="lacingX">
                            <xsl:with-param name="type" select="'double'"/>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                        <xsl:call-template name="lacing">
                            <xsl:with-param name="type" select="'double'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/boards">
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="lacingX"/>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                        <xsl:call-template name="lacing"/>
                    </xsl:when>
                    <xsl:when test="case/type/externalSupport">
                        <pippo/>
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                    </xsl:when>
                    <xsl:when test="case/type/longstitch">
                        <xsl:call-template name="caseX">
                            <xsl:with-param name="certainty" select="100"/>
                        </xsl:call-template>
                        <xsl:call-template name="outerView"/>
                        <xsl:call-template name="innerView"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="overInboard">
                <xsl:call-template name="overInboardX"/>
                <xsl:call-template name="outerView"/>
                <xsl:call-template name="innerView"/>
                <xsl:call-template name="overInbooard_caps"/>
            </xsl:when>
            <xsl:when test="drawnOn">
                <xsl:call-template name="caseX">
                    <xsl:with-param name="certainty" select="100"/>
                    <xsl:with-param name="drawTurnins" select="'no'"/>
                </xsl:call-template>
                <xsl:call-template name="outerView"/>
                <xsl:call-template name="innerView"/>
            </xsl:when>
            <xsl:when test="guard">
                <xsl:call-template name="caseX">
                    <xsl:with-param name="certainty" select="100"/>
                    <xsl:with-param name="drawTurnins" select="'no'"/>
                </xsl:call-template>
                <xsl:call-template name="outerView"/>
                <xsl:call-template name="innerView"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="boards">
        <xsl:choose>
            <!-- Check for presence of boards according to the binding style -->
            <xsl:when
                test=".[case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached/boards] | overInboard]">
                <!-- Left board -->
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ax + $jointWidth + 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ay - ($bookblockThickness div 2)"/>
                        <xsl:text>)</xsl:text>
                        <xsl:choose>
                            <xsl:when test="case/type/laceAttached/boards">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="-0.3"/>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <path xmlns="http://www.w3.org/2000/svg" class="lineBoardX" fill="#DCDCDC">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ox + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $leftBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ox + + (if (ancestor::book/spine/profile/joints/acute) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $leftBoardThickness"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                </g>
                <!-- Right board -->
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ax + $jointWidth + 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookblockThickness div 2) - $rightBoardThickness"/>
                        <xsl:text>)</xsl:text>
                        <xsl:choose>
                            <xsl:when test="case/type/laceAttached/boards">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="0.3"/>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <path xmlns="http://www.w3.org/2000/svg" class="lineBoardX" fill="#DCDCDC">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ox + (if (ancestor::book/spine/profile/joints/acute) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ox + $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $rightBoardThickness"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ox + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + $rightBoardThickness"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
            <xsl:otherwise>
                <!-- do nothing: only draw a reference line? -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="spineArc">
        <!-- param to determine if the arc to be drawn is inner or outer or normal (the default value), i.e. as in the case of 'boardsCoverSpineInfill'
            the normal arc is the normal covering arc while the inner one is the one to draw the spine filler -->
        <xsl:param name="type" select="'normal'"/>
        <xsl:param name="counter" select="1"/>
        <!-- spine arc -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Spine arc</xsl:text>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
            <xsl:choose>
                <xsl:when test="$type eq 'inner'">
                    <xsl:choose>
                        <xsl:when test="$counter eq 2">
                            <xsl:attribute name="class">
                                <xsl:text>line_white6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-linecap">
                                <xsl:text>butt</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-linecap">
                                <xsl:text>butt</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$type eq 'support'">
                    <xsl:choose>
                        <xsl:when test="$counter eq 1">
                            <xsl:attribute name="stroke">
                                <xsl:text>#000000</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-width">
                                <xsl:text>1.8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-linecap">
                                <xsl:text>butt</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="fill">
                                <xsl:text>none</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$counter eq 2">
                            <xsl:attribute name="stroke">
                                <xsl:text>#FFFFFF</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-width">
                                <xsl:text>1.8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-linecap">
                                <xsl:text>butt</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="fill">
                                <xsl:text>none</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$counter eq 3">
                            <xsl:attribute name="stroke">
                                <xsl:text>url(#horizontalLines)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-width">
                                <xsl:text>1.8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-linecap">
                                <xsl:text>butt</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="fill">
                                <xsl:text>none</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="stroke-linecap">
                        <xsl:text>round</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <!--<xsl:choose>
                <xsl:when test="ancestor::book/spine/profile/shape[NK | NC]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'4'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>-->
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:choose>
                    <xsl:when test="$type eq 'inner'">
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                    </xsl:when>
                    <xsl:when test="$type eq 'outer'">
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                        <xsl:value-of select="$arc_tMin/ytMin + 0.5"/>
                    </xsl:when>
                    <xsl:when test="overInboard/joints/steppedJoint">
                        <xsl:value-of select="$arc_tMin/ytMin + 1.5"/>
                    </xsl:when>
                    <xsl:when test="$type eq 'inner' or $type eq 'support'">
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                    </xsl:when>
                    <xsl:when test="$type eq 'outer'">
                        <xsl:value-of select="$arc_tMin/ytMin - 3"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$arc_tMin/ytMin - 1"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of
                    select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94) - (if ($type eq 'outer') then 2 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$Ax - $arcShape/xRadius - (if ($type eq 'outer') then 2 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of
                    select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94)  - (if ($type eq 'outer') then 2 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:choose>
                    <xsl:when test="$type eq 'inner'">
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                    </xsl:when>
                    <xsl:when test="$type eq 'outer'">
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker - 0.5"
                        />
                    </xsl:when>
                    <xsl:when test="overInboard/joints/steppedJoint">
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker - 1.5"
                        />
                    </xsl:when>
                    <xsl:when test="$type eq 'inner' or $type eq 'support'">
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                    </xsl:when>
                    <xsl:when test="$type eq 'outer'">
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker + 3"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker + 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="$counter eq 1 and $type eq 'inner'">
                <xsl:call-template name="spineArc">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="type" select="'inner'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$counter eq 1 and $type eq 'support'">
                <xsl:call-template name="spineArc">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="type" select="'support'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$counter eq 2 and $type eq 'support'">
                <xsl:call-template name="spineArc">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="type" select="'support'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="bookblock">
        <!-- param to determine if the arc to be drawn is inner or outer, i.e. as in the case of 'boardsCoverSpineInfill'
            the outer arc is the normal covering arc while the inner one is the one to draw the spine filler -->
        <xsl:param name="type" select="'outer'"/>
        <xsl:variable name="thicknessL">
            <xsl:choose>
                <!-- bindings with boards -->
                <xsl:when
                    test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                    <xsl:value-of select="$leftBoardThickness + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="if (case/preparation/edgeTreatment[turnedIn | NC | NK | other] or following-sibling::turnins/turnin/location[foredgeLeft | foredgeRight]) then 0 else -1"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="thicknessR">
            <xsl:choose>
                <!-- bindings with boards -->
                <xsl:when
                    test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                    <xsl:value-of select="$rightBoardThickness"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="if (case/preparation/edgeTreatment[turnedIn | NC | NK | other] or following-sibling::turnins/turnin/location[foredgeLeft | foredgeRight]) then -1 else -2"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <g xmlns="http://www.w3.org/2000/svg">
            <!--<xsl:attribute name="fill-opacity">
                <xsl:choose>
                    <xsl:when
                        test="self::node()[preceding-sibling::use/secondary]/ancestor::coverings/yes/cover[use/primary]/type/case/type/adhesive/threePiece">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>-->
            <!-- bottom part -->
            <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
                <xsl:attribute name="class">
                    <xsl:text>nolineFilledGrey</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax - $arcShape/xRadius"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of
                                select="$arc_tMin/xtMin - 0.5 + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                            <xsl:value-of
                                select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker - 0.5"/>
                        </xsl:when>
                        <xsl:when test="overInboard/joints/steppedJoint">
                            <xsl:value-of
                                select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker - 1.5"/>
                        </xsl:when>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker + 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- draw right joints -->
                    <xsl:choose>
                        <xsl:when
                            test="node()/joints[tightJoint | spineCrease[jointCrease[no | NA]] | NC | NK | other]">
                            <!-- leave the natural line -->
                        </xsl:when>
                        <xsl:when
                            test="case/joints[spineCrease[jointCrease[yes | NC | NK | other]]]">
                            <!-- leave the natural line -->
                        </xsl:when>
                        <xsl:when test="node()/joints[steppedJoint | groovedJoint]">
                            <!-- leave the natural line -->
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <!-- bindings with boards -->
                        <xsl:when
                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookblockThickness div 2) - $thicknessR"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + 1 + (if (ancestor::book/spine/profile/joints/acute) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookblockThickness div 2) - $thicknessR - 2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookblockThickness div 2) - $thicknessR - 2"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- this draws a Greek-style foredge -->
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$arc_tMin/xtMin + $jointWidth + 1 + $boardWidth - (if (following-sibling::yapp[yes | NC | NK | other]) then 1 else 0)
                        - (if (case/type/adhesive[threePiece[cutFlush | NC | NK | other] or $type eq 'inner']) then 1.5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Ay + ($bookblockThickness div 2)
                        - (if (.[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]) then $thicknessR
                        else (if (following-sibling::turnins/turnin/location[foredgeLeft | foredgeRight] or case/preparation/edgeTreatment[turnedIn | NC | NK | other]) then 1 else 0))
                    - (if (.[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]) then 2 else 0)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$arc_tMin/xtMin + $jointWidth + 1 + $boardWidth - (if (following-sibling::yapp[yes | NC | NK | other]) then 1 else 0)
                        - (if (case/type/adhesive[threePiece[cutFlush | NC | NK | other] or $type eq 'inner']) then 1.5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                </xsl:attribute>
            </path>
            <!-- upper part -->
            <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1">
                <xsl:attribute name="class">
                    <xsl:text>nolineFilledGrey</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax - $arcShape/xRadius"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + 0.5"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of
                                select="$arc_tMin/xtMin - 0.5 + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                            <xsl:value-of select="$arc_tMin/ytMin + 0.5"/>
                        </xsl:when>
                        <xsl:when test="overInboard/joints/steppedJoint">
                            <xsl:value-of select="$arc_tMin/ytMin + 1.5"/>
                        </xsl:when>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of select="$arc_tMin/ytMin"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$arc_tMin/ytMin - 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when
                            test="node()/joints[tightJoint | spineCrease[jointCrease[no | NA]] | NC | NK | other]">
                            <!-- leave the natural line -->
                        </xsl:when>
                        <xsl:when
                            test="case/joints[spineCrease[jointCrease[yes | NC | NK | other]]]">
                            <!-- leave the natural line -->
                        </xsl:when>
                        <xsl:when test="node()/joints[steppedJoint | groovedJoint]">
                            <!-- leave the natural line -->
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <!-- bindings with boards -->
                        <xsl:when
                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookblockThickness div 2) - 1 + $thicknessL"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + 1 + (if (ancestor::book/spine/profile/joints/acute) then 5 else 0)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookblockThickness div 2) - 1 + $thicknessL + 2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookblockThickness div 2) + $thicknessL + 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- this draws a Greek-style foredge -->
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$arc_tMin/xtMin + $jointWidth + 1 + $boardWidth - (if (following-sibling::yapp[yes | NC | NK | other]) then 1 else 0)
                        - (if (case/type/adhesive[threePiece[cutFlush | NC | NK | other] or $type eq 'inner']) then 1.5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Ay - ($bookblockThickness div 2)
                    - (if (.[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]) then 1 else 0) 
                    + (if (.[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]) then $thicknessL
                    else (if (following-sibling::turnins/turnin/location[foredgeLeft | foredgeRight] or case/preparation/edgeTreatment[turnedIn | NC | NK | other]) then 1 else 0))
                    + (if (.[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]) then 2 else 0)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$arc_tMin/xtMin + $jointWidth + 1 + $boardWidth - (if (following-sibling::yapp[yes | NC | NK | other]) then 1 else 0)
                        - (if (case/type/adhesive[threePiece[cutFlush | NC | NK | other] or $type eq 'inner']) then 1.5 else 0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + 0.5"/>
                </xsl:attribute>
            </path>
            <!-- White gaper -->
            <path xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-opacity="1"
                stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/onePiece">
                            <xsl:text>line_white5</xsl:text>
                        </xsl:when>
                        <xsl:when test="case/type/laceAttached/tacketed">
                            <xsl:text>line_white8</xsl:text>
                        </xsl:when>
                        <xsl:when test="drawnOn">
                            <xsl:text>line_grey</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line_white3</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of
                                select="$arc_tMin/xtMin - 0.5 + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                            <xsl:value-of select="$arc_tMin/ytMin + 0.5"/>
                        </xsl:when>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of select="$arc_tMin/ytMin"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$arc_tMin/ytMin - 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax - $arcShape/xRadius"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius div (if (ancestor::book/spine/profile/shape[round | heavyRound]) then 1.05 else 0.94)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of
                                select="$arc_tMin/xtMin - 0.5 + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/joints/angled) then 5 else 0)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                            <xsl:value-of
                                select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker - 0.5"/>
                        </xsl:when>
                        <xsl:when test="$type eq 'inner'">
                            <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker + 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- draw joints -->
                    <xsl:choose>
                        <xsl:when
                            test="case/type/adhesive[threePiece[cutFlush | NC | NK | other] or $type eq 'inner']">
                            <!-- left joint + side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) + (if (case/type/adhesive/threePiece[cutFlush | NC | NK | other]) then 0.5 else 0)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) + $leftBoardThickness + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) + $leftBoardThickness + 1"/>
                            <!-- right joint + side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) - (if (case/type/adhesive/threePiece[cutFlush | NC | NK | other]) then 0.5 else 0)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) - $rightBoardThickness - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) - $rightBoardThickness - 1"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="node()/joints[tightJoint | spineCrease[jointCrease[no | NA]] | NC | NK | other]">
                                    <!-- left joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- right joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                </xsl:when>
                                <xsl:when
                                    test="case/joints[spineCrease[jointCrease[yes | NC | NK | other]]]">
                                    <!-- left joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1.75"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- right joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1.75"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                </xsl:when>
                                <xsl:when test="node()/joints/steppedJoint">
                                    <!-- left joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- shoulder -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 3)"/>
                                    <!-- joint -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + $leftBoardThickness + 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- right joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <!-- shoulder -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 3)"/>
                                    <!-- joint -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - $rightBoardThickness - 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                </xsl:when>
                                <xsl:when test="node()/joints/groovedJoint">
                                    <!-- left joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- shoulder -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 3)"/>
                                    <!-- joint -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <!-- right joint -->
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <!-- shoulder -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 3)"/>
                                    <!-- joint -->
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="overInboardX">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>bookblock</xsl:text>
        </desc>
        <!-- draw bookblock -->
        <xsl:call-template name="bookblock"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>overInboard cross-section</xsl:text>
        </desc>
        <!-- draw spine curvature -->
        <xsl:call-template name="spineArc"/>
        <!-- draw joints -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>joints</xsl:text>
        </desc>
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
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <!-- left joint -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <!-- right joint -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="overInboard/joints/steppedJoint">
                <!-- left joint -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>left joint</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                        <!-- shoulder -->
                        <!--<xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 3)"/>-->
                        <!-- joint -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + $leftBoardThickness + 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                    </xsl:attribute>
                </path>
                <!-- right joint -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>right joint</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                        <!-- shoulder -->
                        <!--<xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 3)"/>-->
                        <!-- joint -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - $rightBoardThickness - 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="overInboard/joints/groovedJoint">
                <!-- left joint -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>left joint</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <!-- shoulder -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 3)"/>
                        <!-- joint -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                    </xsl:attribute>
                </path>
                <!-- right joint -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>right joint</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <!-- shoulder -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 3)"/>
                        <!-- joint -->
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- draw side covering -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>sides</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="overInboard/type[full | NC | NK | other]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="overInboard/type[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <!-- left side -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <!-- right side -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="overInboard/type[half | quarter]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke="url(#fading4)" stroke-width="1" fill="none">
                    <xsl:attribute name="d">
                        <!-- left side -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <!-- right side -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
                <xsl:choose>
                    <xsl:when test="overInboard/type/half">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke="url(#fading)" stroke-width="1" fill="none">
                            <xsl:attribute name="d">
                                <!-- left side corner-->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                <!-- right side corner-->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <!-- Parchment Tips -->
                <xsl:choose>
                    <xsl:when
                        test="overInboard/type/quarter/quarterWithParchmentTips[yes | NC | NK | other]">
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>parchment tips</xsl:text>
                        </desc>
                        <!-- left side -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth - 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5 + $leftBoardThickness + 0.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5 + $leftBoardThickness + 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5 + $leftBoardThickness + 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth - 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 0.5 + $leftBoardThickness + 1"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- right side -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth - 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 0.5 - $rightBoardThickness - 0.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5 - $rightBoardThickness"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5 - $rightBoardThickness"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$arc_tMin/xtMin + $jointWidth + $boardWidth - 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 0.5 - $rightBoardThickness - 1"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
                <!-- second material on side -->
                <xsl:choose>
                    <xsl:when test="count(ancestor-or-self::cover/materials/material) gt 1">
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>second material on side</xsl:text>
                        </desc>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <!-- left side -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                stroke-width="0.3" fill="none">
                                <xsl:attribute name="stroke">
                                    <xsl:choose>
                                        <xsl:when test="overInboard/type/half">
                                            <xsl:text>url(#doubleFading3)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#fading)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <!--<xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>-->
                                <!--<xsl:choose>
                                    <xsl:when test="ancestor::cover/turnins/turnin/location/foredgeLeft">
                                        <!-\- do not add uncertainty for presence of second material on side -\->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'3'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:attribute name="d">
                                    <!--
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>-->
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 4) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + (if (overInboard/type/half) then 2 * ($boardWidth div 3) - 1 else $boardWidth + 1)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + 0.0001"/>

                                    <!--
                                    <xsl:choose>
                                        <xsl:when test="overInboard/type/half">
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3) - 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3) + 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                                        </xsl:when>
                                    </xsl:choose>-->
                                </xsl:attribute>
                            </path>
                            <!-- right side -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                stroke-width="0.3" fill="none">
                                <xsl:attribute name="stroke">
                                    <xsl:choose>
                                        <xsl:when test="overInboard/type/half">
                                            <xsl:text>url(#doubleFading3)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>url(#fading)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <!--<xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="ancestor::cover/turnins/turnin/location/foredgeRight">
                                        <!-\- do not add uncertainty for presence of second material on side -\->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'3'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:attribute name="d">
                                    <!--
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>-->
                                    <xsl:text>&#32;M</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 4) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$arc_tMin/xtMin + $jointWidth + (if (overInboard/type/half) then 2 * ($boardWidth div 3) - 1 else $boardWidth + 1)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 + 0.0001"/>
                                    <!--<xsl:choose>
                                        <xsl:when test="overInboard/type/half">
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3) - 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$arc_tMin/xtMin + $jointWidth + 2 * ($boardWidth div 3) + 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2"/>
                                        </xsl:when>
                                    </xsl:choose>-->
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when
                test="overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                <!-- do not draw turnins -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="turnInsX">
                    <xsl:with-param name="TxL"
                        select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                    <xsl:with-param name="TyL">
                        <xsl:choose>
                            <xsl:when test="overInboard/type/quarter">
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="TxR"
                        select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                    <xsl:with-param name="TyR">
                        <xsl:choose>
                            <xsl:when test="overInboard/type/quarter">
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="boardDelta">
                        <xsl:choose>
                            <xsl:when test="overInboard/type/quarter">
                                <xsl:value-of select="1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="line">
                        <xsl:choose>
                            <xsl:when test="overInboard/type/quarter">
                                <xsl:text>line2</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>line</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="turnInsX">
        <xsl:param name="TxL"/>
        <xsl:param name="TyL"/>
        <xsl:param name="TxR"/>
        <xsl:param name="TyR"/>
        <xsl:param name="boardDelta"/>
        <xsl:param name="line"/>
        <xsl:param name="type"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>turnins cross-section</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when
                test="following-sibling::turnins/turnin/location[NC | NK | other] or case/preparation/edgeTreatment[ NK | other]">
                <!-- Add a little spot of imprecision: there is no way of saying turnins are NOT present 
                    and people have been forced to say NC or NK or OTHER in such cases therefore no turnin will be drawn -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$line"/>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'5'"/>
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$TxL"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$TyL"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$TxL + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$TyL"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$TxR"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$TyR"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$TxR + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$TyR"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="thicknessL">
                    <xsl:choose>
                        <!-- bindings with boards -->
                        <xsl:when
                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                            <xsl:value-of
                                select="$leftBoardThickness + $boardDelta - (if (case/type/laceAttached[boards]) then 0.5 else 0)"
                            />
                        </xsl:when>
                        <xsl:when test="$type eq 'outer'">
                            <xsl:value-of select="2.2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="thicknessR">
                    <xsl:choose>
                        <!-- bindings with boards -->
                        <xsl:when
                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                            <xsl:value-of
                                select="$rightBoardThickness + $boardDelta - (if (case/type/laceAttached[boards]) then 0.5 else 0)"
                            />
                        </xsl:when>
                        <xsl:when test="$type eq 'outer'">
                            <xsl:value-of select="2.2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="overInboard/type[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="case/preparation/edgeTreatment/NC">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'5'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <!-- Left side -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$line"/>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$TxL"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$TyL + $thicknessL + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$TxL - ($boardWidth div 8)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$TyL + $thicknessL + 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- board thickness foredge left -->
                    <xsl:choose>
                        <!-- yapp -->
                        <xsl:when test="following-sibling::yapp[yes | NC | NK | other]">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$line"/>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="following-sibling::yapp[NC | NK | other]">
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'3'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$TxL"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyL"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$TxL + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyL"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$TxL + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyL + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$TxL + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:choose>
                                        <xsl:when
                                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards | coverLining]]]">
                                            <xsl:value-of select="$TyL + 2.5 * ($thicknessL)"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 2.5 * ($thicknessL) + 1"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 2.5 * ($thicknessL)"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + $thicknessL + 1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$TyL + $bookblockThickness div 5"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$TyL + ($bookblockThickness div 5) + 1 "/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + $bookblockThickness div 5"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$line"/>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$TxL"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyL"/>
                                    <xsl:choose>
                                        <xsl:when
                                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards | coverLining]]]">
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 1"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + $thicknessL"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + $thicknessL + 1"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + $thicknessL + 1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxL + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 0.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxL"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyL + 1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </path>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Right side -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$line"/>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$TxL"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$TyR - $thicknessR - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$TxR - ($boardWidth div 8)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$TyR - $thicknessR - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- board thickness foredge right -->
                    <xsl:choose>
                        <!-- yapp -->
                        <xsl:when test="following-sibling::yapp[yes | NC | NK | other]">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$line"/>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="following-sibling::yapp[NC | NK | other]">
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'3'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$TxR"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyR"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$TxR + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyR"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$TxR + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyR - 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$TxR + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:choose>
                                        <xsl:when
                                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards | coverLining]]]">
                                            <xsl:value-of select="$TyR - 2.5 * ($thicknessR)"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 2.5 * ($thicknessR) - 1"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 2.5 * ($thicknessR)"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - $thicknessR - 1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$TyR - $bookblockThickness div 5"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$TyR - ($bookblockThickness div 5) - 1"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - $bookblockThickness div 5"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$line"/>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$TxR"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$TyR"/>
                                    <xsl:choose>
                                        <xsl:when
                                            test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards | coverLining]]]">
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 1"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - $thicknessR"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - $thicknessR - 1"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - $thicknessR - 1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of select="$TxR + 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 0.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$TxR"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$TyR - 1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </path>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="outerView">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Outer view</xsl:text>
        </desc>
        <!-- Spine -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>spine</xsl:text>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$By"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$By"/>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$By + $coverHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$By + $coverHeight"/>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="overInboard or case/type/externalSupport">
                <!-- bands -->
                <!-- draw bands if raised -->
                <xsl:for-each select="ancestor::book/sewing/stations/station[group/current]">
                    <xsl:choose>
                        <xsl:when
                            test="self::station[preparation[piercedHole | singleKnifeCut]]/type/supported[type[single/raised | double]]">
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>bands</xsl:text>
                            </desc>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::book/coverings/yes/cover/type/case/type/externalSupport">
                                        <xsl:attribute name="fill">
                                            <xsl:text>url(#verticalLines)</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke">
                                            <xsl:text>#000000</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-width">
                                            <xsl:text>0.5</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">
                                            <xsl:text>line2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement - (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement - (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) - 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement - (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement - (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement + (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) - 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement + (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) + 3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement + (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$By + measurement + (if (type/supported/type[double]) then 4 else 2)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:when
                            test="ancestor::book/coverings/yes/cover/type/case/type/externalSupport and self::station/type/unsupported/kettleStitch">
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>kettleStitch</xsl:text>
                            </desc>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 0.25"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 0.25"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 0.25"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 0.25"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <!-- tying up -->
        <!--<xsl:choose>
            <xsl:when test="tyingUp/yes">
                <xsl:for-each select="tyingUp/yes/locations/location">
                    <xsl:choose>
                        <xsl:when test=""></xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>-->
        <!-- Joint lines -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>joints</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="node()/joints[tightJoint | NC | NK | other | spineCrease]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="not(case)">
                            <xsl:attribute name="stroke-dasharray">
                                <xsl:text>0.5 2</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="node()/joints[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By  + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                    </xsl:attribute>
                </path>
                <xsl:choose>
                    <xsl:when test="node()/joints/spineCrease/jointCrease/yes">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line3</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="node()/joints[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'6'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="node()/joints[steppedJoint | groovedJoint]">
                <!-- left joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                    </xsl:attribute>
                </path>
                <!-- right joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- Sides -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>sides</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="drawnOn or case">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line5</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when
                test="node()/type[full | NC | NK | other | half | quarter] or case or drawnOn or guard">
                <xsl:choose>
                    <xsl:when test="guard">
                        <!-- do not draw -->                       
                    </xsl:when>
                    <xsl:otherwise>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="node()/type[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'6'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="case/type/adhesive/threePiece[turnedIn]">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="overInboard/type[half | quarter] or guard">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - (if (guard) then 10 else ($boardWidth div 4))"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - (if (guard) then 10 else ($boardWidth div 4))"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + (if (guard) then 10 else ($boardWidth div 4))"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + (if (guard) then 10 else ($boardWidth div 4))"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                        <xsl:choose>
                            <xsl:when test="guard">
                                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                    <xsl:attribute name="class">
                                        <xsl:text>line2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                    <xsl:attribute name="class">
                                        <xsl:text>line5</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="overInboard/type/half">
                                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                    <xsl:attribute name="class">
                                        <xsl:text>line2</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="d">
                                        <!-- right -->
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 2 * ($boardWidth div 3)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + ($boardWidth div 3)"/>
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 2 * ($boardWidth div 3)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$By + $coverHeight - ($boardWidth div 3)"/>
                                        <!-- left -->
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 2 * ($boardWidth div 3)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + ($boardWidth div 3)"/>
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 2 * ($boardWidth div 3)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$By + $coverHeight"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$By + $coverHeight - ($boardWidth div 3)"/>
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <!-- quarter parchment tips -->
        <xsl:choose>
            <xsl:when
                test="overInboard/type/quarter/quarterWithParchmentTips[yes | NC | NK | other]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>parchment tips</xsl:text>
                </desc>
                <!-- left side -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 5"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 5 + $boardWidth div 20"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 5 + $boardWidth div 20"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 5 - $boardWidth div 20"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 5 - $boardWidth div 20"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <!-- do nothing -->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/coverLining">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>lining</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 1"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/longstitch">
                <xsl:call-template name="longstitch_sewing"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="longstitch_sewing">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>sewing lines</xsl:text>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg" filter="url(#warp_big)">
            <xsl:for-each select="ancestor::book/sewing/stations/station[group/current]">
                <xsl:choose>
                    <!-- check for odd stations as the start of the sewing -->
                    <xsl:when test="position() mod 2 = 1">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="fill">
                                <xsl:text>url(#verticalLines2)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="class">
                                <xsl:text>nolineFilled</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) + 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) + 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + following-sibling::station[1]/measurement"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + following-sibling::station[1]/measurement"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template name="innerView">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Inner view</xsl:text>
        </desc>
        <!-- Spine -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>spine</xsl:text>
        </desc>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy"/>
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy + $coverHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy + $coverHeight"/>
            </xsl:attribute>
        </path>
        <!-- Joint lines -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>joints</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="node()/joints[tightJoint | NC | NK | other | spineCrease]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="not(case)">
                            <xsl:attribute name="stroke-dasharray">
                                <xsl:text>1 1</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="node()/joints[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy  + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
                <xsl:choose>
                    <xsl:when test="node()/joints/spineCrease/jointCrease/yes">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line3</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="node()/joints[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'6'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="node()/joints[steppedJoint | groovedJoint]">
                <!-- left joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
                <!-- right joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when
                test=".[case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached/boards] | overInboard]">
                <!-- board lines -->
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>board lines</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- Sides -->
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>sides</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="guard">
                <!-- do not draw -->
            </xsl:when>
            <xsl:otherwise>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="node()/type[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/adhesive/threePiece[turnedIn]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other] or guard">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="case/type/adhesive/threePiece[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - (if (guard) then 10 else $boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - (if (guard) then 10 else $boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + (if (guard) then 10 else $boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + (if (guard) then 10 else $boardWidth div 7)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:choose>
                            <xsl:when test="guard">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
                <xsl:choose>
                    <xsl:when test="guard">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/adhesive/boardsCoverSpineInfill">
                <!-- draw spine infill -->
                <!-- under turn-ins -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="case/preparation/edgeTreatment/turnedIn">
                            <xsl:attribute name="stroke-dasharray">
                                <xsl:text>1 2</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                    </xsl:attribute>
                </path>
                <!-- not under turn-ins -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="overInboard/type[half | quarter]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                        <xsl:choose>
                            <xsl:when test="overInboard/type[half]">
                                <!-- right -->
                                <!-- head -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $turninWidth"/>
                                <!-- tail -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                <!-- foredge -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($boardWidth div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($boardWidth div 3)"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - ($boardWidth div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - ($boardWidth div 3)"/>
                                <!-- left -->
                                <!-- head -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $turninWidth"/>
                                <!-- tail -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                <!-- foredge -->
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($boardWidth div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($boardWidth div 3)"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - ($boardWidth div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $coverHeight - ($boardWidth div 3)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- yapps -->
        <xsl:choose>
            <xsl:when test="following-sibling::yapp[yes | NC | NK | other]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="following-sibling::yapp[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth - 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth - 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
                <!-- double line for thickness -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="following-sibling::yapp[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/preparation/edgeTreatment/other">
                <!-- do not draw turnIns -->
            </xsl:when>
            <xsl:when test="case/preparation/edgeTreatment/not(turnedIn | NC | NK)">
                <xsl:call-template name="turnIns">
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="drawnOn | guard">
                <!-- do not draw turnIns -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line5</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <!-- turnIns -->
                <!--<xsl:choose>
                    <xsl:when
                        test="case or /book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]">
                        <!-\- do not draw turn-ins cuts at the joints -\->
                    </xsl:when>
                    <xsl:otherwise>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="40"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                            <xsl:for-each select="ancestor-or-self::cover/turnins/turnin">
                                <xsl:choose>
                                    <xsl:when test="location/head">
                                        <g xmlns="http://www.w3.org/2000/svg">
                                            <!-\- head turnin left -\->
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke-linecap="round">
                                                <xsl:attribute name="class">
                                                  <xsl:text>line2</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 3"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy + $turninWidth"/>
                                                </xsl:attribute>
                                            </path>
                                            <!-\- head turnin right -\->
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke-linecap="round">
                                                <xsl:attribute name="class">
                                                  <xsl:text>line2</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 3"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy + $turninWidth"/>
                                                </xsl:attribute>
                                            </path>
                                        </g>
                                    </xsl:when>
                                    <xsl:when test="location/tail">
                                        <g xmlns="http://www.w3.org/2000/svg">
                                            <!-\- tail turnin left -\->
                                            <desc xmlns="http://www.w3.org/2000/svg">
                                                <xsl:text>tail turnin left</xsl:text>
                                            </desc>
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke-linecap="round">
                                                <xsl:attribute name="class">
                                                  <xsl:text>line2</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy + $coverHeight"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 3"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth"/>
                                                </xsl:attribute>
                                            </path>
                                        </g>
                                        <g xmlns="http://www.w3.org/2000/svg">
                                            <!-\- tail turnin right -\->
                                            <desc xmlns="http://www.w3.org/2000/svg">
                                                <xsl:text>tail turnin right</xsl:text>
                                            </desc>
                                            <path xmlns="http://www.w3.org/2000/svg"
                                                stroke-linecap="round">
                                                <xsl:attribute name="class">
                                                  <xsl:text>line2</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="d">
                                                  <xsl:text>M</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Cy + $coverHeight"/>
                                                  <xsl:text>&#32;L</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 3"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth"/>
                                                </xsl:attribute>
                                            </path>
                                        </g>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </g>
                    </xsl:otherwise>
                </xsl:choose>-->
                <xsl:call-template name="turnIns"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- quarter parchment tips -->
        <xsl:choose>
            <xsl:when
                test="overInboard/type/quarter/quarterWithParchmentTips[yes | NC | NK | other]">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>parchment tips</xsl:text>
                </desc>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <!-- 1 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 2.5"/>
                        <!-- 2 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 2.5"/>
                        <!-- 3 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 2.5"/>
                        <!-- 4 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 2.5"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="overInboard/type/quarter/quarterWithParchmentTips[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'6'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <!-- 1 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - 2 * ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20 + 5"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 2.5"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5 + $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5 + 2 * ($boardWidth div 20)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20 + 5"/>
                        <!-- 2 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 5 - 2 * ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20 - 5"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 2.5"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5 - $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5 - 2 * ($boardWidth div 20)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20 - 5"/>
                        <!-- 3 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + 2 * ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20 - 5"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 2.5"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5 - $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 5 - 2 * ($boardWidth div 20)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - $boardWidth div 20 - 5"/>
                        <!-- 4 -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + $boardWidth div 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 5 + 2 * ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20 + 5"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 2.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 2.5"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5 + $boardWidth div 20"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + ($boardWidth div 20)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 5 + 2 * ($boardWidth div 20)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 15"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardWidth div 20 + 5"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <!-- do nothing -->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/coverLining">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + ($bookblockThickness div 2) + $jointWidth + $boardWidth - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookblockThickness div 2) - $jointWidth - $boardWidth + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + 1"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="overInbooard_caps">
        <xsl:variable name="Dy" select="$Dy - $bookblockThickness div 2"/>
        <!-- Section title -->
        <xsl:call-template name="sectionTitle">
            <xsl:with-param name="class" select="'noteText3'"/>
            <xsl:with-param name="x" select="$Dx"/>
            <xsl:with-param name="y" select="$Dy - $text_delta"/>
            <xsl:with-param name="text" select="'cap detail:'"/>
        </xsl:call-template>
        <!-- Detail description -->
        <xsl:call-template name="sectionTitle">
            <xsl:with-param name="class" select="'noteText3'"/>
            <xsl:with-param name="x" select="$Dx"/>
            <xsl:with-param name="y" select="$Dy - $text_delta + 5"/>
            <xsl:with-param name="text">
                <xsl:value-of
                    select="if (overInboard/caps/other) 
                    then concat(overInboard/caps/node()[2]/name(), ': ', overInboard/caps/other/text()) 
                    else overInboard/caps/node()[2]/name()"/>
                <xsl:choose>
                    <xsl:when test="overInboard/capCore[yes | NC | NK | other]">
                        <xsl:text> (capCore: </xsl:text>
                        <xsl:value-of
                            select="if (overInboard/capCore/other) 
                    then concat(overInboard/capCore/node()[2]/name(), ': ', overInboard/capCore/other/text()) 
                    else overInboard/capCore/node()[2]/name()"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <!-- cross-section general framework -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke="url(#fading2)">
            <xsl:attribute name="class">
                <xsl:text>lineFading_05</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Dx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Dy"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Dx + 20"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Dy + 0.0001"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
            stroke="url(#fadingDownGrey)">
            <xsl:attribute name="class">
                <xsl:text>lineFading_05</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Dx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Dy"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Dx + 0.0001"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Dy + (if (($bookThicknessDatatypeChecker div 2) ge $turninWidth * 3) then ($bookThicknessDatatypeChecker div 2) else $turninWidth * 3)"
                />
            </xsl:attribute>
        </path>
        <!-- endband -->
        <xsl:choose>
            <xsl:when test="ancestor::book/endbands/yes">
                <circle xmlns="http://www.w3.org/2000/svg" r="2.5">
                    <xsl:attribute name="cx">
                        <xsl:value-of select="$Dx + 3"/>
                    </xsl:attribute>
                    <xsl:attribute name="cy">
                        <xsl:value-of select="$Dy - (if (overInboard/caps/covered) then 6 else 4)"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                </circle>
            </xsl:when>
        </xsl:choose>
        <!-- general section of cap turnin -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
            stroke="url(#fadingDownGrey)">
            <xsl:attribute name="class">
                <xsl:text>lineFading_1</xsl:text>
            </xsl:attribute>
            <!--
            <xsl:choose>
                <xsl:when test="overInboard/caps[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>-->
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of
                    select="$Dx + 0.0001 - 3 + (if (overInboard/caps/covered) then 1.5 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Dy + (if (($bookThicknessDatatypeChecker div 2) ge $turninWidth * 3) then ($bookThicknessDatatypeChecker div 2) else $turninWidth * 3)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Dx - 3  + (if (overInboard/caps/covered) then 1.5 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Dy"/>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="overInboard/caps/not(covered)">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <!--<xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="overInboard/caps[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'5'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>-->
                    <xsl:choose>
                        <xsl:when test="overInboard/caps[NC | NK | other]">
                            <xsl:attribute name="class">
                                <xsl:text>line_grey</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx + 0.0001 - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $turninWidth * 2"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- Caps -->
        <xsl:choose>
            <xsl:when
                test="overInboard/caps[straight | pulledOver | covered | reversed | NC | NK | other]">
                <!-- cross-section -->
                <xsl:choose>
                    <xsl:when test="overInboard/caps[straight | NC | NK | other]">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="overInboard/caps[NC | NK | other]">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'5'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx + 0.0001 - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 4.5 else 1)"/>
                                <xsl:choose>
                                    <xsl:when test="overInboard/capCore[yes | NC | NK]">
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 3"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes) then 8 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 6 else 3.75))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.25"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes) then 8 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 6 else 3.75))"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx + 0.3"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes) then 8 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 6 else 3.75))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx + 0.3"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes) then 6.25 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 4.25 else 1.5))"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes) then 2 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 1 else 0))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Dy"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#32;C</xsl:text>
                                        <xsl:value-of select="$Dx - 3"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7 else 1.5)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7 else 1.5)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 4.5 else 1)"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="overInboard/caps/reversed">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 5.5 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 0.0001 - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 5.5 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx + 0.0001 - 6.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 6 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 0.0001 - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 6.5 else 1)"/>
                                <xsl:text>&#32;C</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7 else 1.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7 else 1.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 6.5 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 6.5 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                    <xsl:when test="overInboard/caps/pulledOver">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx + 0.0001 - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 4.5 else 1)"/>
                                <xsl:choose>
                                    <xsl:when test="overInboard/capCore[yes | NC | NK]">
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 2 "/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 9.5 else 1.5) - 1.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx + 3.5 - 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 9.5 else 1.5) - 1.5"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx + 4.5 + 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 8.5 else 1) - 1.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx + 3.5 - 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 8 else 1) + 0.25"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7.5 else 1.5)"/>

                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Dy"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 9.5 else 1.5)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx + 3.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 9.5 else 1.5)"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx + 4.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 8.5 else 1)"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx + 3.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares  or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 8 else 1)"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of select="$Dx - 2"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$Dy - (if (ancestor::book/endbands/yes or ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares or ancestor::book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]) then 7.5 else 1.5)"/>

                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Dx - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Dy"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                            </xsl:attribute>
                        </path>
                        <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2)"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 1.75"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.75"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) + 1"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Dx - 1.25"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.25"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) + 1"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) - 1"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) + 0.3"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) + 1.3"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($turninWidth div 2) + 2"/>
                            </xsl:attribute>
                        </path>-->
                    </xsl:when>
                    <xsl:when test="overInboard/caps/covered">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 9.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 9.75"/>
                                <!--
                                <xsl:text>&#32;A 3.5,3.5 0,0 1 </xsl:text>
                                <xsl:value-of select="$Dx + 6.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 5.25"/>-->
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx + 6.75"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 9.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 6.75"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 5.25"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Dx + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 2.25"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Dx + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 1.25"/>
                            </xsl:attribute>
                        </path>
                        <!-- Saddle stitch -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx - 3"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx + 8.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy - 2.5"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <!-- outer view -->
                <xsl:choose>
                    <xsl:when
                        test="/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]">
                        <!-- only greek-style bindings with protruding caps need a different profile -->
                        <g xmlns="http://www.w3.org/2000/svg" id="greekCap">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By - 9"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Bx"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By - 9"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By - 9"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekCap">
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(180,</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>)translate(0,</xsl:text>
                                <xsl:value-of select="-$coverHeight"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                    <xsl:when test="overInboard/caps/covered">
                        <!-- Saddle stitch -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="saddleStitch">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="stroke-dasharray">
                                <xsl:text>4 5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) - 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 6"/>
                            </xsl:attribute>
                        </path>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#saddleStitch">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0,</xsl:text>
                                <xsl:value-of select="$coverHeight - 12"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                    <xsl:when test="overInboard/caps/reversed">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="reversedCap">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 0.3"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 0.3"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                            </xsl:attribute>
                        </path>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#reversedCap">
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(180,</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By"/>
                                <xsl:text>)translate(0,</xsl:text>
                                <xsl:value-of select="-$coverHeight"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
                <!-- inner view -->
                <xsl:choose>
                    <xsl:when
                        test="/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore]">
                        <!-- only greek-style bindings with protruding caps need a different profile -->
                        <g xmlns="http://www.w3.org/2000/svg" id="greekCap_innerView">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy - 9"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Cx"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy - 9"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy - 9"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy - 9"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                </xsl:attribute>
                            </path>
                            <!-- board lines -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line3</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + 2"/>
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 6)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + 2"/>
                                </xsl:attribute>
                            </path>
                            <g xmlns="http://www.w3.org/2000/svg" id="innerGreekCap">
                                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                    filter="url(#warp_small)">
                                    <xsl:attribute name="class">
                                        <xsl:text>line4</xsl:text>
                                    </xsl:attribute>
                                    <!--
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>-->
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy + $turninWidth"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 10)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 12)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 12)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                    </xsl:attribute>
                                </path>
                                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                    filter="url(#warp_small)" stroke-dashArray="0.1 0.1">
                                    <xsl:attribute name="class">
                                        <xsl:text>line4</xsl:text>
                                    </xsl:attribute>
                                    <!--
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="50"/>
                                        <xsl:with-param name="type" select="'3'"/>
                                    </xsl:call-template>-->
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy + $turninWidth"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 10)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 12)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy + 2"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 12)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of
                                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 6)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy"/>
                                    </xsl:attribute>
                                </path>
                                <!-- cap turnin -->
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="filter">
                                        <xsl:text>url(#warp_small)</xsl:text>
                                    </xsl:attribute>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy - 9"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + ($turninWidth div 2)"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$Cx"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + ($turninWidth div 2)"/>
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy - 9"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + ($turninWidth div 2)"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$Cx"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + ($turninWidth div 2)"/>
                                        </xsl:attribute>
                                    </path>
                                </g>
                            </g>
                            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#innerGreekCap">
                                <xsl:attribute name="transform">
                                    <xsl:text>scale(-1 1)translate(</xsl:text>
                                    <xsl:value-of
                                        select="- 2*(2*$delta + $jointWidth + 2*$boardWidth + $bookThicknessDatatypeChecker + ($boardWidth - ($boardWidth div 6)))"/>
                                    <xsl:text>, 0) translate(</xsl:text>
                                    <xsl:value-of
                                        select="-2*($boardWidth div 6) - 2*$jointWidth - ($bookThicknessDatatypeChecker)"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                            </use>
                        </g>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#greekCap_innerView">
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(180,</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>)translate(0,</xsl:text>
                                <xsl:value-of select="-$coverHeight"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                    <xsl:when
                        test="overInboard/caps[pulledOver | reversed | straight | covered | NC | NK | other]">
                        <g xmlns="http://www.w3.org/2000/svg" id="pulledOverCap">
                            <xsl:choose>
                                <xsl:when test="overInboard/caps/covered">
                                    <!-- Saddle stitch -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line2</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>5 4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) + 3"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + 6"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) - 3"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + 6"/>
                                        </xsl:attribute>
                                    </path>
                                </xsl:when>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                filter="url(#warp_big)">
                                <!--<xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="overInboard/caps[NC | NK | other]">
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="50"/>
                                            <xsl:with-param name="type" select="'3'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>-->
                                <xsl:choose>
                                    <xsl:when test="overInboard/caps[NC | NK | other]">
                                        <xsl:attribute name="class">
                                            <xsl:text>line_grey</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">
                                            <xsl:text>line2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Cy + (if (overInboard/caps/covered) then 7 else $turninWidth)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Cy + (if (overInboard/caps/covered) then 7 else $turninWidth)"/>
                                    <!--<xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$Cx"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + 2* $turninWidth"/>-->
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Cy + (if (overInboard/caps/covered) then 7 else $turninWidth)"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$Cy + (if (overInboard/caps/covered) then 7 else $turninWidth)"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#pulledOverCap">
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(180,</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>)translate(0,</xsl:text>
                                <xsl:value-of select="-$coverHeight"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!--<xsl:when test="overInboard/caps/straight">
                <!-\- cross-section -\->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy - 2 * $turninWidth"/>
                    </xsl:attribute>
                </path>
                <!-\- outer view -\->
                <g xmlns="http://www.w3.org/2000/svg" id="straightCap_outerview">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line_white3</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of select="$turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$turninWidth"/>
                            <xsl:text>&#32;0,0 1 </xsl:text>
                            <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                        </xsl:attribute>
                    </path>
                </g>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#straightCap_outerview">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(180,</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>)translate(0,</xsl:text>
                        <xsl:value-of select="-$coverHeight"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <!-\- inner view -\->
                <g xmlns="http://www.w3.org/2000/svg" id="straightCap_innerview">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line_white3</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of select="$turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$turninWidth"/>
                            <xsl:text>&#32;0,0 1 </xsl:text>
                            <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                </g>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#straightCap_innerview">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(180,</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>)translate(0,</xsl:text>
                        <xsl:value-of select="-$coverHeight"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>-->
        </xsl:choose>
        <xsl:call-template name="capCore">
            <xsl:with-param name="Dx" select="$Dx"/>
            <xsl:with-param name="Dy" select="$Dy"/>
            <xsl:with-param name="Bx" select="$Bx"/>
            <xsl:with-param name="bookThicknessDatatypeChecker"
                select="$bookThicknessDatatypeChecker"/>
            <xsl:with-param name="By" select="$By"/>
            <xsl:with-param name="coverHeight" select="$coverHeight"/>
            <xsl:with-param name="Cx" select="$Cx"/>
            <xsl:with-param name="Cy" select="$Cy"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="capCore">
        <xsl:param name="Dx"/>
        <xsl:param name="Dy"/>
        <xsl:param name="Bx"/>
        <xsl:param name="bookThicknessDatatypeChecker"/>
        <xsl:param name="By"/>
        <xsl:param name="coverHeight"/>
        <xsl:param name="Cx"/>
        <xsl:param name="Cy"/>
        <!-- Cap cores -->
        <xsl:choose>
            <xsl:when test="overInboard/capCore[yes | NC | NK]">
                <!-- cross-section -->
                <circle xmlns="http://www.w3.org/2000/svg" r="0.75">
                    <xsl:choose>
                        <xsl:when test="overInboard/caps/reversed">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="- 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="1"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="overInboard/caps/pulledOver">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="3.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="-3"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="cx">
                        <xsl:value-of select="$Dx - 1.25"/>
                    </xsl:attribute>
                    <xsl:attribute name="cy">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/endbands/yes) then 6.5 else (if (ancestor::book/boards/yes/boards/board[location[left | right]]/formation/size/squares) then 4.5 else 2.25))"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="overInboard/capCore[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </circle>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="stroke-dasharray">
                        <xsl:text>1 1</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="overInboard/capCore[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <!-- outer view -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                        id="capCore_outerview">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 2"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#capCore_outerview">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$coverHeight - 3"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <!-- inner view -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                        id="capCore_innerview">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 2"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#capCore_innerview">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="$coverHeight - 3"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </g>
            </xsl:when>
            <xsl:when test="overInboard/capCore[no | other]">
                <!-- do nothing -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="turnIns">
        <xsl:param name="certainty" select="100"/>
        <xsl:for-each select="ancestor-or-self::cover/turnins/turnin">
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="50"/>
                            <xsl:with-param name="type" select="'3'"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="location/head">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>head turnin</xsl:text>
                            </desc>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <!-- head turnin left -->
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>head turnin left</xsl:text>
                                </desc>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- NB: sketchy lines: what is uncertain is the shape -->
                                    <xsl:choose>
                                        <xsl:when test="trim[not(neatTrim)]">
                                            <xsl:attribute name="filter">
                                                <xsl:text>url(#warp_big)</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth + 0.00001"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth + 0.00001"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth - 10"/>
                                        </xsl:attribute>
                                    </path>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth + 0.00001"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth + 0.00001"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth - 10"/>
                                        </xsl:attribute>
                                    </path>
                                </g>
                                <!-- head turnin corner left -->
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                        <!-- do not call corners template -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <desc xmlns="http://www.w3.org/2000/svg">
                                            <xsl:text>head turnin corner left</xsl:text>
                                        </desc>
                                        <xsl:call-template name="corners">
                                            <xsl:with-param name="location" select="'headLeft'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </g>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <!-- head turnin right -->
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>head turnin right</xsl:text>
                                </desc>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- NB: sketchy lines: what is uncertain is the shape -->
                                    <xsl:choose>
                                        <xsl:when test="trim[not(neatTrim)]">
                                            <xsl:attribute name="filter">
                                                <xsl:text>url(#warp_big)</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth - 10"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- dashed overlay -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $turninWidth - 10"/>
                                        </xsl:attribute>
                                    </path>
                                </g>
                                <!-- head turnin corner right -->
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                        <!-- do not call corners template -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <desc xmlns="http://www.w3.org/2000/svg">
                                            <xsl:text>head turnin corner right</xsl:text>
                                        </desc>
                                        <xsl:call-template name="corners">
                                            <xsl:with-param name="location" select="'headRight'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </g>
                        </g>
                    </xsl:when>
                    <xsl:when test="location/foredgeLeft">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                <!-- do not draw foredge turnin -->
                            </xsl:when>
                            <xsl:otherwise>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- left foredge turnin -->
                                    <desc xmlns="http://www.w3.org/2000/svg">
                                        <xsl:text>left fore-edge turnin</xsl:text>
                                    </desc>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <!-- NB: sketchy lines: what is uncertain is the shape -->
                                        <xsl:choose>
                                            <xsl:when test="trim[not(neatTrim)]">
                                                <xsl:attribute name="filter">
                                                  <xsl:text>url(#warp_big)</xsl:text>
                                                </xsl:attribute>
                                            </xsl:when>
                                        </xsl:choose>
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round">
                                            <xsl:attribute name="class">
                                                <xsl:text>line4</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke="#FFFFFF"
                                            stroke-opacity="0">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth - 10"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke-dashArray="0.1 0.1">
                                            <xsl:attribute name="class">
                                                <xsl:text>line4</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-dashArray="0.1 0.1">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth - 10"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <!-- left foredge turnin corner -->
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                            <!-- do not call corners template -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <desc xmlns="http://www.w3.org/2000/svg">
                                                <xsl:text>left fore-edge turnin corner</xsl:text>
                                            </desc>
                                            <xsl:call-template name="corners">
                                                <xsl:with-param name="location"
                                                  select="'foredgeLeftHead'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="corners">
                                                <xsl:with-param name="location"
                                                  select="'foredgeLeftTail'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </g>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="location/foredgeRight">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                <!-- do not draw foredge -->
                            </xsl:when>
                            <xsl:otherwise>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- right foredge turnin -->
                                    <desc xmlns="http://www.w3.org/2000/svg">
                                        <xsl:text>right fore-edge turnin</xsl:text>
                                    </desc>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <!-- NB: sketchy lines: what is uncertain is the shape -->
                                        <xsl:choose>
                                            <xsl:when test="trim[not(neatTrim)]">
                                                <xsl:attribute name="filter">
                                                  <xsl:text>url(#warp_big)</xsl:text>
                                                </xsl:attribute>
                                            </xsl:when>
                                        </xsl:choose>
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round">
                                            <xsl:attribute name="class">
                                                <xsl:text>line4</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $turninWidth +  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke="#FFFFFF"
                                            stroke-opacity="0">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth + 10"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke-dashArray="0.1 0.1">
                                            <xsl:attribute name="class">
                                                <xsl:text>line4</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $turninWidth +  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                        <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                        <path xmlns="http://www.w3.org/2000/svg"
                                            stroke-linecap="round" stroke="#FFFFFF"
                                            stroke-opacity="0" stroke-dashArray="0.1 0.1">
                                            <xsl:attribute name="d">
                                                <xsl:text>M</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                                <xsl:text>&#32;L</xsl:text>
                                                <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth + 10"/>
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of
                                                  select="$Cy + $coverHeight - $turninWidth -  (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                />
                                            </xsl:attribute>
                                        </path>
                                    </g>
                                    <!-- right foredge turnin corner -->
                                    <xsl:choose>
                                        <xsl:when
                                            test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                            <!-- do not call corners template -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <desc xmlns="http://www.w3.org/2000/svg">
                                                <xsl:text>right fore-edge turnin corner</xsl:text>
                                            </desc>
                                            <xsl:call-template name="corners">
                                                <xsl:with-param name="location"
                                                  select="'foredgeRightHead'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="corners">
                                                <xsl:with-param name="location"
                                                  select="'foredgeRightTail'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </g>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="location/tail">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <desc xmlns="http://www.w3.org/2000/svg">
                                <xsl:text>tail turnin</xsl:text>
                            </desc>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <!-- tail turnin left -->
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>tail turnin left</xsl:text>
                                </desc>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- NB: sketchy lines: what is uncertain is the shape -->
                                    <xsl:choose>
                                        <xsl:when test="trim[not(neatTrim)]">
                                            <xsl:attribute name="filter">
                                                <xsl:text>url(#warp_big)</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Cy + $coverHeight - $turninWidth + 10"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- dashed overlay -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Cy + $coverHeight - $turninWidth + 10"/>
                                        </xsl:attribute>
                                    </path>
                                </g>
                                <!-- tail turnin corner left -->
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                        <!-- do not call corners template -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <desc xmlns="http://www.w3.org/2000/svg">
                                            <xsl:text>tail turnin corner left</xsl:text>
                                        </desc>
                                        <xsl:call-template name="corners">
                                            <xsl:with-param name="location" select="'tailLeft'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </g>
                            <g xmlns="http://www.w3.org/2000/svg">
                                <!-- tail turnin right -->
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>tail turnin right</xsl:text>
                                </desc>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!-- NB: sketchy lines: what is uncertain is the shape -->
                                    <xsl:choose>
                                        <xsl:when test="trim[not(neatTrim)]">
                                            <xsl:attribute name="filter">
                                                <xsl:text>url(#warp_big)</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Cy + $coverHeight - $turninWidth + 10"/>
                                        </xsl:attribute>
                                    </path>
                                    <!-- dashed overlay -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="class">
                                            <xsl:text>line4</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + (if (ancestor-or-self::cover/type/case) then 0 else ($bookThicknessDatatypeChecker div 2 + $jointWidth + (if (/book/endbands/yes/endband[cores/yes/cores/type/core/boardAttachment/yes/attachment[sewn | adhesive | NC | NK | other]]/primary/yes/construction/type[greekSingleCore | greekDoubleCore])then ($boardWidth div 6) else 0)))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth div 4 "
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"
                                            />
                                        </xsl:attribute>
                                    </path>
                                    <!-- line to make the group thicker than a line so to be able to apply the sketchy line filter -->
                                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                        stroke="#FFFFFF" stroke-opacity="0"
                                        stroke-dashArray="0.1 0.1">
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + $coverHeight - $turninWidth"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of
                                                select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + $boardWidth - $turninWidth - (if (count(ancestor-or-self::cover/type/node()/corners/corner) gt 1) then 0 else (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre | openMitre]) then (if (ancestor-or-self::cover/type/node()/corners/corner[tonguedMitre]) then ($turninWidth div 3) else ($turninWidth div 5)) else 0))"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$Cy + $coverHeight - $turninWidth + 10"/>
                                        </xsl:attribute>
                                    </path>
                                </g>
                                <!-- tail turnin corner right -->
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor-or-self::cover/type/overInboard/type/quarter and count(ancestor-or-self::cover/materials/material) eq 1">
                                        <!-- do not call corners template -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <desc xmlns="http://www.w3.org/2000/svg">
                                            <xsl:text>tail turnin corner right</xsl:text>
                                        </desc>
                                        <xsl:call-template name="corners">
                                            <xsl:with-param name="location" select="'tailRight'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </g>
                        </g>
                    </xsl:when>
                </xsl:choose>
            </g>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="corners">
        <xsl:param name="location"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="transform">
                <xsl:choose>
                    <xsl:when test="$location eq 'foredgeLeftHead'">
                        <xsl:text>scale(-1 1)translate(</xsl:text>
                        <xsl:value-of
                            select="- 2*(2*$delta + $jointWidth + 2*$boardWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>, 0)rotate(90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'headRight'">
                        <xsl:text>scale(-1 1)translate(</xsl:text>
                        <xsl:value-of
                            select="- 2*(2*$delta + $jointWidth + 2*$boardWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>, 0)translate(</xsl:text>
                        <xsl:value-of
                            select="-(2*$boardWidth + 2*$jointWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>, 0)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'foredgeRightHead'">
                        <xsl:text>rotate(90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>)translate(0,</xsl:text>
                        <xsl:value-of
                            select="-(2*$boardWidth + 2*$jointWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'tailLeft'">
                        <xsl:text>scale(-1 1)translate(</xsl:text>
                        <xsl:value-of
                            select="- 2*(2*$delta + $jointWidth + 2*$boardWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>, 0)rotate(90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>)rotate(90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>)translate(0,</xsl:text>
                        <xsl:value-of select="-($coverHeight - 2*$turninWidth)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'foredgeLeftTail'">
                        <xsl:text>rotate(-90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>)translate(</xsl:text>
                        <xsl:value-of select="-($coverHeight - 2*$turninWidth)"/>
                        <xsl:text>, 0)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'tailRight'">
                        <xsl:text>rotate(180,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>)translate(</xsl:text>
                        <xsl:value-of
                            select="-(2*$boardWidth + 2*$jointWidth + $bookThicknessDatatypeChecker - 2*$turninWidth)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="-($coverHeight - 2*$turninWidth)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$location eq 'foredgeRightTail'">
                        <xsl:text>scale(-1 1)translate(</xsl:text>
                        <xsl:value-of
                            select="- 2*(2*$delta + $jointWidth + 2*$boardWidth + $bookThicknessDatatypeChecker)"/>
                        <xsl:text>, 0)rotate(90,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>)rotate(180,</xsl:text>
                        <xsl:value-of
                            select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $turninWidth"/>
                        <xsl:text>)translate(</xsl:text>
                        <xsl:value-of select="-($coverHeight - 2*$turninWidth)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="-(2*$boardWidth + 2*$jointWidth + $bookThicknessDatatypeChecker - 2*$turninWidth)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="count(ancestor-or-self::cover/type/node()/corners/corner) gt 1">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'6'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when
                    test="ancestor-or-self::cover/type/node()/corners[lapped | NC | NK | other | corner[lappedForedgeOver | lappedHeadAndTailOver | lappedMixed | clockwise | anticlockwise | NC | NK | other]]">
                    <!-- 'lapped' is the nomenclature used for case bindings, but no indication is given whether the head/tail or the foredge turnins are on top -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners[NC | NK | other | corner[lappedMixed | NC | NK | other]]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners[lapped | NC | NK | other | corner[lappedForedgeOver | NC | NK | other]]">
                                <xsl:choose>
                                    <xsl:when test="matches($location, 'head|tail')">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners/corner/lappedHeadAndTailOver">
                                <xsl:choose>
                                    <xsl:when test="matches($location, 'foredge')">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners/corner/lappedMixed">
                                <xsl:choose>
                                    <xsl:when
                                        test="matches($location, 'headRight|tailRight|tailLeft|foredgeLeftHead')">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners/corner/clockwise">
                                <xsl:choose>
                                    <xsl:when
                                        test="matches($location, 'headRight|foredgeRightTail|tailLeft|foredgeLeftHead')">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="ancestor-or-self::cover/type/node()/corners/corner/anticlockwise">
                                <xsl:choose>
                                    <xsl:when
                                        test="matches($location, 'headLeft|foredgeLeftTail|tailRight|foredgeRightHead')">
                                        <xsl:attribute name="stroke-dasharray">
                                            <xsl:text>1 2</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + (if (ancestor-or-self::cover/type/case/corners[NC | NK | other]) then 0 else ($turninWidth div 3))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="ancestor-or-self::cover/type/node()/corners/corner/tonguedMitre">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + ($turninWidth div 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($turninWidth div 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                        stroke="url(#fading3)" stroke-width="0.5" fill="none">
                        <!--<xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>-->
                        <!--
                        <!-\- opacity set to 50% to allow for lines drawn twice -\->
                        <xsl:attribute name="stroke-opacity">
                            <xsl:value-of select="0.5"/>
                        </xsl:attribute>-->
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($turninWidth div 5) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + ($turninWidth div 3) - 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <!-- <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth + ($turninWidth div 3) - 1"/>-->
                            <!-- <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + ($turninWidth div 5) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 1"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>z</xsl:text>-->
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="ancestor-or-self::cover/type/node()/corners/corner/buttMitre">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <!-- opacity set to 50% to allow for lines drawn twice -->
                        <xsl:attribute name="stroke-opacity">
                            <xsl:value-of select="0.5"/>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="ancestor-or-self::cover/type/node()/corners/corner/openMitre">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth + ($turninWidth div 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="ancestor-or-self::cover/type/node()/corners/locked">
                    <!-- Not enough information to indicate the pattern of the locking mechanism; 
                    only a general view of the corner is drawn-->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:choose>
                            <xsl:when test="matches($location, 'head|tail')">
                                <xsl:attribute name="class">
                                    <xsl:text>line2_noLine</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <!--
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>-->
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($turninWidth div 3) * 0.9"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth * 0.6"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($turninWidth div 3) * 0.9"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth * 0.6"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth "/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth * 0.6"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth "/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                        stroke-dasharray="1 1">
                        <xsl:choose>
                            <xsl:when test="matches($location, 'head|tail')">
                                <xsl:attribute name="class">
                                    <xsl:text>line2_noLine</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + $turninWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth + ($turninWidth div 2)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + $turninWidth"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - $boardWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
            </xsl:choose>
        </g>
    </xsl:template>

    <xsl:template name="caseX">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <!-- Parameter to indicate whether to call the boockblock temmplate; in case of 'boardsCoverSpineInfill'
            the bookblock is drawn already and needs not to be drawn here or it'll cover everything -->
        <xsl:param name="drawBookblock" select="'yes'"/>
        <!-- Parameter to indicate whether to call the turnins temmplate; in case of the lining cover of 'coverLining'
            the turnins are not to be drawn, described turnins are those of the outer cover -->
        <xsl:param name="drawTurnins" select="'yes'"/>
        <!-- Parameter to indicate whether the cover to be drawn is an outer one (for 'coverLining'):
            'outer' indicates this, the default and neutral value is 'normal' -->
        <xsl:param name="type" select="'normal'"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="$certainty lt 100">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <!-- draw bookblock -->
            <xsl:choose>
                <xsl:when test="$drawBookblock eq 'no'">
                    <!-- do nothing, do not call the bookblock tempplate -->
                </xsl:when>
                <xsl:otherwise>
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>bookblock</xsl:text>
                    </desc>
                    <xsl:call-template name="bookblock"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- draw spine curvature -->
            <xsl:call-template name="spineArc">
                <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <!-- draw joints -->
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>joints</xsl:text>
            </desc>
            <xsl:choose>
                <xsl:when
                    test="case/joints[spineCrease[jointCrease[no | NA]] | NC | NK | other] or .[drawnOn | guard]">
                    <!-- left joint -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="-2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="case/joints[NC | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- right joint -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="case/joints[NC | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="case/joints[spineCrease[jointCrease[yes | NC | NK | other]]]">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:choose>
                            <xsl:when test="case/joints[spineCrease[jointCrease[NC | NK | other]]]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <!-- left joint -->
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>left joint</xsl:text>
                        </desc>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="$type eq 'outer'">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(0,</xsl:text>
                                        <xsl:value-of select="-2"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                <!-- joint -->
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            </xsl:attribute>
                        </path>
                        <!-- right joint -->
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>right joint</xsl:text>
                        </desc>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="$type eq 'outer'">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(0,</xsl:text>
                                        <xsl:value-of select="2"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                <!-- joint -->
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:when>
                <xsl:when test="case/joints/groovedJoint">
                    <!-- left joint -->
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>left joint</xsl:text>
                    </desc>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="-2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <!-- shoulder -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness div 2)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1 + ($leftBoardThickness)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- right joint -->
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>right joint</xsl:text>
                    </desc>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <!-- shoulder -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 3"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness div 2)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + 3 + 2 * ($leftBoardThickness div 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1 - ($rightBoardThickness)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
            </xsl:choose>
            <!-- draw side covering -->
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>sides</xsl:text>
            </desc>
            <xsl:choose>
                <xsl:when
                    test="node()/type[full | NC | NK | other | adhesive[onePiece | boardsCoverSpineInfill | NK | NC | other] | laceAttached | externalSupport | longstitch] or .[drawnOn | guard]">
                    <!-- left side -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="-2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when
                                test="node()/type[NC | NK | other | adhesive[NK | NC | other]]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + (if (./guard) then 10 else ($boardWidth + 1))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- right side -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$type eq 'outer'">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(0,</xsl:text>
                                    <xsl:value-of select="2"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when
                                test="node()/type[NC | NK | other | adhesive[NK | NC | other]]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + (if (./guard) then 10 else ($boardWidth + 1))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:when test="case/type/adhesive/threePiece[turnedIn]">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <!-- left side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <!-- right side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$drawTurnins eq 'no'">
                    <!-- no turnIns should be drawn -->
                </xsl:when>
                <xsl:when test="case/preparation/edgeTreatment[turnedIn | NC | NK | other]">
                    <xsl:call-template name="turnInsX">
                        <xsl:with-param name="TxL"
                            select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                        <xsl:with-param name="TyL">
                            <xsl:choose>
                                <xsl:when test="$type eq 'outer'">
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 3"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="TxR"
                            select="$arc_tMin/xtMin + $jointWidth + $boardWidth + 1"/>
                        <xsl:with-param name="TyR">
                            <xsl:choose>
                                <xsl:when test="$type eq 'outer'">
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 3"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="boardDelta">
                            <xsl:value-of select="1"/>
                        </xsl:with-param>
                        <xsl:with-param name="line">
                            <xsl:text>line</xsl:text>
                        </xsl:with-param>
                        <xsl:with-param name="type">
                            <xsl:value-of select="$type"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- no turnIns should be drawn -->
                </xsl:otherwise>
            </xsl:choose>
        </g>
    </xsl:template>

    <xsl:template name="caseX_threePiece">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="case/type/adhesive/threePiece[cutFlush | NC | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg" transform="translate(1.5,0)">
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>bookblock</xsl:text>
                    </desc>
                    <!-- draw bookblock -->
                    <xsl:call-template name="bookblock"/>
                    <!-- draw spine curvature -->
                    <xsl:call-template name="spineArc"/>
                    <!-- draw joints -->
                    <desc xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>joints</xsl:text>
                    </desc>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="case/type/adhesive/threePiece[NC | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="d">
                            <!-- left joint + side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) + $leftBoardThickness + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) + $leftBoardThickness + 1"/>
                            <!-- right joint + side -->
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) - $rightBoardThickness - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + $jointWidth + ($boardWidth div 7)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) - $rightBoardThickness - 1"
                            />
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
            <xsl:when test="case/type/adhesive/threePiece/turnedIn">
                <xsl:call-template name="caseX"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="caseX_boardsCoverSpineInfill">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <!-- infill and bookblock -->
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(1,0)">
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>bookblock</xsl:text>
            </desc>
            <!-- draw bookblock -->
            <xsl:call-template name="bookblock">
                <xsl:with-param name="type" select="'inner'"/>
            </xsl:call-template>
            <!-- draw spine curvature -->
            <xsl:call-template name="spineArc">
                <xsl:with-param name="type" select="'inner'"/>
            </xsl:call-template>
        </g>
        <!-- cover -->
        <xsl:call-template name="caseX">
            <xsl:with-param name="certainty" select="100"/>
            <xsl:with-param name="drawBookblock" select="'no'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="caseX_coverLining">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <!-- Inner cover -->
        <xsl:call-template name="caseX">
            <xsl:with-param name="certainty" select="$certainty"/>
            <xsl:with-param name="drawTurnins" select="'no'"/>
        </xsl:call-template>
        <!-- Outer cover -->
        <xsl:call-template name="caseX">
            <xsl:with-param name="drawBookblock" select="'no'"/>
            <xsl:with-param name="type" select="'outer'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="lacingX">
        <!-- Parameter to select a different path for endband lacing for 'coverLining'; 
        default is 'normal', to trigger the alternative path select 'double'-->
        <xsl:param name="type" select="'normal'"/>
        <xsl:variable name="jointWidth">
            <xsl:choose>
                <xsl:when test="$jointWidth lt 5">
                    <xsl:value-of select="5"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$jointWidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::book/spine/profile/shape[flat | NK]">
                <!-- Through cover exit left -->
                <!-- white line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
                    <xsl:attribute name="class">
                        <xsl:text>line_white</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                    </xsl:attribute>
                </path>
                <!-- drawing line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                    </xsl:attribute>
                </path>
                <!-- Through cover exit right -->
                <!-- white line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
                    <xsl:attribute name="class">
                        <xsl:text>line_white</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"
                        />
                    </xsl:attribute>
                </path>
                <!-- drawing line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"
                        />
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin - 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:otherwise>
                <!-- Through cover exit left -->
                <!-- white line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
                    <xsl:attribute name="class">
                        <xsl:text>line_white</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.2"/>
                    </xsl:attribute>
                </path>
                <!-- drawing line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.2"/>
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.2"/>
                    </xsl:attribute>
                </path>
                <!-- Through cover exit right -->
                <!-- white line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="square">
                    <xsl:attribute name="class">
                        <xsl:text>line_white</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 2.5 else 1)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4.2 else 2.2)"
                        />
                    </xsl:attribute>
                </path>
                <!-- drawing line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 2.5 else 1)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4.2 else 2.2)"
                        />
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$arc_tMin/ytMin + $bookThicknessDatatypeChecker"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 2.5 else 1)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 0.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4.2 else 2.2)"
                        />
                    </xsl:attribute>
                </path>
            </xsl:otherwise>
        </xsl:choose>
        <!--  -->
        <xsl:variable name="thicknessL">
            <xsl:choose>
                <!-- bindings with boards -->
                <xsl:when
                    test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                    <xsl:value-of
                        select="$leftBoardThickness + 1 - (if (case/type/laceAttached[boards]) then 0.5 else 0)"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="thicknessR">
            <xsl:choose>
                <!-- bindings with boards -->
                <xsl:when
                    test=".[overInboard | case/type[adhesive[threePiece | boardsCoverSpineInfill] | laceAttached[boards]]]">
                    <xsl:value-of
                        select="$rightBoardThickness + 1 - (if (case/type/laceAttached[boards]) then 0.5 else 0)"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Through cover entry left -->
        <!-- white line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
            <xsl:attribute name="class">
                <xsl:text>line_white</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.25"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.3"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75 - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
            </xsl:attribute>
        </path>
        <!-- drawing line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75 - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay - ($bookThicknessDatatypeChecker div 2) + (if (case/type/laceAttached/boards) then $thicknessL else 0)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + 3 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay - ($bookThicknessDatatypeChecker div 2) + (if (case/type/laceAttached/boards) then $thicknessL else 0)"
                />
            </xsl:attribute>
        </path>
        <!-- hollow line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line_white6</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75 - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay - ($bookThicknessDatatypeChecker div 2) + (if (case/type/laceAttached/boards) then $thicknessL else 0)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + 3 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay - ($bookThicknessDatatypeChecker div 2) + (if (case/type/laceAttached/boards) then $thicknessL else 0)"
                />
            </xsl:attribute>
        </path>
        <!-- Through cover entry right -->
        <!-- white line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
            <xsl:attribute name="class">
                <xsl:text>line_white</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth - 0.25"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4.3 else 2.3)"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75 - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
            </xsl:attribute>
        </path>
        <!-- drawing line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75 - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - (if (case/type/laceAttached/boards) then $thicknessR else 0)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + 3 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - (if (case/type/laceAttached/boards) then $thicknessR else 0)"
                />
            </xsl:attribute>
        </path>
        <!-- hollow line -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
            <xsl:attribute name="class">
                <xsl:text>line_white6</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if ($type eq 'double') then 4 else 2)"/>
                <xsl:text>&#32;Q</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + $jointWidth + 0.5"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2)"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of
                    select="$arc_tMin/xtMin + $jointWidth + 0.75  - (if (case/type/laceAttached/boards) then 0.35 else 0)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - (if (case/type/laceAttached/boards) then $thicknessR else 0)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$arc_tMin/xtMin + 3 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$Ay + ($bookThicknessDatatypeChecker div 2) - (if (case/type/laceAttached/boards) then $thicknessR else 0)"
                />
            </xsl:attribute>
        </path>
        <!-- Sewing support spine section -->
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(1,0)">
            <xsl:call-template name="spineArc">
                <xsl:with-param name="type" select="'inner'"/>
            </xsl:call-template>
        </g>
        <!-- external paths -->
        <!-- based on caseX joints-->
        <xsl:choose>
            <xsl:when
                test="case/joints[spineCrease[jointCrease[no | NA]] | groovedJoint | NC | NK | other]">
                <!-- left joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="-1"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2) + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="-1"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay - ($bookThicknessDatatypeChecker div 2) - (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2) + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                    </xsl:attribute>
                </path>
                <!-- right joint -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$type eq 'double'">
                                <xsl:value-of select="3"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2) + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
                <!-- hollow line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line_white6</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$type eq 'double'">
                                <xsl:value-of select="3"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + ($jointWidth div 2) + 2"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$arc_tMin/xtMin + $jointWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="case/joints[spineCrease[jointCrease[yes | NC | NK | other]]]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <!-- left joint -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="-1"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.75"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- hollow line -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line_white6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:value-of select="-1"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay - ($bookThicknessDatatypeChecker div 2) - 2.75"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- right joint -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line2</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$type eq 'double'">
                                    <xsl:value-of select="3"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2.75"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- hollow line -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                        <xsl:attribute name="class">
                            <xsl:text>line_white6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>translate(0,</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$type eq 'double'">
                                    <xsl:value-of select="3"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$arc_tMin/xtMin + (if (ancestor::book/spine/profile/shape[flat | NK]) then 0 else 1)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + (if (ancestor::book/spine/profile/shape[flat | NK]) then 1 else 1.25)"/>
                            <!-- joint -->
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Ay + ($bookThicknessDatatypeChecker div 2) + 2.75"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$arc_tMin/xtMin + 5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
        </xsl:choose>
        <!-- Section DIVIDER: white line to separate the two halves of the cross-section so to draw both sewing support lacing-in and endband lacing-in patterns -->
        <xsl:choose>
            <xsl:when test="$type eq 'double'">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line_white5</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ax - $delta"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $jointWidth + $boardWidth + $delta"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:attribute>
                </path>
                <xsl:call-template name="caseX_laceAttached_boardsNotes">
                    <xsl:with-param name="arcTyMin" select="$arc_tMin/ytMin"/>
                    <xsl:with-param name="boardThickneesL" select="$thicknessL"/>
                    <xsl:with-param name="boardThickneesR" select="$thicknessR"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="caseX_laceAttached_boardsNotes">
        <xsl:param name="arcTyMin"/>
        <xsl:param name="boardThickneesL"/>
        <xsl:param name="boardThickneesR"/>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$arcTyMin -  $boardThickneesL - 7"/>
            </xsl:attribute>
            <xsl:text>support lacing-in</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$arcTyMin + $bookblockThickness +  $boardThickneesR + 9"/>
            </xsl:attribute>
            <xsl:text>endband lacing-in</xsl:text>
        </text>
        <path xmlns="http://www.w3.org/2000/svg" class="line2" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ax + 2 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arcTyMin - $boardThickneesR - 6.5"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax + $jointWidth * 1.3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arcTyMin - $boardThickneesR - 4.5"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" class="line2" marker-end="url(#arrowSymbol)">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ax + 2 * $jointWidth"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arcTyMin + $bookblockThickness + $boardThickneesR + 6.8"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax + $jointWidth * 1.3"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$arcTyMin + $bookblockThickness + $boardThickneesR + 4.8"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="lacing">
        <!-- Parameter to select a different path for endband lacing for 'coverLining'; 
        default is 'normal', to trigger the alternative path select 'double'-->
        <xsl:param name="type" select="'normal'"/>
        <xsl:variable name="jointWidth">
            <xsl:choose>
                <xsl:when test="$jointWidth lt 5">
                    <xsl:value-of select="5"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$jointWidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="case/type/laceAttached[node()[supportSlip | endbandSupportSlip | NC | NK | other] | coverLining]">
                <xsl:for-each select="ancestor::book/sewing/stations/station[type/supported]">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached/node()[NC | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <!-- outer view -->
                        <!-- left -->
                        <g xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached/coverLining">
                                    <xsl:attribute name="stroke-dasharray">
                                        <xsl:text>1 1</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 2.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 2.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                </xsl:attribute>
                            </path>
                            <!-- right -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 2.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 2.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 1.5"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 1.5"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <!-- sewing supports: spine -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- laced-in part -->
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 2"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 2"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- inner view -->
                        <!-- sewing supports: spine -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- laced-through parts -->
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- laced-in part -->
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 2"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 2"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 1.5"/>
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <!-- Because 'endbandSupportSlip' and 'coverLining' have to be captured in both cases, the two choices have been separated -->
        <xsl:choose>
            <xsl:when
                test="case/type/laceAttached[node()[endbandSlip | endbandSupportSlip | NC | NK | other] | coverLining]">
                <xsl:for-each select="ancestor::book/endbands/yes/endband[location[head | tail]]">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached/node()[C | NK | other]">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="50"/>
                                    <xsl:with-param name="type" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <!-- outer view -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 3 else 3)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 6 else 6)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 6.5 else 6.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Bx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 3 else 3)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 6 else 6)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 6.5 else 6.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Bx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- laced-in part -->
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0, </xsl:text>
                                <xsl:value-of select="if (location/tail) then - 2.5 else 2.5"/>
                                <xsl:text>) rotate(</xsl:text>
                                <xsl:value-of select="if (location/tail) then -35 else 35"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0, </xsl:text>
                                <xsl:value-of select="if (location/tail) then - 2.5 else 2.5"/>
                                <xsl:text>) rotate(</xsl:text>
                                <xsl:value-of select="if (location/tail) then 35 else -35"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$By + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- inner view -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- laced through part -->
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 3 else 3)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 6 else 6)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 6.5 else 6.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx + ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-dasharray="1 1">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx - ($bookblockThickness div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 3 else 3)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 6 else 6)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - ($jointWidth div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 6.5 else 6.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx - ($bookThicknessDatatypeChecker div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- laced-in part -->
                        <!-- right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0, </xsl:text>
                                <xsl:value-of select="if (location/tail) then - 2.5 else 2.5"/>
                                <xsl:text>) rotate(</xsl:text>
                                <xsl:value-of select="if (location/tail) then -35 else 35"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth + ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($bookThicknessDatatypeChecker div 2) + $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(0, </xsl:text>
                                <xsl:value-of select="if (location/tail) then - 2.5 else 2.5"/>
                                <xsl:text>) rotate(</xsl:text>
                                <xsl:value-of select="if (location/tail) then 35 else -35"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 2.5 else 2.5)"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 1 else 1)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 0.5 else 0.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 9)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4.5 else 4.5)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth - ($boardWidth div 8)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Cx - ($bookThicknessDatatypeChecker div 2) - $jointWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (if (location/tail) then $coverHeight - 4 else 4)"
                                />
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="tacketingX">
        <!-- Sewing supports -->
        <g xmlns="http://www.w3.org/2000/svg" transform="translate(2,0)">
            <xsl:call-template name="spineArc">
                <xsl:with-param name="type" select="'support'"/>
            </xsl:call-template>
        </g>
        <!-- There is no way in the schema to say that there are no reinforcements,
            therefore it looks like surveyors were forced to use type[NC | NK | other]
            to indicate that there weren't any (at least in the two tacketed examples in the database -->
        <g xmlns="http://www.w3.org/2000/svg">
            <!-- Information is sketchy and only general -->
            <!--<xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="50"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>-->
            <xsl:choose>
                <xsl:when
                    test="case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]">
                    <!-- do nothing, see note above -->
                </xsl:when>
                <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type/individual">
                    <!-- draw reinforcements -->
                    <!-- It is not know the number of tackets; we are assuming two tacketing 'stations':
                    one towards the left side, one towards the right side -->
                    <xsl:variable name="individualTacketLength">
                        <xsl:value-of select="(($bookThicknessDatatypeChecker div 2) div 3)"/>
                    </xsl:variable>
                    <!--
                    <!-\- center -\->
                    <g xmlns="http://www.w3.org/2000/svg" id="individualTacket">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - ($individualTacketLength div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($individualTacketLength div 2)"/>
                            </xsl:attribute>
                        </path>
                        <!-\-<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when
                                        test="case/type/laceAttached/tacketed/reinforcements/covering/parchment">
                                        <xsl:text>line2</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>line</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Ax - $arcShape/xRadius - (if (case/type/laceAttached/tacketed/reinforcements/covering/tannedSkin)then 3.2 else 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - ($individualTacketLength div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Ax - $arcShape/xRadius - (if (case/type/laceAttached/tacketed/reinforcements/covering/tannedSkin)then 3.2 else 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($individualTacketLength div 2)"/>
                            </xsl:attribute>
                        </path>-\->
                    </g>-->
                    <!-- left -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                        transform="translate(0,{-($bookThicknessDatatypeChecker div 2) + 2}) ">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($individualTacketLength div 2)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($individualTacketLength div 2) - 2"/>
                        </xsl:attribute>
                    </path>
                    <!--
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#individualTacket"
                        y="{-($bookThicknessDatatypeChecker div 2) + 2}"/>-->
                    <!-- right -->
                    <!--
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#individualTacket"
                        y="{($bookThicknessDatatypeChecker div 2) - 2}"/>-->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                        transform="translate(0,{($bookThicknessDatatypeChecker div 2) - 2}) ">
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($individualTacketLength div 2) + 2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($individualTacketLength div 2)"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:otherwise>
                    <!-- draw reinforcement -->
                    <g xmlns="http://www.w3.org/2000/svg" id="reinforcement">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-width="1.5" fill="none">
                            <xsl:attribute name="stroke">
                                <xsl:choose>
                                    <xsl:when
                                        test="case/type/laceAttached/tacketed/reinforcements/type/bands">
                                        <xsl:text>url(#doubleFadingVertical)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>#000000</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax - $arcShape/xRadius - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) -
                                    (if (case/type/laceAttached/tacketed/reinforcements/type/bands) then 30 else 0)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax - $arcShape/xRadius - 2 + 0.0001"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) +
                                    (if (case/type/laceAttached/tacketed/reinforcements/type/bands) then 30 else 0)"
                                />
                            </xsl:attribute>
                        </path>
                        <!-- <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-width="0.2" fill="none">
                            <xsl:attribute name="stroke">
                                <xsl:choose>
                                    <xsl:when
                                        test="case/type/laceAttached/tacketed/reinforcements/type/bands">
                                        <xsl:text>url(#doubleFadingVertical)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>#000000</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Ax - $arcShape/xRadius - (if (case/type/laceAttached/tacketed/reinforcements/covering/tannedSkin)then 3.2 else 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay - ($bookThicknessDatatypeChecker div 2) -
                                    (if (case/type/laceAttached/tacketed/reinforcements/type/bands) then 30 else 0)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Ax - $arcShape/xRadius - (if (case/type/laceAttached/tacketed/reinforcements/covering/tannedSkin)then 3.2 else 3) + 0.0001"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Ay + ($bookThicknessDatatypeChecker div 2) +
                                    (if (case/type/laceAttached/tacketed/reinforcements/type/bands) then 30 else 0)"
                                />
                            </xsl:attribute>
                        </path>-->
                    </g>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Variable to select how much to protrude the tacket from the spine in the drawing -->
            <xsl:variable name="protrusionOfTacket">
                <xsl:choose>
                    <xsl:when
                        test="case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]">
                        <xsl:value-of select="2"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="4"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="case/type/laceAttached/tacketed/type[NC | NK | other]">
                    <!-- because of the nature of generic information of the whole description of tacketing, nothing is drawn if type is not explicitly selected -->
                </xsl:when>
                <xsl:when test="case/type/laceAttached/tacketed/type/loop">
                    <!-- It is not know the number of tackets; we are assuming three tacketing 'stations':
                    one towards the left side, one towards the right side, and one in the middle of the spine -->
                    <!-- left -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                    then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                    else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                    <!-- right -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <!--<!-\- center -\->
                    <xsl:choose>
                        <xsl:when
                            test="case/type/laceAttached/tacketed/reinforcements/type[not(NC | NK | other)]">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="stroke-opacity">
                                    <xsl:text>0.5</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                        then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                        else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="stroke-opacity">
                                    <xsl:text>0.5</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                        then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                        else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                    </xsl:choose>-->
                    <xsl:call-template name="tacketX"/>
                </xsl:when>
                <xsl:when test="case/type/laceAttached/tacketed/type/saltire">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:variable name="centerX">
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket"
                            />
                        </xsl:variable>
                        <xsl:variable name="centerY">
                            <xsl:value-of select="$Ay"/>
                        </xsl:variable>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of select="$centerX"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$centerY"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:variable name="startX">
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) - ($bookThicknessDatatypeChecker div 2) + 1"
                            />
                        </xsl:variable>
                        <xsl:variable name="endX">
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) + ($bookThicknessDatatypeChecker div 2) - 1"
                            />
                        </xsl:variable>
                        <!-- crossing -->
                        <g xmlns="http://www.w3.org/2000/svg" transform="translate(0,2.1)">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$endX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 2.3"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$centerX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 3.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select=" $centerX - ((($endX)-($startX)) div 2.5)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 2.1"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$endX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.3"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$centerX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 2"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$centerX - 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.75"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$startX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 2.35"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$centerX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$centerX + 1.3"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.8"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$startX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.35"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of select="$centerX"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 0.1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select=" $centerX + ((($endX)-($startX)) div 2.5)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay - 1.5"/>
                                </xsl:attribute>
                            </path>
                        </g>
                    </g>
                    <!-- sides -->
                    <!-- left -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) + 0.2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:text>1,1 0 0,0</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"
                            />
                        </xsl:attribute>
                    </path>
                    <!-- right -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
            else $Ax - $arcShape/xRadius - $protrusionOfTacket) + 0.2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:text>1,1 0 0,1</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"
                            />
                        </xsl:attribute>
                    </path>
                    <xsl:call-template name="tacketX"/>
                </xsl:when>
                <xsl:when test="case/type/laceAttached/tacketed/type/transverse">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <xsl:call-template name="tacketX"/>
                </xsl:when>
                <xsl:when test="case/type/laceAttached/tacketed/type/transverseTwisted">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:variable name="startX">
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket) - ($bookThicknessDatatypeChecker div 2) + 1"
                            />
                        </xsl:variable>
                        <xsl:variable name="endX">
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket) + ($bookThicknessDatatypeChecker div 2) - 1"
                            />
                        </xsl:variable>
                        <!-- twist support -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4_full</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$startX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$endX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$endX + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$endX + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$endX + 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$endX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$endX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$startX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$startX - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$startX - 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$startX - 0.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$startX"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 0.75"/>
                            </xsl:attribute>
                        </path>
                        <!-- twist -->
                        <xsl:variable name="twistModule">
                            <!-- twice the curved line - 1 -->
                            <xsl:value-of select="3"/>
                        </xsl:variable>
                        <xsl:call-template name="tacket_twist">
                            <xsl:with-param name="twistModule">
                                <xsl:value-of select="$twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistCount" as="xs:double">
                                <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistRemainder">
                                <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="startX">
                                <xsl:value-of select="$startX + 1"/>
                            </xsl:with-param>
                            <xsl:with-param name="startY">
                                <xsl:value-of select="$Ay - 0.75"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </g>
                    <!-- sides -->
                    <!-- left -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                            then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                            else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                    then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                    else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                    then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                    else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                    then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                    else $Ax - $arcShape/xRadius - $protrusionOfTacket) + 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1.5"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:text>1,1 0 0,0</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 0.5"
                            />
                        </xsl:attribute>
                    </path>
                    <!-- right -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket) - 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                            <xsl:text>&#32;M</xsl:text>
                            <xsl:value-of
                                select="(if (case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]) 
                                then $Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - (if (ancestor::book/spine/profile/shape[flat | NK])then 4 else 6)
                                else $Ax - $arcShape/xRadius - $protrusionOfTacket) + 0.75"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1.5"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:text>1,1 0 0,1</xsl:text>
                            <xsl:value-of
                                select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 0.5"
                            />
                        </xsl:attribute>
                    </path>
                    <xsl:call-template name="tacketX"/>
                </xsl:when>
            </xsl:choose>
            <!-- sides extensions -->
            <!-- left -->
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when
                            test="case/type/laceAttached/tacketed/type/transverseTwisted or case/type/laceAttached/tacketed/type/saltire">
                            <xsl:text>line7</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line6</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) + 1.5"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                </xsl:attribute>
            </path>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when
                            test="case/type/laceAttached/tacketed/type/transverseTwisted or case/type/laceAttached/tacketed/type/saltire">
                            <xsl:text>line_white9</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line_white</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) + 1.5"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - 1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay - ($bookThicknessDatatypeChecker div 2) + 1"/>
                </xsl:attribute>
            </path>
            <!-- right -->
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when
                            test="case/type/laceAttached/tacketed/type/transverseTwisted or case/type/laceAttached/tacketed/type/saltire">
                            <xsl:text>line7</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line6</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) + 1.5"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                </xsl:attribute>
            </path>
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when
                            test="case/type/laceAttached/tacketed/type/transverseTwisted or case/type/laceAttached/tacketed/type/saltire">
                            <xsl:text>line_white9</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line_white</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) + 1.5"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of
                        select="$Ax - $arcShape/xRadius + (if (ancestor::book/spine/profile/shape[flat | NK]) then 2 else 5) - 1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ay + ($bookThicknessDatatypeChecker div 2) - 1"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="tacketX">
        <!-- Section title -->
        <xsl:call-template name="sectionTitle">
            <xsl:with-param name="class" select="'noteText3'"/>
            <xsl:with-param name="x" select="$Dx"/>
            <xsl:with-param name="y" select="$Dy - ($text_delta div 2)"/>
            <xsl:with-param name="text" select="'tacket detail'"/>
        </xsl:call-template>
        <!-- description details -->
        <xsl:call-template name="sectionTitle">
            <xsl:with-param name="class" select="'noteText3'"/>
            <xsl:with-param name="x" select="$Dx"/>
            <xsl:with-param name="y" select="$Dy + ($text_delta div 1.5)"/>
            <xsl:with-param name="text"
                select="if (case/type/laceAttached/tacketed/type/other) 
                then concat(case/type/laceAttached/tacketed/type/node()[2]/name(), ': ', case/type/laceAttached/tacketed/type/other/text()) 
                else case/type/laceAttached/tacketed/type/node()[2]/name()"
            />
        </xsl:call-template>
        <xsl:call-template name="sectionTitle">
            <xsl:with-param name="class" select="'noteText3'"/>
            <xsl:with-param name="x" select="$Dx"/>
            <xsl:with-param name="y" select="$Dy + ($text_delta div 1.5) + 5"/>
            <xsl:with-param name="text"
                select="concat((if (case/type/laceAttached/tacketed/reinforcements/type/other) 
                then concat(case/type/laceAttached/tacketed/reinforcements/type/node()[2]/name(), ': ', case/type/laceAttached/tacketed/reinforcements/type/other/text()) 
                else case/type/laceAttached/tacketed/reinforcements/type/node()[2]/name()), ' reinf.')"
            />
        </xsl:call-template>
        <!-- framework -->
        <g xmlns="http://www.w3.org/2000/svg">
            <!-- gathering line -->
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                stroke="url(#doubleFading3)" stroke-width="0.5" fill="none">
                <!--<xsl:attribute name="class">
                    <xsl:text>line2_doubleFading_h</xsl:text>
                </xsl:attribute>-->
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Dx - ($delta div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Dy + (if (case/type/laceAttached/tacketed/type/transverseTwisted) then 4 else 3)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Dx + ($delta div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Dy + (if (case/type/laceAttached/tacketed/type/transverseTwisted) then 4 else 3) + 0.00001"
                    />
                </xsl:attribute>
            </path>
            <!-- cover line -->
            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                stroke="url(#doubleFading3)" stroke-width="1" fill="none">
                <!--<xsl:attribute name="class">
                    <xsl:text>line_doubleFading_h</xsl:text>
                </xsl:attribute>-->
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Dx - ($delta div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Dx + ($delta div 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) + 0.00001"
                    />
                </xsl:attribute>
            </path>
            <xsl:choose>
                <xsl:when
                    test="case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]">
                    <!-- reinforcement line -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt" stroke-width="1"
                        fill="none">
                        <xsl:attribute name="stroke">
                            <xsl:choose>
                                <xsl:when
                                    test="case/type/laceAttached/tacketed/reinforcements/type[singleStation | individual]">
                                    <xsl:text>#000000</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>url(#doubleFading3)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of
                                select="$Dx - ($delta div (if (case/type/laceAttached/tacketed/reinforcements/type[singleStation | individual]) then 4 else 2))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3 else 4.5)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of
                                select="$Dx + ($delta div (if (case/type/laceAttached/tacketed/reinforcements/type[singleStation | individual]) then 4 else 2))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3 else 4.5) + 0.00001"
                            />
                        </xsl:attribute>
                    </path>
                </xsl:when>
            </xsl:choose>
        </g>
        <!-- tacket -->
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/type/loop">
                <!-- tacket -->
                <rect xmlns="http://www.w3.org/2000/svg" rx="1.5" ry="1.5">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="16"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="12.75"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of
                            select="(if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 9.5 else 11) + 
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3.7 else 5.2) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </rect>
                <rect xmlns="http://www.w3.org/2000/svg" rx="0.5" ry="0.5">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="13"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="9.75"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of
                            select="(if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 6.5 else 8) + 
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.2 else 3.7) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </rect>
                <!-- extensions -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 0.7 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 9"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 7.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 10"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 8.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2 - 
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 2.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 0.7 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 9"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 7.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 10"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 8.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 2.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <!-- twist -->
                <xsl:variable name="twistModule">
                    <!-- twice the curved line - 1 -->
                    <xsl:value-of select="3"/>
                </xsl:variable>
                <xsl:call-template name="tacket_twist">
                    <xsl:with-param name="twistModule">
                        <xsl:value-of select="$twistModule"/>
                    </xsl:with-param>
                    <xsl:with-param name="twistCount" as="xs:double">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of
                                    select="((($Dx + 2) - 2) - ($Dx - 2)) div $twistModule"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of
                                    select="((($Dx + 6) - 2) - ($Dx - 6)) div $twistModule"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of
                                    select="((($Dx + 4.4) - 2) - ($Dx - 4.4)) div $twistModule"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="0"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="twistRemainder">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="(($Dx + 2) - ($Dx - 2)) mod $twistModule"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="(($Dx + 6) - ($Dx - 6)) mod $twistModule"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="(($Dx + 4.4) - ($Dx - 4.4)) mod $twistModule"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="startX">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.4"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="startY">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/saltire">
                <!-- tacket -->
                <rect xmlns="http://www.w3.org/2000/svg" rx="1.5" ry="1.5">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="16"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="12.75"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of
                            select="(if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 9.5 else 11) + 
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3.7 else 5.2) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </rect>
                <rect xmlns="http://www.w3.org/2000/svg" rx="0.5" ry="0.5">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="13"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="9.75"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of
                            select="(if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 6.5 else 8) +
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.2 else 3.7) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </rect>
                <!-- loop-opening -->
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line_white3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx - 10"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.55 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + 10"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.55 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <!-- protruding parts -->
                <!-- crossing -->
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 3.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 7.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 5.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.3 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 3.5 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - ((($Dx + 2)-($Dx - 2)) div 2.5)"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - ((($Dx + 6)-($Dx - 6)) div 2.5)"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - ((($Dx + 4.4)-($Dx - 4.4)) div 2.5)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 3.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 7.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 5.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.3 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Dx - 1.5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.75 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 3.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 7.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 5.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.35 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.5 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Dx + 1.3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.8 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 3.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 7.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 5.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.35 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 0.1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + ((($Dx + 2)-($Dx - 2)) div 2.5)"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + ((($Dx + 6)-($Dx - 6)) div 2.5)"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + ((($Dx + 4.4)-($Dx - 4.4)) div 2.5)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1.5 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <!-- sides -->
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;A</xsl:text>
                        <xsl:text>1,1 0 0,1</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;A</xsl:text>
                        <xsl:text>1,1 0 0,0</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"
                        />
                    </xsl:attribute>
                </path>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(180 </xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>) translate(0,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="-0.6"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="-2"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="-0.6"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <!-- extensions -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx - 4"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx - 8"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx - 6.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx - 5"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx - 9"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx - 7.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx - 6"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx - 10"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx - 8.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx + 6"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx + 2.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2"
                            />
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx + 4"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx + 8"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx + 6.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx + 5"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx + 9"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx + 7.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx + 6"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx + 10"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx + 8.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx + 6"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx + 2.4"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2"
                            />
                        </xsl:attribute>
                    </path>
                    <!-- twist -->
                    <xsl:variable name="twistModule">
                        <!-- twice the curved line - 1 -->
                        <xsl:value-of select="3"/>
                    </xsl:variable>
                    <xsl:call-template name="tacket_twist">
                        <xsl:with-param name="twistModule">
                            <xsl:value-of select="$twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="twistCount" as="xs:double">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of
                                        select="((($Dx + 2) - 2) - ($Dx - 2)) div $twistModule"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of
                                        select="((($Dx + 6) - 2) - ($Dx - 6)) div $twistModule"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of
                                        select="((($Dx + 4.4) - 2) - ($Dx - 4.4)) div $twistModule"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="0"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="twistRemainder">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="(($Dx + 2) - ($Dx - 2)) mod $twistModule"
                                    />
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="(($Dx + 6) - ($Dx - 6)) mod $twistModule"
                                    />
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of
                                        select="(($Dx + 4.4) - ($Dx - 4.4)) mod $twistModule"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="startX">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                    <xsl:value-of select="$Dx - 2"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                    <xsl:value-of select="$Dx - 6"/>
                                </xsl:when>
                                <xsl:when
                                    test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                    <xsl:value-of select="$Dx - 4.4"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="startY">
                            <xsl:value-of
                                select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2.2"
                            />
                        </xsl:with-param>
                    </xsl:call-template>
                </g>
            </xsl:when>
        </xsl:choose>
        <!-- sewing supports -->
        <xsl:choose>
            <xsl:when
                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupportRound">
                    <xsl:attribute name="x">
                        <xsl:value-of
                            select="if (case/type/laceAttached/tacketed/type/transverse) then $Dx - 3.5 else $Dx"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Dy"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when
                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupportFlat">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Dx - 6"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Dy - 0.5"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when
                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupportRound">
                    <xsl:attribute name="x">
                        <xsl:value-of
                            select="$Dx - (if (case/type/laceAttached/tacketed/type/transverse) then 3.4 else 2.4)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Dy"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#sewingSupportRound">
                    <xsl:attribute name="x">
                        <xsl:value-of
                            select="$Dx + (if (case/type/laceAttached/tacketed/type/transverse) then 3.4 else 2.4)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Dy"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/type[loop | saltire]">
                <!-- Draw a portion of the framework lines again -->
                <!-- gathering line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 5"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + 3"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 5"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + 3 + 0.00001"/>
                    </xsl:attribute>
                </path>
                <!-- cover line -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt">
                    <xsl:attribute name="class">
                        <xsl:text>line</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 5"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 5"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) + 0.00001"
                        />
                    </xsl:attribute>
                </path>
                <xsl:choose>
                    <xsl:when
                        test="case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]">
                        <!-- reinforcement line -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-width="1" fill="none">
                            <xsl:attribute name="stroke">
                                <xsl:text>#000000</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                        <xsl:value-of select="$Dx - 2.5"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                        <xsl:value-of select="$Dx - 6.5"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                        <xsl:value-of select="$Dx - 5"/>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3 else 4.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                        <xsl:value-of select="$Dx + 2.5"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                        <xsl:value-of select="$Dx + 6.5"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                        <xsl:value-of select="$Dx + 5"/>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3 else 4.5) + 0.00001"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/type/transverse">
                <!-- tacket -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke="url(#fadingDownGrey)" stroke-width="0.2" fill="#FFFFFF">
                    <!--<xsl:attribute name="class">
                        <xsl:text>lineFading_v4_full</xsl:text>
                    </xsl:attribute>-->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx - 0.75"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) + 9"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx - 0.75000001"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx - 0.75"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;A</xsl:text>
                        <xsl:text>1,1 0 0,1</xsl:text>
                        <xsl:value-of select="$Dx + 0.75"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + 0.75"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + 0.75"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + 0.75000001"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) + 9"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/transverseTwisted">
                <!-- tacket -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4_full</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.5 else 2.5)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 1.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 5.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 3.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.5 else 2.5)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.5 else 2.5)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.500001"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5000001"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9000001"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;A</xsl:text>
                        <xsl:text>1,1 0 0,1</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 2 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy - (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 3) - 1 -
                            (if (case/type/laceAttached/tacketed/reinforcements[not(NC | NK | other)]) then 2 else 0)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4.000001"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8.000001"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4000001"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 1.5 else 0)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 4"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 8"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 6.4"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3.5 else 3.5)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx + 1.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx + 5.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx + 3.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3.5 else 3.5)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 3.5 else 3.5)"/>
                        <xsl:text>&#32;A</xsl:text>
                        <xsl:text>1,1 0 0,1 </xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[raised]">
                                <xsl:value-of select="$Dx - 2.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]">
                                <xsl:value-of select="$Dx - 6.5"/>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/double">
                                <xsl:value-of select="$Dx - 4.9"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Dy + (if (ancestor::book/sewing/stations/station[type/supported][1]/type/supported/type/single[flat | other]) then 2.5 else 2.5)"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="tacketing">
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/locations/location/sewing">
                <xsl:call-template name="tacketing_reinforcements"/>
                <xsl:call-template name="tacketing_tackets_sewing"/>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/locations/location/endband">
                <xsl:call-template name="tacketing_reinforcements"/>
                <xsl:call-template name="tacketing_tackets_endband"/>
            </xsl:when>
        </xsl:choose>
        <g xmlns="http://www.w3.org/2000/svg">
            <!-- Information is sketchy and only general -->
            <!--<xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="50"/>
                <xsl:with-param name="type" select="'6'"/>
            </xsl:call-template>-->
            <!-- sewing supports -->
            <!-- outer view -->
            <xsl:for-each select="ancestor::book/sewing/stations/station">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line3</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="($Bx - ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + measurement - 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Bx + ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + measurement - 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Bx + ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + measurement + 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Bx - ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + measurement + 6"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:for-each>
            <!-- inner view -->
            <xsl:for-each select="ancestor::book/sewing/stations/station">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-dasharray="1 1">
                    <xsl:attribute name="class">
                        <xsl:text>line3_filled-semiopaque</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="($Cx - ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + measurement - 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Cx + ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + measurement - 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Cx + ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + measurement + 6"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="($Cx - ($bookblockThickness div 2))"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + measurement + 6"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template name="tacketing_tackets_sewing">
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/type/loop">
                <!-- outer view -->
                <xsl:for-each select="ancestor::book/sewing/stations/station">
                    <g xmlns="http://www.w3.org/2000/svg" id="{concat('twistedLoop', position())}">
                        <xsl:variable name="centralPointX">
                            <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 3"/>
                        </xsl:variable>
                        <xsl:variable name="centralPointY">
                            <xsl:value-of select="$By + measurement"/>
                        </xsl:variable>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of select="$centralPointX"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$centralPointY"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:variable name="startX">
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 8"/>
                        </xsl:variable>
                        <xsl:variable name="startY">
                            <xsl:value-of select="$By + measurement - 0.75"/>
                        </xsl:variable>
                        <xsl:variable name="endX">
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 8"/>
                        </xsl:variable>
                        <!-- twist support -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.7"/>
                            </xsl:attribute>
                        </path>
                        <!-- extensions -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(70, </xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>)translate(0.5,0.5)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 0.75"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(70, </xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>)translate(-0.5,-0.5)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 0.75"/>
                            </xsl:attribute>
                        </path>
                        <!-- twist -->
                        <xsl:variable name="twistModule">
                            <!-- twice the curved line - 1 -->
                            <xsl:value-of select="3"/>
                        </xsl:variable>
                        <xsl:call-template name="tacket_twist">
                            <xsl:with-param name="twistModule">
                                <xsl:value-of select="$twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistCount" as="xs:double">
                                <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistRemainder">
                                <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="startX">
                                <xsl:value-of select="$startX + 1"/>
                            </xsl:with-param>
                            <xsl:with-param name="startY">
                                <xsl:value-of select="$startY"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="{concat('#','twistedLoop',position())}"
                        x="{- ($bookblockThickness) + 6}"/>
                    <!--<xsl:choose>
                            <xsl:when
                                test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached/tacketed/reinforcements/type[not(NC | NK | other)]">
                                <!-\- central -\->
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="{concat('#','twistedLoop',position())}"
                                    x="{- ($bookblockThickness div 2) + 3}"/>
                            </xsl:when>
                        </xsl:choose>-->
                </xsl:for-each>
                <!-- inner view -->
                <xsl:for-each select="ancestor::book/sewing/stations/station">
                    <g xmlns="http://www.w3.org/2000/svg"
                        id="{concat('twistedLoop_inner', position())}">
                        <xsl:variable name="centralPointX">
                            <xsl:value-of select="$Cx + ($bookblockThickness div 2) - 3"/>
                        </xsl:variable>
                        <xsl:variable name="centralPointY">
                            <xsl:value-of select="$Cy + measurement"/>
                        </xsl:variable>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of select="$centralPointX"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$centralPointY"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <!-- twist support -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                            </xsl:attribute>
                        </path>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="{concat('#','twistedLoop_inner',position())}"
                        x="{- ($bookblockThickness) + 6}"/>
                    <!--<xsl:choose>
                            <xsl:when
                                test="ancestor::book/coverings/yes/cover/type/case/type/laceAttached/tacketed/reinforcements/type[not(NC | NK | other)]">
                                <!-\- central -\->
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="{concat('#','twistedLoop_inner',position())}"
                                    x="{- ($bookblockThickness div 2) + 3}"/>
                            </xsl:when>
                        </xsl:choose>-->
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/saltire">
                <!-- outer view -->
                <xsl:for-each select="ancestor::book/sewing/stations/station">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 6"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 6"/>
                            </xsl:attribute>
                        </path>
                    </g>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 6"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6"/>
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:for-each>
                <!-- inner view -->
                <xsl:for-each select="ancestor::book/sewing/stations/station">
                    <xsl:variable name="centralPointX">
                        <xsl:value-of select="$Cx - ($bookblockThickness div 2) + 3"/>
                    </xsl:variable>
                    <xsl:variable name="centralPointY">
                        <xsl:value-of select="$Cy + measurement"/>
                    </xsl:variable>
                    <g xmlns="http://www.w3.org/2000/svg" id="{concat('twistedLoop', position())}">
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of select="$centralPointX"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$centralPointY"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                        <xsl:variable name="startX">
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                        </xsl:variable>
                        <xsl:variable name="startY">
                            <xsl:value-of select="$Cy + measurement - 0.75"/>
                        </xsl:variable>
                        <xsl:variable name="endX">
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                        </xsl:variable>
                        <!-- twist support -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="{concat('untwistedLoop', position())}">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.7"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 7"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.7"/>
                            </xsl:attribute>
                        </path>
                        <!-- extensions -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(70, </xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>)translate(0.5,0.5)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) + 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.75"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>rotate(70, </xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>)translate(-0.5,-0.5)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.75"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement - 0.75"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 8"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3) - 6"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + measurement + 0.75"/>
                            </xsl:attribute>
                        </path>
                        <!-- twist -->
                        <xsl:variable name="twistModule">
                            <!-- twice the curved line - 1 -->
                            <xsl:value-of select="3"/>
                        </xsl:variable>
                        <xsl:call-template name="tacket_twist">
                            <xsl:with-param name="twistModule">
                                <xsl:value-of select="$twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistCount" as="xs:double">
                                <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistRemainder">
                                <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="startX">
                                <xsl:value-of select="$startX + 1"/>
                            </xsl:with-param>
                            <xsl:with-param name="startY">
                                <xsl:value-of select="$startY"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </g>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="{concat('#','untwistedLoop',position())}">
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(90, </xsl:text>
                            <xsl:value-of select="$centralPointX"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$centralPointY"/>
                            <xsl:text>)translate(0,</xsl:text>
                            <xsl:value-of select="-($bookblockThickness) + 6"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/transverse">
                <!-- NOT ENOUGH INFO -->
                <!--<!-\- outer view -\->
                    <xsl:for-each select="ancestor::book/sewing/stations/station">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <!-\- inner view -\->
                        <!-\- not enough info to draw the internal linking -\->
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 6"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 0.5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 0.5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 0.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 6"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 0.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 7"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 6"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 0.5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 7"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement - 0.5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line6</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 0.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 6"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line_white</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 0.5"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Cy + measurement + 7"/>
                                </xsl:attribute>
                            </path>
                        </g>
                    </xsl:for-each>-->
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/transverseTwisted">
                <!-- outer view -->
                <xsl:for-each select="ancestor::book/sewing/stations/station">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:variable name="startX">
                            <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                        </xsl:variable>
                        <xsl:variable name="startY">
                            <xsl:value-of select="$By + measurement - 7.25"/>
                        </xsl:variable>
                        <xsl:variable name="endX">
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                        </xsl:variable>
                        <!-- twist support -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6.5"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 6.5"/>
                            </xsl:attribute>
                        </path>
                        <!-- extensions -->
                        <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="transform">
                                    <xsl:text>rotate(45, </xsl:text>
                                    <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6.5"/>
                                    <xsl:text>)translate(0.5,0.5)</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 7.15"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="($Bx + ($bookblockThickness div 2) - 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 7.15"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="($Bx + ($bookblockThickness div 2) - 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line4</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="transform">
                                    <xsl:text>rotate(-120, </xsl:text>
                                    <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6.5"/>
                                    <xsl:text>)translate(0.5,0.5)</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 7.15"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="($Bx - ($bookblockThickness div 2) + 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 7.15"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="($Bx - ($bookblockThickness div 2) + 3) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 6"/>
                                </xsl:attribute>
                            </path>-->
                        <!-- twist -->
                        <xsl:variable name="twistModule">
                            <!-- twice the curved line - 1 -->
                            <xsl:value-of select="3"/>
                        </xsl:variable>
                        <xsl:call-template name="tacket_twist">
                            <xsl:with-param name="twistModule">
                                <xsl:value-of select="$twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistCount" as="xs:double">
                                <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="twistRemainder">
                                <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                            </xsl:with-param>
                            <xsl:with-param name="startX">
                                <xsl:value-of select="$startX + 1"/>
                            </xsl:with-param>
                            <xsl:with-param name="startY">
                                <xsl:value-of select="$startY"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </g>
                    <!-- inner view -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement - 7.15"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Cx + ($bookblockThickness div 2) - 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx - ($bookblockThickness div 2) + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement - 7.15"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line_white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement - 7.15"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Cx + ($bookblockThickness div 2) - 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Cx - ($bookblockThickness div 2) + 4"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement + 7"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx - ($bookblockThickness div 2) + 3)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + measurement - 7.15"/>
                        </xsl:attribute>
                    </path>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="tacketing_tackets_endband">
        <xsl:choose>
            <xsl:when test="case/type/laceAttached/tacketed/type/loop">
                <!-- outer view -->
                <g xmlns="http://www.w3.org/2000/svg" id="{concat('twistedLoop', position())}">
                    <xsl:variable name="centralPointX">
                        <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 3"/>
                    </xsl:variable>
                    <xsl:variable name="centralPointY">
                        <xsl:value-of select="$By"/>
                    </xsl:variable>
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(90, </xsl:text>
                        <xsl:value-of select="$centralPointX"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$centralPointY"/>
                        <xsl:text>) translate(5.75, 0)</xsl:text>
                    </xsl:attribute>
                    <xsl:variable name="startX">
                        <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                    </xsl:variable>
                    <xsl:variable name="startY">
                        <xsl:value-of select="$By - 0.75"/>
                    </xsl:variable>
                    <xsl:variable name="endX">
                        <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                    </xsl:variable>
                    <!-- twist support -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By+ 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.7"/>
                        </xsl:attribute>
                    </path>
                    <!-- extensions -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(70, </xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>)translate(0.5,0.5)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.75"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.75"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 0.75"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(70, </xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>)translate(-0.5,-0.5)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.75"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By - 0.75"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$By + 0.75"/>
                        </xsl:attribute>
                    </path>
                    <!-- twist -->
                    <xsl:variable name="twistModule">
                        <!-- twice the curved line - 1 -->
                        <xsl:value-of select="3"/>
                    </xsl:variable>
                    <xsl:call-template name="tacket_twist">
                        <xsl:with-param name="twistModule">
                            <xsl:value-of select="$twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="twistCount" as="xs:double">
                            <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="twistRemainder">
                            <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="startX">
                            <xsl:value-of select="$startX + 1"/>
                        </xsl:with-param>
                        <xsl:with-param name="startY">
                            <xsl:value-of select="$startY"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </g>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop',position())}"
                    x="{- ($bookblockThickness) + 6}"/>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop',position())}"
                    x="{- ($bookblockThickness) + 6}" y="{$coverHeight - 2* 5.75}"/>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop',position())}" y="{$coverHeight - 2* 5.75}"/>
                <!-- inner view -->
                <g xmlns="http://www.w3.org/2000/svg" id="{concat('twistedLoop_inner', position())}">
                    <xsl:variable name="centralPointX">
                        <xsl:value-of select="$Cx + ($bookblockThickness div 2) - 3"/>
                    </xsl:variable>
                    <xsl:variable name="centralPointY">
                        <xsl:value-of select="$Cy"/>
                    </xsl:variable>
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(90, </xsl:text>
                        <xsl:value-of select="$centralPointX"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$centralPointY"/>
                        <xsl:text>) translate(5.75, 0)</xsl:text>
                    </xsl:attribute>
                    <!-- twist support -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy+ 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                        </xsl:attribute>
                    </path>
                </g>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop_inner',position())}"
                    x="{- ($bookblockThickness) + 6}"/>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop_inner',position())}"
                    x="{- ($bookblockThickness) + 6}" y="{$coverHeight - 2* 5.75}"/>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop_inner',position())}"
                    y="{$coverHeight - 2* 5.75}"/>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/type/saltire">
                <!-- outer view -->
                <g xmlns="http://www.w3.org/2000/svg" id="endbandSaltire">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 4"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 7"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 4"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 7"/>
                            </xsl:attribute>
                        </path>
                    </g>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 4"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 4"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line_white</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="($Bx - ($bookblockThickness div 2) + 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 7"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="($Bx + ($bookblockThickness div 2) - 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 4"/>
                            </xsl:attribute>
                        </path>
                    </g>
                </g>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#endbandSaltire"
                    y="{$coverHeight - 2* 5.7}"/>
                <!-- inner view -->
                <xsl:variable name="centralPointX">
                    <xsl:value-of select="$Cx + ($bookblockThickness div 2) - 3"/>
                </xsl:variable>
                <xsl:variable name="centralPointY">
                    <xsl:value-of select="$Cy"/>
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg" id="{concat('twistedLoop', position())}">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(90, </xsl:text>
                        <xsl:value-of select="$centralPointX"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$centralPointY"/>
                        <xsl:text>) translate(5.75, 0)</xsl:text>
                    </xsl:attribute>
                    <xsl:variable name="startX">
                        <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                    </xsl:variable>
                    <xsl:variable name="startY">
                        <xsl:value-of select="$Cy - 0.75"/>
                    </xsl:variable>
                    <xsl:variable name="endX">
                        <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                    </xsl:variable>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                        id="{concat('untwistedLoop', position())}">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 0.7"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy+ 0.7"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 4.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.7"/>
                        </xsl:attribute>
                    </path>
                    <!-- extensions -->
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(70, </xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>)translate(0.5,0.5)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.75"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.75"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) + 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 0.75"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                        <xsl:attribute name="class">
                            <xsl:text>line4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate(70, </xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>)translate(-0.5,-0.5)</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.75"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy - 0.75"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 5.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="($Cx + ($bookblockThickness div 2) - 3) - 3.25"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Cy + 0.75"/>
                        </xsl:attribute>
                    </path>
                    <!-- twist -->
                    <xsl:variable name="twistModule">
                        <!-- twice the curved line - 1 -->
                        <xsl:value-of select="3"/>
                    </xsl:variable>
                    <xsl:call-template name="tacket_twist">
                        <xsl:with-param name="twistModule">
                            <xsl:value-of select="$twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="twistCount" as="xs:double">
                            <xsl:value-of select="(($endX - 2) - ($startX)) div $twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="twistRemainder">
                            <xsl:value-of select="(($endX) - ($startX)) mod $twistModule"/>
                        </xsl:with-param>
                        <xsl:with-param name="startX">
                            <xsl:value-of select="$startX + 1"/>
                        </xsl:with-param>
                        <xsl:with-param name="startY">
                            <xsl:value-of select="$startY"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </g>
                <use xmlns="http://www.w3.org/2000/svg" id="untwistedLoop_head"
                    xlink:href="{concat('#','untwistedLoop',position())}">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(90, </xsl:text>
                        <xsl:value-of select="$centralPointX"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$centralPointY"/>
                        <xsl:text>)translate(5.75,</xsl:text>
                        <xsl:value-of select="($bookblockThickness)- 6"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#untwistedLoop_head">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$coverHeight - 2*5.7"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="{concat('#','twistedLoop',position())}">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0,</xsl:text>
                        <xsl:value-of select="$coverHeight - 2*5.7"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="tacketing_reinforcements">
        <!-- Outer view -->
        <!-- reinforcements -->
        <xsl:choose>
            <!-- There is no way in the schema to say that there are no reinforcements,
            therefore it looks like surveyors were forced to use type[NC | NK | other]
            to indicate that there weren't any (at least in the two tacketed examples in the database -->
            <!-- tackets -->
            <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type[NC | NK | other]">
                <!-- do nothing, see note above -->
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type/bands">
                <xsl:variable name="bandHeight">
                    <xsl:value-of select="($coverHeight div 3) - (($coverHeight div 3) div 2)"/>
                </xsl:variable>
                <!-- middle -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" id="band">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($coverHeight div 2) - ($bandHeight div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth +($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($coverHeight div 2) - ($bandHeight div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx + ($bookblockThickness div 2) + $jointWidth + ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($coverHeight div 2) + ($bandHeight div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Bx - ($bookblockThickness div 2) - $jointWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($coverHeight div 2) + ($bandHeight div 2)"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
                <!-- head -->
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#band">
                    <xsl:attribute name="y">
                        <xsl:value-of select="- ($coverHeight div 2) + $bandHeight - 5"/>
                    </xsl:attribute>
                </use>
                <!-- tail -->
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#band">
                    <xsl:attribute name="y">
                        <xsl:value-of select="($coverHeight div 2) - $bandHeight + 5"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type/individual">
                <!-- draw reinforcements -->
                <!-- It is not know the number of tackets; we are assuming two tacketing 'stations':
                    one towards the left side, one towards the right side -->
                <xsl:choose>
                    <xsl:when test="case/type/laceAttached/tacketed/locations/location/sewing">
                        <xsl:for-each select="ancestor::book/sewing/stations/station">
                            <!--<!-\- center -\->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="individualTacketReinforcement">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 8"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement - 8"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 8"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + measurement + 8"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>-->
                            <!-- left -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                id="individualTacketReinforcement">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of
                                        select="($bookThicknessDatatypeChecker div 2) - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 8"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                            <!-- right -->
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                                id="individualTacketReinforcement">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of
                                        select="-($bookThicknessDatatypeChecker div 2) + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,0)</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 8"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of
                                        select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 8"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/tacketed/locations/location/endband">
                        <!-- head right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="individualTacketReinforcement">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of
                                    select="($bookThicknessDatatypeChecker div 2) - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <!-- tail right -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="individualTacketReinforcement">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of
                                    select="($bookThicknessDatatypeChecker div 2) - ((($bookThicknessDatatypeChecker div 2) div 3) div 2)"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <!-- head left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="individualTacketReinforcement">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of
                                    select="-($bookThicknessDatatypeChecker div 2) + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) + 4"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <!-- tail left -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            id="individualTacketReinforcement">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of
                                    select="-($bookThicknessDatatypeChecker div 2) + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) + 4"/>
                                <xsl:text>,0)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx + ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Bx - ((($bookThicknessDatatypeChecker div 2) div 3) div 2) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type/singleStation">
                <xsl:choose>
                    <xsl:when test="case/type/laceAttached/tacketed/locations/location/sewing">
                        <xsl:for-each select="ancestor::book/sewing/stations/station">
                            <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                                <xsl:attribute name="class">
                                    <xsl:text>line2</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement - 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 10"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$By + measurement + 10"/>
                                    <xsl:text>z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="case/type/laceAttached/tacketed/locations/location/endband">
                        <!-- head -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <!-- tail -->
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 1.5"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$By + $coverHeight - 10"/>
                                <xsl:text>z</xsl:text>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="case/type/laceAttached/tacketed/reinforcements/type/wholeSpine">
                <!--  -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx - ($bookblockThickness div 2) + 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 1"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($bookblockThickness div 2) - 1"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $coverHeight - 1"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="tacket_twist">
        <xsl:param name="counter" select="1" as="xs:integer"/>
        <xsl:param name="twistModule"/>
        <xsl:param name="twistCount" as="xs:double"/>
        <xsl:param name="twistRemainder"/>
        <xsl:param name="startX"/>
        <xsl:param name="startY"/>
        <g xmlns="http://www.w3.org/2000/svg" id="twistTranslated">
            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#twist">
                <xsl:attribute name="transform">
                    <xsl:text>translate(</xsl:text>
                    <xsl:value-of
                        select="if ($counter eq 1) then $startX else $startX + (($counter - 1) * $twistModule + ($twistRemainder div ($twistCount - 1)))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$startY"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
            </use>
        </g>
        <xsl:choose>
            <xsl:when test="$counter le ($twistCount)">
                <xsl:call-template name="tacket_twist">
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="twistModule" select="$twistModule"/>
                    <xsl:with-param name="twistRemainder" select="$twistRemainder"/>
                    <xsl:with-param name="twistCount" select="$twistCount"/>
                    <xsl:with-param name="startX" select="$startX"/>
                    <xsl:with-param name="startY" select="$startY"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Description -->
    <xsl:template name="description">
        <xsl:variable name="Ex">
            <xsl:value-of select="$Bx - ($bookblockThickness div 2) - $jointWidth - $boardWidth"/>
        </xsl:variable>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>descText</xsl:text>
            </xsl:attribute>
            <text xmlns="http://www.w3.org/2000/svg" x="{$Ex}" y="{$Oy + 40}">
                <tspan xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Cover type: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ex + 40}">
                        <xsl:value-of select="type/node()[2]/name()"/>
                        <xsl:choose>
                            <xsl:when test="type[overInboard | case]">
                                <xsl:choose>
                                    <xsl:when test="type/overInboard">
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of
                                            select="if (type/node()/type/other) 
                                                    then concat(type/node()/type/node()[2]/name(), ': ', type/node()/type/other/text()) 
                                                    else type/node()/type/node()[2]/name()"/>
                                        <xsl:choose>
                                            <xsl:when
                                                test="type/overInboard/type/quarter/quarterWithParchmentTips">
                                                <xsl:text> - parchment tips: </xsl:text>
                                                <xsl:value-of
                                                  select="type/overInboard/type/quarter/quarterWithParchmentTips/node()[2]/name()"
                                                />
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of
                                            select="if (type/node()/type/other) 
                                                    then concat(type/node()/type/node()[2]/name(), ': ', type/node()/type/other/text()) 
                                                    else type/node()/type/node()[2]/name()"/>
                                        <xsl:choose>
                                            <xsl:when test="type/case/type[adhesive | laceAttached]">
                                                <xsl:text>: </xsl:text>
                                                <xsl:value-of
                                                  select="if (type/case/type/node()/other) 
                                                            then concat(type/case/type/node()/node()[2]/name(), ': ', type/case/type/node()/other/text()) 
                                                            else type/case/type/node()/node()[2]/name()"/>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="type/case/type[adhesive/threePiece | laceAttached[limpLaced | boards]]">
                                                  <xsl:text> - </xsl:text>
                                                  <xsl:value-of
                                                  select="if (type/case/type/node()/node()/other) 
                                                                    then concat(type/case/type/node()/node()/node()[2]/name(), ': ', type/case/type/node()/node()/other/text()) 
                                                                    else type/case/type/node()/node()/node()[2]/name()"
                                                  />
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="type/case/type/laceAttached/tacketed">
                                                  <xsl:text> - </xsl:text>
                                                  <xsl:value-of
                                                  select="if (type/case/type/laceAttached/tacketed/locations/location/other) 
                                                                    then concat(type/case/type/laceAttached/tacketed/locations/location/node()[2]/name(), ': ', type/case/type/laceAttached/tacketed/locations/location/other/text()) 
                                                                    else type/case/type/laceAttached/tacketed/locations/location/node()[2]/name()"
                                                  />
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:text>)</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="type/case">
                                                <xsl:text> - Edges: </xsl:text>
                                                <xsl:value-of
                                                  select="if (type/case/preparation/edgeTreatment/other) 
                                                    then concat(type/case/preparation/edgeTreatment/node()[2]/name(), ': ', type/case/preparation/edgeTreatment/other/text()) 
                                                    else type/case/preparation/edgeTreatment/node()[2]/name()"
                                                />
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ex}">
                        <xsl:choose>
                            <xsl:when test="type[overInboard | case]">
                                <xsl:text>Joints: </xsl:text>
                                <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ex + 40}">
                                    <xsl:value-of
                                        select="if (type/node()/joints/other) 
                                        then concat(type/node()/joints/node()[2]/name(), ': ', type/node()/joints/other/other/text()) 
                                        else type/node()/joints/node()[2]/name()"/>
                                    <xsl:choose>
                                        <xsl:when test="type/case/joints/spineCrease">
                                            <xsl:text> (joint crease: </xsl:text>
                                            <xsl:value-of
                                                select="if (type/case/joints/spineCrease/jointCrease/other) 
                                                then concat(type/case/joints/spineCrease/jointCrease/node()[2]/name(), ': ', type/case/joints/spineCrease/jointCrease/other/text()) 
                                                else type/case/joints/spineCrease/jointCrease/node()[2]/name()"/>
                                            <xsl:text>)</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </tspan>
                            </xsl:when>
                        </xsl:choose>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ex}">
                        <xsl:choose>
                            <xsl:when test="type[overInboard | case]">
                                <xsl:text>Corners: </xsl:text>
                                <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ex + 40}">
                                    <xsl:choose>
                                        <xsl:when test="type/overInboard">
                                            <xsl:for-each select="type/overInboard/corners/corner">
                                                <xsl:value-of
                                                  select="if (./other) 
                                                    then concat(./node()[2]/name(), ': ', ./text()) 
                                                    else ./node()[2]/name()"/>
                                                <xsl:choose>
                                                  <xsl:when test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="if (type/case/corners/other) 
                                                then concat(type/case/corners/node()[2]/name(), ': ', type/case/corners/other/text()) 
                                                else type/case/corners/node()[2]/name()"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tspan>
                            </xsl:when>
                        </xsl:choose>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ex}">
                        <xsl:text>Turnins: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ex + 40}">
                            <xsl:for-each select="turnins/turnin">
                                <xsl:value-of
                                    select="if (location/other) 
                                    then concat(location/node()[2]/name(), ': ', location/other/text()) 
                                    else location/node()[2]/name()"/>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of
                                    select="if (trim/other) 
                                    then concat(trim/node()[2]/name(), ': ', trim/other/text()) 
                                    else trim/node()[2]/name()"/>
                                <xsl:choose>
                                    <xsl:when test="position() != last()">
                                        <xsl:text>; </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text> - </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:text>Yapp: </xsl:text>
                            <xsl:value-of
                                select="if (yapp/other) 
                                then concat(yapp/node()[2]/name(), ': ', yapp/other/text()) 
                                else yapp/node()[2]/name()"
                            />
                        </tspan>
                    </tspan>
                    <!--<tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ex}">
                        <xsl:choose>
                            <xsl:when test="type/case/type/laceAttached/tacketed">
                                <xsl:text>Tacketing: </xsl:text>
                                <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ex + 40}">
                                    <xsl:text>tacket type: </xsl:text>
                                    <xsl:value-of
                                        select="if (type/case/type/laceAttached/tacketed/type/other) 
                                            then concat(type/case/type/laceAttached/tacketed/type/node()[2]/name(), ': ', type/case/type/laceAttached/tacketed/type/other/text()) 
                                            else type/case/type/laceAttached/tacketed/type/node()[2]/name()"/>
                                    <xsl:text>; </xsl:text>
                                    <xsl:text>reinforcement type: </xsl:text>
                                    <xsl:value-of
                                        select="if (type/case/type/laceAttached/tacketed/reinforcements/type/other) 
                                            then concat(type/case/type/laceAttached/tacketed/reinforcements/type/node()[2]/name(), ': ', type/case/type/laceAttached/tacketed/reinforcements/type/other/text()) 
                                            else type/case/type/laceAttached/tacketed/reinforcements/type/node()[2]/name()"
                                    />
                                </tspan>
                            </xsl:when>
                        </xsl:choose>
                    </tspan>-->
                </tspan>
                <!--<xsl:choose>
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
                </xsl:choose>-->
            </text>
        </g>
    </xsl:template>

    <!-- Titling -->
    <xsl:template name="title">
        <xsl:param name="detected" select="0"/>
        <xsl:param name="use"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of
                    select="$Ax + ($bookblockThickness div 2) + $jointWidth + $boardWidth + ($delta div 2)"
                />
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 20"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:text>covering</xsl:text>
            <xsl:choose>
                <xsl:when test="$detected eq 0">
                    <xsl:text> not detected</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$use"/>
                    <xsl:text>)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </text>
    </xsl:template>

    <xsl:template name="sectionTitle">
        <xsl:param name="class"/>
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="text"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:value-of select="$class"/>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$y"/>
            </xsl:attribute>
            <xsl:value-of select="$text"/>
        </text>
    </xsl:template>

    <!-- Uncertainty template -->
    <xsl:template name="certainty">
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="uncertaintyIncrement"/>
        <xsl:param name="type" as="xs:string"/>
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
            <xsl:when test="$type = '5'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f5)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$type = '6'">
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:attribute name="filter">
                            <xsl:text>url(#f6)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
