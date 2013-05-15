leibniz.xml : leibniz.p
	tptp4X -c -x -umachine -fxml leibniz.p > leibniz.xml || rm -f leibniz.xml

gdv.xsl : gdv.xsltxt
	java -jar xsltxt.jar toXSL $< $@ || rm -f $@

%.ax.xml : leibniz.xml gdv.xsl
	xsltproc --output $@ --stringparam problem "$*" gdv.xsl leibniz.xml

render-tptp.xsl : render-tptp.xsltxt
	java -jar xsltxt.jar toXSL $< $@ || rm -f $@

%.ax : %.ax.xml render-tptp.xsl
	xsltproc --output $@ render-tptp.xsl $< || rm -f $@
