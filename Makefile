JAVA = java
XSLTXT = xsltxt.jar

%.xsl: %.xsltxt
	$(JAVA) -jar $(XSLTXT) toXSL $*.xsltxt $*.xsl || rm $*.xsl;

all: name-formulas.xsl ignore-axioms.xsl normalize-step-names.xsl sort-tstp.xsl tstp-dependencies.xsl

clean:
	rm -f *.xsl
