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
        select="concat('../../Transformations/BoardMarkers/SVGoutput/', $fileref[1], '_', 'BoardMarkers')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <xsl:variable name="Bx" select="$Ox + 50"/>
    <xsl:variable name="By" select="$Oy + 50"/>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/markers/yes/marker/boardMarker">
            <xsl:result-document
                href="{if (last() = 1) then concat($filenamePath, '.svg') else concat($filenamePath, '_',position(), '.svg')}"
                method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../GitHub/XSLTransformations/BoardMarkers/CSS/style.css"&#32;</xsl:text>
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
                    <title>Board Markers: <xsl:value-of select="$shelfmark"/></title>
                    <!-- The following copies the definitions from the Master SVG file for sewing paths -->
                    <xsl:copy-of
                        select="document('../SVGmaster/boardMarkersSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">Board Markers</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Board marker location: </xsl:text>
                            <xsl:value-of
                                select="if (location/other) then concat(location/node()[2]/name(), ': ', location/other/child::text()) else location/node()[2]/name()"
                            />
                        </desc>
                        <xsl:choose>
                            <xsl:when test="location/NC">
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>Board marker location not checked</xsl:text>
                                </desc>
                            </xsl:when>
                            <xsl:when test="location/NK">
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>Board marker location not known</xsl:text>
                                </desc>
                            </xsl:when>
                            <xsl:when test="location/other">
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>Board marker location not covered by schema yet</xsl:text>
                                </desc>
                            </xsl:when>
                        </xsl:choose>
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Board marker attachment: </xsl:text>
                            <xsl:value-of
                                select="if (attachment/other) then concat(attachment/child::node()[2]/name(), ': ', attachment/other/child::text()) else attachment/child::node()[2]/name()"
                            />
                        </desc>
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Board marker material: </xsl:text>
                            <xsl:value-of
                                select="if (material/other) then concat(material/child::node()[2]/name(), ': ', material/other/child::text()) else material/child::node()[2]/name()"
                            />
                        </desc>
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Board marker attachment position: </xsl:text>
                            <xsl:value-of
                                select="if (attachmentPosition/other) then concat(attachmentPosition/child::node()[2]/name(), ': ', attachmentPosition/other/child::text()) else attachmentPosition/child::node()[2]/name()"
                            />
                        </desc>
                        <xsl:call-template name="location"/>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="location">
        <xsl:choose>
            <xsl:when test="location[NC | NK]">
                <!-- Draw the most probable location (right foredge?) with a degree of uncertainty? -->
                <!-- Location problem described -->
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0, 20)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="crossSection">
                        <xsl:with-param name="certainty" select="50"/>
                    </xsl:call-template>
                </g>
                <xsl:call-template name="above">
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="location/foredgeRight">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(0, 20)</xsl:text>
                    </xsl:attribute>
                <xsl:call-template name="crossSection"/>
                </g>
                <xsl:call-template name="above"/>
            </xsl:when>
            <xsl:when test="location/foredgeLeft">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(-50, -50) scale(-1, 1) translate(-250, 70)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="crossSection"/>
                </g>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(-200, -50)  scale(-1, 1) translate(-650, 50)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="above"/>
                </g>
            </xsl:when>
            <xsl:when test="location/other">
                <!-- Location problem described -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="crossSection">
        <xsl:param name="certainty"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#boardProfile</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$By"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="attachmentPosition/overTurnin">
                <xsl:call-template name="overTurnin"/>
                <xsl:call-template name="attachment">
                    <xsl:with-param name="Gy" select="$By - 4"/>
                    <xsl:with-param name="Ny" select="$By - 6.5"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachmentPosition/underTurnin">
                <xsl:call-template name="underTurnin"/>                
                <xsl:call-template name="attachment">
                    <xsl:with-param name="Gy" select="$By - 2"/>
                    <xsl:with-param name="Ny" select="$By - 4.5"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachmentPosition[NC | NK]">
                <!-- select the most probable diagram (over Turn-in?) with a degree of uncertainty -->
                <xsl:call-template name="overTurnin">
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
                <xsl:call-template name="attachment">
                    <xsl:with-param name="Gy" select="$By - 4"/>
                    <xsl:with-param name="Ny" select="$By - 6.5"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachmentPosition/other">
                <!-- Attachment position problem described -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="underTurnin">
        <xsl:param name="certainty" select="100"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#turnin</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Bx + 10"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$By - 6"/>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#boardMarker</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Bx + 20"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$By - 4"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>
        </g>
    </xsl:template>
    
    <xsl:template name="overTurnin">
        <xsl:param name="certainty" select="100"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#turnin</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Bx + 10"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$By + 10"/>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>scale(1, 0.8)</xsl:text>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:text>#boardMarker</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Bx + 20"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$By - 6"/>
                </xsl:attribute>
            </use>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>
        </g>    
    </xsl:template>
    
    <xsl:template name="attachment">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="Gy" select="$By - 4"/>
        <xsl:param name="Ny" select="$By - 6.5"/>
        <xsl:choose>
            <xsl:when test="attachment/NC">
                <!-- select the most probable mean of attachment (nailed?) with a degree of uncertainty-->
                <xsl:call-template name="nailed">
                    <xsl:with-param name="Ny" select="$Ny"/>
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachment/nailed">
                <xsl:call-template name="nailed">
                    <xsl:with-param name="Ny" select="$Ny"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachment/glued">
                <xsl:call-template name="glued">
                    <xsl:with-param name="Gy" select="$Gy"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachment/other">
                <!-- say something -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="nailed">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="Ny" select="$By - 6.5"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#nail</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx + 33"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Ny"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>
        </use>
    </xsl:template>
    
    <xsl:template name="glued">
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="Gy" select="$By - 4"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#gluedAttachment</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx + 20"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Gy"/>
            </xsl:attribute>
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'3'"/>
            </xsl:call-template>
        </use>
    </xsl:template>

    <xsl:template name="above">
        <xsl:param name="certainty" select="100"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#boardOutline</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx + 150"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$By"/>
            </xsl:attribute>
        </use>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="attachmentPosition/overTurnin">
                    <xsl:attribute name="fill-opacity">
                        <xsl:value-of select="1"/>
                    </xsl:attribute>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#boardMarker_above</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Bx + 175"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$By + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate (-45, 225, 70)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="attachment_above"/>
                </xsl:when>
                <xsl:when test="attachmentPosition/underTurnin">
                    <xsl:attribute name="fill-opacity">
                        <xsl:value-of select="0"/>
                    </xsl:attribute>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#boardMarker_above</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Bx + 175"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$By + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate (-45, 225, 70)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="attachment_above"/>
                    <xsl:call-template name="turninOpacity"/>
                </xsl:when>
                <xsl:when test="attachmentPosition[NC | NK]">
                    <xsl:attribute name="fill-opacity">
                        <xsl:value-of select="0.8"/>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" select="50"/>
                        <xsl:with-param name="type" select="'3'"/>
                    </xsl:call-template>
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#boardMarker_above</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Bx + 175"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$By + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="transform">
                            <xsl:text>rotate (-45, 225, 70)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <xsl:call-template name="attachment_above"/>
                </xsl:when>
            </xsl:choose>
        </g>
    </xsl:template>

    <xsl:template name="attachment_above">
        <xsl:param name="certainty" select="100"/>
        <xsl:choose>
            <xsl:when test="attachment/NC">
                <!-- select the most probable mean of attachment (nailed?) with a degree of uncertainty-->
                <xsl:call-template name="nailed_above">
                    <xsl:with-param name="certainty" select="50"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="attachment/nailed">
                <xsl:call-template name="nailed_above"/>
            </xsl:when>
            <xsl:when test="attachment/glued">
                <!-- No need to add anything to the diagram -->
            </xsl:when>
            <xsl:when test="attachment/other">
                <!-- say something -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="nailed_above">
        <xsl:param name="certainty" select="100"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#nail_above</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx + 185"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$By + 10"/>
            </xsl:attribute>
        </use>
    </xsl:template>
    
    <xsl:template name="turninOpacity">
        <xsl:param name="certainty" select="100"/>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#turninOpacity</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Bx + 170"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$By + 1"/>
            </xsl:attribute>
        </use>
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
