<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- the name of the problem to inspect -->
  <xsl:param name="problem">
    <xsl:text/>
  </xsl:param>
  <!-- the action to take: extract axioms only, or create a problem -->
  <!-- Only two values are acceptable: 'axioms' and 'problem' -->
  <xsl:param name="action">
    <xsl:text>axioms</xsl:text>
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
          <xsl:text>Error: the tstp document element is missing.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp">
    <!-- Is the parameter sane? -->
    <xsl:if test="$problem = &quot;&quot;">
      <xsl:message terminate="yes">
        <xsl:text>Error: the empty string is not a suitable problem.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="$action = &quot;&quot;">
      <xsl:message terminate="yes">
        <xsl:text>Error: the empty string is not an appropriate value for the action paramter.  The acceptable values are &apos;problem&apos; (to extract a problem) and &apos;axioms&apos; (to extract just the axioms for a problem).</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not($action = &quot;problem&quot;) and not($action = &quot;axioms&quot;)">
      <xsl:variable name="message" select="concat (&quot;Error: inappropriate value&quot;, &quot;
&quot;, &quot;
&quot;, &quot;  &quot;, $action, &quot;
&quot;, &quot;
&quot;, &quot;for the action parameter.  The acceptable values are &apos;problem&apos; (to extract a problem) and &apos;axioms&apos; (to extract just the axioms for a problem).&quot;)"/>
      <xsl:message terminate="yes">
        <xsl:value-of select="$message"/>
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="formula[@name = $problem]">
        <xsl:element name="tstp">
          <xsl:choose>
            <xsl:when test="$action = &quot;problem&quot;">
              <xsl:apply-templates select="formula[@name = $problem]" mode="problem"/>
            </xsl:when>
            <xsl:when test="$action = &quot;axioms&quot;">
              <xsl:apply-templates select="formula[@name = $problem]" mode="axioms"/>
            </xsl:when>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message" select="concat (&quot;No formula by the name &apos;&quot;, $problem, &quot;&apos;.&quot;)"/>
        <xsl:message terminate="yes">
          <xsl:value-of select="$message"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="formula" mode="problem">
    <xsl:variable name="s" select="@status"/>
    <xsl:variable name="message" select="concat (&quot;Error: we arrived at an unhandled node of status &apos;&quot;, $s, &quot;&apos;.&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;definition&quot;]" mode="problem">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="message" select="concat (&quot;Error: &quot;, $n, &quot; is the name of a definition.  Why, then, are we trying to construct a theorem proving problem for it?&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;axiom&quot;]" mode="problem">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="message" select="concat (&quot;Error: &quot;, $n, &quot; is the name of an axiom.  Why, then, are we trying to construct a theorem proving problem for it?&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;lemma&quot; or @status = &quot;theorem&quot;]" mode="problem">
    <xsl:variable name="n" select="@name"/>
    <xsl:apply-templates select="." mode="strip-extras">
      <xsl:with-param name="status">
        <xsl:text>conjecture</xsl:text>
      </xsl:with-param>
    </xsl:apply-templates>
    <xsl:for-each select="source">
      <xsl:for-each select="non-logical-data[@name = &quot;depends&quot;]">
        <xsl:for-each select="non-logical-data[1]">
          <xsl:for-each select="non-logical-data[@name]">
            <xsl:variable name="dependency-n" select="@name"/>
            <xsl:for-each select="ancestor::tstp">
              <xsl:choose>
                <xsl:when test="formula[@name = $dependency-n]">
                  <xsl:for-each select="formula[@name = $dependency-n]">
                    <xsl:apply-templates select="." mode="strip-extras"/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="message" select="concat (&quot;Error: formula &quot;, $n, &quot; depends on &quot;, $dependency-n, &quot; but there appears to be no formula with that name.&quot;)"/>
                  <xsl:message terminate="yes">
                    <xsl:value-of select="$message"/>
                  </xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="formula" mode="axioms">
    <xsl:variable name="s" select="@status"/>
    <xsl:variable name="message" select="concat (&quot;Error: we arrived at an unhandled node of status &apos;&quot;, $s, &quot;&apos;.&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;definition&quot;]" mode="axioms">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="message" select="concat (&quot;Error: &quot;, $n, &quot; is the name of a definition.  Why, then, are we trying to extract the axioms of a theorem proving problem for it?&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;axiom&quot;]" mode="problem">
    <xsl:variable name="n" select="@name"/>
    <xsl:variable name="message" select="concat (&quot;Error: &quot;, $n, &quot; is the name of an axiom.  Why, then, are we trying to extract the axioms of a theorem proving problem for it?&quot;)"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;lemma&quot; or @status = &quot;theorem&quot;]" mode="axioms">
    <xsl:variable name="n" select="@name"/>
    <xsl:for-each select="source">
      <xsl:for-each select="non-logical-data[@name = &quot;depends&quot;]">
        <xsl:for-each select="non-logical-data[1]">
          <xsl:for-each select="non-logical-data[@name]">
            <xsl:variable name="dependency-n" select="@name"/>
            <xsl:for-each select="ancestor::tstp">
              <xsl:choose>
                <xsl:when test="formula[@name = $dependency-n]">
                  <xsl:for-each select="formula[@name = $dependency-n]">
                    <xsl:apply-templates select="." mode="strip-extras"/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="message" select="concat (&quot;Error: formula &quot;, $n, &quot; depends on &quot;, $dependency-n, &quot; but there appears to be no formula with that name.&quot;)"/>
                  <xsl:message terminate="yes">
                    <xsl:value-of select="$message"/>
                  </xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="strip-extras">
    <xsl:param name="status"/>
    <!-- By default, just copy and recurse -->
    <xsl:variable name="n" select="name (.)"/>
    <xsl:element name="{$n}">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="*" mode="strip-extras">
        <xsl:with-param name="status" select="$status"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="formula" mode="strip-extras">
    <xsl:param name="status"/>
    <xsl:element name="formula">
      <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:if test="not($status = &quot;&quot;)">
        <xsl:attribute name="status">
          <xsl:value-of select="$status"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*[1]" mode="strip-extras"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
