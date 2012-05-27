<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- If '1', the conjecture (if there is one) will be printed as an -->
  <!-- axiom.  Otherwise, the conjecture formula (if there is one) will -->
  <!-- simply be ignored. -->
  <xsl:param name="axiomatize">
    <xsl:text>0</xsl:text>
  </xsl:param>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Templates -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="*">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:element name="{$n}">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="tstp">
        <xsl:apply-templates select="tstp"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Error: the required tstp root element is missing.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp">
    <xsl:element name="tstp">
      <xsl:if test="$axiomatize = &quot;1&quot;">
        <xsl:for-each select="formula[@status = &quot;conjecture&quot;]">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </xsl:if>
      <xsl:for-each select="formula[not(@status = &quot;conjecture&quot;)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;conjecture&quot;]">
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="status">
        <xsl:text>axiom</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
