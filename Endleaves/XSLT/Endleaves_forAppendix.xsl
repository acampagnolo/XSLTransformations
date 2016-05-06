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
    <xsl:variable name="filenameLeft_structure"
        select="concat('../../Transformations/Endleaves/SVGoutput/',  $fileref[1], '/', $fileref[1], '_', 'leftEndleaves_structure', '.svg')"/>
    <xsl:variable name="filenameLeft_use"
        select="concat('../../Transformations/Endleaves/SVGoutput/',  $fileref[1], '/', $fileref[1], '_', 'leftEndleaves_use', '.svg')"/>
    <xsl:variable name="filenameRight_structure"
        select="concat('../../Transformations/Endleaves/SVGoutput/',  $fileref[1], '/', $fileref[1], '_', 'rightEndleaves_structure', '.svg')"/>
    <xsl:variable name="filenameRight_use"
        select="concat('../../Transformations/Endleaves/SVGoutput/',  $fileref[1], '/', $fileref[1], '_', 'rightEndleaves_use', '.svg')"/>


    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="20"/>

    <xsl:param name="Oy"
        select="$Ox + $delta * (count(/book/endleaves/left/yes/type/separate/units/unit[1]/following-sibling::unit/components/component))"/>

    <!-- X and Y values to place the outermost gathering for both left and right endleaves -->
    <xsl:variable name="Ax" select="$Ox + 155"/>
    <xsl:variable name="Ay" select="$Oy + 120"/>

    <!-- Value to determine the Y value of distance between the different components of the endleaves-->
    <xsl:variable name="delta" select="6"/>

    <xsl:template name="main" match="/">
        <xsl:choose>
            <xsl:when test="book/endleaves[left | right]">
                <xsl:for-each select="book/endleaves/left">
                    <!-- draw USE diagram (i.e. no differentiation between pastedowns or not -->
                    <xsl:result-document href="{$filenameLeft_use}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Endleaves/CSS/style.css"&#32;</xsl:text>
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
                            version="1.1" x="0" y="0" width="420mm" height="297mm" viewBox="0 0 420 297"
                            preserveAspectRatio="xMidYMid meet">
                            <title>Left endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                            <xsl:copy-of
                                select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                            <desc xmlns="http://www.w3.org/2000/svg">Left endleaves</desc>
                            <xsl:call-template name="title">
                                <xsl:with-param name="side" select="'left'"/>
                                <xsl:with-param name="use" select="'use'"/>
                            </xsl:call-template>
                            <xsl:variable name="unknown">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[NC | NK]">
                                        <xsl:text>ncNK</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="./yes/type[other]">
                                        <xsl:text>other</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="description">
                                <xsl:with-param name="baseline"
                                    select="if (type/separate/units/unit/components/component/type/hook/type/textHook) then $Ay + $delta + 100 + $delta * count(type/separate/units/unit/components/component[type/hook/type/textHook])  else $Ay + $delta + 100"/>
                                <xsl:with-param name="unknown" select="$unknown"/>
                            </xsl:call-template>
                            <svg>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ox"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Oy"/>
                                </xsl:attribute>
                                <xsl:call-template name="leftEndleaves">
                                    <xsl:with-param name="use" select="false()"/>
                                </xsl:call-template>
                            </svg>
                        </svg>
                    </xsl:result-document>
                    <!-- draw STRUCTURE diagram (i.e. with differentiation between pastedowns or not -->
                    <xsl:result-document href="{$filenameLeft_structure}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Endleaves/CSS/style.css"&#32;</xsl:text>
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
                            version="1.1" x="0" y="0" width="420mm" height="297mm" viewBox="0 0 420 297"
                            preserveAspectRatio="xMidYMid meet">
                            <title>Left endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                            <xsl:copy-of
                                select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                            <desc xmlns="http://www.w3.org/2000/svg">Left endleaves</desc>
                            <xsl:call-template name="title">
                                <xsl:with-param name="side" select="'left'"/>
                                <xsl:with-param name="use" select="'structure'"/>
                            </xsl:call-template>
                            <xsl:variable name="unknown">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[NC | NK]">
                                        <xsl:text>ncNK</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="./yes/type[other]">
                                        <xsl:text>other</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="description">
                                <xsl:with-param name="baseline"
                                    select="if (type/separate/units/unit/components/component/type/hook/type/textHook) then $Ay + $delta + 100 + $delta * count(type/separate/units/unit/components/component[type/hook/type/textHook])  else $Ay + $delta + 100"/>
                                <xsl:with-param name="unknown" select="$unknown"/>
                            </xsl:call-template>
                            <svg>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ox"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Oy"/>
                                </xsl:attribute>
                                <xsl:call-template name="leftEndleaves">
                                    <xsl:with-param name="use" select="true()"/>
                                </xsl:call-template>
                            </svg>
                        </svg>
                    </xsl:result-document>
                </xsl:for-each>
                <xsl:for-each select="book/endleaves/right">
                    <!-- draw USE diagram (i.e. no differentiation between pastedowns or not -->
                    <xsl:result-document href="{$filenameRight_use}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Endleaves/CSS/style.css"&#32;</xsl:text>
                    <xsl:text>type="text/css"</xsl:text>
                </xsl:processing-instruction>
                        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                            version="1.1" x="0" y="0" width="420mm" height="297mm" viewBox="0 0 420 297"
                            preserveAspectRatio="xMidYMid meet">
                            <title>Right endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                            <xsl:copy-of
                                select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                            <xsl:call-template name="title">
                                <xsl:with-param name="side" select="'right'"/>
                                <xsl:with-param name="use" select="'use'"/>
                            </xsl:call-template>
                            <xsl:variable name="unknown">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[NC | NK]">
                                        <xsl:text>ncNK</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="./yes/type[other]">
                                        <xsl:text>other</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="description">
                                <xsl:with-param name="baseline"
                                    select="if (type/separate/units/unit/components/component/type/hook/type/textHook) then $Ay + $delta + 100 + $delta * count(type/separate/units/unit/components/component[type/hook/type/textHook])  else $Ay + $delta + 100"/>
                                <xsl:with-param name="unknown" select="$unknown"/>
                            </xsl:call-template>
                            <g transform="scale(-1 1)">
                                <desc>Right endleaves</desc>
                                <svg>
                                    <xsl:attribute name="x">
                                        <xsl:value-of select="$Ox - 365"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="y">
                                        <xsl:value-of select="$Oy"/>
                                    </xsl:attribute>
                                    <xsl:call-template name="leftEndleaves">
                                        <xsl:with-param name="use" select="false()"/>
                                    </xsl:call-template>
                                </svg>
                            </g>
                        </svg>
                    </xsl:result-document>
                    <!-- draw STRUCTURE diagram (i.e. with differentiation between pastedowns or not -->
                    <xsl:result-document href="{$filenameRight_structure}" method="xml" indent="yes"
                        encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
                        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                        <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../../GitHub/XSLTransformations/Endleaves/CSS/style.css"&#32;</xsl:text>
                    <xsl:text>type="text/css"</xsl:text>
                </xsl:processing-instruction>
                        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                            version="1.1" x="0" y="0" width="420mm" height="297mm" viewBox="0 0 420 297"
                            preserveAspectRatio="xMidYMid meet">
                            <title>Right endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                            <xsl:copy-of
                                select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                                xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                            <xsl:call-template name="title">
                                <xsl:with-param name="side" select="'right'"/>
                                <xsl:with-param name="use" select="'structure'"/>
                            </xsl:call-template>
                            <xsl:variable name="unknown">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[NC | NK]">
                                        <xsl:text>ncNK</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="./yes/type[other]">
                                        <xsl:text>other</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="description">
                                <xsl:with-param name="baseline"
                                    select="if (type/separate/units/unit/components/component/type/hook/type/textHook) then $Ay + $delta + 100 + $delta * count(type/separate/units/unit/components/component[type/hook/type/textHook])  else $Ay + $delta + 100"/>
                                <xsl:with-param name="unknown" select="$unknown"/>
                            </xsl:call-template>
                            <g transform="scale(-1 1)">
                                <desc>Right endleaves</desc>
                                <svg>
                                    <xsl:attribute name="x">
                                        <xsl:value-of select="$Ox - 365"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="y">
                                        <xsl:value-of select="$Oy"/>
                                    </xsl:attribute>
                                    <xsl:call-template name="leftEndleaves">
                                        <xsl:with-param name="use" select="true()"/>
                                    </xsl:call-template>
                                </svg>
                            </g>
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

    <xsl:template name="leftEndleaves">
        <xsl:param name="use" select="false()"/>
        <xsl:choose>
            <!-- If endleaves are present, then the right sequence of templates is called to construct the diagram, otherwise only the outer gathering is drawn -->
            <xsl:when test="self::node()[yes | no]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <xsl:choose>
                        <xsl:when test="./yes/type/separate/units/unit//hook/type[textHook]">
                            <!-- shorter outermost gathering -->
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[integral]">
                                        <xsl:attribute name="class">
                                            <xsl:text>line</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">
                                            <xsl:text>line_ref</xsl:text>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ax + 140"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + $delta + 10"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay"/>
                                    <xsl:text>&#32;A</xsl:text>
                                    <xsl:value-of select="10"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="10"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:text>0</xsl:text>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:text>0</xsl:text>
                                    <xsl:text>,</xsl:text>
                                    <xsl:text>0</xsl:text>
                                    <xsl:value-of select="$Ax + $delta + 10"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay + 20"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + 140"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$Ay + 20"/>
                                    <xsl:text>&#32;z</xsl:text>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <use xlink:href="#outermostGL">
                                <xsl:choose>
                                    <xsl:when test="./yes/type[integral]">
                                        <xsl:attribute name="class">
                                            <xsl:text>line</xsl:text>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">
                                            <xsl:text>line_ref</xsl:text>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ax"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Ay"/>
                                </xsl:attribute>
                            </use>
                            <use xlink:href="#outermostGL">
                                <xsl:attribute name="class">
                                    <xsl:text>line_ref</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ax"/>
                                </xsl:attribute>
                                <xsl:attribute name="y">
                                    <xsl:value-of select="$Ay + $delta + 20"/>
                                </xsl:attribute>
                            </use>
                        </xsl:otherwise>
                    </xsl:choose>
                </g>
                <xsl:choose>
                    <xsl:when test="./yes/type[integral]">
                        <xsl:call-template name="leftEndleavesIntegral">
                            <xsl:with-param name="use" select="$use"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./yes/type[separate]">
                        <xsl:call-template name="leftEndleavesSeparate">
                            <xsl:with-param name="use" select="$use"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Type of endleaves not checked, not
                            known, or other</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="totLeaves" select="./yes/type/integral/numberOfLeaves" as="xs:integer"/>
        <xsl:param name="currentLeaf" select="1"/>
        <xsl:variable name="baseline_int" select="$Ay"/>
        <xsl:variable name="B1x" select="$Ax - 145"/>
        <xsl:variable name="B1y"
            select="$baseline_int - ($delta * $totLeaves) - ($delta * ($totLeaves - $currentLeaf)) - 5 -
            (if (./yes/type/separate//pastedown/yes) then ($delta * (count(./yes/type/separate//pastedown/yes))) else 0)"/>
        <desc xmlns="http://www.w3.org/2000/svg">Integral endleaves</desc>
        <desc xmlns="http://www.w3.org/2000/svg">Leaf N.<xsl:value-of
                select="$totLeaves - $currentLeaf + 1"/></desc>
        <xsl:choose>
            <xsl:when test="./yes/type/integral/pastedown[yes] and $use eq false()">
                <xsl:call-template name="leftEndleavesIntegral-Pastedown">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./yes/type/integral/pastedown[yes] and $use eq true()">
                <xsl:call-template name="leftEndleavesIntegral-Flyleaves">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="use" select="$use"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./yes/type/integral/pastedown[no]">
                <xsl:call-template name="leftEndleavesIntegral-Flyleaves">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="use" select="$use"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Integral flyleaves not checked, not known,
                    or other.</desc>
                <!-- Draw as if no, but with uncertainty -->
                <xsl:call-template name="leftEndleavesIntegral-Flyleaves">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="certainty" select="if ($use eq true()) then 100 else 50"/>
                    <xsl:with-param name="use" select="$use"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral-Pastedown">
        <xsl:param name="totLeaves" as="xs:integer"/>
        <xsl:param name="currentLeaf"/>
        <xsl:param name="baseline_int"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:choose>
            <xsl:when test="$currentLeaf = $totLeaves">
                <desc xmlns="http://www.w3.org/2000/svg">Pastedown</desc>
                <g xmlns="http://www.w3.org/2000/svg">
                    <use xlink:href="#pastedown">
                        <xsl:attribute name="x">
                            <xsl:value-of select="$B1x"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$B1y"/>
                        </xsl:attribute>
                    </use>
                    <path>
                        <xsl:attribute name="class">
                            <xsl:text>line</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline_int + 10"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Ax"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y + $delta"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$B1x + 130"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y"/>
                        </xsl:attribute>
                    </path>
                </g>
            </xsl:when>
            <xsl:when test="$currentLeaf lt $totLeaves">
                <desc xmlns="http://www.w3.org/2000/svg">Flyleaf</desc>
                <xsl:call-template name="leftEndleavesIntegral-Flyleaf">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                </xsl:call-template>
                <xsl:call-template name="leftEndleavesIntegral">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf + 1"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral-Flyleaves">
        <xsl:param name="use" select="false()"/>
        <xsl:param name="totLeaves" as="xs:integer"/>
        <xsl:param name="currentLeaf"/>
        <xsl:param name="baseline_int"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="certainty" select="100"/>
        <xsl:choose>
            <xsl:when test="$currentLeaf = $totLeaves">
                <desc xmlns="http://www.w3.org/2000/svg">Flyleaf</desc>
                <xsl:call-template name="leftEndleavesIntegral-Flyleaf">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$currentLeaf lt $totLeaves">
                <desc xmlns="http://www.w3.org/2000/svg">Flyleaf</desc>
                <xsl:call-template name="leftEndleavesIntegral-Flyleaf">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="baseline_int" select="$baseline_int"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
                <xsl:call-template name="leftEndleavesIntegral">
                    <xsl:with-param name="totLeaves" select="$totLeaves" as="xs:integer"/>
                    <xsl:with-param name="currentLeaf" select="$currentLeaf + 1"/>
                    <xsl:with-param name="use" select="$use"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral-Flyleaf">
        <xsl:param name="totLeaves"/>
        <xsl:param name="currentLeaf"/>
        <xsl:param name="baseline_int"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:variable name="Ax"
            select="if (./yes/type/separate/units/unit/components/component/type/hook/type/textHook) then $Ax + 6 else $Ax"/>
        <xsl:variable name="Ax2"
            select="if (./yes/type/separate/units/unit/components/component/type/hook/type/textHook) then $Ax + 134 else $Ax + 140"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'2'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline_int + 10"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of select="$Ax"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline_int - ($delta * $currentLeaf))"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax + 10"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline_int - ($delta * $currentLeaf))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline_int - ($delta * $currentLeaf))"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparate">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <desc xmlns="http://www.w3.org/2000/svg">Separate endleaves</desc>
        <xsl:for-each select="./yes/type/separate/units/unit">
            <!-- Variable to count the number of Units -->
            <xsl:variable name="countUnits" select="last()"/>
            <!-- Counter variable for the current unit -->
            <xsl:variable name="currentUnit" select="position()"/>
            <desc xmlns="http://www.w3.org/2000/svg">Unit N. <xsl:value-of select="$currentUnit"
                /></desc>
            <xsl:call-template name="leftEndleavesSeparate_components">
                <xsl:with-param name="use" select="$use"/>
                <xsl:with-param name="countUnits" select="$countUnits"/>
                <xsl:with-param name="currentUnit" select="$currentUnit"/>
                <xsl:with-param name="baseline"
                    select="if (following-sibling::unit[1]/components/component//type[textHook]) then $Ay - $delta * count(following-sibling::unit[1]/components/component)
                    - (if (ancestor::yes/type/integral) then $delta * count(ancestor::yes/type/integral/xs:integer(numberOfLeaves)) + $delta * 1.5 else 0)
                    else $Ay - ((if (ancestor::yes/type[integral]) then $delta * ancestor::yes/type/integral/xs:integer(numberOfLeaves) else 0) 
                    + (if (preceding-sibling::unit[1]/components/component//type[textHook]) then $delta * count(preceding-sibling::unit[1]/components/component) else 0) 
                    + (if (components/component//type[textHook]) then (if (ancestor::yes/type/integral) then - $delta * ancestor::yes/type/integral/numberOfLeaves else 0)
                    else $delta * 2 * count(following-sibling::unit/components/component) 
                    + (($delta - 2) * count(following-sibling::unit[not(components//type[textHook])]))
                    - (if (following-sibling::unit[1]/components/component/type[singleLeaf | NC | NK | other]) then $delta * 1.5 else 0)
                    ))"
                />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparate_components">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="countUnits"/>
        <xsl:param name="currentUnit"/>
        <xsl:param name="baseline"/>
        <xsl:for-each select="./components/component">
            <!-- Variable to count the number of Components -->
            <xsl:variable name="countComponents" select="last()"/>
            <!-- Counter variable for the current component -->
            <xsl:variable name="currentComponent" select="position()"/>
            <g xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="material/parchment">
                            <xsl:text>line2</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>line</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <desc xmlns="http://www.w3.org/2000/svg">Component N. <xsl:value-of
                        select="$currentComponent"/></desc>
                <xsl:choose>
                    <xsl:when test="./type/hook/type[textHook]">
                        <use xmlns="http://www.w3.org/2000/svg" xlink:href="#outermostGL">
                            <xsl:attribute name="class">
                                <xsl:text>line_ref</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="x">
                                <xsl:value-of select="$Ax"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="$Ay + $delta + 20 + $delta * $countComponents"
                                />
                            </xsl:attribute>
                        </use>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./pastedown[yes] and $use eq false()">
                        <desc xmlns="http://www.w3.org/2000/svg">Pastedown</desc>
                        <xsl:call-template name="leftEndleavesSeparatePastedown">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./pastedown[yes] and $use eq true()">
                        <desc xmlns="http://www.w3.org/2000/svg">Flyleaves</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./pastedown[no]">
                        <desc xmlns="http://www.w3.org/2000/svg">Flyleaves</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Type of endleaf component not
                            checked, not known, or other</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                            <xsl:with-param name="certainty"
                                select="if ($use eq true()) then 100 else 50"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </g>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaves">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-Fold">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[guard]">
                <desc xmlns="http://www.w3.org/2000/svg">Type guard</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-Guard">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[hook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type hook</desc>
                <xsl:choose>
                    <xsl:when test="./type/hook/type[endleafHook]">
                        <desc xmlns="http://www.w3.org/2000/svg">Type endleaf-hook</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves-EndleafHook">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./type/hook/type[textHook]">
                        <desc xmlns="http://www.w3.org/2000/svg">Type text-hook</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves-TextHook">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                            <xsl:with-param name="certainty" select="$certainty"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or
                            other type</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="./type[outsideHook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type outside hook</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-OutsideHook">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="certainty" select="$certainty"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[singleLeaf]">
                <desc xmlns="http://www.w3.org/2000/svg">Type single leaf</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaf-SingleLeaf">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="certainty" select="$certainty" as="xs:integer"/>
                </xsl:call-template>
                <xsl:call-template name="componentAttachment">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline"
                        select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other
                    type</desc>
                <!-- draw single leaf that fades away at the fold-->
                <xsl:call-template name="leftEndleavesSeparateFlyleaf-SingleLeaf">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="certainty" select="$certainty" as="xs:integer"/>
                    <xsl:with-param name="unknown" select="'yes'"/>
                </xsl:call-template>
                <xsl:call-template name="componentAttachment">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="certainty" select="50" as="xs:integer"/>
                    <xsl:with-param name="baseline"
                        select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaves-Fold">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <desc xmlns="http://www.w3.org/2000/svg">Folded flyleaves</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
            <path>
                <xsl:choose>
                    <xsl:when test="$certainty lt 100">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'2'"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="B1x"
            select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 145"/>
        <xsl:variable name="B1y"
            select="$baseline - 
            (2 * $delta * $countComponents) - 
            (3 * $delta * count(ancestor::unit/preceding-sibling::unit/components/component[pastedown/yes])) -
            ($delta * count(preceding-sibling::component)) +
            (if (ancestor::yes/type/integral/pastedown/yes) then ($delta * (ancestor::yes/type/integral/numberOfLeaves) + $delta) else 0)
            - 10 + 
            (if (./type/hook/type[textHook]) then $delta * $countComponents - 
            (if (ancestor::yes/type/integral) then $delta +  $delta * ancestor::yes/type/integral/numberOfLeaves else 0) - 5 else 0)"/>
        <xsl:call-template name="leftEndleavesSeparatePastedown-pastedown">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="B1x" select="$B1x"/>
            <xsl:with-param name="B1y" select="$B1y"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline" select="$baseline"/>
            <xsl:with-param name="unknown"
                select="if (./type[NC | NK | other]) then 'yes' else 'no'"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparatePastedown-Fold">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[guard]">
                <desc xmlns="http://www.w3.org/2000/svg">Type guard</desc>
                <xsl:call-template name="leftEndleavesSeparatePastedown-Guard">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[hook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type hook</desc>
                <xsl:choose>
                    <xsl:when test="./type/hook/type[endleafHook]">
                        <desc xmlns="http://www.w3.org/2000/svg">Type pastedown-endleaf-hook</desc>
                        <xsl:call-template name="leftEndleavesSeparatePastedown-EndleafHook">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="B1x" select="$B1x"/>
                            <xsl:with-param name="B1yParam" select="$B1y"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./type/hook/type[textHook]">
                        <desc xmlns="http://www.w3.org/2000/svg">Type pastedown-text-hook</desc>
                        <xsl:call-template name="leftEndleavesSeparatePastedown-TextHook">
                            <xsl:with-param name="use" select="$use"/>
                            <xsl:with-param name="B1x" select="$B1x"/>
                            <xsl:with-param name="B1y" select="$B1y"/>
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or
                            other type</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="./type[outsideHook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type outside hook</desc>
                <xsl:call-template name="leftEndleavesSeparatePastedown-OutsideHook">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[singleLeaf]">
                <desc xmlns="http://www.w3.org/2000/svg">Type single leaf</desc>
                <!-- Pastedown already drawn when detected its presence -->
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other
                    type</desc>
                <!-- Pastedown already drawn when detected its presence -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaf-SingleLeaf">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:param name="unknown" select="'no'"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path for the flyleaf</desc>
            <path>
                <xsl:choose>
                    <xsl:when test="$unknown eq 'yes'">
                        <xsl:attribute name="stroke">
                            <xsl:text>url(#fading)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy + (if ($unknown eq 'yes') then 0.0001 else 0)"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaf-SingleLeaf_part">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100" as="xs:integer"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path for the flyleaf</desc>
            <path>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Dx"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-pastedown">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="unknown" select="'no'"/>
        <g xmlns="http://www.w3.org/2000/svg" id="{concat('pastedown', position())}">
            <desc>pastedown</desc>
            <path>                
                <xsl:choose>
                    <xsl:when test="$unknown eq 'yes'">
                        <xsl:attribute name="stroke">
                            <xsl:text>url(#fading2)</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:choose>
                        <xsl:when test="./type[outsideHook]">
                            <xsl:value-of select="$B1x + 115"/>
                        </xsl:when>                        
                        <xsl:when test="./type[guard]">
                            <xsl:value-of select="$B1x + 95"/>
                        </xsl:when>
                        <xsl:otherwise>                            
                            <xsl:value-of select="$B1x"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="./type/hook/type[textHook]">
                            <xsl:value-of select="$B1y + $delta"/>
                        </xsl:when>
                        <xsl:when test="./type/hook/type[endleafHook]">
                            <xsl:value-of select="$B1y - 5"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$B1y"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$B1x + 130"/>
                    <xsl:text>,</xsl:text>
                    <xsl:choose>
                        <xsl:when test="./type/hook/type[textHook]">
                            <xsl:value-of
                                select="$B1y + $delta + (if ($unknown eq 'yes') then 0.001 else 0)"
                            />
                        </xsl:when>
                        <xsl:when test="./type/hook/type[endleafHook]">
                            <xsl:value-of
                                select="$B1y - 5 + (if ($unknown eq 'yes') then 0.001 else 0)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$B1y + (if ($unknown eq 'yes') then 0.001 else 0)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </path>
            <g xmlns="http://www.w3.org/2000/svg">
                <use xlink:href="#pasted">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$B1x"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="./type/hook/type[textHook]">
                            <xsl:attribute name="y">
                                <xsl:value-of select="$B1y + $delta"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="./type/hook/type[endleafHook]">
                            <xsl:attribute name="y">
                                <xsl:value-of select="$B1y - 5"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="y">
                                <xsl:value-of select="$B1y"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="./type[guard]">
                            <xsl:attribute name="clip-path">
                                <xsl:text>url(#guardClip)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="./type[outsideHook]">
                            <xsl:attribute name="clip-path">
                                <xsl:text>url(#outsideHookClip)</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </use>
            </g>
        </g>
        <xsl:choose>
            <xsl:when test="./type[singleLeaf]">
                <!-- do not call the component attachment -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="componentAttachment">
                    <xsl:with-param name="use" select="$use"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="certainty"
                        select="if ($unknown eq 'yes') then 50 else 100" as="xs:integer"/>
                    <xsl:with-param name="onlySewn"
                        select="if (./type[singleLeaf]) then 'yes' else 'no'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-Fold">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <xsl:call-template name="leftEndleavesSeparateFlyleaf-SingleLeaf_part">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="baseline" select="$baseline"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="currentComponent" select="$currentComponent"/>
        </xsl:call-template>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Dx"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$B1x + 130"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaves-Guard">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <desc xmlns="http://www.w3.org/2000/svg">Flyleaf guard</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-Guard">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty"
                        select="if ($currentComponent eq $countComponents) then 50 else 100"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$B1x + 130"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaves-EndleafHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="certainty" select="100"/>
        <desc xmlns="http://www.w3.org/2000/svg">Endleaf-hook</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./type/hook/double/yes">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                                <xsl:text>&#32;A</xsl:text>
                                <xsl:value-of
                                    select="$delta - 1 + (count(following-sibling::component) * $delta) + 2.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$delta - 1 + (count(following-sibling::component) * $delta)  + 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta)) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                            </xsl:attribute>
                        </path>
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="$certainty"/>
                                <xsl:with-param name="type" select="'4'"/>
                            </xsl:call-template>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + 140"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta))) - 2"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta))) - 2"/>
                                <xsl:text>&#32;A</xsl:text>
                                <xsl:value-of
                                    select="$delta - 1 + (count(following-sibling::component) * $delta) + 2.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$delta - 1 + (count(following-sibling::component) * $delta)  + 2.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta)) - 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                            </xsl:attribute>
                        </path>
                    </g>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax + $delta + ($delta * $countComponents)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta * $currentComponent) -1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + ($delta * $countComponents)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta * $currentComponent) -1"/>
                                    <xsl:text>&#32;A</xsl:text>
                                    <xsl:value-of
                                        select="$delta - 1 + (count(following-sibling::component) * $delta) -0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$delta - 1 + (count(following-sibling::component) * $delta) -0.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta)) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta * $countComponents) - 5"/>
                                </xsl:attribute>
                            </path>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="type" select="'4'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ax + 140"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta))) + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + ($delta * $countComponents)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta))) + 1"/>
                                    <xsl:text>&#32;A</xsl:text>
                                    <xsl:value-of
                                        select="$delta - 1 + (count(following-sibling::component) * $delta) - 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$delta - 1 + (count(following-sibling::component) * $delta) - 0.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta)) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta * $countComponents) - 5"/>
                                </xsl:attribute>
                            </path>
                        </g>
                        <path xmlns="http://www.w3.org/2000/svg" stroke-linecap="round">
                            <!-- always uncertain as the schema does not tell if the double is a single or two sheets -->
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'4'"/>
                            </xsl:call-template>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ax + $delta + ($delta * $countComponents) + 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax + $delta + ($delta * $countComponents) + 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ax + $delta + ($delta * $countComponents) + 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"
                                />
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:when>
                <xsl:otherwise>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + 140"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                        </xsl:attribute>
                    </path>
                </xsl:otherwise>
            </xsl:choose>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-EndleafHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1yParam"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <xsl:variable name="B1y" select="$B1yParam - 5"/>
        <desc xmlns="http://www.w3.org/2000/svg">Pastedown endleaf-hook</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./type/hook/double/yes">
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax - 2 + ($delta * count(preceding-sibling::component)) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax - 2 + ($delta * count(preceding-sibling::component)) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax - 2 + ($delta * count(preceding-sibling::component)) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$B1x + 130"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y"/>
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + 140"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"
                            />
                        </xsl:attribute>
                    </path>
                    <path xmlns="http://www.w3.org/2000/svg">

                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="50"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 1"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent) + 2"/>
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:otherwise>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + $delta + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$B1x + 130"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y"/>
                        </xsl:attribute>
                    </path>
                </xsl:otherwise>
            </xsl:choose>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaves-TextHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="certainty" select="100"/>
        <desc xmlns="http://www.w3.org/2000/svg">Text-hook</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./type/hook/double/yes">
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $delta + 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;A</xsl:text>
                                <xsl:value-of
                                    select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline + 10"/>
                            </xsl:attribute>
                        </path>
                        <xsl:choose>
                            <xsl:when test="ancestor::yes/type/integral">
                                <path>
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="$certainty"/>
                                        <xsl:with-param name="type" select="'4'"/>
                                    </xsl:call-template>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$baseline + 10"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ax + 16"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ax + 140"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"
                                        />
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                            <xsl:otherwise>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="$certainty"/>
                                        <xsl:with-param name="type" select="'4'"/>
                                    </xsl:call-template>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ax + 140"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ax + $delta + 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of
                                            select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$baseline + 10"/>
                                    </xsl:attribute>
                                </path>
                            </xsl:otherwise>
                        </xsl:choose>
                    </g>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <g xmlns="http://www.w3.org/2000/svg">
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + $delta + 10"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                                    <xsl:text>&#32;A</xsl:text>
                                    <xsl:value-of
                                        select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="1"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$baseline + 10"/>
                                </xsl:attribute>
                            </path>
                            <xsl:choose>
                                <xsl:when test="ancestor::yes/type/integral">
                                    <path>
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="$certainty"/>
                                            <xsl:with-param name="type" select="'4'"/>
                                        </xsl:call-template>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of
                                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$baseline + 10"/>
                                            <xsl:text>&#32;Q</xsl:text>
                                            <xsl:value-of
                                                select="$Ax - $delta * (count(following-sibling::component)) - 2"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - 2 - $delta * (count(following-sibling::component))"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="$Ax + 16"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - 2 - $delta * (count(following-sibling::component))"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ax + 140"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - 2 - $delta * (count(following-sibling::component))"
                                            />
                                        </xsl:attribute>
                                    </path>
                                </xsl:when>
                                <xsl:otherwise>
                                    <path xmlns="http://www.w3.org/2000/svg">
                                        <xsl:call-template name="certainty">
                                            <xsl:with-param name="certainty" select="$certainty"/>
                                            <xsl:with-param name="type" select="'4'"/>
                                        </xsl:call-template>
                                        <xsl:attribute name="d">
                                            <xsl:text>M</xsl:text>
                                            <xsl:value-of select="$Ax + 140"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) - 1"/>
                                            <xsl:text>&#32;L</xsl:text>
                                            <xsl:value-of select="$Ax + $delta + 10"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) - 1"/>
                                            <xsl:text>&#32;A</xsl:text>
                                            <xsl:value-of
                                                select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of
                                                select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="0"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of select="0"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="0"/>
                                            <xsl:text>&#32;</xsl:text>
                                            <xsl:value-of
                                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 1"/>
                                            <xsl:text>,</xsl:text>
                                            <xsl:value-of select="$baseline + 10"/>
                                        </xsl:attribute>
                                    </path>
                                </xsl:otherwise>
                            </xsl:choose>
                        </g>
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:call-template name="certainty">
                                <xsl:with-param name="certainty" select="50"/>
                                <xsl:with-param name="type" select="'3'"/>
                            </xsl:call-template>
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent)"/>
                                <xsl:text>&#32;Q</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"
                                />
                            </xsl:attribute>
                        </path>
                    </g>
                </xsl:when>
                <xsl:otherwise>
                    <g xmlns="http://www.w3.org/2000/svg">
                        <path xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="d">
                                <xsl:text>M</xsl:text>
                                <xsl:value-of
                                    select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;L</xsl:text>
                                <xsl:value-of select="$Ax + $delta + 10"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                                <xsl:text>&#32;A</xsl:text>
                                <xsl:value-of
                                    select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of
                                    select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of select="0"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="1"/>
                                <xsl:text>&#32;</xsl:text>
                                <xsl:value-of
                                    select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="$baseline + 10"/>
                            </xsl:attribute>
                        </path>
                        <xsl:choose>
                            <xsl:when test="ancestor::yes/type/integral">
                                <path>
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="$certainty"/>
                                        <xsl:with-param name="type" select="'4'"/>
                                    </xsl:call-template>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$baseline + 10"/>
                                        <xsl:text>&#32;Q</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="$Ax + 16"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ax + 140"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"
                                        />
                                    </xsl:attribute>
                                </path>
                            </xsl:when>
                            <xsl:otherwise>
                                <path xmlns="http://www.w3.org/2000/svg">
                                    <xsl:call-template name="certainty">
                                        <xsl:with-param name="certainty" select="$certainty"/>
                                        <xsl:with-param name="type" select="'4'"/>
                                    </xsl:call-template>
                                    <xsl:attribute name="d">
                                        <xsl:text>M</xsl:text>
                                        <xsl:value-of select="$Ax + 140"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                        <xsl:text>&#32;L</xsl:text>
                                        <xsl:value-of select="$Ax + $delta + 10"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                        <xsl:text>&#32;A</xsl:text>
                                        <xsl:value-of
                                            select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="0"/>
                                        <xsl:text>&#32;</xsl:text>
                                        <xsl:value-of
                                            select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of select="$baseline + 10"/>
                                    </xsl:attribute>
                                </path>
                            </xsl:otherwise>
                        </xsl:choose>
                    </g>
                </xsl:otherwise>
            </xsl:choose>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <!-- GOOD -->
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline + ($delta * $countComponents) - ($delta * $currentComponent) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-TextHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="certainty" select="100"/>
        <desc xmlns="http://www.w3.org/2000/svg">Text-hook</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:choose>
                <xsl:when test="./type/hook/double/yes">                    
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + $delta + 10"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta) + 0.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline + 10"/>
                        </xsl:attribute>
                    </path>
                    <xsl:choose>
                        <xsl:when test="ancestor::yes/type/integral">
                            <path>
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="type" select="'4'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$baseline + 10"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$B1y + $delta"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$B1x + 130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$B1y + $delta"/>
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="type" select="'4'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$baseline + 10"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) - 2"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$B1y + $delta"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$B1x + 130"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$B1y + $delta"/>
                                </xsl:attribute>
                            </path>                            
                        </xsl:otherwise>
                    </xsl:choose>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + $delta + 10"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline + 10"/>
                        </xsl:attribute>
                    </path>
                    <xsl:choose>
                        <xsl:when test="ancestor::yes/type/integral">
                            <path>
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="type" select="'4'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$baseline + 10"/>
                                    <xsl:text>&#32;Q</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - $delta * (count(following-sibling::component))"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="$Ax + 16"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + 140"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="($baseline - ($delta * ancestor::yes/type/integral/numberOfLeaves) - $delta) - $delta * (count(following-sibling::component))"
                                    />
                                </xsl:attribute>
                            </path>
                        </xsl:when>
                        <xsl:otherwise>
                            <path xmlns="http://www.w3.org/2000/svg">
                                <xsl:call-template name="certainty">
                                    <xsl:with-param name="certainty" select="$certainty"/>
                                    <xsl:with-param name="type" select="'4'"/>
                                </xsl:call-template>
                                <xsl:attribute name="d">
                                    <xsl:text>M</xsl:text>
                                    <xsl:value-of select="$Ax + 140"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                    <xsl:text>&#32;L</xsl:text>
                                    <xsl:value-of select="$Ax + $delta + 10"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$baseline - ($delta + ($delta * $countComponents) - ($delta * $currentComponent)) + 1"/>
                                    <xsl:text>&#32;A</xsl:text>
                                    <xsl:value-of
                                        select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of
                                        select="$delta + 10 + (count(following-sibling::component) * $delta) - 1.5"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="0"/>
                                    <xsl:text>&#32;</xsl:text>
                                    <xsl:value-of
                                        select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta) + 1"/>
                                    <xsl:text>,</xsl:text>
                                    <xsl:value-of select="$baseline + 10"/>
                                </xsl:attribute>
                            </path>
                        </xsl:otherwise>
                    </xsl:choose>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="50"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) + 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax + (2 * $delta) + ($delta * $countComponents) + 2"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent) - 1"
                            />
                        </xsl:attribute>
                    </path>
                </xsl:when>
                <xsl:otherwise>
                    <path xmlns="http://www.w3.org/2000/svg">
                        <xsl:call-template name="certainty">
                            <xsl:with-param name="certainty" select="$certainty"/>
                            <xsl:with-param name="type" select="'4'"/>
                        </xsl:call-template>
                        <xsl:attribute name="d">
                            <xsl:text>M</xsl:text>
                            <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;L</xsl:text>
                            <xsl:value-of select="$Ax + $delta + 10"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$baseline + $delta + 20 + ($delta * $countComponents) - ($delta * $currentComponent)"/>
                            <xsl:text>&#32;A</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of
                                select="$delta + 10 + (count(following-sibling::component) * $delta)"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="0"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="1"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of
                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$baseline + 10"/>
                            <xsl:text>&#32;Q</xsl:text>
                            <xsl:value-of
                                select="$Ax - ($delta * $countComponents) + $delta - 1 + (count(preceding-sibling::component) * $delta)"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y + $delta"/>
                            <xsl:text>&#32;</xsl:text>
                            <xsl:value-of select="$B1x + 130"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="$B1y + $delta"/>
                        </xsl:attribute>
                    </path>
                </xsl:otherwise>
            </xsl:choose>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline + ($delta * $countComponents) - ($delta * $currentComponent) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaves-OutsideHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="certainty"/>
        <desc xmlns="http://www.w3.org/2000/svg">Outside hook</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
            <path>
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="$certainty"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of
                        select="$Ax + ($delta * $countComponents) - 2 - ($delta - 1 + (count(following-sibling::component) * $delta))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-OutsideHook">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path for the flyleaf</desc>
            <path>
                <!-- Because the schema does not go down to the element level and does not allow for each part of the endleaf 
                    to be pasted as pastedown, this flyleaf id drawn as uncertain to accommodate for the possibility that it 
                    was actually a pastedown as it is common in Dutch bindings -->
                <xsl:call-template name="certainty">
                    <xsl:with-param name="certainty" select="50"/>
                    <xsl:with-param name="type" select="'4'"/>
                </xsl:call-template>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Dx"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;Q</xsl:text>
                    <xsl:value-of select="$Ax - 2 + ($delta * count(preceding-sibling::component))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$B1x + 130"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$B1y"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline"
                select="if (attachment/glued) then $baseline - ($delta * $currentComponent) + ($delta) else $baseline"
            />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="componentAttachment">
        <xsl:param name="use" select="false()" as="xs:boolean"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100"/>
        <xsl:param name="onlySewn" select="'no'"/>
        <!-- Only draw the sewn attachment and not the glued option for single leaves and all units but textHook if there is a integral pastedown -->
        <xsl:variable name="onlySewn"
            select="if (($onlySewn eq 'yes') or 
            (ancestor::yes/type/integral/pastedown/yes and boolean(not(type/hook/type[textHook]))
            )) then 'yes' else 'no'"/>
        <xsl:variable name="rotation"
            select="if (boolean(
            (pastedown/yes and $use eq false() and $countComponents le 3) 
            or (following-sibling::component/pastedown/yes  and $use eq false() and $countComponents le 3) 
            or (preceding-sibling::component/pastedown/yes  and $use eq false() and $countComponents le 3)
            )) then 45 else 0"/>
        <xsl:choose>
            <xsl:when test="./attachment[sewn]">
                <desc xmlns="http://www.w3.org/2000/svg">Sewn component</desc>
                <xsl:choose>
                    <xsl:when test="./type/hook/type[textHook]">
                        <xsl:call-template name="sewnComponent-textHook">
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./type/hook/type[endleafHook]">
                        <xsl:call-template name="sewnComponent-endleafHook">
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="rotation" select="$rotation"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="sewnComponent">
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="baseline" select="$baseline"/>
                            <xsl:with-param name="rotation" select="$rotation"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="./attachment[glued]">
                <desc xmlns="http://www.w3.org/2000/svg">Glued component</desc>
                <xsl:choose>
                    <xsl:when test="./type/hook/type[textHook]">
                        <xsl:call-template name="gluedComponent-textHook">
                            <xsl:with-param name="baseline" select="$baseline"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$onlySewn eq 'no'">
                                <!-- Only draw the sewn attachment and not the glued option for single leaves and all units but textHook if there is a integral pastedown -->
                                <xsl:call-template name="gluedComponent">
                                    <xsl:with-param name="baseline" select="$baseline"/>
                                    <xsl:with-param name="certainty" select="$certainty"
                                        as="xs:integer"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Attachment method not checked, not known,
                    or other</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewnComponent">
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <xsl:param name="rotation" select="0"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>thread</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>rotate(</xsl:text>
                    <xsl:value-of select="-$rotation"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax - ($delta * 1.5)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="sewnComponent-endleafHook">
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <xsl:param name="rotation" select="0"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>thread</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="transform">
                    <xsl:text>rotate(</xsl:text>
                    <xsl:value-of select="-$rotation"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax - ($delta * 1.2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="sewnComponent-textHook">
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>thread</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + $delta + 10 - 3"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline + 10"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax - ($delta * 2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline + 10"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="gluedComponent">
        <xsl:param name="baseline"/>
        <xsl:param name="certainty" select="100"/>
        <xsl:variable name="componentID" select="generate-id()"/>
        <mask xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="id">
                <xsl:value-of select="concat('fademask', $componentID)"/>
            </xsl:attribute>
            <rect>
                <xsl:attribute name="width">
                    <xsl:value-of select="$delta * 2.5"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="$delta"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Ax + ($delta div 2)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$baseline - $delta "/>
                </xsl:attribute>
                <xsl:attribute name="fill">
                    <xsl:text>url(#radialFading)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="stroke-opacity">
                    <xsl:value-of select="0.0"/>
                </xsl:attribute>
            </rect>
        </mask>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:call-template name="certainty">
                <xsl:with-param name="certainty" select="$certainty"/>
                <xsl:with-param name="type" select="'4'"/>
            </xsl:call-template>
            <rect>
                <xsl:attribute name="width">
                    <xsl:value-of select="$delta * 2.5"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="$delta"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Ax + ($delta div 2)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$baseline - $delta "/>
                </xsl:attribute>
                <xsl:attribute name="fill">
                    <xsl:text>url(#gluedPattern2)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="stroke-opacity">
                    <xsl:value-of select="0.0"/>
                </xsl:attribute>
                <xsl:attribute name="mask">
                    <xsl:value-of select="concat('url(#fademask', $componentID, ')')"/>
                </xsl:attribute>
            </rect>
        </g>
    </xsl:template>

    <xsl:template name="gluedComponent-textHook">
        <xsl:param name="baseline"/>
        <xsl:variable name="componentID" select="generate-id()"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <desc xmlns="http://www.w3.org/2000/svg">
                <xsl:text>Glued component - textHook</xsl:text>
            </desc>
            <mask xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="id">
                    <xsl:value-of select="concat('fademask', $componentID)"/>
                </xsl:attribute>
                <rect xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="width">
                        <xsl:value-of select="$delta * 2.5"/>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of select="$delta"/>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ax + 1.5*($delta)"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$baseline + 20 "/>
                    </xsl:attribute>
                    <xsl:attribute name="fill">
                        <xsl:text>url(#radialFading)</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="stroke-opacity">
                        <xsl:value-of select="0.0"/>
                    </xsl:attribute>
                </rect>
            </mask>
            <rect xmlns="http://www.w3.org/2000/svg">
                <xsl:attribute name="width">
                    <xsl:value-of select="$delta * 2.5"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="$delta"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="$Ax + 1.5*($delta)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$baseline + 20 "/>
                </xsl:attribute>
                <xsl:attribute name="fill">
                    <xsl:text>url(#gluedPattern2)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="stroke-opacity">
                    <xsl:value-of select="0.0"/>
                </xsl:attribute>
                <xsl:attribute name="mask">
                    <xsl:value-of select="concat('url(#fademask', $componentID, ')')"/>
                </xsl:attribute>
            </rect>
        </g>
    </xsl:template>


    <!-- Titling -->
    <xsl:template name="title">
        <xsl:param name="detected" as="xs:integer" select="1"/>
        <xsl:param name="side" select="'left'"/>
        <xsl:param name="use" select="'use'"/>
        <text xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>titleText</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="x">
                <xsl:value-of select="$Ax"/>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:value-of select="$Oy + 5"/>
            </xsl:attribute>
            <xsl:value-of select="$shelfmark"/>
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="$detected eq 0">
                    <xsl:text>endleaves not detected</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(upper-case(substring($side,1,1)),
                        substring($side, 2),
                        ' '[not(last())]
                        )"/>
                    <xsl:text> endleaves (</xsl:text>
                    <xsl:value-of
                        select="concat(upper-case(substring($use,1,1)),
                        substring($use, 2),
                        ' '[not(last())]
                        )"/>
                    <xsl:text>)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>            
        </text>
    </xsl:template>

    <!-- Description -->
    <xsl:template name="description">
        <xsl:param name="baseline"/>
        <xsl:param name="unknown"/>
        <xsl:variable name="baseline" select="$baseline - 10"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <xsl:attribute name="class">
                <xsl:text>descText</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="no | NC | NK | other">
                    <text xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$baseline"/>
                        </xsl:attribute>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:choose>
                                <xsl:when test="no">
                                    <xsl:text>There are no endleaves</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Endleaves not described</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tspan>
                    </text>
                </xsl:when>
                <xsl:when test="$unknown eq 'other'">
                    <text xmlns="http://www.w3.org/2000/svg">
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox + 20"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$baseline"/>
                        </xsl:attribute>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:value-of select="./yes/type/other/text()"/>
                        </tspan>
                    </text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$unknown"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="yes/type">
                <xsl:variable name="position" select="position()"/>
                <text xmlns="http://www.w3.org/2000/svg">
                    <xsl:attribute name="x">
                        <xsl:value-of select="$Ox + 20"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                        <xsl:value-of select="$baseline"/>
                    </xsl:attribute>
                    <xsl:for-each select="separate">
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="dy">
                                <xsl:value-of select="0 + 6 * ($position - 1)"/>
                            </xsl:attribute>
                            <xsl:text>Separate endleaves: </xsl:text>
                            <xsl:for-each select="units/unit">
                                <xsl:variable name="position" select="position()"/>
                                <tspan xmlns="http://www.w3.org/2000/svg">
                                    <xsl:attribute name="x">
                                        <xsl:value-of select="$Ox + 80"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="dy">
                                        <xsl:value-of select="if ($position eq 1) then 0 else 7"/>
                                    </xsl:attribute>
                                    <xsl:text>unit </xsl:text>
                                    <xsl:value-of select="position()"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:for-each select="components/component">
                                        <xsl:variable name="position" select="position()"/>
                                        <tspan xmlns="http://www.w3.org/2000/svg">
                                            <xsl:attribute name="x">
                                                <xsl:attribute name="x">
                                                  <xsl:value-of select="$Ox + 100"/>
                                                </xsl:attribute>
                                            </xsl:attribute>
                                            <xsl:attribute name="dy">
                                                <xsl:value-of
                                                  select="if ($position eq 1) then 0 else 7"/>
                                            </xsl:attribute>
                                            <xsl:text>component </xsl:text>
                                            <xsl:value-of select="position()"/>
                                            <xsl:text>: </xsl:text>
                                            <tspan xmlns="http://www.w3.org/2000/svg">
                                                <xsl:attribute name="dx">
                                                  <xsl:text>2pt</xsl:text>
                                                </xsl:attribute>
                                                <xsl:choose>
                                                  <xsl:when test="type/hook">
                                                  <xsl:value-of
                                                  select="type/hook/type/node()/name()"/>
                                                  <xsl:choose>
                                                  <xsl:when test="type/hook/node()/double/yes">
                                                  <xsl:text> double</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:when test="type[NC | NK | other]">
                                                  <xsl:text>type </xsl:text>
                                                  <xsl:choose>
                                                  <xsl:when test="type/NC">
                                                  <xsl:text>not checked</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="type/NK">
                                                  <xsl:text>not known</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="type/other">
                                                  <xsl:text>other</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="type/node()/name()"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text> (</xsl:text>
                                                <xsl:choose>
                                                  <xsl:when test="pastedown/yes">
                                                  <xsl:text> pastedown, </xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="pastedown[NC | NK | other]">
                                                  <xsl:text> pastedown: </xsl:text>
                                                  <xsl:value-of select="pastedown/node()/name()"/>
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:when>
                                                </xsl:choose>
                                                <xsl:choose>
                                                  <xsl:when test="material[NC | NK | other]">
                                                  <xsl:text>material: </xsl:text>
                                                  <xsl:choose>
                                                  <xsl:when test="material/NC">
                                                  <xsl:text>not checked</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="material/NK">
                                                  <xsl:text>not known</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="material/other">
                                                  <xsl:value-of select="material/other/text()"/>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="material/node()/name()"/>
                                                  <tspan xmlns="http://www.w3.org/2000/svg"
                                                  dx="-1pt">
                                                  <xsl:text>, </xsl:text>
                                                  </tspan>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:choose>
                                                  <xsl:when test="attachment[NC | NK | other]">
                                                  <xsl:text>attachment: </xsl:text>
                                                  <xsl:choose>
                                                  <xsl:when test="attachment/NC">
                                                  <xsl:text>not checked</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="attachment/NK">
                                                  <xsl:text>not known</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="attachment/other">
                                                  <xsl:value-of select="attachment/other/text()"/>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="attachment/node()/name()"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <tspan xmlns="http://www.w3.org/2000/svg" dx="0pt">
                                                  <xsl:text>)</xsl:text>
                                                </tspan>
                                            </tspan>
                                        </tspan>
                                    </xsl:for-each>
                                </tspan>
                            </xsl:for-each>
                        </tspan>
                    </xsl:for-each>
                    <xsl:for-each select="integral">
                        <xsl:variable name="position"
                            select="if ($position eq 1) then 1 else 1.5 + count(parent::type/preceding-sibling::type/separate/units/unit/components/component)"/>
                        <tspan xmlns="http://www.w3.org/2000/svg">
                            <xsl:attribute name="dy">
                                <xsl:value-of select="concat(0 + 6 * ($position - 1), 'pt')"/>
                            </xsl:attribute>
                            <xsl:text>Integral endleaves: </xsl:text>
                            <tspan xmlns="http://www.w3.org/2000/svg">
                                <xsl:attribute name="x">
                                    <xsl:value-of select="$Ox + 80"/>
                                </xsl:attribute>
                                <xsl:value-of select="numberOfLeaves"/>
                                <xsl:choose>
                                    <xsl:when test="xs:integer(numberOfLeaves) gt 1">
                                        <xsl:text> leaves</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text> leaf</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="pastedown/yes">
                                        <xsl:text> (pastedown)</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </tspan>
                        </tspan>
                    </xsl:for-each>
                </text>
            </xsl:for-each>
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