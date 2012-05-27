<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="utils/token-strings.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- A comma-delimited string (that also starts and ends -->
  <!-- with a comma) of the order of the nodes that we should print -->
  <xsl:param name="ordering">
    <xsl:text/>
  </xsl:param>

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
        <xsl:choose>
          <xsl:when test="$ordering = &quot;&quot;">
            <xsl:element name="tstp">
              <xsl:for-each select="@*">
                <xsl:copy-of select="."/>
              </xsl:for-each>
              <xsl:apply-templates select="tstp">
                <xsl:with-param name="token-string">
                  <xsl:text>,,</xsl:text>
                </xsl:with-param>
              </xsl:apply-templates>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="ordering-ok">
              <xsl:call-template name="is-valid-token-string">
                <xsl:with-param name="string" select="$ordering"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$ordering-ok = &quot;1&quot;">
                <xsl:element name="tstp">
                  <xsl:for-each select="@*">
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                  <xsl:apply-templates select="tstp">
                    <xsl:with-param name="token-string" select="$ordering"/>
                  </xsl:apply-templates>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="message" select="concat (&quot;Error: the given ordering &apos;&quot;, $ordering, &quot;&apos; is not a valid token string.&quot;)"/>
                <xsl:message terminate="yes">
                  <xsl:value-of select="$message"/>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Error: the required tstp document element is missing.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp">
    <xsl:param name="token-string"/>
    <xsl:variable name="num-formulas" select="count (formula)"/>
    <xsl:variable name="num-commas-expected" select="$num-formulas + 1"/>
    <xsl:variable name="empty">
      <xsl:call-template name="token-string-is-empty">
        <xsl:with-param name="token-string" select="$token-string"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$empty = &quot;1&quot;"/>
      <xsl:otherwise>
        <xsl:variable name="head">
          <xsl:call-template name="token-string-head">
            <xsl:with-param name="token-string" select="$token-string"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="tail">
          <xsl:call-template name="token-string-tail">
            <xsl:with-param name="token-string" select="$token-string"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="formula[@name = $head]">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:apply-templates select=".">
          <xsl:with-param name="token-string" select="$tail"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="formula">
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
