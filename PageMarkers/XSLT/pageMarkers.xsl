<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs svg xlink lig xsi" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenamePath"
        select="concat('../../Transformations/PageMarkers/SVGoutput/', $fileref[1], '_', 'PageMarkers')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <xsl:variable name="Ax" select="$Ox + 40"/>
    <xsl:variable name="Ay" select="$Oy + 50"/>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/markers/yes/marker/pageMarker">
            <xsl:result-document href="{if (last() = 1) then concat($filenamePath, '.svg') else concat($filenamePath, '_',position(), '.svg')}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../GitHub/XSLTransformations/PageMarkers/CSS/style.css"&#32;</xsl:text>
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
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                    version="1.1" x="0" y="0" width="297mm" height="210mm" viewBox="0 0 297 210"
                    preserveAspectRatio="xMidYMid meet">
                    <title>Page Markers: <xsl:value-of select="$shelfmark"/></title>
                    <!-- The following copies the definitions from the Master SVG file for sewing paths -->
                    <xsl:copy-of
                        select="document('../SVGmaster/pageMarkersSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">Page Markers</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="type"/>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- Template to mute all unwanted nodes -->
    <xsl:template match="text()"/>

    <xsl:template match="book/markers/yes/marker/pageMarker/type">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Page marker type: </xsl:text>
            <xsl:value-of
                select="if (other) then concat(child::node()[2]/name(), ': ', other/child::text()) else child::node()[2]/name()"
            />
        </desc>
        <xsl:choose>
            <xsl:when test="NC">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Page marker type not checked</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="NK">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Page marker type not known</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="other">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Page marker type not covered by schema yet</xsl:text>
                </desc>
            </xsl:when>
        </xsl:choose>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Page marker attachment: </xsl:text>
            <xsl:value-of
                select="if (following-sibling::attachment/other) then concat(following-sibling::attachment/child::node()[2]/name(), ': ', following-sibling::attachment/other/child::text()) else following-sibling::attachment/child::node()[2]/name()"
            />
        </desc>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Page marker material: </xsl:text>
            <xsl:value-of
                select="if (following-sibling::material/other) then concat(following-sibling::material/child::node()[2]/name(), ': ', following-sibling::material/other/child::text()) else following-sibling::material/child::node()[2]/name()"
            />
        </desc>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Page marker's set location(s): </xsl:text>
            <xsl:for-each select="following-sibling::locations/locationSet">
                <xsl:value-of
                    select="if (other) then concat(child::node()[2]/name(), ': ', other/child::text()) else child::node()[2]/name()"
                />
            </xsl:for-each>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#pageProfile</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 20"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 52.5"/>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="NC">
                    <!-- Draw the most probable type with high degree of uncertainty? -->
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#folded</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="folded">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#folded</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="foldedAndKnotted">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#foldedKnotted</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="straight">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#straight</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="NK">
                    <!-- Typology problem described -->
                </xsl:when>
                <xsl:when test="other">
                    <!-- Typology problem described -->
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Ay"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:call-template name="attachment"/>
        <xsl:call-template name="locationSet"/>
    </xsl:template>

    <xsl:template name="attachment">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Attachment type: </xsl:text>
            <xsl:value-of select="following-sibling::attachment/child::node()[2]/name()"/>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="following-sibling::attachment/NC">
                    <!-- Draw the most probable type with high degree of uncertainty? -->
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#gluedAttachment</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="straight">
                            <xsl:attribute name="clip-path">
                                <xsl:text>url(#singleSided)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="following-sibling::attachment/adhesive">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#gluedAttachment</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="straight">
                            <xsl:attribute name="clip-path">
                                <xsl:text>url(#singleSided)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="following-sibling::attachment/sewn">
                    <xsl:choose>
                        <xsl:when test="straight">
                            <xsl:attribute name="xlink:href">
                                <xsl:text>#sewnAttachment2</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="xlink:href">
                                <xsl:text>#sewnAttachment</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="following-sibling::attachment/NK">
                    <!-- Typology problem described -->
                </xsl:when>
                <xsl:when test="following-sibling::attachment/other">
                    <!-- Typology problem described -->
                </xsl:when>
            </xsl:choose>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Ay"/>
            </xsl:attribute>
        </use>
    </xsl:template>

    <xsl:template name="locationSet">
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#pageOutline</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax + 70"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Ay"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>line</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:for-each select="following-sibling::locations/locationSet">
            <xsl:variable name="Bx">
                <xsl:value-of select="($Ax + 160) - (21 * position())"/>
            </xsl:variable>
            <xsl:variable name="By">
                <xsl:value-of
                    select="if (head | foredge | NC) then $Ay + (21 * position()) else ($Ay + 120) - (21 * position())"
                />
            </xsl:variable>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:variable name="diagramSelection">
                    <xsl:choose>
                        <xsl:when test="../preceding-sibling::type[folded | straight]">
                            <xsl:text>#foldedStraight_above</xsl:text>
                        </xsl:when>
                        <xsl:when test="../preceding-sibling::type/foldedAndKnotted">
                            <xsl:text>#foldedKnotted_above</xsl:text>
                        </xsl:when>
                        <xsl:when test="../preceding-sibling::type/NC">
                            <xsl:text>#foldedStraight_above</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="../preceding-sibling::type/NC">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="50"/>
                            <xsl:with-param name="type" select="'3'"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="NC">
                        <!-- Draw the most probable type with high degree of uncertainty? -->
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$diagramSelection"/>
                        </xsl:attribute>
                        <!-- Increase uncertainty -->
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="50"/>
                            <xsl:with-param name="type" select="'3'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="head">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="concat($diagramSelection, '-90')"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="foredge">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$diagramSelection"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="tail">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="concat($diagramSelection, '90')"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="NK">
                        <!-- Typology problem described -->
                    </xsl:when>
                    <xsl:when test="other">
                        <!-- Typology problem described -->
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Bx"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$By"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>above</xsl:text>
                </xsl:attribute>
            </use>
            <xsl:call-template name="numberOfTabs">
                <xsl:with-param name="Bx" select="$Bx"/>
                <xsl:with-param name="By" select="$By"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="numberOfTabs">
        <xsl:param name="Bx" select="1"/>
        <xsl:param name="By" select="1"/>
        <xsl:variable name="Tx" select="($Ax + 160) - (21 * position()) + 6"/>
        <xsl:variable name="Ty">
            <xsl:choose>
                <xsl:when test="foredge | NC">
                    <xsl:value-of select="$Ay + (21 * position()) + 6"/>
                </xsl:when>
                <xsl:when test="head">
                    <xsl:value-of select="$Ay + (21 * position()) - 8"/>
                </xsl:when>
                <xsl:when test="tail">
                    <xsl:value-of select="($Ay + 120) - (21 * position()) + 8"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="x" select="$Tx"/>
            <xsl:attribute name="y" select="$Ty"/>
            <xsl:attribute name="text-anchor">
                <xsl:text>middle</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="dominant-baseline">
                <xsl:text>central</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="font-family">
                <xsl:text>serif</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="font-size">
                <xsl:text>8pt</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="child::node()/text()"/>
        </text>
    </xsl:template>

    <xsl:template name="certainty">
        <xsl:param name="certainty" select="100"/>
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
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
