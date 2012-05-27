<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Keys -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:key name="formulas" match="formula[@name]" use="@name"/>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Templates -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- If we don't handle something explicitly, we don't handle it at all. -->
  <xsl:template match="*">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:variable name="message" select="concat (&quot;Error: we have arrived at an unhandled &quot;, $n, &quot; node.&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

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

  <xsl:template match="formula[@name and @status = &quot;axiom&quot;]">
    <xsl:variable name="axiom-name" select="@name"/>
    <xsl:for-each select="parent::*">
      <xsl:for-each select="formula[@name and not(@status = &quot;axiom&quot;)]">
        <xsl:variable name="non-axiom-name" select="@name"/>
        <xsl:value-of select="$axiom-name"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$non-axiom-name"/>
        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="formula[@name and source and not(@status = &quot;axiom&quot;)]">
    <xsl:apply-templates select="source">
      <xsl:with-param name="formula" select="@name"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="source">
    <xsl:param name="formula"/>
    <xsl:for-each select="descendant::*[@name]">
      <xsl:variable name="n" select="@name"/>
      <xsl:if test="key (&quot;formulas&quot;, $n)">
        <xsl:for-each select="key (&quot;formulas&quot;, $n)">
          <xsl:value-of select="@name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$formula"/>
          <xsl:text>
</xsl:text>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
