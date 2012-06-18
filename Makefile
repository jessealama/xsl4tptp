JAVA = java
XSLTXT = xsltxt.jar

%.xsl: %.xsltxt
	$(JAVA) -jar $(XSLTXT) toXSL $*.xsltxt $*.xsl || rm $*.xsl;

all: name-formulas.xsl ignore-axioms.xsl ignore-conjecture.xsl normalize-step-names.xsl sort-tstp.xsl tstp-dependencies.xsl render-tptp.xsl tptp-info.xsl paradox-interpretation.xsl tptp-to-lisp.xsl used-premises.xsl

clean:
	rm -f *.xsl
