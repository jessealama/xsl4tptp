<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="render-tptp.xsl"/>
  <xsl:output method="text"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- The field of the formula that we are after -->
  <xsl:param name="field">
    <xsl:text/>
  </xsl:param>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Templates -->
  <!-- //////////////////////////////////////////////////////////////////// -->
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
    <xsl:choose>
      <xsl:when test="count (formula) &gt; 1">
        <xsl:message terminate="yes">
          <xsl:text>Error: this stylesheet should be applied only to TPTP problems/TSTP solutions containing a single formula.</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="formula"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="formula">
    <xsl:choose>
      <xsl:when test="$field = &quot;name&quot;">
        <xsl:value-of select="@name"/>
      </xsl:when>
      <xsl:when test="$field = &quot;status&quot;">
        <xsl:value-of select="@status"/>
      </xsl:when>
      <xsl:when test="$field = &quot;syntax&quot;">
        <xsl:value-of select="@syntax"/>
      </xsl:when>
      <xsl:when test="$field = &quot;formula&quot;">
        <xsl:apply-templates select="*[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:value-of select="concat (&quot;Error: unknown target field &apos;&quot;, $field, &quot;&apos;.&quot;)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
