<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="render-tptp.xsl"/>
  <xsl:output method="text"/>
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- Stylesheet parameters -->
  <!-- //////////////////////////////////////////////////////////////////// -->
  <!-- If '1', any function symbol whose name starts with skolem-prefix -->
  <!-- will be ignored.  (See the skolem-prefix stylesheet parameter.) -->
  <xsl:param name="ignore-skolems">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- Any function starting with this prefix will be considered a skolem -->
  <!-- function. -->
  <xsl:param name="skolem-prefix">
    <xsl:text>sK</xsl:text>
  </xsl:param>
  <!-- If we are not ignoring skolems, and this is '1', we will print them -->
  <!-- last.  If we are not ignoring skolems and this is not '1', then -->
  <!-- skolems will be presented in whatever order they appear in in the -->
  <!-- given interpretation.  (If we are ignoring skolems, the value of -->
  <!-- this variable is immaterial.) -->
  <xsl:param name="skolems-last">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <xsl:param name="splitting-prefix">
    <xsl:text>sP</xsl:text>
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
          <xsl:text>Error: the required tstp document element is missing.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tstp[not(formula[@name = &quot;domain&quot;])]">
    <xsl:message terminate="yes">
      <xsl:text>Error: the required domain formula is missing.</xsl:text>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tstp[formula[@name = &quot;domain&quot;]]">
    <xsl:apply-templates select="formula[@name = &quot;domain&quot;]"/>
    <xsl:if test="formula[@status = &quot;fi_predicates&quot;]">
      <xsl:for-each select="formula[@status = &quot;fi_predicates&quot;
                      and not(starts-with(@name, $splitting-prefix))]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="formula[@status = &quot;fi_functors&quot;]">
      <xsl:choose>
        <xsl:when test="$ignore-skolems = &quot;1&quot;">
          <xsl:apply-templates select="formula[@status = &quot;fi_functors&quot;
                       and not(starts-with (@name, $skolem-prefix))]"/>
        </xsl:when>
        <xsl:when test="$skolems-last = &quot;1&quot;">
          <xsl:apply-templates select="formula[@status = &quot;fi_functors&quot;
                       and not(starts-with (@name, $skolem-prefix))]"/>
          <xsl:apply-templates select="formula[@status = &quot;fi_functors&quot;
                       and starts-with (@name, $skolem-prefix)]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="formula[@status = &quot;fi_functors&quot;]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print-domain">
    <xsl:for-each select="quantifier[@type = &quot;universal&quot;]">
      <xsl:for-each select="*[position() = last()]">
        <xsl:choose>
          <xsl:when test="self::disjunction">
            <xsl:for-each select="predicate[@name = &quot;=&quot;]">
              <xsl:apply-templates select="." mode="emit-rhs"/>
              <xsl:if test="position() &lt; last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:text>
</xsl:text>
          </xsl:when>
          <xsl:when test="self::predicate">
            <xsl:apply-templates select="." mode="emit-rhs"/>
            <xsl:text>
</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>Error: unable to handle a domain formula whose matrix is neither an atom nor a disjunction.</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="formula[@name = &quot;domain&quot; and quantifier[@type = &quot;universal&quot;]]">
    <xsl:text>Domain: </xsl:text>
    <xsl:call-template name="print-domain"/>
  </xsl:template>

  <xsl:template match="formula[@name = &quot;domain&quot; and not(quantifier[@type = &quot;universal&quot;])]">
    <xsl:message terminate="yes">
      <xsl:text>Error: the domain formula does not have the expected shape (universal quantification).</xsl:text>
    </xsl:message>
  </xsl:template>

  <xsl:template match="formula[@status = &quot;fi_predicates&quot; or @status = &quot;fi_functors&quot;]">
    <xsl:value-of select="@name"/>
    <xsl:text>
</xsl:text>
    <xsl:for-each select="*[1]">
      <xsl:for-each select="descendant::*[not(self::conjunction) and parent::conjunction]">
        <xsl:apply-templates select="."/>
        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="equivalence[*[2][self::defined-predicate[@name = &quot;true&quot;]]]">
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>

  <xsl:template match="equivalence[*[2][self::defined-predicate[@name = &quot;false&quot;]]]">
    <xsl:text>~</xsl:text>
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>

  <xsl:template match="*" mode="emit-rhs">
    <xsl:choose>
      <xsl:when test="count (*) = 2">
        <xsl:apply-templates select="*[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Error: we cannot print the right-hand side of an element that does not have exactly two children.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
