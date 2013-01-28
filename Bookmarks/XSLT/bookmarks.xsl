<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs svg xlink lig xsi" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"/>

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize(replace($shelfmark, '/', '.'), '\.')"/>
    <xsl:variable name="filenamePath"
        select="concat('../../Transformations/Sewing/SVGoutput/', $fileref[1], '/', $fileref[1], '_', 'Bookmarks')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>
    
    <!-- TO DO -->
    <!-- NB: It might be a good idea to have the the X and Y values of  various parts of the bookmarks depend on the position of the drawn endbands and not on the absolute Ox and Oy values; this way each view could be moved around without loosing its integrity -->
    <!-- TO DO-->

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/markers/yes/marker/bookmark">
            <xsl:result-document
                href="{if (last() = 1) then concat($filenamePath, '.svg') else concat($filenamePath, '_',position(), '.svg')}"
                method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../../GitHub/XSLTransformations/Bookmarks/CSS/style.css"&#32;</xsl:text>
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
                    <title>Boookmarks: <xsl:value-of select="$shelfmark"/></title>
                    <!-- The following copies the definitions from the Master SVG file for sewing paths -->
                    <xsl:copy-of
                        select="document('../SVGmaster/bookmarksSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">Bookmarks</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <desc xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Bookmark type: </xsl:text>
                            <xsl:value-of
                                select="if (./other) then concat(./node()[2]/name(), ': ', ./other/child::text()) else ./node()[2]/name()"
                            />
                        </desc>
                        <xsl:choose>
                            <xsl:when test=".[simple | compound | loose]">
                                <desc xmlns="http://www.w3.org/2000/svg">
                                    <xsl:text>Bookmark material: </xsl:text>
                                    <xsl:value-of
                                        select="if (./node()/material/other) then concat(./node()/material/child::node()[2]/name(), ': ', ./node()/material/other/child::text()) else ./node()/material/child::node()[2]/name()"
                                    />
                                </desc>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:call-template name="type"/>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="type">
        <xsl:choose>
            <xsl:when test="./NC">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Bookmark type not checked</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="./NK">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Bookmark type not known</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="./other">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Bookmark type not covered by schema yet</xsl:text>
                </desc>
            </xsl:when>
            <xsl:when test="./loose">
                <xsl:text>'Loose' bookmark, not enough information is given for a meaningful diagram</xsl:text>
            </xsl:when>
            <xsl:when test="./simple">
                <xsl:text>'Simple' bookmark, not enough information is given for a meaningful diagram</xsl:text>
            </xsl:when>
            <xsl:when test="./compound">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Compound bookmark primary type: </xsl:text>
                    <xsl:value-of
                        select="if (./compound/primaryType/other) then concat(./compound/primaryType/node()[2]/name(), ': ', ./compound/primaryType/other/text()) else ./compound/primaryType/node()[2]/name()"
                    />
                </desc>
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Compound bookmark primary attachment type: </xsl:text>
                    <xsl:value-of
                        select="if (./compound/primaryAttachment/type/other) then concat(./compound/primaryAttachment/type/node()[2]/name(), ': ', ./compound/primaryAttachment/type/other/text()) else ./compound/primaryAttachment/type/node()[2]/name()"
                    />
                </desc>
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Compound bookmark primary attachment decoration: </xsl:text>
                    <xsl:value-of
                        select="if (./compound/primaryAttachment/decoration/other) then concat(./compound/primaryAttachment/decoration/node()[2]/name(), ': ', ./compound/primaryAttachment/decoration/other/text()) else ./compound/primaryAttachment/decoration/node()[2]/name()"
                    />
                </desc>
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Compound bookmark secondary type: </xsl:text>
                    <xsl:value-of
                        select="if (./compound/secondaryType/other) then concat(./compound/secondaryType/node()[2]/name(), ': ', ./compound/secondaryType/other/text()) else ./compound/secondaryType/node()[2]/name()"
                    />
                </desc>
                <xsl:call-template name="endbandDiagrams"/>
                <xsl:call-template name="prymaryTypeXYvalues"/>
                <xsl:call-template name="primaryAttachmentXYvalues"/>
                <!--<xsl:call-template name="primaryAttachmentDecoration"/>-->
                <xsl:call-template name="secondaryTypeXYvalues"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="endbandDiagrams">
        <xsl:variable name="endband_numberOfCores">
            <xsl:value-of
                select="ancestor::book/endbands[yes]/descendant::endband[location/head]/cores/yes/numberOfCores/text()"
            />
        </xsl:variable>
        <xsl:variable name="primaryCores">
            <xsl:value-of
                select="count(ancestor::book/endbands[yes]/descendant::endband[location/head]/cores/yes/cores/type[core])"
            />
        </xsl:variable>
        <xsl:variable name="crowningCores">
            <xsl:value-of
                select="count(ancestor::book/endbands[yes]/descendant::endband[location/head]/cores/yes/cores/type[crowningCore])"
            />
        </xsl:variable>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>The </xsl:text>
            <xsl:value-of select=".[not(NC | NK | loose | other)]/node()[2]/name()"/>
            <xsl:text> bookmark is attached to an endband formed of </xsl:text>
            <xsl:value-of select="$endband_numberOfCores"/>
            <xsl:text> core</xsl:text>
            <xsl:if test="xs:integer($endband_numberOfCores) gt 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$primaryCores"/>
            <xsl:text> primary core</xsl:text>
            <xsl:if test="xs:integer($primaryCores) gt 1 or xs:integer($primaryCores) eq 0">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text> and </xsl:text>
            <xsl:value-of select="$crowningCores"/>
            <xsl:text> crowning core</xsl:text>
            <xsl:if test="xs:integer($crowningCores) gt 1 or xs:integer($crowningCores) eq 0">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </desc>
        <use xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="xlink:href">
                <xsl:text>#textblock</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 15"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="if (./compound/primaryType/span2) then $Oy + 59 else $Oy + 61"/>
            </xsl:attribute>
        </use>
        <xsl:choose>
            <xsl:when test="xs:integer($primaryCores) gt 1">
                <!-- TO DO -->
                <!-- NB: how to draw this? -->
                <!-- TO DO -->
                <!-- For the moment drawing just one as below just to have something. Come back to this after having done the endband transformation -->
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 50"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 50"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 43"/>
                    </xsl:attribute>
                </use>
                <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1, 1) translate(-400, 0)">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#endbandCore_front</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 130"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy + 43"/>
                        </xsl:attribute>
                    </use>
                </g>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 103"/>
                    </xsl:attribute>
                </use>
                <!-- Modify the above USE to reflect more complex endbands if needed -->
            </xsl:when>
            <xsl:when test="xs:integer($primaryCores) eq 1">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 50"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 50"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 43"/>
                    </xsl:attribute>
                </use>
                <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1, 1) translate(-400, 0)">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#endbandCore_front</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 130"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy + 43"/>
                        </xsl:attribute>
                    </use>
                </g>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 103"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="xs:integer($crowningCores) gt 1">
                <!-- TO DO -->
                <!-- NB: how to draw this? -->
                <!-- TO DO -->
                <!-- For the moment drawing just one as below just to have something. Come back to this after having done the endband transformation -->
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 48"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="if (./compound/primaryType/span2) then $Oy + 39 else $Oy + 40"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 38"/>
                    </xsl:attribute>
                </use>
                <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1, 1) translate(-400, 0)">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#endbandCore_front</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 130"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy + 38"/>
                        </xsl:attribute>
                    </use>
                </g>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 85"/>
                    </xsl:attribute>
                </use>
                <!-- Modify the above USE to reflect more complex endbands if needed -->
            </xsl:when>
            <xsl:when test="xs:integer($crowningCores) eq 1">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 48"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="if (./compound/primaryType/span2) then $Oy + 39 else $Oy + 40"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 38"/>
                    </xsl:attribute>
                </use>
                <g xmlns="http://www.w3.org/2000/svg" transform="scale(-1, 1) translate(-400, 0)">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#endbandCore_front</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 130"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy + 38"/>
                        </xsl:attribute>
                    </use>
                </g>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:text>#endbandCore_front</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 100"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$Oy + 85"/>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="prymaryTypeXYvalues">
        <!-- Need two variables for the values of X and Y in the <use> element that vary accordingly to the primaryType; Need a couple of values for each view: cross-section, front, back, above-->
        <!-- NB: some secondary types might need further modifications from the standard X and Y values for their respective primary type, but these might be adjusted inside the X/Y selection xPath or with a <xsl:choose> -->
        <xsl:variable name="x">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Ox + 47"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Ox + 46"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_front">
            <xsl:choose>
                <xsl:when
                    test="./compound/primaryType[twistedSpan | closedLoop | twistedClosedLoop | NC | NK]">
                    <xsl:value-of select="$Ox + 140"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Ox + 130"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_above">
            <xsl:choose>
                <xsl:when
                    test="./compound/primaryType[twistedSpan | closedLoop | twistedClosedLoop | NC | NK]">
                    <xsl:value-of select="$Ox + 140"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Ox + 130"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 42"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Oy + 59"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_front">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 42"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Oy + 57"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_above">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 110"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Oy + 117"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="primaryType">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="x_front" select="$x_front"/>
            <xsl:with-param name="y_front" select="$y_front"/>
            <xsl:with-param name="x_above" select="$x_above"/>
            <xsl:with-param name="y_above" select="$y_above"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="primaryType">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="x_front"/>
        <xsl:param name="y_front"/>
        <xsl:param name="x_above"/>
        <xsl:param name="y_above"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/NC">
                    <xsl:text>Primary bookmark type not checked.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/primaryType/NK">
                    <xsl:text>Primary bookmark type not known.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/primaryType/other">
                    <xsl:text>Primary bookmark type not covered by schema yet. Description notes: </xsl:text>
                    <xsl:value-of select="./compound/primaryType/other/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Primary bookmark type: </xsl:text>
                    <xsl:value-of select="./compound/primaryType/node()[2]/name()"/>
                </xsl:otherwise>
            </xsl:choose>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty"
                    select="if (./compound/primaryType[ NC | NK]) then xs:integer(50) else xs:integer(100)"
                />
                <xsl:with-param name="type" select="'1'"/>
            </xsl:call-template>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="./compound/material[NC | cord | thread | NK | other]">
                        <xsl:text>line</xsl:text>
                    </xsl:when>
                    <xsl:when test="./compound/material[textile | ribbon]">
                        <xsl:text>line7</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when
                            test="./compound/primaryType[NC | NK | span1 | span2 | multipleSpan | closedLoop]">
                            <xsl:text>#type1</xsl:text>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[twistedSpan | twistedClosedLoop]">
                            <xsl:value-of
                                select="concat('#', ./compound/primaryType/node()[2]/name())"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryType[span1 | span2 | multipleSpan]">
                            <xsl:text>#span_front</xsl:text>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[NC | NK]">
                            <xsl:text>#closedLoop_front</xsl:text>
                        </xsl:when>
                        <xsl:when
                            test="./compound/primaryType[twistedSpan | twistedClosedLoop | closedLoop]">
                            <xsl:value-of
                                select="concat('#', ./compound/primaryType/node()[2]/name(), '_front')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="if (./compound/primaryType/multipleSpan) then $x_front - 20 else $x_front"
                    />
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_front"/>
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="./compound/primaryType/multipleSpan">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#span_front</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x_front + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y_front"/>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryType[span1 | span2 | multipleSpan]">
                            <xsl:text>#span_above</xsl:text>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[NC | NK]">
                            <xsl:text>#closedLoop_above</xsl:text>
                        </xsl:when>
                        <xsl:when
                            test="./compound/primaryType[twistedSpan | twistedClosedLoop | closedLoop]">
                            <xsl:value-of
                                select="concat('#', ./compound/primaryType/node()[2]/name(), '_above')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of
                        select="if (./compound/primaryType/multipleSpan) then $x_above - 20 else $x_above"
                    />
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_above"/>
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="./compound/primaryType/multipleSpan">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:text>#span_above</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x_above + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y_above"/>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
        </g>
    </xsl:template>

    <xsl:template name="primaryAttachmentXYvalues">
        <xsl:param name="certainty" select="100"/>
        <!-- Need two variables for the values of X and Y in the <use> element that vary accordingly to the primaryType; Need a couple of values for each view: cross-section, front, back, above-->
        <xsl:variable name="x">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Ox + 43"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Ox + 42"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_back">
            <!-- Some types require a different value from the standard one: adjust to the right value when the variable is called -->
            <xsl:value-of select="$Ox + 229"/>
        </xsl:variable>
        <xsl:variable name="x_above">
            <!-- Some types require a different value from the standard one: adjust to the right value when the variable is called -->
            <xsl:value-of select="$Ox + 140"/>
        </xsl:variable>
        <xsl:variable name="y">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 41"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Oy + 58"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_back">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 42"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Oy + 57"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_above">
            <xsl:value-of select="$Oy + 102"/>
        </xsl:variable>
        <xsl:call-template name="primaryAttachmentType">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="x_back" select="$x_back"/>
            <xsl:with-param name="y_back" select="$y_back"/>
            <xsl:with-param name="x_above" select="$x_above"/>
            <xsl:with-param name="y_above" select="$y_above"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="primaryAttachmentType">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="x_back"/>
        <xsl:param name="y_back"/>
        <xsl:param name="x_above"/>
        <xsl:param name="y_above"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./compound/primaryAttachment/type/NC">
                    <xsl:text>Primary attachment type not checked.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/primaryAttachment/type/NK">
                    <xsl:text>Primary attachment type not known.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/primaryAttachment/type/other">
                    <xsl:text>Primary attachment type not covered by schema yet. Description notes: </xsl:text>
                    <xsl:value-of select="./compound/primaryAttachment/type/other/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Primary attachment type: </xsl:text>
                    <xsl:value-of select="./compound/primaryAttachment/type/node()[2]/name()"/>
                </xsl:otherwise>
            </xsl:choose>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty"
                    select="if (./compound/primaryAttachment/type[NC | NK]) then xs:integer(50) else xs:integer(100)"
                />
                <xsl:with-param name="type" select="'1'"/>
            </xsl:call-template>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="./compound/material[NC | cord | thread | NK | other]">
                        <xsl:text>line</xsl:text>
                    </xsl:when>
                    <xsl:when test="./compound/material[textile | ribbon]">
                        <xsl:text>line7</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryAttachment/type[NC | NK | other]">
                            <!-- Do nothing? -->
                        </xsl:when>
                        <xsl:when test="./compound/primaryAttachment/type/frayed and ./compound/primaryType/span2">
                            <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name(), '2')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$x"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$y"/>
                    </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryAttachment/type[NC | NK | other]">
                            <!-- Do nothing? -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name(), '_back')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryType[span1 | span2]">
                            <xsl:value-of select="$x_back - 10"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType/multipleSpan">
                            <xsl:value-of select="$x_back - 30"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[closedLoop | twistedSpan | twistedClosedLoop | NC | NK]">
                            <xsl:value-of select="if (./compound/primaryAttachment/type/frayed) then $x_back else $x_back - 0.5"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_back"/>
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="./compound/primaryAttachment/type[not(frayed)]">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:choose>
                                <xsl:when test="./compound/primaryAttachment/type[NC | NK | other]">
                                    <!-- Do nothing? -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name(), '_back')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:choose>
                                <xsl:when test="./compound/primaryType[span1 | span2]">
                                    <xsl:value-of select="$x_back + 10"/>
                                </xsl:when>
                                <xsl:when test="./compound/primaryType/multipleSpan">
                                    <xsl:value-of select="$x_back + 30"/>
                                </xsl:when>
                                <xsl:when test="./compound/primaryType[closedLoop | twistedSpan | twistedClosedLoop]">
                                    <xsl:value-of select="$x_back + 0.5"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y_back"/>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryAttachment/type[NC | NK | frayed | other]">
                            <!-- Do nothing? -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name(), '_above')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryType[span1 | span2]">
                            <xsl:value-of select="$x_above - 10"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType/multipleSpan">
                            <xsl:value-of select="$x_above - 30"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[closedLoop | twistedSpan | twistedClosedLoop]">
                            <xsl:value-of select="$x_above - 0.5"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_above"/>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryAttachment/type[NC | NK | frayed | other]">
                            <!-- Do nothing? -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/primaryAttachment/type/node()[2]/name(), '_above')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:choose>
                        <xsl:when test="./compound/primaryType[span1 | span2]">
                            <xsl:value-of select="$x_above + 10"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType/multipleSpan">
                            <xsl:value-of select="$x_above + 30"/>
                        </xsl:when>
                        <xsl:when test="./compound/primaryType[closedLoop | twistedSpan | twistedClosedLoop]">
                            <xsl:value-of select="$x_above -+ 0.5"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_above"/>
                </xsl:attribute>
            </use>
        </g>
    </xsl:template>


    <!--<xsl:template name="primaryAttachmentDecoration">
        <!-\- something -\->
    </xsl:template>-->


    <xsl:template name="secondaryTypeXYvalues">
        <xsl:param name="certainty" select="100"/>
        <!-- Need two variables for the values of X and Y in the <use> element that vary accordingly to the primaryType; Need a couple of values for each view: cross-section, front, back, above-->
        <xsl:variable name="x">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | multipleSpan | closedLoop | NC | NK | other]">
                    <xsl:value-of select="$Ox + 64"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Ox + 65"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType[twistedSpan | twistedClosedLoop]">
                    <xsl:value-of select="$Ox + 63.5"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="$Ox + 63.5"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 62 else $Ox + 61"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_front">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | span2 | multipleSpan | closedLoop | NC | NK | other]">
                    <xsl:value-of select="$Ox + 140"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="$Ox + 136"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 144 else $Ox + 142"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 143 else (if (./compound/secondaryType/hitchedDoubleLength) then $Ox + 142 else $Ox + 141.5)"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_above">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | span2 | multipleSpan | closedLoop | NC | NK | other]">
                    <xsl:value-of select="$Ox + 140"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 136 else $Ox + 137.5"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 144 else $Ox + 142"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Ox + 137 else $Ox + 138"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | multipleSpan | closedLoop | NC | NK | other]">
                    <xsl:value-of select="$Oy + 58.5"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 41.5"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength | hitchedDoubleLength]) then $Oy + 56 else $Oy + 57.5"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 56 else $Oy + 58"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 51 else $Oy + 49.5"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_front">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | multipleSpan | other]">
                    <xsl:value-of select="$Oy + 62"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 47"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType[closedLoop | NC | NK]">
                    <xsl:value-of select="$Oy + 60"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="$Oy + 52"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 53 else $Oy + 55.5"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 47 else (if (./compound/secondaryType/hitchedDoubleLength) then $Oy + 48 else $Oy + 46)"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y_above">
            <xsl:choose>
                <xsl:when test="./compound/primaryType[span1 | multipleSpan | other]">
                    <xsl:value-of select="$Oy + 126"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/span2">
                    <xsl:value-of select="$Oy + 119"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType[closedLoop | NC | NK]">
                    <xsl:value-of select="$Oy + 132"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <xsl:value-of select="$Oy + 128"/>
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 121.5 else $Oy + 123.5"/>
                </xsl:when>
                <!--<!-\- Alternative positioning -\->
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <xsl:value-of select="if (./compound/secondaryType[knottedDoubleLength | knottedSingleLength]) then $Oy + 121.5 else $Oy + 122.5"/>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="secondaryType">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="x_front" select="$x_front"/>
            <xsl:with-param name="y_front" select="$y_front"/>
            <xsl:with-param name="x_above" select="$x_above"/>
            <xsl:with-param name="y_above" select="$y_above"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="secondaryType">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="x_front"/>
        <xsl:param name="y_front"/>
        <xsl:param name="x_above"/>
        <xsl:param name="y_above"/>
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./compound/secondaryType/NC">
                    <xsl:text>Secondary type not checked.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/secondaryType/NK">
                    <xsl:text>Secondary type not known.</xsl:text>
                </xsl:when>
                <xsl:when test="./compound/secondaryType/other">
                    <xsl:text>Secondary type not covered by schema yet. Description notes: </xsl:text>
                    <xsl:value-of select="./compound/secondaryType/other/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Secondary type: </xsl:text>
                    <xsl:value-of select="./compound/secondaryType/node()[2]/name()"/>
                </xsl:otherwise>
            </xsl:choose>
        </desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty"
                    select="if (./compound/secondaryType[NC | NK| other]) then xs:integer(50) else xs:integer(100)"
                />
                <xsl:with-param name="type" select="'1'"></xsl:with-param>
            </xsl:call-template>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="./compound/material[NC | cord | thread | NK | other]">
                        <xsl:text>line</xsl:text>
                    </xsl:when>
                    <xsl:when test="./compound/material[textile | ribbon]">
                        <xsl:text>line7</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <!--<xsl:attribute name="class">
                <xsl:text>semiTransparent</xsl:text>
            </xsl:attribute>-->
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/secondaryType[NC | NK | other]">
                            <!-- ɑ very generic shape is drawn -->
                            <xsl:text>#generic</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/secondaryType/node()[2]/name())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y"/>
                </xsl:attribute>
            </use>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/secondaryType[NC | NK | other]">
                            <!-- ɑ very generic shape is drawn -->
                            <xsl:text>#generic_front</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/secondaryType/node()[2]/name(), '_front')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="if (./compound/secondaryType/multipleSpan) then $x_front - 20 else $x_front"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_front"/>
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="./compound/secondaryType/multipleSpan">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="concat('#', ./compound/secondaryType/node()[2]/name(), '_front')"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x_front + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y_front"/>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
            <use xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="xlink:href">
                    <xsl:choose>
                        <xsl:when test="./compound/secondaryType[NC | NK | other]">
                            <!-- ɑ very generic shape is drawn -->
                            <xsl:text>#generic_above</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', ./compound/secondaryType/node()[2]/name(), '_above')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="if (./compound/secondaryType/multipleSpan) then $x_above - 20 else $x_above"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$y_above"/>
                </xsl:attribute>
            </use>
            <xsl:choose>
                <xsl:when test="./compound/secondaryType/multipleSpan">
                    <use xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="concat('#', ./compound/secondaryType/node()[2]/name(), '_above')"/>
                        </xsl:attribute>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$x_above + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$y_above"/>
                        </xsl:attribute>
                    </use>
                </xsl:when>
            </xsl:choose>
        </g>
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