<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="utils/copy.xsl"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="tstp">
        <xsl:apply-templates select="tstp"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Error: the required tstp document element is missing.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp">
    <xsl:element name="tstp">
      <xsl:apply-templates select="formula"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula">
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:value-of select="count (preceding-sibling::formula) + 1"/>
      </xsl:attribute>
      <xsl:apply-templates select="*" mode="copy"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
