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
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenameLeft"
        select="concat('../../Transformations/Endleaves/SVGoutput/', $fileref[1], '_', 'leftEndleaves', '.svg')"/>
    <xsl:variable name="filenameRight"
        select="concat('../../Transformations/Endleaves/SVGoutput/', $fileref[1], '_', 'rightEndleaves', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="Ox" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="Oy" select="$Ox"/>

    <!-- X and Y values to place the outermost gathering for both left and right endleaves -->
    <xsl:variable name="Ax" select="$Ox + 155"/>
    <xsl:variable name="Ay" select="$Oy + 90"/>

    <!-- Value to determine the Y value of distance between the different components of the endleaves-->
    <xsl:variable name="delta" select="6"/>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/endleaves/left">
            <xsl:result-document href="{$filenameLeft}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../GitHub/Transformations/Endleaves/CSS/style.css"&#32;</xsl:text>
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
                    <title>Left endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                    <xsl:copy-of
                        select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc xmlns="http://www.w3.org/2000/svg">Left endleaves</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ox"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Oy"/>
                        </xsl:attribute>
                        <xsl:call-template name="leftEndleaves"/>
                    </svg>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
        <xsl:for-each select="book/endleaves/right">
            <xsl:result-document href="{$filenameRight}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>href="../../../GitHub/Transformations/Endleaves/CSS/style.css"&#32;</xsl:text>
                    <xsl:text>type="text/css"</xsl:text>
                </xsl:processing-instruction>
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                    version="1.1" x="0" y="0" width="297mm" height="210mm" viewBox="0 0 297 210"
                    preserveAspectRatio="xMidYMid meet">
                    <title>Right endleaves of book: <xsl:value-of select="$shelfmark"/></title>
                    <xsl:copy-of
                        select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <g transform="scale(-1 1)">
                        <desc>Right endleaves</desc>
                        <svg>
                            <xsl:attribute name="x">
                                <xsl:value-of select="$Ox - 305"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="$Oy"/>
                            </xsl:attribute>
                            <xsl:call-template name="leftEndleaves"/>
                        </svg>
                    </g>
                </svg>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="leftEndleaves">
        <xsl:choose>
            <xsl:when test="self::node()[yes | no]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <use xlink:href="#outermostGL">
                        <xsl:attribute name="x">
                            <xsl:value-of select="$Ax"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$Ay"/>
                        </xsl:attribute>
                    </use>
                </g>
                <xsl:choose>
                    <xsl:when test="./yes/type[integral]">
                        <xsl:call-template name="leftEndleavesIntegral"/>
                    </xsl:when>
                    <xsl:when test="./yes/type[separate]">
                        <xsl:call-template name="leftEndleavesSeparate"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Type of endleaves not checked, not
                            known, or other</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- NB: is there an otherwise?? -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral">
        <desc xmlns="http://www.w3.org/2000/svg">integral endleaves</desc>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparate">
        <desc xmlns="http://www.w3.org/2000/svg">Separate endleaves</desc>
        <xsl:for-each select="./yes/type/separate/units/unit">
            <!-- Variable to count the number of Units -->
            <xsl:variable name="countUnits" select="last()"/>
            <!-- Counter variable for the current unit -->
            <xsl:variable name="currentUnit" select="position()"/>
            <desc xmlns="http://www.w3.org/2000/svg">Unit N. <xsl:value-of select="$currentUnit"
                /></desc>
            <xsl:call-template name="leftEndleavesSeparate_components">
                <xsl:with-param name="countUnits" select="$countUnits"/>
                <xsl:with-param name="currentUnit" select="$currentUnit"/>
                <!-- if the units need to be separated more than then delta, subtract 1 or nothing from delta in its last occurrence -->
                <xsl:with-param name="baseline" select="$Ay - ($delta * 2 * count(following-sibling::unit/components/component) + (($delta - 2) * count(following-sibling::unit)))"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparate_components">
        <xsl:param name="countUnits"/>
        <xsl:param name="currentUnit"/>
        <xsl:param name="baseline"/>
        <xsl:for-each select="./components/component">
            <!-- Variable to count the number of Components -->
            <xsl:variable name="countComponents" select="last()"/>
            <!-- Counter variable for the current component -->
            <xsl:variable name="currentComponent" select="position()"/>
            <!-- Variable to select what kind of material the component is made of -->
            <xsl:variable name="componentMaterial" select="./material/node()/name()"/>
            <desc xmlns="http://www.w3.org/2000/svg">Component N. <xsl:value-of
                    select="$currentComponent"/></desc>
            <xsl:choose>
                <xsl:when test="./pastedown[yes]">
                    <desc xmlns="http://www.w3.org/2000/svg">Pastedown</desc>
                    <xsl:call-template name="leftEndleavesSeparatePastedown">
                        <xsl:with-param name="countComponents" select="$countComponents"/>
                        <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        <xsl:with-param name="baseline" select="$baseline"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="./pastedown[no]">
                    <desc xmlns="http://www.w3.org/2000/svg">Flyleaves</desc>
                    <xsl:call-template name="leftEndleavesSeparateFlyleaves">
                        <xsl:with-param name="baseline" select="$baseline"/>
                        <xsl:with-param name="countComponents" select="$countComponents"/>
                        <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <desc xmlns="http://www.w3.org/2000/svg">Type of endleaf component not checked,
                        not known, or other</desc>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="leftEndleavesSeparateFlyleaves">
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-Fold">
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[guard]">
                <desc xmlns="http://www.w3.org/2000/svg">Type guard</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-Guard">
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[hook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type hook</desc>
            </xsl:when>
            <xsl:when test="./type[outsideHook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type outside hook</desc>
            </xsl:when>
            <xsl:when test="./type[singleLeaf]">
                <desc xmlns="http://www.w3.org/2000/svg">Type single leaf</desc>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other
                    type</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaves-Fold">
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <desc xmlns="http://www.w3.org/2000/svg">Folded flyleaves</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
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
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + 140"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline" select="$baseline"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown">
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="B1x" select="$Ax - 145"/>
        <xsl:variable name="B1y" select="$baseline - (2* $delta * $countComponents) - ($delta * count(preceding-sibling::component))"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <use xlink:href="#pastedown">
                <xsl:attribute name="x">
                    <xsl:value-of select="$B1x"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$B1y"/>
                </xsl:attribute>
            </use>
        </g>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparatePastedown-Fold">
                    <xsl:with-param name="B1x" select="$B1x"/>
                    <xsl:with-param name="B1y" select="$B1y"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./type[guard]">
                <desc xmlns="http://www.w3.org/2000/svg">Type guard</desc>
            </xsl:when>
            <xsl:when test="./type[hook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type hook</desc>
            </xsl:when>
            <xsl:when test="./type[outsideHook]">
                <desc xmlns="http://www.w3.org/2000/svg">Type outside hook</desc>
            </xsl:when>
            <xsl:when test="./type[singleLeaf]">
                <desc xmlns="http://www.w3.org/2000/svg">Type single leaf</desc>
                <!-- NB: No Template is called as the pastedown is automatically drawn when its presence has been registered -->
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other
                    type</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-Fold">
        <xsl:param name="B1x"/>
        <xsl:param name="B1y"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:param name="baseline"/>
        <xsl:variable name="Dx" select="$Ax + ($delta * $countComponents) - 2"/>
        <xsl:variable name="Dy" select="$baseline - ($delta * $currentComponent)"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
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
        <g xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M&#32;</xsl:text>
                    <xsl:value-of select="$Dx"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$Dy"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
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
                    <xsl:text>&#32;Q&#32;</xsl:text>
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
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline" select="$baseline"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="leftEndleavesSeparateFlyleaves-Guard">
        <xsl:param name="baseline"/>
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <desc xmlns="http://www.w3.org/2000/svg">Flyleaf guard</desc>
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>line</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $currentComponent)"/>
                    <xsl:text>&#32;A</xsl:text>
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$delta - 1 + (count(following-sibling::component) * $delta)"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="0"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 2"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                    <xsl:text>&#32;L</xsl:text>
                    <xsl:value-of select="$Ax + (2 * $delta) + ($delta * $countComponents)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($baseline - ($delta * $currentComponent)) - (2 * ($delta - 1 + (count(following-sibling::component) * $delta)))"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="countComponents" select="$countComponents"/>
            <xsl:with-param name="baseline" select="$baseline"/>
        </xsl:call-template>
    </xsl:template>
        

    <xsl:template name="componentAttachment">
        <xsl:param name="countComponents"/>
        <xsl:param name="baseline"/>
        <xsl:choose>
            <xsl:when test="./attachment[sewn]">
                <desc xmlns="http://www.w3.org/2000/svg">Sewn component</desc>
                <xsl:call-template name="sewnComponent">
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./attachment[glued]">
                <desc xmlns="http://www.w3.org/2000/svg">Glued component</desc>
                <xsl:call-template name="gluedComponent">
                    <xsl:with-param name="baseline" select="$baseline"/>
                </xsl:call-template>
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
        <g xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="class">
                    <xsl:text>thread</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="d">
                    <xsl:text>M&#32;</xsl:text>
                    <xsl:value-of select="$Ax + ($delta * $countComponents) - 3"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                    <xsl:text>&#32;L&#32;</xsl:text>
                    <xsl:value-of select="$Ax - ($delta * 1.2)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$baseline - ($delta * $countComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <xsl:template name="gluedComponent">
        <xsl:param name="baseline"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <rect>
                <xsl:attribute name="width">
                    <xsl:value-of select="$delta * 1.5"/>
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
            </rect>
        </g>
    </xsl:template>

</xsl:stylesheet>
