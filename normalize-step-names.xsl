<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="utils/trace.xsl"/>
  <xsl:include href="utils/copy.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:param name="axiom-prefix">
    <xsl:text>ax</xsl:text>
  </xsl:param>
  <xsl:param name="step-prefix">
    <xsl:text>step</xsl:text>
  </xsl:param>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Keys -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:key name="non-axioms" match="formula[not(@status = &quot;axiom&quot;)]" use="@name"/>
  <xsl:key name="axioms" match="formula[@status = &quot;axiom&quot;]" use="@name"/>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Templates -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- If we don't handle something explicitly, we don't handle it at all. -->
  <xsl:template match="*">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:variable name="message" select="concat (&quot;Error: we have arrived at an unhandled &quot;, $n, &quot; node.&quot;)"/>
    <xsl:apply-templates select="." mode="trace"/>
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
    <xsl:element name="tstp">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="formula"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[not(source)]">
    <xsl:variable name="pos" select="count (preceding-sibling::formula[@status = &quot;axiom&quot;]) + 1"/>
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:value-of select="concat ($axiom-prefix, $pos)"/>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]" mode="copy"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;axiom&quot; and source]">
    <xsl:variable name="pos" select="count (preceding-sibling::formula[@status = &quot;axiom&quot;]) + 1"/>
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:value-of select="concat ($axiom-prefix, $pos)"/>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]" mode="copy"/>
      <xsl:apply-templates select="source"/>
      <xsl:if test="useful-info">
        <xsl:apply-templates select="useful-info" mode="copy"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[not(@status = &quot;axiom&quot;) and source]">
    <xsl:variable name="pos" select="count (preceding-sibling::formula[not(@status = &quot;axiom&quot;)]) + 1"/>
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:value-of select="concat ($step-prefix, $pos)"/>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]" mode="copy"/>
      <xsl:apply-templates select="source"/>
      <xsl:if test="useful-info">
        <xsl:apply-templates select="useful-info" mode="copy"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;negated_conjecture&quot;]">
    <xsl:variable name="pos" select="count (preceding-sibling::formula[not(@status = &quot;axiom&quot;)]) + 1"/>
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:value-of select="concat ($step-prefix, $pos)"/>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]" mode="copy"/>
      <xsl:if test="source">
        <xsl:apply-templates select="source"/>
      </xsl:if>
      <xsl:if test="useful-info">
        <xsl:apply-templates select="useful-info" mode="copy"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;conjecture&quot;]">
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="name">
        <xsl:text>goal</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]" mode="copy"/>
      <xsl:if test="source">
        <xsl:apply-templates select="source"/>
      </xsl:if>
      <xsl:if test="useful-info">
        <xsl:apply-templates select="useful-info" mode="copy"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="maybe-rewrite">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:variable name="message" select="concat (&quot;Error: we have arrived at an unhandled &quot;, $n, &quot; node in maybe-rewrite mode.&quot;)"/>
    <xsl:apply-templates select="." mode="trace"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="non-logical-data[@name]" mode="maybe-rewrite">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="nld" select="."/>
    <xsl:choose>
      <xsl:when test="key (&quot;axioms&quot;, $n)">
        <xsl:for-each select="key (&quot;axioms&quot;, $n)">
          <xsl:element name="non-logical-data">
            <xsl:variable name="other-position" select="count (preceding-sibling::formula[@status = &quot;axiom&quot;]) + 1"/>
            <xsl:attribute name="name">
              <xsl:value-of select="concat ($axiom-prefix, $other-position)"/>
            </xsl:attribute>
            <xsl:for-each select="$nld">
              <xsl:apply-templates select="*" mode="maybe-rewrite"/>
            </xsl:for-each>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="key (&quot;non-axioms&quot;, $n)">
        <xsl:for-each select="key (&quot;non-axioms&quot;, $n)">
          <xsl:element name="non-logical-data">
            <xsl:variable name="other-position" select="count (preceding-sibling::formula[not(@status = &quot;axiom&quot;)]) + 1"/>
            <xsl:attribute name="name">
              <xsl:value-of select="concat ($step-prefix, $other-position)"/>
            </xsl:attribute>
            <xsl:for-each select="$nld">
              <xsl:apply-templates select="*" mode="maybe-rewrite"/>
            </xsl:for-each>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message" select="concat (&quot;Warning: unknown formula &apos;&quot;, $n, &quot;&apos;.&quot;)"/>
        <xsl:message terminate="no">
          <xsl:value-of select="$message"/>
        </xsl:message>
        <xsl:element name="non-logical-data">
          <xsl:for-each select="@*">
            <xsl:copy-of select="."/>
          </xsl:for-each>
          <xsl:apply-templates select="*" mode="maybe-rewrite"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="number[@name]" mode="maybe-rewrite">
    <xsl:variable name="n" select="@name"/>
    <xsl:choose>
      <xsl:when test="key (&quot;axioms&quot;, $n)">
        <xsl:for-each select="key (&quot;axioms&quot;, $n)">
          <xsl:element name="non-logical-data">
            <xsl:variable name="other-position" select="count (preceding-sibling::formula[@status = &quot;axiom&quot;]) + 1"/>
            <xsl:attribute name="name">
              <xsl:value-of select="concat ($axiom-prefix, $other-position)"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="key (&quot;non-axioms&quot;, $n)">
        <xsl:for-each select="key (&quot;non-axioms&quot;, $n)">
          <xsl:element name="non-logical-data">
            <xsl:variable name="other-position" select="count (preceding-sibling::formula[not(@status = &quot;axiom&quot;)]) + 1"/>
            <xsl:attribute name="name">
              <xsl:value-of select="concat ($step-prefix, $other-position)"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message" select="concat (&quot;Warning: unknown formula &apos;&quot;, $n, &quot;&apos;.&quot;)"/>
        <xsl:message terminate="no">
          <xsl:value-of select="$message"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="non-logical-data[not(@name)]" mode="maybe-rewrite">
    <xsl:element name="non-logical-data">
      <xsl:apply-templates select="*" mode="maybe-rewrite"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="source">
    <xsl:element name="source">
      <xsl:for-each select="*">
        <xsl:apply-templates select="." mode="maybe-rewrite"/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
