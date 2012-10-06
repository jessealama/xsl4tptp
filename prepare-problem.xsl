<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="utils/token-strings.xsl"/>
  <xsl:import href="utils/copy.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="conjecture">
    <xsl:text/>
  </xsl:param>
  <xsl:param name="premises">
    <xsl:text/>
  </xsl:param>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$conjecture = &quot;&quot;">
        <xsl:message terminate="yes">
          <xsl:text>Error: a (name for a) conjecture formula must be supplied.</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:when test="not(tstp)">
        <xsl:message terminate="yes">
          <xsl:text>Error: this stylesheet is supposed to be applied to an XMLized TPTP file, but the mandatory tstp document node is missing.</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:when test="not(tstp/formula[@name = $conjecture])">
        <xsl:message terminate="yes">
          <xsl:value-of select="concat (&quot;Error: there is no formula with the name &apos;&quot;, $conjecture, &quot;&apos;.&quot;)"/>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="tstp">
          <xsl:apply-templates select="formula[@name = $conjecture]" mode="conjecture"/>
          <xsl:if test="not($premises = &quot;&quot;)">
            <xsl:variable name="valid">
              <xsl:call-template name="token-string-is-valid">
                <xsl:with-param name="string" select="$premises"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$valid = &quot;1&quot;">
                <xsl:apply-templates select=".">
                  <xsl:with-param name="premises-to-emit" select="$premises"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">
                  <xsl:value-of select="concat (&quot;Error: &apos;&quot;, $premises, &quot;&apos; is not a valid token string.&quot;)"/>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp">
    <xsl:param name="premises-to-emit"/>
    <xsl:variable name="empty">
      <xsl:call-template name="token-string-is-empty">
        <xsl:with-param name="token-string" select="$premises-to-emit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$empty = &quot;1&quot;"/>
      <xsl:otherwise>
        <xsl:variable name="head">
          <xsl:call-template name="token-string-head">
            <xsl:with-param name="token-string" select="$premises-to-emit"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="tail">
          <xsl:call-template name="token-string-tail">
            <xsl:with-param name="token-string" select="$premises-to-emit"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="formula[@name = $head]">
            <xsl:apply-templates select="formula[@name = $head][1]" mode="axiom"/>
            <xsl:apply-templates select=".">
              <xsl:with-param name="premises-to-emit" select="$tail"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:value-of select="concat (&quot;Error: there is no formula by the name &apos;&quot;, $head, &quot;&apos;.&quot;)"/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="formula" mode="conjecture">
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="status">
        <xsl:text>conjecture</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*" mode="copy"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula" mode="axiom">
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:attribute name="status">
        <xsl:text>axiom</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*" mode="copy"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
