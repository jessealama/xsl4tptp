<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="utils/die.xsl"/>
  <xsl:import href="utils/list.xsl"/>
  <xsl:output method="text"/>

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
    <xsl:text>(</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="formula"/>
    <xsl:text>
</xsl:text>
    <xsl:text>)</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="formula[not(@name)]">
    <xsl:apply-templates select="." mode="die">
      <xsl:with-param name="message">
        <xsl:text>Error: formulas must have names.</xsl:text>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="formula[not(@syntax)]">
    <xsl:apply-templates select="." mode="die">
      <xsl:with-param name="message">
        <xsl:text>Error: formulas must have a syntax.</xsl:text>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="formula[not(@status)]">
    <xsl:apply-templates select="." mode="die">
      <xsl:with-param name="message">
        <xsl:text>Error: formulas must have a status.</xsl:text>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="formula[@name and @syntax and @status]">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="status" select="@status"/>
    <xsl:variable name="syntax" select="@syntax"/>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$syntax"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$n"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$status"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:if test="source">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="source"/>
    </xsl:if>
    <xsl:if test="useful-info">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="useful-info"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="source[not(non-logical-data) and not(number) and not(string)]">
    <xsl:message terminate="yes">
      <xsl:text>Error: don&apos;t know how to handle a source node that lacks a non-logical-data child, a number child, and a string child.</xsl:text>
    </xsl:message>
  </xsl:template>

  <xsl:template match="source[non-logical-data]">
    <xsl:apply-templates select="non-logical-data"/>
  </xsl:template>

  <xsl:template match="source[number]">
    <xsl:apply-templates select="number"/>
  </xsl:template>

  <xsl:template match="source[string]">
    <xsl:apply-templates select="string"/>
  </xsl:template>

  <xsl:template match="useful-info[not(non-logical-data) and not(number) and not(string)]">
    <xsl:message terminate="yes">
      <xsl:text>Error: don&apos;t know how to handle a useful-info node that lacks a non-logical-data child, a number child, and a string child.</xsl:text>
    </xsl:message>
  </xsl:template>

  <xsl:template match="useful-info[non-logical-data]">
    <xsl:apply-templates select="non-logical-data"/>
  </xsl:template>

  <xsl:template match="useful-info[string]">
    <xsl:apply-templates select="string"/>
  </xsl:template>

  <xsl:template match="non-logical-data[number]">
    <xsl:apply-templates select="number"/>
  </xsl:template>

  <xsl:template match="non-logical-data[@name and *]">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="separ">
        <xsl:text> </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="non-logical-data[@name and not(*)]">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template match="non-logical-data[not(@name)]">
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="separ">
        <xsl:text> </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="number">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template match="string">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Rendering TPTP formulas -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="disjunction">
    <xsl:text>(or </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="conjunction">
    <xsl:text>(and </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="implication">
    <xsl:text>(implies </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="reverse-implication">
    <xsl:text>(implies </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="equivalence">
    <xsl:text>(iff </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="nonequivalence">
    <xsl:text>(xor </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="predicate[@name]">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text> </xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="negation">
    <xsl:text>(not </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;universal&quot;]">
    <xsl:text>(all </xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text> </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;existential&quot;]">
    <xsl:text>(exists </xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text> </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name = &quot;false&quot;]">
    <xsl:text>(false)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name = &quot;true&quot;]">
    <xsl:text>(true)</xsl:text>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Terms -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="function[@name]">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text> </xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="variable[@name]">
    <xsl:text>?</xsl:text>
    <xsl:value-of select="@name"/>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Strings -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="string[@name]">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="quote">
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:value-of select="concat ($quote, $n, $quote)"/>
  </xsl:template>
</xsl:stylesheet>
