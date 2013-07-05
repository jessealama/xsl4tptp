<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="utils/die.xsl"/>
  <xsl:include href="utils/list.xsl"/>
  <xsl:output method="text"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Variables -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:variable name="newline" select="&apos;&#10;&apos;"/>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Templates -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- If we don't handle something explicitly, we don't handle it at all. -->
  <xsl:template match="*">
    <xsl:variable name="n" select="name (.)"/>
    <xsl:variable name="message" select="concat (&quot;Error: we have arrived at an unhandled &quot;, $n, &quot; node.&quot;)"/>
    <xsl:apply-templates select="." mode="die">
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
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
    <xsl:for-each select="node()">
      <xsl:apply-templates select="."/>
      <xsl:choose>
        <xsl:when test="self::text()"/>
        <xsl:otherwise>
          <xsl:text>
</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="comment">
    <xsl:for-each select="text()">
      <xsl:variable name="s" select="."/>
      <xsl:variable name="c">
        <xsl:call-template name="chomp">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:message>
        <xsl:value-of select="concat (&quot;before chomping:&quot;, &quot;
&quot;, $s, &quot;
&quot;, &quot;after chomping:&quot;, &quot;
&quot;, $c)"/>
      </xsl:message>
      <xsl:call-template name="emit-percents">
        <xsl:with-param name="s" select="$c"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- if the string starts with a newline, delete it -->
  <xsl:template name="chomp-front">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="starts-with ($s, $newline)">
        <xsl:value-of select="substring-after ($s, $newline)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>does not start with newline</xsl:text>
        </xsl:message>
        <xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chomp-tail">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains ($s, $newline)">
        <xsl:variable name="before" select="substring-before ($s, $newline)"/>
        <xsl:choose>
          <xsl:when test="contains ($before, $newline)">
            <xsl:variable name="chomped">
              <xsl:call-template name="chomp-tail">
                <xsl:with-param name="s" select="substring-after ($before, $newline)"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat ($before, $newline, $chomped)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$before"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chomp">
    <xsl:param name="s"/>
    <xsl:variable name="front">
      <xsl:call-template name="chomp-front">
        <xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="chomp-tail">
      <xsl:with-param name="s" select="$front"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="emit-percents">
    <xsl:param name="s"/>
    <xsl:value-of select="translate ($s, $newline, &quot;%&quot;)"/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="formula[@syntax = &quot;formula&quot; and @status and @name]">
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@status"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:if test="source">
      <xsl:apply-templates select="source"/>
    </xsl:if>
    <xsl:if test="useful-info">
      <xsl:apply-templates select="useful-info"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
    <xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="formula[@syntax = &quot;clause&quot; and @status and @name]">
    <xsl:text>cnf(</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@status"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:if test="source">
      <xsl:apply-templates select="source"/>
    </xsl:if>
    <xsl:if test="useful-info">
      <xsl:apply-templates select="useful-info"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
    <xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="number[@name]">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template match="non-logical-data[@name and (non-logical-data or number)]">
    <xsl:value-of select="@name"/>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="non-logical-data | number"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="non-logical-data[@name and not(non-logical-data or number)]">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template match="non-logical-data[not(@name) and (non-logical-data or number)]">
    <xsl:text>[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="non-logical-data | number"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="non-logical-data[not(@name) and not(non-logical-data) and not(number)]">
    <xsl:text>[]</xsl:text>
  </xsl:template>

  <xsl:template match="source">
    <xsl:choose>
      <xsl:when test="non-logical-data and number">
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="non-logical-data | number"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="non-logical-data[@name]">
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="non-logical-data[@name]"/>
      </xsl:when>
      <xsl:when test="number">
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="number"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="useful-info">
    <xsl:choose>
      <xsl:when test="non-logical-data[@name]">
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="non-logical-data[@name]"/>
      </xsl:when>
      <xsl:when test="non-logical-data[not(@name)] or number">
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="non-logical-data | number"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="number">
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="number"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Formulas proper -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="disjunction">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> | </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="conjunction">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> &amp; </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="implication">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> =&gt; </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="reverse-implication">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> &lt;= </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="equivalence">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> &lt;=&gt; </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="nonequivalence">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> &lt;~&gt; </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="predicate[@name = &quot;=&quot;]">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="predicate[@name and not(@name = &quot;=&quot;)]">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:value-of select="@name"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="negation">
    <xsl:text>~ </xsl:text>
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;universal&quot;]">
    <xsl:text>(! </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
    <xsl:text> : </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier[@type = &quot;existential&quot;]">
    <xsl:text>(? </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="variable"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
    <xsl:text> : </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name = &quot;false&quot;]">
    <xsl:text>$false</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name = &quot;true&quot;]">
    <xsl:text>$true</xsl:text>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Terms -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="function[@name]">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:value-of select="@name"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="variable[@name]">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Strings -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <xsl:template match="string[@name]">
    <xsl:variable name="n" select="@name"/>
    <xsl:value-of select="concat (&quot;&apos;&quot;, $n, &quot;&apos;&quot;)"/>
  </xsl:template>
</xsl:stylesheet>
