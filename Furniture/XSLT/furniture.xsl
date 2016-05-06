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
    <xsl:variable name="Px" select="$Ox + 30"/>
    <xsl:variable name="Py" select="$Oy + 30"/>

    <!-- Only a portion of the book width is drawn: this parameter selects the length -->
    <xsl:param name="boardLength" select="70"/>

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
                        test="yes/furniture[type[clasp[type[stirrupRing | NK | piercedStrap]] | pin | straps[type[tripleBraidedStrap | NK | doubleBraidedStrap | flat | other]]]]">
                        <xsl:variable name="group" select="1"/>
                        <xsl:choose>
                            <xsl:when
                                test="(yes/furniture/type/clasp/type[NK] and yes/furniture[type[pin | straps[type[tripleBraidedStrap | doubleBraidedStrap]]]]) or (yes/furniture/type/straps[type[NK | flat | other]] and yes/furniture[type[pin | clasp[type[stirrupRing | piercedStrap]]  | pin ]]) or (yes/furniture[type[clasp[type[stirrupRing | piercedStrap]] | pin | straps[type[tripleBraidedStrap | doubleBraidedStrap]]]])">
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
                                        <xsl:call-template name="title"/>
                                        <svg>
                                            <xsl:attribute name="x">
                                                <xsl:value-of select="$Ox"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="y">
                                                <xsl:value-of select="$Oy + 20"/>
                                            </xsl:attribute>
                                            <!-- Board cross sections -->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-- First board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection"> </use>
                                                <!-- Second board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <!-- Boards -->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py + 50"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-- First board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board"> </use>
                                                <!-- Second board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:for-each-group
                                                  select="yes/furniture[type[clasp[type[stirrupRing | NK | piercedStrap]] | pin | straps[type[tripleBraidedStrap | NK | doubleBraidedStrap | flat | other]]]]"
                                                  group-by="type">
                                                  <xsl:call-template name="types">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                  <xsl:call-template name="description">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                </xsl:for-each-group>
                                            </g>
                                            <!-- fader -->
                                            <use xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="xlink:href">
                                                  <xsl:text>#fader</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="x">
                                                  <xsl:value-of select="$Px + 150"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="y">
                                                  <xsl:value-of select="$Py - 10"/>
                                                </xsl:attribute>
                                            </use>
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="yes/furniture[type[clasp[type[NK | simpleHook | foldedHook | piercedStrap]] | catchplate[type[rollerRoundBar | raisedLip | bentAndSlotted | other | NK]] | straps[type[NK | flat | other]] | strapPlates | strapCollars]]">
                        <xsl:variable name="group" select="2"/>
                        <xsl:choose>
                            <xsl:when
                                test="(yes/furniture/type/clasp/type[NK] and yes/furniture[type[catchplate | strapPlates | strapCollars]]) or (yes/furniture/type/straps[type[NK | flat | other]] and yes/furniture[type[catchplate | clasp[type[simpleHook | foldedHook | piercedStrap]] | strapPlates | strapCollars]]) or (yes/furniture[type[clasp[type[simpleHook | foldedHook | piercedStrap]] | catchplate[type[rollerRoundBar | raisedLip | bentAndSlotted | other | NK]] | straps[type[flat | NK]] | strapPlates | strapCollars]]) or yes/furniture/type/catchplate">
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
                                        <xsl:call-template name="title"/>
                                        <svg>
                                            <xsl:attribute name="x">
                                                <xsl:value-of select="$Ox"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="y">
                                                <xsl:value-of select="$Oy + 20"/>
                                            </xsl:attribute>
                                            <!-- Board cross sections -->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-- First board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection"/>
                                                <!-- Second board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <!-- Boards -->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py + 50"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-- First board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board"> </use>
                                                <!-- Second board -->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:for-each-group
                                                  select="yes/furniture[type[clasp[type[NK | simpleHook | foldedHook | piercedStrap]] | catchplate[type[rollerRoundBar | raisedLip | bentAndSlotted | other | NK]] | straps[type[NK | flat | other]] | strapPlates | strapCollars]]"
                                                  group-by="type">
                                                  <!-- grouping problem: patch to sort catchplates and clasps -->
                                                  <xsl:variable name="patch">
                                                  <xsl:copy-of select="current-group()"/>
                                                  </xsl:variable>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="$patch/furniture/type[clasp | catchplate]">
                                                  <xsl:for-each select="$patch/furniture">
                                                  <xsl:call-template name="types">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                  <xsl:call-template name="description">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                  </xsl:for-each>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:call-template name="types">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                  <xsl:call-template name="description">
                                                  <xsl:with-param name="group"
                                                  select="current-group()"/>
                                                  </xsl:call-template>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:for-each-group>
                                            </g>
                                            <!-- fader -->
                                            <use xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="xlink:href">
                                                  <xsl:text>#fader</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="x">
                                                  <xsl:value-of select="$Px + 150"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="y">
                                                  <xsl:value-of select="$Py - 10"/>
                                                </xsl:attribute>
                                            </use>
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="yes/furniture[type[bosses | corners | plates | ties]]">
                        <!--<!-\- NB: check how many times things are drawn -\->
                        <xsl:for-each-group
                            select="yes/furniture[type[bosses | corners | plates | ties]]"
                            group-by="type">
                            <xsl:variable name="group">
                                <xsl:value-of select="3"/>
                                <xsl:text>-</xsl:text>
                                <xsl:number format="001"/>
                            </xsl:variable>
                            <xsl:for-each select="type">
                                <!-\- Each group of furniture is drawn on a different file -\->
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
                                    <!-\- Printed on A0 -\->
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
                                            <!-\- Board cross sections -\->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-\- First board -\->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection"/> 
                                                <!-\- Second board -\->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#boardXsection">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                </xsl:attribute>
                                                </use>
                                            </g>
                                            <!-\- Boards -\->
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$Px"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Py + 50"/>
                                                  <xsl:text>)</xsl:text>
                                                </xsl:attribute>
                                                <!-\- First board -\->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board"/> 
                                                <!-\- Second board -\->
                                                <use xmlns="http://www.w3.org/2000/svg"
                                                  xlink:href="#board">
                                                  <xsl:attribute name="transform">
                                                  <xsl:text>translate(</xsl:text>
                                                  <xsl:value-of select="$boardLength *4"/>
                                                  <xsl:text>,</xsl:text>
                                                  <xsl:value-of select="$Oy"/>
                                                  <xsl:text>)&#32;scale(-1,1)</xsl:text>
                                                  </xsl:attribute>
                                                </use>
                                            </g>
                                            <g xmlns="http://www.w3.org/2000/svg">
                                                <xsl:call-template name="types">
                                                    <xsl:with-param name="group"
                                                        select="current-group()"/>
                                                </xsl:call-template>
                                            </g>
                                        </svg>
                                    </svg>
                                </xsl:result-document>
                            </xsl:for-each>
                        </xsl:for-each-group>-->
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="types">
        <xsl:param name="group"/>
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
                <xsl:call-template name="claps"/>
            </xsl:when>
            <xsl:when test="type/catchplate">
                <xsl:call-template name="catchplate"/>
            </xsl:when>
            <xsl:when test="type/pin">
                <xsl:call-template name="pin"/>
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
                <xsl:call-template name="straps"/>
                <xsl:choose>
                    <xsl:when
                        test="preceding-sibling::furniture/type/strapPlates or following-sibling::furniture/type/strapPlates">
                        <xsl:call-template name="strapPlates"/>
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::furniture/type/strapCollars or following-sibling::furniture/type/strapCollars">
                        <xsl:call-template name="strapCollars"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="type/strapPlates">
                <!-- It has to be drawn over the strap: called with strap if presence registered -->
            </xsl:when>
            <xsl:when test="type/strapCollars">
                <!-- It has to be drawn over the strap: called with strap if presence registered -->
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
        <xsl:variable name="wideNarrowEdge">
            <xsl:choose>
                <xsl:when
                    test="preceding-sibling::furniture/type/catchplate/type/raisedLip or following-sibling::furniture/type/catchplate/type/raisedLip">
                    <xsl:text>#simpleORfoldedHook_wide</xsl:text>
                </xsl:when>
                <xsl:when
                    test="preceding-sibling::furniture/type/catchplate/type[rollerRoundBar | bentAndSlotted] or following-sibling::furniture/type/catchplate/type[rollerRoundBar | bentAndSlotted]">
                    <xsl:text>#simpleORfoldedHook_narrow</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>#simpleORfoldedHook_wide</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="type/clasp/type/stirrupRing">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#stirrupRingX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#stirrupRing">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 117.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/clasp/type[simpleHook | foldedHook]">
                <xsl:choose>
                    <xsl:when test="type/clasp/type/simpleHook">
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#simpleHookX">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Py - 3.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="{$wideNarrowEdge}">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 117.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                    <xsl:when test="type/clasp/type/foldedHook">
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#foldedHookX">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Py - 3.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="{$wideNarrowEdge}">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 117.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/clasp/type/piercedStrap">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#piercedStrapX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#piercedStrap">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 20"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 117.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/clasp/type[NC | NK]">
                <!-- When there is a pin then 'stirrupRing', when a chatchplate 'simpleHook' -->
                <!--<xsl:choose>
                    <xsl:when
                        test="preceding-sibling::furniture/type[pin | straps/type[tripleBraidedStrap | doubleBraidedStrap]] or following-sibling::furniture/type[pin | straps/type[tripleBraidedStrap | doubleBraidedStrap]]">
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#stirrupRingX">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Py - 3.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </use>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#stirrupRing">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 117.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </use>
                    </xsl:when>
                    <xsl:when
                        test="preceding-sibling::furniture/type[catchplate] or following-sibling::furniture/type[catchplate]">
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#simpleHookX">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Py - 3.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </use>
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="{$wideNarrowEdge}">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength + 20"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Oy + 117.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </use>
                    </xsl:when>
                </xsl:choose>-->
            </xsl:when>
            <xsl:when test="type/clasp/type/other">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="pin">
        <xsl:choose>
            <xsl:when test="type/pin/type[simplePin | fastenedPin | NC | NK]">
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="type/pin/location/side">
                                <xsl:choose>
                                    <xsl:when
                                        test="type/pin/type/simplePin and type/pin/throughPastedown/yes">
                                        <xsl:text>#simplePinXSide_2</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="type/pin/type/simplePin and type/pin/throughPastedown/not(yes)">
                                        <xsl:text>#simplePinXSide</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="type/pin/type/fastenedPin and type/pin/throughPastedown/yes">
                                        <xsl:text>#fastenedPinXSide_2</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="type/pin/type/fastenedPin and type/pin/throughPastedown/not(yes)">
                                        <xsl:text>#fastenedPinXSide</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="type/pin/type/simplePin">
                                        <xsl:text>#simplePinX</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="type/pin/type/fastenedPin and type/pin/throughPastedown/yes">
                                        <xsl:text>#fastenedPinX_2</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="type/pin/type/fastenedPin and type/pin/throughPastedown/not(yes)">
                                        <xsl:text>#fastenedPinX</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="type/pin/type[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="type/pin/location/side">
                                <xsl:choose>
                                    <xsl:when test="type/pin/type/simplePin">
                                        <xsl:text>#simplePinSide</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="type/pin/type/fastenedPin">
                                        <xsl:text>#fastenedPinSide</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="type/pin/type/simplePin">
                                        <xsl:text>#simplePin</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="type/pin/type/fastenedPin">
                                        <xsl:text>#fastenedPin</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 116"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="type/pin/type[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </use>
            </xsl:when>
            <xsl:when test="type/pin/type/other">
                <!--  -->
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="firstBoard_pastedown"/>
    </xsl:template>

    <xsl:template name="straps">
        <xsl:choose>
            <xsl:when test="type/straps/type[tripleBraidedStrap | doubleBraidedStrap]">
                <xsl:call-template name="straps_pastedownSide"/>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#braidedStrapX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="type/straps/type/tripleBraidedStrap">
                                <xsl:text>#tripleBraidedStrap</xsl:text>
                            </xsl:when>
                            <xsl:when test="type/straps/type/doubleBraidedStrap">
                                <xsl:text>#doubleBraidedStrap</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 117.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/straps/type[flat | NC | NK]">
                <xsl:call-template name="straps_pastedownSide"/>
                <xsl:variable name="claspAttachment">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::furniture/type/clasp/type/stirrupRing or following-sibling::furniture/type/clasp/type/stirrupRing">
                            <xsl:text>#flatStrapX_aroundClasp</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>#flatStrapX_underClasp</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="type/straps/type[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="{$claspAttachment}">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#flatStrapX">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg" xlink:href="#flatStrap">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Oy + 117.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::furniture/type/clasp/type/piercedStrap or following-sibling::furniture/type/clasp/type/piercedStrap">
                            <!-- Do nothing -->
                        </xsl:when>
                        <xsl:otherwise>
                            <use xmlns="http://www.w3.org/2000/svg" xlink:href="#flatStrap_claspEnd">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Px + $boardLength + 38"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Oy + 117.5"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="stroke-dasharray">
                                    <xsl:choose>
                                        <xsl:when
                                            test="preceding-sibling::furniture/type/clasp/type/stirrupRing or following-sibling::furniture/type/clasp/type/stirrupRing">
                                            <xsl:text>0 0</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>2 1</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </use>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
            </xsl:when>
            <xsl:when test="type/straps/type/other">
                <!--  -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="straps_pastedownSide">
        <xsl:variable name="pastedownSideIDcaller">
            <xsl:choose>
                <xsl:when test="type/straps/pastedownSide/under">
                    <xsl:choose>
                        <xsl:when test="type/straps/type[tripleBraidedStrap | doubleBraidedStrap]">
                            <xsl:text>#braidedStrapXend_underPastedown</xsl:text>
                        </xsl:when>
                        <xsl:when test="type/straps/type/flat">
                            <xsl:text>#flatStrapXend_underPastedown</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="type/straps/pastedownSide[through | NC | NK | other]">
                    <xsl:choose>
                        <xsl:when test="type/straps/type[tripleBraidedStrap | doubleBraidedStrap]">
                            <xsl:text>#braidedStrapXend_throughPastedown</xsl:text>
                        </xsl:when>
                        <xsl:when test="type/straps/type/flat">
                            <xsl:text>#flatStrapXend_throughPastedown</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when
                test="preceding-sibling::furniture/type[strapPlates | strapCollars] or following-sibling::furniture/type[strapPlates | strapCollars] or type/straps/type/flat">
                <!-- Prepare for strapPlate or strapCollars -->
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#flatStrapXend_strapPlatesORstrapCollars">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:otherwise>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="$pastedownSideIDcaller"/>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" as="xs:integer">
                            <xsl:choose>
                                <xsl:when test="type/straps/pastedownSide[under | through]">
                                    <xsl:value-of select="100"/>
                                </xsl:when>
                                <xsl:when test="type/straps/pastedownSide[other | NC | NK]">
                                    <xsl:value-of select="50"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="50"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </use>
                <xsl:choose>
                    <xsl:when test="type/straps/pastedownSide/under">
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::furniture/type/clasp/type/stirrupRing or following-sibling::furniture/type/clasp/type/stirrupRing">
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#flatStrapXend_underPastedown_doubleThickness">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of select="$Px + $boardLength + 38"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Py - 3.5"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </use>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="type/straps/pastedownSide[through | NC | NK | other]">
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::furniture/type/clasp/type/stirrupRing or following-sibling::furniture/type/clasp/type/stirrupRing">
                                <use xmlns="http://www.w3.org/2000/svg"
                                    xlink:href="#flatStrapXend_throughPastedown_doubleThickness">
                                    <xsl:attribute name="transform">
                                        <xsl:text>translate(</xsl:text>
                                        <xsl:value-of select="$Px + $boardLength + 38"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$Py - 3.5"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:attribute>
                                </use>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <!-- from above -->
        <xsl:choose>
            <xsl:when
                test="preceding-sibling::furniture/type[strapPlates | strapCollars] or following-sibling::furniture/type[strapPlates | strapCollars] or type/straps/type/flat">
                <!-- prepare for strapPlate or strapCollars -->
            </xsl:when>
            <xsl:otherwise>
                <use xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="xlink:href">
                        <xsl:choose>
                            <xsl:when test="type/straps/type/tripleBraidedStrap">
                                <xsl:text>#strapEnding_tripleStrap</xsl:text>
                            </xsl:when>
                            <xsl:when test="type/straps/type/doubleBraidedStrap">
                                <xsl:text>#strapEnding_doubleStrap</xsl:text>
                            </xsl:when>
                            <xsl:when test="type/straps/type/flat">
                                <xsl:text>#strapEnding_flat</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Ox"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" as="xs:integer">
                            <xsl:choose>
                                <xsl:when test="type/straps/pastedownSide[under | through]">
                                    <xsl:value-of select="100"/>
                                </xsl:when>
                                <xsl:when test="type/straps/pastedownSide[other | NC | NK]">
                                    <xsl:value-of select="50"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="50"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </use>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="strapPlates">
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#strapPlateX">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Px + $boardLength + 38"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Py - 3.5"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#strapPlate">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:call-template name="secondBoard_pastedown"/>
    </xsl:template>

    <xsl:template name="strapCollars">
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#strapCollarsX">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Px + $boardLength + 38"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Py - 3.5"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </use>
        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#strapCollars">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$Ox"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$Oy"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </use>
        <xsl:call-template name="secondBoard_pastedown"/>
    </xsl:template>

    <xsl:template name="catchplate">
        <xsl:choose>
            <xsl:when test="type/catchplate/type/rollerRoundBar">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#rollerRoundBar_catchplateX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#rollerRoundBar_catchplate">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 116"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/catchplate/type/raisedLip">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#raisedLip_catchplateX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#raisedLip_catchplate">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 116"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/catchplate/type/bentAndSlotted">
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#bentAndSlotted_catchplateX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#bentAndSlotted_catchplate">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 116"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when test="type/catchplate/type[NC | NK]">
                <!--<use xmlns="http://www.w3.org/2000/svg" xlink:href="#rollerRoundBar_catchplateX">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="certainty">
                        <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                        <xsl:with-param name="type" select="'2'"/>
                    </xsl:call-template>
                </use>
                <use xmlns="http://www.w3.org/2000/svg" xlink:href="#rollerRoundBar_catchplate">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Oy + 116"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>-->
            </xsl:when>
            <xsl:when test="type/catchplate/type/other">
                <!--  -->
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="firstBoard_pastedown"/>
    </xsl:template>

    <xsl:template name="firstBoard_pastedown">
        <xsl:choose>
            <xsl:when test="type/node()/throughPastedown[no | NC | NK | NA]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="type/node()/throughPastedown[NC | NK]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="#pastedown_throughPastedown_first">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py + 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <xsl:choose>
                        <xsl:when test="type/not(pin)">
                            <use xmlns="http://www.w3.org/2000/svg"
                                xlink:href="#firstBoard_elementAttachments_under">
                                <xsl:attribute name="transform">
                                    <xsl:text>translate(</xsl:text>
                                    <xsl:value-of select="$Px + $boardLength"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Py + 3.5"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </use>
                        </xsl:when>
                    </xsl:choose>
                </g>
            </xsl:when>
            <xsl:when test="type/node()/throughPastedown/yes">
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#pastedown_throughPastedown_first">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py + 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <xsl:choose>
                    <xsl:when test="type/not(pin)">
                        <use xmlns="http://www.w3.org/2000/svg"
                            xlink:href="#firstBoard_elementAttachments_through">
                            <xsl:attribute name="transform">
                                <xsl:text>translate(</xsl:text>
                                <xsl:value-of select="$Px + $boardLength"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$Py + 3.5"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="secondBoard_pastedown">
        <xsl:choose>
            <xsl:when
                test="preceding-sibling::furniture/type/strapPlates/throughPastedown[no | NC | NK | other] or following-sibling::furniture/type/strapPlates/throughPastedown[no | NC | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::furniture/type/strapPlates/throughPastedown[NC | NK | other]  or following-sibling::furniture/type/strapPlates/throughPastedown[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="#pastedown_throughPastedown_second">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="#secondBoard_elementAttachments_under_strapPlates">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </g>
            </xsl:when>
            <xsl:when
                test="preceding-sibling::furniture/type/strapPlates/throughPastedown/yes or following-sibling::furniture/type/strapPlates/throughPastedown/yes">
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#pastedown_throughPastedown_second">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#secondBoard_elementAttachments_through_strapPlates">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when
                test="preceding-sibling::furniture/type/strapPlates/throughPastedown/NA or following-sibling::furniture/type/node()/throughPastedown/NA">
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#secondBoard_elementAttachments_under_strapPlates">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when
                test="preceding-sibling::furniture/type/strapCollars/throughPastedown[no | NC | NK | other] or following-sibling::furniture/type/strapCollars/throughPastedown[no | NC | NK | other]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::furniture/type/strapCollars/throughPastedown[NC | NK | other]  or following-sibling::furniture/type/strapCollars/throughPastedown[NC | NK | other]">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="50"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" as="xs:integer" select="100"/>
                                <xsl:with-param name="type" select="'2'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="#pastedown_throughPastedown_second">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                    <use xmlns="http://www.w3.org/2000/svg"
                        xlink:href="#secondBoard_elementAttachments_under_strapCollars">
                        <xsl:attribute name="transform">
                            <xsl:text>translate(</xsl:text>
                            <xsl:value-of select="$Px + $boardLength + 38"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$Py - 3.5"/>
                            <xsl:text>)</xsl:text>
                        </xsl:attribute>
                    </use>
                </g>
            </xsl:when>
            <xsl:when
                test="preceding-sibling::furniture/type/strapCollars/throughPastedown/yes or following-sibling::furniture/type/strapCollars/throughPastedown/yes">
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#pastedown_throughPastedown_second">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#secondBoard_elementAttachments_through_strapCollars">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
            <xsl:when
                test="preceding-sibling::furniture/type/strapCollars/throughPastedown/NA or following-sibling::furniture/type/node()/throughPastedown/NA">
                <use xmlns="http://www.w3.org/2000/svg"
                    xlink:href="#secondBoard_elementAttachments_under_strapCollars">
                    <xsl:attribute name="transform">
                        <xsl:text>translate(</xsl:text>
                        <xsl:value-of select="$Px + $boardLength + 38"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="$Py - 3.5"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </use>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Titling -->
    <xsl:template name="title">
        <xsl:param name="detected" select="0"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ox + 175"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 20"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:text>furniture</xsl:text>
        </text>
    </xsl:template>

    <!-- Description -->
    <xsl:template name="description">
        <xsl:param name="group"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <text xmlns="http://www.w3.org/2000/svg" x="{$Ox + 20}" y="{$Oy + 170}">
                <xsl:choose>
                    <xsl:when test="type/NC">
                        <xsl:attribute name="class">
                            <xsl:text>noteText2</xsl:text>
                        </xsl:attribute>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:text>Furniture was detected but the type was not recorded</xsl:text>
                        </tspan>
                    </xsl:when>
                </xsl:choose>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 20}">
                    <xsl:choose>
                        <xsl:when test="type/catchplate">
                            <xsl:attribute name="class">
                                <xsl:text>noteText2</xsl:text>
                            </xsl:attribute>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 65}">
                                <xsl:text>Catchplate:</xsl:text>
                            </tspan>
                            <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 65}">
                                <xsl:value-of select="type/node()/type/node()[2]/name()"/>
                            </tspan>
                            <tspan dy="6.5" x="{$Ox + 65}">
                                <xsl:text>Through pastedown: </xsl:text>
                                <xsl:value-of select="type/catchplate/throughPastedown/node()[2]/name()"/>
                            </tspan>
                        </xsl:when>
                        <xsl:when test="type/pin">
                            <xsl:attribute name="class">
                                <xsl:text>noteText2</xsl:text>
                            </xsl:attribute>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 65}">
                                <xsl:text>Pin:</xsl:text>
                            </tspan>
                            <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 65}">
                                <xsl:value-of select="type/node()/type/node()[2]/name()"/>
                            </tspan>
                            <tspan dy="6.5" x="{$Ox + 65}">
                                <xsl:text>Location: </xsl:text>
                                <xsl:value-of select="type/pin/location/node()[2]/name()"/>
                            </tspan>
                            <tspan dy="6.5" x="{$Ox + 65}">
                                <xsl:text>Through pastedown: </xsl:text>
                                <xsl:value-of select="type/pin/throughPastedown/node()[2]/name()"/>
                            </tspan>
                        </xsl:when>
                    </xsl:choose>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 135}">
                    <xsl:choose>
                        <xsl:when test="type/clasp">
                            <xsl:attribute name="class">
                                <xsl:text>noteText2</xsl:text>
                            </xsl:attribute>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 135}">
                                <xsl:text>Clasp:</xsl:text>
                            </tspan>
                            <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 135}">
                                <xsl:value-of select="type/node()/type/node()[2]/name()"/>
                            </tspan><!--
                            <tspan dy="6.5" x="{$Ox + 100}">
                                <xsl:text>Through pastedown: </xsl:text>
                                <xsl:value-of select="type/clasp/throughPastedown/node()[2]/name()"/>
                            </tspan>-->
                        </xsl:when>
                    </xsl:choose>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 200}">
                    <xsl:choose>
                        <xsl:when test="type/straps">   
                            <xsl:attribute name="class">
                                <xsl:text>noteText2</xsl:text>
                            </xsl:attribute>                         
                            <xsl:variable name="slideX">
                                <xsl:choose>
                                    <xsl:when
                                        test="preceding-sibling::furniture/type[strapPlates | strapCollars] or following-sibling::furniture/type[strapPlates | strapCollars]">
                                        <xsl:value-of select="200"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="230"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + $slideX}">
                                <xsl:text>Strap:</xsl:text>
                            </tspan>
                            <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + $slideX}">
                                <xsl:value-of select="type/node()/type/node()[2]/name()"/>
                            </tspan>
                            <tspan dy="6.5" x="{$Ox + $slideX}">
                                <xsl:text>Pastedown side: </xsl:text>
                                <xsl:value-of select="type/straps/pastedownSide/node()[2]/name()"/>
                            </tspan>
                        </xsl:when>
                    </xsl:choose>
                </tspan>
                <tspan xmlns="http://www.w3.org/2000/svg" dy="6.5" x="{$Ox + 245}">
                    <xsl:choose>
                        <xsl:when test="type[strapPlates | strapCollars]">
                            <xsl:attribute name="class">
                                <xsl:text>noteText</xsl:text>
                            </xsl:attribute>
                            <tspan xmlns="http://www.w3.org/2000/svg" x="{$Ox + 245}">
                                <xsl:choose>
                                    <xsl:when test="type/strapPlates">                                        
                                        <xsl:text>Strap plates</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="type/strapCollars">
                                        <xsl:text>Strap collars</xsl:text>                                        
                                    </xsl:when>
                                </xsl:choose>
                            </tspan>
                            <tspan dy="6.5" x="{$Ox + 245}">
                                <xsl:text>Through pastedown: </xsl:text>
                                <xsl:value-of select="type/node()/throughPastedown/node()[2]/name()"/>
                            </tspan>
                        </xsl:when>
                    </xsl:choose>
                </tspan>
                
                <!--<tspan xmlns="http://www.w3.org/2000/svg">
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
                </tspan>-->
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
