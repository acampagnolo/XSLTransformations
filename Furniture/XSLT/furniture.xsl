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
    <xsl:variable name="filename"
        select="concat('../../Transformations/Furniture/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'furniture', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <xsl:param name="Oy" select="0"/>

    <!-- Gap between furniture frames -->
    <xsl:variable name="gap">
        <xsl:value-of select="20"/>
    </xsl:variable>

    <!-- Frame dimension -->
    <xsl:variable name="frameDimension">
        <xsl:value-of select="150"/>
    </xsl:variable>

    <xsl:template name="main" match="/">
        <xsl:result-document href="{$filename}" method="xml" indent="yes" encoding="utf-8"
            doctype-public="-//W3C//DTD SVG 1.1//EN"
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
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.1" x="0" y="0" width="1189mm" height="841mm" viewBox="0 0 1189 841"
                preserveAspectRatio="xMidYMid meet">
                <title>Furniture of book: <xsl:value-of select="$shelfmark"/></title>
                <xsl:copy-of
                    select="document('../SVGmaster/spineLiningSVGmaster.svg')/svg:svg/svg:defs"
                    xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                <desc xmlns="http://www.w3.org/2000/svg">Furniture of book: <xsl:value-of
                        select="$shelfmark"/></desc>
                <svg>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </svg>
            </svg>
        </xsl:result-document>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <!-- Template that calls the spine arc pipeline of templates for both halves of the bookblock and the lining -->
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
                <!--                <xsl:variable name="totalFurnitureTypes">
                    <xsl:value-of select="count(./yes/furniture)"/>
                </xsl:variable>-->
                <xsl:for-each select="yes/furniture">
                    <xsl:variable name="P_coordinates">
                        <xsl:choose>
                            <xsl:when test="position() eq 1 or position() eq 5 or position() eq 9">
                                <my:Px>
                                    <xsl:value-of select="$Ox + $gap"/>
                                </my:Px>
                            </xsl:when>
                            <xsl:when test="position() eq 2 or position() eq 6 or position() eq 10">
                                <my:Px>
                                    <xsl:value-of select="($Ox + $gap) + $gap + $frameDimension"/>
                                </my:Px>
                            </xsl:when>
                            <xsl:when test="position() eq 3 or position() eq 7 or position() eq 11">
                                <my:Px>
                                    <xsl:value-of
                                        select="($Ox + $gap) + ($gap + $frameDimension) * 2"/>
                                </my:Px>
                            </xsl:when>
                            <xsl:when test="position() eq 4 or position() eq 8 or position() eq 12">
                                <my:Px>
                                    <xsl:value-of
                                        select="($Ox + $gap) + ($gap + $frameDimension) * 3"/>
                                </my:Px>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when
                                test="position() eq 1 or position() eq 2 or position() eq 3 or position() eq 4">
                                <my:Py>
                                    <xsl:value-of select="$Oy + $gap"/>
                                </my:Py>
                            </xsl:when>
                            <xsl:when
                                test="position() eq 5 or position() eq 6 or position() eq 7 or position() eq 8">
                                <my:Py>
                                    <xsl:value-of select="($Oy + $gap) + $gap + $frameDimension"/>
                                </my:Py>
                            </xsl:when>
                            <xsl:when
                                test="position() eq 9 or position() eq 10 or position() eq 11 or position() eq 12">
                                <my:Py>
                                    <xsl:value-of
                                        select="($Oy + $gap) + ($gap + $frameDimension) * 2"/>
                                </my:Py>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="x" select="$P_coordinates/my:Px"/>
                        <xsl:attribute name="y" select="$P_coordinates/my:Py"/>
                        <!-- Framework to visualize positioning of various types of furniture present: do not visualize in the final version -->
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="class">
                                <xsl:text>line</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Px"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Py"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Px + $frameDimension"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Py"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Px + $frameDimension"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Py + $frameDimension"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Px"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$P_coordinates/my:Py + $frameDimension"/>
                                <xsl:text>&#32;z</xsl:text>
                            </xsl:attribute>
                        </path>
                        <!-- call furniture template -->
                        <xsl:call-template name="types">
                            <xsl:with-param name="P_coordinates" select="$P_coordinates"/>
                        </xsl:call-template>
                    </g>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="types">
        <xsl:param name="P_coordinates"/>
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
        <xsl:choose>
            <xsl:when test="type/NC">
                <!-- It makes little sense to draw something here just for the sake of it. 
                        Add a note that furniture was detected but the type was not recorded -->                
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Furniture was detected but the type was not recorded</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="type/clasp">
                <xsl:call-template name="claps">
                    <xsl:with-param name="P_coordinates" select="$P_coordinates"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="type/catchplate">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/pin">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/bosses">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/corners">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/plates">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/fullCover">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/straps">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/strapPlates">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/strapCollars">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/ties">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/articulatedMetalSpines">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="claps">
        <xsl:param name="P_coordinates"/>
        <xsl:choose>
            <xsl:when test="type/clasp/type/stirrupRing">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/clasp/type/simpleHook">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/clasp/type/foldedHook">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/clasp/type/piercedStrap">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/clasp/type[NC | NK]">
                <!--  -->
            </xsl:when>
            <xsl:when test="type/clasp/type/other">
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
