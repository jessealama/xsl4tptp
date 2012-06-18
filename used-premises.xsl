<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <xsl:key name="formulas" match="formula" use="@name"/>

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
    <xsl:apply-templates select="formula"/>
  </xsl:template>

  <xsl:template match="formula[not(source)]">
    <xsl:text/>
  </xsl:template>

  <xsl:template match="formula[source]">
    <xsl:apply-templates select="source"/>
  </xsl:template>

  <xsl:template match="source">
    <xsl:for-each select="descendant::*[@name]">
      <xsl:variable name="n" select="@name"/>
      <xsl:if test="key (&quot;formulas&quot;, $n)">
        <xsl:value-of select="$n"/>
        <xsl:text>
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
