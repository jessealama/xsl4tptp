<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="utils/list.xsl"/>
  <xsl:output method="text"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:param name="implication-sign">
    <xsl:text>rightarrow</xsl:text>
  </xsl:param>
  <xsl:param name="biimplication-sign">
    <xsl:text>leftrightarrow</xsl:text>
  </xsl:param>
  <xsl:param name="negation-sign">
    <xsl:text>neg</xsl:text>
  </xsl:param>
  <xsl:param name="conjunction-sign">
    <xsl:text>wedge</xsl:text>
  </xsl:param>
  <xsl:param name="disjunction-sign">
    <xsl:text>vee</xsl:text>
  </xsl:param>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Utilities -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template name="command-sequence">
    <xsl:param name="command"/>
    <xsl:value-of select="concat (&quot;&#92;&quot;, $command)"/>
  </xsl:template>

  <xsl:template name="escape-underscore">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="$s = &quot;&quot;">
        <xsl:text/>
      </xsl:when>
      <xsl:when test="contains ($s, &quot;_&quot;)">
        <xsl:variable name="before" select="substring-before ($s, &quot;_&quot;)"/>
        <xsl:variable name="after" select="substring-after ($s, &quot;_&quot;)"/>
        <xsl:variable name="escaped">
          <xsl:call-template name="escape-underscore">
            <xsl:with-param name="s" select="$after"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat ($before, &quot;&#92;&quot;, &quot;_&quot;, $escaped)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>begin</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>{description}</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="formula"/>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>end</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>{description}</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="formula">
    <xsl:text>item[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>]</xsl:text>
    <xsl:text>$</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>$</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Formulas proper -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="*">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="concat (&quot;Error: we have arrived at an unhandled &quot;, $n, &quot; node in render-latex mode.&quot;)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;universal&quot;]">
    <xsl:text>&#92;</xsl:text>
    <xsl:text>forall </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>left</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>[ </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>right</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;existential&quot;]">
    <xsl:text>&#92;</xsl:text>
    <xsl:text>exists </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>left</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>[ </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command">
        <xsl:text>right</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="implication">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$implication-sign"/>
    </xsl:call-template>
    <xsl:text>} </xsl:text>
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <xsl:template match="reverse-implication">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$implication-sign"/>
    </xsl:call-template>
    <xsl:text>} </xsl:text>
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>

  <xsl:template match="equivalence">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$biimplication-sign"/>
    </xsl:call-template>
    <xsl:text>} </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="nonequivalence">
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$negation-sign"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$biimplication-sign"/>
    </xsl:call-template>
    <xsl:text>} </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="predicate[* and @name = &quot;=&quot;]">
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <xsl:template match="predicate[* and not(@name = &quot;=&quot;)]">
    <xsl:call-template name="escape-underscore">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="predicate[not(*)]">
    <xsl:call-template name="escape-underscore">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="negation">
    <xsl:text>(</xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$negation-sign"/>
    </xsl:call-template>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="conjunction">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$conjunction-sign"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="disjunction">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="command-sequence">
      <xsl:with-param name="command" select="$disjunction-sign"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="variable">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template match="function[*]">
    <xsl:call-template name="escape-underscore">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="function[not(*)]">
    <xsl:call-template name="escape-underscore">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
