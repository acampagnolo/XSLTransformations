<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs svg xlink" version="2.0">

    <xsl:output method="xhtml" indent="yes" encoding="UTF-8"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        omit-xml-declaration="no" standalone="no"/>

    <xsl:template match="/">
        <xsl:element name="html" xpath-default-namespace="http://www.w3.org/1999/xhtml">
            <xsl:element name="head">
                <xsl:element name="title">
                    <xsl:value-of select="/svg:svg/svg:desc"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="body">
                <xsl:copy-of select="/svg:svg"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
