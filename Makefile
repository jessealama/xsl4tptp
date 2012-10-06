java = java
xsltxt.jar = xsltxt.jar

%.xsl: %.xsltxt
	$(java) -jar $(xsltxt.jar) toXSL $*.xsltxt $*.xsl || (rm -f $*.xsl; false);

all: name-formulas.xsl ignore-axioms.xsl ignore-conjecture.xsl normalize-step-names.xsl sort-tstp.xsl tstp-dependencies.xsl render-tptp.xsl tptp-info.xsl paradox-interpretation.xsl tptp-to-lisp.xsl used-premises.xsl tptp-to-latex.xsl

clean:
	rm -f *.xsl
