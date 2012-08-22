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
        select="concat('../../Transformations/Bookmarks/SVGoutput/', $fileref[1], '_', 'Bookmarks')"/>

    <!-- X and Y reference values of the Origin - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved  NB: in SVG the origin is the top left corner of the screen area -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/markers/yes/marker/bookmark">
            <xsl:result-document
                href="{if (last() = 1) then concat($filenamePath, '.svg') else concat($filenamePath, '_',position(), '.svg')}"
                method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>href="../../../GitHub/Transformations/Bookmarks/CSS/style.css"&#32;</xsl:text>
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
                <xsl:call-template name="primaryType"/>
                <xsl:call-template name="primaryAttachmentType"/>
                <!--<xsl:call-template name="primaryAttachmentDecoration"/>-->
                <xsl:call-template name="secondaryType"/>
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
            <xsl:text>bookmark is attached to an endband formed of </xsl:text>
            <xsl:value-of select="$endband_numberOfCores"/>
            <xsl:text> core</xsl:text>
            <xsl:if test="xs:integer($endband_numberOfCores) gt 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$primaryCores"/>
            <xsl:text> primary core</xsl:text>
            <xsl:if test="xs:integer($primaryCores) gt 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text> and </xsl:text>
            <xsl:value-of select="$crowningCores"/>
            <xsl:text> crowning core</xsl:text>
            <xsl:if test="xs:integer($crowningCores) gt 1">
                <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </desc>
        <xsl:choose>
            <xsl:when test="./compound/primaryType/span2">
                <!-- Draw higher textblock diagram -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Draw standard textblock diagram -->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="xs:integer($primaryCores) gt 1">
                <!-- NB: how to draw this? -->
            </xsl:when>
            <xsl:when test="xs:integer($primaryCores) eq 1">
                <!-- draw primary core in all views -->
            </xsl:when>
            <xsl:when test="xs:integer($crowningCores) gt 1">
                <!-- NB: how to draw this? -->
            </xsl:when>
            <xsl:when test="xs:integer($crowningCores) eq 1">
                <!-- draw crowning core in all views -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="primaryType">
        <desc xmlns="http://www.w3.org/2000/svg">
            <xsl:text>Primary bookmark type: </xsl:text>
            <xsl:value-of select="./compound/primaryType[not(NC | NK | other)]/node()[2]/name()"/>
        </desc>
        <xsl:choose>
            <xsl:when test="./compound/primaryType/NC">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Primary bookmark type not checked.</xsl:text>
                </desc>
                <!--NB:  No file from St Catherine has this option. The most probable type should be drawn with a high degree of uncertainty: 'closedLoop.' -->
                <!-- TO DO -->
                <!-- Call the 'closedLoop' diagram option with a high degree of uncertainty -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/NK">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Primary bookmark type not known.</xsl:text>
                </desc>
                <!--NB:  The most probable type should be drawn with a high degree of uncertainty: 'closedLoop.' -->
                <!-- TO DO -->
                <!-- Call the 'closedLoop' diagram option with a high degree of uncertainty -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/other">
                <desc xmlns="http://www.w3.org/2000/svg">
                    <xsl:text>Primary bookmark type not covered by schema yet. Description notes: </xsl:text>
                    <xsl:value-of select="./compound/primaryType/other/text()"/>
                </desc>
            </xsl:when>
            <xsl:when test="./compound/primaryType/span1">
                <!-- TO DO -->
                <!-- Call the 'span1' diagram option -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/span2">
                <!-- TO DO -->
                <!-- Call the 'span2' diagram option -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/multipleSpan">
                <!-- TO DO -->
                <!-- Call the 'multipleSpan' diagram option -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/twistedSpan">
                <!-- TO DO -->
                <!-- Call the 'twistedSpan' diagram option -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/closedLoop">
                <!-- TO DO -->
                <!-- Call the 'closedLoop' diagram option -->
                <!-- TO DO -->
            </xsl:when>
            <xsl:when test="./compound/primaryType/twistedClosedLoop">
                <!-- TO DO -->
                <!-- Call the 'twistedClosedLoop' diagram option -->
                <!-- TO DO -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="useXYvalues">
        <!-- Need two variables for the values of X and Y in the <use> element that vary accordingly to the primaryType; Need a couple of values for each view: cross-section, front, back, above-->
        <!-- NB: some secondary types might need further modifications from the standard X and Y values for their respective primary type, but these might be adjusted inside the X/Y selection xPath or with a <xsl:choose> -->
        <xsl:variable name="x">
            <xsl:choose>
                <xsl:when test="./compound/primaryType/span1">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>-->
                </xsl:when>
                <xsl:when test="./compound/primaryType/span2">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>-->
                </xsl:when>
                <xsl:when test="./compound/primaryType/multipleSpan">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>-->
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedSpan">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>-->
                </xsl:when>
                <xsl:when test="./compound/primaryType/closedLoop">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>-->
                </xsl:when>
                <xsl:when test="./compound/primaryType/twistedClosedLoop">
                    <!-- if some secondary types require a different value from the standard one adjust  here and pass on the right value -->
                    <!--<xsl:value-of select="x"/>
                        or
                        <xsl:choose>
                        <xsl:when test="mmm">
                            <xsl:value-of select="x"/>
                        </xsl:when>
                    </xsl:choose>-->
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x_front">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="x_back">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="x_above">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="y">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="y_front">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="y_back">
            <!-- selection -->
        </xsl:variable>
        <xsl:variable name="y_above">
            <!-- selection -->
        </xsl:variable>
        <xsl:call-template name="primaryAttachmentType">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="x_back" select="$x_back"/>
            <xsl:with-param name="y_back" select="$y_back"/>
            <xsl:with-param name="x_above" select="$x_above"/>
            <xsl:with-param name="y_above" select="$y_above"/>
        </xsl:call-template>
        <xsl:call-template name="secondaryType">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="x_front" select="$x_front"/>
            <xsl:with-param name="y_front" select="$y_front"/>
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
        <xsl:choose>
            <xsl:when test="./compound/secondaryType[NC | NK | other]">
                <!-- do something and set a high degree of uncertainty. A possibility for NC and NK is drawing the most probable diagram with a high degree of uncertainty, while for 'other' a signpost diagram (again with a high degree of uncertainty) might work? -->
            </xsl:when>
            <xsl:otherwise>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="./compound/primaryAttachment/type/node()[2]/name()"/>
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
                        <xsl:value-of
                            select="concat(./compound/primaryAttachment/type/node()[2]/name(), '_back')"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$x_back"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$y_back"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of
                            select="concat(./compound/primaryAttachment/type/node()[2]/name(), '_above')"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$x_above"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$y_above"/>
                    </xsl:attribute>
                </use>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template name="primaryAttachmentDecoration">
        <!-\- something -\->
    </xsl:template>-->

    <xsl:template name="secondaryType">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="x_front"/>
        <xsl:param name="y_front"/>
        <xsl:param name="x_above"/>
        <xsl:param name="y_above"/>
        <xsl:choose>
            <xsl:when test="./compound/secondaryType[NC | NK | other]">
                <!-- do something and set a high degree of uncertainty. A possibility for NC and NK is drawing the most probable diagram with a high degree of uncertainty, while for 'other' a signpost diagram (again with a high degree of uncertainty) might work? -->
            </xsl:when>
            <xsl:otherwise>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="./compound/secondaryType/node()[2]/name()"/>
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
                        <xsl:value-of
                            select="concat(./compound/secondaryType/node()[2]/name(), '_front')"/>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$x_front"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$y_front"/>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of
                            select="concat(./compound/secondaryType/node()[2]/name(), '_above')"/>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$x_above"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$y_above"/>
                    </xsl:attribute>
                </use>
            </xsl:otherwise>
        </xsl:choose>
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
