<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:lig="http://www.ligatus.org.uk/stcatherines/sites/ligatus.org.uk.stcatherines/files/basic-1.8_0.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs svg xlink lig"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" standalone="no"
        xpath-default-namespace="http://www.w3.org/2000/svg" exclude-result-prefixes="xlink"
        include-content-type="no" />

    <xsl:variable name="shelfmark" select="//bibliographical/shelfmark"/>
    <xsl:variable name="fileref" select="tokenize($shelfmark, '\.')"/>
    <xsl:variable name="filenameLeft"
        select="concat('../../Transformations/Endleaves/SVGoutput/', $fileref[1], '_', 'leftEndleaves', '.svg')"/>
    <xsl:variable name="filenameRight"
        select="concat('../../Transformations/Endleaves/SVGoutput/', $fileref[1], '_', 'rightEndleaves', '.svg')"/>

    <!-- X and Y reference values - i.e. the registration for the whole diagram, changing these values, the whole diagram can be moved -->
    <xsl:param name="referenceXvalue" select="0"/>
    <!-- N.B.: The reference value for Y is the same as the reference value for X -->
    <xsl:param name="referenceYvalue" select="$referenceXvalue"/>

    <!-- X and Y values to place the outermost gathering for both left and right endleaves -->
    <xsl:variable name="XoutermostG" select="$referenceXvalue + 155"/>
    <xsl:variable name="YoutermostG" select="$referenceYvalue + 90"/>

    <!-- Value to determine the Y value of distance between the different components of the endleaves-->
    <xsl:variable name="deltaFlyleaves" select="6"/>

    <xsl:template name="main" match="/">
        <xsl:for-each select="book/endleaves/left">
            <xsl:result-document href="{$filenameLeft}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0" y="0"
                    width="297mm" height="210mm" viewBox="0 0 297 210" preserveAspectRatio="xMinYMin meet">
                    <desc>Left endleaves of book: <xsl:value-of select="$shelfmark"/></desc>
                    <xsl:copy-of
                        select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc  xmlns="http://www.w3.org/2000/svg">Left endleaves</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$referenceXvalue"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$referenceYvalue"/>
                        </xsl:attribute>
                        <xsl:call-template name="leftEndleaves"/>
                    </svg>
                </svg>
<!--                <xsl:element name="svg" xpath-default-namespace="http://www.w3.org/2000/svg">
                    <xsl:attribute name="width">100%</xsl:attribute>
                    <xsl:attribute name="height">100%</xsl:attribute>
                    <xsl:element name="desc">
                        <xsl:text>Left endleaves of book: </xsl:text>
                        <xsl:value-of select="$shelfmark"/>
                    </xsl:element>
                    <xsl:copy-of
                        select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg" copy-namespaces="no"/>
                    <desc>Left endleaves</desc>
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$referenceXvalue"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$referenceYvalue"/>
                        </xsl:attribute>
                        <xsl:call-template name="leftEndleaves"/>
                    </svg>
                </xsl:element>
-->            </xsl:result-document>
        </xsl:for-each>
        <xsl:for-each select="book/endleaves/right">
            <xsl:result-document href="{$filenameRight}" method="xml" indent="yes" encoding="utf-8"
                doctype-public="-//W3C//DTD SVG 1.1//EN"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0" y="0"
                    width="297mm" height="210mm" viewBox="0 0 297 210" preserveAspectRatio="xMinYMin meet">
                    <desc>Right endleaves of book: <xsl:value-of select="$shelfmark"/></desc>
                    <xsl:copy-of
                        select="document('../SVGmaster/EndleavesSVGmaster.svg')/svg:svg/svg:defs"
                        xpath-default-namespace="http://www.w3.org/2000/svg"/>
                    <g transform="scale(-1 1)">
                        <desc>Right endleaves</desc>
                        <svg>
                            <xsl:attribute name="x">
                                <xsl:value-of select="$referenceXvalue - 305"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="$referenceYvalue"/>
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
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$XoutermostG"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="$YoutermostG"/>
                        </xsl:attribute>
                        <use xlink:href="#outermostGL"/>
                    </svg>
                </g>
                <xsl:choose>
                    <xsl:when test="./yes/type[integral]">
                        <xsl:call-template name="leftEndleavesIntegral"/>
                    </xsl:when>
                    <xsl:when test="./yes/type[separate]">
                        <xsl:call-template name="leftEndleavesSeparate"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc  xmlns="http://www.w3.org/2000/svg">Type of endleaves not checked, not known, or other</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!--            <xsl:when test="book/endleaves/left[no]">
                <g xmlns="http://www.w3.org/2000/svg">
                    <svg>
                        <!-\- TODO: select a good value for X and Y coordinates -\->
                        <xsl:attribute name="x">
                            <xsl:value-of select="100"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of select="100"/>
                        </xsl:attribute>
                        <use xlink:href="#outermostGL"/>
                    </svg>
                </g>
            </xsl:when>-->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesIntegral">
        <desc  xmlns="http://www.w3.org/2000/svg">integral endleaves</desc>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparate">
        <desc xmlns="http://www.w3.org/2000/svg">Separate endleaves</desc>
        <xsl:for-each select="./yes/type/separate/units/unit">
            <!-- Variable to count the number of Units -->
            <xsl:variable name="countUnits" select="last()"/>
            <!-- Counter variable for the current unit -->
            <xsl:variable name="currentUnit" select="position()"/>
            <desc xmlns="http://www.w3.org/2000/svg">Unit N. <xsl:value-of select="$currentUnit"/></desc>
            <xsl:for-each select="./components/component">
                <!-- Variable to count the number of Components -->
                <xsl:variable name="countComponents" select="last()"/>
                <!-- Counter variable for the current component -->
                <xsl:variable name="currentComponent" select="position()"/>
                <!-- Variable to select what kind of material the component is made of -->
                <xsl:variable name="componentMaterial" select="./material/node()/name()"/>
                <desc xmlns="http://www.w3.org/2000/svg">Component N. <xsl:value-of select="$currentComponent"/></desc>
                <xsl:choose>
                    <xsl:when test="./pastedown[yes]">
                        <desc xmlns="http://www.w3.org/2000/svg">Pastedown</desc>
                        <xsl:call-template name="leftEndleavesSeparatePastedown">
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xmlns="http://www.w3.org/2000/svg">Flyleaves</desc>
                        <xsl:call-template name="leftEndleavesSeparateFlyleaves">
                            <xsl:with-param name="countComponents" select="$countComponents"/>
                            <xsl:with-param name="currentComponent" select="$currentComponent"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaves">
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparateFlyleaves-Fold">
                    <xsl:with-param name="countComponents" select="$countComponents"/>
                    <xsl:with-param name="currentComponent" select="$currentComponent"/>
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
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other type</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparateFlyleaves-Fold">
        <xsl:param name="countComponents"/>
        <xsl:param name="currentComponent"/>
        <xsl:choose>
            <xsl:when test="$countComponents = 1">
                <!-- TODO -->
                <!-- TODO: Call modified folded flyleaves to be as long as outemost gathering -->
                <!-- TODO  -->
                <desc xmlns="http://www.w3.org/2000/svg">Folded flyleaves</desc>
            </xsl:when>
            <xsl:when test="$countComponents > 1">
                <desc xmlns="http://www.w3.org/2000/svg">Folded flyleaves</desc>
                <g xmlns="http://www.w3.org/2000/svg">
                    <svg>
                        <xsl:attribute name="x">
                            <xsl:value-of select="$XoutermostG"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">
                            <xsl:value-of
                                select="$YoutermostG - ($deltaFlyleaves * $currentComponent) - 10"/>
                        </xsl:attribute>
                        <use xlink:href="#foldedFlyleaf"/>
                    </svg>
                </g>
                <xsl:call-template name="componentAttachment">
                    <xsl:with-param name="XsewnComponent"
                        select="$XoutermostG + ($deltaFlyleaves * 1.5)"/>
                    <xsl:with-param name="CountComponents" select="$countComponents"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown">
        <xsl:param name="countComponents"/>
        <xsl:variable name="pastedownRegistrationX" select="$XoutermostG - 145"/>
        <xsl:variable name="pastedownRegistrationY"
            select="$YoutermostG - ($deltaFlyleaves * ($countComponents * 2))"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <svg>
                <xsl:attribute name="x">
                    <xsl:value-of select="$pastedownRegistrationX"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$pastedownRegistrationY"/>
                </xsl:attribute>
                <use xlink:href="#pastedown"/>
            </svg>
        </g>
        <xsl:choose>
            <xsl:when test="./type[fold]">
                <desc  xmlns="http://www.w3.org/2000/svg">Type fold</desc>
                <xsl:call-template name="leftEndleavesSeparatePastedown-Fold">
                    <xsl:with-param name="pastedownRegistrationX" select="$pastedownRegistrationX"/>
                    <xsl:with-param name="pastedownRegistrationY" select="$pastedownRegistrationY"/>
                    <xsl:with-param name="countComponents" select="$countComponents"/>
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
                <desc xmlns="http://www.w3.org/2000/svg">Type not checked, not known, or other type</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="leftEndleavesSeparatePastedown-Fold">
        <xsl:param name="pastedownRegistrationX"/>
        <xsl:param name="pastedownRegistrationY"/>
        <xsl:param name="countComponents"/>
        <xsl:variable name="folioRegistrationX" select="$XoutermostG + 10"/>
        <xsl:variable name="folioRegistrationY" select="$YoutermostG - $deltaFlyleaves"/>
        <xsl:variable name="deltaQBcurve" select="$deltaFlyleaves * 2"/>
        <g xmlns="http://www.w3.org/2000/svg">
            <svg>
                <xsl:attribute name="x">
                    <xsl:value-of select="$folioRegistrationX"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="$folioRegistrationY"/>
                </xsl:attribute>
                <use xlink:href="#flyleaf"/>
            </svg>
        </g>
        <g stroke="#000000" stroke-width="1" fill="none" xmlns="http://www.w3.org/2000/svg">
            <desc>Parametric path describing the fold from the flyleaf to the pastedown</desc>
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M&#32;</xsl:text>
                    <xsl:value-of select="$folioRegistrationX + 1"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$folioRegistrationY + 1"/>
                    <xsl:text>&#32;Q&#32;</xsl:text>
                    <xsl:value-of select="($folioRegistrationX + 1) - $deltaQBcurve"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$folioRegistrationY + 1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="($folioRegistrationX + 1) - $deltaQBcurve"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($folioRegistrationY + 1) - $deltaQBcurve"/>
                    <!-- CHECK -->
                    <!-- CHECK: is the Line element in path necessary to allow for multiple components?? -->
                    <!-- CHECK -->
                    <xsl:text>&#32;L&#32;</xsl:text>
                    <xsl:value-of select="($folioRegistrationX + 1) - $deltaQBcurve"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($folioRegistrationY + 1) - $deltaQBcurve"/>
                    <xsl:text>&#32;Q&#32;</xsl:text>
                    <xsl:value-of select="($folioRegistrationX + 1) - $deltaQBcurve"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$pastedownRegistrationY + 1"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$pastedownRegistrationX + 131"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$pastedownRegistrationY + 1"/>
                </xsl:attribute>
            </path>
        </g>
        <xsl:call-template name="componentAttachment">
            <xsl:with-param name="XsewnComponent" select="($XoutermostG + 1) + ($deltaFlyleaves * 1.5)"/>
            <xsl:with-param name="CountComponents" select="$countComponents"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="componentAttachment">
        <xsl:param name="XsewnComponent"/>
        <xsl:param name="CountComponents"/>
        <xsl:choose>
            <xsl:when test="./attachment[sewn]">
                <desc xmlns="http://www.w3.org/2000/svg">Sewn component</desc>
                <xsl:call-template name="sewnComponent">
                    <xsl:with-param name="XsewnComponent" select="$XsewnComponent"/>
                    <xsl:with-param name="CountComponents" select="$CountComponents"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="./attachment[glued]">
                <desc xmlns="http://www.w3.org/2000/svg">Glued component</desc>
            </xsl:when>
            <xsl:otherwise>
                <desc xmlns="http://www.w3.org/2000/svg">Attachment method not checked, not known, or other</desc>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sewnComponent">
        <xsl:param name="XsewnComponent"/>
        <xsl:param name="CountComponents"/>
        <g stroke="#000000" stroke-width="0.5" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path>
                <xsl:attribute name="d">
                    <xsl:text>M&#32;</xsl:text>
                    <xsl:value-of select="$XsewnComponent"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($YoutermostG + 1) - ($deltaFlyleaves * $CountComponents) - 5"/>
                    <xsl:text>&#32;L&#32;</xsl:text>
                    <xsl:value-of
                        select="$XsewnComponent - ($deltaFlyleaves * ($CountComponents +1))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="($YoutermostG + 1) - ($deltaFlyleaves * $CountComponents) - 5"/>
                </xsl:attribute>
            </path>
        </g>
    </xsl:template>

    <!--    <xsl:template name="rightEndleaves" match="/book/endleaves[right]">
        <desc>Right endleaves</desc>
    </xsl:template>-->

</xsl:stylesheet>
