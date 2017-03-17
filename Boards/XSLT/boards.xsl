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
    <xsl:variable name="filenameLeft"
        select="concat('../../Transformations/Boards/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'leftBoard', '.svg')"/>
    <xsl:variable name="filenameRight"
        select="concat('../../Transformations/Boards/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'rightBoard', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="$Ox"/>

    <!-- X value of the upperleft corner of the above view of the inner surface of the board -->
    <xsl:variable name="Cx" select="$Ox + 100"/>
    <xsl:variable name="Cy" select="$Oy + 80"/>

    <!-- Value of the delta between the various views -->
    <xsl:param name="delta" select="10"/>

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
    <xsl:variable name="boardHeight">
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

    <xsl:template name="main" match="/">
        <xsl:choose>
            <xsl:when test="book/boards/yes/boards/board/location/left">
                <xsl:for-each select="book/boards/yes/boards/board/location/left">
                    <xsl:variable name="boardThickness">
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/boardThickness[not(NK)]">
                                <xsl:value-of
                                    select="parent::location/following-sibling::formation/xs:integer(boardThickness)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="10"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:result-document href="{$filenameLeft}" method="xml" indent="yes" encoding="utf-8"
                        doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Boards/CSS/style.css"&#32;</xsl:text>
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
                                <xsl:call-template name="title_left">
                                    <xsl:with-param name="detected" select="1"/>
                                </xsl:call-template>
                                <xsl:call-template name="description_left"/>
                                <xsl:call-template name="notes_left">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                </xsl:call-template>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <!--<!-\- This translation brings the cross section to the bottom of the page -\->
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + (2 * $boardThickness) + $boardHeight + 3 * $delta"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>-->
                                    <!-- This translation brings the cross section to the top of the page -->
                                    <!--<xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy - 4 * $delta"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>-->
                                    <!-- This translation brings the cross section to the top of the page over the outer Surface view -->
                                    <xsl:attribute name="transform">
                                        <xsl:text>rotate(180 </xsl:text>
                                        <xsl:value-of select="$Cx + ($boardWidth div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Cy + ($boardThickness div 2)"/>
                                        <xsl:text>)</xsl:text>
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of
                                            select="$Ox - $boardWidth - $boardThickness - 2 * $delta"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Oy + 3 * $delta"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                    <xsl:call-template name="crossSectionFilled">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="crossSection">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                </g>
                                <xsl:variable name="Ex" select="$Cx - $boardThickness - $delta"/>
                                <xsl:variable name="Ey" select="$Cy + $boardThickness + $delta"/>
                                <g xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="transform">
                                        <xsl:text>rotate(180 </xsl:text>
                                        <xsl:value-of select="$Ex + ($boardThickness div 2)"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Ey + ($boardHeight div 2)"/>
                                        <xsl:text>)</xsl:text>
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of
                                            select="$Ex - 2 * $boardWidth - $boardThickness - 16 * $delta"/>
                                        <xsl:text>,0)</xsl:text>
                                    </xsl:attribute>
                                    <xsl:call-template name="crossSectionVerticalFilled">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="crossSectionVertical">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                </g>
                                <xsl:call-template name="head-tailEdge">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                </xsl:call-template>
                                <xsl:call-template name="foredge">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                </xsl:call-template>
                                <xsl:call-template name="spineEdge">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                </xsl:call-template>
                                <xsl:call-template name="innerSurface">
                                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                </xsl:call-template>
                            </svg>
                        </svg>
                    </xsl:result-document>
                </xsl:for-each>
                <xsl:for-each select="book/boards/yes/boards/board/location/right">
                    <xsl:variable name="boardThickness">
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/boardThickness[not(NK)]">
                                <xsl:value-of
                                    select="parent::location/following-sibling::formation/xs:integer(boardThickness)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="10"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:result-document href="{$filenameRight}" method="xml" indent="yes" encoding="utf-8"
                        doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Boards/CSS/style.css"&#32;</xsl:text>
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
                            <desc>Right board</desc>
                            <!--                  
                    <xsl:call-template name="notes_right">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                    </xsl:call-template>-->
                            <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1 1)">
                                <svg>
                                    <!--right board visualization -->
                                    <xsl:attribute name="x">
                                        <xsl:value-of select="$Ox - $boardWidth - 450"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="y">
                                        <xsl:value-of select="$Oy"/>
                                    </xsl:attribute>
                                    <xsl:call-template name="title_right">
                                        <xsl:with-param name="detected" select="1"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="description_right"/>
                                    <xsl:call-template name="notes_right">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <!--<!-\- This translation brings the cross section to the bottom of the page -\->
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Ox"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + (2 * $boardThickness) + $boardHeight + 3 * $delta"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>-->
                                        <!-- This translation brings the cross section to the top of the page -->
                                        <!--<xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Ox"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy - 4 * $delta"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>-->
                                        <!-- This translation brings the cross section to the top of the page over the outer Surface view -->
                                        <xsl:attribute name="transform">
                                            <xsl:text>rotate(180 </xsl:text>
                                            <xsl:value-of select="$Cx + ($boardWidth div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Cy + ($boardThickness div 2)"/>
                                            <xsl:text>)</xsl:text>
                                            <xsl:text>translate(</xsl:text>
                                            <xsl:value-of
                                                select="$Ox - $boardWidth - $boardThickness - 2 * $delta"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Oy + 3 * $delta"/>
                                            <xsl:text>)</xsl:text>
                                        </xsl:attribute>
                                        <xsl:call-template name="crossSectionFilled">
                                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="crossSection">
                                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                        </xsl:call-template>
                                    </g>
                                    <xsl:variable name="Ex" select="$Cx - $boardThickness - $delta"/>
                                    <xsl:variable name="Ey" select="$Cy + $boardThickness + $delta"/>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <xsl:attribute name="transform">
                                            <xsl:text>rotate(180 </xsl:text>
                                            <xsl:value-of select="$Ex + ($boardThickness div 2)"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$Ey + ($boardHeight div 2)"/>
                                            <xsl:text>)</xsl:text>
                                            <xsl:text>translate(</xsl:text>
                                            <xsl:value-of
                                                select="$Ex - 2 * $boardWidth - $boardThickness - 16 * $delta"/>
                                            <xsl:text>,0)</xsl:text>
                                        </xsl:attribute>
                                        <xsl:call-template name="crossSectionVerticalFilled">
                                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="crossSectionVertical">
                                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                        </xsl:call-template>
                                    </g>
                                    <xsl:call-template name="head-tailEdge">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="foredge">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="spineEdge">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="innerSurface">
                                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                                    </xsl:call-template>
                                </svg>
                            </g>
                        </svg>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>                
                <svg xmlns="http://www.w3.org/2000/svg">
                    <xsl:call-template name="title_left">
                        <xsl:with-param name="detected" select="0"/>
                    </xsl:call-template>
                </svg>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>

    <xsl:template name="crossSection">
        <xsl:param name="boardThickness" select="10" as="xs:integer"/>
        <xsl:param name="Bx" select="$Cx"/>
        <xsl:param name="By" select="$Cy"/>
        <xsl:variable name="spineEdgex">
            <xsl:choose>
                <xsl:when test="ancestor::book/spine/profile/joints/angled">
                    <xsl:value-of select="$Bx + $boardWidth * .97"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Bx + $boardWidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- The cross-section is divided in 3 paths (top, spine-edge and bottom, foreedge) so that the right level of uncertainty can be applied to the right portion of the drawing -->
        <!-- NB: the foreedge is drawn in another template (crossSection_foreedge) to allow for the edgeTreatment information to be drawn accordingly -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[centreBevels | claspBevels]">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness "/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth - ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth - ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[centreBevels | claspBevels]">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="ancestor::book/spine/profile/joints/angled">
                        <!--<xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 8)"/>-->
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/slight">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness * 2 div 3"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>-->
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness * .5"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .95"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>-->
                    <xsl:when test="ancestor::book/spine/profile/joints/acute">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$By + $boardThickness - ($boardThickness div (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then 3 else 8))"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <xsl:call-template name="crossSection_foreedge">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="crossSection_foreedge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Bx" select="$Cx"/>
        <xsl:param name="By" select="$Cy"/>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/internalBevels">
                <!-- Do nothing as the foreedge has already been drawn in the previous template -->
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[centreBevels | claspBevels]">
                <!-- NB: boards with centre and clasp bevels do not call the crossSection_edgeTreatment template as the two foreedges are non-compatible  -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 3)"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other]">
                <xsl:call-template name="crossSection_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Bx"/>
                    <xsl:with-param name="Zy" select="$By + $boardThickness"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                <xsl:call-template name="crossSection_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Bx"/>
                    <xsl:with-param name="Zy"
                        select="$By + $boardThickness - ($boardThickness div 3)"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                <xsl:call-template name="crossSection_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Bx"/>
                    <xsl:with-param name="Zy"
                        select="$By + $boardThickness - ($boardThickness div 3)"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSection_edgeTreatment">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Bx" select="$Cx"/>
        <xsl:param name="By" select="$Cy"/>
        <xsl:param name="Zx" select="$Bx"/>
        <xsl:param name="Zy" select="$By + $boardThickness"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($By + $boardThickness) - $Zy)"/>
        </xsl:variable>
        <xsl:choose>
            <!--<xsl:when
                test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4]">
                <!-\- NB: leaves a blank -\->
                <!-\- It might be an idea to draw a very blurry line resembling the simplest of the drawings - i.e. a straight line - 
                            but also setting the line in red to highlight that it's not a correct representation of the original  -\->
                <!-\-<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line-red</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>-\->
            </xsl:when>-->
            <xsl:when
                test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK | type3]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type1">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select=" $By + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$By + (($boardThickness - (($By + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy - ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type2">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$By + (($boardThickness - (($By + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSectionFilled">
        <xsl:param name="boardThickness" select="10" as="xs:integer"/>
        <xsl:param name="Bx" select="$Cx"/>
        <xsl:param name="By" select="$Cy"/>
        <xsl:variable name="spineEdgex">
            <xsl:choose>
                <xsl:when test="ancestor::book/spine/profile/joints/angled">
                    <xsl:value-of select="$Bx + $boardWidth * .97"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Bx + $boardWidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
            fill="#E8E8E8">
            <!--<xsl:attribute name="class">
                <xsl:text>nolineFilled</xsl:text>
            </xsl:attribute>-->
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[centreBevels | claspBevels]">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness "/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth - ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth - ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="ancestor::book/spine/profile/joints/angled">
                        <!--
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 8)"/>-->
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>
                    <!-- <xsl:when test="ancestor::book/spine/profile/joints/slight">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness * 2 div 3"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>-->
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness * .5"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .95"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>-->
                    <xsl:when test="ancestor::book/spine/profile/joints/acute">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$By + $boardThickness - ($boardThickness div (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then 3 else 8))"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + $boardThickness"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <!-- Do nothing as the foreedge has already been drawn -->
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[centreBevels | claspBevels]">
                        <!-- NB: boards with centre and clasp bevels do not call the crossSection_edgeTreatment template as the two foreedges are non-compatible  -->
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Bx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$By + ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other]">
                        <xsl:call-template name="crossSectionFilled_edgeTreatment">
                            <xsl:with-param name="Zx" select="$Bx"/>
                            <xsl:with-param name="Zy" select="$By + $boardThickness"/>
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:call-template name="crossSectionFilled_edgeTreatment">
                            <xsl:with-param name="Zx" select="$Bx"/>
                            <xsl:with-param name="Zy"
                                select="$By + $boardThickness - ($boardThickness div 3)"/>
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:call-template name="crossSectionFilled_edgeTreatment">
                            <xsl:with-param name="Zx" select="$Bx"/>
                            <xsl:with-param name="Zy"
                                select="$By + $boardThickness - ($boardThickness div 3)"/>
                            <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="crossSectionFilled_edgeTreatment">
        <!-- This template completes the crossSectionFilled template  -->
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Bx" select="$Cx"/>
        <xsl:param name="By" select="$Cy"/>
        <xsl:param name="Zx" select="$Bx"/>
        <xsl:param name="Zy" select="$By + $boardThickness"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($By + $boardThickness) - $Zy)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4]">
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Zx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Zy"/>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/edgeTreatment[NC | NK | type3]">
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Zx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Zy"/>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type1">
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select=" $By + ($edgeBoardThickness div 4)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx + ($boardWidth div 84)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$By + (($boardThickness - (($By + $boardThickness) - $Zy)) div 2)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Zy - ($edgeBoardThickness div 4)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Zx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Zy"/>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type2">
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Bx + ($boardWidth div 84)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                    select="$By + (($boardThickness - (($By + $boardThickness) - $Zy)) div 2)"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Zx"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Zy"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="head-tailEdge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Cx" select="$Cx"/>
        <xsl:param name="Cy" select="$Cy"/>
        <xsl:param name="counter" select="1"/>
        <xsl:variable name="spineEdgex">
            <xsl:choose>
                <xsl:when test="ancestor::book/spine/profile/joints/angled">
                    <xsl:value-of select="$Cx + $boardWidth * .97"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Cx + $boardWidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- The cross-section is divided in 3 paths (top, spine-edge and bottom, foreedge) so that the right level of uncertainty can be applied to the right portion of the drawing -->
        <!-- NB: the foreedge is drawn in another template (crossSection_foreedge) to allow for the edgeTreatment information to be drawn accordingly -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | centreBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:choose>
                            <!-- NB: the positioning of the bevels is arbitrary as no measurement (relative or absolute) is given -->
                            <!-- NB: for clasp bevels no precise information is given about the number and location of clasps -->
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/centreBevels">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + ($boardWidth div 3) + ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + 2 * ($boardThickness div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Cx + $boardWidth - ($boardWidth div 3) - ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + 2 * ($boardThickness div 3)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | centreBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$spineEdgex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="ancestor::book/spine/profile/joints/angled">
                        <!--
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness - ($boardThickness div 8)"/>-->
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:when>
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/slight">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness div 3"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:when>-->
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness * .5"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth * .95"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:when>-->
                    <xsl:when test="ancestor::book/spine/profile/joints/acute">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + ($boardThickness div (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then 3 else 8))"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6.5)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Cx + $boardWidth - ($boardWidth div 84) else $Cy + $boardWidth"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <!-- Sewn and recessed shaping line -->
        <xsl:choose>
            <xsl:when
                test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                                <xsl:value-of select="$Cy + ($boardThickness div 3)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$Cy"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $boardThickness"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="head-tailEdge_foredge">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$counter lt 2">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>rotate(</xsl:text>
                        <xsl:value-of select="180"/>
                        <xsl:text>,&#32;</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 2)"/>
                        <xsl:text>,&#32;</xsl:text>
                        <xsl:value-of select="$Cy + ($boardThickness div 2)"/>
                        <xsl:text>)</xsl:text>
                        <xsl:text>&#32;translate(</xsl:text>
                        <xsl:value-of select="200 + $boardWidth"/>
                        <xsl:text>,&#32;</xsl:text>
                        <xsl:value-of
                            select="($Oy + $boardThickness + $boardHeight + 2 * $delta) * -1"/>
                        <xsl:text>)</xsl:text>
                        <xsl:text>&#32;scale(-1, 1)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="head-tailEdge">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        <xsl:with-param name="Cx" select="$Cx"/>
                        <xsl:with-param name="Cy" select="$Cy"/>
                        <xsl:with-param name="counter" select="$counter + 1"/>
                    </xsl:call-template>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="head-tailEdge_foredge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Cx" select="$Cx"/>
        <xsl:param name="Cy" select="$Cy"/>
        <xsl:param name="counter" select="1"/>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/internalBevels">
                <xsl:variable name="edgeBoardThickness">
                    <xsl:value-of select="$boardThickness"/>
                </xsl:variable>
                <!-- Do nothing as the foreedge has already been drawn in the previous template however backcornering need to be drawn -->
                <xsl:choose>
                    <!-- Add the back corner if needed -->
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                            stroke-linejoin="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <!-- TO DO: add uncertainty: NC, NK, other should have an increasingly higher degree of uncertainty  -->
                            <!-- TO DO -->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor::book/spine/profile/joints/acute) then $Cy - 4.5 else $Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor::book/spine/profile/joints/angled) then $Cy + $edgeBoardThickness + 4.5 else $Cy + $edgeBoardThickness"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | centreBevels | claspBevels]">
                <xsl:call-template name="head-tailEdge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Cx"/>
                    <xsl:with-param name="Zy" select="$Cy"/>
                    <xsl:with-param name="Cx" select="$Cx"/>
                    <xsl:with-param name="Cy" select="$Cy + $boardThickness"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                <xsl:call-template name="head-tailEdge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Cx"/>
                    <xsl:with-param name="Zy" select="$Cy + ($boardThickness div 3)"/>
                    <xsl:with-param name="Cx" select="$Cx"/>
                    <xsl:with-param name="Cy" select="$Cy + $boardThickness"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <!--            <xsl:when test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                <xsl:call-template name="head-tailEdge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Cx"/>
                    <xsl:with-param name="Zy"
                        select="$Cy + ($boardThickness div 3)"/>
                    <xsl:with-param name="Cx" select="$Cx"/>
                    <xsl:with-param name="Cy" select="$Cy + $boardThickness"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>-->
        </xsl:choose>
    </xsl:template>

    <!-- NB: the tail edge is the same as the head edge and is drawn simply recalling the same set of templates with different coordinates as parameters -->
    <xsl:template name="head-tailEdge_cornerTreatment">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Cx" select="$Cx"/>
        <xsl:param name="Cy" select="$Cy"/>
        <xsl:param name="Zx" select="$Cx"/>
        <xsl:param name="Zy" select="$Cy + $boardThickness"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($Cy + $boardThickness) - $Zy)"/>
        </xsl:variable>
        <xsl:choose>
            <!--<xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6]">
                <!-\- NB: leaves a blank -\->
                <!-\- It might be an idea to draw a very blurry line resembling the simplest of the drawings - i.e. a straight line - 
                            but also setting the line in red to highlight that it's not a correct representation of the original  -\->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line-red</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>-->
            <xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6 | NC | NK | type5]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6 | NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[type1 | type2]">
                <!-- The diagram is divided in four paths to allow for increased uncertainty towards the spine edge
                    as no description is given for the way the groove ends and where it ends, plus the line of the inside of the groove -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading2)">
                    <xsl:attribute name="class">
                        <xsl:text>line4fading</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 2)"/><!--***-->
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2) + 0.01"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading)">
                    <xsl:attribute name="class">
                        <xsl:text>line2fading</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"
                                />
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"
                                />
                            </xsl:when>
                        </xsl:choose>
                        <!--<xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4) + 0.001"/>-->
                    </xsl:attribute>
                </path>
                <!-- Separate line to allow for fading at different lengths -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading)">
                    <xsl:attribute name="class">
                        <xsl:text>line2fading</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Cx + 3 * ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"
                                />
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Cx + ($boardWidth div 42)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"
                                />
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4) + 0.001"/>
                    </xsl:attribute>
                </path>
               <!-- <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading)">
                    <xsl:attribute name="class">
                        <xsl:text>line2fading</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3.8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4) + 0.01"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3.8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 4.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4) + 0.01"
                        />
                    </xsl:attribute>
                </path>-->
                <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-\- Uncertainty: there is no informtaion on the kind of shape found at the end of the channel  -\->
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                    </xsl:attribute>
                </path>-->
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/corners/foredge/type3">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading2)">
                    <xsl:attribute name="class">
                        <xsl:text>line4fading</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2) + 0.01"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- Uncertainty: there is no informtaion on the kind of shape found at the end of the channel  -->
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/corners/foredge/type4">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading2)">
                    <xsl:attribute name="class">
                        <xsl:text>line4fading</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + $boardWidth - ($boardWidth div 2) - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2) + 0.01"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading2)">
                    <xsl:attribute name="class">
                        <xsl:text>line2fading</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4) + 0.01"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round" stroke="url(#fading2)">
                    <xsl:attribute name="class">
                        <xsl:text>line2fading</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4) + 0.01"
                        />
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy - ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
                <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select=" $Cy + ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Cx + $boardWidth - ($boardWidth div 6) - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + (($boardThickness - (($Cy + $boardThickness) - $Zy)) div 2)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Cy + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 6)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                    </xsl:attribute>
                </path>-->
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <!-- Add the back corner if needed -->
            <xsl:when test="parent::location/following-sibling::formation/corners/spine/backCorner">
                <!-- DO WE NEED TO MODIFY THE FOLLOWING PATH TO COVER LINES??? -->
                <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>nolineFilledWhite</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty: NC, NK, other should have an increasingly higher degree of uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:choose>
                            <xsl:when test="ancestor::book/spine/profile/joints/slight">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth * .97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth * .97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $edgeBoardThickness  * 2 div 3"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Cx + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Cy + $edgeBoardThickness"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Cy"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>-->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty: NC, NK, other should have an increasingly higher degree of uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/spine/profile/joints/acute) then $Cy - 4.5 else $Cy - .5"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Cx + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/spine/profile/joints/angled) then $Cy + $edgeBoardThickness + 4.5 else $Cy + $edgeBoardThickness + .5"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="foredge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Dx" select="$Cx - $boardThickness - $delta"/>
        <xsl:param name="Dy" select="$Cy + $boardThickness + $delta"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | centreBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:choose>
                            <!-- NB: the positioning of the bevels is arbitrary as no measurement (relative or absolute) is given -->
                            <!-- NB: for clasp bevels no precise information is given about the number and location of clasps -->
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/centreBevels">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardHeight div 3.5)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + $boardThickness - ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + ($boardHeight div 3.5) + ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + $boardThickness - ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + $boardHeight - ($boardHeight div 3.5) - ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + $boardHeight - ($boardHeight div 3.5)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/claspBevels">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardHeight div 6)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + ($boardHeight div 6) + ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + ($boardHeight div 6) + ($boardWidth div 16) + ($boardHeight div 32)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + ($boardHeight div 6) + 2 * ($boardWidth div 16) + ($boardHeight div 32)"/>
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + $boardHeight - ($boardHeight div 6) - 2 * ($boardWidth div 16) - ($boardHeight div 32)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + $boardHeight - ($boardHeight div 6) - ($boardWidth div 16) - ($boardHeight div 32)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + ($boardThickness div 3)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$Dy + $boardHeight - ($boardHeight div 6) - ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + $boardHeight - ($boardHeight div 6)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardHeight div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardHeight div 8)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;z</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <xsl:call-template name="foredge_head-tailEdge">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="Dx" select="$Dx"/>
            <xsl:with-param name="Dy" select="$Dy"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="foredge_head-tailEdge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Dx" select="$Cx - $boardThickness - $delta"/>
        <xsl:param name="Dy" select="$Cy + $boardThickness + $delta"/>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/internalBevels">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | centreBevels | claspBevels]">
                <xsl:call-template name="foredge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Dx + $boardThickness"/>
                    <xsl:with-param name="Zy" select="$Dy"/>
                    <xsl:with-param name="Dx" select="$Dx"/>
                    <xsl:with-param name="Dy" select="$Dy"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                <xsl:call-template name="foredge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Dx + ($boardThickness div 3)"/>
                    <xsl:with-param name="Zy" select="$Dy"/>
                    <xsl:with-param name="Dx" select="$Dx + $boardThickness"/>
                    <xsl:with-param name="Dy" select="$Dy"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <!--            <xsl:when test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                <xsl:call-template name="foredge_cornerTreatment">
                    <xsl:with-param name="Zx" select="$Dx + $boardThickness - ($boardThickness div 3)"/>
                    <xsl:with-param name="Zy" select="$Dy"/>
                    <xsl:with-param name="Dx" select="$Dx"/>
                    <xsl:with-param name="Dy" select="$Dy"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>-->
        </xsl:choose>
    </xsl:template>

    <xsl:template name="foredge_cornerTreatment">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Dx" select="$Cx"/>
        <xsl:param name="Dy" select="($Cy + $boardThickness) + $delta"/>
        <xsl:param name="Zx" select="$Dx + $boardThickness"/>
        <xsl:param name="Zy" select="$Dy"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($Dx + $boardThickness) - $Zx)"/>
        </xsl:variable>
        <xsl:choose>
            <!--
            <xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6]">
                <!-\- NB: leaves a blank -\->
                <!-\- It might be an idea to draw a very blurry line resembling the simplest of the drawings - i.e. a straight line - 
                            but also setting the line in red to highlight that it's not a correct representation of the original  -\->
                <!-\-<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line-red</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>-\->
            </xsl:when>-->
            <xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6 | NC | NK | type5]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="parent::location/following-sibling::formation/corners/foredge[other | unknownGrooved | type6 | NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/corners/foredge[type1 | type2]">
                <!-- The diagram is divided in four paths to allow for increased uncertainty towards the spine edge
                    as no description is given for the way the groove ends and where it ends, plus the line of the inside of the groove -->
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + ($boardWidth div 42)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + 3 * ($boardWidth div 84)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 42)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + $boardHeight - 3 * ($boardWidth div 84)"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of
                                    select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardWidth div 42)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + 3 * ($boardWidth div 84)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of
                                    select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + 3 * ($boardWidth div 84)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardWidth div 42)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + $boardHeight - 3 * ($boardWidth div 84)"
                                />
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 42)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 42)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + $boardHeight - 3 * ($boardWidth div 84)"
                                />
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of
                                    select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardWidth div 42)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + 3 * ($boardWidth div 84)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of
                                    select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + 3 * ($boardWidth div 84)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of
                                    select="$Dx + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Dy + ($boardWidth div 42)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + $boardHeight - 3 * ($boardWidth div 84)"
                                />
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 42)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type1">
                                <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 42)"/>
                            </xsl:when>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/foredge/type2">
                                <xsl:value-of select="$Dy + $boardHeight - 3 * ($boardWidth div 84)"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/corners/foredge/type3">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 84)"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/corners/foredge/type4">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 84)"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="$Dx + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + $edgeBoardThickness - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:attribute>
                </path>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Dx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Dx + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Dx + (($boardThickness - (($Dx + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Dy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSectionVertical">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Ex" select="$Cx - $boardThickness - $delta"/>
        <xsl:param name="Ey" select="$Cy + $boardThickness + $delta"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/centreBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardHeight div 8)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <xsl:call-template name="crossSectionVertical_head-tailEdge">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="Ex" select="$Ex"/>
            <xsl:with-param name="Ey" select="$Ey"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="crossSectionVertical_head-tailEdge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Ex" select="$Cx - $boardThickness - $delta"/>
        <xsl:param name="Ey" select="$Cy + $boardThickness + $delta"/>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/internalBevels">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | claspBevels]">
                <xsl:call-template name="crossSectionVertical_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Ex + $boardThickness"/>
                    <xsl:with-param name="Zy" select="$Ey"/>
                    <xsl:with-param name="Ex" select="$Ex"/>
                    <xsl:with-param name="Ey" select="$Ey"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/centreBevels">
                <xsl:call-template name="crossSectionVertical_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Ex + $boardThickness"/>
                    <xsl:with-param name="Zy" select="$Ey"/>
                    <xsl:with-param name="Ex"
                        select="$Ex + $boardThickness - ($boardThickness div 3)"/>
                    <xsl:with-param name="Ey" select="$Ey"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                <xsl:call-template name="crossSectionVertical_edgeTreatment">
                    <xsl:with-param name="Zx" select="$Ex + ($boardThickness div 3)"/>
                    <xsl:with-param name="Zy" select="$Ey"/>
                    <xsl:with-param name="Ex" select="$Ex + $boardThickness"/>
                    <xsl:with-param name="Ey" select="$Ey"/>
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSectionVertical_edgeTreatment">
        <xsl:param name="boardThickness"/>
        <xsl:param name="Ex"/>
        <xsl:param name="Ey"/>
        <xsl:param name="Zx"/>
        <xsl:param name="Zy"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($Ex + $boardThickness) - $Zx)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK | type3]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type1">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/edgeTreatment/type2">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSectionVerticalFilled">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Ex" select="$Cx - $boardThickness - $delta"/>
        <xsl:param name="Ey" select="$Cy + $boardThickness + $delta"/>
        <xsl:variable name="Zx">
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | centreBevels | claspBevels]">
                    <xsl:value-of select="$Ex + $boardThickness"/>
                </xsl:when>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion | internalBevels]">
                    <xsl:value-of select="$Ex + $boardThickness"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="Zy" select="$Ey"/>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness"/>
        </xsl:variable>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
            fill="#E8E8E8">
            <xsl:attribute name="d">
                <!-- external -->
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/centreBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardHeight div 8)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                    </xsl:when>
                </xsl:choose>
                <!-- edge Tail -->
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK | type3]">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment/type1">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then ($boardThickness div 3) else 0) + ($edgeBoardThickness div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                                <xsl:value-of
                                    select="$Ex + ($boardThickness div 3) + (($boardThickness - ($boardThickness div 3)) div 2)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment/type2">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy + $boardHeight"/>
                    </xsl:when>
                </xsl:choose>
                <!-- internal -->
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- edge Head -->
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/centreBevels">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment[other | unknownGrooved | type4 | NC | NK | type3]">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then ($boardThickness div 3) else 0)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment/type1">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Zx - ($edgeBoardThickness div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Zy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                                <xsl:value-of
                                    select="$Ex + ($boardThickness div 3) + (($boardThickness - ($boardThickness div 3)) div 2)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then ($boardThickness div 3) else 0) + ($edgeBoardThickness div 5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (if (parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]) then ($boardThickness div 3) else 0)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/edgeTreatment/type2">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Ex + (($boardThickness - (($Ex + $boardThickness) - $Zx)) div 2)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey + ($boardWidth div 84)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ex"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ey"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="innerSurface">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Ax" select="$Cx"/>
        <xsl:param name="Ay" select="($Cy + $boardThickness) + $delta"/>
        <xsl:param name="counter" select="1"/>
        <!-- The outline is divided in three paths to allow for increased uncertainty in case of NC, NK, or other values for corners/spine -->
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + $boardHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + $boardHeight"/>
                <xsl:text>&#32;M</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <!--<xsl:choose>
                <xsl:when test="parent::location/following-sibling::formation/corners/spine[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>-->
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[square | NC | NK | other]">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ay + $boardHeight - 8 - ($boardHeight * .02) else $Ay + $boardHeight - ($boardWidth div 16)"
                        />
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[backCorner | square | NC | NK | other]">
                        <xsl:value-of select="$Ay + $boardHeight"/>
                    </xsl:when>
                    <!--<xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[NC | NK | other]">
                        <xsl:value-of select="$Ay + $boardHeight - ($boardHeight div 14)"/>
                    </xsl:when>-->
                </xsl:choose>
                <xsl:text>&#32;L</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ay + 8 + ($boardHeight * .02) else $Ay + ($boardWidth div 16)"
                        />
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - ($boardHeight * .04)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardHeight * .04)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[square | NC | NK | other]">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:when>
                    <!--<xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[NC | NK | other]">
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardHeight div 14)"/>
                    </xsl:when>-->
                </xsl:choose>
                <!--<xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine[NC | NK | other]">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:when>
                </xsl:choose>-->
            </xsl:attribute>
        </path>
        <!-- Sewn and recessed shaping -->
        <xsl:choose>
            <xsl:when
                test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ax + $boardWidth - ($boardHeight * .02) else $Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardWidth div 16)"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/spine/backCorner">
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 8 + ($boardHeight * .02)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ax + $boardWidth - ($boardWidth div 84) else $Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/spine/backCorner">
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight - 8 - ($boardHeight * .02)"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!-- <xsl:choose>
            <xsl:when
                test="parent::location/following-sibling::formation/corners/spine[NC | NK | other]">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - ($boardHeight div 14)"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardHeight div 14)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>-->
        <xsl:choose>
            <xsl:when test="$counter eq 1">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-linejoin="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight - ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight - ($boardWidth div 16)"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ax + ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay"/>
                                <xsl:text>&#32;M</xsl:text>
                                <xsl:value-of select="$Ax + ($boardWidth div 16)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight - ($boardWidth div 16)"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <!--
                    <xsl:when test="ancestor::book/spine/profile/joints/slight">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-linejoin="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <!-\- TO DO: add uncertainty  -\->
                            <!-\- TO DO -\->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth *.97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth * .97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>-->
                    <!--<xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-linejoin="round">
                            <xsl:attribute name="class">
                                <xsl:text>line4</xsl:text>
                            </xsl:attribute>
                            <!-\- TO DO: add uncertainty  -\->
                            <!-\- TO DO -\->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth *.95"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth * .95"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight"/>
                            </xsl:attribute>
                        </path>
                    </xsl:when>-->
                    <xsl:when test="ancestor::book/spine/profile/joints/acute">
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                            stroke-linejoin="round">
                            <xsl:attribute name="class">
                                <xsl:text>line2</xsl:text>
                            </xsl:attribute>
                            <!-- TO DO: add uncertainty  -->
                            <!-- TO DO -->
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth *.97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares and ancestor-or-self::board/formation/size/squares) then $Ay + 8 else $Ay"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth * .97"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed) then $Ay + $boardHeight - 8 else $Ay + $boardHeight"
                                />
                            </xsl:attribute>
                        </path>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$counter eq 2">
                <xsl:call-template name="outerSurface_bevels">
                    <xsl:with-param name="boardThickness" select="$boardThickness"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$counter lt 2">
                <!-- Takes the outline of the inner surface and redraws it in a mirror image for the outer surface -->
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>scale(-1, 1)</xsl:text>
                        <xsl:text>&#32;translate(</xsl:text>
                        <xsl:value-of
                            select="(($Ax + 100 + $boardWidth) + ($boardWidth + $boardThickness + (2 * $delta))) * -1"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Oy"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                            <!--<xsl:call-template name="outerSurfaceFilled">
                                <xsl:with-param name="Ax" select="$Ax"/>
                                <xsl:with-param name="Ay" select="$Ay"/>
                            </xsl:call-template>-->
                        </xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="innerSurface">
                        <xsl:with-param name="boardThickness" select="$boardThickness"/>
                        <xsl:with-param name="Ax" select="$Ax"/>
                        <xsl:with-param name="Ay" select="$Ay"/>
                        <xsl:with-param name="counter" select="$counter + 1"/>
                    </xsl:call-template>
                </g>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="outerSurfaceFilled">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Ax" select="$Cx"/>
        <xsl:param name="Ay" select="($Cy + $boardThickness) + $delta"/>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round"
            fill="#F0F0F0">
            <xsl:attribute name="d">
                <xsl:text>M</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay + $boardHeight"/>
                <xsl:text>&#32;L</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares and ancestor-or-self::board/formation/size/squares">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - 8"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ax + $boardWidth - ($boardWidth div 84) else $Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - 8"/>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/spine/backCorner">
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + $boardHeight - 8 - ($boardHeight * .02)"
                                />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight - ($boardHeight * .02)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + $boardHeight"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares">
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/corners/spine/backCorner">
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $boardWidth"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Ay + 8 + ($boardHeight * .02)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/backCorner) then $Ax + $boardWidth - ($boardHeight * .02) else $Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + 8"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + 8"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 6.5)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/corners/spine/backCorner">
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay + ($boardHeight * .02)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth - ($boardWidth div 84)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Ax + $boardWidth"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Ay"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#32;L</xsl:text>
                <xsl:value-of select="$Ax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Ay"/>
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="outerSurface_bevels">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Gx" select="$Cx"/>
        <xsl:param name="Gy" select="($Cy + $boardThickness) + $delta"/>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/bevels/centreBevels">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <!-- centre -->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 3.5)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 3.5) + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - ($boardHeight div 3.5) - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardHeight div 3.5)"/>
                        <!-- head -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 3) + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 2 * ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Gx + $boardWidth - ($boardWidth div 3) - ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 2 * ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy"/>
                        <!-- tail -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 3) + ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - 2 * ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="$Gx + $boardWidth - ($boardWidth div 3) - ($boardWidth div 16)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - 2 * ($boardThickness div 3)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/claspBevels">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-- TO DO: add uncertainty  -->
                    <!-- TO DO -->
                    <xsl:attribute name="d">
                        <!--
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 8) + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 2 * ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 2 * ($boardHeight div 8) + ($boardWidth div 16)"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - 2 * ($boardHeight div 8) - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - 2 * ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 2 * ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - ($boardHeight div 8) - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardHeight div 8)"/>-->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 6)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardHeight div 6) + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + ($boardHeight div 6) + ($boardWidth div 16) + ($boardHeight div 32)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + ($boardHeight div 6) + 2 * ($boardWidth div 16) + ($boardHeight div 32)"/>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - ($boardHeight div 6) - 2 * ($boardWidth div 16) - ($boardHeight div 32)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - ($boardHeight div 6) - ($boardWidth div 16) - ($boardHeight div 32)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="$Gy + $boardHeight - ($boardHeight div 6) - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardHeight div 6)"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                <!--<mask xmlns="http://www.w3.org/2000/svg" id="fademask">
                    <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                        stroke-linejoin="round" fill="url(#fade)">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + 17 * ($boardWidth div 64)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Gx + 17 * ($boardWidth div 64)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - 17 * ($boardWidth div 64)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + 17 * ($boardWidth div 64)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - 17 * ($boardWidth div 64)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Gx + $boardWidth - 17 * ($boardWidth div 64)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Gx + 17 * ($boardWidth div 64)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Gy + $boardHeight - 17 * ($boardWidth div 64)"/>
                            <xsl:text>z</xsl:text>
                        </xsl:attribute>
                    </path>
                </mask>
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round" mask="url(#fademask)">
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 17 * ($boardWidth div 64)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Gx + 17 * ($boardWidth div 64)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - 17 * ($boardWidth div 64)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + ($boardWidth div 4)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + 17 * ($boardWidth div 64)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - 17 * ($boardWidth div 64)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth - 17 * ($boardWidth div 64)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + 17 * ($boardWidth div 64)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - ($boardWidth div 4)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Gx + ($boardWidth div 4)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Gy + $boardHeight - 17 * ($boardWidth div 64)"/>
                        <xsl:text>z</xsl:text>
                    </xsl:attribute>
                </path>-->
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="ancestor::book/spine/profile/joints/angled">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Gy + ($boardWidth div 16) else $Gy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Gx + $boardWidth * .97"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Gy + $boardHeight - ($boardWidth div 16) else $Gy + $boardHeight"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="spineEdge">
        <xsl:param name="boardThickness" select="10"/>
        <xsl:param name="Fx" select="$Cx + $boardWidth + $delta"/>
        <xsl:param name="Fy" select="($Cy + $boardThickness) + $delta"/>
        <xsl:variable name="Zx">
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | centreBevels | claspBevels]">
                    <xsl:value-of select="$Fx + $boardThickness"/>
                </xsl:when>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[cushion | peripheralCushion]">
                    <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                </xsl:when>
                <xsl:when test="parent::location/following-sibling::formation/bevels/internalBevels">
                    <xsl:value-of select="$Fx + ($boardThickness div 3)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="edgeBoardThickness">
            <xsl:value-of select="$boardThickness - (($Fx + $boardThickness) - $Zx)"/>
        </xsl:variable>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when
                    test="parent::location/following-sibling::formation/bevels[NC | NK | other]">
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels[NA | NC | NK | other | internalBevels | centreBevels | claspBevels]">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when test="parent::location/following-sibling::formation/bevels/cushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardHeight div 2)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:when>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/peripheralCushion">
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardHeight div 8)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardHeight div 8)"/>
                        <xsl:text>&#32;Q</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardHeight div 16)"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                        <!-- edge line -->
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="class">
                <xsl:text>line2</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="d">
                <xsl:choose>
                    <xsl:when
                        test="parent::location/following-sibling::formation/bevels/internalBevels">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </path>
        <xsl:choose>
            <xsl:when test="parent::location/following-sibling::formation/corners/spine/backCorner">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <!--<xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardHeight * .02)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardHeight * .02)"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of select="$Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardHeight * .02)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardHeight * .02)"/>-->
                        <xsl:text>M</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/bevels/internalBevels) then $Fx  else $Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + 8 + ($boardHeight * .04) else $Fy + ($boardHeight * .04)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if ($Fx + $boardThickness) then $Fx + $boardThickness else $Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + 8 + ($boardHeight * .04) else $Fy + ($boardHeight * .04)"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/bevels/internalBevels) then $Fx  else $Fx"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + $boardHeight - 8 - ($boardHeight * .04) else $Fy + $boardHeight - ($boardHeight * .04)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of
                            select="if ($Fx + $boardThickness) then $Fx + $boardThickness else $Fx + $edgeBoardThickness"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + $boardHeight - 8 - ($boardHeight * .04) else $Fy + $boardHeight - ($boardHeight * .04)"
                        />
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <!--
            <xsl:when test="ancestor::book/spine/profile/joints/slight">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty: NC, NK, other should have an increasingly higher degree of uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness * 2 div 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness * 2 div 3"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>-->
            <!--<xsl:when test="ancestor::book/spine/profile/joints/quadrant">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line4</xsl:text>
                    </xsl:attribute>
                    <!-\- TO DO: add uncertainty: NC, NK, other should have an increasingly higher degree of uncertainty  -\->
                    <!-\- TO DO -\->
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness * .5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness * .5"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight"/>
                    </xsl:attribute>
                </path>
            </xsl:when>-->
            <xsl:when test="ancestor::book/spine/profile/joints/acute">
                <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + 8 else $Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + $boardThickness - ($boardThickness div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + $boardHeight - 8 else $Fy + $boardHeight"
                        />
                    </xsl:attribute>
                </path>-->
            </xsl:when>
            <xsl:when test="ancestor::book/spine/profile/joints/angled">
                <!--<path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:value-of select="$Fx + ($boardThickness div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + 8 else $Fy"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:value-of select="$Fx + ($boardThickness div 8)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares) then $Fy + $boardHeight - 8 else $Fy + $boardHeight"
                        />
                    </xsl:attribute>
                </path>-->
            </xsl:when>
        </xsl:choose>
        <!-- Sewn and recessed shaping line -->
        <xsl:choose>
            <xsl:when
                test="ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed and ancestor-or-self::board/formation/size/squares">
                <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="butt"
                    stroke-linejoin="round">
                    <xsl:attribute name="class">
                        <xsl:text>line2</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:text>M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/internalBevels">
                                <xsl:value-of select="$Fx"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$Fx"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/cushion">
                                <xsl:value-of
                                    select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$Fx + $boardThickness"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + ($boardWidth div 16)"/>
                        <xsl:text>&#32;M</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/internalBevels">
                                <xsl:value-of select="$Fx"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$Fx"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardWidth div 16)"/>
                        <xsl:text>&#32;L</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="parent::location/following-sibling::formation/bevels/cushion">
                                <xsl:value-of
                                    select="$Fx + $boardThickness - ($boardThickness div 3)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$Fx + $boardThickness"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Fy + $boardHeight - ($boardWidth div 16)"/>
                    </xsl:attribute>
                </path>
            </xsl:when>
        </xsl:choose>
        <!--        <xsl:call-template name="foredge_head-tailEdge">
            <xsl:with-param name="boardThickness" select="$boardThickness"/>
            <xsl:with-param name="Dx" select="$Dx"/>
            <xsl:with-param name="Dy" select="$Dy"/>
        </xsl:call-template>-->
    </xsl:template>

    <!-- Titling -->
    <xsl:template name="title_left">
        <xsl:param name="detected" select="0"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + $boardWidth + $delta"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 20"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="$detected eq 0">
                    <xsl:text>boards not detected</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>left board</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </text>
    </xsl:template>

    <xsl:template name="title_right">
        <xsl:param name="detected" select="0"/>
        <xsl:param name="boardThickness"/>
        <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1,1)">
            <text xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="class">
                    <xsl:text>titleText</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="-($Cx + $boardWidth + $delta)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Oy + 20"/>
                </xsl:attribute>
                <xsl:value-of select="$shelfmark"/>
                <xsl:text> - </xsl:text>
                <xsl:choose>
                    <xsl:when test="$detected eq 0">
                        <xsl:text>boards not detected</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>right board</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </text>
        </g>
    </xsl:template>


    <xsl:template name="notes_left">
        <xsl:param name="boardThickness"/>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy - 1"/>
            </xsl:attribute>
            <xsl:text>head</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness +  2 * $delta + $boardHeight - 1"/>
            </xsl:attribute>
            <xsl:text>tail</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness + $delta - 1"/>
            </xsl:attribute>
            <xsl:text>inner surface</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + $boardWidth + 2 * $delta + $boardThickness + 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness + $delta - 1"/>
            </xsl:attribute>
            <xsl:text>outer surface</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx - $delta - $boardThickness - 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
            </xsl:attribute>
            <xsl:attribute name="transform">
                <xsl:text>rotate(-90, </xsl:text>
                <xsl:value-of select="$Cx - $delta - $boardThickness - 1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:text>fore-edge</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + $boardWidth + $delta - 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
            </xsl:attribute>
            <xsl:attribute name="transform">
                <xsl:text>rotate(-90, </xsl:text>
                <xsl:value-of select="$Cx + $boardWidth + $delta - 1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:text>spine</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + 2 * $boardWidth + $boardThickness + 6 * $delta - 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
            </xsl:attribute>
            <xsl:attribute name="transform">
                <xsl:text>rotate(-90, </xsl:text>
                <xsl:value-of select="$Cx + 2 * $boardWidth + $boardThickness + 6 * $delta - 1"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:text>vertical cross-section</xsl:text>
        </text>
        <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
            <xsl:attribute name="x">
                <xsl:value-of select="$Cx + $boardWidth + 2 * $delta + $boardThickness + 1"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Cy - 3* $delta - 1"/>
            </xsl:attribute>
            <xsl:text>horizontal cross-section</xsl:text>
        </text>
    </xsl:template>

    <xsl:template name="notes_right">
        <xsl:param name="boardThickness"/>
        <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1,1)">
            <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                <xsl:attribute name="x">
                    <xsl:value-of select="-($Cx + 1) - $boardWidth + 1"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy - 1"/>
                </xsl:attribute>
                <xsl:text>head</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                <xsl:attribute name="x">
                    <xsl:value-of select="-($Cx + 1) - $boardWidth + 1"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness +  2 * $delta + $boardHeight - 1"/>
                </xsl:attribute>
                <xsl:text>tail</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                <xsl:attribute name="x">
                    <xsl:value-of select="-($Cx + 1) - $boardWidth + 1"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness + $delta - 1"/>
                </xsl:attribute>
                <xsl:text>inner surface</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="-($Cx + $boardWidth + 2 * $delta + $boardThickness + 1) - $boardWidth + 1"
                    />
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness + $delta - 1"/>
                </xsl:attribute>
                <xsl:text>outer surface</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="-($Cx - $delta - $boardThickness - 1) - $boardThickness - 2"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>rotate(-90, </xsl:text>
                    <xsl:value-of
                        select="-($Cx - $delta - $boardThickness - 1) - $boardThickness - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:text>fore-edge</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
                <xsl:attribute name="x">
                    <xsl:value-of select="-($Cx + $boardWidth + $delta - 1) - $boardThickness - 2"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>rotate(-90, </xsl:text>
                    <xsl:value-of select="-($Cx + $boardWidth + $delta - 1) - $boardThickness - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:text>spine</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText3">
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="-($Cx + 2 * $boardWidth + $boardThickness + 6 * $delta - 1) - $boardThickness - 2"
                    />
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>rotate(-90, </xsl:text>
                    <xsl:value-of
                        select="-($Cx + 2 * $boardWidth + $boardThickness + 6 * $delta - 1) - $boardThickness - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Cy + $boardThickness + $delta + 1"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:text>vertical cross-section</xsl:text>
            </text>
            <text xmlns="http://www.w3.org/2000/svg" class="noteText2">
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="-($Cx + $boardWidth + 2 * $delta + $boardThickness + 1) - $boardWidth + 1"
                    />
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$Cy - 3* $delta - 1"/>
                </xsl:attribute>
                <xsl:text>horizontal cross-section</xsl:text>
            </text>
        </g>
    </xsl:template>

    <!-- Description -->
    <xsl:template name="description_left">
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>descText</xsl:text>
            </xsl:attribute>
            <text xmlns="http://www.w3.org/2000/svg" x="{$Cx}" y="{$Oy + 40}">
                <tspan xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Edge treatment: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Cx + 55}">
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/edgeTreatment/other) then concat(parent::location/following-sibling::formation/edgeTreatment/node()[2]/name(), ': ', parent::location/following-sibling::formation/edgeTreatment/other/text()) else parent::location/following-sibling::formation/edgeTreatment//node()[2]/name()"
                        />
                    </tspan>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Cx}">
                    <xsl:text>Bevels: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Cx + 55}">
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/bevels/other) then concat(parent::location/following-sibling::formation/bevels/node()[2]/name(), ': ', parent::location/following-sibling::formation/bevels/other/text()) else parent::location/following-sibling::formation/bevels/node()[2]/name()"
                        />
                    </tspan>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Cx}">
                    <xsl:text>Corners: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Cx + 55}">
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/foredge/other) then concat(parent::location/following-sibling::formation/corners/foredge/node()[2]/name(), ': ', parent::location/following-sibling::formation/corners/foredge/other/text()) else parent::location/following-sibling::formation/corners/foredge/node()[2]/name()"/>
                        <xsl:text> (foredge), </xsl:text>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg">
                        <xsl:value-of
                            select="if (parent::location/following-sibling::formation/corners/spine/other) then concat(parent::location/following-sibling::formation/corners/spine/node()[2]/name(), ': ', parent::location/following-sibling::formation/corners/spine/other/text()) else parent::location/following-sibling::formation/corners/spine/node()[2]/name()"/>
                        <xsl:text> (spine)</xsl:text>
                    </tspan>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Cx}">
                    <xsl:text>Joint shape: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Cx + 55}">
                        <xsl:value-of
                            select="if (ancestor::book/spine/profile/joints[angled | quadrant | acute]) then ancestor::book/spine/profile/joints/node()[2]/name() else 'square'"
                        />
                    </tspan>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Cx}">
                    <xsl:text>Endband recess: </xsl:text>
                    <tspan xmlns="http://www.w3.org/2000/svg" x="{$Cx + 55}">
                        <xsl:value-of
                            select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares) then 'yes' else 'no'"
                        />
                    </tspan>
                </tspan>
            </text>
        </g>
    </xsl:template>

    <xsl:template name="description_right">
        <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1,1)">
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="class">
                    <xsl:text>descText</xsl:text>
                </xsl:attribute>
                <text xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1}" y="{$Oy + 40}">
                    <tspan xmlns="http://www.w3.org/2000/svg">
                        <xsl:text>Edge treatment: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1 + 55}">
                            <xsl:value-of
                                select="if (parent::location/following-sibling::formation/edgeTreatment/other) then concat(parent::location/following-sibling::formation/edgeTreatment/node()[2]/name(), ': ', parent::location/following-sibling::formation/edgeTreatment/other/text()) else parent::location/following-sibling::formation/edgeTreatment//node()[2]/name()"
                            />
                        </tspan>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{-($Cx + 1) - $boardWidth + 1}">
                        <xsl:text>Bevels: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1 + 55}">
                            <xsl:value-of
                                select="if (parent::location/following-sibling::formation/bevels/other) then concat(parent::location/following-sibling::formation/bevels/node()[2]/name(), ': ', parent::location/following-sibling::formation/bevels/other/text()) else parent::location/following-sibling::formation/bevels/node()[2]/name()"
                            />
                        </tspan>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{-($Cx + 1) - $boardWidth + 1}">
                        <xsl:text>Corners: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1 + 55}">
                            <xsl:value-of
                                select="if (parent::location/following-sibling::formation/corners/foredge/other) then concat(parent::location/following-sibling::formation/corners/foredge/node()[2]/name(), ': ', parent::location/following-sibling::formation/corners/foredge/other/text()) else parent::location/following-sibling::formation/corners/foredge/node()[2]/name()"/>
                            <xsl:text> (foredge), </xsl:text>
                        </tspan>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:value-of
                                select="if (parent::location/following-sibling::formation/corners/spine/other) then concat(parent::location/following-sibling::formation/corners/spine/node()[2]/name(), ': ', parent::location/following-sibling::formation/corners/spine/other/text()) else parent::location/following-sibling::formation/corners/spine/node()[2]/name()"/>
                            <xsl:text> (spine)</xsl:text>
                        </tspan>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{-($Cx + 1) - $boardWidth + 1}">
                        <xsl:text>Joint shape: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1 + 55}">
                            <xsl:value-of
                                select="if (ancestor::book/spine/profile/joints[angled | acute]) then ancestor::book/spine/profile/joints/node()[2]/name() else 'square'"
                            />
                        </tspan>
                    </tspan>
                    <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{-($Cx + 1) - $boardWidth + 1}">
                        <xsl:text>Endband recess: </xsl:text>
                        <tspan xmlns="http://www.w3.org/2000/svg" x="{-($Cx + 1) - $boardWidth + 1 + 55}">
                            <xsl:value-of
                                select="if (ancestor::book/endbands/yes/endband/cores/yes/cores/type/core/boardAttachment/yes/attachment/sewnAndRecessed  and ancestor-or-self::board/formation/size/squares) then 'yes' else 'no'"
                            />
                        </tspan>
                    </tspan>
                </text>
            </g>
        </g>
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
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
